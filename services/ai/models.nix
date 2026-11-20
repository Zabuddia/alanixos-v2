{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Keep the established path so existing v1 model downloads remain reusable.
  stateDir = "/var/lib/llm";
  llamaPackage = pkgs-unstable.llama-cpp-vulkan;
  whisperPackage = pkgs.whisper-cpp-vulkan;

  # Every llama.cpp server accepts WireGuard connections and offloads all
  # supported model layers to the GPU with fused attention enabled.
  commonLlamaArgs = [
    "--host"
    "0.0.0.0"
    "--gpu-layers"
    "all"
    "--flash-attn"
    "on"
  ];

  mkLlamaService =
    {
      description,
      args,
    }:
    {
      inherit description;
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = stateDir;
        HF_HOME = "${stateDir}/huggingface";
        XDG_CACHE_HOME = "${stateDir}/cache";
      };
      serviceConfig = {
        User = "llm";
        Group = "llm";
        WorkingDirectory = stateDir;
        ExecStart = "${lib.getExe' llamaPackage "llama-server"} ${
          lib.escapeShellArgs (commonLlamaArgs ++ args)
        }";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

  # whisper.cpp's small model is downloaded once into persistent state. The
  # service then exposes the same transcription route used by the OpenAI API.
  whisperStart = pkgs.writeShellScript "ai-whisper-start" ''
    set -euo pipefail

    model_dir=${lib.escapeShellArg "${stateDir}/models/whisper"}
    model_path="$model_dir/ggml-small.bin"
    if [ ! -f "$model_path" ]; then
      cd "$model_dir"
      ${lib.getExe' whisperPackage "whisper-cpp-download-ggml-model"} small
    fi

    exec ${lib.getExe' whisperPackage "whisper-server"} \
      --host 0.0.0.0 \
      --port 8085 \
      --model "$model_path" \
      --language auto \
      --processors 1 \
      --request-path /v1/audio/transcriptions \
      --inference-path "" \
      --convert
  '';
in
{
  # Model files and caches are persistent runtime data owned by an unprivileged account.
  users.users.llm = {
    isSystemUser = true;
    group = "llm";
    home = stateDir;
    extraGroups = [
      "render"
      "video"
    ];
  };
  users.groups.llm = { };

  hardware.graphics.enable = true;

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 llm llm - -"
    "d ${stateDir}/cache 0750 llm llm - -"
    "d ${stateDir}/huggingface 0750 llm llm - -"
    "d ${stateDir}/models 0750 llm llm - -"
    "d ${stateDir}/models/whisper 0750 llm llm - -"
  ];

  # Raw model ports and LiteLLM are reachable through trusted WireGuard. The
  # normal firewall still blocks them on untrusted physical networks.
  systemd.services = {
    ai-qwen-vision = mkLlamaService {
      description = "Qwen 3.8 vision model";
      args = [
        # Public API identity and the context reserved for image conversations.
        "--port"
        "8086"
        "--alias"
        "qwen3.8-27b"
        "--ctx-size"
        "131072"
        "--batch-size"
        "2048"
        "--ubatch-size"
        "512"
        "--parallel"
        "1"
        # llama.cpp downloads the quantized model and vision projector from Hugging Face.
        "--hf-repo"
        "unsloth/Qwen3.8-27B-GGUF"
        "--hf-file"
        "Qwen3.8-27B-UD-Q5_K_XL.gguf"
        "--mmproj-url"
        "https://huggingface.co/unsloth/Qwen3.8-27B-GGUF/resolve/main/mmproj-F16.gguf"
        # Fixed sizing prevents llama.cpp from silently reducing the context.
        "--fit"
        "off"
        # Quantized key/value caches reduce GPU memory used by the long context.
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        # Qwen's small MTP draft model predicts several tokens ahead to improve speed.
        "--spec-type"
        "draft-mtp"
        "--spec-draft-hf"
        "ggml-org/Qwen3.8-27B-GGUF:Q4_0"
        "--spec-draft-ngl"
        "all"
        "--spec-draft-n-max"
        "4"
        # Image descriptions should return direct content without hidden reasoning.
        "--reasoning"
        "off"
      ];
    };

    ai-ornith = mkLlamaService {
      description = "Ornith reasoning and tool-use model";
      args = [
        # One large-context slot is dedicated to Jarvis's primary conversation.
        "--port"
        "8088"
        "--alias"
        "ornith-1.5-35b-a3b"
        "--ctx-size"
        "65536"
        "--batch-size"
        "2048"
        "--ubatch-size"
        "512"
        "--parallel"
        "1"
        # This quantization fits the mixture-of-experts model in local GPU memory.
        "--hf-repo"
        "ornith-ai/Ornith-1.5-35B-A3B-GGUF"
        "--hf-file"
        "Ornith-1.5-35B-Q4_K_M.gguf"
        "--fit"
        "off"
        # Retain reusable prompt prefixes in RAM and keep an exact KV cache for tools.
        "--cache-ram"
        "16384"
        "--cache-type-k"
        "f16"
        "--cache-type-v"
        "f16"
        # The embedded Jinja template formats tool calls for this model family.
        "--jinja"
        # Ornith is the reasoning model; low temperature keeps tool use predictable.
        "--reasoning"
        "on"
        "--temp"
        "0.25"
      ];
    };

    ai-embeddings = mkLlamaService {
      description = "Qwen memory embedding model";
      args = [
        # A smaller context and matching batch sizes are required for embedding mode.
        "--port"
        "8082"
        "--alias"
        "qwen3-embedding-4b"
        "--ctx-size"
        "8192"
        "--batch-size"
        "512"
        "--ubatch-size"
        "512"
        "--parallel"
        "1"
        "--hf-repo"
        "Qwen/Qwen3-Embedding-4B-GGUF"
        "--hf-file"
        "Qwen3-Embedding-4B-Q5_K_M.gguf"
        # Disable chat generation and expose only the embeddings API.
        "--embeddings"
      ];
    };

    ai-whisper = {
      description = "Whisper audio transcription API";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        coreutils
        curl
        ffmpeg
        gnugrep
      ];
      environment.HOME = stateDir;
      serviceConfig = {
        User = "llm";
        Group = "llm";
        WorkingDirectory = stateDir;
        ExecStart = whisperStart;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

  };

  # The native module supplies the service account, writable state, tokenizer
  # cache, hardening, and config-file generation for the shared model endpoint.
  services.litellm = {
    enable = true;
    host = "0.0.0.0";
    port = 4000;
    openFirewall = false;
    settings.model_list = [
      {
        model_name = "qwen3.8-27b";
        litellm_params = {
          model = "openai/qwen3.8-27b";
          api_base = "http://127.0.0.1:8086/v1";
          api_key = "local";
        };
      }
      {
        model_name = "ornith-1.5-35b-a3b";
        litellm_params = {
          model = "openai/ornith-1.5-35b-a3b";
          api_base = "http://127.0.0.1:8088/v1";
          api_key = "local";
        };
      }
      {
        model_name = "qwen3-embedding-4b";
        litellm_params = {
          model = "openai/qwen3-embedding-4b";
          api_base = "http://127.0.0.1:8082/v1";
          api_key = "local";
        };
        model_info.mode = "embedding";
      }
      {
        model_name = "whisper-small";
        litellm_params = {
          model = "openai/whisper-small";
          api_base = "http://127.0.0.1:8085/v1";
          api_key = "local";
        };
        model_info.mode = "audio_transcription";
      }
    ];
  };

}

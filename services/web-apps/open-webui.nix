{ pkgs-unstable, ... }:

{
  # Open WebUI is the browser interface for models served by the AI server.
  services.open-webui = {
    enable = true;
    package = pkgs-unstable.open-webui.overrideAttrs (old: {
      # Nixpkgs currently passes these three wrapper arguments as one string,
      # which the shell-wrapper hook rejects after the package has built.
      makeWrapperArgs = [
        "--set"
        "FRONTEND_BUILD_DIR"
        "${old.passthru.frontend}/share/open-webui"
      ];
    });
    # Caddy is the only network-facing process; the application stays private.
    host = "127.0.0.1";
    port = 18080;
    openFirewall = false;

    environment = {
      WEBUI_AUTH = "True";
      ENABLE_PASSWORD_AUTH = "True";
      ENABLE_LOGIN_FORM = "True";
      # Existing accounts remain application-managed. Disabling public signup
      # prevents a fresh Internet visitor from claiming the administrator role.
      ENABLE_INITIAL_ADMIN_SIGNUP = "False";
      ENABLE_SIGNUP = "False";
      DEFAULT_USER_ROLE = "pending";
      WEBUI_URL = "https://openwebui.fifefin.com";

      # LiteLLM presents every local model through one OpenAI-compatible API.
      ENABLE_OPENAI_API = "True";
      OPENAI_API_BASE_URLS = "http://alan-ai-server:4000/v1";
      OPENAI_API_KEYS = "none";
      ENABLE_OLLAMA_API = "False";

      # Searches remain local to the SearXNG service on this machine.
      ENABLE_WEB_SEARCH = "True";
      WEB_SEARCH_ENGINE = "searxng";
      WEB_SEARCH_RESULT_COUNT = "6";
      BYPASS_WEB_SEARCH_WEB_LOADER = "True";
      SEARXNG_QUERY_URL = "http://127.0.0.1:8888/search?q=<query>&format=json";
    };
  };
}

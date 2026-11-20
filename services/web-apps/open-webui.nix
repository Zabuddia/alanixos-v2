{
  # Open WebUI is the browser interface for models served by the AI server.
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 18080;
    openFirewall = false;

    environment = {
      WEBUI_AUTH = "True";
      ENABLE_PASSWORD_AUTH = "True";
      ENABLE_LOGIN_FORM = "True";
      ENABLE_INITIAL_ADMIN_SIGNUP = "True";
      ENABLE_SIGNUP = "True";
      DEFAULT_USER_ROLE = "pending";

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

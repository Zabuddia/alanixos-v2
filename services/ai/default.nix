{
  # Keep each independently useful part of the AI stack in its own module.
  imports = [
    ./models.nix # Local inference servers and their shared API.
    ./openclaw.nix # Jarvis gateway, tools, secrets, and workspace.
    ./speech.nix # Home Assistant's Wyoming speech services.
  ];
}

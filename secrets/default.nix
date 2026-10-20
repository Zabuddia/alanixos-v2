{ hostname, ... }:

{
  # Every machine receives only the encrypted document addressed to its age key.
  sops.defaultSopsFile = ./hosts/${hostname}.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}

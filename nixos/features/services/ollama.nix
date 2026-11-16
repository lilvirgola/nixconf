{
  flake.nixosModules.ollama = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # Down on boot by default (0 VRAM idle) — start on-demand with `ollama-up`
    services.ollama = {
      enable = true;
      package =
        if config.custom.enableCuda
        then pkgs.ollama-cuda
        else pkgs.ollama;
      host = "127.0.0.1";
      port = 11434;
    };
    systemd.services.ollama.wantedBy = lib.mkForce [];

    security.sudo.extraRules = [
      {
        users = [config.custom.username];
        commands = [
          {
            command = "${pkgs.systemd}/bin/systemctl start ollama";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl stop ollama";
            options = ["NOPASSWD"];
          }
          {
            command = "${pkgs.systemd}/bin/systemctl restart ollama";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}

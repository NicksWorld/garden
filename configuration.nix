{
    self,
    inputs,
    modulesPath,
    lib,
    pkgs,
    ...
}:
{
    imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        ./modules/disk-config.nix

        ./modules/networking.nix
        ./modules/nginx.nix
        ./modules/gitea.nix
        ./modules/pds.nix
        ./modules/mail.nix
        ./modules/restic.nix
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        flags = [
            "-L"
        ];

        allowReboot = true;
        rebootWindow = {
            lower = "03:00";
            upper = "05:00";
        };

        dates = "02:00";
        randomizedDelaySec = "45min";
    };

    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.enableRedistributableFirmware = true;
    networking.hostName = "garden";
    time.timeZone = "UTC";

    boot.loader.grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
    };

    users.users.admin = {
        isNormalUser = true;
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBEyvP3QsMUk8k+h/gjmHUZvic/lKVfQDNISIhwiJ4OArcvo8Y1c9Hg+wagVkSw3xA+ggBQw/E7VYoMvx/JtcAQsAAAAEc3NoOg== ssh:"
        ];
        extraGroups = [ "wheel" ];
    };

    services.openssh = {
        enable = true;
        settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
        };
    };

    # Global packages
    environment.systemPackages = with pkgs; [
        zsh
        fish
        neovim
        nano
        git
    ];

    programs.zsh.enable = true;
    programs.bash.completion.enable = true;

    security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
    };
}

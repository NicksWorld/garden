{pkgs, config, ...}:
{
    systemd.tmpfiles.rules = [
        "d /backup - root backup-sync -"
    ];

    services.restic.backups = {
        garden = {
            initialize = true;
            paths = [
                "/var/www" # Webserver data
                "/var/lib/pds" # ATProto PDS
                "/home" # User data
                "${config.services.gitea.stateDir}/dump" # Gitea repository
            ];

            pruneOpts = [
                "--keep-daily 14"
            ];

            # Stop bluesky-pds during backup to ensure usable database files.
            backupPrepareCommand = "systemctl stop bluesky-pds";
            backupCleanupCommand =
            ''
            systemctl start bluesky-pds
            chgrp -R backup-sync /backup
            chmod -R g+rX /backup
            '';

            repository = "/backup";
            passwordFile = "/root/restic_pass";
        };
    };

    # User used for fetching the backup repository
    users.groups.backup-sync = {};
    users.users.backup-sync = {
        isSystemUser = true;
        group = "backup-sync";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCzn4bk+onpJHltUmc/Axqux1l+gdZ1iXuC4ra2FTs1"
        ];
    };
}

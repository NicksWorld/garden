{pkgs, config, ...}:
{
    imports = [
        (builtins.fetchTarball {
            url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
            sha256 = "0pqc7bay9v360x2b7irqaz4ly63gp4z859cgg5c04imknv0pwjqw";
        })
    ];

    mailserver = {
        enable = true;
        stateVersion = 3;
        fqdn = "mail.tty.garden";
        domains = [ "tty.garden" ];

        loginAccounts = {
            "nmcdaniel@tty.garden" = {
                hashedPasswordFile = "/root/email_hashed/admin";
                aliases = [ "postmaster@tty.garden" "admin@tty.garden" ];
            };
        };

        certificateScheme = "acme";
        acmeCertificateName = "tty.garden";
    };

    # SMTP Relay Configuration
    # This can be omitted once SMTP outbound connections are unblocked
    services.postfix = {
        settings.main = {
            relayhost = [ "[smtp.resend.com]:587" ];
            # Must have associated .db made with postmap in the same directory
            smtp_sasl_password_maps = "hash:/root/sasl_passwd";
            smtp_sasl_auth_enable = true;
            smtp_sasl_security_options = "";
            smtp_use_tls = true;
        };
    };
}

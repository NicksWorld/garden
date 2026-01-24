{config, ...}:
{
    security.acme = {
        acceptTerms = true;
        defaults.email = "nickmcdaniel00@gmail.com";

        certs."tty.garden" = {
            dnsProvider = "porkbun";
            environmentFile = "/root/dns_environment";

            extraDomainNames = [
                "*.tty.garden"
            ];

            group = config.services.nginx.group;
            reloadServices = [
                "nginx"
            ];
        };
    };

    systemd.tmpfiles.rules = [
        # Core Web Directory
        "d /var/www/tty.garden - root nginx -"
        # Mirrors
        "d /var/www/mirror - root nginx -"
        "d /var/www/mirror/maple - ahill nginx -"
    ];

    services.nginx =
    let vhostDefault = {
        addSSL = true;
        useACMEHost = "tty.garden";
        acmeRoot = null;
    };
    pdsProxy = {
        # Used for handle verification
        proxyPass = "http://127.0.0.1:3001";
        extraConfig =
        ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        '';
    }; in {
        enable = true;
        
        virtualHosts = {
            "tty.garden" = vhostDefault // {
                root = "/var/www/tty.garden";

                locations."^~ /.well-known/" = pdsProxy;
            };
            "seed.tty.garden" = vhostDefault // {
                locations."/" = {
                    proxyPass = "http://127.0.0.1:3000";
                };
            };
            "mirror.tty.garden" = vhostDefault // {
                root = "/var/www/mirror";

                locations."/" = {
                    extraConfig = "autoindex on;";
                };
            };
            "pds.tty.garden" = vhostDefault // {
                serverAliases = [ ".pds.tty.garden" ];

                locations."/" = {
                    proxyPass = "http://127.0.0.1:3001";
                    proxyWebsockets = true;
                };
            };
            "*.tty.garden" = vhostDefault // {
                locations."/" = {
                    return = "301 https://tty.garden";
                };
                locations."~/.well-known/" = pdsProxy;
            };
        };
    };
}

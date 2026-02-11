{pkgs, config, ...}:
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
    let
        robots = pkgs.fetchzip {
            url = "https://github.com/ai-robots-txt/ai.robots.txt/archive/refs/tags/v1.44.tar.gz";
            sha256 = "14jfkymkrs51xkgf48rin01kcfmk043zkdyzfhb459fv3brxms50";
        };
        vhostDefault = {
            addSSL = true;
            useACMEHost = "tty.garden";
            acmeRoot = null;

            locations."= /robots.txt" = {
                alias = "${robots}/robots.txt";
            };
        };
        forwardingRules =
            ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            '';
        pdsProxy = {
            # Used for handle verification
            proxyPass = "http://127.0.0.1:3001";
            extraConfig = forwardingRules;
        };
    in
    {
        enable = true;
        
        virtualHosts = {
            "tty.garden" = vhostDefault // {
                root = "/var/www/tty.garden";

                locations = vhostDefault.locations // {
                    "^~ /.well-known/" = pdsProxy;
                };
            };
            "seed.tty.garden" = vhostDefault // {
                locations = vhostDefault.locations // {
                    "/" = {
                        proxyPass = "http://127.0.0.1:3000";
                        extraConfig = forwardingRules;
                    };
                };
            };
            "mirror.tty.garden" = vhostDefault // {
                root = "/var/www/mirror";

                locations = vhostDefault.locations // {
                    "/" = {
                        extraConfig = "autoindex on;";
                    };
                };
            };
            "pds.tty.garden" = vhostDefault // {
                serverAliases = [ ".pds.tty.garden" ];

                locations = vhostDefault.locations // {
                    "/" = {
                        proxyPass = "http://127.0.0.1:3001";
                        proxyWebsockets = true;
                        extraConfig = forwardingRules;
                    };
                };
            };
            "*.tty.garden" = vhostDefault // {
                locations = vhostDefault.locations // {
                    "/" = {
                        return = "301 https://tty.garden";
                    };
                    "~/.well-known/" = pdsProxy;
                };
            };
        };
    };
}

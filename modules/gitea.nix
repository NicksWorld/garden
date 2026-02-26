{pkgs, config, ...}:
{
    services.gitea = {
        enable = true;

        dump.enable = true;

        settings = {
            service.DISABLE_REGISTRATION = true;
            server = {
                ROOT_URL = "https://seed.tty.garden/";
            };

            actions = {
                ENABLED = false;
            };

            indexer = {
                REPO_INDEXER_ENABLED = true;
            };

            "highlight.mapping" = {
                ".skr" = "scheme";
            };

            ui = {
                DEFAULT_THEME = "catppuccin-maroon-auto";
                THEMES = "catppuccin-maroon-auto,catppuccin-latte-maroon,catppuccin-mocha-maroon";
            };
        };
    };

    systemd.tmpfiles.rules =
    let catpuccinThemeSrc =
    pkgs.fetchzip {
        url = "https://github.com/catppuccin/gitea/releases/download/v1.0.2/catppuccin-gitea.tar.gz";
        sha256 = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
        stripRoot = false;
    };
    themeFiles = [
        "theme-catppuccin-mocha-maroon.css"
        "theme-catppuccin-latte-maroon.css"
        "theme-catppuccin-maroon-auto.css"
    ];
    customDir = config.services.gitea.customDir;
    in
    [
        "d ${customDir}/public - gitea gitea -"
        "d ${customDir}/public/assets - gitea gitea -"
        "d ${customDir}/public/assets/css - gitea gitea -"
    ]
    ++ map (f:
        "L+ ${customDir}/public/assets/css/${f} - - - - ${catpuccinThemeSrc}/${f}"
    ) themeFiles;
}

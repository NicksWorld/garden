{config, ...}:
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
        };
    };
}

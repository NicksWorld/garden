{config, ...}:
{
    services.bluesky-pds = {
        enable = true;

        environmentFiles = [ "/root/pds_environment" ];

        settings = {
            PDS_PORT = 3001;
            PDS_HOSTNAME = "pds.tty.garden";
            PDS_ADMIN_EMAIL = "nickmcdaniel00@gmail.com";
        };
    };
}

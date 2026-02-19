{config, ...}:
{
    networking.useDHCP = true;
    boot.kernelParams = [ "net.ifnames=0" ];
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 80 443 ];
        allowedUDPPorts = [ 22 ];
        allowedUDPPortRanges = [
            { from = 4000; to = 4007; }
            { from = 8000; to = 8010; }
        ];
    };

    networking.interfaces.eth0.ipv6 = {
        addresses = [
            {
                address = "2a01:4f8:1c1a:1532::1";
                prefixLength = 64;
            }
        ];
    };
    networking.defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
    };
}

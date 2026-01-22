{ lib, ... }:
{
    disko.devices.disk.os = {
        # device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_110097335";
        device = lib.mkDefault "/dev/sda";
        type = "disk";
        content = {
            type = "gpt";
            partitions = {
                boot = {
                    type = "EF02";
                    size = "1M";
                };
                ESP = {
                    type = "EF00";
                    size = "512M";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                    };
                };
                root = {
                    size = "100%";
                    content = {
                        type = "filesystem";
                        format = "xfs";
                        mountpoint = "/";
                        mountOptions = [
                            "defaults"
                            "pquota"
                        ];
                    };
                };
            };
        };
    };
}

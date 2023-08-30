# Packer VirtualBox Debian Preseed

Build automated VirtualBox images for Debian Bookworm using Packer.

Install the VirtualBox plugin for packer:

```bash
packer init m346.pkr.hcl
```

Build the Debian Bookworm Image:

```bash
packer build --force -var-file vars/debian-bookworm.pkrvars.hcl debian.pkr.hcl
```
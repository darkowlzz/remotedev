# DigitalOcean Droplet Image

Build a digitalocean droplet image to be used as the remotdev machine image.

## Prerequisites

- DigitalOcean Access Token
- [Packer](https://www.packer.io/)

## Workflow

```console
$ make

Usage:
  make <target>

Targets:
  help        Display this help.
  build       Build the machine image.
```

### Building an image

`variables.sample.json` is an example variables file. Copy it, create
`variables.json` and fill it with the DO(DigitalOcean) access token, new image
name and region name.

`template.json` contains the packer template with many provisioners to copy
files to the image builder machine and run scripts. It also contains the
builder machine configurations.

Start building the image with:

```console
$ make build
packer validate -var-file=variables.json template.json
packer build -var-file=variables.json template.json
digitalocean: output will be in this color.

==> digitalocean: Creating temporary ssh key for droplet...
==> digitalocean: Creating droplet...
==> digitalocean: Waiting for droplet to become active...
==> digitalocean: Using ssh communicator to connect: 68.183.82.53
==> digitalocean: Waiting for SSH to become available...
==> digitalocean: Connected to SSH!
...
...
==> digitalocean: Gracefully shutting down droplet...
==> digitalocean: Creating snapshot: darkowlzz-dev-1-12-20
==> digitalocean: Waiting for snapshot to complete...
==> digitalocean: Destroying droplet...
==> digitalocean: Deleting temporary ssh key...
Build 'digitalocean' finished.

==> Builds finished. The artifacts of successful builds are:
--> digitalocean: A snapshot was created: 'darkowlzz-dev-1-12-20' (ID: 74365725) in regions '<rgn>'
```

At the end of the build process, the image snapshot name, ID and region are
printed. Use the ID and region in the remotedev machine config to use it.

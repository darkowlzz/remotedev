# DigitalOcean Droplet

Create a remote development environment using digitalocean droplet.

## Prerequisites

- Docker
- DigitalOcean Access Token

## Workflow

```console
$ make

Usage:
  make <target>

Targets:
  help        Display this help.
  up          Provision the machine.
  clean       Delete the machine.
  status      Show the machine status.
  ssh         SSH into the machine.
  deps        Install all the dependencies and configurations before provisioning a machine.
  distclean   Cleanup everything, machine, config and generated files.
  push        Push pushes the specified directory in config to the remote machine.
  pull        Pull pulls the specified remote directory in the config to the local directory.
```

All the operations run within container and any other dependency or
configurations are saved within this repo.

### Provisioning a machine

`secrets.sample.sh` is an example secret file. Copy it, create `secret.sh` and
fill it with the DO(DigitalOcean) access token.

```console
$ cp secrets.sample.sh secrets.sh
...
$ cat secrets.sh
PULUMI_CONFIG_PASSPHRASE=
DIGITALOCEAN_TOKEN=<do-access-token>
```

`PULUMI_CONFIG_PASSPHRASE` can remain empty because this setup runs pulumi in
local-only mode, not using the pulumi online services.

Run `make deps` to generate ssh keys that'd be used to access the machine. This
also uses the DO access token provided above to create a DO ssh key in the
account automatically and saves the details of the DO ssh key in file
`.temp-do-ssh-key-details.json`. This file is used by other operations to get
the ssh key ID.

```console
$ make deps
bash envsetup/deps.sh
Creating ssh key dir /go/src/github.com/darkowlzz/remotedev/machine/do/.ssh...
Generating ssh key...
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in .ssh/id_rsa.
Your public key has been saved in .ssh/id_rsa.pub.
The key fingerprint is:
SHA256:LMXRqlB5WK7GdI6aFkRP30ZEBTKmAj5G1A5bu/X2Nmc remotedev-5245@example.com
The key's randomart image is:
+---[RSA 4096]----+
| .+.. .+*+=o.    |
| o.ooo+*.*.      |
|  +=oo+.*.o      |
| ..o++.B..       |
|    .+*oS        |
|    .=..o        |
|    +  . .       |
|   .      + E    |
|         . +     |
+----[SHA256]-----+
Creating a new digitalocean ssh key with the generated ssh key...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1674  100   882  100   792    683    613  0:00:01  0:00:01 --:--:--  1295
Creating local pulumi stacks directory /go/src/github.com/darkowlzz/remotedev/machine/do/.pulumi/stacks...
Creating pulumi credentials file /go/src/github.com/darkowlzz/remotedev/machine/do/.pulumi/credentials.json...
Creating a new config file from the sample config and updating it...
```

This creates `config.yaml` based on `config.sample.yaml` and adds the ssh key ID
from DO in the `sshKeys` section. The generated machine config file looks like:

```yaml
name: darkowlzz-dev-env
image: imageid
region: rgncode
size: s-1vcpu-1gb
sshKeys:
- 27254155
```

Update the `image` and `region` with valid DO image ID and region name. Change
the machine name accordingly.

`.ssh/` contains the generated ssh keys.

`.pulumi/` contains the local pulumi stack state that's mounted in a container
when running pulumi.

Start machine provisioning with `make up`. This will run a docker container and
run pulumi in it. The container contains a precompiled go binary that's used by
pulumi to provision the machine in a given way as per the configurations in
config.yaml file.

```console
$ make up
bash envsetup/run-in-docker.sh darkowlzz/remotedev:v0.0.1 envsetup/up.sh remotedev
Using container image: darkowlzz/remotedev:v0.0.1
Logged into e33244493cf2 as root (file://~)
remotedev not found, creating a new stack...
Created stack 'remotedev'
Updating (remotedev):
     Type                           Name               Status
 +   pulumi:pulumi:Stack            do-remotedev       created
 +   └─ digitalocean:index:Droplet  darkowlzz-dev-env  created

Outputs:
    ip  : "159.65.159.117"
    name: "darkowlzz-dev-env-20c489c"

Resources:
    + 2 created

Duration: 53s

Permalink: file:///root/.pulumi/stacks/remotedev.json
```

### Access the machine

Access the machine using `make ssh`:

```console
$ make ssh
bash envsetup/run-in-docker.sh darkowlzz/remotedev:v0.0.1 envsetup/ssh.sh remotedev
Using container image: darkowlzz/remotedev:v0.0.1
Connecting to 159.65.159.117
...
Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-66-generic x86_64)

...

root@darkowlzz-dev-env-20c489c:~#
```

### Sync files to the machine

For syncing a local source to a remote destination, add the remote username as
owner, source and destination of the files in the config file. The values must
be absolute paths on local and remote.

```yaml
owner: demouser
source: /Users/darkowlzz/code/projectx
destination: /home/demouser/code
```

The destination must be the directory to which the source will be synced to.

Run `make push` to start the sync. A local sync is performed first. All the
source files are rsynced into `.sync/` dir, excluding the `.git/` directory and
all the files listed in `.gitignore` of the source. Then a remote sync is
performed, copying the local sync directory files to the remote target location.
This ensures that only the minimum amount of files are copied and no sensitive
files are copied to remote. Running `make push` again will copy only the
difference in the source and destination, reducing the sync time. The initial
sync time is usually long but the subsequent sync times are short.

```console
$ make push
bash envsetup/sync-local.sh
/go/src/github.com/weaveworks/ignite /go/src/github.com/darkowlzz/remotedev/machine/do
Copying /go/src/github.com/weaveworks/ignite into local sync dir /go/src/github.com/darkowlzz/remotedev/machine/do/.sync/ignite...
/go/src/github.com/darkowlzz/remotedev/machine/do
bash envsetup/run-in-docker.sh darkowlzz/remotedev:v0.0.1 envsetup/sync-remote.sh
Using container image: darkowlzz/remotedev:v0.0.1
Syncing ignite to 139.59.20.129:/home/demouser/go/src/github.com/weaveworks...
sending incremental file list
ignite/
ignite/.dockerignore
ignite/.grenrc.js
ignite/.readthedocs.yml
ignite/.travis.yml
ignite/CHANGELOG.md
...
sent 7.29M bytes  received 71.37K bytes  61.13K bytes/sec
total size is 27.78M  speedup is 3.77
Sync complete.
```

Similarly, to pull changes made in the remote to local, run `make pull`. This
will pull only the changed file and new files back to the local repo.

### Delete the machine

Delete the machine with `make clean`:

```console
$ make clean
bash envsetup/run-in-docker.sh darkowlzz/remotedev:v0.0.1 envsetup/destroy.sh remotedev
Using container image: darkowlzz/remotedev:v0.0.1
Destroying (remotedev):
     Type                           Name               Status
 -   pulumi:pulumi:Stack            do-remotedev      deleted
 -   └─ digitalocean:index:Droplet  darkowlzz-dev-env  deleted

Outputs:
  - ip  : "159.65.159.117"
  - name: "darkowlzz-dev-env-20c489c"

Resources:
    - 2 deleted

Duration: 26s

Permalink: file:///root/.pulumi/stacks/remotedev.json
The resources in the stack have been deleted, but the history and configuration associated with the stack are still maintained.
If you want to remove the stack completely, run 'pulumi stack rm remotedev'.
```

This doesn't cleans up all the generated files and configuration. It only
destroys the provisioned machine. The DO ssh key is not deleted and can be used
again if the machine is provisioned again.

To delete everything, run `make distclean`, this will delete all the generated
configurations and delete the DO ssh key from the DO account. `secrets.sh` is
not deleted and can be reused.

## Pulumi Container Image

The container image used for this contains pulumi, pulumi plugins, go and the
pulumi go program that defines what to provision, precompiled. Although the
pulumi go program is precompiled, pulumi looks for the go binary when running.
This may not be required in the future. The `Dockerfile` can be used to build a
new container with any change in the pulumi go program  code. `Pulumi.yaml`
contains the name of the binary that pulumi looks for when running.

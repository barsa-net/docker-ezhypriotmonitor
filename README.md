# docker-ezhypriotmonitor
eZ Hypriot Monitor implemented in a Docker container.
This is a dashboard for Hyperiot OS running on a Raspberry Pi

## Usage
Clone the repository with `git clone --recursive` or update your current repository with `git pull --recurse-submodules`

Edit `esm.conf.json` as you please (the [ESM\`WEB documentation](https://www.ezservermonitor.com/esm-web/documentation) explains all the parameters of esm.config.json).

Build the container with `docker build docker-ezhypriotmonitor -t ehm`

Run with
```
docker run -d -p=80:80 -v=/etc/timezone:/etc/timezone:ro -v=/etc/localtime:/etc/localtime:ro -v=/etc/hostname:/dockerhost/etc/hostname:ro -v=/usr/lib/os-release:/dockerhost/usr/lib/os-release:ro -v=/var/run/utmp:/dockerhost/var/run/utmp:ro -v=/sys/class/net:/dockerhost/sys/class/net:ro -v=/boot/mountinfo.d:/mountinfo.d/boot -v=/var/log/lastlog:/dockerhost/var/log/lastlog:ro -v=/etc/passwd:/dockerhost/etc/passwd:ro $(ip a | awk '/inet / {print}' | awk '!(/br-/||/docker0/||/veth/) {print "dockerhost."$NF":"$2}' | sed 's/\/[0-9]*//g' | sed 's/^/--add-host=/g' | tr '\n' ' ') --restart always --name ehm ehm
```

## Run options explanation
Reading informations about your Raspberry Pi from inside a container requires a LOT of volume bindings and some trick, below some explanation about what every option is for.
If you are uncomfortable with some bind you can omit it, but you will lose some information.

### Config file
`-v=$PWD/esm.config.json:/var/www/html/conf/esm.config.json`
### System block
#### Timezone
`-v=/etc/timezone:/etc/timezone:ro`
`-v=/etc/localtime:/etc/localtime:ro`
#### Hostname
`-v=/etc/hostname:/dockerhost/etc/hostname:ro`
#### OS information and Hypriot version
`-v=/usr/lib/os-release:/dockerhost/usr/lib/os-release:ro`
#### Current logged users
`-v=/var/run/utmp:/dockerhost/var/run/utmp:ro`
### Network interfaces statistics
`-v=/sys/class/net:/dockerhost/sys/class/net:ro`
### Disk
#### /boot partition information
`-v=/boot/mountinfo.d:/mountinfo.d/boot:ro`

If you want to monitor some additional partition you can add more binds following the schema `-v=<directory>/mountinfo.d:/mountinfo.d/<directory>`.

E.g.
You have `/dev/sda1` mounted on your Host on `/mnt/some`, adding `-v=/mnt/some/mountinfo.d:/mountinfo.d/mnt/some:ro` will monitor `/dev/sda1` informations.
### Last login
`-v=/var/log/lastlog:/dockerhost/var/log/lastlog:ro`
`-v=/etc/passwd:/dockerhost/etc/passwd:ro`
### Network interfaces ips
`$(ip a | awk '/inet / {print}' | awk '!(/br-/||/docker0/||/veth/) {print "dockerhost."$NF":"$2}' | sed 's/\/[0-9]*//g' | sed 's/^/--add-host=/g' | tr '\n' ' ')`

This gets ips from all interfaces (excluding docker virtual networks) and pass them to the container via `--add-host=dockerhost.<interface>:<interface ip>`.

Unfortunately this **only work with IPv4** as nor PHP nor the original eZ Server Monitor provides IPv6 support so far.

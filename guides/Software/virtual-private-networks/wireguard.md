---
authors:
    - name: kmorton1988
      link: https://github.com/kmorton1988
      avatar: ":dragon_face:"
label: WireGuard
icon: dot
order: alpha
---

Difficulty: [!badge variant="primary" text="Medium / Intermediate"]

WireGuard is a secure VPN tunnel that aims to provide a VPN that is easy to use, fast, and with low overhead. It is cross-platform, but it is the part of the Linux kernel by default with only the need of userland tools to configure and deploy it.

## Preface

We are going to assume that we are working in a Linux environment to configure WireGuard with one server and at least one client. This guide assumes that this configuration is being performed as the root user or the superuser. Your distribution may require you to prefix commands with `sudo`.

## Installation

You can find more details about installing WireGuard on your own operating system here: https://www.wireguard.com/install/. Please complete installation for both the server and client machine.

### Create the Keys

The first step after installing WireGuard for your distribution is to generate keys. We should do this for the server first, but this will be the same for clients as well.

```bash
cd /etc/wireguard && wg genkey | tee private.key | wg pubkey > public.key
```

You should now have `public.key` and `private.key` files in `/etc/wireguard/`.

It is important to make sure your private key **stays private**. No private key should ever leave the machine it was generated on. The client and server will only need the public keys for each other. If you are using the private keys for a client on a server, or vice-versa, you are doing something wrong.

### Server Configuration

Since this is the server, we need to make a new configuration file for it in `/etc/wireguard/`. We will call it `wg0.conf`. The full path should end up being `/etc/wireguard/wg0.conf`. Please use your own private key where appropriate. You can view the contents of a text file from the command line with `cat` (e.g. `cat /path/to/text.file`).

You can change the _Address_ field to use a different address space (e.g. `192.168.x.1`) if you wish. If your server or clients are already using private IP space on a LAN, **use something different**.

```
[Interface]
## Private IP address for the server to use
Address = 10.0.0.1/24
## When WireGuard is shutdown, flushes current running configuration to disk. Any changes made to the configuration before shutdown will be forgotten
SaveConfig = true
## The port WireGuard will listen on for incoming connections. 51194 is the default
ListenPort = 51194
## The server's private key. Not a file path, use the key file contents
PrivateKey = PRIVATEKEY
```

After this is done we should be able to start the VPN tunnel and make sure it's enabled.

!!!
Please consult the documentation for your Linux distribution for enabling/starting services. This guide is using system tools installed on Debian and Debian-based distributions.
!!!


```bash
systemctl enable wg-quick@wg0 && systemctl start wg-quick@wg0
```

That should be it for the server portion.

### Client Configuration

The client will need keys too. Use the same procedure to [make keys](#create-the-keys) for the client as we've done for the server. Once that is done we need to create a client configuration. Let's make `wg0-client.conf` in `/etc/wireguard/`. The full path should be `/etc/wireguard/wg0-client.conf`. You will need to choose a unique IP address for the client. Everything should be the same as the server's private IP except the last octet.

```
[Interface]
## This Desktop/client's private key ##
PrivateKey = CLIENTPRIVATEKEY

## Client IP address ##
Address = 10.0.0.CLIENTOCTET/32

[Peer]
## WireGuard server public key ##
PublicKey = WGSERVERPUBLICKEY

## set ACL ##
## Uncomment the next line to use VPN for VPN connections only
# AllowedIPs = 10.0.0.0/24
## If you want to use the VPN for ALL network traffic, uncomment the following line instead
# AllowedIPs = 0.0.0.0/0

## Your WireGuard server's PUBLIC IPv4/IPv6 address and port ##
Endpoint = WGSERVERPUBLICIP:51194

## Key connection alive ##
PersistentKeepalive = 20
```

This should be all you need for configuring the client-end connection. We will need the private client IP you've chosen and the public client key in a bit. As with the server, we need to enable the WireGuard client service. We don't start it yet because the server still doesn't know about this client.

```bash
systemctl enable wg-quick@wg0-client
```
   

### Configuring the Client as a Peer

Back on your server, we need to add the client so the server will accept the client connection. This is where your client private IP address and public key will be used. Run the following command on the WireGuard server to add the client:

```bash
wg set wg0 peer CLIENTPUBLICKEY allowed-ips CLIENTPRIVATEIP/32
```

You should not need to restart the WireGuard service. Lets start the WireGuard client service on the client:

```bash
systemctl start wg-quick@wg0-client
```

To check that it works, ping the WireGuard server on its private IP.

```bash
$ ping -c 1 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.071 ms

--- 10.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.071/0.071/0.071/0.000 ms
```

If you consider your client Internet connection stable, this next step may not be necessary. You can consider yourself done.

## WireGuard Watchdog (OPTIONAL)

Next we are going to setup a small cronjob that will ping the WireGuard server on its private IP to make sure the connection is still intact. If the connection fails, the tunnel will be restarted.

You can put this script anywhere, but I've opted to put it in `/usr/local/scripts/`.

```bash
mkdir /usr/local/scripts
```

Now for the script. I use `wg-watch.sh`. Let's assume you are going to use ``/usr/local/scripts/wg-watch.sh` for the full file path.

```bash
#!/usr/bin/bash
# Modified from https://mullvad.net/en/help/running-wireguard-router/
# ping VPN gateway to test for connection
# if no contact, restart!

PING=/usr/bin/ping

## DEBIAN
SERVICE=/usr/sbin/service

tries=0
while [[ $tries -lt 3 ]]
do
    if $PING -c 1 10.0.0.1
    then
            echo "wg works"
            exit 0
    fi
    echo "wg fail"
    tries=$((tries+1))
done
echo "wg failed 3 times - restarting tunnel"

## DEBIAN
$SERVICE wg-quick@wg0-client restart
```

Please make sure the paths to certain binaries are congruent with your own system. If they are not, the script will fail. Some distributions put them in different places (e.g. `/bin/bash` instead of `/usr/bin/bash`). If you are not sure where they are, you can do `which binaryname` that should report the full path to the binary.

```bash
$ which bash
/usr/bin/bash
```

Make the script executable:

```bash
chmod +x /usr/local/scripts/wg-watch.sh
```

Once we have that done, we need to schedule it. I choose to schedule this every five minutes, but if you want to wait longer that is up to you. Schedule the script to run on a regular basis using `cron`. You can find out more about `cron` [here](https://opensource.com/article/17/11/how-use-cron-linux).

We're going to use `crontab` to add this script to the list of jobs.

```bash
crontab -e
```

Once the crontab editor is open, add this:

```
*/5 * * * * /usr/local/scripts/wg-watch.sh
```

Write and close the file. Crontab should confirm that it has been updated. You should now be setup with a WireGuard VPN tunnel between a server and a client along with a script to bring the tunnel back up if it fails!

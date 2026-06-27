---
label: How To Host Websites
icon: dot
order: alpha
---

Difficulty: [!badge variant="primary" text="Medium / Intermediate"]

This guide assumes you are able to serve content on port 80 (HTTP) and port 443 (HTTPS). It also assumes you have your own domain name and have access to create or update DNS records for it. For this guide, we will be using Ubuntu Linux 22.04.

## Choosing a Server

A server can be just about anything. You may use an old computer that isn't being used anymore, a cheap small form factor (SFF) machine from an online store, a custom-built machine that has server-grade or consumer-level parts, or even a Raspberry Pi!

Once you've selected your hardware, you'll want to select an operating system. The most popular operating system self-hosters use is Linux, commonly Ubuntu. Linux comes in many flavors to meet many needs. It is freely available and free to modify. Windows Server is usually not chosen due to licensing costs.

## Setting Up DNS

Get the IP address of the machine you will use. If you're serving your content outside your local network, the local IP address of the machine will not work (for example, `192.168.x.x` or `10.1.3.10`). You will need to obtain your public IP address. You can find your public IP address on your router status page or by going to https://ifconfig.me/. Use that IP address when creating an A record at your DNS host.

If your ISP changes your public IP address regularly, use a dynamic DNS provider or a DNS provider with an API so your records can be updated automatically. If your router's WAN address is private, such as `100.64.x.x`, `10.x.x.x`, `172.16.x.x` to `172.31.x.x`, or `192.168.x.x`, you may be behind CGNAT and direct port forwarding from the internet may not work. In that case, consider a VPS reverse proxy, a tunnel service, or asking your ISP for a public IP address.

## Network Configuration

As noted above, you will need to ensure ports `80` and `443` are open and able to be used for your web server. If you need to perform port forwarding, we recommend reviewing your router's documentation. It's possible your ISP will block common ports used for internet traffic, such as 80 (HTTP), 443 (HTTPS), 21 (FTP), and 25 (SMTP). Some ISPs will have no problem unblocking some of these ports, but it should not be expected that they will cooperate.

Make sure the server's own firewall allows HTTP and HTTPS traffic too. On Ubuntu, that may mean allowing the web server profile with `ufw`, such as `sudo ufw allow 'Nginx Full'` or `sudo ufw allow 'Apache Full'`, depending on which web server you install.

!!!warning
There may be clauses in your service agreement stating that hosting services from your home internet connection is prohibited. While ISPs rarely take action against customers if they are found in violation of this rule, there are legitimate reasons for having such a clause.
!!!

## Hosting a Website with Apache

1. Log in to your server via SSH.

## Hosting a Website with Nginx

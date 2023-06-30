---
label: How To Host Websites
icon: globe
order: alpha
---

Difficulty: [!badge variant="primary" text="Medium / Intermediate"]

This guide assumes you are able to serve content on port 80 (HTTP) and port 443 (HTTPS). It also assumes you have your own domain name and have access to create and/or update DNS records for it. For this guide we will be using Ubuntu Linux (22.04).

## Choosing a Server

A server can be just about anything. You may use an old computer that isn't being uses anymore, a cheap small form factor (SFF) machine from an online store, a custom built machine that has server grade or consumer level parts, or even a Raspberry Pi!

Once you've selected your hardware you'll want to select an operating system. The most popular operating system self-hosters use is Linux (commonly Ubuntu). Linux comes in many flavors to meet many needs. It is freely available and free to modify. Windows Server is usually not chosen due to licensing costs.

## Setting Up DNS

Get the IP address of the machine you will use. If you're serving your content locally (ex. your home network), then the local IP address of the machine will not work (e.g. `192.168.x.x` or `10.1.3.10`). You will need to obtain your public IP address. You can find your public IP address on your router status page or by going to https://ifconfig.me/. Use that IP address when creating an A record at your DNS host.

## Network Configuration

As noted above you will need to ensure port `80` and `443` are open and able to be used for your web server. If you need to perform port forwarding we recommend reviewing your routers documentation. It's possible your ISP will block common ports used for Internet traffic such as 80 (HTTP), 443 (HTTPS), 21 (FTP), and 25 (SMTP). Some ISPs will have no problem unblocking some of these ports, but it should not be expected that they will cooperate.

!!!warning
There may be clauses in your service agreement stating that hosting services from your home Internet connection is prohibited. While ISPs rarely take action against customers if they are found in violation of this rule, there are legitimate reasons for having such clause.
!!!

## Hosting a Website with Apache

1. Login to your server via SSH. 

## Hosting a Website with Nginx


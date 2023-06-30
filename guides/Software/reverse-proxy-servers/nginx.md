---
authors:
    - name: kmorton1988
      link: https://github.com/kmorton1988
      avatar: ":dragon_face:"
label: Nginx
icon: dot
order: alpha
---

Difficulty: [!badge variant="success" text="Easy / Basic"]

## Prerequisites

There are some prerequisites you'll need before setting up a reverse proxy server. The first thing you'll need is to have port 80 and 443 of your public IP address forwarded to the machine you want to use as a proxy. This can be configured through your router. You will also need a domain name with an A record that points to your public IP address. Finally, you'll need some services running on your local network for you to proxy.

## Nginx Installation

### Debian-based Systems

1. First, type `sudo apt update` to update the package information.
2. Then, type `sudo apt install nginx` to install Nginx.
3. Finally, allow the necessary ports using `sudo ufw allow 80/tcp` and `sudo ufw allow 443/tcp`.

### RHEL-based Systems

1. First, enable the EPEL repository using `sudo yum install epel-release`.
2. Then, type `sudo yum install nginx` to install Nginx.
3. Finally, allow the necessary ports using `sudo firewall-cmd --permanent --zone=public --add-service=http` and `sudo firewall-cmd --permanent --zone=public --add-service=https`. Type `sudo firewall-cmd --reload` to reload the firewall.

Make sure Nginx starts up using `sudo systemctl start nginx`.

To verify that Nginx is working properly, visit `http://yoursite.com` and you should see a Nginx welcome page similar to what's shown below. This specific page may vary depending on your distro.

!!!warning FIX ME!
Add screenshot of Nginx welcome page here.
!!!

## Deciding on the Reverse Proxy Structure

Before we actually create our reverse proxy configuration, we have to decide which local servers will handle each of the subdomains. For example, if I wanted `nextcloud.yoursite.com` to be handled by a server at `192.168.0.230`, I could add a Nginx configuration for that.

Once you've decided which subdomains you'll use, add a CNAME record that maps the subdomain to your main domain name. Below is an example in Google Domains. It will vary depending on your DNS provider.

!!!warning FIX ME!
Add screenshot of CNAME configuration in Google Domains here.
!!!

## Modifying the Nginx Configuration Files

!!!
Editable templates for each of the config files shown in this guide can be found at [this GitHub repo](https://github.com/Rav4s/NginX-Config-Files).
!!!

In order to set up the reverse proxy we have to remove the default website configuration and add our own to handle each subdomain. In this guide, we'll create two config files, one for a www/non-www domain and one for any other subdomain.

### Removing the Default Configuration

To remove the default configuration, type in `cd /etc/nginx/sites-enabled/` to enter the directory and `sudo rm default` to remove the configuration file.

### Creating the First Configuration File

To begin, type `cd /etc/nginx/sites-available/` to enter the `sites-available` directory. Then type `sudo vi reverse-proxy.conf` to begin editing the file.

The first thing you'll want to add in this file is a server block. This server block will listen on `http://www.yoursite.com` and redirect visitors to `https://www.yoursite.com`.

```nginx
server {
    listen 80;
    server_name www.yoursite.com;
    return 301 https://www.yoursite.com$request_uri;
}
```

The next thing to add is another server block, which will listen on `http://yoursite.com` and redirect visitors to `https://www.yoursite.com`

```nginx
server {
    listen 80;
    server_name yoursite.com;
    return 301 https://www.yoursite.com$request_uri;
}
```

Our third server block will listen on `https://yoursite.com`, and redirect the https traffic to `https://www.yoursite.com`. This server block also contains information about the SSL certificates, which we will modify later when we obtain them.

```nginx
server {
    listen 443;
    server_name yoursite.com;
    return 301 https://www.yoursite.com$request_uri;

    # SSL Configuration

    ssl_certificate /etc/letsencrypt/live/yoursite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yoursite.com/privkey.pem; # managed by Certbot
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

}
```

This last server block will perform the actual proxying. It will listen on `https://www.yoursite.com` and proxy requests to a backend server. To do this, we can add a location block within this server block. Within the location block, we set proxy headers which nginx forwards to the backend, and we add the proxy pass and proxy redirect with the IP address and port of the backend server. The last few lines are optional, but I recommend using them because they heighten the security of your server. These lines enable HSTS, clickjacking protection, XSS protection, and disable content and MIME sniffing. Finally, we can add a line which adds the trailing slash to all URLs.

```nginx
server {
    listen 443;
    server_name www.yoursite.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yoursite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yoursite.com/privkey.pem; # managed by Certbot
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    # Set the access log location
    access_log            /var/log/nginx/yoursite.access.log;

    location / {

      # Set the proxy headers
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      # Configure which address the request is proxied to
      proxy_pass          http://yourserverip:yourport/;
      proxy_read_timeout  90;
      proxy_redirect      http://yourserverip:yourport https://www.yoursite.com;

      # Security headers
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
      add_header Referrer-Policy "origin";

      # Add the trailing slash
      rewrite ^([^.]*[^/])$ $1/ permanent;
    }

}
```

After adding these lines, type `:wqa` to save the file and exit Vim.

There's one more step before we can use this configuration. We need to symlink it to the `sites-enabled` directory. To do this, type `sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf`.

### Creating the Second Configuration File

This next configuration file will serve as a template for any other subdomains you want to add to your reverse proxy. To begin making this config file, type `cd /etc/nginx/sites-available/` and then `sudo vi SUBDOMAIN.conf`, replacing `SUBDOMAIN` with the subdomain you want to configure.

The first thing we'll add in this file is a server block. This server block will listen on `http://YOURSUBDOMAIN.YOURSITEDOMAIN.com` and redirect visitors to `https://YOURSUBDOMAIN.YOURSITEDOMAIN.com`.

```nginx
server {
    listen 80;
    server_name YOURSUBDOMAIN.YOURSITEDOMAIN.com;
    return 301 https://$host$request_uri;
}
```

This next server block will perform the actual proxying. It will listen on `https://YOURSUBDOMAIN.YOURSITEDOMAIN.com` and proxy requests to your backend server. To do this, we'll add a location block inside the server block. Within the location block, we set proxy headers which nginx forwards to the backend, and we add the proxy pass and proxy redirect with the IP address and port of the backend server. Again, the security headers at the bottom are optional, but they will greatly improve the security of your server, so I recommend that you add them.

```nginx
server {
    listen 443;
    server_name YOURSUBDOMAIN.YOURSITEDOMAIN.com;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/YOURSUBDOMAIN.YOURSITEDOMAIN.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/YOURSUBDOMAIN.YOURSITEDOMAIN.com/privkey.pem; # managed by Certbot
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    # Set the access log location
    access_log            /var/log/nginx/YOURSUBDOMAIN.access.log;

    location / {

    # Set the proxy headers
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;

      # Configure which address the request is proxied to
      proxy_pass          http://YOURSERVER:YOURPORT;
      proxy_read_timeout  90;
      proxy_redirect      http://YOURSERVER:YOURPORT https://YOURSUBDOMAIN.YOURSITEDOMAIN.com;

      # Set the security headers
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"; #HSTS
      add_header X-Frame-Options DENY; #Prevents clickjacking
      add_header X-Content-Type-Options nosniff; #Prevents MIME sniffing
      add_header X-XSS-Protection "1; mode=block"; #Prevents cross-site scripting attacks
      add_header Referrer-Policy "origin";
    }

}
```

After adding these lines, type `:wqa` to save the file and exit Vim.

Finally, to symlink this file to the `sites-enabled` directory, type `sudo ln -s /etc/nginx/sites-available/SUBDOMAIN.conf /etc/nginx/sites-enabled/SUBDOMAIN.conf`.

To add any additional subdomains, simply copy the previous config file and replace the server_name with the new subdomain, along with the backend's IP address and port. Then symlink the new file to the `sites-enabled` directory.

## Restarting Nginx

If you try to restart Nginx at this stage (`sudo systemctl restart nginx`), you'll probably see a few errors saying that the certificate files don't exist. In order to get Nginx to start, we'll have to use a temporary certificate.

To obtain a temporary certificate and store it in the working directory, type `openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem`. Two files, `key.pem` and `certificate.pem` will be stored in your working directory.

Now modify these two lines in your config files

```nginx
ssl_certificate /etc/letsencrypt/live/yoursite.com/fullchain.pem; # managed by Certbot
ssl_certificate_key /etc/letsencrypt/live/yoursite.com/privkey.pem; # managed by Certbot
```

so that they look like this:

```nginx
ssl_certificate /path/to/certificate.pem; # managed by Certbot
ssl_certificate_key /path/to/key.pem; # managed by Certbot
```

Make sure to replace `/path/to/` with the path to your certificate and key files.

After modifying these lines in each configuration, we can restart Nginx using `sudo systemctl restart nginx`.

## Obtaining Let's Encrypt TLS Certificates

Now that Nginx has restarted with the new configuration, we can obtain TLS certificates from Let's Encrypt, a certificate authority that provides free certificates. To obtain a Let's Encrypt certificate, we can use Certbot.

To install Certbot on a Debian-based distro, type `sudo apt install python3-certbot-nginx`.

To install on a RHEL-based distro, type `sudo yum install certbot python3-certbot-nginx`.

Then, to obtain certificates for your www and non-www domains, type `sudo certbot --nginx -d YOURSITEDOMAIN.com -d www.YOURSITEDOMAIN.com`.

Certbot will ask for some information, including your email address, agreement to the Terms of Service, and whether or not you want to subscribe to their newsletter. Then Certbot will obtain your certificate.

To obtain a certificate for any additional subdomains, type `sudo certbot --nginx -d sub.domain.com`, replacing `sub.domain.com` with the proper subdomain address.

Certbot will automatically update the config files with the path to your new certificates, so you don't need to do that manually.

Once you've obtained all the certificates you need, restart Nginx with `sudo systemctl restart nginx`.

Now, visit each of your subdomains and ensure that they are accessible over https.

### Auto-Renewal Cronjob

The last thing we should do is to set up the auto-renewal of our TLS certificates using `cron`. To do this, open the crontab for editing by typing `sudo crontab -e`.

Then add the following line to the crontab to automatically try to renew the certificates at 1:00am every day:

`0 1 * * * certbot renew --deploy-hook "systemctl restart nginx"`

## Conclusion

In conclusion, a reverse proxy allows you to easily host multiple sites on the same IP address without exposing unnecessary ports. If you enjoyed this article, feel free to check out [my website](https://www.yeetpc.com), where I post articles about upgrading/restoring computers, securing your servers, and more. Thanks for reading and happy self-hosting!

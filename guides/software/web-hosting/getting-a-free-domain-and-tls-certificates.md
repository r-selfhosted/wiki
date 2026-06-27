---
authors:
    - name: ioqy
      link: https://github.com/ioqy
      avatar: ":dragon_face:"
label: Free Domain w/ TLS
title: Getting a Free Domain with a TLS Certificate
icon: dot
order: alpha
---

Difficulty: [!badge variant="success" text="Easy / Basic"]

With this tutorial you will get a valid TLS certificate from Let's Encrypt without having to open any incoming ports. You can use the certificate to enable HTTPS with your reverse proxy (Apache, Nginx, Caddy, etc...) or other self hosted services. Since this only uses `acme.sh` which is a shell script it should work on everything that runs Linux.

The tutorial was written for and tested with Duck DNS and deSEC, but you can (in theory, because I did sadly encounter a few bugs/incompatibilities here and there) use [every one of the 150+ DNS providers supported by `acme.sh` (there is also a second page at the end)](https://github.com/acmesh-official/acme.sh/wiki/dnsapi). If you want to use a wildcard certificate I would recommend deSEC because Duck DNS currently has a bug/incompatibility with `acme.sh`.

If you want to use another DNS provider you can skip right to step [Install `acme.sh`](#install-acmesh). You will need to change the parameter `--dns YOURDNS` in all the below commands and set the necessary variables yourself according to the [acme.sh DNS API wiki](https://github.com/acmesh-official/acme.sh/wiki/dnsapi).


## Select a DynDNS Provider

### Duck DNS

1. Go to https://www.duckdns.org/ and sign in with one of the providers at the top.
2. After your are successfully logged in, enter the sub domain you want and press _add domain_. This domain name (including the `.duckdns.org` part) needs to be replaced in all commands where you see `$YOURDOMAIN`.
3. Enter either:
    - The local IP address of your server if your server is not accessible from the internet or the public IP address of your server if your server is accessible from the internet in the _current ip_ field and press _update ip_.  
      
      The chosen sub domain name will be the one that the server/service needs to be addressed when using the certificate, for it to be valid. Since you set the sub domain to the IP address of your server it should be reachable when the sub domain name get's translated by any DNS. Depending on your home router you might need add an exception of the sub domain name to the DNS rebind protection.
4. Keep the website open, because you need it in a later step.

### deSEC

1. Go to https://desec.io/signup and create a new account. It doesn't matter what you choose for _Do you want to set up a domain right away?_ because you can add a domain afterwards.
2. Log into your deSEC account.
3. If you havent't added a domain during signup, click on the _+_ button on the right and enter the subdomain you want and add _.dedyn.io_ after your subdomain so it looks like _example.dedyn.io_. If the sub domain was added successfull there will be a popup with setup instructions which you will not need and can be closed. This domain name needs to be replaced in all commands where you see `$YOURDOMAIN`.
4. Optionally add a DNS record. Click onto your sub domain name and then the _+_ button on the right. A popup with _Create New Record Set_ will show up. Choose the _Record Set Type_ value _A_ and enter either:
    - The local IP address of your server if your server is not accessible from the internet or the public IP address of your server if your server is accessible from the internet in the 'IPv4 address' field and press _Save_.  
  
        The choosen sub domain name will be the one that the server/service needs to be addressed when using the certificate, for it to be valid. Since you set the sub domain to the IP address of your server it should be reachable when the sub domain name get's translated by any DNS. Depending on your home router you might need add an exception of the sub domain name to the DNS rebind protection.
5. At the top menu change to _TOKEN MANAGEMENT_ and press the _+_ button on the right. A popup with _Generate New Token_ will show up. Enter a token name of your choosing (the name doesn't matter and is only for the convenience of knowing what the token is used for). Press _save_.  
  
    Now there will be a green bar at in the popup saying:
    ```
    Your new token's secret value is: aaaabbbbccccddddeeeeffffgggg
    It is only displayed once.
    ```
    Copy the secret token value into a text editor because you'll need it later. Don't worry, you can always come back to this step and generate a new token in case you lose the secret token value.


## Install `acme.sh`

1. Run the following command on your server to install `acme.sh`:
    ```bash
    curl https://get.acme.sh | sh -s
    ```
  
    If you wish to receive an expiration notification email before your certificates expires you can insert your email address and install acme.sh with the following command:

    ```bash
    curl https://get.acme.sh | sh -s email=my@example.com
    ```

    You can find more information on expiration emails here: https://letsencrypt.org/docs/expiration-emails/

2. Run the command - `exec $SHELL`. This will pick up on anything new which the installation has installed.


## Configure `acme.sh`

1. First enable auto updates. This allows the script to keep itself updated:
    ```bash
    acme.sh --upgrade --auto-upgrade
    ```
2. Next change the default CA (Certificate Authority) to Let's Encrypt (see explanation in the remarks):
    ```bash
    acme.sh --set-default-ca --server letsencrypt
    ```
3. Take the token from your DynDNS provider and insert it into either one of the following commands between the quotation marks:  
    ```bash Duck DNS
    export DuckDNS_Token="aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    ```
    ```bash deSEC
    export DEDYN_TOKEN="aaaabbbbccccddddeeeeffffgggg"
    ```


## Issuing a TLS Certificate

In the following commands you need to replace `$YOURDNS` with either _dns_duckdns_ for Duck DNS or _dns_desec_ if you chose deSEC. Insert your registered sub domain in the following command to issue your first certificate:

```bash
acme.sh --issue --dns $YOURDNS --domain $YOURDOMAIN
```

If you have registered more domains you can add them as alternative names to the certificate by adding more `--domain $YOURDOMAIN` at the end, for example:

```sh
acme.sh --issue --dns $YOURDNS --domain subdomain.example.com --domain subdomain-nextcloud.example.com --domain subdomain-vaultwarden.example.com
```

The first given `--domain` of the `--issue` command will be the primary domain of the certificate and the only one domain you will need to state when running other `acme.sh` commands. I would recommend keeping the primary domain the same when adding/removing other subdomains.


## 4. Installing The Certificate to a Target Directory

After the certificate is issued, `acme.sh` needs to copy the certificate to a target directory. The target directory (or at least filename) must be unique. Your `reloadcmd` command must also be for this specific certificate.

The following command sets the variable `CERTIFICATE_DIRECTORY` (which is just for ease of use in the next command) with a directory of your choosing as well as creates the directory.

```bash
CERTIFICATE_DIRECTORY=$HOME/certificates
mkdir -p "$CERTIFICATE_DIRECTORY"
```

Now tell `acme.sh` where and under which filenames it should copy the certificate (`--cert-file` and `--fullchain-file`) and key (`--key-file`) files and which command (`--reloadcmd`) it should run to restart your reverse proxy or other service.

```bash
acme.sh --install-cert --domain $YOURDOMAIN --cert-file "$CERTIFICATE_DIRECTORY/certificate.pem" --fullchain-file "$CERTIFICATE_DIRECTORY/fullchain.pem" --key-file "$CERTIFICATE_DIRECTORY/key.pem" --reloadcmd "sudo service apache2 force-reload"
```

In the above example we've set the directory to store the certificate files as a `certificates` directory within your home directory and to run the command `sudo service apache2 force-reload` once the certificate has been obtained.

## Automatic Renewal

Certificates from Let's Encrypt are only valid for 90 days. Because of this `acme.sh` will create a daily cronjob that runs at a random time. When the task is run it will:
* Renew every certificate after 60 days.
* Copy the certificate and key files to their previously configured destination directory.
* Run the `reloadcmd` command as previously configured.


## Notes

1. **How can I add more domain names to my certificate?**  
    Run the command from [Issuing a TLS Certificate](#issuing-a-tls-certificate) again with all domain names (old and new) that you want in your certificate. As long as the primary domain stays the same it is not necessary to install the certificate again.  
  
    After changing the domain names with the `--issue` parameter, it will not copy the new certificate to it's destination or run the `--reloadcmd` that was set with the `--install-cert` command. You will either have to do it by yourself or run the `--install-cert` command again (with all the same parameters as before) or copy the files manually from the `.acme.sh` directory in your home directory. If you don't know the parameters from last time you can look them up in the info about the certificate (see next point).
2. **Show configuration of `acme.sh`:**
    ```bash
    acme.sh --info
    ```
3. **Show configuration of a certificate:**
    ```bash
    acme.sh --info -d $YOURDOMAIN
    ```
4. **List all certificates issued with `acme.sh`:**
    ```bash
    acme.sh --list
    ```
5. **Remove a certificate from `acme.sh`:**
    ```bash
    acme.sh --remove -d YOURDOMAIN
    ```
6. **Why change the default CA to Let's Encrypt?**  
    I did encounter bugs with the default CA of acme.sh (ZeroSSL) which where gone once I switched to Let's Encrypt.

7. **How to create a wildcard certificate:**  
    Add `*.YOURSUBDOMAIN.YOURSITEDOMAIN.com` as an alternative domain name to your certificate:
    ```bash
    acme.sh --issue --dns dns_... --domain YOURSUBDOMAIN.YOURSITEDOMAIN.com --domain *.YOURSUBDOMAIN.YOURSITEDOMAIN.com
    ```
    In theory it works with Duck DNS, but if you add the wildcard as an alternative name there sadly is a bug or incompatibility (depending on who you want to blame) and acme.sh runs into an infinite loop. It works if you only use the wildcard domain as the primary domain name. But with only a wildcard in the certificate I don't know if this certificate will play nice with all devices, browsers and applications.  
      
    If you want to use acme.sh and create a wildcard certificate desec.io works as a DNS provider.

8. **How to create a staging certificate for testing:**
    Add the `--test` parameter to the `--issue` command to create test (or staging) certificates which are not valid but are better if you are just testing things. The certificate will stay in the staging environment until you renew it without the `--test` parameter:
    ```bash
    acme.sh --renew -d YOURSUBDOMAIN.YOURSITEDOMAIN.com
    ```

    More on that topic here: https://letsencrypt.org/docs/staging-environment/

9. **Uninstall `acme.sh`:**
    ```bash
    acme.sh --uninstall
    ```

    and delete the `.acme.sh` directory in your home directory.

---
authors:
    - name: jimmybrancaccio
      link: https://github.com/jimmybrancaccio
      avatar: ":dragon_face:"
label: Dell OMSA HDD Errors
title: Fixing Hard Drive Error Icons in Dell OMSA
icon: alert-fill
order: alpha
---

Difficulty: [!badge variant="success" text="Easy / Basic"]

For those of us who are using non-Dell hard drives, you may notice an error or warning icon in OMSA. They will also show up as uncertified, which can be a bit annoying. Thankfully, this is relatively easy to fix. If you've installed Dell OMSA on a Linux system, you may follow these steps:

1. First stop all of the Dell services by running `srvadmin-services.sh stop`.
2. Go into the `/opt/dell/srvadmin/etc/srvadmin-storage/` directory.
3. Back up the config file with `cp stsvc.ini stsvc.ini.bak`.
4. Open the `stsvc.ini` file and locate the following text:
```ini
;nonDellCertified flag for blocking all non-dell certified alerts.
NonDellCertifiedFlag=yes
```

Change this text to:
```ini
;nonDellCertified flag for blocking all non-dell certified alerts.
NonDellCertifiedFlag=no
```
5. Save and exit the file.
6. Start up the Dell services again using `srvadmin-services.sh start`.

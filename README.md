# freeipa-pen
## Email alerts and reports for expiring passwords in a FreeIPA domain.

FreeIPA-PEN is a bash script designed to be installed on an IPA server and invoked by cron.  

### There are two functions which may be called as arguements:  

## notify_users
```
./mailer.sh notify_users
```
This function is designed to be run every day. It queries users in LDAP via a system account configured in mailer.conf and sends an email to the user's email address if it exists and the expiration of their password falls within the notification window.  

## admin_report  
```
./mailer.sh admin_report
```



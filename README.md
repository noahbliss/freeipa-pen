# freeipa-pen
## Password Expiration Notifications for FreeIPA

FreeIPA-PEN is a bash script designed to be installed on an IPA server and invoked by cron. It sends emails to users to alert of imminent password expiration. It can also email an admin user a report on soon-to-expire and already expired accounts.  

`install.sh` copies `mailer.sh` and `mailer.conf` to `/etc/passexp/` and sets sane permissions.  

Configuration before use is required and can be done in the `mailer.conf` file.  
You will also need:  
- a FreeIPA System (Service) Account - [FreeIPA-SAM](https://github.com/noahbliss/freeipa-sam) can help  
- users in FreeIPA with valid "mail" values  
- a mail server that will accept and route notification messages (easiest way would probably be an internal open relay with only the FreeIPA server whitelisted)

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
This function is designed to be run at less regular intervals, like every week or month. It enumerates enabled accounts that do not have a valid mail value and lists them in a report for your administrator before they expire. It also includes a list of enabled but expired accounts for review.  

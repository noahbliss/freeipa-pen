#!/usr/bin/env bash
source /etc/passexp/mailer.conf
#user=
#password=
#hostname=
#bind_dn="uid=svc_passexp,cn=sysaccounts,cn=etc,dc=sec,dc=local"
#search_base="cn=users,cn=accounts,dc=sec,dc=local"
#warn_days=7
#email_from=
#admin_email=
#email_subject=
#email_body=
#nomail_subject=
#nomail_body=

#ldap_out=/etc/passexp/ldap_output
#nomail_users=/etc/passexp/nomail_users
#expired_users=/etc/passexp/expired_users

notify_users() {
        touch "$ldap_out" "$nomail_users" "$expired_users"
        < /dev/null > "$ldap_out" # wipe $ldap_out
        < /dev/null > "$nomail_users" # wipe $nomail_users
        < /dev/null > "$expired_users" # wipe $expired_users
	chmod 600 "$ldap_out" "$nomail_users" "$expired_users"
	# Fetch info from ldap
	ldapsearch -xw "$password" -D "$bind_dn" -b "$search_base" -LLL "(&(krbPasswordExpiration=*)(!(nsaccountlock=TRUE)))" dn uid krbPasswordExpiration mail > "$ldap_out"
	echo "" >> "$ldap_out" # add a blank line so the last user processes
	
	while read line; do
	    lineroot=`echo "$line" | cut -d':' -f1`
	    case "$lineroot" in
	        "dn")
	            dn=`echo "$line" | cut -d' ' -f2`
	            unset uid mail days_left
	            ;;
	        "uid")
	            uid=`echo "$line" | cut -d' ' -f2`
	            ;;
	        "krbPasswordExpiration")
	            ldap_exp=`echo "$line" | cut -d' ' -f2`
		    parsed="${ldap_exp:0:4}-${ldap_exp:4:2}-${ldap_exp:6:2}"
	            days_left=$(((($(date -d $parsed +%s) - $(date +%s)) / (24*3600)) + 1))
	            unset ldap_exp
	            ;;
	        "mail")
	            mail=`echo "$line" | cut -d' ' -f2`
	            ;;
	        *)
		    if [ $uid ] && [ $days_left ] && [ -z $mail ] && [ $days_left -le $nomail_warn_days ] && [ $days_left -ge 0 ]; then
		    	echo "$uid -- expiring in $days_left days" >> "$nomail_users"
		    elif [ $uid ] && [ $days_left ] && [ $days_left -lt 0 ]; then
			echo "$uid,$parsed,$mail" >> "$expired_users"
		    elif [ $uid ] && [ $days_left ] && [ $mail ] && [ $days_left -le $warn_days ] && [ $days_left -gt 0 ]; then
	    	    	echo -e "$email_body\n\n Days remaining: $days_left" | mailx -s "$email_subject" -r "$email_from" -S smtp="$mail_server" "$mail"
			#echo "Email would be sent to $mail for $uid with $days_left left"
    	    	    elif [ $uid ] && [ $days_left ] && [ $mail ]; then
			echo "$uid expiring in $days_left does not meet threshold."
		    fi
		    unset parsed dn uid mail days_left
	            ;;
	    esac
	        
	        
	done < "$ldap_out"
	#< /dev/null > "$ldap_out" # wipe $ldap_out
}

admin_report() {
	nomail_num=`wc -l $nomail_users | cut -d' ' -f1`
	expired_users_num=`wc -l $expired_users | cut -d' ' -f1`
	nomail_message="There are $nomail_num accounts with no email address on file with passwords expiring within the next $nomail_warn_days days."
	expired_message="There are $expired_users_num accounts with expired passwords."
	echo  -e "Begin report:\n\n$nomail_message\n$expired_message\n\nNo Mail users:\n\n$(cat $nomail_users)\n\n--------\n\nExpired password accounts:\n\n$(cat $expired_users)" | mailx -s "$admin_report_subject" -r "$email_from" -S smtp="$mail_server" "$admin_email"	
}

if [ -z $1 ] || [ $1 == "help" ]; then
    echo "You need to specify either $0 notify_users or $0 admin_report"
    exit
fi
$@

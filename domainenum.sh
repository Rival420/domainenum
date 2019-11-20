#! /bin/bash

if [[ $# -lt 1 ]];then
        printf "[-] Please specify a domain"
	exit 1 #exit the script
fi

printf "[+] enumerating subdomains for $1 ..."
subfinder -d $1 -o subdomains.txt 1>/dev/null --silent

printf "[+] Looking up IP addresses for the found subdomains...\n\n"
for domain in $(cat subdomains.txt); do
	host $domain 2>/dev/null | grep "has address" | cut -d" " -f4 >> iplist.txt
done
printf "[+] checking each IP with shodan...\n"
for ip in $(cat iplist.txt); do
	shodan host $ip 2>/dev/null  > $ip
done

printf "\n"
printf "[+] deleting empty results\n"
find . -type f -size 0 -delete

printf "[+] printing results for domain $1"
printf "\n"
for result in $(ls | grep -v "txt\|sh");do
	printf "\nIP Address: $result \nHostname: $(cat $result | grep 'Hostnames' | awk -F' ' '{print $2}')\n\n"
	printf "$(cat $result | grep 'Number')\n"
	printf "$(cat $result | grep '/tcp\|/udp')\n"
	printf "$(cat $result | grep 'CVE')\n"
	printf "\n"
	printf "******************************************"
	printf "\n"
done

printf "\n"
printf "[+] Cleaning up results"

mkdir ../test/$1
for file in $(ls | grep -v "sh"); do
	mv $file ../test/$1
done

printf "\n"
printf "[+] Command Completed, check results"
printf "\n"


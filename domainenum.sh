#! /bin/bash

if [[ $# -lt 1 ]];then
        printf "[-] Please specify a domain\n"
	exit 1 #exit the script
fi

printf "[+] enumerating subdomains for $1 ...\n\n"
subfinder -d $1 -o subdomains.txt 1>/dev/null --silent

printf "[+] Looking up IP addresses for the found subdomains...\n\n"
for domain in $(cat subdomains.txt); do
	host $domain 2>/dev/null | grep "has address" | cut -d" " -f4 >> iplist.txt
done

printf "[+] checking each IP with shodan...\n\n"
for ip in $(cat iplist.txt); do
	shodan host $ip 2>/dev/null  > $ip
done

printf "[+] deleting empty results\n\n"

find . -type f -size 0 -delete

printf "[+] printing results for domain $1\n"
printf "\n"
for result in $(ls | grep -v "txt\|sh\|domain_results");do
	printf "\nIP Address: $result \nHostname: $(cat $result | grep 'Hostnames' | awk -F' ' '{print $2}')\n\n"
	printf "$(cat $result | grep 'Number')\n"
	printf "$(cat $result | grep '/tcp\|/udp')\n"
	printf "$(cat $result | grep 'CVE' | sort -nu)\n"
	printf "\n"
	printf "******************************************"
	printf "\n"
done

printf "\n"
printf "[+] Cleaning up results"
if [ ! -d domain_results ]; then
  mkdir domain_results
fi
if [ ! -d domain_results/$1 ]; then
  mkdir domain_results/$1
fi
for file in $(ls | grep -v "sh\|domain_results" ); do
    mv $file domain_results/$1
done

#mkdir ../results/$1
#for file in $(ls | grep -v "sh"); do
#	mv $file ../results/$1
#done

printf "\n"
printf "[+] Command Completed, check results"
printf "\n"


#!/bin/bash

help() {
	splash
	echo -e "[${yellow}*${default}] Usage: ./${red}nssecu2${default} <target/file> <threads>"
}

report() {
	mkdir Scans Scans/${1} &> /dev/null
	mkdir Output Output/${1} &> /dev/null
}

port_scan() {
	echo -e "[${yellow}*${default}] Target: $1 Number of threads: ${thread}."
	echo -e "[${yellow}*${default}] Checking if the port is open: ${1}...\n"
	sleep 1
	nmap -T4 -Pn -v --open $1 -p 80,443,8000,8080 -oN Scans/${1}/$1.txt
	echo -e "[${yellow}*${default}] Scan finished."
	sleep
}

bruteforce() {
    if grep -q 80/tcp Scans/${1}/${1}.txt; then
        echo -e "[${yellow}*${default}] Port 80(HTTP) is open. Starting bruteforce...\n"
		sleep 1
		#hydra -L $user -P $pass $1 http-get -f -q -e ns -o Output/${1}/http-get_${1}.txt -I -V / -t $thread
        gobuster dir -u http://$1 -w /usr/share/wordlists/dirb/commont.txt -o Output/${1}/http-get_${1}.txt -v -t $thread
        finished_brute $1
    else
        echo -e "[${red}!${default}] Port 80(HTTP) is not open...."
    fi

    if grep -q 443/tcp Scans/${1}/${1}.txt; then
        echo -e "[${yellow}*${default}] Port 443(HTTPS) is open. Starting bruteforce...\n"
		sleep 1
		#hydra -L $user -P $pass $1 https-get -s 443 -f -q -e ns -o Output/${1}/https-get_${1}.txt -I -V -m / -t $thread
        gobuster dir -u https://$1 -w /usr/share/wordlists/dirb/commont.txt -o Output/${1}/http-get_${1}.txt -v -t $thread
        finished_brute $1
    else
        echo -e "[${red}!${default}] Port 443(HTTPS) is not open, quitting..."
    fi

    #if grep -q 8000/tcp Scans/${1}/${1}.txt; then
        #echo -e "[${yellow}*${default}] Port 8000(HTTP HEAD) is open. Starting bruteforce...\n"
		#sleep 1
		#hydra -L $user -P $pass $1 http-head -s 8000 -f -q -e ns -o Output/${1}/http-head_8000_${1}.txt -I -V -m / -t $thread
		#gobuster dir -u http://$1 -w /usr/share/wordlists/dirb/commont.txt -o Output/${1}/http-get_${1}.txt -v -t $thread
        #finished_brute $1
    #else
        #echo -e "[${red}!${default}] Port 8080(HTTP HEAD) is not open..."
    #fi

    #if grep -q 8080/tcp Scans/${1}/${1}.txt; then
        #echo -e "[${yellow}*${default}] Port 8080(HTTP HEAD) is open. Starting bruteforce...\n"
	    #sleep 1
		#hydra -L $user -P $pass $1 http-head -S 8080 -f -q -e ns -o Output/${1}/http-head_8080_${1}.txt -I -V -m / -t $thread
		#gobuster dir -u http://$1 -w /usr/share/wordlists/dirb/commont.txt -o Output/${1}/http-get_${1}.txt -v -t $thread
        #finished_brute $1
    #else
        #echo -e "[${red}!${default}] Port 8080(HTTP HEAD) is not open, quitting..."
    #fi
}

finished_brute() {
        echo -e "[${green}*${default}] Bruteforce finished. Credentials found saved at: Output/${1}/."
        sleep 1
}

	red='\033[0;31m'
	green='\033[0;32m'
	yellow='\033[0;33m'
	default='\033[0;39m'

    thread="16"

	splash

    if [ $# -eq 0 ]; then
                echo -e "[${red}!${default}] Error: No arguments supplied."
                echo -e "[${yellow}*${default}] Usage: ./nssecu2 <target/file> <threads>"
		exit
	fi

	if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
		help
		exit
	fi

    if [ ! -z "$2" ]; then
        if [ "$2" -gt "64" ] || [ "$2" -lt "1" ]; then
            echo -e "[${red}!${default}] Maximum number of threads is 64!"
            exit
        else
            thread=$2
        fi
    fi

	if [[ -f $1 ]]; then
		while IFS= read -r line
			do
				sleep 1
				report $line
				port_scan $line
				bruteforce $line $2
		done < "$1"
		exit
	fi

	sleep 1
	report $1
	port_scan $1
	bruteforce $1 $2

#!/bin/bash

# Check if IP of target is entered

if [ -z "$1" ] && [ -z "$2" ]

 then

    echo "Correct usage is ./recon.sh IP MINRATE-NMAP"

    exit

  else

    echo "Target IP $1"

    echo "Running Nmap…"

# Run Nmap scan on target and save results to file

    nmap -sVC -p- --min-rate $2 --script vuln $1 > scan_results.txt

    echo "Scan complete – results written to scan_results.txt"

fi

# If the Samba port 445 is found and open, run enum4linux.

if grep 445 scan_results.txt | grep -iq open

  then

    enum4linux -U -S $1 >> scan_results.txt

    echo "Samba found. Enumeration complete."

    echo "Results added to scan_results.txt."

    echo "To view the results, cat the file."

  else

   echo "Open SMB share ports not found."


fi

if grep 80 scan_results.txt | grep -iq open
  then
    echo "HTTP Found. Running gobuster..."
    echo "Wait up to 5 min!"
    gobuster dir --url http://$1 -w /usr/share/dirb/wordlists/common.txt -x php >> scan_results.txt
    echo "Results added to scan_result.txt"
    echo "Running Nmap with nikto scan..."
    nikto -h $1
    echo "Results added to scan_result.txt"
  else
    echo "http port not found..."
fi

if grep 8080 scan_results.txt | grep -iq open
  then
    echo "Probably other HTTP service found on 8080!"
  else
    echo "No other http services!"
fi

echo "Scan Completed!"
echo "Results writed to scan_result.txt! Bye!"

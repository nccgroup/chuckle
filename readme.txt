Chuckle - An automated SMB Relay Script.

Chuckle requires a few tools to work:

SMBRelayX.py
Veil (latest version from git)
Responder (Comment out appropriate line if using latest version/old version due to a change in options relating to interface)
Nmap
Nbtscan (unixwiz)
MSFconsole

Usuage should be fairly simple, run as root or use sudo:

sudo ./chuckle.sh

Wait a while or coax a prvileged user into authenticating against you and you should end up with a shell on your target machine. 
Be careful when running this and never run on a network you are not permitted to do so.

Thanks to theguly for his additions. 

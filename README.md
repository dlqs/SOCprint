```
Bash script to print stuff in NUS SoC.

Usage (one-liner):
curl -s https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh | bash /dev/stdin -u <username> -f <filename> -p <printqueue>

Voila! No drivers to mess with.

Requirements: bash and a sunfire account. You need to be connected to SoC wifi, directly or via VPN.
You will be prompted for your password by ssh (unless you use the -i option). This script *does not* record/capture your password.

Roughly, this script will:
1. Using ssh, copy your file into your home directory in sunfire.comp.nus.edu.sg to a temporary, random name.
2. Submit your job to the printqueue.
3. List the printqueue. You *should* see your job here. If not, something has gone wrong.
4. Remove the temporary file.

Parameters

 -u, --username         (required) Sunfire username (without the @sunfire.comp.nus.edu.sg part).
 -i, --identity-file    (optional) Identity file to pass into ssh. If set, avoids interactive password.
 -f, --filename         (required to print) File to print. Tested with PDF/plain text files. Undefined behaviour for anything else.
 -p, --printqueue       (optional to print) Printqueue to send job to. Defaults to psc008-dx.
 -l, --list-printqueues (required to list printqueues) List printqueues. See below.

Print command example: 
./socprint.sh -u d-lee -f ~/Downloads/cs3210_tutorial8.pdf -p psc008-dx

List printqueue command example:
./socprint.sh -u d-lee -l

Printqueues

You're probably looking for one of these:
 - COM1 basement:                   psc008 psc008-dx psc008-sx psc011 psc011-dx psc011-sx
 - COM1 L1, in front of Tech Svsc:  psts psts-dx psts-sx pstsb pstsb-dx pstsb-sx
 - Most other printers have user restrictions. See https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues

The suffixes mean:
 - (no suffix) or -dx: double sided
 - -sx: single sided

Complete list of valid printqueues (generated with -l option; last updated 4 March 2021):  
 - Some printers have user restrictions. See https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues

psts psts-sx psts-dx psts-nb pstsb pstsb-sx pstsb-dx pstsb-nb pstsc pstsc-sx pstsc-dx pstsc-nb psgob psgob-sx psgob-dx psgoc psgoc-sx psgoc-dx 
psa206 psa206-sx psa206-dx psa403 psa403-sx psa403-dx psa411 psa411-sx psa411-dx psa413 psa413-sx psa413-dx psa421 psa421-sx psa421-dx psa425 
psa425-sx psa425-dx psa426 psa426-sx psa426-dx psa427 psa427-sx psa427-dx psa501 psa501-sx psa501-dx psa502 psa502-sx psa502-dx psa518 psa518-sx 
psa518-dx psa518-nb psa518-nb-sx psa521 psa521-sx psa521-dx psa522 psa522-sx psa522-dx psa525 psa525-sx psa525-dx psa618 psa618-sx psa618-dx psc008 
psc008-sx psc008-dx psc008-nb psc011 psc011-sx psc011-dx psc011-nb psc102 psc102-sx psc102-dx psc102-nb psc102-nb-sx psc106 psc106-sx psc106-dx 
psc106-nb psc106-nb-sx psc106-nb-dx psc107 psc107-sx psc107-dx psc108 psc108-sx psc108-dx psc109 psc109-sx psc109-dx psc110 psc110-sx psc110-dx 
psc111 psc111-sx psc111-dx psc113 psc113-sx psc113-dx psc115 psc115-sx psc115-dx psc116 psc116-sx psc116-dx psc119 psc119-sx psc119-dx psc121 
psc121-sx psc121-dx psc313 psc313-sx psc313-dx psc313-nb psc313-nb-sx psd001 psd001-sx psd001-dx psd002 psd002-sx psd002-dx psd003 psd003-sx 
psd003-dx psd102 psd102-sx psd102-dx psd103 psd103-sx psd103-dx psd105 psd105-sx psd105-dx psd106 psd106-sx psd106-dx psd107 psd107-sx psd107-dx 
psd109 psd109-sx psd109-dx psd110 psd110-sx psd110-dx psd238 psd238-sx psd238-dx psd238-nb psd238-nb-sx psd263 psd263-sx psd263-dx psd263-nb 
psd263-nb-sx psd313 psd313-sx psd313-dx psd313-nb psd313-nb-sx psd404 psd404-sx psd404-dx psd405 psd405-sx psd405-dx psd405-nb psd405-nb-sx 
psi505 psi505-sx psi505-dx psu102 psu102-sx psu102-dx psx302 psx302-sx psx302-dx psx302-nb psx302-nb-sx psx306 psx306-sx psx306-dx psx342a 
psx342a-sx psx342a-dx psx342b psx342b-sx psx342b-dx

```

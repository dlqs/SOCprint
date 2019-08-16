# Print stuff in SoC
### This script copies your print file into your @sunfire.nus.edu.sg account and then sends it to SoC printers.

### Requirements
 - Bash
 - A .pdf file
 - A valid sunfire account (You will be asked to log in twice. Your password is not saved.)
 
### Usage
To print:
`./socprint.sh <username> <filename>`  
e.g. `./socprint.sh -c dlee ~/Downloads/tutorial1.pdf`
 
To download: either clone this repository, or run `wget https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh`

To use it from outside the source directory: `# ln -s <full path to>/socprint.sh /usr/local/bin`

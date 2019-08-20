# Print stuff in SoC
### This script copies your print file into your @sunfire.nus.edu.sg account and then sends it to SoC printers.

Works for the four black-and-white and double-sided-capable printers.

### Requirements
 - Bash
 - A .pdf/.txt file
 - A valid sunfire account (Your password is not saved.)
 
### Usage
To print:
 - `./socprint.sh <username> <filename>`  
e.g. `./socprint.sh dlee ~/Downloads/tutorial1.pdf`
 
To download:
 - Clone this repository, or
 - Run `wget https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh`

To use it from outside the source directory: 
 - `# ln -s <full path to>/socprint.sh /usr/local/bin`

# Print stuff in SoC
#### This script copies your print file into your @sunfire.nus.edu.sg account and then sends it to SoC printers.

#### Usage: `./socprint.sh <username> <filename>`  
Example: `./socprint.sh -c dlee ~/Downloads/tutorial1.pdf`

#### Requirements:
 - Bash
 - A .pdf file
 - A valid sunfire account (You will be asked to log in twice. Your password is not saved.)

#### To use it from outside the source directory: `# ln -s <full path to>/socprint.sh /usr/local/bin`

# NUS SoC bash script for printing  
### Bash script for copying files into your sunfire.comp.nus.edu.sg account and printing to SoC printers.  

### Usage: `./socprint.sh [-p printer][-c cleanup] username filename`  
Copies `filename` into ~/print then adds it to print queue.  
`username` as in <username>@sunfire.comp.nus.edu.sg.  
`filename` should be in same directory as script. Must be postscript or ASCII file.  
Default printer is psc008-dx.  

Example: `./socprint.sh -c dlee tutorial1.pdf`  
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; `./socprint.sh -p psc008-sx dlee tutorial1.pdf`  

### Options:  
`-p printer`: set printer. Must be valid name as listed under *print queues* at [dochub.comp.nus.edu.sg](https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues)  

`-c cleanup`: set cleanup flag. Removes file (with `rm -i`) after they have been added to the print queue.  

`-a about`: see about. Links to this page.  

`-h help`: see help.

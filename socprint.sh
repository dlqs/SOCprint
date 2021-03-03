#!/bin/bash

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -a | --about )
    echo 1.0.0
    exit
    ;;
  -h | --help )
    echo "Usage: $0 <username> <filename>"
    echo "e.g. $0 dlee ~/Downloads/tutorial.pdf"
    exit
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi


if [[ "$#" != "2" ]]; then
    echo "Usage: $0 <username> <filename>"
    echo "Try '$0 --help' for more information"
    exit 1
elif [[ $1 = *"@"* ]]; then
    echo "Error: <username> should not contain @hostname"
    exit 1
elif [[ -z "$1" ]]; then
    echo "Error: <username> should not be empty"
    exit 1
fi

fullpath="$(realpath "$2")"
echo "Found $fullpath"
if [[ ! -f "$fullpath" ]]; then
    echo "Error: Unable to find $fullpath"
    exit 1
elif [[ $fullpath != *.pdf ]] && [[ $fullpath != *.txt ]]; then
    echo "Error: file extension must be a .pdf or .txt"
    exit 1
fi

echo "Select a printer"
select printer in psc008 psc011 psts pstsc
do
break
done

echo "Select a print mode"
echo "-dx: double side; -sx: single side; -nb: no banner"
select mode in -dx -sx -nb
do
echo "You will be prompted for your sunfire password. It will not be saved."
break
done

printer="$printer$mode"
echo "Submitting $2 for print with $1@sunfire.comp.nus.edu.sg at $printer"

# print
ssh "$1@sunfire.comp.nus.edu.sg" "cat - > $tempname; lpr -P $printer $tempname; lpq -P $printer; rm $tempname;" < "$fullpath"
exit 0

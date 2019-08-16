#!/usr/bin/bash

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -a | --about )
    echo 1.0.0
    exit
    ;;
  -h | --help )
    echo "Usage: $0 <username> <filename>"
    echo "e.g. $0 weili ~/Downloads/tutorial.pdf"
    exit
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi


if [ "$#" != "2" ]; then
    echo "Usage: $0 <username> <filename>"
    echo "Try '$0 --help' for more information"
    exit 1
elif [[ $1 = *"@"* ]]; then
    echo "Error: <username> should not contain @hostname"
    exit 1
elif [ -z "$1" ]; then
    echo "Error: <username> cannot be empty"
    exit 1
fi

fullpath=$(realpath $2)
dirpath=$(dirname $fullpath)
tempname=".temp.$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5 )"
if [ ! -f "$fullpath" ]; then
    echo "Error: Unable to find $fullpath"
    exit 1
elif [[ $fullpath != *.pdf ]]; then
    echo "Error: file must be a .pdf"
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
echo "Selected: $printer$mode"
break
done

printer="$printer$mode"
exit 0
echo "Submitting $2 for print with $1@sunfire.comp.nus.edu.sg at $printer"

# create a copy
cp $fullpath "$dirpath/$tempname"
# transfer over to sunfire server
scp "$dirpath/$tempname" $1@sunfire.comp.nus.edu.sg:~/
# print
ssh $1@sunfire.comp.nus.edu.sg "lpr -P $printer $tempname; echo "===Print Queue==="; lpq -P $printer; rm $tempname; pusage;"
# delete copy
rm "$dirpath/$tempname"
exit 0

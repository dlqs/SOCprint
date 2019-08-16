#!/usr/bin/bash

do_cleanup=true

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -a | --about )
    echo 1.0.0
    exit
    ;;
  -h | --help )
    echo "Usage: $0 <username> <filename>"
    echo "Try '$0 --help' for more information."
    exit
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

echo "Warning: your file will be transferred via the Sunfire server and will overwrite any file of the same name."
if [ "$#" != "2" ]; then
    echo "Usage: $0 <username> <filename>"
    echo "Try '$0 --help' for more information."
    exit 1
elif [ ! -f "$2" ]; then
    echo "Error: file $2 does not exist!"
    exit 1
elif [[ $1 = *"@"* ]]; then
    echo "Error: <username> should not contain @hostname"
    exit 1
elif [ -z "$1" ]; then
    echo "Error: <username> cannot be empty!"
    exit 1
fi

echo "Select a printer"
select printer in psc008 psc008-dx
do
echo "Choose: $printer"
break
done

if [ "$do_cleanup" == "true" ]; then
    cleanup="rm -i .temp.print"
else
    cleanup=""
fi

fullpath=$(realpath $2)
dirpath=$(dirname $fullpath)
filename="$(basename -- $fullpath)"
echo "Submitting $2 for print with user $1@sunfire.comp.nus.edu.sg at $printer"

cp $fullpath "$dirpath/.temp.print"
scp "$dirpath/.temp.print" $1@sunfire.comp.nus.edu.sg:~/
ssh $1@sunfire.comp.nus.edu.sg "lpr -P $printer .temp.print; lpq -P $printer; $cleanup; pusage; logout;"
rm -i "$dirpath/.temp.print"
exit 0

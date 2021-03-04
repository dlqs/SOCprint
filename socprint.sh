#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

export LC_ALL=C

host="sunfire.comp.nus.edu.sg"
default_printqueue="psc008-dx"

usage() {
  cat <<EOF
Usage: "${BASH_SOURCE[0]}" [-h] [-v] [-f] -u username -f filename arg1 [arg2...]

A Bash script to print stuff in NUS SoC.

Print command parameters:

-u, --username          Sunfire username (without @sunfire.comp.nus.edu.sg)
-i, --identity-file     Use provided identity file with ssh
-f, --file              File to print. Accepts PDFs and text files.

List Printqueue command parameters:

-u, --username          Sunfire username (without @sunfire.comp.nus.edu.sg)
-i, --identity-file     Use provided identity file with ssh
-l, --list-printqueue   Show available printqueues

Other options:

-h, --help              Print this help and exit
EOF
  exit
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  identity_file=''
  printqueue=''
  list_printqueues=false

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -l | --list-printqueues) 
      list_printqueues=true
      ;;
    -i | --identity-file) 
      identity_file="${2-}" 
      shift
      ;;
    -p | --printqueue) 
      printqueue="${2-}" 
      shift
      ;;
    -f | --filename) 
      filename="${2-}" 
      shift
      ;;
    -u | --username)
      username="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # check required params and arguments
  return 0
}

parse_params "$@"

[[ -z "${username-}" ]] && die "Missing required parameter: -u/--username"
sshcmd="${username}@${host}"
if [[ ! -z ${identity_file} ]]; then
  # Use the ssh identity_file if provided
  sshcmd="${sshcmd} -i ${identity_file}"
fi

msg "Using ${username}@${host} ..."
if [[ $list_printqueues == true ]]; then
  ssh $sshcmd "cat /etc/printcap | grep '^p' | sed 's/^\([^:]*\).*$/\1/'"
  exit 0
fi

[[ -z "${filename-}" ]] && die "Missing required parameter: -f/--filename"
[[ ! -f "${filename-}" ]] && die "Error: No such file"

filetype=$(file -i $filename | cut -f 2 -d ' ')
[[ $filetype != "application/pdf;" && $filetype != text* ]] && msg "Warning: File is not valid PDF or text. Print behaviour is undefined."

# Generate a random 8 character alphanumeric string *without* tr
tempname=$(perl -e '@c=("A".."Z","a".."z",0..9);$p.=$c[rand(scalar @c)] for 1..8; print "$p\n"')
tempname="SOCPrint_${tempname}"

# The long ssh command does this:
# 1. Copy file to a temporary name on the server
# 2. Submit it to the print queue via lpr
# 3. List the print queue via lpq
# 4. Remove the temporary file

[[ -z "${printqueue-}" ]] && msg "Using default printqueue: ${default_printqueue}" && msg "Hint: To set a different one, use the -p option. To list all, use the -l option."
printqueue=default_printqueue

ssh $sshcmd "cat - > ${tempname}; lpr -P ${printqueue} ${tempname}; lpq -P ${printqueue}; rm ${tempname};" < "${filename}"

exit 0

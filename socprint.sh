#!/bin/sh

set -euf

host="sunfire.comp.nus.edu.sg"
default_printqueue="psc008-dx"
default_script="/usr/local/bin/socprint.sh"

usage() {
  cat <<EOF
NAME
  socprint - POSIX™-compliant, zero-dependency shell script to print stuff in NUS SoC

REQUIREMENTS
  POSIX™-compliant sh, a sunfire account, and connection to SoC wifi.

USAGE
  To use instantly, run the following line:
  curl -s https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh | sh -s -- -u <username> -f <filepath> -p <printqueue>

  To download and run from any directory:
  sudo curl https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh -o $default_script
  sudo chmod 755 $default_script
  socprint.sh -u <username> -f <filepath> -p <printqueue>

PARAMETERS
  -u, --username <username>
    (required) Sunfire username, without the @sunfire.comp.nus.edu.sg part.

  -i, --identity-file <filepath>
    (optional) Additional identity file to use with ssh. Skip if you already set up sunfire identity files for ssh.

  -f, --filepath <filepath>
    (required to print) File to print. Tested with PDF/plain text files. Undefined behaviour for anything else.

  -p, --printqueue <printqueue>
    (required to print/show) Printqueue to send job to. Default: psc008-dx. See PRINTQUEUES.

  -s, --show-printqueue
    (required to show) Show list of jobs at specified printqueue.

  -l, --list-printqueues
    (required to list printqueues) List printqueues, i.e. valid arguments for -p.

  --dry-run
    (for debugging/tests) Echoes commands to be executed without executing them.

EXAMPLES
  To print:
  ./socprint.sh -u d-lee -f ~/Downloads/cs3210_tutorial8.pdf -p psc008-dx

  To list printqueues:
  ./socprint.sh -u d-lee -l

  To show printqueue at psc008:
  ./socprint.sh -u d-lee -s -p psc008

DESCRIPTION
  This script targets conformance to POSIX.1-2017 standards (https://pubs.opengroup.org/onlinepubs/9699919799/).
  This improves portability, enterprise-gradeability, and makes printing in SoC a zero-dependency,
  no-ass-sucking experience. Roughly speaking, this script will:
  1. Login to sunfire using ssh.
     You will be prompted for your password, unless your identity files are set up.
     This script *does not* save/record your password.
  2. Copy the file into your home directory in sunfire, to a temporary file.
  3. Submit your job to the printqueue.
  4. List the printqueue. You job *should* appear. If not, something has gone wrong.
  5. Remove the temporary file.

PRINTQUEUES
  Popular places:
  - COM1 basement:                   psc008 psc008-dx psc008-sx psc011 psc011-dx psc011-sx
  - COM1 L1, in front of tech svsc:  psts psts-dx psts-sx pstb pstb-dx pstb-sx
  - (no suffix)/-dx: double sided, -sx: single sided, -nb: no banner
  - Most other printers have user restrictions.
    See https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues.
  - For the full list of printqueues, generate with the -l option, or view the SOURCE.

SOURCE
  https://github.com/dlqs/SOCprint
  File bugs or compliance issues above. We take POSIX™ conformance seriously.
  POSIX™ is a Trademark of The IEEE.

CONTRIBUTORS
  Donald Lee, Julius Nugroho, Sean Ng

GENERATE README
  ./socprint.sh -h > README \
  && echo "List of valid printqueues, generated with -l option on 5 March 2021\n" >> README \
  && ./socprint.sh -u d-lee -l >> README

EOF
  exit 0
}

msg() {
  # Log messages to stderr instead of stdout
  # Woahhhhh %b siol
  printf "%b\n" "${1-}" >&2
}

die() {
  msg "$1"
  exit 1
}

check_updates() {
  # Calculate git hash-object hash without git, since it is not POSIX compliant
  size=$( wc -c ${default_script} | cut -f 1 -d ' ' )
  my_sha=$( (printf "blob %s\0" "$size" && cat ${default_script}) | shasum -a 1 )

  # Pull latest hash from master
  github_sha=$( curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/dlqs/SOCprint/contents/socprint.sh | sed -n 's/.*"sha":\s"\(.*\)",/\1/p' )
  if [ "$my_sha" != "$github_sha" ]; then
    msg "Hint: You appear to have downloaded this script to $default_script. There's a newer version available ($( printf '%s' "$my_sha" | head -c 10) v $( printf '%s' "$github_sha" | head -c 10 ))."
    msg "Run the following command to download the new script:"
    msg "sudo curl https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh -o $default_script \n"
  fi
}

parse_params() {
  # default values of variables
  identity_file=''
  printqueue=''
  list_printqueues=false
  show_printqueue=false

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -l | --list-printqueues)
      list_printqueues=true
      ;;
    -s | --show-printqueue)
      show_printqueue=true
      ;;
    -i | --identity-file)
      identity_file="${2-}"
      shift
      ;;
    -p | --printqueue)
      printqueue="${2-}"
      shift
      ;;
    -f | --filepath)
      filepath="${2-}"
      shift
      ;;
    -u | --username)
      username="${2-}"
      shift
      ;;
    --dry-run)
      dry_run=true
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

parse_params "$@"

# Only check update if downloaded to local bin and we're not dry-running, as
# this could potentially mess tests up.
[ -f "/usr/local/bin/socprint.sh" ] && [ -z "${dry_run-}" ] && check_updates

[ -z "${username}" ] && die "Missing required parameter: -u/--username"
sshcmd="${username}@${host}"

# Use the ssh identity_file if provided
[ -n "${identity_file}" ] && sshcmd="${sshcmd} -i ${identity_file}"

if [ -n "${dry_run-}" ]; then
  eval_or_echo_in_dry_run='echo'
else
  eval_or_echo_in_dry_run='eval'
fi

msg "Using ${username}@${host} ..."

if [ "${list_printqueues}" = true ]; then
  cmd=$( cat <<EOF
ssh $sshcmd "cat /etc/printcap | grep '^p' | sed 's/^\([^:]*\).*$/\1/'"
EOF
  )
  $eval_or_echo_in_dry_run "$cmd"
  exit 0
fi

if [ -z "${printqueue-}" ]; then
  msg "Using default printqueue: ${default_printqueue}"
  msg "Hint: To set a different one, use the -p option. To list all, use the -l option."
  printqueue="${default_printqueue}"
fi

if [ "${show_printqueue}" = true ]; then
  cmd=$( cat <<EOF
ssh $sshcmd "lpq -P ${printqueue};"
EOF
  )
  $eval_or_echo_in_dry_run "$cmd"
  exit 0
fi

[ -z "${filepath-}" ] && die "Missing required parameter: -f/--filepath"
[ ! -f "${filepath-}" ] && die "Error: No such file"

filetype=$( file -i "${filepath}" | cut -f 2 -d ' ')
[ "${filetype}" != 'application/pdf;' ] && [ "$( printf '%s' "$filetype" | head -c 4 )" != 'text' ] && msg "Warning: File is not PDF or text. Print behaviour is undefined."

# Generate random 8 character alphanumeric string in a POSIX compliant way
tempname=$( awk 'BEGIN{srand();for(i=0;i<8;i++){r=int(61*rand());printf("%c",r<10?48+r:r<35?55+r:62+r)}}' )
tempname="SOCPrint_${tempname}"

cmd=$( cat <<EOF
ssh $sshcmd "
  cat - > ${tempname};
  lpr -P ${printqueue} ${tempname};
  lpq -P ${printqueue};
  rm ${tempname};" < "${filepath}"
EOF
  )
$eval_or_echo_in_dry_run "$cmd"

exit 0

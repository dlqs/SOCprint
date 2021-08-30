#!/bin/sh

#  ======================================================================
#
#  MIT LICENSE
#
#  Copyright (c) 2021-present Donald Lee and contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#  
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#  ======================================================================

set -euf
export LC_ALL=C
host='sunfire.comp.nus.edu.sg'
default_script='/usr/local/bin/socprint.sh'

usage() {
    cat <<EOF
NAME
  socprint.sh - POSIX™-compliant, zero-dependency shell script to print in NUS SoC

SYPNOSIS
  socprint.sh (p|print) [options] <username> <printqueue> [-|<filepath>]
  socprint.sh (j|jobs ) [options] <username> <printqueue>
  socprint.sh (l|list ) [options] <username>
  socprint.sh (h|help )

QUICKSTART
  To print a file instantly, copy and paste the following line into your shell:
  curl -s https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh | sh -s -- print <username> <printqueue> <filepath>

  Alternatively, use the hosted version at https://socprint.xyz

DESCRIPTION
  This script requires a POSIX™-compliant sh, a sunfire account, and connection to
  SoC wifi.

  Besides the above, this script has zero-dependencies, is portable, and handles text/byte streams. This makes printing
  in SoC a painless, non-ass-sucking experience that doesn't require installing any drivers.

COMMANDS (shortname|longname)
  (p|print) Print a file at specified printqueue.
  (j|jobs ) List jobs at specified printqueue.
  (l|list ) List all printqueues.
  (h|help ) Show this message.

OPTIONS
  <username>
    Sunfire username, without the @sunfire.comp.nus.edu.sg part.

  <printqueue>
    Printer + suffix. See PRINTQUEUES for commonly-used printers.

  [-|<filepath>]
    Print file. Recommended PDF/text. Undefined behaviour for other file types.
    If unspecified or -, read from standard input.

  -i, --identity-file <filepath>
    (optional) Additional identity file to use with ssh. Skip if you already set
    up sunfire identity files for ssh.

  -2
    (optional) Prints every two logical pages onto one physical page.
    Can only be used for pdf files that have portrait orientation.

  --dry-run
    (for debugging/tests) Echoes commands to be executed without executing them.

EXAMPLES
  To print from filepath:
    ./socprint.sh print d-lee psc008-dx ~/d/cs3210_tutorial8.pdf

  To combine with curl and the pipe operator:
    curl -s https://www.comp.nus.edu.sg/~ooibc/bxtree.pdf | ./socprint.sh print d-lee psc008-dx

  To print with shortname, using the redirection operator:
    ./socprint.sh p d-lee psc008-dx < ~/d/cs3210_tutorial8.pdf

  To check jobs:
    ./socprint.sh jobs d-lee psc008-dx

  To list printqueues:
    ./socprint.sh list d-lee

  To download and run from any directory:
    sudo curl https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh -o $default_script
    sudo chmod 755 $default_script

PRINTQUEUES
  Popular places:
  - COM1 basement:                   psc008-dx psc008-sx psc011-dx psc011-sx
  - COM1 L1, in front of tech svsc:  psts-dx psts-sx pstb-dx pstb-sx pstc-dx pstc-sx
  - -dx: double sided, -sx: single sided, -nb: no banner
  - Most other printers have user restrictions.
    See https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues.
  - For the full list of printqueues, generate with the -l option, or view the SOURCE.

IMPLEMENTATION
  Roughly speaking, the print command will:
  1. Login to sunfire using ssh.
     You will be prompted for your password, unless your identity files are set up.
     This script *does not* save/record your password.
  2. Copy the file into your home directory in sunfire, to a temporary file.
  3. Submit your job to the printqueue.
  4. List the printqueue. You job *should* appear. If not, something has gone wrong.
  5. Remove the temporary file.

STANDARDS
  This script targets conformance to POSIX.1-2017 standards (https://pubs.opengroup.org/onlinepubs/9699919799/).
  Yes, you read that right and no, we're not kidding. POSIX™ compliance is serious enterprise business!!!1
  POSIX™ is a Trademark of The IEEE.

SOURCE
  https://github.com/dlqs/SOCprint
  File bugs or POSIX™ compliance issues above.

CONTRIBUTORS
  Donald Lee, Julius Nugroho, Sean Ng

KEYWORDS
  how to print NUS SoC National University of Singapore School of Computing
  printers shell command line basement sunfire mac windows linux bsd ben

LICENSE
  This project is licensed under terms of the MIT License. Full text in source code.

GENERATE README
  ./socprint.sh help > README \
  && echo "List of valid printqueues, generated with list command on 5 March 2021\n" >> README \
  && ./socprint.sh list d-lee >> README

EOF
exit 0
}

msg() {
    # Log messages to stderr instead of stdout
    printf "%b\n" "${1-}" >&2
}

die() {
    msg "$1"
    exit 1
}

star_banner() {
    printf "If you liked our script, help us out with a star! https://github.com/dlqs/SOCprint" | awk '
BEGIN {
    srand();
    s=int(rand()*10);
} { 
    c=128;
    w=127;
    f=0.1;
    for (i=1; i<=length($0); i+=1) {
        v=s+f*(i+2*NR);
        r=sin(v)*w+c;
        g=sin(v+2.094)*w+c;
        b=sin(v+4.188)*w+c;
        printf "\x1b[38;2;%d;%d;%dm%s", r, g, b, substr($0, i, 1);
    }
    printf "\x1b[0m\n";
}
'
}

check_updates() {
    # Calculate git hash-object hash without git, since it is not POSIX compliant
    size=$( wc -c ${default_script} | cut -f 1 -d ' ' )
    my_sha=$( (printf "blob %s\0" "$size" && cat ${default_script}) | shasum -a 1 | cut -f 1 -d ' ')

  # Pull latest hash from master
  github_sha=$( curl -m 1 -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/dlqs/SOCprint/contents/socprint.sh | sed -n 's/.*"sha":\s"\(.*\)",/\1/p' )
  if [ "$my_sha" != "$github_sha" ]; then
      msg "Hint: You appear to have downloaded this script to $default_script. There's a newer version available ($( printf '%s' "$my_sha" | head -c 10) v $( printf '%s' "$github_sha" | head -c 10 ))."
      msg "Run the following command to download the new script:"
      msg "sudo curl https://raw.githubusercontent.com/dlqs/SOCprint/master/socprint.sh -o $default_script"
  fi
}

command="${1-}"
shift

identity_file=''
options=''

while :; do
    case "${1-}" in
        -i | --identity-file)
            identity_file="${2-}"
            shift
            ;;
        -2)
            two_pages_to_one=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        -?*) die "Unknown option: $1" ;;
        *) break ;;
    esac
    #shift
done

if [ -n "${dry_run-}" ]; then
    eval_or_echo_in_dry_run='printf %b\n'
else
    eval_or_echo_in_dry_run='eval'
fi

if [ "${command}" = 'h' ] || [ "${command}" = 'help' ]; then
    usage
    exit 0
fi

check_username() {
    [ -z "${1-}" ] && die "Missing required argument: <username>"
    username="${1-}"
    sshcmd="${username-}@${host}"
    # Use the ssh identity_file if provided
    [ -n "${identity_file}" ] && sshcmd="${sshcmd} -i ${identity_file}"
    return 0
}

check_printqueue() {
    [ -z "${2-}" ] && die "Missing required argument: <printqueue>"
    printqueue="${2-}"
    [ "$(printf "%s" "$printqueue" | head -c1)" != 'p' ] && die "Error: <printqueue> should start with 'p', e.g. psc008-dx. See PRINTQUEUES in help."
    return 0
}

case "${command-}" in
    p | print)
        check_username "$@"
        check_printqueue "$@"

        filepath="${3-}"
        if [ -z "${filepath-}" ] || [ "${filepath-}" = '-' ]; then
            filepath='/dev/stdin'
        else
            [ ! -f "${filepath-}" ] && die "Error: No such file"
            # Warn if filetype is unexpected
            file "${filepath}" | cut -f 2 -d ':' | grep -Eqv '(PDF|text)' && msg "Warning: File is not PDF or text. Print behaviour is undefined."
        fi

  # Generate random 8 character alphanumeric string in a POSIX compliant way
  tempname=$( awk 'BEGIN{srand();for(i=0;i<8;i++){r=int(61*rand());printf("%c",r<10?48+r:r<35?55+r:62+r)}}' )
  tempname="SOCPrint_${tempname}"

  if [ -n "${two_pages_to_one-}" ]; then
      tempname2="${tempname}2"
      tempname3="${tempname}3"
      options="pdf2ps ${tempname} ${tempname2}; multips ${tempname2} > ${tempname3}; mv -f ${tempname3} ${tempname}; rm ${tempname2};"
  else
      options=""
  fi

  cmd=$( cat <<EOF
  ssh $sshcmd "
    cat - > ${tempname};
    $options
    lpr -P ${printqueue} ${tempname};
    lpq -P ${printqueue};
    rm ${tempname};" < "${filepath}";
    star_banner
EOF
)
;;
j | jobs)
    check_username "$@"
    check_printqueue "$@"

    cmd=$( cat <<EOF
  ssh $sshcmd "lpq -P ${printqueue};"
EOF
)
;;
l | list)
    check_username "$@"

    cmd=$( cat <<EOF
  ssh $sshcmd "cat /etc/printcap | grep '^p' | sed 's/^\([^:]*\).*$/\1/'"
EOF
)
;;
q | quota)
    check_username "$@"

    # -t is needed because pusage works with interactive ssh and not without. 
    # Using -t emulates an interaction session. 'man ssh' for details
    cmd=$( cat <<EOF
  ssh $sshcmd -t "/usr/local/bin/pusage"
EOF
)
;;
esac

[ -z "${cmd-}" ] && die "Error: unknown command: ${command-}"
msg "Using ${username-}@${host} ..."
$eval_or_echo_in_dry_run "$cmd"

# Only check update if downloaded to local bin and we're not dry-running, as
# this could potentially mess tests up.
[ -f "/usr/local/bin/socprint.sh" ] && [ -z "${dry_run-}" ] && check_updates

exit 0

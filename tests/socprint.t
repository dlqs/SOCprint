Perform setup
  $ cp $TESTDIR/../socprint.sh $TMPDIR

Check that list printer command is correct
  $ $TMPDIR/socprint.sh list --dry-run test_user
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg "cat /etc/printcap | grep '^p' | sed 's/^\\([^:]*\\).*$/\x01/'" (esc)

Check that bad files print warnings and errors
  $ touch $TMPDIR/incorrect_format
  $ $TMPDIR/socprint.sh print --dry-run test_user psc008-dx $TMPDIR/incorrect_format
  Warning: File is not PDF or text. Print behaviour is undefined.
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg "
      cat - > SOCPrint_*; (glob)
      
      lpr -P psc008-dx SOCPrint_*; (glob)
      lpq -P psc008-dx;
      rm SOCPrint_*;" < "*/incorrect_format"; (glob)
      star_banner

  $ touch $TMPDIR/acceptable_format.txt
  $ $TMPDIR/socprint.sh print --dry-run test_user psc008-dx $TMPDIR/acceptable_format.txt
  Warning: File is not PDF or text. Print behaviour is undefined.
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg "
      cat - > SOCPrint_*; (glob)
      
      lpr -P psc008-dx SOCPrint_*; (glob)
      lpq -P psc008-dx;
      rm SOCPrint_*;" < "*/acceptable_format.txt"; (glob)
      star_banner

  $ $TMPDIR/socprint.sh print --dry-run test_user psc008-dx $TMPDIR/non_existent_file.txt
  Error: No such file
  [1]

  $ $TMPDIR/socprint.sh print --dry-run test_user psc008-dx
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg "
      cat - > SOCPrint_*; (glob)
      
      lpr -P psc008-dx SOCPrint_*; (glob)
      lpq -P psc008-dx;
      rm SOCPrint_*;" < "/dev/stdin"; (glob)
      star_banner

Check printer selection works
  $ $TMPDIR/socprint.sh print --dry-run test_user psc008-dx $TMPDIR/acceptable_format.txt 
  Warning: File is not PDF or text. Print behaviour is undefined.
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg "
      cat - > SOCPrint_*; (glob)
      
      lpr -P psc008-dx SOCPrint_*; (glob)
      lpq -P psc008-dx;
      rm SOCPrint_*;" < "*/acceptable_format.txt"; (glob)
      star_banner

  $ $TMPDIR/socprint.sh print --dry-run test_user $TMPDIR/acceptable_format.txt
  Error: <printqueue> should start with 'p', e.g. psc008-dx. See PRINTQUEUES in help.
  [1]

Check quota works
  $ $TMPDIR/socprint.sh quota --dry-run test_user
  Using test_user@sunfire.comp.nus.edu.sg ...
    ssh test_user@sunfire.comp.nus.edu.sg -t "/usr/local/bin/pusage"


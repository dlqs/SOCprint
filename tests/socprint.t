Perform setup
  $ cp $TESTDIR/../socprint.sh $TMPDIR

Check that list printer command is correct
  $ $TMPDIR/socprint.sh -u test_user -l --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  ssh test_user@sunfire.comp.nus.edu.sg "cat /etc/printcap | grep '^p' | sed 's/^\([^:]*\).*$/\1/'"

Check that bad files print warnings and errors
  $ touch $TMPDIR/incorrect_format
  $ $TMPDIR/socprint.sh -u test_user -f $TMPDIR/incorrect_format -p psc008-dx --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Warning: File is not PDF or text. Print behaviour is undefined.
  ssh test_user@sunfire.comp.nus.edu.sg " cat - > SOCPrint_*; lpr -P psc008-dx SOCPrint_*; lpq -P psc008-dx; rm SOCPrint_*;" < */incorrect_format (glob)

  $ touch $TMPDIR/acceptable_format.txt
  $ $TMPDIR/socprint.sh -u test_user -f $TMPDIR/acceptable_format.txt -p psc008-dx --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Warning: File is not PDF or text. Print behaviour is undefined.
  ssh test_user@sunfire.comp.nus.edu.sg " cat - > SOCPrint_*; lpr -P psc008-dx SOCPrint_*; lpq -P psc008-dx; rm SOCPrint_*;" < */acceptable_format.txt (glob)

  $ $TMPDIR/socprint.sh -u test_user -f $TMPDIR/non_existent_file.txt -p psc008-dx --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Error: No such file
  [1]

  $ $TMPDIR/socprint.sh -u test_user -p psc008-dx --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Missing required parameter: -f/--filename
  [1]

Check printer selection works
  $ $TMPDIR/socprint.sh -u test_user -f $TMPDIR/acceptable_format.txt --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Warning: File is not PDF or text. Print behaviour is undefined.
  Using default printqueue: psc008-dx
  Hint: To set a different one, use the -p option. To list all, use the -l option.
  ssh test_user@sunfire.comp.nus.edu.sg " cat - > SOCPrint_*; lpr -P psc008-dx SOCPrint_*; lpq -P psc008-dx; rm SOCPrint_*;" < */acceptable_format.txt (glob)

  $ $TMPDIR/socprint.sh -u test_user -f $TMPDIR/acceptable_format.txt -p psc011-nb --dry-run
  Using test_user@sunfire.comp.nus.edu.sg ...
  Warning: File is not PDF or text. Print behaviour is undefined.
  ssh test_user@sunfire.comp.nus.edu.sg " cat - > SOCPrint_*; lpr -P psc011-nb SOCPrint_*; lpq -P psc011-nb; rm SOCPrint_*;" < */acceptable_format.txt (glob)

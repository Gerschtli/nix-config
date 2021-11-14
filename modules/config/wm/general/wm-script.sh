if zenity --question --text="Are you sure you want to @message@?" 2> /dev/null; then
    @systemctlCommand@ @command@
fi

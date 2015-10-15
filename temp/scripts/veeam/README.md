INTRODUCTION

This script can create hard links of Veeam backup files from the last calendar month from the time it is run.  It can also delete these hard links from the tape backup directory.  This can then be used in conjunction with a tape backup utility to backup an entire month's Veeam backups to tape.

The script consists of three files.

run-veeam-backup-lastmonth.cmd: Runs PowerShell and executes veeam-backup-lastmonth.ps1 with the backup parameter.  This create hard links of each backup file created in the last calendar month from when the script is run.

run-veeam-cleanup-backups.cmd: Runs PowerShell and executes veeam-backup-lastmonth.ps1 with the cleanup parameter.  This will delete all hard links from the tapeout directory.

veeam-backup-lastmonth.ps1: The PowerShell script which is executed by the previous two .cmd files.


REQUIREMENTS

* The script is written and tested for PowerShell version 2.

* PowerShell execution policy needs to be set to "remotesigned" to allow the script to execute.  To do this, start a PowerShell session as the Administrator user.  Type the following line and press enter, then answer "Y" to the prompt to confirm:

Set-ExecutionPolicy remotesigned


INSTALLATION
* Copy the three files (run-veeam-backup-lastmonth.cmd, run-veeam-cleanup-backups.cmd and veeam-backup-lastmonth.ps1) to a directory from which you want to run them.

* Edit veeam-backup-lastmonth.ps1 and set the variables under the "--- Set variables below ---" line.  These are explained below.

$backupDir: The directory which contains the Veeam backup files.
$tapeOutDir: The directory which should be backed up to tape.  The files in this directory will be created and deleted by the script.
$logfile: The output log of this script.  This is for information and debugging purposes.
$emailFrom: The email address which the script will send emails from.
$emailTo: The email addresses, separated by commas (,), which will receive email reports by this script.
$subject: The subject line of the emails.
$smtpServer: The SMTP server which the script will use to send emails.

Once these are all set you can execute each of the .cmd scripts to test the functionality.  These two scripts can then be used by the tape backup utility or added to a scheduled task.

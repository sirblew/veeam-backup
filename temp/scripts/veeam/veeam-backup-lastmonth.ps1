# Powershell script to symlink all Veeam backup files in the last month to a temporary directory
# Brendan Lewis 14/09/2011
#
# --- Set variables below ---

# The directory which contains the Veeam backup files
$backupDir = "d:\veeam\BEarena"
# The directory which should be backed up to tape
$tapeOutDir = "d:\Veeam\TapeOut\BEarena"
# The output log of this script
$logfile = "d:\Veeam\veeam-backup-lastmonth.log"
# The email address which the script will send emails from
$emailFrom = "brendan.lewis@bearena.com.au"
# The email addresses, separated by commas (,), which will receive email reports by this script
$emailTo = "brendan.lewis@bearena.com.au,darren.ashley@bearena.com.au"
# The subject line of the emails
$subject = "Veeam backup script"
# The SMTP server which the script will use to send emails
$smtpServer = "mail.bearena.com.au"

# --- End set variables

clear-host
$now = get-date
$global:emailBody=""
# Create the WriteLog function
Function WriteLog ([string]$Entry) {
   Write-Host $Entry
   If ($logfile -ne $null) {Out-File $logfile -append -InputObject $Entry;} ;
   $Entry += "`n"
   $global:emailBody += $Entry
}
WriteLog ("Script started at " + $now + " with arguments: " + $args + "`n")

Set-Location $backupDir
if (-not (Test-Path $tapeOutDir)) {
	WriteLog "Error: $tapeOutDir does not exist! Creating $tapeOutDir"
	mkdir $tapeOutDir
}

$today = (Get-Date).dayofweek
$dayOfMonth = (get-date).day
# Backups must only run on the first monday of the month
if($today -ne "Monday" -xor $dayOfMonth -gt "30") {
	exit
}

Function doCleanup () {
    get-childitem -Path $tapeOutDir\*.v?? | foreach-Object { $fileName = $_.Name ; remove-Item -Force $tapeOutDir\$fileName ; $deleteList += ($tapeOutDir + "\" + $fileName + "`n") }
    writeLog "Deleting tape backup files..."
    writeLog $deleteList
}

Function doBackup () {
    # Set start and end dates
    $endOfLastMonth = (get-date).adddays(-$dayOfMonth)
    $endDateDay = $endOfLastMonth.day
    $lastMonth = $endOfLastMonth.month
    $year = $endOfLastMonth.year
    $startDate = "01/$lastMonth/$year"
    $endDate = "$endDateDay/$lastMonth/$year"

    # --- For testing
    #$startDate = "01/9/2011"
    #$endDate = "30/9/2011"
    # --- End testing

    doCleanup
    WriteLog ("Searching for backup files from $startDate to $endDate")
    get-childitem -Path $backupDir -filter *.v?? |
	   where {$_.CreationTime -gt
    	[datetime]::parse($startdate) -and
	    $_.CreationTime -lt [datetime]::parse($enddate)
    	} | foreach-object { $fileName = $_.Name ; $mklinkOut = (cmd /c mklink /h $tapeOutDir\$_ $backupDir\$fileName | out-String) ; WriteLog $mklinkOut }
    WriteLog ("Listing contents of $tapeOutDir below:")
    WriteLog (get-childitem -Path $tapeOutDir | out-string)
    $now = get-date
    WriteLog ("Finished at " + $now)
}

# Process parameters
#Write-Host "Num Args:" $args.Length;
if ($args -eq "backup") {
    doBackup
}
elseif ($args -eq "cleanup") {
    doCleanup
}
else {
    write-Host "Usage: veeam-backup-lastmonth.ps1 [backup|cleanup]"
    exit
}

# Email output
Send-MailMessage -To $emailTo -Subject $subject -From $emailFrom -Body $global:emailBody -smtpServer $smtpServer
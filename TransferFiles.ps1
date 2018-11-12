# Template for specifying sources and destinations for file transferring
# start a transcript
Start-Transcript -Path "C:\automation\logs\MoveFilesTranscript$(get-date -f MMddyyy).log" -Append -Verbose

# set the credit card name
# yesterday's date
$Yesterday = (Get-Date).AddDays(-1).ToString('MM/dd/yyyy')
$Today = Get-Date -Format MM/dd/yyyy
$CreditCardFileName = "*-333.pdf"


#Location to get files from and to, for moving them
$SourceAndTargetDirectories = @{}
# for copying them
$CopySourceAndTargetDirectories = @{}
# for copying them by creation date
$CopyByCreateDateSourceAndTargetDirectories = @{}
$CopyByCreateDateFromDate = @{}
$CopyByCreateDateToDate = @{}

# files to move
# setup as dictionaries. the key is the source and the value is the desitionation
$SourceAndTargetDirectories["\\PathToSource\file.txt"] = "D:\PathToDestination"
$SourceAndTargetDirectories["\\PathToSource\files\*"] = "D:\PathToDestination"
$SourceAndTargetDirectories["\\PathToSource\files\*"] = "D:\PathToDestination"
$SourceAndTargetDirectories["\\PathToSource\files\*"] = "C:\PathToDestination"

# files to copy by create date instead of move
# getting credit card statements created yesterday only
$CopyByCreateDateSourceAndTargetDirectories["\\PathToSource\$CreditCardFileName"] = "D:\PathToDestination"
$CopyByCreateDateFromDate["\\PathToSource\$CreditCardFileName"] = "$Yesterday"
$CopyByCreateDateToDate["\\PathToSource\$CreditCardFileName"] = "$Today"

#Log File
$Logging = "C:\automation\logs\MoveFiles$(get-date -f MMddyyy).log"


# go through the locations, moving the files
foreach ($SourceDirectory in $SourceAndTargetDirectories.Keys) {
	try {
		Move-Item -Path $SourceDirectory -Destination $SourceAndTargetDirectories[$SourceDirectory] -Force -ErrorAction "Stop" -Verbose
	}
	# if there are errors then log them
	catch {
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.GetType().FullName)" | Add-content $Logging
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.Message)" | Add-content $Logging
	}
}

# go through the locations, copying the files
foreach ($SourceDirectory in $CopySourceAndTargetDirectories.Keys) {
	try {
		Copy-Item -Path $SourceDirectory -Destination $CopySourceAndTargetDirectories[$SourceDirectory] -Force -ErrorAction "Stop" -Verbose
	}
	# if there are errors then log them
	catch {
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.GetType().FullName)" | Add-content $Logging
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.Message)" | Add-content $Logging
	}
}

# go through the locations, copying the files created between certain dates
foreach ($SourceDirectory in $CopyByCreateDateSourceAndTargetDirectories.Keys) {
	try {
		Get-ChildItem -Path $SourceDirectory | Where-Object {$_.CreationTime -ge $CopyByCreateDateFromDate[$SourceDirectory] -and $_.CreationTime -le $CopyByCreateDateToDate[$SourceDirectory] } | Copy-Item -Destination $CopyByCreateDateSourceAndTargetDirectories[$SourceDirectory] -Force -ErrorAction "Stop" -Verbose
	}
	# if there are errors then log them
	catch {
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.GetType().FullName)" | Add-content $Logging
		"$(get-date -format T): Error For: $SourceDirectory :Error type: $($_.Exception.Message)" | Add-content $Logging
	}
}

Stop-Transcript
Param(
	[parameter(Mandatory=$true)]
	[String]
	$ComputerName
)

$MemberList = @()

try {
	$WMIClassMembers = Get-WmiObject -class win32_groupuser -ComputerName $ComputerName -ErrorAction Stop
}
catch {
	Write-Warning -Message "Problem encountered with access to WMI on $ComputerName"
	Write-Warning -Message "$($_.Exception.Message)"
}

foreach ($Member in $WMIClassMembers) {
	$MemberName = ($Member.PartComponent).split(',')[1]
	$MemberName = ($MemberName).split('=')[1]
	$MemberName = ($MemberName).Trim('"')

	$LocalGroupName = ($Member.GroupComponent).split(',')[1]
	$LocalGroupName = ($LocalGroupName).split('=')[1]
	$LocalGroupName = ($LocalGroupName).Trim('"')

	$MemberList += $member | Select-Object (
		@{ Label="Computer"; Expression={$_.PSComputerName} },
		@{ Label="LocalGroupName"; Expression={$LocalGroupName} },
		@{ Label="MemberName"; Expression={$MemberName} }
	)

}

$MemberList
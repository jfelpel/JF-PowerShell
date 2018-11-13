<#

.Example
Get-ComputerLocalGroupMembers -ComputerName computername
This will get all members of all local groups from the specified computer

.Example
Get-ADComputer -Filter {name -like '*name*'} | select -ExpandProperty name | sort name | % {Get-ComputerLocalGroupMembers -ComputerName $_} | Export-Csv export.csv
This will get a list of computers from AD that match the filter, Select the "name" property from the results, sort the names, then run "Get-ComputerLocalGroupMembers"
against each result. Then finally dump the whole output to a csv. 

#>
function Get-ComputerLocalGroupMembers {
	[CmdletBinding()]
	param (
		[parameter(Mandatory=$true)]
		[String]
		$ComputerName
	)
	
	$ListofGroupsandMembers = @()

	#attempt to query WMI on remote server
	try {
		$WMIClassMembers = Get-WmiObject -class win32_groupuser -ComputerName $ComputerName -ErrorAction Stop
	}
	catch {
		Write-Warning -Message "Problem encountered with access to WMI on $ComputerName"
		Write-Warning -Message "$($_.Exception.Message)"
	}

	#Itereate through the WMI results and parse out groups and group members
	foreach ($Member in $WMIClassMembers) {
		$MemberName = ($Member.PartComponent).split(',')[1]
		$MemberName = ($MemberName).split('=')[1]
		$MemberName = ($MemberName).Trim('"')

		$LocalGroupName = ($Member.GroupComponent).split(',')[1]
		$LocalGroupName = ($LocalGroupName).split('=')[1]
		$LocalGroupName = ($LocalGroupName).Trim('"')

		$ListofGroupsandMembers += $member | Select-Object (
			@{ Label="Computer"; Expression={$_.PSComputerName} },
			@{ Label="LocalGroupName"; Expression={$LocalGroupName} },
			@{ Label="MemberName"; Expression={$MemberName} }
		)

	}

	#print the list of groups and group members
	$ListofGroupsandMembers
}

# Get-ComputerLocalGroupMembers
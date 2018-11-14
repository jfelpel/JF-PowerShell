function Get-ComputerLocalGroupMembers {
	<#
	
	.Synopsis
	Get a list of all local group members from the specified computer.
	
	.Description
	The Get-ComputerLocalGroupMembers function is used to retreive a list of local group members from a specified computer.
	One return entry will result for each member of each group. Meaning, if a user is a member of three groups, three entries will be returned.

	Also, for this function to be able to gather WMI data from the remote computer, the host running the script will need to have admin privledges to that remote computer.
	
	.NOTES
	Written by Jeremy Felpel
	GitHub: jfelpel
	
	.LINK
	https://github.com/jfelpel/JF-PowerShell01
	
	.Example
	Get-ComputerLocalGroupMembers -ComputerName computername
	This will get all members of all local groups from the specified computer
	
	.Example
	Get-ADComputer -Filter {name -like '*name*'} | select -ExpandProperty name | sort name | % {Get-ComputerLocalGroupMembers -ComputerName $_} | Export-Csv export.csv
	This will get a list of computers from AD that match the filter, Select the "name" property from the results, sort the names, then run "Get-ComputerLocalGroupMembers"
	against each result. Then finally dump the whole output to a csv.

	#>

	# [CmdletBinding()]
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
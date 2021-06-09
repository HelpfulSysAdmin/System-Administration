    PARAM (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="MSI Database Filename",ValueFromPipeline=$true)]
        [Alias("Filename","Path","Database","Msi")]
        $msiDbName
    )
 
    # A quick check to see if the file exist
    if(!(Test-Path $msiDbName)){
        throw "Could not find " + $msiDbName
    }
     
    # Creating WI object and load MSI database
    $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    $WindowsInstallerDatabase = $WindowsInstaller.OpenDatabase($msiDbName,0)
     
    # Open the Property-view
    $WindowsInstallerDatabaseView = $WindowsInstallerDatabase.OpenView("SELECT * FROM Property")
    $WindowsInstallerDatabaseView.Execute()
     
	Remove-Variable Results -ErrorAction SilentlyContinue
    $Results = @()
	
	# Loop through the table
    $WindowsInstallerDatabaseRow = $WindowsInstallerDatabaseView.Fetch()
    while($WindowsInstallerDatabaseRow -ne $null) {
        # Add property and value to hash table
		$name = $WindowsInstallerDatabaseRow.StringData(1)
		$value = $WindowsInstallerDatabaseRow.StringData(2)
		$Results += New-Object -TypeName PSObject -Property @{Name=$name;Value=$value}

		# Fetch the next row
	    $WindowsInstallerDatabaseRow = $WindowsInstallerDatabaseView.Fetch()
    }

 	$WindowsInstallerDatabaseView.Close()
     
    # Return the hash table
    $Results | Select Name, Value | ft -AutoSize
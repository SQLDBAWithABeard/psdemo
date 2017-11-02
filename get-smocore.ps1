# Register NuGet package source, if needed
# The package source may not be available on some systems (e.g. Linux)
if (-not (Get-PackageSource | Where-Object ( $_.Name -eq 'NuGet' ))) {
   Register-PackageSource -Name Nuget -ProviderName NuGet -Location https://www.nuget.org/api/v2
}

# Check that the NuGet feed is available and has the SMO package
# Output should look like this:
#    Name                           Version          Source           Summary
#    ----                           -------          ------           -------
#    Microsoft.SqlServer.SqlMana... 140.17199.0      Nuget            All libraries included as part of the SQL Server Ma...
Find-Package -Name Microsoft.SqlServer.SqlManagementObjects

# Install latest SMO package from NuGet
Install-Package -Name Microsoft.sqlserver.SqlManagementObjects -Scope CurrentUser -Force

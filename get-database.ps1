# # Register NuGet package source, if needed
# # The package source may not be available on some systems (e.g. Linux)
# if (-not (Get-PackageSource | Where-Object ( $_.Name -eq 'NuGet' ))) {
#    Register-PackageSource -Name Nuget -ProviderName NuGet -Location https://www.nuget.org/api/v2
# }

# # Check that the NuGet feed is available and has the SMO package
# # Output should look like this:
# #    Name                           Version          Source           Summary
# #    ----                           -------          ------           -------
# #    Microsoft.SqlServer.SqlMana... 140.17199.0      Nuget            All libraries included as part of the SQL Server Ma...
# Find-Package -Name Microsoft.SqlServer.SqlManagementObjects

# # Install latest SMO package from NuGet
# Install-Package -Name Microsoft.sqlserver.SqlManagementObjects -Scope CurrentUser

# Build path to misc assemblies (SMO, SqlClient, ...)
$smopath       = Join-Path ((Get-Package Microsoft.SqlServer.SqlManagementObjects).Source  | Split-Path) (Join-Path lib netcoreapp2.0)
$sqlclientpath = Join-Path ((Get-Package System.Data.SqlClient).Source  | Split-Path) (Join-Path lib netstandard2.0)

# Add types...
Add-Type -Path (Join-Path $sqlclientpath System.Data.SqlClient.dll)
Add-Type -Path (Join-Path $smopath       Microsoft.SqlServer.Smo.dll)
Add-Type -Path (Join-Path $smopath       Microsoft.SqlServer.ConnectionInfo.dll)
#if ($PSEdition -eq "Core") { Add-Type -Path "$PSHOME\System.Data.dll" } else { Add-Type -AssemblyName "System.Data" }

#
# Don't show this! :)
# CAVEAT!! Due to lack of support for things like 
#    System.Data.SqlClient.SqlCredential                    (in System.Data.dll, https://github.com/dotnet/corefx/issues/11542)
#    Microsoft.SqlServer.Management.Common.ServerConnection (the overload that takes a SecureString)
# we have to use clear-text user/password. DO NOT DO IN PRODUCTION CODE!
#
$connStr = "Data Source=localhost;Persist Security Info=True;User ID=sa;Password=SqlDevOps2017"

# See comment above. This could be a lot simpler and more secure...
$sqlconn = New-Object System.Data.SqlClient.SqlConnection $connStr
$conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection $sqlconn
$server = New-Object Microsoft.SqlServer.Management.Smo.Server $conn

# Print the Host Plaform (Linux or Windows)
Write-Host "Your SQL Server is running on: $($server.HostPlatform)"

# Show the databases on the server and some info about them. Output would look like this:
#
# There are 4 databases on the server.
#
# Name   Status  Size CompatibilityLevel Owner
# ----   ------  ---- ------------------ -----
# master Normal 7,375         Version140 sa
# model  Normal    16         Version140 sa
# msdb   Normal 21,25         Version140 sa
# tempdb Normal    16         Version140 sa

Write-Host "There are $($server.Databases.Count) databases on the server."
Write-Host ""
$server.Databases | select Name, Status, Size, CompatibilityLevel, Owner | Format-Table -AutoSize

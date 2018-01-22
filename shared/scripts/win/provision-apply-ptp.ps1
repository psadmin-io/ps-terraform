#Requires -Version 5

<#PSScriptInfo

    .VERSION 1.0

    .GUID cad7db76-01e8-4abd-bdb9-3fca50cadbc7

    .AUTHOR psadmin.io

    .SYNOPSIS
        ps-vagabond provisioning boot

    .DESCRIPTION
        Provisioning bootstrap script for ps-vagabond

    .PARAMETER PATCH_ID
        Patch ID for the PUM image

    .PARAMETER MOS_USERNAME
        My Oracle Support Username

    .PARAMETER MOS_PASSWORD
        My Oracle Support Password

    .PARAMETER DPK_INSTALL
        Directory to use for downloading the DPK files

    .EXAMPLE
        provision-boot.ps1 -PATCH_ID 23711856 -MOS_USERNAME user@example.com -MOS_PASSWORD mymospassword -DPK_INSTALL C:/peoplesoft/dpk/fn92u020

#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [String]$PATCH_ID     = $env:PATCH_ID,
  [String]$DPK_INSTALL  = $env:DPK_INSTALL,
  [String]$PTP_INSTALL  = $env:PTP_INSTALL,
  [String]$PUPPET_HOME  = $env:PUPPET_HOME,
  [String]$CA_PATH      = $env:CA_PATH,
  [String]$DPK_ROLE     = $env:DPK_ROLE,
  [string]$database     = 'true',
  [string]$puppet       = 'true'
)

#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Variables]----------------------------------------------------------

$DEBUG = "true"
$computername = $env:computername

function determine_tools_version() {
  $TOOLS_VERSION = $(Get-Content ${DPK_INSTALL}/setup/bs-manifest | select-string "version" | % {$_.line.split("=")[1]})
  $TOOLS_MAJOR_VERSION = $TOOLS_VERSION.split(".")[0]
  $TOOLS_MINOR_VERSION = $TOOLS_VERSION.split(".")[1]
  $TOOLS_PATCH_VERSION = $TOOLS_VERSION.split(".")[2]

  if ($DEBUG -eq "true") {
      Write-Host "Tools Version: ${TOOLS_VERSION}"
      Write-Host "Tools Major Version: ${TOOLS_MAJOR_VERSION}"
      Write-Host "Tools Minor Version: ${TOOLS_MINOR_VERSION}"
      Write-Host "Tools Patch Version: ${TOOLS_PATCH_VERSION}"
  }
}

function determine_puppet_home() {
  switch ($TOOLS_MINOR_VERSION) {
      "55" { 
          $PUPPET_HOME = "C:\ProgramData\PuppetLabs\puppet\etc"
       }
       "56" {
          $PUPPET_HOME = "${PSFT_BASE_DIR}/dpk/puppet"
          Write-Host "PeopleTools Patching for 8.56 is not supported yet."
          exit
       }
      Default { Write-Host "PeopleTools version could not be determined in the bs-manifest file."}
  }  

  if ($DEBUG -eq "true" ) {
      Write-Host "Puppet Home Directory: ${PUPPET_HOME}"
  }
}

Function create-ca-ini
{
  $base           = hiera peoplesoft_base | Resolve-Path
  $db_name        = hiera db_name
  $access_id      = hiera access_id
  $access_pwd     = hiera access_pwd
  $db_user        = hiera db_user
  $db_user_pwd    = hiera db_user_pwd
  $db_connect_id  = hiera db_connect_id
  $db_connect_pwd = hiera db_connect_pwd
  $sqlplus_location = hiera oracle_client_location | Resolve-Path
  $ps_home_location = hiera ps_home_location | Resolve-Path

  $file = New-Item -type file "${base}\ca.ini" -force
  $template=@"
[GENERAL]
MODE=UM
ACTION=ENVCREATE
OUT=${base}\ca\ca.log
EXONERR=Y

[ENVCREATE]
TGTENV=${db_name}
CT=2
UNI=Y
CA=${access_id}
CAP=${access_pwd}
CO=${db_user}
CP=${db_user_pwd}
CI=${db_connect_id}
CW=${db_connect_pwd}
CZYN=N
SQH=${sqlplus_location}\BIN\sqlplus.exe
INP=All
PL=PEOPLETOOLS
IND=ALL
INL=All
INBL=ENG
PSH=${ps_home_location}
PAH=${ps_home_location}
PCH=${ps_home_location}
REPLACE=N
"@ 
  if ($DEBUG -eq "true") {
    Write-Host "This is the template: ${template}"
    Write-Host "Writing to location: ${file}"
  }
  $template | out-file $file -Encoding ascii
}

function create_ca_environment() {
  $base = hiera peoplesoft_base
  $jdk = hiera jdk_location | Resolve-Path
  Write-Host "[${computername}][Task] Configure Change Assistant"
  if (-Not (test-path "${base}\ca")) {
    Write-Host "`tBuild CA output/stage folders"
    mkdir $base\ca
    mkdir $base\ca\output
    mkdir $base\ca\stage
  }

  Write-Host "`tSet permissions on the ps_home folder for the Administrators group"
  icacls "${ps_home_location}" /grant "Administrators:(OI)(CI)(M)" /T /C

  Set-Location $CA_PATH
  $env:JAVA_HOME="${jdk}"
  (Get-Content "${CA_PATH}\changeassistant.bat").replace('jre\bin\java -Xms512m -Xmx1g com.peoplesoft.pt.changeassistant.client.main.frmMain %*', 'jre\bin\java -Xms256m -Xmx512m com.peoplesoft.pt.changeassistant.client.main.frmMain %*') | Set-Content "${CA_PATH}\changeassistant.bat"
  Write-Host "`tConfigure Change Assistant's General Options"
  # Configure CA
  & "${CA_PATH}\changeassistant.bat" -MODE UM `
      -ACTION OPTIONS `
      -OUT "${base}\ca\output\ca.log" `
      -REPLACE Y `
      -EXONERR Y `
      -SWP False `
      -MCP 5 `
      -PSH "${ps_home_location}" `
      -STG "${base}\ca\stage" `
      -OD "${base}\ca\output" `
      -DL "${ps_home_location}\PTP" `
      -SQH "${sqlplus_location}\BIN\sqlplus.exe" `
      -EMYN N 
  
  Write-Host "`tCreate an environment in Change Assistant"
  # Create CA Environment
  & "${CA_PATH}\changeassistant.bat" -INI "${base}\ca.ini"

  Write-Host "[${computername}][Done] Configure Change Assistant"
}

function patch_database (){
  # Apply PTP
  Write-Host "[${computername}][Task] Apply the PeopleTools Patch to the Database"
  # Get the new Patch version to apply
  $dpk_home = hiera dpk_location
  $PTP_VERSION = ((get-content "${dpk_home}\pt-manifest" | select-string "^version").ToString() -split "=")[1] -replace "\.", ""

  if ($DEBUG -eq "true") {
    & "C:\Program Files\PeopleSoft\Change Assistant\changeassistant.bat" -MODE UM `
    -ACTION PTPAPPLY `
    -TGTENV PSFTDB `
    -UPD "PTP${PTP_VERSION}"
  } else {
    & "C:\Program Files\PeopleSoft\Change Assistant\changeassistant.bat" -MODE UM `
    -ACTION PTPAPPLY `
    -TGTENV PSFTDB `
    -UPD "PTP${PTP_VERSION}" 2>&1 | out-null
  }
  Write-Host "[${computername}][Done] Apply the PeopleTools Patch to the Database"
}

function install_hiera_eyaml() {

  # Install Hiera-eyaml
  # -------------------
  Write-Host "[${computername}][Task] Install Hiera-eyaml"
  copy-item c:\vagrant\scripts\RubyGemsRootCA.pem "C:\Program Files\Puppet Labs\Puppet\sys\ruby\lib\ruby\2.0.0\rubygems\ssl_certs\" -force
  $env:PATH += ";C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin"
  gem install hiera-eyaml
  Write-Host "[${computername}][Done] Install Hiera-eyaml" -ForegroundColor green

  # Configure Hiera-eyaml
  # ---------------------
  Write-Host "[${computername}][Task] Configure Hiera-eyaml"
  # copy-item c:\vagrant\hiera.yaml C:\ProgramData\PuppetLabs\hiera\etc\hiera.yaml -force
  # copy-item c:\vagrant\eyaml.yaml C:\ProgramData\PuppetLabs\hiera\etc\eyaml.yaml -force
  [System.Environment]::SetEnvironmentVariable("EYAML_CONFIG", "C:\ProgramData\PuppetLabs\hiera\etc\eyaml.yaml", "Machine")
  if ( -not ( test-path C:\ProgramData\PuppetLabs\puppet\etc\secure\keys) ) { mkdir C:\ProgramData\PuppetLabs\puppet\etc\secure\keys }
  copy-item c:\vagrant\keys\* C:\ProgramData\PuppetLabs\puppet\etc\secure\keys\ -force
  # [System.Environment]::SetEnvironmentVariable("EDITOR", "C:\Program Files\Sublime Text 3\sublime_text.exe -n -w", "Machine")
  Write-Host "[${computername}][Done] Configure Hiera-eyaml" -ForegroundColor green

}

function deploy_patched_domains() {
  Write-Host "[${computername}][Task] Deploy patched domains"
  # (Get-Content "${PUPPET_HOME}\manifests\site.pp") -replace 'include.*', "include ::pt_role::pt_tools_midtier" | Set-Content "${PUPPET_HOME}\manifests\site.pp"
  if ($DEBUG -eq "true") {
    puppet apply "${PUPPET_HOME}\manifests\site.pp" --trace --debug
  } else {
    puppet apply "${PUPPET_HOME}\manifests\site.pp" 2>&1 | out-null 
  }
  Write-Host "[${computername}][Done] Deploy patched domains"
}

# . change_to_midtier
# . execute_dpk_cleanup
# . execute_psft_dpk_setup

. determine_tools_version
. determine_puppet_home

if ($database -eq 'true') {
  . create-ca-ini
  . create_ca_environment
  . patch_database
}
if ($puppet -eq 'true') {
  # . install_hiera_eyaml
  . deploy_patched_domains
}
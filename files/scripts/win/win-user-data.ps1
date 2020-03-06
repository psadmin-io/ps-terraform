_<powershell>
  # Update hosts file with new hostname
  # $ip = (iwr http://169.254.169.254/latest/meta-data/local-ipv4).content
  $hostname = "${hostname}"
  $hosts = "C:\Windows\System32\drivers\etc\hosts"

  # Remove old hostnames
  get-content -path $hosts | select-string $hostname -notmatch | out-file $hosts
  add-content -path $hosts -value "$${ip}`t`t$${hostname}`t`t$${hostname}.$${dns_label}"
  #add-content -path $hosts -value "$${ip}`t`t$${env:computername}`t`t$${env:computername}.$${{subnet_dns}.$${dns_suffix}"
  # add psterraform for Oracle Listener configuration # TODO
  add-content -path $hosts -value "$${ip}`t`tpsterraform`t`tpsterraform.$${dns_label}"

  # Disable windows firewall
  netsh advfirewall set allprofiles state off  

  # Set Administrator password
  $admin = [adsi]("WinNT://./${admin_user}, user") 
  $admin.psbase.invoke("SetPassword", "${admin_pass}")
  
  # Set NODENAME Env Var
  # [Environment]::SetEnvironmentVariable("NODENAME", $hostname)
  # [Environment]::SetEnvironmentVariable("NODENAME", $hostname, [System.EnvironmentVariableTarget]::Machine)

  # # Set Timezone
  # Set-TimeZone -Name "Central Standard Time"

  # TODO - winrm settings needed?
  winrm set winrm/config/service/Auth '@{Basic="true"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}' 

</powershell>
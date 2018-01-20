<powershell>
  winrm set winrm/config/service/Auth '@{Basic="true"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="6144"}'
  netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
  # Set Administrator password
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.psbase.invoke("SetPassword", "${admin_password}")
  netsh advfirewall set allprofiles state off
  C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule
  ($TaskScheduler = New-Object -ComObject Schedule.Service).Connect("localhost")
  $MyTask = $TaskScheduler.GetFolder('\').GetTask("Amazon Ec2 Launch - Instance Initialization")
  $MyTask.Enabled = $true
  Rename-Computer -NewName "${machine_name}"
  Restart-Computer
</powershell>
<###############################################################
.Description
   Both the OpenSSH client and server are available on Windows.

Requirements: 
   Windows 10 v1709, Server v1709, Server 2018, or later.

   Must use powershell.exe or pwsh.exe, not powershell_ise.exe.

   The 'NT Service\sshd' identity must be granted the privilege
   named 'Replace a token' (AssignPrimaryTokenPrivilege) if it
   is not granted automatically.

.Notes:
   Only the ED25519 key type is available until the LibreSSL 
   library is added at a later date.  

   Follow the OpenSSH project here:
   https://github.com/powershell/Win32-OpenSSH

################################################################>


# Confirm that OpenSSH is available to be enabled:
Get-WindowsCapability -Online | Where { $_.Name -like 'OpenSSH*' } 



#####################################
#   CLIENT CONFIGURATION
#####################################

# Install the OpenSSH client (edit the version number as needed): 
Add-WindowsCapability -Online -Name 'OpenSSH.Client~~~~0.0.1.0' 


# The PATH environment variable has a new folder:
$env:Path -split ';' | Where { $_ -match 'OpenSSH' } 


# OpenSSH utilities are now available in the PATH:
Get-Command -Name ssh.exe
Get-Command -Name ssh-keygen.exe


# For password authentication, connect as Amy to Server47, where
# Amy is a local account, then run "exit" to disconnect:
ssh.exe amy@server47.testing.local


# For password authentication, connect as Amy to Server47, where
# Amy is a global account in the testing.local domain:
ssh.exe amy@testing.local@server47.testing.local
ssh.exe testing\amy@server47.testing.local


# For password authentication, connect as yourself to Server47:
ssh.exe server47.testing.local


# For key-based authentication, first generate a new key pair
# and follow the prompts; press Enter to accept the defaults,
# or enter a passphrase to encrypt the private key:
ssh-keygen.exe


# Your public and private key pairs are stored here by default:
dir $env:USERPROFILE\.ssh


# If desired, your private key can be protected by
# the ssh-agent service to make authentication easier:
Start-Service -Name ssh-agent
ssh-add.exe $env:USERPROFILE\.ssh\id_ed25519



#####################################
#   SERVER CONFIGURATION
#####################################

# Install the OpenSSH server (edit the version number as needed): 
Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' 


# Start the ssh-agent service:
Start-Service -Name ssh-agent


# Switch into the OpenSSH installation folder:
cd $env:WinDir\System32\OpenSSH


# Generate an OpenSSH key pair to authenticate the host:
.\ssh-keygen.exe -A


# List the public and private host key files:
 dir ssh_host_*


# Add the host private key to the protection of the ssh-agent service:
.\ssh-add.exe ssh_host_ed25519_key


# Install the OpenSSHUtils PowerShell module:
Install-Module -Name OpenSSHUtils -Force


# If desired, review the functions from the OpenSSHUtils module:
Get-Command -Module OpenSSHUtils


# Use a function from the OpenSSHUtils module to alter the permissions 
# and owner of the host public and private keys:
Repair-SshdHostKeyPermission -FilePath $env:WinDir\System32\OpenSSH\ssh_host_ed25519_key -Confirm:$False


# Start the sshd service:
Start-Service -Name sshd 


# Optionally, add a firewall rule to allow inbound connections to the sshd service:
New-NetFirewallRule -Name 'OpenSSH' -DisplayName 'OpenSSH' -Service sshd -Enabled True -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Profile Any




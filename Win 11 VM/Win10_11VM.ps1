#################################################################
# Parameters
$WinVMName = "Test-Win11VM"

$PolicyScope = "Machine"

$IsoPath = "C:\Users\%USERPROFILE%\Downloads\Win11_English_x64.iso"

#################################################################
# Install/Enable various modules and features

# Installs RSAT tools to allow for GPO modifications later
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

# Install and import PolicyFileEditor
# https://www.powershellgallery.com/packages/PolicyFileEditor/3.0.1
If(-not(Get-InstalledModule PolicyFileEditor -ErrorAction silentlycontinue)){
    Install-Module PolicyFileEditor -Confirm:$False -Force
}

# Turns on the Hyper-V feature if not enabled
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V already enabled."
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Write-Host "Hyper-V enabled."
}

# Import the GPO Module (Requires RSAT first)
Import-Module grouppolicy

# Import PolicyFileEditor Module
Import-Module PolicyFileEditor

#################################################################
# Enable GPO needed for USB device use
# https://gerane.github.io/powershell/Local-gpo-powershell/
# Currently it is set to apply to the full machine policy, 
# but you can choose to just apply these settings to user policy.
# Just change what is commented out below

$MachinePolicy = "$env:windir\system32\GroupPolicy\Machine\registry.pol"
$UserPolicy = "$env:windir\system32\GroupPolicy\User\registry.pol"
$RegType = "DWord"

if($PolicyScope -eq "Machine"){
    # Set Machine Policies
    Set-PolicyFileEntry -Path $MachinePolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "fEnableRemoteFXAdvancedRemoteApp" -Data "1" -Type $RegType
    Set-PolicyFileEntry -Path $MachinePolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "fEnableVirtualizedGraphics" -Data "1" -Type $RegType
    Set-PolicyFileEntry -Path $MachinePolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" -ValueName "fUsbRedirectionEnableMode" -Data "2" -Type $RegType
    gpupdate /force
    Get-PolicyFileEntry -Path $machinepolicy -All
}elseif($PolicyScope -eq "User"){
    # Set User Policies
    Set-PolicyFileEntry -Path $UserPolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "fEnableRemoteFXAdvancedRemoteApp" -Data "1" -Type $RegType
    Set-PolicyFileEntry -Path $UserPolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "fEnableVirtualizedGraphics" -Data "1" -Type $RegType
    Set-PolicyFileEntry -Path $UserPolicy -Key "SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" -ValueName "fUsbRedirectionEnableMode" -Data "2" -Type $RegType
    gpupdate /force
    Get-PolicyFileEntry -Path $UserPolicy -All
}else{
    Write-Host "Policy scope not set. Policy has not been applied and USB devices may not work on VM."
}

#################################################################
# Start VM creation in Hyper-V

New-VM -Name $WinVMName -MemoryStartupBytes 8GB -BootDevice VHD -NewVHDPath .\VMs\Win11.vhdx -Path .\VMData -NewVHDSizeBytes 175GB -Generation 2
Set-VMProcessor -VMName $WinVMName -Count 2
Set-VMDvdDrive -VMName $WinVMName -ControllerNumber 1 -Path $IsoPath
Enable-VMIntegrationService * -VMName $WinVMName
Set-VMFirmware -VMName $WinVMName -EnableSecureBoot On -SecureBootTemplate MicrosoftWindows
Update-VMVersion -VMName $WinVMName -Force

# Everything needed to get TPM enabled
$owner = Get-HgsGuardian UntrustedGuardian
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
Set-VMKeyProtector -VMName $WinVMName -KeyProtector $kp.RawData
Enable-VMTPM -VMName $WinVMName
Set-VMSecurity -VMName $WinVMName -EncryptStateAndVmMigrationTraffic $true

# TODO: Verify if VM exists before trying this. No sense running it if the VM fails to build
VMConnect.exe localhost $WinVMName /edit

# View ReadMe for next steps
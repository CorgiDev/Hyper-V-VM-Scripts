#################################################################
# Parameters
#################################################################
$WinVMName = "Test-Win11VM"
# Scope used for GPO. Can be set to "Machine" or "User".
$PolicyScope = "Machine"
# Location where you saved your ISO file.
$IsoPath = "C:\Users\%USERPROFILE%\Downloads\Win11_English_x64.iso"
# Locatiion where your VHD will be saved
$vhdPath = "C:\VMs\Win11.vhdx"
# Variables used for log file
$currentTimeStamp = (Get-Date -Format �MM-dd-yyyy_hh-mm-ss�).ToString()
$logPath = "C:\VM_Creation_Logs\VMCreationLog_" + $currentTimeStamp + ".txt"

#################################################################
# Functions
#################################################################
function Confirm-VMExistence {
    param(
        [string]$Exists,
        [string]$VHDPath,
        [string]$VMName
    )

    if($Exists){
	    Write-Host "Windows 11 VM creation successful. Starting first run of VM."
        VMConnect.exe localhost $VMName /edit
    }
    else{
	    Write-Host "Windows 11 VM creation did not complete successfully. Performing cleanup."
        Dismount-CustomVM -Exists $Exists -VHDPath $VHDPath -VMName $VMName
    }
}

function Dismount-CustomVM{
    param(
        [string]$Exists,
        [string]$VHDPath,
        [string]$VMName
    )

    if($Exists){
        Write-Host "Failed VM found. Removing failed VM."
        Remove-VM -Name $VMName -Force
    }else{
        Write-Host "VM was not created successfully. Completing clean up."
    }

    if(Test-Path $VHDPath) {
        Write-Host "Failed VHD found. Performing cleanup."
        Remove-Item $VHDPath -Confirm
        Write-Host "Failed VHD removed. Try script again once errors have been resolved."
    }
    else
    {
        Write-Host "No fuirther cleanup necessary. Terminating script. Try again once errors resolved."
    }
}

#################################################################
# Ensure script run as Admin and relaunch if not
#################################################################
$CurrentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentIdentity)
 
if (-not ($CurrentPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
    $WaitTime = 5 
    Write-Warning "You do not have Administrator rights to run this script."
    Write-Warning "Launching a new powershell process as Administrator in $WaitTime seconds..." 
    Start-Sleep -Seconds $WaitTime 
    $Arguments = '-File "' + $PSCommandPath + '"' 
    Start-Process "powershell" -Verb RunAs -ArgumentList $Arguments 
    return
}

# Thsi is used for storing info related to the run in case you need it for troubleshooting and such.
Start-Transcript -path $logPath

#################################################################
# Install/Enable various modules and features
#################################################################
# Installs RSAT tools to allow for GPO modifications later
try{
    Write-Host "Installing RSAT tools from Microsoft."
    Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
}catch{
    Write-Host "Installation of RSAT tools failed. Exiting script."
    Stop-Transcript
}

# Install PolicyFileEditor Module
# https://www.powershellgallery.com/packages/PolicyFileEditor/
Write-Host "Installing the PolicyEditor Powershell Module from Powershell Gallery."
if(-not(Get-InstalledModule PolicyFileEditor -ErrorAction silentlycontinue)){
    Install-Module PolicyFileEditor -Confirm:$False -Force
}

# Turns on the Hyper-V feature if not enabled
Write-Host "Enabling Hyper-V feature in Windows."
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V already enabled."
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Write-Host "Hyper-V enabled."
}

Write-Host "Importing GroupPolicy and PolicyEditor Powershell modules."
try{
    # Import the GPO Module (Requires RSAT first)
    Import-Module grouppolicy
    # Import PolicyFileEditor Module
    Import-Module PolicyFileEditor
}catch{
    Write-Host "Module import failed. Exiting script."
    Stop-Transcript
}

#################################################################
# Enable GPO needed for USB device use
# https://gerane.github.io/powershell/Local-gpo-powershell/
# Currently it is set to apply to the full machine policy, 
# but you can choose to just apply these settings to user policy
# by changing the PolicyScope variable at the top of this script.
#################################################################
$MachinePolicy = "$env:windir\system32\GroupPolicy\Machine\registry.pol"
$UserPolicy = "$env:windir\system32\GroupPolicy\User\registry.pol"
$RegType = "DWord"

try{
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
        Write-Host "Policy scope not set properly. Policy has not been applied and USB devices may not work on VM. Terminating script."
        Stop-Transcript
        break
    }
}catch{
    Stop-Transcript
}

#################################################################
# Start VM creation in Hyper-V
#################################################################
# TODO: If any errors occur, the VM needs to be deleted still since it won't have been created correctly.
try{
    New-VM -Name $WinVMName -MemoryStartupBytes 8GB -BootDevice VHD -NewVHDPath $vhdPath -Path .\VMData -NewVHDSizeBytes 175GB -Generation 2 -Switch "Default Switch"
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

    $exists = Get-VM -VMName $WinVMName -ErrorAction SilentlyContinue
    Confirm-VMExistence -Exists $exists -VHDPath $vhdPath -VMName $WinVMName
}
catch{
    $exists = Get-VM -VMName $WinVMName -ErrorAction SilentlyContinue
    Write-Host "Windows 11 VM creation did not complete successfully. Performing cleanup."
    Dismount-CustomVM -Exists $exists -VHDPath $vhdPath -VMName $WinVMName
    Stop-Transcript
}

Stop-Transcript
#################################################################
# View ReadMe for next steps
#################################################################
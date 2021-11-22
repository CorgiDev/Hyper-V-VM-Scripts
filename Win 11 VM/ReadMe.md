# Windows 11 VM in Hyper-V

## Pre-requisites

The following are things you must have before you can create a VM in Hyper-V, particularly a Windows 11 VM.

- Your physical computer MUST support TPM.
  - This is required for Windows 11.
- Your physical computer MUST be running a Pro/Enterprise version of Windows. Home editions will not work.
- You MUST have a valid Windows 11 ISO.
  - [Download Windows 11 ISO](https://www.microsoft.com/software-download/windows11)
- You MUST have a valid Windows key to acttivate your Windows VM.

# How to Setup VM in Hyper-V

1. Make sure the Windows ISO is located in your Downloads folder. `"C:\Users\%USERPROFILE%\Downloads\`
2. Make sure the ISO file name matches what is in the `IsoPath` variable at the top of the script.
2. Run the `Win11VM.ps1` script as admin.
3. As long as it completes without errors, the window to start the VM should display.
4. Start the VM, and proceed with the insstall of Windows, you'll need to press a key to have it boot to the installation media.
5. DURING the install,
   1. If the Windows key being used it your own, initially login with your personal account so digital entitlement is assigned to you. 
   2. If it belongs to your work, use your work/school account to access work/school resources.
6. At "Connect to <WinVMName>" ddialog set to full screen and select "Use all my monitors if you wish / if applicable
7. Select the "Local Resources" tab.
8. Check the "Printers" and "Clipboard" options if not already checked.
9. Click the "More" button under "Local devices and resources" section.
10. Check all the options listed here, except under "Drives." You can check the drives that you actually want shared between the VM and the host machine. Click OK.
11. Click the "Settings" button under "Remote audio" section.
12. Select the "Play on the computer" and "Record from this computer" options. Click OK.
13. Click OK and then Connect.
14. If login screen does not display, turn off "Enhanced session" from the "View" menu for the VM window.
15. Go to "Settings" > "Accounts" > "Sign-in options"
16. Remove the Windows Hello Pin you had to setup during install.
17. Turn "Enhanced session" back on.
18. Turn on Bitlocker.
19. If using your personal account, go to "Settings" > "Accounts" > "Access work or schoool" and connect your work/school account.

## Issue: Running Scripts Disabled

If you get an error about not being able to run the script because running scripts is disabled on this system there is an easy fix for this. The error will look similar to the one shown below:

```
File C:\Users\evilt\Desktop\repos\Hyper-V-VM-Scripts\Win 11 VM\Win11VM.ps1 cannot be loaded because running scripts is disabled on 
this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
    + CategoryInfo          : SecurityError: (:) [], ParentContainsErrorRecordException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

The fix for that is to first run `Get-ExecutionPolicy -List`. This will show you what your script execution policy is currently set to. If running scripts is disabled, you should get results like those below.

```
PS C:\WINDOWS\system32> Get-ExecutionPolicy -List

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine      Restricted
```

If you do, run the command `Set-ExecutionPolicy Unrestricted -Force`, and then run the list command again to confirm it has changed. Your results should appear similar to those shown below:

```
PS C:\WINDOWS\system32> Set-ExecutionPolicy Unrestricted -Force
PS C:\WINDOWS\system32> Get-ExecutionPolicy –List

        Scope ExecutionPolicy
        ----- ---------------
MachinePolicy       Undefined
   UserPolicy       Undefined
      Process       Undefined
  CurrentUser       Undefined
 LocalMachine    Unrestricted
```

Now run the VM creation script again. Barring any other issues, the script should run successfully now.

## Issue: Unable to turn off Windows Hello on the VM

Occassionally, the option to remove Windows Hello will not be available to the user. In this case, you have one of 2 options:

1. You can leave Windows Hello enabled, but disable "Enhanced session" using the "View" drop-down menu of the VM window's menu bar. You cannot login and then enable it again because it will reload the window and take you back to the login screen which won't be visible due to the glitch in Windows 10/11 with Enhanced Session and Windows Hello.
2. Disable Windows Hello in the VM from Local GPO or the Registry.

### Disable Windows Hello from the Local GPO (Recommended)

1. Open the Group Policy Editor and navigate to `Computer Configuration > Administrative Templates > System > Logon
2. Double-click on Turn on convenience PIN sign-in
3. Click on Disabled to disable the prompt or Not Configured for the default setting.
4. Run `gpupdate /force` in a Command Prompt window and try to remove the Windows Hello pin again.
5. If you still are unable to remove the pin, make sure the option to "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device (Recommended)" is turned OFF.
6. Then go to the Pin option and select the "I forgot my pin" option. 
7. Proceed through the windows until you get to where you would set a new pin. At this stage, the stored pin has been removed.
8. Simply cancel out of the window without setting a new pin. You may get a message about one being required, but you can still exit out and the pin will be removed. 

Now you can use Windows with "Enhanced session" and just log in with your password. When you log in, you may still be prompted for a pin, but you can select "Sign-In options" and select to login with your Microsoft account password.

### Disable Windows Hello from the Registry (Less Recommended)

1. Open the Registry by running `regedit.exe` or finding it in the Start Menu.
2. Navigate to `Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions`
3. Double-click on `value` on the right pane.
4. Change the Value data to `0`. You would change the Value data back to `1` if you later wish to re-enable Windows Hello.
5. Reboot.
6. If you still are unable to remove the pin, make sure the option to "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device (Recommended)" is turned OFF.
7. Then go to the Pin option and select the "I forgot my pin" option. 
8. Proceed through the windows until you get to where you would set a new pin. At this stage, the stored pin has been removed.
9. Simply cancel out of the window without setting a new pin. You may get a message about one being required, but you can still exit out and the pin will be removed. 

Now you can use Windows with "Enhanced session" and just log in with your password. When you log in, you may still be prompted for a pin, but you can select "Sign-In options" and select to login with your Microsoft account password.

- Source: [MajorGeeks.com - How to Disable Windows Hello PIN in Windows 10 and 11](https://www.majorgeeks.com/content/page/disable_windows_hello.html)

## Additional Recommended Installs

Links in this section must be accessed from within the VM or they will download to your physical machine. Unless of course, you shared a drive with your VM.

### Ninite Installer

Ninite is a helpful installation program where you can select a variety of applications to install and it will go pull the newest version minus any adware and install it all for you without you having to do anything other than run the installer.

The following [Ninite link](https://ninite.com/cccp-filezilla-gimp-notepadplusplus-vlc-vscode-winrar-zoom/) will Install:
   - Notepad++
   - FileZilla
   - VS Code
   - CCCP (Combined Community Codec Pack)
   - VLC Player
   - WinRAR
   - Gimp (basically a free version of Photoshop)
   - Zoom

  You can also just visit the [Ninite homepage]((https://ninite.com/) to customize a Ninite installer to suit your needs.
  
## Microsoft Teams

Install Teams using the following url: https://www.microsoft.com/en-us/microsoft-teams/download-app
   1. A regular consumer version of Teams should be pre-installed in Windows 11.
   2. If you need to connect to a work or school account Teams, you will need to go to the url above and then select the download labeled "For work or school."

## Sources

These are some of the general sources I used for this:

- https://www.danielengberg.com/create-hyper-v-vm-powershell/
- https://4sysops.com/archives/install-windows-11-in-a-virtual-machine/
- https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v
- https://www.altaro.com/hyper-v/using-powershell-manage-utilize-hyper-v-integration-services-server-2012-r2/
- https://subscription.packtpub.com/book/virtualization-and-cloud/9781785884313/6/ch06lvl1sec57/vm-protection-vtpm (Requires a subscription to view)
- https://deploywindows.com/2015/11/13/add-virtual-tpm-in-windows-10-hyper-v-guest-with-powershell/
- https://www.reddit.com/r/HyperV/comments/d2u832/vtpm_operation_failed_when_performing_enablevmtpm/
- https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/tpm-key-attestation
- https://www.archy.net/hyper-v-2016-add-vmtpm-issue/

### Windows Features/Tools Related

These resources are more specifically related to Installing/Enabling RSAT.

- https://geekshangout.com/install-all-rsat-tools-via-powershell/
- https://mikefrobbins.com/2018/10/03/use-powershell-to-install-the-remote-server-administration-tools-rsat-on-windows-10-version-1809/
- https://www.itechguides.com/rsat-windows-10/#:~:text=RSAT%20will%20be%20listed.%20To%20confirm%20that%20this,command%20prompt%2C%20type%20this%20command.%20Then%20press%20enter

### Powershell Related

These resources are more specifically related to specific Powershell commands/modules.

- https://www.educba.com/powershell-exit/
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/get-vm?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmsecurity?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vm?view=windowsserver2019-ps
- https://stackoverflow.com/users/1928691/federico-navarrete
   - https://stackoverflow.com/a/51692402
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/enable-vmtpm?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/enable-vmintegrationservice?view=windowsserver2019-ps
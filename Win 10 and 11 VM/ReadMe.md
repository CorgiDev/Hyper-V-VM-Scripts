# Windows 10/11 VM in Hyper-V

## Pre-requisites

The following are things you must have before you can create a VM in Hyper-V, particularly a Windows 10 or 11 VM.

- Your physical computer MUST support TPM.
  - This is the case for Windows 11 at least. Windows 10 may work without.
- Your physical computer MUST be running a Pro/Enterprise version of Windows. Home editions will not work.
- You MUST have a valid Windows 10 or 11 ISO.
  - [Download Windows 10 ISO](https://www.microsoft.com/en-us/software-download/windows10)
  - [Download Windows 11 ISO](https://www.microsoft.com/software-download/windows11)
- You MUST have a valid Windows key to acttivate your Windows VM.

# How to Setup VM in Hyper-V

1. Make sure the Windows ISO is located in your Downloads folder. `"C:\Users\%USERPROFILE%\Downloads\`
2. Make sure the ISO file name matches what is in the `IsoPath` variable at the top of the script.
2. Run the `Win10_11VM.ps1` script as admin.
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

## Microsoft Teams

Install Teams using the following url: https://www.microsoft.com/en-us/microsoft-teams/download-app
   1. A regular consumer version of Teams should be pre-installed in Windows 11.
   2. If you need to connect to a work or school account Teams, you will need to go to the url above and then select the download labeled "For work or school."

## Sources

These are some of the sources I used for this:

- https://subscription.packtpub.com/book/virtualization-and-cloud/9781785884313/6/ch06lvl1sec57/vm-protection-vtpm (Requires a subscription to view)
- https://deploywindows.com/2015/11/13/add-virtual-tpm-in-windows-10-hyper-v-guest-with-powershell/
- https://www.reddit.com/r/HyperV/comments/d2u832/vtpm_operation_failed_when_performing_enablevmtpm/
- https://www.altaro.com/hyper-v/using-powershell-manage-utilize-hyper-v-integration-services-server-2012-r2/
- https://www.danielengberg.com/create-hyper-v-vm-powershell/
- https://4sysops.com/archives/install-windows-11-in-a-virtual-machine/
- https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/manage/component-updates/tpm-key-attestation
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/enable-vmtpm?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/enable-vmintegrationservice?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/get-vm?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vmsecurity?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/powershell/module/hyper-v/new-vm?view=windowsserver2019-ps
- https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v


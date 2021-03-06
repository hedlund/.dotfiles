param (
    [switch]$DryRun = $false
)
$Global:DryRun = $DryRun

$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. ("$ScriptDirectory\functions.ps1")


###############################################################################
# Functions

Function Remove-AllExcept([String]$Path, [String[]]$Keep) {
  Get-Item -Path $Path | Select-Object -ExpandProperty property | ForEach-Object {
    if (!($Keep -contains $_)) {
      Write-Output "Removing startup item: $_"
      if (!$Global:DryRun) {
          Remove-ItemProperty -Path $Path -Name $_
      }
    }
  }
}

Function Ensure-StartItems([String]$Path, [Hashtable]$Items) {
  $Items.Keys | Foreach-Object {
    # Only actually set the value if it doesn't already exists...
    if (!(Test-RegistryValue -Path $Path -Name $_)) {
      Write-Output "Adding startup item: $_"
      if (!$Global:DryRun) {
          New-ItemProperty -Path $Path -Name $_ -PropertyType String -Value $Items.$_ | Out-Null
      }
    }
  }
}

Function Fix-RegistryStartItems([String]$Path, [Hashtable]$Items) {
  Remove-AllExcept -Path $Path -Keep $Items.Keys
  Ensure-StartItems -Path $Path -Items $Items
}


###############################################################################
# Registry: Local Machine start items

Fix-RegistryStartItems -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Items @{
}

###############################################################################
# Registry: Current User start items

Fix-RegistryStartItems -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Items @{
  Flameshot = "C:\Program Files\Flameshot\bin\flameshot.exe"
}


###############################################################################
# Start Menu Startup apps

$AllowedStartupItems = @("QuickLook.lnk")
$StartupPath = "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

# Remove all unspecified...
Get-ChildItem "$StartupPath" -Filter *.lnk | Foreach-Object {
  if (!($AllowedStartupItems -contains $_.Name)) {
    Write-Output "Removing startup item from Start Menu: $($_.Name)"
    if (!$Global:DryRun) {
        Remove-Item -Path $_.FullName
    }
  }
}

# ...and set the ones we actually want
if (!$Global:DryRun) {
    Set-ShortCut -Source "$HOME\AppData\Local\Programs\QuickLook\QuickLook.exe" -Arguments "/autorun" -Destination "$StartupPath\QuickLook.lnk"
}

<#
.SYNOPSIS
  Force la fenêtre de l'émulateur Android actif à s'afficher dans le bureau visible.

.DESCRIPTION
  L'émulateur Android (process qemu-system-*) mémorise parfois une position de
  fenêtre héritée d'une ancienne config multi-écrans, et se dessine HORS écran
  (ex. Top négatif) — la fenêtre existe mais reste invisible.

  Ce script attend qu'une fenêtre d'émulateur apparaisse (jusqu'à -TimeoutSec),
  puis : la restaure si minimisée, et la repositionne dans le bureau visible si
  elle est hors champ, enfin la passe au premier plan.

.PARAMETER TimeoutSec
  Durée max d'attente d'une fenêtre d'émulateur (défaut 60s). 0 = ne pas attendre.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\show_emulator.ps1
  # À lancer juste après avoir démarré l'émulateur.
#>
param([int]$TimeoutSec = 60)

$ErrorActionPreference = 'Stop'

if (-not ([System.Management.Automation.PSTypeName]'EmuWin').Type) {
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class EmuWin {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int ht, bool repaint);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int s);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
'@
}

Add-Type -AssemblyName System.Windows.Forms

function Get-EmulatorWindow {
  Get-Process -Name 'qemu-system-*' -ErrorAction SilentlyContinue |
    Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
}

# 1. Attendre l'apparition d'une fenêtre d'émulateur.
$deadline = (Get-Date).AddSeconds($TimeoutSec)
$proc = Get-EmulatorWindow
while ($null -eq $proc -and (Get-Date) -lt $deadline) {
  Start-Sleep -Milliseconds 800
  $proc = Get-EmulatorWindow
}
if ($null -eq $proc) {
  Write-Output "Aucune fenetre d'emulateur detectee (timeout ${TimeoutSec}s)."
  exit 1
}

$h = $proc.MainWindowHandle
$r = New-Object EmuWin+RECT
[EmuWin]::GetWindowRect($h, [ref]$r) | Out-Null
$vs = [System.Windows.Forms.SystemInformation]::VirtualScreen
$w  = $r.Right - $r.Left
$ht = $r.Bottom - $r.Top
Write-Output "Fenetre : '$($proc.MainWindowTitle)'  pos=($($r.Left),$($r.Top)) taille=${w}x${ht}  minimisee=$([EmuWin]::IsIconic($h))"
Write-Output "Bureau visible : ($($vs.Left),$($vs.Top)) -> ($($vs.Right),$($vs.Bottom))"

# 2. Restaurer si minimisee.
if ([EmuWin]::IsIconic($h)) { [EmuWin]::ShowWindow($h, 9) | Out-Null }  # SW_RESTORE

# 3. Repositionner si (partiellement) hors du bureau visible.
$offScreen = ($r.Left -lt $vs.Left) -or ($r.Top -lt $vs.Top) -or
             ($r.Right -gt $vs.Right) -or ($r.Bottom -gt $vs.Bottom)
if ($offScreen) {
  # Taille bornee au bureau, marge 40px en haut-gauche.
  $newW  = [Math]::Min($w,  $vs.Width  - 80)
  $newHt = [Math]::Min($ht, $vs.Height - 80)
  [EmuWin]::MoveWindow($h, $vs.Left + 40, $vs.Top + 20, $newW, $newHt, $true) | Out-Null
  Write-Output "Fenetre hors ecran -> repositionnee a (40,20) taille ${newW}x${newHt}."
} else {
  Write-Output "Fenetre deja dans le bureau visible."
}

# 4. Premier plan.
[EmuWin]::ShowWindow($h, 5) | Out-Null   # SW_SHOW
[EmuWin]::SetForegroundWindow($h) | Out-Null
[EmuWin]::GetWindowRect($h, [ref]$r) | Out-Null
Write-Output "OK -> fenetre affichee a ($($r.Left),$($r.Top))."

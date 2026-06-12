<#
.SYNOPSIS
  Surveillance d'arrière-plan : affiche automatiquement toute fenêtre d'émulateur
  Android qui démarre hors écran. Conçu pour être lancé au logon (tâche planifiée
  KlinikShowEmulator).

.DESCRIPTION
  Boucle infinie (poll 2s). Pour chaque nouvelle fenêtre d'émulateur (process
  qemu-system-*), si elle est minimisée ou hors du bureau visible, elle est
  restaurée/repositionnée et passée au premier plan — une seule fois par fenêtre
  (pas de vol de focus répété).
#>
$ErrorActionPreference = 'SilentlyContinue'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class EmuWatch {
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int ht, bool repaint);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int s);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
}
'@
Add-Type -AssemblyName System.Windows.Forms

$seen = @{}

while ($true) {
  $procs = Get-Process -Name 'qemu-system-*' -ErrorAction SilentlyContinue |
           Where-Object { $_.MainWindowHandle -ne 0 }
  foreach ($p in $procs) {
    $h = [int64]$p.MainWindowHandle
    if ($seen.ContainsKey($h)) { continue }

    $ptr = $p.MainWindowHandle
    $r = New-Object EmuWatch+RECT
    [EmuWatch]::GetWindowRect($ptr, [ref]$r) | Out-Null
    $vs = [System.Windows.Forms.SystemInformation]::VirtualScreen

    if ([EmuWatch]::IsIconic($ptr)) { [EmuWatch]::ShowWindow($ptr, 9) | Out-Null }  # SW_RESTORE

    $offScreen = ($r.Left -lt $vs.Left) -or ($r.Top -lt $vs.Top) -or
                 ($r.Right -gt $vs.Right) -or ($r.Bottom -gt $vs.Bottom)
    if ($offScreen) {
      $w  = [Math]::Min($r.Right - $r.Left, $vs.Width  - 80)
      $ht = [Math]::Min($r.Bottom - $r.Top, $vs.Height - 80)
      [EmuWatch]::MoveWindow($ptr, $vs.Left + 40, $vs.Top + 20, $w, $ht, $true) | Out-Null
    }
    [EmuWatch]::ShowWindow($ptr, 5) | Out-Null
    [EmuWatch]::SetForegroundWindow($ptr) | Out-Null

    $seen[$h] = $true
  }

  # Purge des handles disparus (émulateurs fermés) pour re-traiter un redémarrage.
  $alive = @($procs | ForEach-Object { [int64]$_.MainWindowHandle })
  foreach ($k in @($seen.Keys)) { if ($alive -notcontains $k) { $seen.Remove($k) } }

  Start-Sleep -Seconds 2
}

@echo off
title AEHERNAL - PC OPTIMIZER v1.0
color 0A
setlocal enabledelayedexpansion

:: Mengecek apakah dijalankan sebagai administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Jalankan script ini sebagai Administrator!
    pause
    exit /b
)

:MENU
cls
echo ===============================================
echo        AEHERNAL - PC OPTIMIZER v1.0
echo              Windows 10 / 11
echo ===============================================
echo.
echo [ DAILY USE ]
echo   [1] Cache Cleaner
echo   [2] SFC Check (Perbaiki file sistem)
echo.
echo [ MAXIMIZE PERFORMANCE ]
echo   [3] Core Optimize (CPU, GPU, RAM)
echo   [4] LOW-END Mode (Optimasi spek rendah)
echo   [5] OPTIONAL Optimize (Tweaks lanjutan)
echo   [6] Reset All Tweaks (Kembalikan ke default)
echo.
echo   [0] Exit
echo.
set /p pilih="Pilih menu: "

if "%pilih%"=="1" goto CLEANER
if "%pilih%"=="2" goto SFC
if "%pilih%"=="3" goto COREOPT
if "%pilih%"=="4" goto LOWEND
if "%pilih%"=="5" goto OPTIONAL
if "%pilih%"=="6" goto RESETALL
if "%pilih%"=="0" goto EXIT
goto MENU

:CLEANER
cls
echo [1] Membersihkan cache system, app, browser...
:: Hapus temporary files Windows
del /q /f /s "%TEMP%\*" 2>nul
del /q /f /s "%WINDIR%\Temp\*" 2>nul
:: Bersihkan prefetch
del /q /f /s "%WINDIR%\Prefetch\*" 2>nul
:: Bersihkan recycle bin
rd /s /q %systemdrive%\$Recycle.Bin 2>nul
:: Bersihkan cache browser (Chrome, Edge, Firefox) - hanya user saat ini
if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2>nul
if exist "%LOCALAPPDATA%\Mozilla\Firefox\Profiles" (
    for /d %%i in ("%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*") do (
        if exist "%%i\cache2" rd /s /q "%%i\cache2" 2>nul
    )
)
echo Selesai membersihkan cache!
timeout /t 2 >nul
goto MENU

:SFC
cls
echo [2] Memeriksa dan memperbaiki file sistem Windows...
sfc /scannow
echo Selesai! Jika ada kerusakan, akan diperbaiki.
timeout /t 5 >nul
goto MENU

:COREOPT
cls
echo [3] Mengoptimalkan CPU, GPU, RAM...
:: Power plan ke High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>nul
:: Atau jika tidak ada, buat power plan high performance
powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
:: Disable hibernation untuk hemat space (optional)
powercfg -h off
:: Set processor performance boost mode ke aggressive (registry)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f 2>nul
powercfg -setacvalueindex scheme_current sub_processor PERFINCPOL 2
powercfg -setactive scheme_current
:: Enable GPU hardware acceleration (registry untuk semua user)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f 2>nul
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f 2>nul
:: Set registry untuk gaming mode
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v GPUPriority /t REG_DWORD /d 8 /f 2>nul
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f 2>nul
:: Set visual effect ke performance (menonaktifkan animasi)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f 2>nul
:: Disable transparency effects
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f 2>nul
echo Optimasi core selesai. (Perubahan power plan, registry, dan visual effect)
timeout /t 3 >nul
goto MENU
cls
echo [4] Mengaktifkan LOW-END Mode untuk spek rendah...
:: Matikan visual efek secara maksimal
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
:: Matikan animasi taskbar dan start menu
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisallowShaking /t REG_DWORD /d 1 /f
:: Matikan translucency dan efek lainnya
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f
:: Disable startup delay (Windows boot optimization)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoRestartShell /t REG_DWORD /d 1 /f
:: Set processor scheduling ke background services (untuk game, biar prioritas lebih tinggi)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f 2>nul
:: Disable fullscreen optimization (mencegah stutter)
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f 2>nul
:: Nonaktifkan Windows Search (hemat RAM)
sc config WSearch start= disabled 2>nul
:: Matikan layanan SysMain (Superfetch) yang sering makan RAM
sc config SysMain start= disabled 2>nul
echo Mode LOW-END diaktifkan. (Semua efek visual dimatikan, layanan tidak penting dinonaktifkan)
echo Disarankan restart agar semua perubahan diterapkan.
timeout /t 5 >nul
goto MENU

:OPTIONAL
cls
echo [5] OPTIONAL Optimize - Tweaks lanjutan
echo =======================================
echo [A] Hapus bloatware ringan (OneDrive, Xbox, dll - aman)
echo [B] Nonaktifkan telemetry dan data collection
echo [C] Set DNS ke Cloudflare (1.1.1.1) untuk koneksi lebih cepat
echo [D] Kembali ke menu utama
set /p opt="Pilih (A/B/C/D): "
if /i "%opt%"=="A" goto BLOAT
if /i "%opt%"=="B" goto TELEMETRY
if /i "%opt%"=="C" goto DNS
goto MENU

:BLOAT
cls
echo Menghapus bloatware ringan...
:: Uninstall OneDrive (per user)
start /wait %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall 2>nul
:: Hapus folder OneDrive
rd /s /q "%USERPROFILE%\OneDrive" 2>nul
:: Nonaktifkan Xbox Game Bar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f
:: Nonaktifkan tips dan saran Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
echo Bloatware ringan dihapus/disabilitas.
timeout /t 3 >nul
goto OPTIONAL

:TELEMETRY
cls
echo Menonaktifkan telemetry dan data collection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
sc config DiagTrack start= disabled 2>nul
sc stop DiagTrack 2>nul
sc config dmwappushservice start= disabled 2>nul
echo Telemetry dinonaktifkan.
timeout /t 3 >nul
goto OPTIONAL

:DNS
cls
echo Mengganti DNS ke Cloudflare (1.1.1.1) untuk adapter aktif...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "Default Gateway"') do set gateway=%%a
for /f "tokens=1-2 delims=:" %%a in ('ipconfig ^| findstr "Ethernet adapter\|Wireless LAN adapter"') do (
    set adapter=%%a
    if not "!adapter!"=="" (
        netsh interface ip set dns name="!adapter!" static 1.1.1.1 2>nul
        netsh interface ip add dns name="!adapter!" 1.0.0.1 index=2 2>nul
    )
)
ipconfig /flushdns >nul
echo DNS Cloudflare diterapkan. Koneksi internet mungkin terputus sesaat.
timeout /t 3 >nul
goto OPTIONAL

:RESETALL
cls
echo [6] Mereset semua tweak ke default Windows...
[17/04/2026 22:24] Aether When???: :: Reset power plan ke Balanced
powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>nul
:: Aktifkan kembali hibernation (optional)
powercfg -h on
:: Hapus registry tweak yang kita buat (reset ke default dengan menghapus kunci tambahan)
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /f 2>nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /f 2>nul
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /f 2>nul
:: Reset visual effects ke default (biarkan Windows yang mengatur)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /f 2>nul
:: Aktifkan kembali transparency
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 1 /f
:: Aktifkan kembali layanan Windows Search (jika sebelumnya dinonaktifkan di LOWEND)
sc config WSearch start= delayed-auto 2>nul
sc config SysMain start= auto 2>nul
:: Aktifkan telemetry ke level dasar (required untuk update)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f
:: Reset DNS ke otomatis
for /f "tokens=1-2 delims=:" %%a in ('ipconfig ^| findstr "Ethernet adapter\|Wireless LAN adapter"') do (
    set adapter=%%a
    if not "!adapter!"=="" (
        netsh interface ip set dns name="!adapter!" dhcp 2>nul
    )
)
:: Aktifkan kembali GameDVR (default)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /f 2>nul
echo Semua tweak telah direset ke default Windows. Perubahan mungkin memerlukan restart.
timeout /t 5 >nul
goto MENU

:EXIT
echo Terima kasih telah menggunakan AETHERNAL PC OPTIMIZER. SEMOGA PC MU BLUESCREEN KARENA KELEBIHAN OPTIMASI AWOKAWOKAWOKA
timeout /t 2 >nul
exit

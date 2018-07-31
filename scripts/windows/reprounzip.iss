; This needs:
;   Default installation of Python 2.7 in C:\Python2.7
;   python27.dll in C:\Python2.7 (might be in Windows\system|system32|SysWOW64)
;     make sure python27.dll is 32bit
;   PyQt4 installed in Python installation
;   ssh.exe and DLLs in input\ssh
;   make sure to generate reprounzip.exe with setuptools (not distutils),
;     change shebang to #!python.exe

[Setup]
AppName=ReproUnzip
AppVerName=ReproUnzip 1.0.14
OutputBaseFilename=reprounzip-setup
DefaultGroupName=ReproUnzip
DefaultDirName={pf}\ReproUnzip
OutputDir=output

[Files]
; Base Python files
Source: C:\Python2.7\*; DestDir: {app}\python2.7; Flags: recursesubdirs
; SSH
Source: input\ssh\*; DestDir: {app}\ssh
; Other files
Source: input\reprounzip.bat; DestDir: {app}
Source: input\reprounzip-qt.bat; DestDir: {app}
Source: input\reprozip-jupyter.bat; DestDir: {app}
Source: input\reprozip.ico; DestDir: {app}

[UninstallDelete]
; Makes sure .pyc files don't get left behind
Type: filesandordirs; Name: {app}\python2.7\Lib

[Tasks]
Name: desktopicon; Description: Create a &desktop icon; GroupDescription: Additional icons:
Name: desktopicon\common; Description: For all users; GroupDescription: Additional icons:; Flags: exclusive
Name: desktopicon\user; Description: For the current user only; GroupDescription: Additional icons:; Flags: exclusive unchecked
Name: associatefiles; Description: Associate *.rpz files with ReproUnzip; GroupDescription: File Association:

[Icons]
Name: {group}\ReproUnzip; Filename: {app}\reprounzip-qt.bat; WorkingDir: {app}; IconFilename: {app}\reprozip.ico; IconIndex: 0;
Name: {commondesktop}\ReproUnzip; Filename: {app}\reprounzip-qt.bat; WorkingDir: {app}; Tasks: desktopicon; IconFilename: {app}\reprozip.ico; IconIndex: 0
Name: {group}\Uninstall ReproUnzip; Filename: {uninstallexe}

[Registry]
Root: HKCR; Subkey: .rpz; ValueType: string; ValueData: ReproZipBundle; Flags: uninsdeletevalue; Tasks: associatefiles
Root: HKCR; Subkey: ReproZipBundle; ValueType: string; ValueData: ReproZip Bundle; Flags: uninsdeletekey; Tasks: associatefiles
Root: HKCR; Subkey: ReproZipBundle\shell\open\command; ValueType: string; ValueData: """{app}\reprounzip-qt.bat"" ""%1"""; Tasks: associatefiles; Flags: uninsdeletekey
Root: HKCR; Subkey: ReproZipBundle\DefaultIcon; ValueType: string; ValueData: {app}\reprozip.ico; Tasks: associatefiles; Flags: uninsdeletekey

[Setup]
AppId={{C94A4AE9-4677-4B7E-8661-1381605D07A7}
AppName=玖云输入法
AppVersion=0.1.0
AppPublisher=Jiuyun Input contributors
AppPublisherURL=https://github.com/4444654/jiuyun-input
DefaultDirName={autopf}\Jiuyun Input
DefaultGroupName=玖云输入法
OutputDir=build\installer
OutputBaseFilename=JiuyunInput-0.1.0-Windows-x64-Setup
Compression=lzma2
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile=..\..\LICENSE
CloseApplications=no
UninstallDisplayIcon={app}\JiuyunSettings.exe
[Files]
Source: "build\x64\Release\JiuyunIME.dll"; DestDir: "{app}"; Flags: ignoreversion restartreplace uninsrestartdelete
Source: "build\x86\Release\JiuyunIME.dll"; DestDir: "{app}\x86"; Flags: ignoreversion restartreplace uninsrestartdelete
Source: "build\x64\Release\JiuyunSettings.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Dictionary\*.txt"; DestDir: "{app}\Dictionary"; Flags: ignoreversion
Source: "Dictionary\*.txt"; DestDir: "{app}\x86\Dictionary"; Flags: ignoreversion
Source: "tsf\LICENSE.Microsoft.txt"; DestDir: "{app}"; Flags: ignoreversion
[Icons]
Name: "{group}\玖云输入法设置"; Filename: "{app}\JiuyunSettings.exe"
Name: "{group}\卸载玖云输入法"; Filename: "{uninstallexe}"
[Run]
Filename: "{app}\JiuyunSettings.exe"; Description: "打开玖云输入法设置"; Flags: postinstall nowait skipifsilent runasoriginaluser
[UninstallRun]
Filename: "{sys}\regsvr32.exe"; Parameters: "/s /u ""{app}\JiuyunIME.dll"""; Flags: runhidden waituntilterminated
Filename: "{syswow64}\regsvr32.exe"; Parameters: "/s /u ""{app}\x86\JiuyunIME.dll"""; Flags: runhidden waituntilterminated
[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var ExitCode: Integer;
begin
  if CurStep = ssPostInstall then begin
    if not Exec(ExpandConstant('{sys}\regsvr32.exe'), '/s "' + ExpandConstant('{app}\JiuyunIME.dll') + '"', '', SW_HIDE, ewWaitUntilTerminated, ExitCode) or (ExitCode <> 0) then
      RaiseException('Unable to register the 64-bit Jiuyun input service.');
    if not Exec(ExpandConstant('{syswow64}\regsvr32.exe'), '/s "' + ExpandConstant('{app}\x86\JiuyunIME.dll') + '"', '', SW_HIDE, ewWaitUntilTerminated, ExitCode) or (ExitCode <> 0) then
      RaiseException('Unable to register the 32-bit Jiuyun input service.');
  end;
end;

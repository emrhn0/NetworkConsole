; Network Console 2.0 (Flutter) - Inno Setup script.
; Yonetici hakki gerekmez (kullanici profiline kurulur), eski 1.5.x
; kurulumuyla ayni sekilde. Payload klasoru CI tarafindan
; build\windows\x64\runner\Release + NetworkConsole-Agent.exe + ikon
; ile PAYLOAD_DIR degiskeninde saglanir; yerel test icin varsayilan yol
; asagida.
#ifndef MyAppVersion
  #define MyAppVersion "2.8.1"
#endif
#ifndef PayloadDir
  #define PayloadDir "..\build\windows\x64\runner\Release"
#endif

[Setup]
AppId={{B7B6C6C0-6E1E-4C0D-9C4B-0A6F5A8F0E20}
AppName=Network Console
AppVersion={#MyAppVersion}
AppPublisher=Network Console
DefaultDirName={localappdata}\Programs\NetworkConsole2
DefaultGroupName=Network Console
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputBaseFilename=Network_Console_{#MyAppVersion}_windows_Setup
OutputDir=..\..\dist2
Compression=lzma2
SolidCompression=yes
SetupIconFile=..\..\network-console-icon.ico
UninstallDisplayIcon={app}\network_console_app.exe
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

; Kullanici verisi (VirusTotal anahtari, tema, dil - shared_preferences)
; %APPDATA% altinda, {app} klasorunun DISINDA saklanir; asagidaki temizlik
; sadece eski surumun program dosyalarini siler, ayarlara dokunmaz.
[InstallDelete]
Type: filesandordirs; Name: "{app}\data"
Type: files; Name: "{app}\*.dll"
Type: files; Name: "{app}\*.exe"
Type: files; Name: "{app}\*.pdb"

[Files]
Source: "{#PayloadDir}\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Network Console"; Filename: "{app}\network_console_app.exe"
Name: "{userdesktop}\Network Console"; Filename: "{app}\network_console_app.exe"

[Run]
Filename: "{app}\network_console_app.exe"; Description: "Launch Network Console"; Flags: nowait postinstall skipifsilent
; Uygulama icindeki guncelleyici bu kurucuyu sessiz calistirir ve kendisi
; cikmak zorundadir (dosyalari degistirilecek), dolayisiyla uygulamayi tekrar
; baslatacak kimse kalmaz - ustteki satir sessiz kurulumda atlanir. /RELAUNCH
; bunu kurucuya yaptirir.
Filename: "{app}\network_console_app.exe"; Flags: nowait; Check: RelaunchRequested

[Code]
function RelaunchRequested: Boolean;
begin
  Result := WizardSilent and (Pos('/RELAUNCH', UpperCase(GetCmdTail)) > 0);
end;

// Ajan (NetworkConsole-Agent.exe) uygulama kapansa da arka planda (tray)
// calismaya devam eden ayri bir surec. Restart Manager onu kapatamiyor:
// pencere yok, PyInstaller onefile iki surec (bootloader + cocuk). Sonuc:
// "Setup was unable to automatically close all applications" ve
// "DeleteFile failed; code 5" - Skip denirse ESKI ajan yerinde kalir.
// Bu yuzden dosyalar kopyalanmadan once ajani (ve kalmis uygulamayi) zorla
// kapatip, exe gercekten silinebilir olana kadar kisa bir sure bekliyoruz.
procedure KillByName(const ExeName: String);
var
  Code: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /T /IM "' + ExeName + '"', '',
       SW_HIDE, ewWaitUntilTerminated, Code);
end;

procedure StopRunningCopies;
var
  I: Integer;
  Agent: String;
begin
  KillByName('NetworkConsole-Agent.exe');
  KillByName('network_console_app.exe');
  Agent := ExpandConstant('{app}\NetworkConsole-Agent.exe');
  // Surec olse bile Windows dosya kilidini bir an tutabiliyor.
  for I := 1 to 20 do
  begin
    if (not FileExists(Agent)) or DeleteFile(Agent) then Break;
    Sleep(250);
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  StopRunningCopies;
  Result := '';
end;

function InitializeUninstall: Boolean;
begin
  KillByName('NetworkConsole-Agent.exe');
  KillByName('network_console_app.exe');
  Result := True;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

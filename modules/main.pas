unit main;

interface

uses
  Windows, Messages, SysUtils,  Classes, Graphics, Controls, Forms, Dialogs,
  Tray, Menus, StdCtrls, ComCtrls, Buttons, ExtCtrls, shellapi, IniFiles;

type
  TForm1 = class(TForm)
    try1: TTray;
    pm1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    shp1: TShape;
    btn13: TButton;
    btn14: TButton;
    pnl1: TPanel;
    grp1: TGroupBox;
    mmo1: TMemo;
    btn1: TButton;
    tmr1: TTimer;
    chk1: TCheckBox;
    btn2: TButton;
    stat1: TStatusBar;
    tmr2: TTimer;
    cbb1: TComboBox;
    lng: TGroupBox;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N4Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure btn14Click(Sender: TObject);
    procedure btn13Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
    procedure cbb1Change(Sender: TObject);
  private
    ini: TIniFile;
    List: TStringList;
    StartTime: TDateTime;

    Lang: string;
    CfgText: string;
    VerText: string;
    Version: string;
    ConText: string;
    DisText: string;
    jobTime: string;
    notActive: string;
    ActiveCFG: string;
    ProgramPath: string;
    ActiveCfgValue: string;
    GoodByeDPIPath: string;

    procedure LoadLang;
    function FindDPIVersion:string;
    function DPIGetVersion(FileName: string):string;
    procedure RegistrationApp;
    procedure RunDPI;
    procedure StopDPI;
    procedure FindCFG;
  public
    procedure MenuItemClick(Sender: TObject);
  end;

var
  Form1     : TForm1;
  AppName   : string = 'GoodbyeDPI-GUI';
  UserConfig: string = '0_user_configuration';

const
  SEC_MAIN  : string = 'main';
  SEC_LANG  : string = 'language';
  VersionGUI: string = 'v1.0.2';
  GOODBYEDPI: string = 'goodbyedpi';
  UPD_FILE  : string = 'update.zip';
  DPI_URL   : string = 'https://github.com/ValdikSS/GoodbyeDPI';
  GUI_URL   : string = 'https://github.com/uberchel/GoodbyeDPI-GUI';
  API_URL   : string = 'https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases';
  CFG_VALUE : string = 'goodbyedpi.exe -6 --blacklist ..\russia-blacklist.txt --blacklist ..\russia-youtube.';
  LANGUAGES : array[0..1] of string = ('Ru', 'En');

implementation

uses
 Utils, help, update, Registry;

{$R *.dfm}

procedure TForm1.RegistrationApp;
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;

  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\UberSOFT\' + AppName, True) then
    begin
      try
       Reg.WriteString('Name', AppName);
       Reg.WriteString('Lang', Lang);
       Reg.WriteString('Version DPI', Version);
       Reg.WriteString('Version GUI', VersionGUI);
       Reg.WriteString('InstallPath', ProgramPath);
      finally
        Reg.CloseKey;
      end;
    end;
  except
  end;
  Reg.Free;
end;

procedure TForm1.LoadLang;
begin
  Lang:= ini.ReadString(SEC_MAIN, 'lang', LANG);
  VerText:= ini.ReadString(SEC_LANG + Lang, 'version', 'Версия DPI:');
  CfgText:= ini.ReadString(SEC_LANG + Lang, 'connfiguration', 'Текущий cfg:');
  ConText:= ini.ReadString(SEC_LANG + Lang, 'connect', 'Подключиться');
  DisText:= ini.ReadString(SEC_LANG + Lang, 'desconnect', 'Отключиться');
  jobTime:= ini.ReadString(SEC_LANG + Lang, 'jobTime', 'Активно:');
  notActive:= ini.ReadString(SEC_LANG + Lang, 'Inactive', 'Неактивно');
  
  chk1.Caption:= ini.ReadString(SEC_LANG + Lang, 'autorun', 'Запускать вместе с Windows');
  btn13.Caption:= ini.ReadString(SEC_LANG + Lang, 'updateDPIBtn', 'Обновить DPI');
  btn14.Caption:= ini.ReadString(SEC_LANG + Lang, 'helpBtn', 'Помощь по DPI');
  btn2.Caption:= ini.ReadString(SEC_LANG + Lang, 'updateDBBtn', 'Обновить Базу');
  btn1.Caption:= ini.ReadString(SEC_LANG + Lang, 'saveBtn', 'Сохранить');
  help.Form2.Caption:= ini.ReadString(SEC_LANG + Lang, 'help', 'Помощь');
  grp1.Caption:= ini.ReadString(SEC_LANG + Lang, 'config', 'Пользовательский конфиг');

  with pm1 do
  begin
     Items[0].Caption:= ConText;
     Items[1].Caption:= ini.ReadString(SEC_LANG + Lang, 'configureBtn', 'Конфигурации');
     Items[3].Caption:= ini.ReadString(SEC_LANG + Lang, 'settingsBtn', 'Настройки');
     Items[5].Caption:= ini.ReadString(SEC_LANG + Lang, 'updateDBBtn', 'Обновить Базу');
     Items[7].Caption:= ini.ReadString(SEC_LANG + Lang, 'exitBtn', 'В&ыход');
  end;

  stat1.Panels[0].Text:= notActive;
  lng.Caption:= ini.ReadString(SEC_LANG + Lang, 'lang', 'Язык');
end;

procedure TForm1.RunDPI;
var
  FFile: string;
begin
  FFile:= string(GoodByeDPIPath + ActiveCFG + '.cmd');

  if FileExists(FFile) then
   begin
    ShellExecute(Handle, 'open', PChar(FFile), nil,nil, 0);
    Application.ProcessMessages;
    tmr1.Enabled:= True;
    tmr2.Enabled:= True;
   end
  else
   MessageBox(Handle, PChar('File Not Found: ' + FFile), 'Attention', 48);
end;

procedure TForm1.StopDPI;
begin
  tmr2.Enabled:= False;
  stat1.Panels[0].Text:= notActive;
  WinExec('taskkill /IM goodbyedpi.exe /F /T', 0);
end;

procedure TForm1.FindCFG;
var
  SearchRec: TSearchRec;
  NewItem: TMenuItem;
  FirstRun: Boolean;
  Name: string;
begin
  FirstRun:= False;
  if FindFirst(GoodByeDPIPath + '*.cmd', faAnyFile, SearchRec) = 0 then
  begin
    repeat
     if (SearchRec.Name = '.') or (SearchRec.Name = '..')
        or (Pos('service', SearchRec.Name) > 0)
        or (Pos('update', SearchRec.Name) > 0)
     then
        Continue;

      NewItem:= TMenuItem.Create(self);
      Name:= Copy(SearchRec.Name, 0, Length(SearchRec.Name) - 4);
      NewItem.Caption:= UpperCase(Name);
      NewItem.OnClick:= MenuItemClick;
      pm1.Items[1].Add(NewItem);
      List.Add(Name);

      if FirstRun = False then
      begin
        Activecfg:= Name;
        FirstRun:= True;
        RegistrationApp;
      end;

    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

function TForm1.DPIGetVersion(FileName: string):string;
var
  VersionPart: string;
  HyphenPos: Integer;
begin
  if (FileName <> '') and (Pos(GOODBYEDPI, FileName) > 0) then
  begin
    HyphenPos:= 0;
    HyphenPos:= Pos('-', FileName);

    if HyphenPos = 0 then HyphenPos:= Pos('–', FileName);
    if HyphenPos = 0 then HyphenPos:= Pos('—', FileName);

    if HyphenPos > 0 then
    begin
      VersionPart:= Copy(FileName, HyphenPos + 1, Length(FileName));
      result:= Trim(VersionPart);
    end
    else
    result:= '';
  end;
end;

function TForm1.FindDPIVersion:string;
var
  SearchRec: TSearchRec;
  VersionPart: string;
  FolderName: string;
  HyphenPos: Integer;
begin
  if FindFirst(ProgramPath + '*.*', faDirectory, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name = '.') or (SearchRec.Name = '..') then Continue;

      if (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        FolderName:= LowerCase(SearchRec.Name);
        if Pos(GOODBYEDPI, FolderName) > 0 then
        begin
          HyphenPos:= 0;
          HyphenPos:= Pos('-', SearchRec.Name);

          if HyphenPos = 0 then HyphenPos:= Pos('–', SearchRec.Name);
          if HyphenPos = 0 then HyphenPos:= Pos('—', SearchRec.Name);

          if HyphenPos > 0 then
          begin
            VersionPart:= Copy(SearchRec.Name, HyphenPos + 1, Length(SearchRec.Name));
            result:= Trim(VersionPart);
            Break;
          end
          else
          begin
            result:= '';
          end;
        end;
      end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  JSON: string;
  Strings: TStringList;
begin
  StartTime:= Now;
  Caption:= AppName;
  Version:= FindDPIVersion;
  List:= TStringList.Create;
  ProgramPath:= ExtractFilePath(ParamStr(0));
  GoodByeDPIPath:= string(ProgramPath + 'goodbyedpi-' + Version + '\');

  if (Version = '') then
  begin
    JSON:= HttpGet(API_URL);
    if JSON <> '' then
    begin
      Strings:= TStringList.Create;

      ExtractUrls(JSON, Strings);
      Application.ProcessMessages;

      DownloadFile(Strings[0], ProgramPath + UPD_FILE);
      Application.ProcessMessages;
      Strings.Free;

      ExtractArhive(ProgramPath + UPD_FILE, '');
      Application.ProcessMessages;
      Sleep(500);

      Version:= FindDPIVersion;
      Application.ProcessMessages;
      Sleep(200);
      
      DeleteFile(ProgramPath + UPD_FILE);
    end;
  end;

  ini:= TIniFile.Create(ProgramPath + 'cfg.ini');
  chk1.Checked:= ini.ReadBool(SEC_MAIN, 'autorun', False);
  ActiveCfg:= ini.ReadString(SEC_MAIN, 'cfg', UserConfig);
  stat1.Panels[2].Text:= VersionGUI;

  ActiveCfgValue:= ini.ReadString(SEC_MAIN, 'cfgValue', CFG_VALUE);
  if ActiveCfgValue = '' then
    mmo1.Text:= CFG_VALUE
  else
    mmo1.Text:= ActiveCfgValue;

  try1.Active(true);
  LoadLang;
  FindCFG;

  cbb1.Text:= Lang;
  for i:= 0 to Length(LANGUAGES)-1 do
  begin
    if ini.SectionExists('Language' + LANGUAGES[i]) then
      cbb1.Items.Add(LANGUAGES[i]);
    if (Lang = LANGUAGES[i]) and (i > cbb1.Items.Count) then
      cbb1.ItemIndex:= i;
  end;


end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);

  pnl1.Caption:= VerText + Version;
  stat1.Panels[1].Text:= CfgText + ActiveCFG;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:= False;
 Form1.Hide;
end;

procedure TForm1.MenuItemClick(Sender: TObject);
var
  Item: TMenuItem;
begin
  if Sender is TMenuItem then
  begin
    Item := TMenuItem(Sender);
    ActiveCFG:= List[Item.Tag];

    if (pm1.Tag = 1) then
    begin
      StopDPI;
      Application.ProcessMessages;
      pm1.Tag:= 0;
    end;

    if (pm1.Tag = 0) then
    begin
      pm1.Items[0].Caption:= DisText;
      pm1.Tag:= 1;
      RunDPI;
    end;
  end;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.N8Click(Sender: TObject);
begin
  StopDPI;
  try1.DeActive;
  Application.Terminate;
end;

procedure TForm1.btn14Click(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.btn13Click(Sender: TObject);
var
  JSON, msg, msgText, msgText2, ver, ver2: string;
  str: TStringList;
  intVer, intVer2: Integer;
begin
  JSON:= HttpGet(API_URL);

  if JSON = '' then exit;

  str:= TStringList.Create;
  ExtractUrls(JSON, str);
  msg:= ini.ReadString(SEC_LANG + Lang, 'msgUpdate', 'Обновление завершено, новая версия:');

  ver:= StringReplace(Version, 'rc', '', [rfReplaceAll]);
  ver:= StringReplace(ver, '-', '', [rfReplaceAll]);
  ver:= StringReplace(ver, '.', '', [rfReplaceAll]);
  intVer:= StrToInt(ver);

  ver2:= StringReplace(DPIGetVersion(str[0]), 'rc', '', [rfReplaceAll]);
  ver2:= StringReplace(ver2, 'zip', '', [rfReplaceAll]);
  ver2:= StringReplace(ver2, '-', '', [rfReplaceAll]);
  ver2:= StringReplace(ver2, '.', '', [rfReplaceAll]);
  intVer2:= StrToInt(ver2);


  if (Boolean(intVer < intVer2)) then
  begin
    StopDPI;
    if JSON <> '' then
    begin
      DownloadFile(str[0], ProgramPath + UPD_FILE);
      Application.ProcessMessages;

      ExtractArhive(ProgramPath + UPD_FILE, '');
      Application.ProcessMessages;
      Sleep(500);

      DeleteDirectory(GoodByeDPIPath);
      Application.ProcessMessages;
      Sleep(500);

      Version:= DPIGetVersion(str[0]);
      pnl1.Caption:= 'GoodByeDPI: ' + Version;
      Application.ProcessMessages;
      str.Free;

      DeleteFile(ProgramPath + UPD_FILE);
      msgText:= ini.ReadString(SEC_LANG + Lang, 'msgUpdateText', 'Обновление завершено, новая версия:');
      MessageBox(Handle, PChar(msgText + Version), PChar(msg), 64);
    end;
  end
  else
  begin
   msgText2:= ini.ReadString(SEC_LANG + Lang, 'msgUpdateText2', 'У вас уже установлена последняя версия:');
   MessageBox(Handle, PChar(msgText2 + Version), PChar(msg), 64);
  end;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  if pm1.Tag = 0 then
    begin
      pm1.Items[0].Caption:= DisText;
      pm1.Tag:= 1;
      RunDPI;
    end
  else
  begin
    pm1.Items[0].Caption:= ConText;
    pm1.Tag:= 0;
    StopDPI;
  end;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  text: string;
begin
  btn1.Enabled:= False;
  text:= '@ECHO OFF' + #10 +
'PUSHD "%~dp0"' + #10 +
'set _arch=x86' + #10 +
'IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set _arch=x86_64)' + #10 +
'IF DEFINED PROCESSOR_ARCHITEW6432 (set _arch=x86_64)' + #10 +
'PUSHD "%_arch%"' + #10#10 +
'start "" ' + mmo1.Text + #10 +
'POPD' + #10 +'POPD';

 ini.WriteString(SEC_MAIN, 'cfgValue', ActiveCfgValue);
 Application.ProcessMessages;

 SaveToFile(GoodByeDPIPath + UserConfig + '.cmd', text);
 Application.ProcessMessages;
 btn1.Enabled:= True;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  H: HWND;
begin
  H := FindWindow('ConsoleWindowClass', nil);
  if H <> 0 then
   ShowWindow(H, SW_HIDE);

  tmr1.Enabled:= False;
end;

procedure TForm1.chk1Click(Sender: TObject);
begin
  if chk1.Checked then
    SetAutoRun(True)
  else
    SetAutoRun(False);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 ini.WriteString(SEC_MAIN, 'cfg', ActiveCFG);
 ini.WriteString(SEC_MAIN, 'cfgValue', ActiveCfgValue);
 ini.WriteBool(SEC_MAIN, 'autorun', chk1.Checked);
 ini.Free;
 List.Free;
end;

procedure TForm1.btn2Click(Sender: TObject);
begin
  WinExec(PChar(GoodByeDPIPath + '0_russia_update_blacklist_file.cmd'), 1);
end;

procedure TForm1.tmr2Timer(Sender: TObject);
var
  Elapsed: TDateTime;
  Hours, Minutes, Seconds: Integer;
begin
  Elapsed:= Now - StartTime;
  Hours:= Trunc(Elapsed * 24);
  Minutes:= Trunc((Elapsed * 24 - Hours) * 60);
  Seconds:= Trunc((((Elapsed * 24 - Hours) * 60) - Minutes) * 60);
  stat1.Panels[0].Text:= Format(jobTime + ' %dday, %dhrs, %dmin, %dsec', [Trunc(Elapsed), Hours, Minutes, Seconds])
end;

procedure TForm1.cbb1Change(Sender: TObject);
begin
 Lang:= cbb1.Items[cbb1.itemIndex];
 ini.WriteString(SEC_MAIN, 'lang', Lang);
 Application.ProcessMessages;
 LoadLang;
end;

end.

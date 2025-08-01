unit main;

interface

uses
  Windows,WinInet, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Tray, Menus, StdCtrls, ComCtrls, Buttons, ExtCtrls,
  ImgList, shellapi, IniFiles;

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
  private
    ini: TIniFile;
    UpdateFile: string;
    function FindGoodbyeDPIVersion:string;
    function FindGoodbyeDPIVersionFile(FileName: string):string;
    procedure FindGoodbyeDPIRuns;
    procedure SetAutoRun(Enable: Boolean);
  public
    procedure MenuItemClick(Sender: TObject);
  end;

var
  Form1: TForm1;
  Version: string;
  ProgramPath: string;
  Activecfg: string;
  GoodByeDPIPath: string;
  StartTime: TDateTime;
  AppName: string = 'GoodbyeDPI-GUI';
  UserConfig: string = '0_user_configuration';

const
  DPI_URL: string = 'https://github.com/ValdikSS/GoodbyeDPI';
  GUI_URL: string = 'https://github.com/uberchel/GoodbyeDPI-GUI';
  API_URL: string = 'https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases';

implementation

uses
 help, Registry, update, ComObj, ActiveX, UrlMon;

{$R *.dfm}

function HttpGet(const URL: string): string;
var
  HTTP: OleVariant;
begin
  Result := '';
  try
    HTTP := CreateOleObject('MSXML2.XMLHTTP.6.0');
    HTTP.open('GET', URL, False);
    HTTP.setRequestHeader('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    HTTP.send;

    if HTTP.status = 200 then
      Result := HTTP.responseText
    else
      raise Exception.Create('Ошибка HTTP: ' + IntToStr(HTTP.status));
  except
    on E: Exception do
      raise Exception.Create('Ошибка запроса: ' + E.Message);
  end;
end;

function DownloadFile(const URL, FileName: string): Boolean;
begin
  Result := URLDownloadToFile(nil, PChar(URL), PChar(FileName), 0, nil) = 0;
end;

function ParseJSON(const JSON: string): OleVariant;
var
  Script: OleVariant;
begin
  Script := CreateOleObject('ScriptControl');
  Script.Language := 'JScript';
  Script.AddCode('function parseJSON(json) { return eval("(" + json + ")"); }');
  Result := Script.Run('parseJSON', JSON);
end;

function SaveToFile(const FileName, Content: string): Boolean;
var
  FileStream: TextFile;
begin
  Result := False;
  try
    AssignFile(FileStream, FileName);
    Rewrite(FileStream);
    Writeln(FileStream, Content);
    CloseFile(FileStream);
    Result := True;
  except
    Result := False;
  end;
end;

function DeleteDirectory(const DirPath: string): Boolean;
var
  SearchRec: TSearchRec;
  FileName: string;
begin
  Result := False;
  
  if not DirectoryExists(DirPath) then
  begin
    Result := True;
    Exit;
  end;

  if FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        FileName := SearchRec.Name;
        if (FileName = '.') or (FileName = '..') then
          Continue;

        FileName := DirPath + '\' + FileName;

        if (SearchRec.Attr and faDirectory) <> 0 then
        begin
          if not DeleteDirectory(FileName) then
            Exit;
        end
        else
        begin
          if FileSetAttr(FileName, 0) <> 0 then
            Continue;
          if not DeleteFile(PChar(FileName)) then
            Exit;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;

  Result := RemoveDir(PChar(DirPath));
end;

procedure Extract7z(const ZipFile, OutputDir: string);
var
  Cmd: string;
begin
  Cmd := Format(ProgramPath + '7z.exe x "%s" -o"%s" -y', [ZipFile, OutputDir]);
  WinExec(PChar(Cmd), SW_HIDE);
end;

procedure RunDPI;
var
  ffile: string;
begin
  ffile:= GoodByeDPIPath + Activecfg + '.cmd';
  if FileExists(ffile) then
   begin
    ShellExecute(Form1.Handle, 'open', PChar(ffile), nil,nil, 0);
    Application.ProcessMessages;
    Form1.tmr1.Enabled:= True;
   end
  else
   MessageBox(Form1.Handle, PChar('Файл не найден: ' + ffile), 'Внимание', 48);
end;

procedure ExitDPI;
begin
  WinExec('taskkill /IM goodbyedpi.exe /F /T', 1);
end;

procedure TForm1.SetAutoRun(Enable: Boolean);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      try
        if Enable then
        begin
          Reg.WriteString(AppName, Application.ExeName);
        end
        else
        begin
          if Reg.ValueExists(AppName) then
            Reg.DeleteValue(AppName);
        end;
      finally
        Reg.CloseKey;
      end;
    end
    else
      raise Exception.Create('Не удалось открыть ключ реестра.');
  except
    on E: Exception do
      MessageBox(Handle, PChar('Ошибка автозагрузки: ' + E.Message), 'Ошибка', 16);
  end;
  Reg.Free;
end;

procedure TForm1.FindGoodbyeDPIRuns;
var
  SearchRec: TSearchRec;
  NewItem: TMenuItem;
  first: Boolean;
begin
  first:= False;
  if FindFirst(GoodByeDPIPath + '*.cmd', faAnyFile, SearchRec) = 0 then
  begin
    repeat
     if (SearchRec.Name = '.') or (SearchRec.Name = '..')
        or (Pos('service', SearchRec.Name) > 0) or (Pos('update', SearchRec.Name) > 0)
     then
        Continue;

      NewItem:= TMenuItem.Create(self);
      NewItem.Caption:= Copy(SearchRec.Name, 0, Length(SearchRec.Name) - 4);
      NewItem.OnClick:= MenuItemClick;
      pm1.Items[1].Add(NewItem);

      if first = False then
      begin
        Activecfg:= NewItem.Caption;
        first:= True;
      end;

    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
  end;
end;

function TForm1.FindGoodbyeDPIVersionFile(FileName: string):string;
var
  VersionPart: string;
  HyphenPos: Integer;
begin

  if FileName <> '' then
  if Pos('goodbyedpi', FileName) > 0 then
  begin
    HyphenPos:= 0;
    HyphenPos:= Pos('-', FileName);
    if HyphenPos = 0 then
      HyphenPos:= Pos('–', FileName);
    if HyphenPos = 0 then
      HyphenPos:= Pos('—', FileName);

    if HyphenPos > 0 then
    begin
      VersionPart:= Copy(FileName, HyphenPos + 1, Length(FileName));
      result:= Trim(VersionPart);
    end
    else
    result:= '';
  end;
end;

function TForm1.FindGoodbyeDPIVersion:string;
var
  SearchRec: TSearchRec;
  VersionPart: string;
  FolderName: string;
  HyphenPos: Integer;
begin
  if FindFirst(ProgramPath + '*.*', faDirectory, SearchRec) = 0 then
  begin
    repeat
      if (SearchRec.Name = '.') or (SearchRec.Name = '..') then
        Continue;

      if (SearchRec.Attr and faDirectory) = faDirectory then
      begin
        FolderName:= LowerCase(SearchRec.Name);
        if Pos('goodbyedpi', FolderName) > 0 then
        begin
          HyphenPos:= 0;
          HyphenPos:= Pos('-', SearchRec.Name);
          if HyphenPos = 0 then
            HyphenPos:= Pos('–', SearchRec.Name);
          if HyphenPos = 0 then
            HyphenPos:= Pos('—', SearchRec.Name);

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

function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  P: Integer;
begin
  P := Pos(SubStr, Copy(S, Offset, Length(S) - Offset + 1));
  if P > 0 then
    Result := P + Offset - 1
  else
    Result := 0;
end;

procedure ExtractUrls(const JSON: string; Urls: TStrings);
var
  PosStart, PosEnd: Integer;
  SearchStr: string;
begin
  Urls.Clear;
  SearchStr := '"browser_download_url":';

  PosStart := 1;
  while PosStart <= Length(JSON) do
  begin
    PosStart := PosEx(SearchStr, JSON, PosStart);
    if PosStart = 0 then Break;
    Inc(PosStart, Length(SearchStr));

    while (PosStart <= Length(JSON)) and (JSON[PosStart] in [' ', #9, ':']) do
      Inc(PosStart);

    if (PosStart > Length(JSON)) or (JSON[PosStart] <> '"') then
    begin
      PosStart := PosStart + 1;
      Continue;
    end;

    Inc(PosStart);
    PosEnd := PosEx('"', JSON, PosStart);
    while (PosEnd > PosStart) and (PosEnd > 1) and (JSON[PosEnd - 1] = '\') do
    begin
      PosEnd := PosEx('"', JSON, PosEnd + 1);
      if PosEnd = 0 then Break;
    end;

    if (PosEnd = 0) or (PosEnd <= PosStart) then Break;
    Urls.Add(Copy(JSON, PosStart, PosEnd - PosStart));
    PosStart := PosEnd + 1;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  JSON: string;
  str: TStringList;
begin
  StartTime:= Now;
  Caption:= AppName;
  Application.title:= Caption;
  Version:= FindGoodbyeDPIVersion;
  ProgramPath := ExtractFilePath(Application.ExeName);

  if (Version = '') then
  begin
    JSON:= HttpGet(API_URL);
    if JSON <> '' then
    begin
      UpdateFile:= ProgramPath + 'update.zip';
      str:= TStringList.Create;
      ExtractUrls(JSON, str);
      DownloadFile(str[0], UpdateFile);
      Extract7z(UpdateFile, ProgramPath);
      Application.ProcessMessages;
      Sleep(500);
      Version:= FindGoodbyeDPIVersion;
      Application.ProcessMessages;
      DeleteFile(UpdateFile);
      str.Free;
    end;
  end;

  GoodByeDPIPath:= ProgramPath + 'goodbyedpi-' + Version + '\';
  ini:= TIniFile.Create(ProgramPath + 'cfg.ini');
  chk1.Checked:= ini.ReadBool(AppName, 'autorun', False);
  Activecfg:= ini.ReadString(AppName, 'cfg', Activecfg);
  try1.Active(true);
  FindGoodbyeDPIRuns;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  pnl1.Caption:= 'Версия DPI: ' + Version;
  stat1.Panels[1].Text:= 'Текущая конфигурация: ' + Activecfg;
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
    Activecfg:= Copy(Item.Caption, 2, Length(Item.Caption));

    if (pm1.Tag = 1) then
    begin
      ExitDPI;
      Application.ProcessMessages;
      pm1.Tag:= 0;
    end;

    if (pm1.Tag = 0) then
    begin
      pm1.Items[0].Caption:= 'Отключить';
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
  ExitDPI;
  try1.DeActive;
  Application.Terminate;
end;

procedure TForm1.btn14Click(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.btn13Click(Sender: TObject);
var
  JSON: string;
  str: TStringList;
begin
  JSON:= HttpGet(API_URL);

  if JSON = '' then exit;

  str:= TStringList.Create;
  ExtractUrls(JSON, str);

  if (Version <> FindGoodbyeDPIVersionFile(str[0])) then
  begin
    ExitDPI;
    if JSON <> '' then
    begin
      DownloadFile(str[0], UpdateFile);
      Extract7z(UpdateFile, ProgramPath);
      Application.ProcessMessages;
      Sleep(500);
      DeleteDirectory(GoodByeDPIPath);
      Application.ProcessMessages;
      Version:= FindGoodbyeDPIVersionFile(str[0]);
      pnl1.Caption:= 'Версия DPI: ' + Version;
      Application.ProcessMessages;
      DeleteFile(UpdateFile);
      str.Free;
      MessageBox(Handle, PChar('Обновление завершено, текущая версия: ' + Version), 'Обновление', 64);
    end;
  end
  else
   MessageBox(Handle, PChar('У вас уже установлена последняя версия: ' + Version), 'Обновление', 64);
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  if pm1.Tag = 0 then
    begin
      pm1.Items[0].Caption:= 'Отключить';
      pm1.Tag:= 1;
      RunDPI;
    end
  else
  begin
    pm1.Items[0].Caption:= 'Включить';
    pm1.Tag:= 0;
    ExitDPI;
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

  tmr1.Enabled:= True;
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
 ini.WriteString(AppName, 'cfg', Activecfg);
 ini.WriteBool(AppName, 'autorun', chk1.Checked);
 ini.Free;
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
  stat1.Panels[0].Text:= Format('Активно: %dчас, %dмин, %dсек', [Hours, Minutes, Seconds])
end;

end.

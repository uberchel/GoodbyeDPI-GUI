unit Utils;

interface

{$A-}
{$C-}
{$D-}

uses
  Windows, Messages, Classes, StrUtils,  SysUtils, ComCtrls, ExtCtrls, ShellApi, Variants,
  ComObj, ActiveX, UrlMon, Registry, main;

// Exports
function HttpGet(const URL: string): string;
function DownloadFile(const URL, FileName: string): Boolean;
function SaveToFile(const FileName, Content: string): Boolean;
function DeleteDirectory(const DirPath: string): Boolean;
function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
function ExtractArhive(const ArhiveFile, Output: string): boolean;
function SetAutoRun(Enable: Boolean): Boolean;
procedure ExtractUrls(const JSON: string; Urls: TStringList);

implementation

function HttpGet(const URL: string): string;
var
  HTTP: OleVariant;
begin
  Result:= '';
  try
    HTTP:= CreateOleObject('MSXML2.XMLHTTP.6.0');
    HTTP.open('GET', URL, False);
    HTTP.setRequestHeader('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
    HTTP.send;

    if HTTP.status = 200 then
      Result:= HTTP.responseText
    else
      raise Exception.Create('HTTP Error: ' + IntToStr(HTTP.status));
  except
    on E: Exception do
      raise Exception.Create('Request error: ' + E.Message);
  end;
end;

function DownloadFile(const URL, FileName: string): Boolean;
begin
  Result:= URLDownloadToFile(nil, PChar(URL), PChar(FileName), 0, nil) = 0;
end;

function ParseJSON(const JSON: string): OleVariant;
var
  Script: OleVariant;
begin
  Script:= CreateOleObject('ScriptControl');
  Script.Language := 'JScript';
  Script.AddCode('function parseJSON(json) { return eval("(" + json + ")"); }');
  Result:= Script.Run('parseJSON', JSON);
end;

function SaveToFile(const FileName, Content: string): Boolean;
var
  FileStream: TextFile;
begin
  Result:= False;
  try
    AssignFile(FileStream, FileName);
    Rewrite(FileStream);
    Writeln(FileStream, Content);
    CloseFile(FileStream);
    Result:= True;
  except
    Result:= False;
  end;
end;

function DeleteDirectory(const DirPath: string): Boolean;
var
  SearchRec: TSearchRec;
  FileName: string;
begin
  Result:= False;

  if not DirectoryExists(DirPath) then
  begin
    Result:= True;
    Exit;
  end;

  if FindFirst(IncludeTrailingPathDelimiter(DirPath) + '*.*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        FileName:= SearchRec.Name;
        if (FileName = '.') or (FileName = '..') then
          Continue;

        FileName:= DirPath + '\' + FileName;

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

  Result:= RemoveDir(PChar(DirPath));
end;

function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer;
var
  P: Integer;
begin
  P:= Pos(SubStr, Copy(S, Offset, Length(S) - Offset + 1));
  if P > 0 then
    Result:= P + Offset - 1
  else
    Result:= 0;
end;

function ExtractArhive(const ArhiveFile, Output: string): boolean;
var
  Cmd: string;
  Path: string;
begin
  Path:= ExtractFilePath(ParamStr(0));
  Cmd := Format(Path + '7z.exe x "%s" -o"%s" -y', [ArhiveFile, Path + Output]);
  Result:= WinExec(PChar(Cmd), 0) <> 0;
end;

function SetAutoRun(Enable: Boolean): Boolean;
var
  Reg: TRegistry;
begin
  Result:= False;

  Reg:= TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      try
        if Enable then
        begin
          Reg.WriteString(AppName, ParamStr(0));
        end
        else
        begin
          if Reg.ValueExists(AppName) then
            Reg.DeleteValue(AppName);
        end;
      finally
        Reg.CloseKey;
      end;
      Result:= True;
    end;
  except
  end;
  Reg.Free;
end;

procedure ExtractUrls(const JSON: string; Urls: TStringList);
var
  PosStart, PosEnd: Integer;
  SearchStr: string;
begin
  Urls.Clear;
  SearchStr:= '"browser_download_url":';

  PosStart:= 1;
  while PosStart <= Length(JSON) do
  begin
    PosStart:= PosEx(SearchStr, JSON, PosStart);
    if PosStart = 0 then Break;
    Inc(PosStart, Length(SearchStr));

    while (PosStart <= Length(JSON)) and (JSON[PosStart] in [' ', #9, ':']) do
      Inc(PosStart);

    if (PosStart > Length(JSON)) or (JSON[PosStart] <> '"') then
    begin
      PosStart:= PosStart + 1;
      Continue;
    end;

    Inc(PosStart);
    PosEnd:= PosEx('"', JSON, PosStart);
    while (PosEnd > PosStart) and (PosEnd > 1) and (JSON[PosEnd - 1] = '\') do
    begin
      PosEnd:= PosEx('"', JSON, PosEnd + 1);
      if PosEnd = 0 then Break;
    end;

    if (PosEnd = 0) or (PosEnd <= PosStart) then Break;
    Urls.Add(Copy(JSON, PosStart, PosEnd - PosStart));
    PosStart:= PosEnd + 1;
  end;
end;

end.

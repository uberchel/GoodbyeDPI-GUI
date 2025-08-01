unit Tray;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, ShellApi ,Menus ,ExtDlgs ,ExtCtrls;
  
const
  WM_NOTIFYICON = WM_USER+1;

var
   MyNotifyIconData:TNotifyIconData;
   hPopupM:Hmenu;
   hMainWnd:HWND;

type
  TTray = class(TComponent)
  private
	  FPopup:TPopupMenu;
	  FHint:String;
	  FImage: TPicture;
	  procedure SetImage(Value: TPicture);
	  procedure TrayMsgHandler(var Message: TMessage); message WM_NOTIFYICON;
	  protected
  public
	   function Active(Visible:Boolean):Boolean;
	   function DeActive:Boolean;
	   destructor Destroy; override;
	   procedure PopupShow;
  published
	   constructor Create(aowner:Tcomponent);override;
	   property  PopupMenu :TPopupMenu read FPopup write FPopup;
	   property  Image:TPicture read FImage  write SetImage;
	   property  Hint:String read FHint write FHint;
  end;


implementation

destructor TTray.Destroy;
begin
 FImage.Free;
 Inherited
end;

constructor Ttray.Create(aowner:Tcomponent);
begin
  inherited Create(aowner);
  FImage:=TPicture.Create;
  
  if Owner is TWinControl then 
	hMainWnd:=(Owner as TWinControl).Handle;
end;


function Ttray.Active(Visible:boolean):boolean;
 begin
   With MyNotifyIconData do
 begin
   CbSize:=SizeOf(MyNotifyIconData);
   {$D-}
   Wnd := AllocateHWnd(TrayMsgHandler);
   Uid:=0;
   uFlags:= NIF_MESSAGE or NIF_ICON or NIF_TIP;
   uCallbackMessage:=WM_NOTIFYICON;
   if Assigned(FImage)then  
	 HIcon:=FImage.Icon.Handle
   else  
     HIcon:=LoadIcon(Hinstance,'MAINICON');
   
   lstrcpyn(SzTip,PChar(FHint),length(FHint) +1);
 end;
   Result:=Shell_NotifyIcon(NIM_ADD, @MyNotifyIconData);
   if (result=True)and(Visible <> False) then
	(Owner as TWinControl).visible:=False;
	
   Active:=Result;
end;

function Ttray.DeActive;
begin
  Result:=Shell_NotifyIcon(NIM_DELETE,@MyNotifyIconData);
  if Result then 
	(Owner as TWinControl).visible:=True;
	
  DeActive:=Result;
end;

procedure TTray.SetImage(Value: TPicture);
begin
 FImage.Assign(Value);
end;

procedure TTray.PopupShow;
var
 CursorPos:TPoint;
begin
  if Assigned(FPopup)then
  begin
    GetCursorPos(CursorPos);
    SetForegroundWindow(hMainWnd);
    Fpopup.Popup(CursorPos.x,CursorPos.y);
    PostMessage(hMainWnd,WM_USER,0,0);
  end;
end;

procedure TTray.TrayMsgHandler(var Message: TMessage);
begin
   case Message.lParam of
     WM_MOUSEMOVE:;
     WM_LBUTTONDOWN:;
     WM_LBUTTONUP:;
    // WM_LBUTTONDBLCLK:DeActive;
     WM_RBUTTONDOWN:PopupShow;
     WM_RBUTTONUP:;
     WM_RBUTTONDBLCLK:;
   end;
end;

end.

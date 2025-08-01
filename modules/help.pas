unit help;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls;

type
  TForm2 = class(TForm)
    redt1: TRichEdit;
    pnl1: TPanel;
    btn1: TButton;
    btn2: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
 uses
  ShellApi, main;

{$R *.dfm}

procedure TForm2.btn1Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar(DPI_URL), nil,nil, 2);
end;

procedure TForm2.btn2Click(Sender: TObject);
begin
 ShellExecute(Application.Handle, 'open', PChar(GUI_URL), nil,nil, 2);
end;

end.

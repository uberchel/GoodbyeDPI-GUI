unit update;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm3 = class(TForm)
    grp1: TGroupBox;
    cbb1: TComboBox;
    grp2: TGroupBox;
    lst1: TListBox;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    procedure btn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses
  main;

{$R *.dfm}

procedure TForm3.btn2Click(Sender: TObject);
begin
  //
end;

end.

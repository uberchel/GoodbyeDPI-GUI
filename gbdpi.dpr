program gbdpi;

uses
  Forms,
  main in 'modules\main.pas' {Form1},
  help in 'modules\help.pas' {Form2},
  update in 'modules\update.pas' {Form3},
  Tray in 'modules\Tray.pas',
  Utils in 'modules\Utils.pas';

{$R 'res\manifest.RES'}
{$R 'res\gbdpi.res'}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.ShowMainForm:= false;
  Application.Run;
end.

program SoundC;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  AutoRun in 'AutoRun.pas',
  route_form in 'route_form.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'SoundC';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

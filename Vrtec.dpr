program Vrtec;

uses
  Forms,
  VrtecForm in 'VrtecForm.pas' {Form1},
  jvShape in 'jvShape.pas',
  VrtecConst in 'VrtecConst.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

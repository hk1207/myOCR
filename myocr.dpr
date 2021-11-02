program myocr;

uses
  Vcl.Forms,
  ocrwork1 in 'ocrwork1.pas' {frmMain},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Lavender Classico');
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

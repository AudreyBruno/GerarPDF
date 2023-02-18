program GerarPDF;

uses
  System.StartUpCopy,
  FMX.Forms,
  untGerarPDF in 'untGerarPDF.pas' {frmGerarPDF},
  uPermissions in 'Units\uPermissions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmGerarPDF, frmGerarPDF);
  Application.Run;
end.
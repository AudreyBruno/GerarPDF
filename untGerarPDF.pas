unit untGerarPDF;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, System.IOUtils, FMX.surfaces

  {$IFDEF ANDROID}
    ,
    Androidapi.Jni.Net, Androidapi.JNI.Os, Androidapi.JNI.GraphicsContentViewText,
    Androidapi.JNI.JavaTypes, Androidapi.Helpers, FMX.Helpers.android, System.Permissions
  {$ENDIF}

  ;

type
  TfrmGerarPDF = class(TForm)
    btnGerarPDF: TButton;
    Image1: TImage;
    procedure btnGerarPDFClick(Sender: TObject);
  private
    procedure GerarPDF;
    function FileNameToUri(const FileName: string): Jnet_Uri;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGerarPDF: TfrmGerarPDF;

implementation

{$R *.fmx}

uses uPermissions;

function TfrmGerarPDF.FileNameToUri(const FileName: string): Jnet_Uri;
var
  JavaFile: JFile;
begin
  JavaFile := TJFile.JavaClass.init(StringToJString(FileName));
  Result := TJnet_Uri.JavaClass.fromFile(JavaFile);
end;

procedure TfrmGerarPDF.GerarPDF;
var
  Document: JPdfDocument;
  PageInfo: JPdfDocument_PageInfo;
  Page: JPdfDocument_Page;
  Canvas: JCanvas;
  Paint: JPaint;
  Recto: JRect;
  Rect: JRect;
  FileName: string;
  OutputStream: JFileOutputStream;
  NativeBitmap: JBitmap;
  sBitMap: TBitmapSurface;
  URIArquivo: JParcelable;
  JArq : JFile;
  Intent: JIntent;
begin
  //Caminho do arquivo
  FileName := TPath.Combine(TPath.GetSharedDocumentsPath, 'Contrato.pdf');

  //Verifica se o arquivo existe se sim deleta ele
  if FileExists(FileName) then
    DeleteFile(FileName);

  //Cria o documento PDF
  Document := TJPdfDocument.JavaClass.Init;

  try
    //Cria Pagina 1
    PageInfo := TJPageInfo_Builder.JavaClass.init(595, 842, 1).Create;
    Page := Document.StartPage(PageInfo);

    Canvas := Page.GetCanvas;
    Paint := TJPaint.JavaClass.Init;

    Paint.SetARGB($FF, 0, 0, $FF);
    Canvas.DrawText(StringToJString('Página 1'), 10, 50, Paint);
    Canvas.DrawText(StringToJString('Página 2'), 20, 40, Paint);
    Canvas.DrawText(StringToJString('Página 3'), 30, 30, Paint);
    Canvas.DrawText(StringToJString('Página 4'), 40, 20, Paint);
    Canvas.DrawText(StringToJString('Página 5'), 50, 10, Paint);

    //Finaliza a pagina 1
    Document.FinishPage(Page);

    //Cria Pagina 1
    PageInfo := TJPageInfo_Builder.JavaClass.init(595, 842, 2).create;
    Page := Document.startPage(PageInfo);

    Canvas := Page.GetCanvas;
    Paint := TJPaint.JavaClass.Init;

    Paint.SetARGB($FF, $FF, 0, 0);
    Canvas.DrawLine(10, 10, 90, 10, Paint);

    Paint.SetStrokeWidth(1);
    Paint.SetARGB($FF, 0, $FF, 0);
    Canvas.DrawLine(10, 20, 90, 20, Paint);

    Paint.SetStrokeWidth(2);
    Paint.SetARGB($FF, 0, 0, $FF);
    Canvas.DrawLine(10, 30, 90, 30, Paint);

    Paint.SetARGB($FF, $FF, $FF, 0);
    Canvas.DrawRect(10, 40, 90, 60, Paint);

    Rect := TJRect.JavaClass.Init;
    Rect.&set(15, 50, 65, 100);
    Recto := TJRect.JavaClass.Init;
    Recto.&set(0, 0, Image1.Bitmap.Width, Image1.Bitmap.Height);
    Paint.setARGB($FF, $FF, 0, $FF);

    NativeBitmap := TJBitmap.JavaClass.createBitmap(Image1.Bitmap.Width, Image1.Bitmap.Height, TJBitmap_Config.JavaClass.ARGB_8888);
    sBitMap := TBitmapSurface.Create;
    sBitMap.Assign(Image1.Bitmap);
    SurfaceToJBitmap(sBitMap, NativeBitmap);

    Canvas.DrawBitmap(NativeBitmap, Recto, Rect, Paint);

    //Finaliza a pagina 2
    Document.FinishPage(Page);


    //Salva o arquivo PDF
    OutputStream := TJFileOutputStream.JavaClass.Init(StringToJString(FileName));

    //Verifica se o arquivo existe para abrilo
    if NOT FileExists(FileName) then
      ShowMessage('Arquivo não encontrado: ' + FileName)
    else
      begin
        JArq := TJFile.JavaClass.init(StringToJString(FileName));
        Intent := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_VIEW);
        Intent.setDataAndType(TAndroidHelper.JFileToJURI(JArq), StringToJString('application/pdf'));
        Intent.setFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
        TAndroidHelper.Activity.startActivity(Intent);
      end;

    try
      Document.WriteTo(OutputStream);
    finally
      OutputStream.Close;
    end;

  finally
    Document.close;
  end;
end;

procedure TfrmGerarPDF.btnGerarPDFClick(Sender: TObject);
var
  message: string;
begin
  message := 'Não foi possível gerar o PDF porque o aplicativo não tem permissão para acessar os arquivos' +
  ' necessários. Por favor, verifique e conceda a permissão de acesso aos arquivos nas configurações do aplicativo' +
  ' para que ele possa criar o PDF com sucesso.';
  RequestPermissions(GerarPDF, message);
end;

end.

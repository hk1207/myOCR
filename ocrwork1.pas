unit ocrwork1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RtOcr, Vcl.ComCtrls, Vcl.FileCtrl, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, hyiedefs, hyieutils, iexBitmaps, iesettings, iexLayers, iexRulers, iexToolbars,
  iexUserInteractions, imageenio, imageenproc, ieview, imageenview,
  ComObj, Math, Jpeg, GIFImg, PngImage, Vcl.ExtDlgs, iemio, iemview;

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FileListBox1: TFileListBox;
    pcon1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    RtOcr: TRtOcr;
    SpeedButton1: TSpeedButton;
    AllText: TMemo;
    MemoText: TMemo;
    ComboBoxLanguages: TComboBox;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SaveTextFileDialog1: TSaveTextFileDialog;
    mmview: TImageEnMView;
    pcon2: TPageControl;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    imview: TImageEnView;
    pmview: TImageEnView;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure RtOcrCompleted(Sender: TObject; const Result: TResult; CustomData: Pointer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure pmviewImageLoaded(Sender: TObject);
    procedure mmviewSelectionChanged(Sender: TObject);
    procedure mmviewImageSelect(Sender: TObject; idx: Integer);
  private
    { Private declarations }
    Languages: TLanguages;
    FPdf: boolean;
    FAll: boolean;
    FAllIng: boolean;
    FError: integer;
    FIndex: integer;
    procedure ocrCheck;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation
uses userproc;
{$R *.dfm}

function Translate(const Point: TPoint; Delta: TPoint): TPoint;
begin
  Result.X := Point.X + Delta.X;
  Result.Y := Point.Y + Delta.Y;
end;

function Rotate(const Point: TPoint; Angle: Double): TPoint;
begin
  Result.X := Round(Point.X * Cos(Angle) - Point.Y * Sin(Angle));
  Result.Y := Round(Point.X * Sin(Angle) + Point.Y * Cos(Angle));
end;

procedure Draw(Canvas: TCanvas; const ARect: TSRect; Angle: Double; Center: TPoint);
var
  Points: array of TPoint;
  I: Integer;
begin
  SetLength(Points, 5);

  Points[0].X := Round(ARect.X);
  Points[0].Y := Round(ARect.Y);

  Points[1].X := Round(ARect.X + ARect.Width);
  Points[1].Y := Round(ARect.Y);

  Points[2].X := Round(ARect.X + ARect.Width);
  Points[2].Y := Round(ARect.Y + ARect.Height);

  Points[3].X := Round(ARect.X);
  Points[3].Y := Round(ARect.Y + ARect.Height);

  Points[4].X := Points[0].X;
  Points[4].Y := Points[0].Y;

  if Angle <> 0.0 then
    for I := 0 to Length(Points) - 1 do
    begin
      Points[I] := Translate(Points[I], Point(-Center.X, -Center.Y));
      Points[I] := Rotate(Points[I], Angle);
      Points[I] := Translate(Points[I], Point(Center.X, Center.Y));
    end;
  Canvas.Polyline(Points);
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  MemoText.Clear;
  AllText.Clear;
  FileListBox1Click(FileListBox1);
end;

procedure TfrmMain.SpeedButton2Click(Sender: TObject);
var
  i,j:word;
  cfile: string;
begin
  MemoText.Clear;
  AllText.Clear;
  if pcon2.ActivePageIndex = 0 then
  begin
    if FileListBox1.Count > 0 then
    begin
      ProgressBar1.Max := FileListBox1.Count;
      ProgressBar1.Position := 0;
      cfile := DirectoryListBox1.Directory + '\' + FileListBox1.Items[0];
      Label1.Caption := cfile;
      imview.IO.LoadFromFile(cfile);
      imview.fit;
      imview.update;
      if ComboBoxLanguages.ItemIndex >= 0 then
      begin
        FIndex  := 0;
        FAllIng := true;
        FAll    := true;
        RtOcr.Picture.Assign(imview.Bitmap);
        RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
      end;
      (*for I := 0 to FileListBox1.Count-1 do
      begin
        try
          cfile := DirectoryListBox1.Directory + '\' + FileListBox1.Items[i];
          Label1.Caption := cfile;
          imview.IO.LoadFromFile(cfile);
          imview.fit;
          imview.update;
          if ComboBoxLanguages.ItemIndex >= 0 then
          begin
            RtOcr.Picture.Assign(imview.Bitmap);
            RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
          end;
        except
          Label1.Caption := 'Error';
        end;
      end;*)
    end;
  end else
  begin
    if mmview.ImageCount > 0 then
    begin
      ProgressBar1.Max := mmview.ImageCount;
      ProgressBar1.Position := 0;
      cfile := 'PDF Pages: 1';
      Label1.Caption := cfile;
      imview.IEBitmap.Assign(mmview.GetTIEBitmap(0));
      imview.fit;
      imview.update;
      mmview.SelectedImage := 0;
      if ComboBoxLanguages.ItemIndex >= 0 then
      begin
        FIndex  := 0;
        FAllIng := true;
        FAll    := true;
        RtOcr.Picture.Assign(imview.Bitmap);
        RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
      end;
    end;
  end;
end;

procedure TfrmMain.SpeedButton3Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.SpeedButton4Click(Sender: TObject);
begin
  FAll := false;
  FAllIng := false;
  Label1.Caption := 'Canceled';
  ProgressBar1.Position := 0;
end;

procedure TfrmMain.SpeedButton5Click(Sender: TObject);
begin
  if SaveTextFileDialog1.Execute then
  begin
    AllText.Lines.SaveToFile(SaveTextFileDialog1.FileName);
  end;
end;

procedure TfrmMain.FileListBox1Click(Sender: TObject);
var
  cfile,cext:string;
  i:word;
begin
  FAll := false;
  FPDf := false;
  Label1.Caption := FileListBox1.FileName;
  cExt := uppercase(ExtractFileExt(FileListBox1.FileName));
  if copy(cExt,2,1) = 'P' then
  begin
    pcon2.ActivePageIndex := 1;
    mmview.Clear;
    mmview.Visible := true;
    fPDf := true;
    pmview.PdfViewer.Enabled   := True;
    mmview.AttachedImageEnView := pmview;
    pmview.IO.LoadFromFile(FileListBox1.FileName);
    if mmview.ImageCount > 0 then
    begin
      imview.IEBitmap.Assign(mmview.GetTIEBitmap(0));
      imview.fit;
      imview.update;
      RtOcr.Picture.Assign(imview.Bitmap);
      if ComboBoxLanguages.ItemIndex >= 0 then
         RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
    end;
  end else
  begin
    pcon2.ActivePageIndex := 0;
    mmview.Visible := false;
    mmview.Clear;
    imview.clear;
    imview.IO.LoadFromFile(FileListBox1.FileName);
    imview.fit;
    imview.update;
    RtOcr.Picture.Assign(imview.Bitmap);
    if ComboBoxLanguages.ItemIndex >= 0 then
       RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Languages := RtOcr.AvailableLanguages;
  for I := 0 to Length(Languages) - 1 do
      ComboBoxLanguages.Items.Add(Languages[I].DisplayName);
  ComboBoxLanguages.ItemIndex := 1;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  pcon1.ActivePageIndex := 0;
  pcon2.ActivePageIndex := 0;
  pcon2.Pages[0].TabVisible := false;
  pcon2.Pages[1].TabVisible := false;
  mmview.Visible := false;
  pmview.PdfViewer.Enabled   := True;
  mmview.AttachedImageEnView := pmview;
end;

procedure TfrmMain.mmviewImageSelect(Sender: TObject; idx: Integer);
begin
 // pmView.PdfViewer.PageIndex := idx;
 screen.Cursor := crHourGlass;
 try
   imview.IEBitmap.Assign(mmview.GetTIEBitmap(idx));
   RtOcr.Picture.Assign(imview.Bitmap);
   RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
 finally
   screen.Cursor := crDefault;
 end;
   exit;
  //----------------------
  TThread.CreateAnonymousThread(
    procedure
    begin
      RtOcr.Picture.Assign(imview.Bitmap);
      RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
     end).Start;
end;

procedure TfrmMain.mmviewSelectionChanged(Sender: TObject);
begin
//  if mmView.LockUpdateCount = 0 then // Avoid programmatic selections
//  begin
//    pmView.PdfViewer.PageIndex := mmView.SelectedImage;
//    imview.IEBitmap.Assign(mmview.GetTIEBitmap(mmview.SelectedImage));
//  end;
end;

procedure TfrmMain.ocrCheck;
begin

end;

procedure TfrmMain.pmviewImageLoaded(Sender: TObject);
begin
  //if FPdf then
  //begin
    mmview.SelectedImage := imview.PdfViewer.PageIndex;
  //end;
end;

procedure TfrmMain.RtOcrCompleted(Sender: TObject; const Result: TResult; CustomData: Pointer);
var
  I, J: Integer;
  Angle: Double;
  Center: TPoint;
  cfile: string;
  bCont:  boolean;
begin
  if Result.Status = stError then
  begin
    inc(FError);
    label1.Caption := 'OCR error: ' + Ferror.ToString;
  end
  else if Result.Status = stCompleted then
  begin
    MemoText.Clear;
    AllText.Lines.Add(' ');
    for I := 0 to Length(Result.Lines) - 1 do
    begin
       MemoText.Lines.Add(Result.Lines[I].Text + #13);
       AllText.Lines.Add(Result.Lines[I].Text + #13);
    end;
    if FAll then
    begin
      inc(FIndex);
      ProgressBar1.Position := FIndex;
      bCont := false;
      if not FPdf then
      begin
        if FIndex < FileListBox1.Count then
        begin
          cfile := DirectoryListBox1.Directory + '\' + FileListBox1.Items[FIndex];
          Label1.Caption := cfile;
          imview.IO.LoadFromFile(cfile);
          bCont := true;
        end;
      end else
      begin
        if FIndex < mmview.ImageCount then
        begin
          mmview.SelectedImage := FIndex;
          pmView.PdfViewer.PageIndex := mmView.SelectedImage;
          cfile := 'PDF Pages: ' + inttostr(FIndex);
          Label1.Caption := cfile;
          imview.IEBitmap.Assign(mmview.GetTIEBitmap(FIndex));
          bCont := true;
        end;
      end;
      //-----------------------------------------------
      if bCont then
      begin
        imview.fit;
        imview.update;
        if ComboBoxLanguages.ItemIndex >= 0 then
        begin
          RtOcr.Picture.Assign(imview.Bitmap);
          TThread.CreateAnonymousThread(
            procedure
            begin
              RtOcr.Recognize(Languages[ComboBoxLanguages.ItemIndex]);
            end).Start;
        end;
      end else
      begin
        FAll    := false;
        FAlling := false;
        ProgressBar1.Position := 0;
      end;
    end;
    {ImageWords.Picture.Bitmap.Assign(Image.Picture.Graphic);
    ImageWords.Picture.Bitmap.PixelFormat := pf32bit;
    ImageWords.Canvas.Pen.Color := TColor($7FFF00);

    Angle := DegToRad(Result.TextAngle);
    Center.X := ImageWords.Width div 2;
    Center.Y := ImageWords.Height div 2;

    for I := 0 to Length(Result.Lines) - 1 do
      with Result.Lines[I] do
        for J := 0 to Length(Words) - 1 do
          Draw(ImageWords.Canvas, Words[J].Rect, Angle, Center);}
  end;
end;

end.

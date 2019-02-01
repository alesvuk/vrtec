unit VrtecForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MPlayer, ComCtrls, StdCtrls, Math, ExtCtrls, jvShape, VrtecConst,
  jpeg, Menus;


type
  // sRazno: razne slike in zvoki (klovn-smeh, avto-brmbrm ...)
  TSection = (sLiki, sBarve, sZivali, sCrke, sFilmi, sText, sRazno);

const
  SectionArray: array [TSection] of AnsiString =
  ('Liki', 'Barve', 'Zivali', 'Crke', 'Filmi', 'Text', 'Razno');

type
  TWay = (wUp, wDown);

  TForm1 = class(TForm)
    mPlay: TMediaPlayer;
    StatusBar1: TStatusBar;
    lCrka: TLabel;
    ColorBox1: TColorBox;
    Label1: TLabel;
    sShape: TShape;
    iImage: TImage;
    MainMenu1: TMainMenu;
    miZvok: TMenuItem;
    miPiskanje: TMenuItem;
    miGlasovi: TMenuItem;
    cbZivali: TComboBox;
    cbRazno: TComboBox;
    miShowSection: TMenuItem;
    miProperties: TMenuItem;
    miLoop: TMenuItem;
    miSection: TMenuItem;
    cbFilmi: TComboBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure miPiskanjeClick(Sender: TObject);
    procedure miGlasoviClick(Sender: TObject);
    procedure cbZivaliChange(Sender: TObject);
    procedure cbRaznoChange(Sender: TObject);
    procedure cbFilmiChange(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mPlayNotify(Sender: TObject);
  private
    FSection: TSection;
    FTextStr: AnsiString;
    FLetter: TLabel;
    FShape: TjvShape;
    FShapeIndex: integer;
    FColorIndex: integer;
    FImage: TImage;
    FKeyPressCount: integer;
    FAnimalIndex: integer;
    FPiskanje: boolean;
    FGlasovi: boolean;
    FShowMovieCount: integer;
    procedure ChangeSection;
    procedure ChangeTextColor(Way: TWay);
    procedure ChangeFont(Way: TWay);
    procedure ChangeShape(Way: TWay);
    function GetRandPos(Ctrl: TControl): TRect;
    function GetRandColor: TColor;
    procedure Play(FileName: AnsiString);
    procedure Stop;
    { Private declarations }
  public
    { Public declarations }
    procedure ShowShape(Key: char);
    procedure ShowColor(Key: char);
    procedure ShowAnimal(Key: char);
    procedure ShowLetter(Key: char);
    procedure ShowMovie(Key: char);
    procedure ShowRazno(Key: char);
    procedure StartText;
    procedure ShowText(Key: char);
    procedure ShowSpecial(Key: word);
  end;

var
  Form1: TForm1;

implementation

uses Types;

{$R *.dfm}
procedure TForm1.Stop;
begin
  try
    if mPlay.Mode in [mpOpen, mpPlaying] then begin
      mPlay.Stop;
      mPlay.Close;
    end;
  except
  end;
end;

procedure TForm1.Play(FileName: AnsiString);
var FileExt: AnsiString;
  Dx, Dy: integer;
  Rect: TRect;
label Ponovi;
begin
  if not FGlasovi then Exit;
Ponovi:
  FileExt := ExtractFileExt(FileName);
  if not FileExists(FileName) then begin
    if FileExt = '' then begin
      FileName := ChangeFileExt(FileName, '.mp3');
      if not FileExists(FileName) then Goto Ponovi
    end;
    if FileExt = '.mp3' then FileName := ChangeFileExt(FileName, '.wav');
    if (FileExt = '.wav') then FileName := ChangeFileExt(FileName, '.mp3');
  end;
  if FileExists(FileName) then begin
    mPlay.Display := nil;
    if FileExt = '.mpg' then
      mPlay.Display := Self;
    mPlay.FileName := FileName;
    mPlay.Wait := True;
    mPlay.Open;
    if FileExt = '.mpg' then begin
      Rect := mPlay.DisplayRect;
      OffsetRect(Rect, 10, 25);
      mPlay.DisplayRect := Rect;
    end;
    FPiskanje := False;
    mPlay.Play;
  end;
end;

procedure TForm1.ChangeFont(Way: TWay);
begin
  if FLetter = nil then Exit;
  case Way of
    wDown: begin
      FLetter.Font.Size := FLetter.Font.Size - 2;
      if FLetter.Font.Size <= 20 then FLetter.Font.Size := 20;
    end;
    wUp: begin
      FLetter.Font.Size := FLetter.Font.Size + 2;
      if FLetter.Font.Size >= lCrka.Font.Size * 2 then FLetter.Font.Size := lCrka.Font.Size *2;
    end;
  end;
end;

procedure TForm1.ChangeTextColor(Way: TWay);
begin
  case Way of
    wUp: begin
      if ColorBox1.ItemIndex = 0 then
        ColorBox1.ItemIndex := ColorBox1.Items.Count - 1
      else
        ColorBox1.ItemIndex := ColorBox1.ItemIndex - 1;

    end;
    wDown: begin
      if ColorBox1.ItemIndex = ColorBox1.Items.Count - 1 then
        ColorBox1.ItemIndex := 0
      else
        ColorBox1.ItemIndex := ColorBox1.ItemIndex + 1;
    end;
  end;
  if FLetter <> nil then
    FLetter.Font.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  if FShape <> nil then
    FShape.Brush.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
end;

function TForm1.GetRandPos(Ctrl: TControl): TRect;
var Top, Left: integer;
begin
  Result := Ctrl.BoundsRect;
  Top := RandomRange(0, Form1.ClientHeight - (Ctrl.ClientHeight+20));
  Left := RandomRange(0, Form1.ClientWidth - (Ctrl.ClientWidth+20));
  Result.Top := Top;
  Result.Left := Left;
  Result.Bottom := Result.Top + Ctrl.ClientHeight;
  Result.Right := Result.Left + Ctrl.ClientWidth;
end;

function TForm1.GetRandColor: TColor;
var Index: integer;
begin
  Index := RandomRange(0, ColorBox1.Items.Count-1 );
  ColorBox1.ItemIndex := Index;
  Result := ColorBox1.Colors[Index];
end;


procedure TForm1.ChangeShape(Way: TWay);
var tmpShape: TjvShapeType;
begin
  if FShape = nil then Exit;
  tmpShape := FShape.Shape;
  case Way of
    wUp: begin
      if FShape.Shape = jstRectangle then
        tmpShape := jstflower
      else
        Dec(tmpShape);
    end;
    wDown: begin
      if FShape.Shape = jstflower then
        tmpShape := jstRectangle
      else
        Inc(tmpShape);
    end;
  end;
  FShape.Shape := tmpShape;
end;

procedure TForm1.ShowShape(Key: Char);
var VoiceName: AnsiString;
  i: integer;
begin
  if FShape = nil then FShape := TjvShape.Create(Self);
  FShape.Visible := True;
  FShape.BoundsRect := GetRandPos(sShape);
  FShape.Brush.Color := GetRandColor;
  FShape.Pen.Width := 5;
  FShape.Pen.Color := clBlack;

  FShape.Shape := ShapeArray[FShapeIndex].Type_;
  FShape.Parent := Self;

  VoiceName := ShapeArray[FShapeIndex].Voice;
  if FShapeIndex = High(ShapeArray) then
    FShapeIndex := Low(ShapeArray)
  else
    Inc(FShapeIndex);

  Play(PathLiki + VoiceName + '.mp3');
end;

procedure TForm1.ShowColor(Key: Char);
var VoiceName: AnsiString;
begin
  Form1.Color := ColorArray[FColorIndex].Color;
  VoiceName := ColorArray[FColorIndex].Voice;
  if FColorIndex = High(ColorArray) then
    FColorIndex := Low(ColorArray)
  else
    Inc(FColorIndex);
  Play(PathBarve + VoiceName + '.mp3');
end;

procedure TForm1.ShowAnimal(Key: Char);
var index: integer;
  FileName: AnsiString;
  Value: AnsiString;
begin
  if AnimalArray.Count = 0 then begin
    FKeyPressCount := 10;
    Exit;
  end;
  if FImage = nil then FImage := TImage.Create(Self);
  FImage.Visible := True;
  FImage.BoundsRect := GetRandPos(sShape);
  FImage.Transparent := True;
  FImage.Stretch := True;
  // Change from aray of used item to current array
  if AnimalArray.Count = 0 then begin
    AnimalArray.Assign(UsedAnimalArray);
    UsedAnimalArray.Clear;
  end;
  index := RandomRange(0, AnimalArray.Count);
  Value := AnimalArray[index];
  UsedAnimalArray.Add(AnimalArray[index]);
  AnimalArray.Delete(index);

  cbZivali.ItemIndex := cbZivali.Items.IndexOf(Value);
  FileName := PathZivali + Value + '.jpg';
  if FileExists(FileName) then
    FImage.Picture.LoadFromFile(FileName);
  FImage.Parent := Self;
  Play(PathZivali + Value);
end;

procedure TForm1.ShowLetter(Key: Char);
var VoiceName: AnsiString;
  i: integer;
begin
  if FLetter <> nil then FLetter.Visible := False;

  FLetter := TLabel.Create(Self);
  FLetter.Font := lCrka.Font;
  FLetter.Font.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  FLetter.Transparent := True;
  FLetter.BoundsRect := GetRandPos(lCrka);
  FLetter.Caption := UpperCase(Key);
  FLetter.Parent := Self;

  VoiceName := UpperCase(Key);
  try
//    VoiceName := PChar(LetterArray.Data[Pointer(Key)]);
  except
  end;

  Play(PathCrke + VoiceName + '.mp3');
end;

procedure TForm1.ShowMovie(Key: Char);
var Value, FileName: AnsiString;
begin
  if FilmiArray.Count = 0 then Exit;
  if FShowMovieCount = FilmiArray.Count then begin
    FKeyPressCount := 10;
    FShowMovieCount := 0;
    Exit;
  end;
  Value := FilmiArray[0];
  FilmiArray.Move(0, FilmiArray.Count-1);
  Inc(FShowMovieCount);
  Play(PathFilmi + Value + '.mpg');
end;

procedure TForm1.ShowRazno(Key: char);
var index: integer;
  FileName: AnsiString;
  Value: AnsiString;
begin
  if RaznoArray.Count = 0 then begin
    FKeyPressCount := 10;
    Exit;
  end;
  if FImage = nil then FImage := TImage.Create(Self);
  FImage.Visible := True;
  FImage.BoundsRect := GetRandPos(sShape);
  FImage.Transparent := True;
  FImage.Stretch := True;
  // Change from aray of used item to current array
  if RaznoArray.Count = 0 then begin
    RaznoArray.Assign(UsedRaznoArray);
    UsedRaznoArray.Clear;
  end;
  index := RandomRange(0, RaznoArray.Count);
  Value := RaznoArray[index];
  UsedRaznoArray.Add(RaznoArray[index]);
  RaznoArray.Delete(index);

  cbRazno.ItemIndex := cbRazno.Items.IndexOf(Value);
  FileName := PathRazno + Value + '.jpg';
  if FileExists(FileName) then
    FImage.Picture.LoadFromFile(FileName);
  FImage.Parent := Self;
  Play(PathRazno + Value);
end;

procedure TForm1.ShowSpecial(Key: Word);
var tmpIndex: integer;
  FileName: AnsiString;
begin
  if FImage = nil then FImage := TImage.Create(Self);
  FImage.Visible := True;
  FImage.BoundsRect := GetRandPos(sShape);
  FImage.Transparent := True;
  FImage.Stretch := True;
  FileName := '';
  try
    FileName := PathRazno + PChar(SpecialArray.Data[Pointer(Key)]) + '.jpg';
    cbRazno.ItemIndex := cbRazno.Items.IndexOf(PChar(SpecialArray.Data[Pointer(Key)]));
  except
  end;

  if FileExists(FileName) then
    FImage.Picture.LoadFromFile(FileName);
  FImage.Parent := Self;
  Play(PathRazno + PChar(SpecialArray.Data[Pointer(Key)]));
end;

procedure TForm1.StartText;
begin
  if FLetter <> nil then FLetter.Visible := False;
  FLetter := TLabel.Create(Self);
  FLetter.Parent := Self;
  FLetter.Font := lCrka.Font;
  FLetter.Font.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  FLetter.Transparent := True;
  FLetter.BoundsRect := lCrka.BoundsRect;
  FLetter.Top := (Form1.Height div 2) - (FLetter.Height div 2);
  FLetter.Left := 0;
  FLetter.Caption := '';
end;

procedure TForm1.ShowText(Key: Char);
begin
  Play(PathCrke + UpperCase(Key) + '.mp3');
  FLetter.Caption := FLetter.Caption + UpperCase(Key);
end;

procedure TForm1.ChangeSection;
begin
  if FSection = High(FSection) then  begin
  // loop on fist section
    FSection := Low(FSection);
    if Assigned(FLetter) then
      FLetter.Visible := False;
    if Assigned(FShape) then
      FShape.Visible := False;
    if Assigned(FImage) then
      FImage.Visible := False;
  end
  else
    Inc(FSection);
  // Skip Text section on loop
  if (FSection = sText) and (FKeyPressCount >= 10) then Inc(FSection);

  if FSection = sText then StartText;

  StatusBar1.Panels[0].Text := SectionArray[FSection];
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var tmpSection: TSection;
begin
  Stop;
  if ((Key = VK_SPACE) or (FKeyPressCount >= 10)) then begin
    tmpSection := FSection;
    ChangeSection;
    while not miShowSection.Items[Ord(FSection)].Checked do begin
      // We come thru all section and none was checked
      if tmpSection = FSection then Break;
      ChangeSection;
    end;
    Key := 0;
    FKeyPressCount := 0;
  end;
  // Windows key
  if Key = 91 then Form1.BringToFront;
  if Shift = [] then
    case Key of
      // Special show on space key
      VK_SPACE, VK_INSERT, VK_DELETE: ShowSpecial(Key);
      VK_UP: ChangeTextColor(wUp);
      VK_DOWN: ChangeTextColor(wDown);
      VK_RETURN: begin
        ShowSpecial(Key);
        Key := 0;
        StartText;
      end;
    end
  else
    case Key of
      VK_UP: case FSection of
        sCrke, sText: ChangeFont(wUp);
        sLiki: ChangeShape(wUp);
      end;
      VK_DOWN: case FSection of
        sCrke, sText: ChangeFont(wDown);
        sLiki: ChangeShape(wDown);
      end;
    end;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then ShowSpecial(VK_SPACE);
  if (Key = ' ') or (Key = Char(13)) then Exit;
  if Assigned(FImage) then
    FImage.Visible := False;
  if Assigned(FShape) then
    FShape.Visible := False;

  try
    case FSection of
      sLiki: ShowShape(Key);
      sBarve: ShowColor(Key);
      sZivali: ShowAnimal(Key);
      sCrke: ShowLetter(Key);
      sFilmi: ShowMovie(Key);
      sRazno: ShowRazno(Key);
      sText: ShowText(Key);
    end;
    if miLoop.Checked and (FSection <> sText) then Inc(FKeyPresscount);
  except
  end;
  Key := #0;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  lCrka.Visible := False;
  sShape.Visible := False;
  iImage.Visible := False;
  FSection := sRazno;
  StatusBar1.Panels[0].Text := SectionArray[FSection];
end;

procedure TForm1.FormCreate(Sender: TObject);
var i: TSection;
  tmpMenuItem: TMenuItem;
  j: integer;
  FileName: AnsiString;
begin

//  for j:= 0 to 126 do begin
//    FileName :=  PathCrke + {Format('%.3d',[j]) + '-' +}Chr(j) + '.txt';
//    CopyFile(PathCrke + '_prazen.txt', PChar(FileName), False);
//  end;

{
  for j:= Low(ColorArray) to High(ColorArray) do begin
    FileName :=  PathBarve + ColorArray[j].Voice + '.txt';
    CopyFile(PathCrke + '_prazen.txt', PChar(FileName), False);
  end;
}

{
  for j:= Low(ShapeArray) to High(ShapeArray) do begin
    FileName :=  PathLiki + ShapeArray[j].Voice + '.txt';
    CopyFile(PathCrke + '_prazen.txt', PChar(FileName), False);
  end;
}

  FShapeIndex := Low(ShapeArray);
  FColorIndex := Low(ColorArray);
  FGlasovi:= True;
  FPiskanje := True;
  for i:= Low(SectionArray) to High(SectionArray) do begin
    tmpMenuItem := TMenuItem.Create(Self);
    tmpMenuItem.Caption := SectionArray[i];
    tmpMenuItem.OnClick := miSection.OnClick;
    tmpMenuItem.Tag := Ord(i);
    tmpMenuItem.AutoCheck := miSection.AutoCheck;
    tmpMenuItem.Checked := miSection.Checked;
    miShowSection.Add(tmpMenuItem);
  end;
  miShowSection.Remove(miSection);

  for j:= 0 to RaznoArray.Count - 1 do
    cbRazno.AddItem(RaznoArray[j], nil);
  for j:= 0 to AnimalArray.Count - 1 do
    cbZivali.AddItem(AnimalArray[j], nil);
  for j:= 0 to FilmiArray.Count - 1 do
    cbFilmi.AddItem(FilmiArray[j], nil);

  Randomize;
end;

procedure TForm1.ColorBox1Change(Sender: TObject);
begin
  case FSection of
    sLiki: if Assigned(FShape) then FShape.Brush.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
    sBarve: Form1.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
    sCrke: if Assigned(FLetter) then FLetter.Font.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
    sText: if Assigned(FLetter) then FLetter.Font.Color := ColorBox1.Colors[ColorBox1.ItemIndex];
  end;
  ColorBox1.Enabled := False;
  ColorBox1.Enabled := True;
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if FPiskanje then
   Windows.Beep(100+X, 10);
 Canvas.Ellipse(X-5,y-5,x+5,y+5);
end;

procedure TForm1.miPiskanjeClick(Sender: TObject);
begin
  FPiskanje := miPiskanje.Checked;
end;

procedure TForm1.miGlasoviClick(Sender: TObject);
begin
  FGlasovi := miGlasovi.Checked;
end;

procedure TForm1.cbZivaliChange(Sender: TObject);
var FileName, Value: AnsiString;
begin
  if FImage = nil then FImage := TImage.Create(Self);
  FImage.BoundsRect := GetRandPos(sShape);
  FImage.Transparent := True;
  FImage.Stretch := True;

  Value := cbZivali.Items[cbZivali.ItemIndex];
  FileName := PathZivali + Value + '.jpg';
  if FileExists(FileName) then
    FImage.Picture.LoadFromFile(FileName);
  FImage.Parent := Self;
  Play(PathZivali + Value);

  cbZivali.Enabled := False;
  cbZivali.Enabled := True;
end;

procedure TForm1.cbRaznoChange(Sender: TObject);
var FileName, Value: AnsiString;
begin
  if FImage = nil then FImage := TImage.Create(Self);
  FImage.BoundsRect := GetRandPos(sShape);
  FImage.Transparent := True;
  FImage.Stretch := True;

  Value := cbRazno.Items[cbRazno.ItemIndex];
  FileName := PathRazno + Value + '.jpg';
  if FileExists(FileName) then
    FImage.Picture.LoadFromFile(FileName);
  FImage.Parent := Self;
  Play(PathRazno + Value);

  cbRazno.Enabled := False;
  cbRazno.Enabled := True;

end;

procedure TForm1.cbFilmiChange(Sender: TObject);
var Value: AnsiString;
begin
  Value := cbFilmi.Items[cbFilmi.ItemIndex];
  Play(PathFilmi + Value + '.mpg');

  cbFilmi.Enabled := False;
  cbFilmi.Enabled := True;
end;


procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft: ShowSpecial(VK_LBUTTON);
    mbRight:  ShowSpecial(VK_RBUTTON);
  end;
end;

procedure TForm1.mPlayNotify(Sender: TObject);
begin
  FPiskanje := True;
  OutputDebugstring(PChar('Play'));
end;

end.

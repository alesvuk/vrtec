unit VrtecConst;

interface
uses jvShape, Graphics,Contnrs, Windows, SysUtils, Classes;

type

  TShapeRec = record
    Type_: TjvShapeType;
    Voice: AnsiString;
  end;

  TCharRec = record
    Char: char;
    Voice: AnsiString;
  end;

  TColorRec = record
    Color: TColor;
    Voice: AnsiString;
  end;

  TPictureRec = record
    Name: AnsiString;
    Pic: AnsiString;
    Voice: AnsiString;
  end;

  TSpecialRec = record
    Key: Word;
    Name: AnsiString;
  end;

const

  PathBarve = '.\barve\';
  PathCrke = '.\crke\';
  PathFilmi = '.\filmi\';
  PathLiki = '.\liki\';
  PathRazno = '.\razno\';
  PathText = '.\text\';
  PathZivali = '.\zivali\';


  ColorArray: array [1..18] of TColorRec = (
   (Color: clRed; Voice: 'red'),
   (Color: clBlack; Voice: 'black'),
   (Color: clMaroon; Voice: 'maroon'),
   (Color: clGreen; Voice: 'green'),
   (Color: clOlive; Voice: 'green'),
   (Color: clNavy; Voice: 'blue'),
   (Color: clPurple; Voice: 'purple'),
   (Color: clTeal; Voice: 'teal'),
   (Color: clGray; Voice: 'gray'),
   (Color: clSilver; Voice: 'silver'),
   (Color: clRed; Voice: 'red'),
   (Color: clLime; Voice: 'lime'),
   (Color: clYellow; Voice: 'yellow'),
   (Color: clBlue; Voice: 'blue'),
   (Color: clAqua; Voice: 'blue'),
   (Color: clLtGray; Voice: 'gray'),
   (Color: clDkGray; Voice: 'gray'),
   (Color: clWhite; Voice: 'white'));

  ShapeArray: array [1..11] of TShapeRec = (
   (Type_: jstRectangle; Voice: 'Pravokotnik'),
   (Type_: jstSquare;  Voice: 'Kvadrat'),
   (Type_: jstEllipse;   Voice: 'Elipsa'),
   (Type_: jstCircle; Voice: 'Krog'),
   (Type_: jstTriangleRight; Voice: 'Trikotnik'),
   (Type_: jstTriangleUp; Voice: 'Trikotnik'),
   (Type_: jstTriangleLeft; Voice: 'Trikotnik'),
   (Type_: jstTriangleDown; Voice: 'Trikotnik'),
   (Type_: jstDiamond; Voice: 'Diamand'),
   (Type_: jstOctagon; Voice: 'Veckotnik'),
   (Type_: jstflower; Voice: 'Rozica')
   );
{
    jstCloudLeft,jstCloudRight,jstDoubleOval,jstDoubleOvalV,
    jstTorus,jstFrame,jstFrameNarrow,
    jstCubeUpRight,jstCubeUpLeft,jstCubeDownRight,jstCubeDownLeft,
    jstCubeHalf,jstRoofRight,jstRoofLeft,jstRoofFront,jstRoofBack,
    jstPyramid,jstMoret,jstZ,jstN,jstMatta,
    jstPistacheTop,jstPistacheBottom,jstPistacheLeft,jstPistacheRight,
    jst1Hole,jst1HoleBig,jstflower);
}


var
  AnimalArray: TStringList;  // include jpeg files from directory
  UsedAnimalArray: TStringList;
  RaznoArray: TStringList; // include jpeg files from directory
  UsedRaznoArray: TStringList;

  FilmiArray: TStringList;

  SpecialArray: TBucketList;
  LetterArray: TBucketList;

implementation

procedure AddSpecial(Key: word; const Name: AnsiString);
begin
  if not Assigned(SpecialArray) then
    SpecialArray := TBucketList.Create;
  SpecialArray.Add(Pointer(Key), PChar(Name));
end;

procedure AddLetter(Key: char; const Name: AnsiString);
begin
  if not Assigned(LetterArray) then
    LetterArray := TBucketList.Create;
  LetterArray.Add(Pointer(Key), PChar(Name));
end;

procedure FillList(var Buck: TStringList; Path: AnsiString);
var Data: TSearchRec;
  Pattern: AnsiString;
begin
  Pattern := '*.jpg';
  if Path = PathFilmi then Pattern := '*.mpg';

  if not Assigned(Buck) then Buck := TStringList.Create;
  if FindFirst(Path + Pattern, faArchive, Data) = 0 then
    repeat
      Buck.Add(ChangeFileExt(Data.Name, ''));
    until FindNext(Data) <> 0;
  FindClose(Data);
end;


initialization
  AddSpecial(VK_SPACE, 'dingdong');
  AddSpecial(VK_RETURN, 'cokolada');
  AddSpecial(VK_INSERT, 'nodi');
  AddSpecial(VK_DELETE, 'telebajski');
  AddSpecial(VK_LBUTTON, 'clown');
  AddSpecial(VK_RBUTTON, 'zivjo');

  AddLetter(';', 'podpicje');
  AddLetter(',', 'vejica');
  AddLetter('<', 'manjse');
  AddLetter('>', 'vecje');
  AddLetter('/', 'deljeno');
  AddLetter(':', 'dvopicje');
  AddLetter('?', 'vprasaj');
  AddLetter('-', 'minus');
  AddLetter('=', 'enako');
  AddLetter('*', 'zvezdica');
  AddLetter('+', 'plus');
  AddLetter('(', 'oklepaj');
  AddLetter(')', 'zaklepaj');
  AddLetter('.', 'pika');
  AddLetter('''', 'pika');
  AddLetter('!', 'klicaj');
  AddLetter('"', 'narekovaj');

  FillList(RaznoArray, PathRazno);
  UsedRaznoArray := TStringList.Create;

  FillList(AnimalArray, PathZivali);
  UsedAnimalArray := TStringList.Create;

  FillList(FilmiArray, PathFilmi);


finalization
  SpecialArray.Free;
  LetterArray.Free;
  RaznoArray.Free;
  UsedRaznoArray.Free;

end.

unit RtfDoc;

{
  Класс описывающий создание документов формата RTF
  Class for creating RTF document.
  }


interface

{$IFDEF FPC}
 {$MODE Delphi}
{$ENDIF} 

uses 
  SysUtils,Dialogs,LConvEncoding,RtfPars;
  
type
  TRtfDoc = class(TObject)
  private
    FParser : TRTFParser;
    procedure DoGroup;
    procedure DoCtrl;
  //  procedure DoText;
{$IFDEF FPC}
    procedure HandleError(s : ShortString);
{$ELSE}  {Delphi}
    procedure HandleError(s : string);
{$ENDIF}
  protected
    FFileName : string;
    FFileVar  : TextFile;
    i,n, nNum, nSize, nStyle, nAlign : Word;
  public
    PageHeight,PageWidth,PageMLeft,PageMRight,PageMTop,PageMBottom: Word;
    arTblWidths: array[0..100] of single;
    arTblAlign: array[0..100] of integer;
    arTblValues: array[0..100] of string;
    nColumns: integer;
    bParOpen: boolean;
    constructor Create;
    destructor Destroy; override;
    property Parser : TRTFParser read FParser;
    property FileName : string read FFileName;
    procedure Start(const FileName : string); virtual;
    procedure Done; virtual;
    procedure DefaultFontTable(DefFont: Integer); virtual;
    procedure OutToken(      AClass : Integer;
                             Major  : Integer;
                             Minor  : Integer;
                             Param  : Integer;
                       const Text   : string); virtual;
    procedure OutCtrl(Major : Integer;
                      Minor : Integer;
                      Param : Integer); virtual;
//    procedure OutText(const inText : string); virtual;
    procedure OutText(const inText : string);

    Procedure SetFont(nNum_: Word; nSize_: Word; nStyle_: Word); //установить шрифт
    procedure BeginTable(nColCount: integer; nLeftInd: integer;nAlign_: integer);//инициализация таблицы
    Procedure EndTable; //закрытие таблицы
    Procedure WriteRow;    //запись строки таблицы
    function Twips(nCm: Single):Word;    //перевод сантиметров в твипы
    procedure PageA4; //установка формата А4
    procedure PageA4landScape; //установка формата А4 альбомный
    procedure PageSetup(nHeight: Word; nWidth: Word; nMLeft: Word; nMRight: Word; nMTop: Word; nMBottom: Word; bLandscape: boolean); //установки страницы
    Procedure BeginPar(nFirstIndent: word; nLIndent: word; nAl: Word);    //начало абзаца
    Procedure EndPar;    //конец абзаца
    procedure WriteString(cText: string; Font: Word; Size: Word; Style: Word);    //вывод строки абзаца
    procedure WriteLine(nSize: Word;cLineStyle: String;nThick: Word);//рисование линии
    function RtfColSize(ColWid: integer; Wid: integer):single; //расчет ширины колонки RTF пропорционально ширине колонки в гриде
  end;


implementation


constructor TRtfDoc.Create;
begin
  inherited Create;
  FParser := TRTFParser.Create(nil);
  //флаг начала абзаца
  bParOpen := false;
  //выравнивание по умолчанию
  nAlign := rtfQuadLeft;
  //устанавливаем параметры страницы А4
  PageHeight:=Twips(21);
  PageWidth :=Twips(29.7);
  PageMLeft :=Twips(1.5);
  PageMRight:=Twips(1.5);
  PageMTop  :=Twips(2);
  PageMBottom:=Twips(2);
end;


destructor TRtfDoc.Destroy;
begin
  Parser.Free;
  //освобождаем массивы из памяти
  FreeAndNil(arTblWidths);
  FreeAndNil(arTblAlign);
  FreeAndNil(arTblValues);
  inherited Destroy;
end;


//начало абзаца
Procedure TRtfDoc.BeginPar(nFirstIndent: word; nLIndent: word; nAl: Word);
begin
     If bParOpen then  EndPar;
     OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
     //сброс настроек абзаца
     OutCtrl(rtfParAttr, rtfParDef,rtfNoParam);
     //сброс шрифта на простой
     OutCtrl(rtfCharAttr, rtfPlain,rtfNoParam);
     //выравнивание
     If nAl>0 then nAlign := nAl;
     OutCtrl(rtfParAttr, nAlign, rtfNoParam);
     //отступ первой строки
     If nFirstIndent>0 then
       OutCtrl(rtfParAttr, rtfFirstIndent, Twips(nFirstIndent));
     //отступ строки абзаца
     If nLIndent>0 then
       OutCtrl(rtfParAttr, rtfLeftIndent, Twips(nLIndent));
     bParOpen := true;
end;

//конец абзаца
procedure TRtfDoc.EndPar;
begin
     If bParOpen then
       begin
       WriteLn(FFileVar,'\par');
       bParOpen := false;
       end;
    OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
end;

//вывод строки абзаца
procedure TRtfDoc.WriteString(cText: string; Font: Word; Size: Word; Style: Word);
begin
  SetFont(Font, Size, Style);
  OutText(cText);
  OutCtrl(rtfSpecialChar, rtfPar, rtfNoParam);
  bParOpen:= false;
end;

//установка формата А4
procedure TRtfDoc.PageA4;
begin
  PageSetup(Twips(29.7),Twips(21),Twips(1.5),Twips(1.5),Twips(2),Twips(2),False);
end;

//установка формата А4
procedure TRtfDoc.PageA4LandScape;
begin
   PageSetup(Twips(21),Twips(29.7),Twips(2.5),Twips(2.5),Twips(2),Twips(2), true);
End;

//установки страницы
procedure TRtfDoc.PageSetup(nHeight: Word; nWidth: Word; nMLeft: Word; nMRight: Word; nMTop: Word; nMBottom: Word; bLandscape: boolean);
var
  sx: string;
begin
  If nHeight>0 then PageHeight:=nHeight;
  iF nWidth>0 then PageWidth:=nWidth;
  IF nMLeft>0 then PageMLeft:=nMLeft;
  If nMRight>0 then PageMRight:=nMRight;
  If nMTop>0 then PageMTop:=nMTop;
  If nMBottom>0 then PageMBottom:=nMBottom;

  sx:='\paperw'+IntToStr(PageWidth)+'\paperh'+IntToStr(PageHeight)+'\margl'+IntToStr(PageMLeft)+'\margr'+IntToStr(PageMRight)+'\margt'+IntToStr(PageMTop)+'\margb'+IntToStr(nMBottom);
  If bLandscape then sx:= sx+'\landscape';
  WriteLn(FFileVar,sx);
end;

//**   ******   установить шрифт
Procedure TRtfDoc.SetFont(nNum_: Word; nSize_: Word; nStyle_: Word);
begin                  // шрифт ,      кегль    ,  стиль
  If (nStyle_<0) OR (nSize_<0) OR (nNum_<0) then exit;
    nNum := nNum_;
    nSize := nSize_;
    nStyle := nStyle_;
    //стиль шрифта
    OutCtrl(rtfCharAttr, nStyle, 1);
    //номер шрифта (всего в RTF их 7)
    If nNum<7 then
     OutCtrl(rtfCharAttr, rtfFontNum, nNum);
    //размер шрифта
    OutCtrl(rtfCharAttr, rtfFontSize, nSize);
end;

//**********   инициализация таблицы
procedure TRtfDoc.BeginTable(nColCount: integer; nLeftInd: integer;nAlign_: integer);
var                    // количество колонок,   левый отступ,   выравнивание
   i,nAl: integer;
begin
     If nColCount<0 then exit;
     nColumns:= nColCount;
     //выравнивание
  if nAlign_ > 0 then nAl := nAlign_ else nAl :=nAlign;
   //инициализация массивов
   //устанавливаем ширину 2см по умолчанию
  For i:= 1 To nColumns do
  begin
  arTblWidths[i]:= 3;
  arTblAlign[i] := nAl;
  arTblValues[i] := '';
  end;

  //начало таблицы
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfTblAttr, rtfRowDef, rtfNoParam);
  //левый отступ
  IF nLeftInd>0 then
  OutCtrl(rtfTblAttr, rtfRowLeftEdge, nLeftInd);
end;


//*******************закрытие таблицы
Procedure TRtfDoc.EndTable;
 begin
   If nColumns<0 then exit;

   OutCtrl(rtfParAttr, rtfParDef, rtfNoParam);
   OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
   nColumns := 0;
end;

//запись строки таблицы
Procedure TRtfDoc.WriteRow;
var
   i: integer;
   nTmp : single;
begin
  If nColumns<0 then exit;
  //рисуем рамки ячеек
  nTmp := 0;
  For i:= 1 To nColumns do
  begin
  nTmp := nTmp + arTblWidths[i];
  OutCtrl(rtfTblAttr, rtfCellBordTop, rtfNoParam);
  OutCtrl(rtfParAttr, rtfBorderSingle, rtfNoParam);
  OutCtrl(rtfTblAttr, rtfCellBordLeft, rtfNoParam);
  OutCtrl(rtfParAttr, rtfBorderSingle, rtfNoParam);
  OutCtrl(rtfTblAttr, rtfCellBordRight, rtfNoParam);
  OutCtrl(rtfParAttr, rtfBorderSingle, rtfNoParam);
  OutCtrl(rtfTblAttr, rtfCellBordBottom, rtfNoParam);
  OutCtrl(rtfParAttr, rtfBorderSingle, rtfNoParam);
  OutCtrl(rtfTblAttr, rtfCellPos, Twips(nTmp));
  WriteLn(FFileVar);
  end;

  //рисуем содержимое ячеек
  OutCtrl(rtfParAttr, rtfInTable, rtfNoParam);
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
 // SetFont(nNum, nSize, nStyle);

  For i:= 1 to nColumns do
  begin
   If i > 1 then
   OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
   //значение ячейки
   OutText(trim(arTblValues[i]));
   OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
   OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
   //выравнивание
   OutCtrl(rtfParAttr, arTblAlign[i], rtfNoParam);
   //левый отступ текста от края ячейки
   OutCtrl(rtfParAttr, rtfLeftIndent, 30);
   //правый отступ текста от края ячейки
   OutCtrl(rtfParAttr, rtfRightIndent, 30);
   OutCtrl(rtfSpecialChar, rtfCell, rtfNoParam);//конец ячейки
   OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  end;
//   OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
   OutCtrl(rtfSpecialChar, rtfRow, rtfNoParam);//конец строки таблицы
//   OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
end;


//расчет ширины колонки RTF пропорционально ширине колонки в гриде
function TRtfDoc.RtfColSize(ColWid: integer; Wid: integer):single;
var                 // ширина столбца грида , ширина грида
  pageTw: integer;
  lyam: single;
  nTem,pageCm: single;//extended;
  cTem: string;
begin
     //определяем ширину столбца
        //переводим ширину страницы в см (PageWidth константа в RTFdoc)
        PageTw := PageWidth-PageMLeft-(PageMRight div 2);
        pageCm := pageTw*2.54/1440;
        //расчет размера колонок из расчета ширины грида
        //ширина колонки rtf = ширина страницы* ширина столбца грида / ширину грида
        lyam := pageCm*ColWid/Wid;
        //cTem:= FloatToStrF(lyam,ffgeneral,5,2);//в строку и отсекаем дробную часть до 2 знаков после запятой
        Result := lyam;
end;


//рисование линии
procedure TRtfDoc.WriteLine(nSize: Word;cLineStyle: String;nThick: Word);//длина линии, тип, толщина
//  \dplinesolid \dplinehollow \dplinedash  \dplinedot  \dplinedado  \dplinedadodo
var
   ss: string;
begin
  ss:='{\pard {\*\do\dobxcolumn\dobypara\dodhgt\dpline\dpxsize';
  ss:= ss + trim(INtToStr(nSize));
  If trim(cLineStyle)<>'' then ss:=ss+'\'+cLineStyle;
  If nThick>0 then ss:= ss + '\dplinew'+trim(IntTostr(nThick));
  ss := ss + '}\par}';

  WriteLn(FFileVar,ss);
end;

//перевод сантиметров в твипы
function TRtfDoc.Twips(nCm: Single):Word;
begin
     Result:= Round(nCm * 1440/2.54);
end;

//создание документа
procedure TRtfDoc.Start(const FileName : string);
var
  CurYear   : Word;
  CurMonth  : Word;
  CurDay    : Word;
  CurHour   : Word;
  CurMinute : Word;
  CurSecond : Word;
  CurSec100 : Word;
begin
  FFileName := FileName;
  AssignFile(FFileVar, FFileName);
  Rewrite(FFileVar);

  Parser.ResetParser;

  Parser.ClassCallbacks[rtfGroup] := DoGroup;
//  Parser.ClassCallbacks[rtfText] := DoText;
  Parser.ClassCallbacks[rtfControl] := DoCtrl;
  Parser.DestinationCallbacks[rtfFontTbl] := nil;
  Parser.DestinationCallbacks[rtfColorTbl] := nil;
  Parser.DestinationCallbacks[rtfInfo] := nil;
  Parser.OnRTFError := HandleError;

  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfVersion, -1, 1);
  OutCtrl(rtfCharSet, rtfAnsiCharSet, rtfNoParam);

   {Output document creation date and time}
  DecodeDate(Now, CurYear, CurMonth, CurDay);
  DecodeTime(Now, CurHour, CurMinute, CurSecond, CurSec100);
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfDestination, rtfInfo, rtfNoParam); 
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfSpecialChar, rtfICreateTime, rtfNoParam);
  OutCtrl(rtfSpecialChar, rtfIYear, CurYear);
  OutCtrl(rtfSpecialChar, rtfIMonth, CurMonth);
  OutCtrl(rtfSpecialChar, rtfIDay, CurDay);
  OutCtrl(rtfSpecialChar, rtfIHour, CurHour);
  OutCtrl(rtfSpecialChar, rtfIMinute, CurMinute);
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  WriteLn(FFileVar);
  //установить шрифт по умолчанию
  DefaultFontTable(0);

end;  {TRtfDoc.Start}

//Таблица шрифтов по умолчанию
procedure TRtfDoc.DefaultFontTable(DefFont: Integer);
begin
   //начало описания шрифтов с указанием шрифта по умолчанию
  OutCtrl(rtfDefFont, -1, DefFont);
   //описание
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfDestination, rtfFontTbl, rtfNoParam);
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  //номер шрифта
  OutCtrl(rtfCharAttr, rtfFontNum, 0);
  OutToken(rtfControl, rtfFontFamily, rtfFFNil, rtfNoParam,
           'DejaVu Sans Cyr;');
  //Specifies the character set of a font in the font table
  Write(FFileVar, '\fcharset204');
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfCharAttr, rtfFontNum, 1);
  Write(FFileVar, '\fmodern\fcharser204 Courier Cyr{\*\falt Courier New};');
{  OutToken(rtfControl, rtfFontFamily, rtfFFRoman, rtfNoParam,
           'Courier New;');
  //Specifies the character set of a font in the font table
  Write(FFileVar, '\fcharset204');
 }
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfCharAttr, rtfFontNum, 2);
  OutToken(rtfControl, rtfFontFamily, rtfFFNil, rtfNoParam,
           'DejaVu Serif Cyr;');
  //Specifies the character set of a font in the font table
  Write(FFileVar, '\fcharset204');
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  OutToken(rtfGroup, rtfBeginGroup, -1, rtfNoParam, '');
  OutCtrl(rtfCharAttr, rtfFontNum, 3);
  OutToken(rtfControl, rtfFontFamily, rtfFFNil, rtfNoParam,
           'Cyr Cyr;');
  //Specifies the character set of a font in the font table
  Write(FFileVar, '\fcharset204');
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  WriteLn(FFileVar);
end;  {TRtfDoc.OutDefaultFontTable}


procedure TRtfDoc.Done;
begin
  WriteLn(FFileVar);
  OutToken(rtfGroup, rtfEndGroup, -1, rtfNoParam, '');
  CloseFile(FFileVar);
end;


procedure TRtfDoc.OutToken(      AClass : Integer;
                                 Major  : Integer;
                                 Minor  : Integer;
                                 Param  : Integer;
                           const Text   : string);
begin
  Parser.SetToken(AClass, Major, Minor, Param, Text);
  Parser.RouteToken;
  if Text <> '' then
    Write(FFileVar, Text);
end;


procedure TRtfDoc.OutCtrl(Major : Integer;
                          Minor : Integer;
                          Param : Integer);
begin
  OutToken(rtfControl, Major, Minor, Param, '');
end;

{
procedure TRtfDoc.OutText(const inText : string);
var
  CharNum : Integer;
  ansiText: string;
begin
  for CharNum := 1 to Length(inText) do
    OutToken(rtfText, Ord(inText[CharNum]), 0, rtfNoParam, '');
end;
 }

procedure TRtfDoc.DoGroup;
begin
  if Parser.rtfMajor = rtfBeginGroup then
    Write(FFileVar, '{')
  else
    Write(FFileVar, '}');
end;


procedure TRtfDoc.DoCtrl;
var
  RtfIdx : Integer;
begin
  if (Parser.rtfMajor = rtfSpecialChar) and
     (Parser.rtfMinor = rtfPar) then
    WriteLn(FFileVar);
  RtfIdx := 0;
  while rtfKey[RtfIdx].rtfKStr <> '' do
    begin
    if (Parser.rtfMajor = rtfKey[RtfIdx].rtfKMajor) and
       (Parser.rtfMinor = rtfKey[RtfIdx].rtfKMinor) then
      begin
      Write(FFileVar, '\');
      Write(FFileVar, rtfKey[RtfIdx].rtfKStr);
      if Parser.rtfParam <> rtfNoParam then
        Write(FFileVar, IntToStr(Parser.rtfParam));
      if rtfKey[RtfIdx].rtfKStr <> '*' then
        Write(FFileVar, ' ');
      Exit;
      end;
    Inc(RtfIdx);  
    end;
end;  {TRtfDoc.DoCtrl}


//procedure TRtfDoc.DoText;
//var
//  AChar : Char;
//begin
//   {rtfMajor contains the character ASCII code,
//     so just output it for now, preceded by \
//     if special char.}
//  AChar := Chr(Parser.rtfMajor);
//  case AChar of
//    '\' : Write(FFileVar, '\\');
//    '{' : Write(FFileVar, '\{');
//    '}' : Write(FFileVar, '\}');
//    else
//      begin
//      if AChar > #127 then  {8-bit ANSI character?}
//        Write(FFileVar, '\''' + IntToHex(Ord(AChar), 2))  {Encode using 7-bit chars}
//      else  {7-bit ANSI character}
//        Write(FFileVar, AChar);
//      end;
//    end;
//end;  {TRtfDoc.DoText}

//перекодировка текста в 16-й вид и запись в RTF
procedure TRtfDoc.OutText(const inText : string);
var
  AChar : Char;
  CharNum: integer;
  ansiText: Ansistring;
begin
  ansiText := UTF8ToCp1251(inText);
  for CharNum := 1 to Length(ansiText) do
  begin
   {rtfMajor contains the character ASCII code,
     so just output it for now, preceded by \
     if special char.}
 // AChar := Chr(Parser.rtfMajor);
  AChar := ansiText[CharNum];
  case AChar of
    '\' : Write(FFileVar, '\\');
    '{' : Write(FFileVar, '\{');
    '}' : Write(FFileVar, '\}');
    else
      begin
      if AChar > #127 then  {8-bit ANSI character?}
         Write(FFileVar, '\''' + IntToHex(Ord(AChar), 2))  {Encode using 7-bit chars}
//        Write(FFileVar, '\''' + IntToHex(Utf8CharacterTOUnicode(pChar(AChar),nSimvol)-848, 2))  {Encode using 7-bit chars}
      else  {7-bit ANSI character}
        Write(FFileVar, AChar);
      end;
    end;

  end;
end;


{$IFDEF FPC}
procedure TRtfDoc.HandleError(s : ShortString);
begin
  WriteLn(StdErr, s);
end;
{$ELSE}  {Delphi}
procedure TRtfDoc.HandleError(s : string);
begin
  WriteLn(ErrOutput, S);
end;
{$ENDIF}



end.


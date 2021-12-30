unit consol;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons;

type

  { TFormC }

  TFormC = class(TForm)
    BitBtn9: TBitBtn;
    Image1: TImage;
    Image3: TImage;
    Label11: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Memo2: TMemo;
    Memo3: TMemo;
    StringGrid2: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn9Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormC: TformC;

implementation

uses
  platproc,main;

{$R *.lfm}

{ Tform100 }

procedure TFormC.BitBtn9Click(Sender: TObject);
var
  n,m:integer;
begin
   //проверка что memo2 не пустое
   if FormC.memo2.lines.Count=0 then exit;

   //Соединяемся с сервером
   FormC.Memo3.Clear;

   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   // Выполняем команду и ловим ошибки
  try
    FormC.ZQuery1.SQL.Clear;
    for n:=1 to FormC.Memo2.lines.Count do
     begin
       FormC.ZQuery1.SQL.add(trim(FormC.Memo2.lines.Strings[n-1]));
     end;
     FormC.ZQuery1.Open;
     FormC.Memo3.Append('Команда выполнена успешно !!!'+chr(13));
     // Если SELECT то выводим результат
     if (uppercase(copy(trim(FormC.Memo2.lines.Strings[n-1]),1,6))='SELECT') and (FormC.ZQuery1.RecordCount>0) then
       begin
         FormC.StringGrid2.ColCount:=FormC.ZQuery1.FieldCount+1;
         //Заполняем заголовки полей в первую строчку
         for n:=1 to FormC.ZQuery1.FieldCount do
           begin
            FormC.StringGrid2.Cells[n,0]:=FormC.ZQuery1.Fields[n-1].fieldname;
           end;
         //Заполняем поля в остальные строчки
         FormC.StringGrid2.RowCount:=FormC.ZQuery1.RecordCount+1;
         for n:=1 to FormC.ZQuery1.RecordCount do
          begin
             for m:=1 to FormC.ZQuery1.FieldCount do
              begin
               FormC.StringGrid2.Cells[m,n]:=FormC.zquery1.FieldByName(FormC.ZQuery1.Fields[m-1].fieldname).AsWideString;
              end;
               FormC.zquery1.Next;
          end;
       end;
  except
    on E: Exception do
    begin
       FormC.Memo3.Append('ОШИБКА: '+e.Message);
    end;
  end;
   FormC.ZQuery1.close;
   FormC.Zconnection1.disconnect;
end;


procedure TFormC.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState  );
begin
  //*************************************************    HOT KEYS  *************************************************
   // F1
    if (Key=112) then showmessagealt('[F1] - Справка'+#13+'[F5] - Выполнить'+#13+'[ESC] - Отмена\Выход');
    //F5 - выполнить
    if (Key=116) then FormC.BitBtn9.Click;
    // ESC
    if (Key=27) then FormC.Close;

    If (Key=27) OR (Key=112) OR (Key=116) then Key:=0;
end;

end.


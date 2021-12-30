unit sync_table;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, Buttons, ExtCtrls;

type

  { TForm8 }

  TForm8 = class(TForm)
    BitBtn14: TBitBtn;
    BitBtn23: TBitBtn;
    Image1: TImage;
    Label2: TLabel;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn23Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SetCheckboxState(Sender: TObject; ACol, ARow: Integer;
      const Value: TCheckboxState);
    procedure UpdateGrid();
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form8: TForm8; 

implementation
uses platproc,main;

var
  mymas:array of string;
{$R *.lfm}

{ TForm8 }


procedure TForm8.UpdateGrid();
 var
   n,m:integer;
 begin
  //Соединяемся с сервером
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

    //Текущий Список таблиц для синхронизации
   form8.ZQuery1.SQL.clear;
   form8.ZQuery1.SQL.add('SELECT name_table FROM av_sync_table;');
   try
    form8.ZQuery1.Open;
   except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    form8.ZQuery1.Close;
    form8.Zconnection1.disconnect;
    exit;
   end;

   SetLength(MyMas,0);
   if form8.ZQuery1.RecordCount>0 then
     begin
       for n:=0 to form8.ZQuery1.RecordCount-1 do
         begin
           SetLength(MyMas,length(myMas)+1);
           MyMas[length(myMas)-1]:=trim(form8.ZQuery1.FieldByName('name_table').asString);
           form8.ZQuery1.Next;
         end;
     end;

    //Текущий Список таблиц ЦС
   form8.ZQuery1.SQL.clear;
   //form8.ZQuery1.SQL.add('SELECT a.relname, c.description FROM pg_class AS a ');
   //form8.ZQuery1.SQL.add('JOIN pg_namespace as d ON d.oid=a.relnamespace AND d.nspname=current_schema() ');
   //form8.ZQuery1.SQL.add('LEFT JOIN pg_description AS c ON c.objoid = a.oid AND c.objsubid=0 ');
   //form8.ZQuery1.SQL.add('WHERE substring(a.relname, 1, 3) = ''av_'' and not(a.relname LIKE ''%id_seq%'')');
   //form8.ZQuery1.SQL.add('ORDER by a.relname ;');
   form8.ZQuery1.SQL.add('SELECT table_name');
   form8.ZQuery1.SQL.add(',(SELECT c.description FROM pg_description AS c WHERE c.objoid = (select a.oid FROM pg_class a WHERE a.relname=table_name limit 1) limit 1) rem');
   form8.ZQuery1.SQL.add('    FROM information_schema.tables');
   form8.ZQuery1.SQL.add('WHERE table_type = ''BASE TABLE''');
   form8.ZQuery1.SQL.add('AND substring(table_name,1,3) = ''av_''');
   form8.ZQuery1.SQL.add('    AND table_schema NOT IN');
   form8.ZQuery1.SQL.add('        (''pg_catalog'', ''information_schema'')');
   form8.ZQuery1.SQL.add('        order by table_name');
   //showmessage(ZQuery1.SQL.Text);
   try
    form8.ZQuery1.Open;
   except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    form8.ZQuery1.Close;
    form8.Zconnection1.disconnect;
    exit;
   end;

 if form8.ZQuery1.RecordCount<1 then
     begin
       form8.ZQuery1.close;
       form8.ZConnection1.Disconnect;
       exit;
     end;


 // Заполняем Stringgrid
  form8.StringGrid1.RowCount:=1;

  //SetLength(arTables,FormDLog.ZQuery1.RecordCount,2);
  for n:=0 to form8.ZQuery1.RecordCount-1 do
   begin
     form8.StringGrid1.RowCount:=form8.StringGrid1.RowCount+1;
     form8.StringGrid1.Cells[0,n+1]:=trim(form8.ZQuery1.FieldByName('table_name').asString);
     form8.StringGrid1.Cells[1,n+1]:=trim(form8.ZQuery1.FieldByName('rem').asString);
     form8.StringGrid1.Cells[2,n+1]:='';
     for m:=0 to length(mymas)-1 do if mymas[m]=trim(form8.ZQuery1.FieldByName('table_name').asString) then  form8.StringGrid1.Cells[2,n+1]:='*';
     ZQuery1.Next;
   end;
  form8.StringGrid1.Repaint;
  end;


procedure TForm8.BitBtn14Click(Sender: TObject);
begin
  form8.Close;
end;

procedure TForm8.BitBtn23Click(Sender: TObject);
 var
   n:integer;
   flag:boolean=false;
begin
  // Сохранить текущие данные
  if form8.StringGrid1.RowCount=1 then
      begin
        showmessagealt('Пока нечего сохранять !');
        exit;
      end;
  for n:=1 to form8.StringGrid1.RowCount-1 do
   begin
     if trim(form8.StringGrid1.Cells[2,n])='*' then flag:=true;
   end;

  if flag=false then
        begin
          showmessagealt('Нельзя сохранить так как нет выбранных таблиц!');
          exit;
        end;

 if flag=true then
    begin
          // Соединение с базой
           // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

           //Открываем транзакцию
           form8.ZConnection1.StartTransaction;
           form8.Zconnection1.AutoCommit:=false;

           // Удааляем предыдущие записи
          form8.ZQuery1.SQL.Clear;
          form8.ZQuery1.SQL.add('DELETE FROM av_sync_table;');
          form8.ZQuery1.ExecSQL;

          // --- Сканируем GRID
          for n:=1 to form8.StringGrid1.RowCount-1 do
           begin
             if trim(form8.StringGrid1.Cells[2,n])='*' then
                 begin
                  ZQuery1.SQL.Clear;
                  ZQuery1.SQL.add('INSERT INTO av_sync_table(name_table)    VALUES ('+QuotedStr(trim(form8.StringGrid1.Cells[0,n]))+');');
                  ZQuery1.ExecSQL;
                 end;
           end;
          // Завершение транзакции
             form8.Zconnection1.Commit;
             form8.Zconnection1.AutoCommit:=true;
              if form8.ZConnection1.InTransaction then
              begin
                showmessagealt('Данные НЕ обновлены !'+#13+'Не удается завершить транзакцию !!!');
                form8.ZConnection1.Rollback;
                form8.ZQuery1.close;
                form8.Zconnection1.disconnect;
                exit;
              end;
                form8.ZQuery1.close;
                form8.Zconnection1.disconnect;
     end;
  form8.Close;
end;

procedure TForm8.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
   // ESC
   if Key=27 then form8.close;

   //
end;

procedure TForm8.FormShow(Sender: TObject);
begin
  centrform(form8);
  UpdateGrid();
end;

procedure TForm8.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
   with Sender as TStringGrid, Canvas do
    begin

       if (gdSelected in aState) then
           begin
            Brush.Color:=clCream;
            FillRect(aRect);
            pen.Width:=4;
            pen.Color:=clGray;
            MoveTo(aRect.left,aRect.bottom-1);
            LineTo(aRect.right,aRect.Bottom-1);
            MoveTo(aRect.left,aRect.top-1);
            LineTo(aRect.right,aRect.Top);
           end
         else
          begin
            Brush.Color:=clWhite;
            FillRect(aRect);
          end;

      // Наименование таблиц
      if (aRow>0) and (aCol=0) then
         begin
          font.Size:=14;
          font.Color:=clBlack;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;

      // Синхронизация
      if (aRow>0) and (aCol=2) then
         begin
          font.Size:=16;
          font.Color:=clRed;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;


       // Остальные поля
      if (aRow>0) and (aCol=1) then
         begin
          font.Size:=12;
          font.Color:=clBlack;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;

       // Заголовок
       if aRow=0 then
         begin
           Brush.Color:=clWhite;
           FillRect(aRect);
           Font.Color := clBlack;
           font.Size:=10;
           TextOut(aRect.Left + 3, aRect.Top+4, Cells[aCol, aRow]);
          end;
    end;
end;

procedure TForm8.StringGrid1SetCheckboxState(Sender: TObject; ACol,
  ARow: Integer; const Value: TCheckboxState);
begin
  if (form8.StringGrid1.Col=2) and  (form8.StringGrid1.row>0) and (form8.StringGrid1.Cells[form8.StringGrid1.Col,form8.StringGrid1.Row]='') then form8.StringGrid1.Cells[form8.StringGrid1.Col,form8.StringGrid1.Row]:='*' else form8.StringGrid1.Cells[form8.StringGrid1.Col,form8.StringGrid1.Row]:='';
end;

end.


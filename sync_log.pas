unit sync_log;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, Buttons, ExtCtrls;

type

  { TForm88 }

  TForm88 = class(TForm)
    BitBtn14: TBitBtn;
    Image1: TImage;
    Label2: TLabel;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure UpdateGrid();
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form88: TForm88;

implementation
uses platproc,main;

var
  mymas:array of string;
{$R *.lfm}

{ TForm8 }


procedure TForm88.UpdateGrid();
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
   form88.ZQuery1.SQL.clear;
   form88.ZQuery1.SQL.add('SELECT a.createdate,                                        ');
   form88.ZQuery1.SQL.add('   a.id_server,                                            ');
   form88.ZQuery1.SQL.add('(select b.name from av_spr_point b where a.id_server=b.id order by b.del asc,b.createdate desc limit 1) as name_server, ');
   form88.ZQuery1.SQL.add('   a.attempt,                                           ');
   form88.ZQuery1.SQL.add('   a.sync_result                                          ');
   form88.ZQuery1.SQL.add('  FROM av_update_log a   ');
   form88.ZQuery1.SQL.add(' order by a.createdate desc;');
   //showmessage(ZQuery1.SQL.Text);//$
   try
    form88.ZQuery1.Open;
   except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    form88.ZQuery1.Close;
    form88.Zconnection1.disconnect;
    exit;
   end;


 if form88.ZQuery1.RecordCount<1 then
     begin
       form88.ZQuery1.close;
       form88.ZConnection1.Disconnect;
       exit;
     end;


 // Заполняем Stringgrid
  form88.StringGrid1.RowCount:=1;

  //SetLength(arTables,FormDLog.ZQuery1.RecordCount,2);
  for n:=0 to form88.ZQuery1.RecordCount-1 do
   begin
     form88.StringGrid1.RowCount:=form88.StringGrid1.RowCount+1;
     form88.StringGrid1.Cells[0,n+1]:=trim(form88.ZQuery1.FieldByName('createdate').asString);
     form88.StringGrid1.Cells[1,n+1]:=trim(form88.ZQuery1.FieldByName('id_server').asString)+'-'+trim(form88.ZQuery1.FieldByName('name_server').asString);
     form88.StringGrid1.Cells[2,n+1]:=trim(form88.ZQuery1.FieldByName('attempt').asString);
     if form88.ZQuery1.FieldByName('sync_result').asBoolean then form88.StringGrid1.Cells[3,n+1]:='УСПЕШНО' else form88.StringGrid1.Cells[3,n+1]:='НЕУДАЧА';
     ZQuery1.Next;
   end;

   form88.ZQuery1.close;
   form88.ZConnection1.Disconnect;
end;


procedure Tform88.BitBtn14Click(Sender: TObject);
begin
  form88.Close;
end;

procedure Tform88.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
   // ESC
   if Key=27 then form88.close;

   //
end;

procedure Tform88.FormShow(Sender: TObject);
begin
  centrform(form88);
  form88.UpdateGrid();
end;

procedure Tform88.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
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

      // Остальные поля
      if (aRow>0) and (aCol<3) then
         begin
          font.Size:=10;
          font.Color:=clBlack;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;

      // Статус
      if (aRow>0) and (aCol=3) then
         begin
          font.Size:=16;
          if trim(Cells[aCol, aRow])='УСПЕШНО' then  font.Color:=clGreen else font.Color:=clRed;
          TextOut(aRect.Left + 5, aRect.Top+2, Cells[aCol, aRow]);
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


end.


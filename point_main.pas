unit point_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, Grids, Buttons, ComCtrls, StdCtrls, ExtCtrls, LazUTF8;

type

  { TForm9 }

  TForm9 = class(TForm)

    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Edit1: TEdit;
    Image3: TImage;
    ImageList1: TImageList;
    Label2: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    StringGrid1: TStringGrid;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure UpdateGrid(filter_type:byte; stroka:string);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form9: TForm9;
  flag_edit_point:integer;
  result_name_point, name_pnt:string;

implementation
uses
  main,platproc;
{$R *.lfm}

{ TForm9 }
 procedure TForm9.UpdateGrid(filter_type:byte; stroka:string);
 var
   n:integer;
begin
  Stringgrid1.RowCount:=1;
  //соединение с БД
   If not(Connect2(form9.Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;

   //запрос списка
   form9.ZQuery1.SQL.Clear;
   form9.ZQuery1.SQL.add('select a.id,c.name as name_group,a.name,b.name as locality,b.rajon,b.region,b.land ');
   form9.ZQuery1.SQL.add('from av_spr_point a,av_spr_locality b,av_spr_point_group c ');
   form9.ZQuery1.SQL.add('where a.kod_locality=b.id AND a.id_group=c.id AND a.del=0 AND b.del=0 AND c.del=0 ');

   if (stroka<>'') and (filter_type=2) then
     begin
          ZQuery1.SQL.add('and (a.name ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or b.rajon ilike '+quotedstr(stroka+'%')+')');
     end;
   if (stroka<>'') and (filter_type=1) then ZQuery1.SQL.add('and cast(a.id as text) like '+quotedstr(stroka+'%'));
   form9.ZQuery1.SQL.add('ORDER BY a.name;');

  with FOrm9 do
  begin
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;
  end;

   if form9.ZQuery1.RecordCount=0 then
     begin
      form9.ZQuery1.Close;
      form9.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
   form9.StringGrid1.RowCount:=form9.ZQuery1.RecordCount+1;
   for n:=1 to form9.ZQuery1.RecordCount do
    begin
      form9.StringGrid1.Cells[0,n]:=form9.ZQuery1.FieldByName('id').asString;
      form9.StringGrid1.Cells[1,n]:=form9.ZQuery1.FieldByName('name_group').asString;
      form9.StringGrid1.Cells[2,n]:=form9.ZQuery1.FieldByName('name').asString;
      form9.StringGrid1.Cells[3,n]:=form9.ZQuery1.FieldByName('locality').asString;
      form9.StringGrid1.Cells[4,n]:=form9.ZQuery1.FieldByName('rajon').asString;
      form9.StringGrid1.Cells[5,n]:=form9.ZQuery1.FieldByName('region').asString;
      form9.StringGrid1.Cells[6,n]:=form9.ZQuery1.FieldByName('Land').asString;
      form9.ZQuery1.Next;
    end;
   form9.ZQuery1.Close;
   form9.Zconnection1.disconnect;
   form9.StringGrid1.Refresh;
   //form9.StringGrid1.SetFocus;

end;

procedure TForm9.ToolButton8Click(Sender: TObject);
begin
    GridPoisk(form9.StringGrid1,form9.Edit1);
end;

procedure TForm9.ToolButton1Click(Sender: TObject);
begin
   SortGrid(form9.StringGrid1,form9.StringGrid1.col,form9.ProgressBar1,0,1);
end;

procedure TForm9.BitBtn4Click(Sender: TObject);
begin
  result_name_point:='';
  name_pnt:='';
  form9.Close;
end;

procedure TForm9.BitBtn5Click(Sender: TObject);
begin
  If trim(form9.stringgrid1.cells[2,form9.StringGrid1.Row])='' then
    begin
     showmessagealt('Сначала выберите остановочный пункт !');
     exit;
    end;
   result_name_point:=form9.StringGrid1.Cells[0,form9.StringGrid1.row];
   name_pnt:=form9.stringgrid1.cells[2,form9.StringGrid1.Row];
   form9.close;
end;

procedure TForm9.Edit1Change(Sender: TObject);
var
  typ:byte=0;
  ss:string='';
  n:integer=0;
begin
  with FOrm9 do
begin
  ss:=trimleft(Edit1.Text);
  if UTF8Length(ss)>0 then
       begin
         //определяем тип данных для поиска
         for n:=1 to UTF8Length(ss) do
           begin
             //если хоть один нецифровой символ, тогда отвал и поиск строковых значений
              if not(ss[n] in ['0'..'9']) then
                begin
                typ:=2;
                break;
                end;
           end;
            if typ=2 then  updategrid(2,ss)
           else updategrid(1,ss);
       end
  else
     begin
      updategrid(0,'');
      Edit1.Visible:=false;
      Stringgrid1.SetFocus;
     end;
end;
end;

procedure TForm9.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
    //// Автоматический контекстный поиск
    //if (GetSymKey(char(Key))=true) then
    //  begin
    //    form9.Edit1.SetFocus;
    //  end;
    // if (Key=13) and (form9.Edit1.Focused) then Form9.ToolButton8.Click;
  With Form9 do
  begin
   //поле поиска
  If Edit1.Visible then
    begin
    // ESC поиск // Вверх по списку   // Вниз по списку
     If key=27 then
        begin
          //datatyp := 0;
          updategrid(0,'');
          StringGrid1.SetFocus;
          key:=0;
          exit;
      end;
  if (Key=38) OR (Key=40) then
     begin
       Edit1.Visible:=false;
       StringGrid1.SetFocus;
       key:=0;
       exit;
     end;
      // ENTER - остановить контекстный поиск
   if (Key=13) then
     begin
       StringGrid1.SetFocus;
       key:=0;
       exit;
     end;
    end;

    // F1
//     if Key=112 then showmessagealt('F1 - Справка'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+#13+'F7 - Поиск'+#13+'F8 - Удалить'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
     if Key=112 then showmessagealt('F1 - Справка'+#13+'F7 - Поиск'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');

    //F4 - Изменить
  //  if (Key=115) and (form9.bitbtn12.enabled=true) then form9.BitBtn12.Click;
    //F5 - Добавить
 //   if (Key=116) and (form9.bitbtn1.enabled=true) then form9.BitBtn1.Click;
    //F7 - Поиск
    if (Key=118) then form9.ToolButton8.Click;
    //F8 - Удалить
 //   if (Key=119) and (form9.bitbtn2.enabled=true) then form9.BitBtn2.Click;
    // ESC
    if Key=27 then form9.BitBtn4.Click;
    // ENTER
    if (Key=13) and  (form9.StringGrid1.Focused) then form9.BitBtn5.Click;

     // Контекcтный поиск
   if (Edit1.Visible=false) AND (stringgrid1.Focused) then
     begin
       If (get_type_char(key)>0) or (key=8) or (key=46) or (key=96) then //8-backspace 46-delete 96- numpad 0
       begin
         Edit1.text:='';
         Edit1.Visible:=true;
         Edit1.SetFocus;
       end;
     end;
     if (Key=112) or (Key=115) or (Key=116) or (Key=119) or (Key=27)  or (Key=13) then Key:=0;
  end;
end;

procedure TForm9.FormShow(Sender: TObject);
begin
   Centrform(form9);
   form9.UpdateGrid(0,'');
  // SortGrid(form9.StringGrid1,2,form9.ProgressBar1);
   form9.StringGrid1.Col:=2;
   form9.StringGrid1.SetFocus;
end;

procedure TForm9.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
     with Sender as TStringGrid, Canvas do
  begin
       Brush.Color:=clWhite;
       FillRect(aRect);
       if (gdSelected in aState) then
           begin
            pen.Width:=4;
            pen.Color:=clRed;
            MoveTo(aRect.left,aRect.bottom-1);
            LineTo(aRect.right,aRect.Bottom-1);
            MoveTo(aRect.left,aRect.top-1);
            LineTo(aRect.right,aRect.Top);
            Font.Color := clBlue;
            font.Size:=12;
            font.Style:= [];
           end
         else
          begin
            font.Style:= [];
            Font.Color := clBlack;
            font.Size:=11;
          end;

       // Остальные поля
    // if (aRow>0) and not(aCol=1) and not(aCol=2) and not(aCol=0) then
     if (aRow>0) and not(aCol=1) then
         begin
     //     Font.Size:=10;
     //     Font.Color := clBlack;
          TextOut(aRect.Left + 10, aRect.Top+8, Cells[aCol, aRow]);
         end;

      ////Остановочный пункт
      //if (aRow>0) and ((aCol=2) or (aCol=0))then
      // begin
      //   TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
      // end;

      // Группа
      if (aRow>0) and (aCol=1) then
         begin
          Font.Size:=11;
          Font.Color := clBlack;
          TextOut(aRect.Left + 5, aRect.Top+8, Cells[aCol, aRow]);
         end;

      // Заголовок
       if aRow=0 then
         begin
           RowHeights[aRow]:=30;
           Brush.Color:=clCream;
           FillRect(aRect);
           Font.Color := clBlack;
           font.Size:=9;
           font.Style:=[fsBold];
           TextOut(aRect.Left + 5, aRect.Top+15, Cells[aCol, aRow]);
           //Рисуем значки сортировки и активного столбца
            DrawCell_header(aCol,Canvas,aRect.left,(Sender as TStringgrid));
          end;
     end;
end;

procedure TForm9.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   Click_Header((Sender as TStringgrid),X,Y,Self.ProgressBar1);
end;



end.


unit spr_arms;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, FileUtil, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons;

type

  { TForm6 }

  TForm6 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form6: TForm6;

implementation
uses mainadmin,unit5,platproc;

{$R *.lfm}

{ TForm6 }

procedure TForm6.BitBtn1Click(Sender: TObject);
begin
    //Добавляем новую запись
  if not(trim(form6.Edit1.text)='') and not(trim(form6.Edit2.text)='') then
     begin
       form6.stringgrid1.RowCount:=form6.stringgrid1.RowCount+1;
       form6.StringGrid1.cells[1,form6.stringgrid1.RowCount-1]:=inttostr(form6.stringgrid1.Rowcount-1);
       form6.StringGrid1.cells[2,form6.stringgrid1.RowCount-1]:=trim(form6.Edit1.text);
       form6.StringGrid1.cells[3,form6.stringgrid1.RowCount-1]:=trim(form6.Edit2.text);
     end
  else
    begin
      showmessage('Введены не все добавляемые параметры !');
    end;
end;

procedure TForm6.BitBtn2Click(Sender: TObject);
begin
  DelStringGrid(Form6.StringGrid1,Form6.StringGrid1.Row);
end;

procedure TForm6.BitBtn3Click(Sender: TObject);
 var
   n:integer;
begin
  //Сохранить изменения
   MConnect(form6.ZConnection1,form1.Edit4.text,form1.Edit2.text,form1.Edit13.text);
    try
      form6.Zconnection1.connect;
      form1.memo1.Append('Соединение с сервером SQL - OK');
    except
      showmessage('Соединение с сервером SQL - ОШИБКА');
      exit;
    end;

  // Удаляем записи
 try
  form6.ZQuery1.SQL.Clear;
  form6.ZQuery1.SQL.add('DELETE FROM av_arm;');
  form6.ZQuery1.ExecSQL;
 except
   showmessage('Выполнение команды SQL - ОШИБКА');
   form6.Zconnection1.disconnect;
   exit;
 end;

  //Сохраняем новые записи
  for n:=1 to form6.stringgrid1.RowCount-1 do
     begin
       try
          form6.ZQuery1.SQL.Clear;
          form6.ZQuery1.SQL.add('INSERT INTO av_arm (id,armname,armapp) VALUES (');
          form6.ZQuery1.SQL.add(form6.StringGrid1.cells[1,n]+',');
          form6.ZQuery1.SQL.add(QuotedStr(form6.StringGrid1.cells[2,n])+',');
          form6.ZQuery1.SQL.add(QuotedStr(form6.StringGrid1.cells[3,n])+');');
          form6.ZQuery1.Open;
        except
          showmessage('Выполнение команды SQL - ОШИБКА');
          form6.Zconnection1.disconnect;
          exit;
        end;
      end;
  form6.Zconnection1.disconnect;
  showmessage('Все данные сохранены !');
end;

procedure TForm6.BitBtn4Click(Sender: TObject);
begin
  form6.Close;
end;

procedure TForm6.BitBtn5Click(Sender: TObject);
begin
  // Выбор арма и передача его в форму form5
  id_arm:=form6.stringgrid1.Cells[1,form6.stringgrid1.row];
  form6.Close;
end;

// *********************************************************************  hot keys *****************************************
procedure TForm6.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then Form6.Close;

   With form6 do
   begin
    // F1
    if Key=112 then showmessage('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F3 - Выбрать'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+
                    #13+'F8 - Удалить'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Сохранить
    if (Key=113) and (bitbtn3.enabled=true) then bitbtn3.click;
    //F3 - Выбрать
    If (Key=114) and (BitBtn5.Enabled=true) then BitBtn5.click;
    //F4 - Изменить
   // if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn1.enabled=true) then BitBtn1.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn2.enabled=true) then BitBtn2.Click;
     // ENTER
   // if Key=13 then
   end;
end;


procedure TForm6.FormShow(Sender: TObject);
var
   n:integer;
begin
  CentrForm(Form6);
  //Заполняем StringGrid
    MConnect(form6.Zconnection1,form1.Edit4.text,form1.Edit2.text,form1.Edit13.text);
     try
       form6.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
   // Запрос
  try
   form6.ZQuery1.SQL.Clear;
   form6.ZQuery1.SQL.add('SELECT * FROM av_arm');
   form6.ZQuery1.open;
  except
    showmessage('Команда SQL - ОШИБКА');
    exit;
  end;
   if form6.ZQuery1.RecordCount<1 then exit;
   form6.stringgrid1.RowCount:=form6.ZQuery1.Recordcount+1;
   for n:=1 to form6.ZQuery1.Recordcount do
      begin
           form6.StringGrid1.cells[1,n]:=form6.ZQuery1.FieldByName('id').asString;
           form6.StringGrid1.cells[2,n]:=form6.ZQuery1.FieldByName('armname').asString;
           form6.StringGrid1.cells[3,n]:=form6.ZQuery1.FieldByName('armapp').asString;
           form6.zquery1.Next;
      end;
   form6.ZQuery1.close;
   form6.Zconnection1.disconnect;
end;



procedure TForm6.StringGrid1DblClick(Sender: TObject);
begin
 form6.BitBtn5.Click;
end;




end.


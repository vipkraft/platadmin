unit spr_grup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons;

type

  { TFormGroups }

  TFormGroups = class(TForm)
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
    procedure FormClose();
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormGroups: TFormGroups;

implementation
uses main,platproc;
{$R *.lfm}

{ TFormGroups }
var
  lgFlag: boolean;
  otvet: integer;

procedure TFormGroups.FormClose();
begin
   //Проверяем флаг наличия изменений
  If lgFlag then
    begin
        otvet := MessageDlg('Внесенные изменения НЕ будут сохранены'+chr(13)+'Продолжить выход ?',mtConfirmation, mbYesNo, 0);
        if otvet=6 then FormGroups.Close;
    end
  else
  FormGroups.Close;
end;

// *********************************************************************  hot keys *****************************************
procedure TFormGroups.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then FormGroups.Close;

   With FormGroups do
   begin
    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F3 - Выбрать'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+
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


procedure TFormGroups.BitBtn4Click(Sender: TObject);
begin
  FormClose();
end;

procedure TFormGroups.BitBtn5Click(Sender: TObject);
begin
  // Выбор арма и передача его в форму form3
  ngrup:=FormGroups.stringgrid1.Cells[1,FormGroups.stringgrid1.row];
  sgrup:=FormGroups.stringgrid1.Cells[2,FormGroups.stringgrid1.row];
  FormClose();
end;

procedure TFormGroups.BitBtn1Click(Sender: TObject);
begin
     //Добавляем новую запись
  if not(trim(FormGroups.Edit1.text)='') then
     begin
       FormGroups.stringgrid1.RowCount:=FormGroups.stringgrid1.RowCount+1;
       FormGroups.StringGrid1.cells[1,FormGroups.stringgrid1.RowCount-1]:=inttostr(FormGroups.stringgrid1.Rowcount-1);
       FormGroups.StringGrid1.cells[2,FormGroups.stringgrid1.RowCount-1]:=trim(FormGroups.Edit1.text);
       //флаг наличия изменений
       lgFlag:=true;
     end
  else
    begin
      showmessagealt('Сначала введите наименование группы !');
    end;
end;

procedure TFormGroups.BitBtn2Click(Sender: TObject);
begin
  DelStringGrid(FormGroups.StringGrid1,FormGroups.StringGrid1.Row);
  lgFlag:=true;
end;

procedure TFormGroups.BitBtn3Click(Sender: TObject);
 var
   n:integer;
begin
  //Сохранить изменения
  //соединение с БД
   If not(Connect2(formGroups.Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;

  // Удаляем записи
 try
  FormGroups.ZQuery1.SQL.Clear;
  FormGroups.ZQuery1.SQL.add('DELETE FROM av_group;');
  FormGroups.ZQuery1.ExecSQL;
 except
   showmessagealt('Выполнение команды SQL - ОШИБКА');
   FormGroups.Zconnection1.disconnect;
   exit;
 end;

  //Сохраняем новые записи
  for n:=1 to FormGroups.stringgrid1.RowCount-1 do
     begin
       try
          FormGroups.ZQuery1.SQL.Clear;
          FormGroups.ZQuery1.SQL.add('INSERT INTO av_group (id,grupa) VALUES (');
          //FormGroups.ZQuery1.SQL.add(id_arm+',');
          FormGroups.ZQuery1.SQL.add(FormGroups.StringGrid1.cells[1,n]+',');
          FormGroups.ZQuery1.SQL.add(QuotedStr(FormGroups.StringGrid1.cells[2,n])+');');
//          FormGroups.ZQuery1.SQL.add(QuotedStr(FormGroups.StringGrid1.cells[3,n])+');');

          FormGroups.ZQuery1.ExecSQL;
        except
          showmessagealt('Выполнение команды SQL - ОШИБКА');
         // FormGroups.Zconnection1.disconnect;
          exit;
        end;
      end;

  FormGroups.Zconnection1.disconnect;
  showmessagealt('Все данные сохранены !');
  //сбросить флаг наличия изменений
  lgFlag:=false;
end;

//************ ВОзникновение формы **********************************************
procedure TFormGroups.FormShow(Sender: TObject);
var
 n:integer;
begin
 CentrForm(FormGroups);
  //Инициализируем флаг наличия изменений
  lgFlag:=false;
  //Заполняем StringGrid
   //соединение с БД
   If not(Connect2(formGroups.Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
  //Запрос
  try
   FormGroups.ZQuery1.SQL.Clear;
   FormGroups.ZQuery1.SQL.add('SELECT * FROM av_group WHERE del=0;');
   FormGroups.ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    exit;
  end;

  If formgroups.ZQuery1.RecordCount < 1 then exit;
  FormGroups.stringgrid1.RowCount:=FormGroups.ZQuery1.Recordcount+1;
  for n:=1 to FormGroups.ZQuery1.recordcount do
      begin
           FormGroups.StringGrid1.cells[1,n]:=inttostr(FormGroups.ZQuery1.FieldByName('id').asInteger);
           FormGroups.StringGrid1.cells[2,n]:=FormGroups.ZQuery1.FieldByName('grupa').asString;
           FormGroups.zquery1.Next;
      end;
   FormGroups.ZQuery1.close;
   FormGroups.Zconnection1.disconnect;
end;

end.


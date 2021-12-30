unit spr_option;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons, LazUTF8;

type

  { TForm7 }

  TForm7 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    ComboBox1: TComboBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape2: TShape;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GridUpdate; //обновить грид опций
    function GetNextId(Grid: TStringGrid; sid: String):integer; //ПОЛУЧЕНИЕ НОВОГО уникального ID
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;   Shift: TShiftState);
    procedure UpdateCombo(); //обновить список АРМ-ов
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form7: TForm7; 

implementation
uses main,arm,platproc;
{$R *.lfm}

{ TForm7 }
var
  lChange:boolean=false;
  numarm:string='0';

//*************************************** //обновить список АРМ-ов********************************************
procedure TForm7.UpdateCombo;
  var
  n : integer;
begin

  With Form7 do
  begin
    ComboBox1.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT id,armname FROM av_arm WHERE del=0 ORDER BY id ASC;');
  //Заполняем grid1 АРМ
  try
    ZQuery1.Open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
    exit;
  end;
 if ZQuery1.RecordCount<1 then
     begin
       ZQuery1.close;
       ZConnection1.Disconnect;
       exit;
     end;
 // Заполняем combo
 for n:=1 to ZQuery1.RecordCount do
   begin
      combobox1.Items.Add(ZQuery1.FieldByName('id').asString+' - ' + ZQuery1.FieldByName('armname').asString);
      ZQuery1.Next;
     end;
   combobox1.ItemIndex:=0;
 ZQuery1.Close;
 Zconnection1.disconnect;
 end;
end;

//***************************              ПОЛУЧЕНИЕ НОВОГО уникального ID **********************************
function TForm7.GetNextId(Grid: TStringGrid; sid: String):integer;
begin
  Result:=-1;
  with Form7 do
  begin
  //Получаем максимальный Id в таблице
    //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

    ZQuery1.SQL.Clear;
    ZQuery1.Sql.Add('Select max('+sid+') from av_arm_options ;');
    try
       ZQuery1.open;
     except
      showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
      Zconnection1.disconnect;
      exit;
     end;
     //new_id:=0;
     If ZQuery1.RecordCount=1 then
       begin
         result:=ZQuery1.Fields.Fields[0].AsInteger;
         end;
       ZQuery1.close;
       Zconnection1.disconnect;
 end;
end;


procedure TForm7.StringGrid1KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  with form7 do
begin
   If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;
   If fl_edit_option=1 then exit;
   lChange:=true;
   //если это не новая запись, помечаем на редактирование
   If (Stringgrid1.Cells[3,Stringgrid1.Row]='0') AND (UTF8copy(trim(Stringgrid1.Cells[1,Stringgrid1.Row]),1,2)<>'<!') then
     begin
       (Stringgrid1.Cells[3,Stringgrid1.Row]:='4');
     end;
   //если запись, восстановленная после удаления, то не сохранять изменения по ней
   If (Stringgrid1.Cells[3,Stringgrid1.Row]='2') AND (UTF8copy(trim(Stringgrid1.Cells[1,Stringgrid1.Row]),1,2)<>'<!') then
     begin
       (Stringgrid1.Cells[3,Stringgrid1.Row]:='3');
     end;
end;
end;

//****************************       обновить грид опций  *********************************************
procedure TForm7.GridUpdate;
var
  n:integer=0;
begin
  with Form7 do
begin
  //Заполняем StringGrid
     //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

 // Запрос
  try
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_arm_options WHERE del=0 AND id_arm='+numarm+';');
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    exit;
  end;

  Stringgrid1.RowCount:=1;
  if ZQuery1.recordcount>0 then
      begin
       for n:=1 to ZQuery1.recordcount do
          begin
            stringgrid1.RowCount:=stringgrid1.RowCount+1;
            StringGrid1.cells[0,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('id').asString;
            StringGrid1.cells[1,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('optname').asString;
            StringGrid1.cells[2,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('optvalue').asString;
            StringGrid1.cells[3,Stringgrid1.RowCount-1]:='0'; //тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового,4 -редактирование
            zquery1.Next;
          end;
      end;
  ZQuery1.close;
  Zconnection1.disconnect;
end;
end;

procedure TForm7.BitBtn4Click(Sender: TObject);
begin
  form7.Close;
end;

//********************************* ВЫБРАТЬ ***********************************
procedure TForm7.BitBtn5Click(Sender: TObject);
begin
  With Form7 do
begin
 If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[0,Stringgrid1.Row])='') then
   begin
     showmessagealt('Выбрана некорректная запись опции !');
     exit;
   end;
  // Выбор опции и передача его в форму form5
  id_opt:=stringgrid1.Cells[0,stringgrid1.row];
end;

 form7.Close;
end;

procedure TForm7.ComboBox1Change(Sender: TObject);
begin
   Form7.Label5.Caption:=Form7.ComboBox1.Text;
   //назначить новый id arm
   numarm := UTF8copy(Form7.ComboBox1.Text,1,UTF8pos('-',Form7.ComboBox1.Text)-1);
   GridUpdate();
end;


//************** ЗАКРЫТИЕ ФОРМЫ ********************************************
procedure TForm7.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  imes: integer;
begin
   if lChange AND (fl_edit_option=2) then
    begin
    imes := dialogs.MessageDlg('Внесенные изменения НЕ будут сохранены !'+#13+'Продолжить выход ?',mtConfirmation, mbYesNo, 0);
    if imes=7 then CloseAction := caNone;
    end;
end;


// *********************************************************************  hot keys *****************************************
procedure TForm7.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then Form7.Close;

   With form7 do
   begin
    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F5 - Добавить'+
         #13+'F8 - Удалить'+#13+'ПРОБЕЛ - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Сохранить
    if (Key=113) and (bitbtn3.visible=true) then bitbtn3.click;
    //32 - Пробел
    If (Key=32) and (BitBtn5.visible=true) then BitBtn5.click;
    //F4 - Изменить
    //if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn1.enabled=true) then BitBtn1.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn2.enabled=true) then BitBtn2.Click;
     // ENTER
   // if Key=13 then
   end;
end;


//*********************                     Добавляем новую запись     ************************************
procedure TForm7.BitBtn1Click(Sender: TObject);
var
  new:integer=0;
  n:integer=0;
begin
  With form7 do
begin
  If form7.StringGrid1.Cells[1,form7.stringgrid1.Row] = '' then
    begin
      showmessagealt('Сначала заполните НАИМЕНОВАНИЕ опции строкой выше...');
      exit;
      end;
  //If form7.StringGrid1.Cells[2,form7.stringgrid1.Row] = '' then
  //  begin
  //    showmessagealt('Сначала заполните ЗНАЧЕНИЯ опции строкой выше...');
  //    exit;
  //    end;

    new:=-1;
    new := GetNextId(form7.StringGrid1, 'id'); //получить новый id
    IF new=-1 then
      begin
      showmessagealt('Не удается получить новый ID !');
      exit;
      end;


    //Получаем максимальный Id в гриде
     for n:=1 to Stringgrid1.RowCount-1 do
        begin
           If new<StrToInt(Stringgrid1.Cells[0,n]) then
             new:=StrToInt(Stringgrid1.Cells[0,n]);
       end;
     new:=new+1;

   //showmessage(inttostr(new));

     form7.stringgrid1.RowCount:=form7.stringgrid1.RowCount+1;
     form7.StringGrid1.cells[0,form7.stringgrid1.RowCount-1]:=inttostr(new);
     form7.StringGrid1.cells[3,form7.stringgrid1.RowCount-1]:='1';
     Stringgrid1.setfocus;
     Stringgrid1.Row:=Stringgrid1.RowCount-1;
     lChange:=true;
     end;
end;


//*************************************** ПОМЕТИТЬ НА УДАЛЕНИЕ **********************************
procedure TForm7.BitBtn2Click(Sender: TObject);
begin
  With FOrm7 do
begin
  If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[0,Stringgrid1.Row])='') then exit;

  Stringgrid1.Cells[1,Stringgrid1.Row]:= '<! НА УДАЛЕНИЕ !> ' + Stringgrid1.Cells[1,Stringgrid1.Row];
  If (Stringgrid1.Cells[3,Stringgrid1.Row]='0') OR (Stringgrid1.Cells[3,Stringgrid1.Row]='4') then
   Stringgrid1.Cells[3,Stringgrid1.Row]:= '2'
  else Stringgrid1.Cells[3,Stringgrid1.Row]:= '3';


  StringGrid1.row:=StringGrid1.row + 1;
  Stringgrid1.setfocus;
  lChange:=true;  //флаг изменения
end;
end;


//**********************************         СОХРАНИТЬ            ***************************************************
procedure TForm7.BitBtn3Click(Sender: TObject);
 var
   m:integer;
begin
  If not lChange then
    begin
      showmessagealt('ИЗМЕНЕНИЙ НЕ БЫЛО !');
      exit;
      end;
  //Сохранить изменения

      //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

with Form7 do
begin
  for m:=1 to Stringgrid1.RowCount-1 do
  begin
//Открываем транзакцию
  try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      showmessagealt('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      ZConnection1.Rollback;
      exit;
     end;

 //УДАЛЕНИЕ значений опций у пользователей
    If (Stringgrid1.Cells[3,m]='2') or (UTF8copy(trim(Stringgrid1.Cells[1,m]),1,2)='<!') then
    begin
        //Формируем запрос на удаление опции
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_arm_options SET del=2, createdate=now(), id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id='+(Stringgrid1.Cells[0,m])+';');
         ZQuery1.ExecSQL;
        //Формируем запрос на удаление разрешений данного меню
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=2, createdate=now(), id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND option_id='+(Stringgrid1.Cells[0,m])+';');
         ZQuery1.ExecSQL;
    end;
    //РЕДАКТИРОВАНИЕ
    If Stringgrid1.Cells[3,m]='4' then
      begin
       //Формируем запрос на удаление
      ZQuery1.SQL.Clear;
      ZQuery1.SQL.add('UPDATE av_arm_options SET del=1, createdate=now(), id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id='+(Stringgrid1.Cells[0,m])+';');
      //showmessage(ZQuery1.SQL.text);
      ZQuery1.ExecSQL;
      end;

     //ФОрмируем запрос на добавление
     If ((Stringgrid1.Cells[3,m]='1') or (Stringgrid1.Cells[3,m]='4')) and //((Stringgrid1.Cells[3,m]='0') or
             (UTF8copy(trim(Stringgrid1.Cells[1,m]),1,2)<>'<!') then
      begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('INSERT INTO av_arm_options(id_arm,id,optname,optvalue,createdate,del,id_user) VALUES (');
       ZQuery1.SQL.add(numarm+','+StringGrid1.Cells[0,m]+','+QuotedStr(trim(StringGrid1.Cells[1,m]))+','+QuotedStr(trim(StringGrid1.Cells[2,m])));
       ZQuery1.SQL.add(',now(),0,'+GLuser+');');
       ZQuery1.ExecSQL;
      end;

// Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
 //обнуляем строчку
  Stringgrid1.Cells[3,m]:='0';
 //закрываем цикл по гриду меню
  end;
 showmessagealt('Транзакция успешно завершена !');
 lChange:=false;
 form7.Zconnection1.disconnect;
 fORM7.Close;
end;
end;


procedure TForm7.FormShow(Sender: TObject);
var
 n:integer;
begin
 CentrForm(Form7);
 Form7.Label5.Caption := namearm;

 //если режим выбора
 IF fl_edit_option=1 then
 begin
   form7.BitBtn5.Visible:=true;
   StringGrid1.Options:=StringGrid1.Options+[goRowSelect];  //Включаем редактирование, другие элементы не трогаем
   GroupBox3.Enabled:=false;
   numarm := form5.StringGrid1.Cells[0,form5.StringGrid1.row];
 end;
 //если режим редактирования
 IF fl_edit_option=2 then
 begin
   form7.BitBtn1.Visible:=true;
   form7.BitBtn2.Visible:=true;
   form7.BitBtn3.Visible:=true;
   StringGrid1.Options:=StringGrid1.Options+[goEditing];  //Включаем редактирование, другие элементы не трогаем
   GroupBox3.Enabled:= true;
   numarm := '0';
   UpdateCombo(); //обновить список АРМ-ов
   Form7.Label5.Caption:=Form7.ComboBox1.Text;
   numarm := UTF8copy(Form7.ComboBox1.Text,1,UTF8pos('-',Form7.ComboBox1.Text)-1);
 end;
 GridUpdate();
end;



end.


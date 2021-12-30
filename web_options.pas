unit web_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons, LazUTF8;

type

  { TFormWO }

  TFormWO = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Shape2: TShape;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GridUpdate; //обновить грид опций
    function GetNextId(Grid: TStringGrid; sid: String):integer; //ПОЛУЧЕНИЕ НОВОГО уникального ID
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;   Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormWO: TFormWO;

implementation
uses main,platproc,web_users,web_usr_opt;
{$R *.lfm}

{ TFormWO }
var
  lChange:boolean=false;
  numarm:string='0';

//***************************              ПОЛУЧЕНИЕ НОВОГО уникального ID **********************************
function TFormWO.GetNextId(Grid: TStringGrid; sid: String):integer;
begin
  Result:=-1;
  with FormWO do
  begin
  //Получаем максимальный Id в таблице
    //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

    ZQuery1.SQL.Clear;
    ZQuery1.Sql.Add('Select max('+sid+') from av_web_options;');
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

procedure TFormWO.StringGrid1EditingDone(Sender: TObject);
begin
   with FormWO do
begin
   If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;
   If webid>0 then exit;
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


procedure TFormWO.StringGrid1KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  with FormWO do
begin
   If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;
   If webid>0 then exit;
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
procedure TFormWO.GridUpdate;
var
  n:integer=0;
begin
  with FormWO do
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
   ZQuery1.SQL.add('SELECT a.* ');
   //ZQuery1.SQL.add(',coalesce((SELECT a.opt_value FROM av_web_user_options as b where b.del=0 AND b.option_id=a.id AND b.id_web='+inttostr(webid)+'ORDER BY a.createdate DESC Limit 1),''0'') as user_value ');
   ZQuery1.SQL.add('FROM av_web_options a WHERE a.del=0 ORDER BY a.id;');
   //showmessage(ZQuery1.SQL.Text);//$
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
            StringGrid1.cells[1,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('oname').asString;
            StringGrid1.cells[2,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('val1').asString;
            StringGrid1.cells[3,Stringgrid1.RowCount-1]:='0'; //тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового,4 -редактирование
            StringGrid1.cells[4,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('rem1').asString;
            StringGrid1.cells[5,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('val2').asString;
            StringGrid1.cells[6,Stringgrid1.RowCount-1]:=ZQuery1.FieldByName('rem2').asString;
            zquery1.Next;
          end;
      end;
  ZQuery1.close;
  Zconnection1.disconnect;
  Stringgrid1.ColWidths[3]:=1;
end;
end;

procedure TFormWO.BitBtn4Click(Sender: TObject);
begin
  FormWO.Close;
end;

//********************************* ВЫБРАТЬ ***********************************
procedure TFormWO.BitBtn5Click(Sender: TObject);
begin
  With FormWO do
begin
 If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[0,Stringgrid1.Row])='') then
   begin
     showmessagealt('Выбрана некорректная запись опции !');
     exit;
   end;
  // Выбор опции и передача его в форму form5
  optid:=stringgrid1.Cells[0,stringgrid1.row];
end;

 FormWO.Close;
end;



//************** ЗАКРЫТИЕ ФОРМЫ ********************************************
procedure TFormWO.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  imes: integer;
begin
   if lChange  then
    begin
    imes := dialogs.MessageDlg('Внесенные изменения НЕ будут сохранены !'+#13+'Продолжить выход ?',mtConfirmation, mbYesNo, 0);
    if imes=7 then CloseAction := caNone;
    end;
end;


// *********************************************************************  hot keys *****************************************
procedure TFormWO.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then FormWO.Close;

   With FormWO do
   begin
    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F5 - Добавить'+
         #13+'F8 - Удалить'+#13+'ПРОБЕЛ - Выбор'+#13+'ESC - Отмена\Выход');

    //F2 - Сохранить
    if (Key=113) and (bitbtn3.enabled=true) then bitbtn3.click;
    //F5 - Добавить
    if (Key=116) and (bitbtn1.enabled=true) then BitBtn1.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn2.enabled=true) then BitBtn2.Click;
     // ENTER
   // if Key=13 then
     //32 - Пробел
    If (Key=32) and (BitBtn5.visible=true) then BitBtn5.click;
    //F4 - Изменить
    //if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
   end;
end;


//*********************                     Добавляем новую запись     ************************************
procedure TFormWO.BitBtn1Click(Sender: TObject);
var
  new:integer=0;
  n:integer=0;
begin
  With FormWO do
begin
  If FormWO.StringGrid1.Cells[1,FormWO.stringgrid1.Row] = '' then
    begin
      showmessagealt('Сначала заполните НАИМЕНОВАНИЕ опции строкой выше...');
      exit;
      end;
  //If FormWO.StringGrid1.Cells[2,FormWO.stringgrid1.Row] = '' then
  //  begin
  //    showmessagealt('Сначала заполните ЗНАЧЕНИЯ опции строкой выше...');
  //    exit;
  //    end;

    new:=-1;
    new := GetNextId(FormWO.StringGrid1, 'id'); //получить новый id
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

     FormWO.stringgrid1.RowCount:=FormWO.stringgrid1.RowCount+1;
     FormWO.StringGrid1.cells[0,FormWO.stringgrid1.RowCount-1]:=inttostr(new);
     FormWO.StringGrid1.cells[3,FormWO.stringgrid1.RowCount-1]:='1';
     Stringgrid1.setfocus;
     Stringgrid1.Row:=Stringgrid1.RowCount-1;
     lChange:=true;
     end;
end;


//*************************************** ПОМЕТИТЬ НА УДАЛЕНИЕ **********************************
procedure TFormWO.BitBtn2Click(Sender: TObject);
begin
  With FormWO do
begin
  If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;

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
procedure TFormWO.BitBtn3Click(Sender: TObject);
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

with FormWO do
begin
  for m:=1 to Stringgrid1.RowCount-1 do
  begin
//Открываем транзакцию
  try
   If not Zconnection1.InTransaction then
    begin
      Zconnection1.StartTransaction
    end
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
         ZQuery1.SQL.add('UPDATE av_web_options SET del=2, createdate=now(), id_user='+GLuser+' WHERE del=0  AND id='+(Stringgrid1.Cells[0,m])+';');
         ZQuery1.ExecSQL;
        //Формируем запрос на удаление разрешений данного меню
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_web_user_options SET del=2, createdate=now(), id_user='+GLuser+' WHERE del=0 AND option_id='+(Stringgrid1.Cells[0,m]));
         ZQuery1.SQL.add(' AND id_web='+inttostr(webid));
         ZQuery1.SQL.add(';');
         ZQuery1.ExecSQL;
    end;
    //РЕДАКТИРОВАНИЕ
    If Stringgrid1.Cells[3,m]='4' then
      begin
       //Формируем запрос на удаление
      ZQuery1.SQL.Clear;
      ZQuery1.SQL.add('UPDATE av_web_options SET del=1, createdate=now(), id_user='+GLuser+' WHERE del=0 AND id='+(Stringgrid1.Cells[0,m])+';');
      //showmessage(ZQuery1.SQL.text);
      ZQuery1.ExecSQL;
      end;

     //ФОрмируем запрос на добавление
     If ((Stringgrid1.Cells[3,m]='1') or (Stringgrid1.Cells[3,m]='4')) and //((Stringgrid1.Cells[3,m]='0') or
             (UTF8copy(trim(Stringgrid1.Cells[1,m]),1,2)<>'<!') then
      begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('INSERT INTO av_web_options(id, oname, val1,rem1, val2,rem2, createdate, del, id_user) VALUES (');
       ZQuery1.SQL.add(StringGrid1.Cells[0,m]+','+QuotedStr(trim(StringGrid1.Cells[1,m]))+','+QuotedStr(trim(StringGrid1.Cells[2,m]))+','+QuotedStr(trim(StringGrid1.Cells[4,m]))+',');
       ZQuery1.SQL.add(QuotedStr(trim(StringGrid1.Cells[5,m]))+','+QuotedStr(trim(StringGrid1.Cells[6,m])));
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
 FormWO.Zconnection1.disconnect;
 FormWO.Close;
end;
end;


procedure TFormWO.FormShow(Sender: TObject);
var
 n:integer;
begin
 CentrForm(FormWO);
 //если режим выбора
 if (webid>0) then
  begin
  //FormWO.Label5.Caption:= 'для пользователя: '+webname;
  FormWO.BitBtn1.Enabled:=false;
  FormWO.BitBtn2.Enabled:=false;
  FormWO.BitBtn3.Enabled:=false;
  FormWO.BitBtn5.visible:=true;
    StringGrid1.Options:=StringGrid1.Options+[goRowSelect];  //Включаем редактирование, другие элементы не трогаем
  end
 else
 //режим редактирования
  begin
     StringGrid1.Options:=StringGrid1.Options+[goEditing];  //Включаем редактирование, другие элементы не трогаем
     FormWO.BitBtn5.visible:=false;
  end;
 GridUpdate();
end;



end.


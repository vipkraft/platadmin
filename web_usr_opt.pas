unit web_usr_opt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons, LazUTF8, web_options;

type

  { TFormU }

  TFormU = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape2: TShape;
    StringGrid3: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    function GetNextId(Grid: TStringGrid; sid: String):integer; //ПОЛУЧЕНИЕ НОВОГО уникального ID
    procedure StringGrid3EditingDone(Sender: TObject);
    procedure StringGrid3KeyDown(Sender: TObject; var Key: Word;   Shift: TShiftState);
     //обновить грид опций пользователя
    procedure UpdateGrid3();
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormU: TFormU;
  optid: string;

implementation
uses main,platproc,web_users;
{$R *.lfm}

{ TFormU }
var
  lChange:boolean=false;
  numarm:string='0';
  n: integer;


  //обновить грид опций пользователя
  procedure TFormU.UpdateGrid3();
  begin
       with FormU do
       begin
         Stringgrid3.RowCount:=1;
    // Подключаемся к серверу
     If not(Connect2(Zconnection1, flagProfile)) then
       begin
        showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
        exit;
       end;

     ////timeC := strtodate(StringGrid1.Cells[6,StringGrid1.row]);
     ////запрос списка
     ZQuery1.SQL.Clear;
     //если перевозчик
     ZQuery1.SQL.add('SELECT b.option_id, b.val1, b.val2 ');
     ZQuery1.SQL.add(',coalesce((SELECT a.oname FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(',''1'') as cname ');
     ZQuery1.SQL.add(',coalesce((SELECT a.rem1 FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(','''') as remark1 ');
     ZQuery1.SQL.add(',coalesce((SELECT a.rem2 FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(','''') as remark2 ');
     ZQuery1.SQL.add(' FROM av_web_user_options as b where b.del=0 and b.id_web='+inttostr(webid));
     ZQuery1.SQL.add(' order by b.option_id ;');
      //showmessage(ZQuery1.SQL.Text);//$
       try
         ZQuery1.open;
       except
         showmessage('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
         ZQuery1.Close;
         Zconnection1.disconnect;
         exit;
       end;
     if ZQuery1.RecordCount=0 then
       begin
         //showmessagealt('Найдено более одной записи с данным ID !!!');
         ZQuery1.close;
         ZConnection1.Disconnect;
         exit;
       end;
     label3.Caption:=inttostr(ZQuery1.RecordCount);
     for n:=1 to ZQuery1.RecordCount do
      begin
        StringGrid3.RowCount:=StringGrid3.RowCount+1;

        StringGrid3.Cells[0,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('option_id').asString;
        StringGrid3.Cells[1,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('cname').asString;
        StringGrid3.Cells[2,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('val1').asString;
        StringGrid3.Cells[3,StringGrid3.RowCount-1]:='0';//тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового,4 -редактирование
        StringGrid3.Cells[4,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('remark1').asString;
        StringGrid3.Cells[5,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('val2').asString;
        StringGrid3.Cells[6,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('remark2').asString;
        ZQuery1.Next;
      end;

      ZQuery1.close;
      ZConnection1.Disconnect;
      Stringgrid3.ColWidths[3]:=1;
       end;
    end;


//***************************              ПОЛУЧЕНИЕ НОВОГО уникального ID **********************************
function TFormU.GetNextId(Grid: TStringGrid; sid: String):integer;
begin
  Result:=-1;
  with FormU do
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

procedure TFormU.StringGrid3EditingDone(Sender: TObject);
begin
   with FormU do
begin
   If (StringGrid3.RowCount<2) or (trim(StringGrid3.Cells[1,StringGrid3.Row])='') then exit;
   lChange:=true;
   //если это не новая запись, помечаем на редактирование
   If (StringGrid3.Cells[3,StringGrid3.Row]='0') AND (UTF8copy(trim(StringGrid3.Cells[1,StringGrid3.Row]),1,2)<>'<!') then
     begin
       (StringGrid3.Cells[3,StringGrid3.Row]:='4');
     end;
   //если запись, восстановленная после удаления, то не сохранять изменения по ней
   If (StringGrid3.Cells[3,StringGrid3.Row]='2') AND (UTF8copy(trim(StringGrid3.Cells[1,StringGrid3.Row]),1,2)<>'<!') then
     begin
       (StringGrid3.Cells[3,StringGrid3.Row]:='3');
     end;
end;
end;


procedure TFormU.StringGrid3KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  with FormU do
begin
   If (StringGrid3.RowCount<2) or (trim(StringGrid3.Cells[1,StringGrid3.Row])='') then exit;
   lChange:=true;
   //если это не новая запись, помечаем на редактирование
   If (StringGrid3.Cells[3,StringGrid3.Row]='0') AND (UTF8copy(trim(StringGrid3.Cells[1,StringGrid3.Row]),1,2)<>'<!') then
     begin
       (StringGrid3.Cells[3,StringGrid3.Row]:='4');
     end;
   //если запись, восстановленная после удаления, то не сохранять изменения по ней
   If (StringGrid3.Cells[3,StringGrid3.Row]='2') AND (UTF8copy(trim(StringGrid3.Cells[1,StringGrid3.Row]),1,2)<>'<!') then
     begin
       (StringGrid3.Cells[3,StringGrid3.Row]:='3');
     end;
end;
end;


procedure TFormU.BitBtn4Click(Sender: TObject);
begin
  FormU.Close;
end;


//************** ЗАКРЫТИЕ ФОРМЫ ********************************************
procedure TFormU.FormClose(Sender: TObject; var CloseAction: TCloseAction);
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
procedure TFormU.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then FormU.Close;

   With FormU do
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

    //F4 - Изменить
    //if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
   end;
end;


//****************  ДОБАВИТЬ ОПЦИЮ  *****************
procedure TFormU.BitBtn1Click(Sender: TObject);
begin
  optid:='';
  If webid=0 then
  begin
   showmessagealt('3.Ошибка преобразования ID web-пользователя !');
   exit;
  end;
   //webname:=Form_webusr.Edit3.text;
   formWO:=TformWO.create(self);
   formWO.Showmodal;
   FreeAndNil(formWO);
    with FormU do
  begin
     //если не выбрано ничего, то выход
  IF optid='' then exit;

  // Проверка что опция с таким ID уже есть
 for n:=1 to StringGrid3.RowCount-1 do
    begin
      if trim(StringGrid3.cells[0,n])=optid then
       begin
         showmessagealt('Такая ОПЦИЯ уже существует !');
         exit;
       end;
    end;
   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

  //Выбираем нужную запись
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT * FROM av_web_options WHERE del=0 AND id='+optid+';');
 try
  ZQuery1.Open;
 except
   showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
   ZQuery1.Close;
   Zconnection1.disconnect;
   exit;
 end;

 //Защита от дурака
 if ZQuery1.RecordCount<>1 then
  begin
    showmessagealt('Такая опция не существует или задвоена !');
    Zconnection1.disconnect;
    exit;
  end;

 //Заполняем новую строку StringGrid
 StringGrid3.RowCount := StringGrid3.RowCount+1;

 StringGrid3.cells[0,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('id').asString;
 StringGrid3.cells[1,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('oname').asString;
 StringGrid3.cells[2,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('val1').asString;
 StringGrid3.cells[3,StringGrid3.RowCount-1]:='1';
 StringGrid3.cells[4,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('rem1').asString;
 StringGrid3.cells[5,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('val2').asString;
 StringGrid3.cells[6,StringGrid3.RowCount-1]:=ZQuery1.FieldByName('rem2').asString;
 ZQuery1.close;
 Zconnection1.disconnect;

 lChange:= true;
 //Определяем фокус на новом АРМ
 StringGrid3.row:=StringGrid3.rowcount-1;
  StringGrid3.SetFocus;
  end;
end;


//*************************************** ПОМЕТИТЬ НА УДАЛЕНИЕ **********************************
procedure TFormU.BitBtn2Click(Sender: TObject);
begin
  With FormU do
  begin
 If (StringGrid3.RowCount<2) or (trim(StringGrid3.Cells[1,StringGrid3.Row])='') then exit;
//Подтверждение
 If MessageDlg('Подтверждаете удаление опции?',mtConfirmation, mbYesNo, 0)=7 then exit;
 StringGrid3.Cells[1,StringGrid3.Row]:= '<! НА УДАЛЕНИЕ !> ' + StringGrid3.Cells[1,StringGrid3.Row];
 If (StringGrid3.Cells[3,StringGrid3.Row]='0') OR (StringGrid3.Cells[3,StringGrid3.Row]='4') then
  StringGrid3.Cells[3,StringGrid3.Row]:= '2'
 else StringGrid3.Cells[3,StringGrid3.Row]:= '3';

 StringGrid3.row:=StringGrid3.row + 1;
 StringGrid3.setfocus;
 lChange:=true;  //флаг изменения
end;
end;


//**********************************         СОХРАНИТЬ            ***************************************************
procedure TFormU.BitBtn3Click(Sender: TObject);
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

with FormU do
begin
  for m:=1 to StringGrid3.RowCount-1 do
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
    If (StringGrid3.Cells[3,m]='2') or (UTF8copy(trim(StringGrid3.Cells[1,m]),1,2)='<!') then
    begin
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_web_user_options SET del=2, createdate=now(), id_user='+GLuser+' WHERE del=0 AND option_id='+(StringGrid3.Cells[0,m]));
         ZQuery1.SQL.add(' AND id_web='+inttostr(webid));
         ZQuery1.SQL.add(';');
         ZQuery1.ExecSQL;
    end;
    //РЕДАКТИРОВАНИЕ
    If StringGrid3.Cells[3,m]='4' then
      begin
       //Формируем запрос на удаление
      ZQuery1.SQL.Clear;
      ZQuery1.SQL.add('UPDATE av_web_user_options SET del=1,createdate=now(),id_user='+GLuser+' WHERE id_web='+inttostr(webid));
      ZQuery1.SQL.add(' AND del=0 AND option_id='+StringGrid3.Cells[0,m]+';');
      //showmessage(ZQuery1.SQL.text);
      ZQuery1.ExecSQL;
      end;

     //ФОрмируем запрос на добавление
     If ((StringGrid3.Cells[3,m]='1') or (StringGrid3.Cells[3,m]='4')) and //((StringGrid3.Cells[3,m]='0') or
             (UTF8copy(trim(StringGrid3.Cells[1,m]),1,2)<>'<!') then
      begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('INSERT INTO av_web_user_options(option_id, id_web, val1,val2, createdate_first, createdate, id_user_first,id_user, del) VALUES (');
       ZQuery1.SQL.add(StringGrid3.Cells[0,m]+','+inttostr(webid)+','+Quotedstr(StringGrid3.Cells[2,m])+','+Quotedstr(StringGrid3.Cells[5,m])+',now(),now(),'+GLuser+','+GLuser+',0);');//id
     //showmessage(ZQuery1.SQL.Text);//$
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
  StringGrid3.Cells[3,m]:='0';
 //закрываем цикл по гриду меню
  end;
 showmessagealt('Транзакция успешно завершена !');
 lChange:=false;
 FormU.Zconnection1.disconnect;
 FormU.Close;
end;
end;


procedure TFormU.FormShow(Sender: TObject);
var
 n:integer;
begin
 CentrForm(FormU);
 //если режим выбора
 if (webid=0) then
  begin
    showmessagealt('Ошибка ! Не определен пользователь !');
    FormU.Close;
    exit;
  end;
 formU.Label5.Caption:=form_webusr.StringGrid1.Cells[1,form_webusr.StringGrid1.Row];
 UpdateGrid3();
end;



end.


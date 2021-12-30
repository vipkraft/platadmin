unit web_usr_kontr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons, LazUTF8, web_options,users_main, ExtPersonal;

type

  { TFormK }

  TFormK = class(TForm)
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
    StringGrid2: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    function  GetNextId(Grid: TStringGrid; sid: String):integer; //ПОЛУЧЕНИЕ НОВОГО уникального ID
     //обновить грид пользователя
    procedure UpdateGrid2();
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormK: TFormK;
  optid: string;

implementation
uses main,platproc,web_users;
{$R *.lfm}

{ TFormK }
var
  lChange:boolean=false;
  numarm:string='0';
  n: integer;


    //обновить грид перевозчиков/сотрудников
  procedure TFormK.UpdateGrid2();
  begin
     with FormK do
     begin
       Stringgrid2.RowCount:=1;
         If (webid=0) then exit;
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
   If form_mode=3 then
     begin
      ZQuery1.SQL.add('select * from (SELECT id_kontr as id,(select c.name from av_spr_kontragent c where c.del=0 and c.id=id_kontr order by c.createdate desc limit 1) cname ');
      ZQuery1.SQL.add('FROM av_web_users_kontr WHERE del=0 AND id_web='+inttostr(webid));
      ZQuery1.SQL.add(') z ORDER BY z.cname;');
      end;
   //если сотрудник
    If form_mode=4 then
     begin
      ZQuery1.SQL.add('select * from (SELECT id_agent as id,(select c.name from av_users c where c.del=0 and c.id=id_agent order by c.createdate desc limit 1) cname ');
      ZQuery1.SQL.add('FROM av_web_users_agent WHERE del=0 AND id_web='+inttostr(webid));
      ZQuery1.SQL.add(') z ORDER BY z.cname;');
      end;
   //ZQuery1.SQL.add('SELECT * FROM av_users WHERE del='+StringGrid1.Cells[5,StringGrid1.row]+' AND id='+StringGrid1.Cells[0,StringGrid1.row]);
   //ZQuery1.SQL.add(' AND date_trunc(''milliseconds'',createdate)='+QuotedStr(StringGrid1.Cells[6,StringGrid1.row])+';');
   ////проверка поля создания пользователя с временем в ячейке на разницу меньше секудны
   ////ZQuery1.SQL.add(' AND (date_part(''epoch'', timestamp_mi(createdate,timestamp'+QuotedStr(StringGrid1.Cells[6,StringGrid1.row])+'))<1);');
   //showmessage(ZQuery1.SQL.text);//$
   //
     try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
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
   for n:=1 to ZQuery1.RecordCount do
    begin
      StringGrid2.RowCount:=StringGrid2.RowCount+1;
      StringGrid2.Cells[0,StringGrid2.RowCount-1]:=ZQuery1.FieldByName('id').asString;
      StringGrid2.Cells[1,StringGrid2.RowCount-1]:=ZQuery1.FieldByName('cname').asString;
      ZQuery1.Next;
    end;
   //if ZQuery1.RecordCount<1 then
   //  begin
   //    ZQuery1.close;
   //    ZConnection1.Disconnect;
   //    exit;
   //  end;
   //
   //  label15.Caption:=ZQuery1.FieldbyName('fullname').AsString;//fullname
   //  label34.Caption:=formatdatetime('dd-mm-yyyy hh:nn',ZQuery1.FieldByName('createdate_first').asDatetime);//createdate
   //  label17.Caption:=formatdatetime('dd-mm-yyyy',ZQuery1.FieldByName('birthday').asDatetime);//birthday
   //  label19.Caption:=ZQuery1.FieldbyName('pol').AsString;//pol
   //  label25.Caption:=ZQuery1.FieldbyName('dolg').AsString;//dolg
   //  IF ZQuery1.FieldbyName('status').AsInteger=1 then
   //    label35.Caption:='АКТИВЕН'
   //  else label35.Caption:='НЕ Активен'; //активность
   //  label32.Caption:=ZQuery1.FieldbyName('kod1c').AsString;//kod1c
   //  IF ZQuery1.FieldbyName('tip').AsInteger=0 then
   //    label30.Caption:='Сотрудник'
   label3.Caption:=inttostr(ZQuery1.RecordCount);
    ZQuery1.close;
    ZConnection1.Disconnect;
     end;
  end;


//***************************              ПОЛУЧЕНИЕ НОВОГО уникального ID **********************************
function TFormK.GetNextId(Grid: TStringGrid; sid: String):integer;
begin
  Result:=-1;
  with FormK do
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

procedure TFormK.BitBtn4Click(Sender: TObject);
begin
  FormK.Close;
end;


// *********************************************************************  hot keys *****************************************
procedure TFormK.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then FormK.Close;

   With FormK do
   begin
    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F5 - Добавить'+
         #13+'F8 - Удалить'+#13+'ПРОБЕЛ - Выбор'+#13+'ESC - Отмена\Выход');

    //F2 - Сохранить
    //if (Key=113) and (bitbtn3.enabled=true) then bitbtn3.click;
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


//****************  ДОБАВИТЬ из справочника *****************
procedure TFormK.BitBtn1Click(Sender: TObject);
begin
  with FormK do
  begin
  //режим перевозчиков
  If form_mode=3 then
  begin
    resid:=0;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);

    If resid=0 then exit;

     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
     //проверка на дубляж

      //****** проверяем на полный дубляж
       ZQuery1.SQL.Clear;
       ZQuery1.Sql.Add('Select 1 from av_web_users_kontr WHERE del=0 AND id_kontr='+inttostr(resid)+' limit 1; ');
       try
      //showmessage(ZQuery1.SQL.Text);//$
       ZQuery1.Open;
       except
         showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
         Zconnection1.disconnect;
         exit;
       end;
       If ZQuery1.RecordCount>0 then
         begin
          showmessagealt('Данные перевозчик уже добавлен !');
          exit;
         end;
       //**************************************************************

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

   //записываем в таблицу юзеров
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('INSERT INTO av_web_users_kontr(id_web, id_kontr, createdate, del, id_user) VALUES (');
   ZQuery1.SQL.add(inttostr(webid)+','+inttostr(resid)+',now(),0,'+GLuser+');');//id
  ZQuery1.ExecSQL;
  // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
   ZQuery1.close;
   Zconnection1.disconnect;
end;

    //режим агентов
  If form_mode=4  then
  begin
    resid:=0;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);

    If resid=0 then exit;

     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
     //проверка на дубляж

      //****** проверяем на полный дубляж
       ZQuery1.SQL.Clear;
       ZQuery1.Sql.Add('Select 1 from av_web_users_agent WHERE del=0 AND id_web='+inttostr(webid)+' AND id_agent='+inttostr(resid)+' limit 1; ');
       try
      //showmessage(ZQuery1.SQL.Text);//$
       ZQuery1.Open;
       except
         showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
         Zconnection1.disconnect;
         exit;
       end;
       If ZQuery1.RecordCount>0 then
         begin
          showmessagealt('Данные перевозчик уже добавлен !');
          exit;
         end;
       //**************************************************************

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

   //записываем в таблицу юзеров
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('INSERT INTO av_web_users_agent(id_web, id_agent, createdate, del, id_user) VALUES (');
   ZQuery1.SQL.add(inttostr(webid)+','+inttostr(resid)+',now(),0,'+GLuser+');');//id
   //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;
  // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
   ZQuery1.close;
   Zconnection1.disconnect;
end;
end;
    FormK.UpdateGrid2();
end;


//*************************************** ПОМЕТИТЬ НА УДАЛЕНИЕ **********************************
procedure TFormK.BitBtn2Click(Sender: TObject);
begin
    with FormK do
  begin
   If (Stringgrid2.RowCount<2) or (trim(Stringgrid2.Cells[0,Stringgrid2.Row])='') then exit;
   If MessageDlg('Подтвердите удаление перевозчика из списка... ',mtConfirmation, mbYesNo, 0)=7 then exit;
  //режим перевозчиков
  If form_mode=3 then
  begin
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
     //проверка на дубляж

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
   ZQuery1.SQL.Clear;
   ZQuery1.Sql.Add('Update av_web_users_kontr set del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id_web='+inttostr(webid));
   ZQuery1.Sql.Add(' and id_kontr='+Stringgrid2.Cells[0,Stringgrid2.row]);
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;
  // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
   ZQuery1.close;
   Zconnection1.disconnect;
end;

    //режим агентов
  If form_mode=4 then
  begin
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
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

   ZQuery1.SQL.Clear;
   ZQuery1.Sql.Add('Update av_web_users_agent set del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id_web='+inttostr(webid));
   ZQuery1.Sql.Add(' and id_agent='+Stringgrid2.Cells[0,Stringgrid2.row]);
   //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;
  // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
   ZQuery1.close;
   Zconnection1.disconnect;
end;


end;
    FormK.UpdateGrid2();
end;


//**********************************         СОХРАНИТЬ            ***************************************************
procedure TFormK.BitBtn3Click(Sender: TObject);
 var
   m:integer;
begin

end;


procedure TFormK.FormShow(Sender: TObject);
var
 n:integer;
begin
 CentrForm(FormK);
 //если режим выбора
 if (webid=0) then
  begin
    showmessagealt('Ошибка ! Не определен пользователь !');
    FormK.Close;
    exit;
  end;
 FormK.Label5.Caption:=form_webusr.StringGrid1.Cells[1,form_webusr.StringGrid1.Row];
 UpdateGrid2();
end;



end.


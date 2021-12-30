unit users_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, Grids, Buttons, ComCtrls, StdCtrls, ExtCtrls, LazUTF8, usr_edit, arm,DB;

type

  { TForm_users }

  TForm_users = class(TForm )
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    Shape3: TShape;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1Enter(Sender: TObject);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure UpdateGrid(filter_type:byte; stroka:string);//обновить список пользователей
    procedure UpdateGrups(); //обновить комбо с группами
    procedure UpdateServers(); //обновить комбо с серверами
    procedure UpdatePodr(); //обновить комбо с подразделениями
    procedure UsrParam();//показать доп инфу
  private
    { private declarations }
  public
    { public declarations }
  end; 


var
  Form_users : TForm_users;
  //flag_edit_point : integer;
  result_user, result_usname : string;
  fl_open:byte=0;

implementation
uses
  platproc,main;
{$R *.lfm}

{ TForm_users }

//*******************************    Отображение данных пользователей  ************************************************
procedure Tform_users.UsrParam();
 var
 BlobStream: TStream;
 FileStream: TStream;
 timeC : TDateTime;
begin
    with form_users do
       begin
         label34.Caption:='';//createdate
         label15.Caption:='';//фио
         label17.Caption:='';//birthday
         label19.Caption:='';//pol
         label25.Caption:='';//dolg
         label35.Caption:='';//status
         label32.Caption:='';//kod1c
         label30.Caption:='';//tip
         image2.Picture.Clear;

  If (Stringgrid1.RowCount<2) or (Stringgrid1.Row<1) or (Stringgrid1.Cells[1,Stringgrid1.row]='') then exit;

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //timeC := strtodate(StringGrid1.Cells[6,StringGrid1.row]);
   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_users WHERE del='+StringGrid1.Cells[5,StringGrid1.row]+' AND id='+StringGrid1.Cells[0,StringGrid1.row]);
   ZQuery1.SQL.add(' AND date_trunc(''milliseconds'',createdate)='+QuotedStr(StringGrid1.Cells[6,StringGrid1.row])+';');
   //проверка поля создания пользователя с временем в ячейке на разницу меньше секудны
   //ZQuery1.SQL.add(' AND (date_part(''epoch'', timestamp_mi(createdate,timestamp'+QuotedStr(StringGrid1.Cells[6,StringGrid1.row])+'))<1);');
   //showmessage(ZQuery1.SQL.text);//$

     try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
       exit;
     end;
   if ZQuery1.RecordCount>1 then
     begin
       showmessagealt('Найдено более одной записи с данным ID !!!');
       ZQuery1.close;
       ZConnection1.Disconnect;
       exit;
     end;
   if ZQuery1.RecordCount<1 then
     begin
       ZQuery1.close;
       ZConnection1.Disconnect;
       exit;
     end;

     label15.Caption:=ZQuery1.FieldbyName('fullname').AsString;//fullname
     label34.Caption:=formatdatetime('dd-mm-yyyy hh:nn',ZQuery1.FieldByName('createdate_first').asDatetime);;//createdate
     label17.Caption:=formatdatetime('dd-mm-yyyy',ZQuery1.FieldByName('birthday').asDatetime);//birthday
     label19.Caption:=ZQuery1.FieldbyName('pol').AsString;//pol
     label25.Caption:=ZQuery1.FieldbyName('dolg').AsString;//dolg
     IF ZQuery1.FieldbyName('status').AsInteger=1 then
       label35.Caption:='АКТИВЕН'
     else label35.Caption:='НЕ Активен'; //активность
     label32.Caption:=ZQuery1.FieldbyName('kod1c').AsString;//kod1c
     IF ZQuery1.FieldbyName('tip').AsInteger=0 then
       label30.Caption:='Сотрудник'
     else label30.Caption:='Котрагент'; //tip

      // Загрузка фото
   if (ZQuery1.FieldByName('foto').IsBlob=true) then
     begin
       try
      BlobStream:=  ZQuery1.CreateBlobStream(ZQuery1.FieldByName('foto'), bmRead);
       If BlobStream.Size>10 then
           begin
             FileStream:= TFileStream.Create('foto.jpg', fmCreate);
               try
                FileStream.CopyFrom(BlobStream, BlobStream.Size);
               finally
                FileStream.Free;
               end;

            image2.Picture.LoadFromFile('foto.jpg');
           end;
        finally
            BlobStream.Free;
           end;
     end;
    ZQuery1.close;
    ZConnection1.Disconnect;
    end;
end;

//*************************************** //обновить КОМБО С ПОДРАЗДЕЛЕНИЯМИ ********************************************
procedure TForm_users.UpdatePodr();
  var
  n : integer;
begin
  With Form_users do
  begin
    ComboBox3.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('select tablename FROM pg_tables WHERE tablename=''av_1c_otd_podr'';');
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

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT * FROM av_1c_otd_podr WHERE kodpodr!=0 AND kodotd>1200 ORDER by name;');
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
      combobox3.Items.Add(ZQuery1.FieldByName('name').asString+' -- ' + ZQuery1.FieldByName('kodpodr').asString);
      ZQuery1.Next;
     end;
   combobox3.ItemIndex:=-1;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;


//*************************************** //обновить КОМБО С СЕРВЕРАМИ ********************************************
procedure TForm_users.UpdateServers();
  var
  n : integer;
begin

  With Form_users do
  begin
    combobox2.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT get_servers_list('+quotedstr('srvs')+',1,1,'+quotedstr('')+');');
  ZQuery1.SQL.add('FETCH ALL IN srvs;');
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
      combobox2.Items.Add(ZQuery1.FieldByName('pname').asString+'[' + ZQuery1.FieldByName('id').asString+']');
      ZQuery1.Next;
     end;
   combobox2.ItemIndex:=-1;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;


//**************************           обновить combo с группами ***************************************
procedure TForm_users.UpdateGrups();
var
 n:integer;
begin
 With FOrm_users do
begin
  ComboBox1.Clear;
  //Заполняем StringGrid
   //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
  //Запрос
  ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_group WHERE del=0;');
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.close;
    ZConnection1.Disconnect;
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
      combobox1.Items.Add(ZQuery1.FieldByName('id').asString+' - ' + ZQuery1.FieldByName('grupa').asString);
      ZQuery1.Next;
     end;

   combobox1.ItemIndex:=-1;
  ZQuery1.Close;
  Zconnection1.disconnect;
end;
end;


//******************************************************** ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
procedure TForm_users.UpdateGrid(filter_type:byte; stroka:string);
 var
   n:integer;
  grp,srv,podr: string;
begin
   with Form_users do
  begin
    grp:= UTF8copy(ComboBox1.Text,1,UTF8pos('-',ComboBox1.Text)-1);
    srv := copy(ComboBox2.Text,pos('[',ComboBox2.Text)+1,pos(']',ComboBox2.Text)-pos('[',ComboBox2.Text)-1);
    podr := Utf8copy(ComboBox3.Text,UTF8pos('--',ComboBox3.Text)+3,Utf8Length(ComboBox3.text));

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //* просто все юзеры
   If users_mode=0 then
     begin
   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT u.* FROM av_users u');

   //ZQuery1.SQL.add('Select u.id,u.name,u.createdate,u.kodotd,u.kodpodr,u.birthday,u.fullname,u.pol,u.dolg,u.status,u.kod1c,u.tip,u.del,p.name as namepodr,f.name as nameserv,u.group_id,g.grupa ');
   //ZQuery1.SQL.add('FROM av_users as u ');
   //ZQuery1.SQL.add('join av_users_group as g ON u.group_id=g.id ');
   //ZQuery1.SQL.add('LEFT JOIN av_1c_otd_podr as p ON u.kodotd=p.kodotd and u.kodpodr=p.kodpodr ');
   //ZQuery1.SQL.add('LEFT JOIN av_servers as m ON m.del=0 AND m.id=u.kodotd ');
   //ZQuery1.SQL.add('LEFT JOIN av_spr_point as f ON f.del=0 AND f.id=m.point_id ');
     end;
   //*** если пользователи, запрещенные для серваков
   If users_mode=1 then
     begin
       Label2.Caption:= 'Пользователи, запрещенные для серверов';
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.* ');
       ZQuery1.SQL.add('FROM av_users as u ');
       ZQuery1.SQL.add('JOIN av_servers_denyuser as s ON s.denyuser_id=u.id AND s.del=0 ');
     end;
   //*** если пользователи, запрещенные для расписаний
   If users_mode=2 then
     begin
       Label2.Caption:= 'Пользователи, запрещенные для расписаний';
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.* ');
       ZQuery1.SQL.add('FROM av_users as u ');
       ZQuery1.SQL.add('JOIN av_shedule_denyuser as s ON s.denyuser_id=u.id AND s.del=0 ');
     end;

   //если не пустой фильтр
  IF (trim(grp)<>'') AND (trim(grp)<>'0') then
  ZQuery1.SQL.add('JOIN av_users_group as g ON g.user_id=u.id AND g.del=0 AND g.group_id='+grp);
  IF (trim(srv)<>'') AND (trim(srv)<>'0') then
    ZQuery1.SQL.add('JOIN av_users_servers c ON c.user_id=u.id AND c.del=0 AND c.server_id='+srv);
  IF (trim(podr)<>'') AND (trim(podr)<>'0') then
    ZQuery1.SQL.add('JOIN av_users_podr as p ON p.user_id=u.id AND p.del=0 AND p.podr_id='+podr);

   //Выбирать удаленных или нет
   If not(CheckBox1.Checked) then  ZQuery1.SQL.add('WHERE u.del=0 ');
   If (CheckBox1.Checked) then  ZQuery1.SQL.add('WHERE u.del=2 ');

   //Контекстный поиск beta версии =)
   if (stroka<>'') and (filter_type=2) then
     begin
          ZQuery1.SQL.add('and (u.name ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or u.fullname ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or u.dolg ilike '+quotedstr(stroka+'%')+')');
     end;
   if (stroka<>'') and (filter_type=1) then ZQuery1.SQL.add('and (cast(u.id as text) like '+quotedstr(stroka+'%')+' or cast(u.kod1c as text) like '+quotedstr(stroka+'%')+')');

 ////осуществлять контекстный поиск или нет
 //If filter_type=1 then
 //  begin
 //  ZQuery1.SQL.add('AND ((u.id='+stroka+') OR (u.kod1c='+stroka+')) '); //OR (u.kodpodr='+stroka+')
 //  end;
 //If filter_type=2 then
 //  begin
 //  ZQuery1.SQL.add('AND ((UPPER(substr(u.name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
 //  ZQuery1.SQL.add('OR (UPPER(substr(u.fullname,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
 //  ZQuery1.SQL.add('OR (UPPER(substr(u.dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  end;

  ZQuery1.SQL.add('ORDER BY u.name; ');
  //showmessage(ZQuery1.SQL.text);//$
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
    exit;
  end;

  Label3.Caption := '-';
 StringGrid1.RowCount:=1;

   if Form_users.ZQuery1.RecordCount=0 then
     begin
      Form_users.ZQuery1.Close;
      Form_users.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid

   for n:=1 to ZQuery1.RecordCount do
    begin
      StringGrid1.RowCount:=StringGrid1.RowCount+1;
      StringGrid1.Cells[0,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('id').asString;
      StringGrid1.Cells[1,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('name').asString;
      StringGrid1.Cells[2,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('fullname').asString;
      StringGrid1.Cells[3,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('dolg').asString;
      StringGrid1.Cells[4,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('status').asString;
      StringGrid1.Cells[5,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('del').asString;
      StringGrid1.Cells[6,StringGrid1.RowCount-1]:=formatdatetime('dd-mm-yyyy hh:nn:ss.zzz',ZQuery1.FieldByName('createdate').asDatetime);
      ZQuery1.Next;
    end;
   Form_users.ZQuery1.Close;
   Form_users.Zconnection1.disconnect;
   //Label3.Caption := inttostr(StringGrid1.RowCount-1);
   Form_users.StringGrid1.Row := Form_users.StringGrid1.RowCount-1;
   //Form_users.StringGrid1.SetFocus;
   end;
end;

// выход
procedure TForm_users.BitBtn3Click(Sender: TObject);
begin
  result_user:='';
  result_usname:='';
  Form_users.Close;
end;

procedure TForm_users.BitBtn4Click(Sender: TObject);
begin
  UsrParam();
end;

//********************************** отфильтровать грид ******************
procedure TForm_users.Edit1Change(Sender: TObject);
var
  typ:byte=0;
  ss:string='';
  n:integer=0;
begin
  with FOrm_users do
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

// выбрать
procedure TForm_users.BitBtn2Click(Sender: TObject);
begin
  // проверки *-
  with Form_users.StringGrid1 do
  begin
  If (trim(Cells[1,Row])='') or (trim(Cells[2,Row])='') then
    begin
     showmessagealt('Сначала выберите пользователя !');
     exit;
    end;
  If (trim(Cells[4,Row])='0') then
    begin
     showmessagealt('Нельзя выбрать неактивного пользователя!'+#13+'Обратитесь к Администратору системы !');
     exit;
    end;
  If (trim(Cells[5,Row])<>'0') then
    begin
     showmessagealt('Нельзя выбрать удаленного пользователя!'+#13+'Обратитесь к Администратору системы !');
     exit;
    end;
  //---------------------------------------------------
  end;
   result_user:= Form_users.StringGrid1.Cells[0,Form_users.StringGrid1.row];
   result_usname:= Form_users.stringgrid1.cells[1,Form_users.StringGrid1.Row];
   Form_users.close;
end;

// обновить
procedure TForm_users.BitBtn1Click(Sender: TObject);
begin
  Form_users.UpdateGrid(0,'');
end;

//************************************************   УДАЛИТЬ ********************************
procedure TForm_users.BitBtn11Click(Sender: TObject);
var
  nuser:string='';
begin
  with Form_users do
  begin
    nuser:=trim(Stringgrid1.Cells[0,Stringgrid1.Row]);
    If (nuser='') OR (Stringgrid1.rowcount<2) then
    begin
      showmessagealt('Сначала выберите запись для удаления !');
      exit;
      end;
   //Подтверждение
  If MessageDlg('Действительно удалить запись?',mtConfirmation, mbYesNo, 0)=7 then exit;

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
      Zconnection1.Disconnect;
      exit;
     end;
      If users_mode=1 then
      begin
         //Помечаем на удаление пользователя из запрещенных для серверов
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_denyuser SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND denyuser_id='+nuser+';');
       ZQuery1.ExecSQL;
      end;
      If users_mode=2 then
      begin
         //Помечаем на удаление пользователя из запрещенных для расписаний
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_shedule_denyuser SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND denyuser_id='+nuser+';');
       ZQuery1.ExecSQL;
      end;
      If users_mode=0 then
      begin
       //Удаляем запись из разрешенных пользователю армов
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_arm SET del=2 WHERE del=0 AND id_user='+nuser+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление опции армов этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id='+nuser+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление разрешения меню этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id='+nuser+';');
       ZQuery1.ExecSQL;
       ////Помечаем на удаление группы пользователя
        ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_group SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
         //Помечаем на удаление сервера пользователя
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_servers SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
         //Помечаем на удаление подразделения пользователя
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_podr SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
       //помечаем пользователя на удаление
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users SET del=2,createdate=now(),id_user='+Gluser+' WHERE del=0 AND id='+nuser);
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
 ZQuery1.Close;
 Zconnection1.disconnect;
 UpdateGrid(0,'');
    end;
end;

//************************** ИЗМЕНИТЬ *********************************
procedure TForm_users.BitBtn12Click(Sender: TObject);
var
  nrow:integer=0;
begin
   fl_open:=2;
   form_edit:=Tform_edit.create(self);
   form_edit.ShowModal;
   FreeAndNil(form_edit);
   nRow:= Form_users.StringGrid1.Row;
   Form_users.UpdateGrid(0,'');
   Form_users.StringGrid1.Row := nRow;
end;

//*************************** КНОПКА ФИЛЬТРАЦИИ **************************
procedure TForm_users.BitBtn13Click(Sender: TObject);
begin
    with form_users do
begin
  If GroupBox1.Height>35 then
  begin
  //Stringgrid1.Height:=665;
  //BitBtn10.Top:=697;
  GroupBox1.Top:=697;
  GroupBox1.Height:=32;
  end
  else
  begin
    //Stringgrid1.Height:=665;//525
    //BitBtn10.Top:=560;
    GroupBox1.Top:= 560;
    GroupBox1.Height:=170;
  end;
end;
end;

//************************************ ДОСТУП ***************************
procedure TForm_users.BitBtn14Click(Sender: TObject);
begin
  Form5:=TForm5.Create(self);
  form5.showmodal;
  FreeAndNil(form5);
end;

//***************************************** АКТИВАЦИЯ / ДЕАКТИВАЦИЯ ******************************
procedure TForm_users.BitBtn17Click(Sender: TObject);
begin
  with form_users do
  begin
  //проверка, что выбрана запись
  IF (StringGrid1.Cells[0,StringGrid1.row]=emptystr) or (StringGrid1.RowCount<2) then
    begin
     showmessagealt('Сначала выберите пользователя!');
     exit;
     end;
  //проверка, не удаленный пользователь
  If trim(StringGrid1.Cells[5,StringGrid1.row])<>'0' then
    begin
     showmessagealt('Невозможно Активировать удаленного пользователя!');
     exit;
    end;

   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   // Выбор пользователей
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.add('Update av_users SET status=1 WHERE del=0 AND id='+StringGrid1.Cells[0,StringGrid1.row]+';');
  //showmessage(ZQuery1.SQL.Text);
   try
       ZQuery1.ExecSQL;
   except
      ZQuery1.Close;
      Zconnection1.disconnect;
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     exit;
   end;
    ZQuery1.Close;
    Zconnection1.disconnect;
    showmessagealt('ПОЛЬЗОВАТЕЛЬ УСПЕШНО АКТИВИРОВАН !');
   end;
end;

//***************************** ДОБАВИТЬ ********************************
procedure TForm_users.BitBtn10Click(Sender: TObject);
begin
   fl_open:=1;
   form_edit:=Tform_edit.create(self);
   form_edit.ShowModal;
   FreeAndNil(form_edit);
   Form_users.UpdateGrid(0,'');
end;


procedure TForm_users.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
//********************                    HOT KEYS  ******************************************
  With Form_users do
//begin
//  //поле поиска
//  If Edit1.Visible then
//    begin
//    // ESC поиск // Вверх по списку   // Вниз по списку
//  if (Key=27) OR (Key=38) OR (Key=40) then
//     begin
//       Edit1.Visible:=false;
//       StringGrid1.SetFocus;
//      exit;
//     end;
//      // ENTER - остановить контекстный поиск
//   if (Key=13) then
//     begin
//       StringGrid1.SetFocus;
//       //exit;
//     end;
//    end;

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
     if Key=112 then showmessagealt('F1 - Справка'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+#13+'F8 - Удалить'+#13+'F9 - Доступ'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
     //F4 - Изменить
    if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn10.enabled=true) then BitBtn10.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn11.enabled=true) then BitBtn11.Click;
    //F9 - Доступ
    if (Key=120) and (bitbtn14.enabled=true) then BitBtn14.Click;
    // ПРОБЕЛ
    if (Key=32) and  (StringGrid1.Focused) then BitBtn2.Click;
    // ESC
    if Key=27 then BitBtn3.Click;
    // ENTER
    if (Key=13) and  (StringGrid1.Focused) then BitBtn2.Click;
     if (Key=112) or (Key=115) or (Key=116) or (Key=119) or (Key=120) then Key:=0;

   //   // Контекcтный поиск
   //if Stringgrid1.Focused AND (Edit1.Visible=false) then
   //  begin
   //    If (get_type_char(key)>0) or (key=8) or (key=46) or (key=96) then //8-backspace 46-delete 96- numpad 0
   //    begin
   //      Edit1.text:='';
   //      Edit1.Visible:=true;
   //      Edit1.SetFocus;
   //    end;
   //  end;
   //if (Key=27) or (Key=32) or (Key=13) then Key:=0;
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
    if (Key=112) or (Key=115) or (Key=116) or (Key=119) or (Key=120) or (Key=27) or (Key=13)  then Key:=0;
end;
end;


procedure TForm_users.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
begin
     with Sender as TStringGrid, Canvas do
  begin
       //Если пользователь удален, закрашиваем строку серым цветом
      if (Cells[5,aRow]='0') then
        Brush.color := clWhite;
      if (Cells[5,aRow]='2') then
        Brush.Color := clSilver;
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
            font.Size:=11;
            font.Style:= [];
           end
         else
          begin
            font.Style:= [];
            Font.Color := clBlack;
            font.Size:=10;
          end;

          // имя
      if (aRow>0) and (aCol=1) then
         begin
          //Font.Size:=12;
//        Font.Color := clBlack;
          TextOut(aRect.Left + 10, aRect.Top+5, Cells[aCol, aRow]);
         end;

         // Остальные поля
     if (aRow>0) and not(aCol=1) then
         begin
          Font.Size:=10;
          //Font.Color := clBlack;
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
           TextOut(aRect.Left + 5, aRect.Top+12, Cells[aCol, aRow]);
           //Рисуем значки сортировки и активного столбца
            DrawCell_header(aCol,Canvas,aRect.left,(Sender as TStringgrid));
          end;
     end;
end;

procedure TForm_users.StringGrid1Enter(Sender: TObject);
begin
  edit1.Visible:=false;
end;

procedure TForm_users.StringGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TForm_users.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer
  );
begin

end;


procedure TForm_users.FormShow(Sender: TObject);
begin
   Centrform(Form_users);
   case users_mode of
   0: form_users.Label2.Caption:= 'ПОЛЬЗОВАТЕЛИ АСПБ';
   1: form_users.Label2.Caption:= 'ПОЛЬЗОВАТЕЛИ, ЗАПРЕЩЕННЫЕ ДЛЯ СЕРВЕРОВ АСПБ';
   2: form_users.Label2.Caption:= 'ПОЛЬЗОВАТЕЛИ, ЗАПРЕЩЕННЫЕ ДЛЯ РАСПИСАНИЙ АСПБ';
   end;

   Label15.Caption:='';
   Label17.Caption:='';
   Label19.Caption:='';
   Label25.Caption:='';
   Label30.Caption:='';
   Label32.Caption:='';
   Label34.Caption:='';
   Label35.Caption:='';

   If users_mode<>0 then
     begin
       form_users.BitBtn10.Enabled:=false;
       form_users.BitBtn12.Enabled:=false;
     end;
   UpdateGrups(); //обновить комбо с группами
   UpdateServers(); //обновить комбо с серверами
   //UpdatePodr(); //обновить комбо с подразделениями
   //GroupBox1.Top:=697;
   //GroupBox1.Height:=32;

   Form_users.UpdateGrid(0,'');
   //UsrParam();
   Form_users.StringGrid1.Col:= 2;
   //SortGrid(Form_users.StringGrid1,2,Form_users.ProgressBar1,0,1);
   Form_users.StringGrid1.SetFocus;
   {if flag_access=1 then
     begin
      with Form_users do
       begin
        BitBtn1.Enabled:=false;
        BitBtn2.Enabled:=false;
        BitBtn12.Enabled:=false;
       end;
     end;
     }
end;


end.


unit usr_edit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Buttons, EditBtn, ExtDlgs,
   {$IFDEF LINUX}
  unix,
  {$ENDIF}
  DB, LazUTF8,
  Grids, StrUtils, spr_grup, spr_otd_podr, extPersonal;

type

  { TForm_edit }

  TForm_edit = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    DateEdit1: TDateEdit;
    Edit11: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit8: TEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    OpenPictureDialog1: TOpenPictureDialog;
    Shape17: TShape;
    Shape18: TShape;
    Shape19: TShape;
    Shape3: TShape;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure DateEdit1Change(Sender: TObject);
    procedure Edit11Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
    procedure Edit8Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid1SetCheckboxState(Sender: TObject; ACol, ARow: Integer;      const Value: TCheckboxState);
    procedure StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid2SetCheckboxState(Sender: TObject; ACol, ARow: Integer;      const Value: TCheckboxState);
    procedure StringGrid3SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid3SetCheckboxState(Sender: TObject; ACol, ARow: Integer;      const Value: TCheckboxState);
    procedure UpdateGrup(); //обновить grid с группами
    procedure UpdateServers(); //обновить grid с серверами
    procedure UpdateFilial(); //обновить grid с подразделениями
    procedure ClearFields();//очистить поля
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form_edit: TForm_edit;


implementation
uses
  main,platproc,users_main;

var
  fl_edit:boolean=false;
  nuser:string='';
  BlobStream: TStream;
  FileStream: TStream;


{$R *.lfm}

{ TForm_edit }


procedure TForm_Edit.ClearFields();//очистить поля
begin
  with Form_Edit do
  begin
  If fl_open=1 then
    begin
     Edit4.Text:='';
     Edit8.Text:='';
    end;
    Edit2.Text:='';
    Edit3.Text:='';
    Edit5.Text:='';
    Edit6.Text:='';
    dateedit1.Text:='';
    Edit8.Text:='';
    Edit11.Text:='';
    memo1.Text:='';
    fl_edit:=false;
  end;
end;

//**************************           обновить ГРИД с подразделениями ***************************************
procedure TForm_Edit.UpdateFilial(); //обновить grid с подразделениями
var
 n:integer;
begin
 With FOrm_edit do
begin
  Stringgrid3.RowCount:=0;
  //Заполняем StringGrid
   //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
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


 //если режим добавления
 If fl_open=1 then
    begin
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_1c_otd_podr a ');
   ZQuery1.SQL.add('WHERE kodpodr!=0 AND kodotd>1200 ORDER BY a.name ASC; ');
   end;
 //если режим редактирования
  If fl_open=2 then
     begin
       If trim(nuser)='' then exit;
   //Запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT a.kodpodr,a.name,CASE WHEN c.podr_id is null THEN 0 ELSE 1 END flag FROM av_1c_otd_podr a ');
     ZQuery1.SQL.add('LEFT JOIN av_users_podr c ON c.del=0 AND c.podr_id=a.kodpodr AND c.user_id='+nuser);
     ZQuery1.SQL.add(' WHERE kodpodr!=0 AND kodotd>1200 ORDER BY flag DESC,a.name ASC; ');
     end;
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
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
 // Заполняем грид
 for n:=1 to ZQuery1.RecordCount do
   begin
     Stringgrid3.RowCount:= Stringgrid3.RowCount + 1;
     Stringgrid3.Cells[0,Stringgrid3.RowCount-1] := ZQuery1.FieldByName('kodpodr').asString;
     Stringgrid3.Cells[1,Stringgrid3.RowCount-1] := ZQuery1.FieldByName('name').asString;
     IF fl_open=1 then
        Stringgrid3.Cells[2,Stringgrid3.RowCount-1] := '0'
       else
        Stringgrid3.Cells[2,Stringgrid3.RowCount-1] := ZQuery1.FieldByName('flag').asString;
      ZQuery1.Next;
     end;

  ZQuery1.Close;
  Zconnection1.disconnect;
end;
end;


//**************************           обновить ГРИД с серверами ***************************************
procedure TForm_Edit.UpdateServers();
var
 n, j:integer;
begin
 With FOrm_edit do
begin
  Stringgrid2.RowCount:=0;
  //Заполняем StringGrid
   //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
 //если режим добавления
   //If fl_open=1 then
     begin
   //Запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT get_servers_list('+quotedstr('srvs')+',1,1,'+quotedstr('')+');');
     ZQuery1.SQL.add('FETCH ALL IN srvs;');
     end;
   //showmessage(ZQuery1.SQL.text);
     try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
     end;
   if ZQuery1.RecordCount<1 then
     begin
       ZQuery1.close;
       ZConnection1.Disconnect;
       exit;
     end;
 // Заполняем грид
 for n:=1 to ZQuery1.RecordCount do
   begin
     Stringgrid2.RowCount:= Stringgrid2.RowCount + 1;
     Stringgrid2.Cells[0,Stringgrid2.RowCount-1] := ZQuery1.FieldByName('id').asString;
     Stringgrid2.Cells[1,Stringgrid2.RowCount-1] := ZQuery1.FieldByName('pname').asString;
     Stringgrid2.Cells[2,Stringgrid2.RowCount-1] := '0';
     ZQuery1.Next;
     end;


 //если режим редактирования
   If fl_open=2 then
     begin
   //Запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT server_id FROM av_users_servers c WHERE c.del=0 AND c.user_id='+nuser+';');
       try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
     end;
   if ZQuery1.RecordCount>0 then
     begin
       // Заполняем грид
 for n:=1 to ZQuery1.RecordCount do
   begin
     for j:=0 to Stringgrid2.RowCount-1 do
       begin
           If Stringgrid2.Cells[0,j] = ZQuery1.FieldByName('server_id').asString then
             begin
                Stringgrid2.Cells[2,j] := '1';
                break;
             end;
       end;
        ZQuery1.Next;
     end;
     end;
     end;

  ZQuery1.Close;
  Zconnection1.disconnect;
end;
end;


//**************************           обновить Грид с группами ***************************************
procedure TForm_Edit.UpdateGrup();
var
 n:integer;
begin
 With FOrm_edit do
begin
  Stringgrid1.RowCount:=0;
  //Заполняем StringGrid
   //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
 //если режим добавления
 If fl_open=1 then
    begin
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_group WHERE del=0;');
   end;
 //если режим редактирования
  If fl_open=2 then
     begin
       If trim(nuser)='' then exit;
   //Запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT a.id,a.grupa,CASE WHEN c.group_id is null THEN 0 ELSE 1 END flag FROM av_group a ');
     ZQuery1.SQL.add('LEFT JOIN av_users_group c ON c.del=0 AND c.group_id=a.id AND c.user_id='+nuser);
     ZQuery1.SQL.add('WHERE a.del=0 ORDER BY flag DESC,a.id ASC; ');
     end;
  //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
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
 // Заполняем грид
 for n:=1 to ZQuery1.RecordCount do
   begin
     Stringgrid1.RowCount:= Stringgrid1.RowCount + 1;
     Stringgrid1.Cells[0,Stringgrid1.RowCount-1] := ZQuery1.FieldByName('id').asString;
     Stringgrid1.Cells[1,Stringgrid1.RowCount-1] := ZQuery1.FieldByName('grupa').asString;
     IF fl_open=1 then
       Stringgrid1.Cells[2,Stringgrid1.RowCount-1] := '0'
       else
         Stringgrid1.Cells[2,Stringgrid1.RowCount-1] := ZQuery1.FieldByName('flag').asString;
      ZQuery1.Next;
     end;

  ZQuery1.Close;
  Zconnection1.disconnect;
end;
end;

//***************************************************  HOT KEYS  **************************************************************
procedure TForm_edit.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  With Form_edit do
begin
    // F1
    if Key=112 then showmessagealt('[F1] - Справка'+#13+'[F2] - Сохранить'+#13+'[F9] - Сотрудники'+#13+'[F10] - Контрагенты'+#13+'[ESC] - Отмена\Выход');
    // F2 - Сохранить
    if (Key=113) and (BitBtn5.Enabled=true) then BitBtn5.Click;
   { //F3 - ATC
    if (Key=114) and (bitbtn6.enabled=true) then  bitbtn6.click;
    //F4 - Изменить
    if (Key=115) and (bitbtn12.enabled=true) then  BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn1.enabled=true) then  BitBtn1.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn2.enabled=true) then  BitBtn2.Click;
    }
    // F9 - Сотрудники
    if (Key=120) and (BitBtn8.Enabled=true) then BitBtn8.Click;
    // F10 - Контрагенты
    if (Key=121) and (BitBtn9.Enabled=true) then BitBtn9.Click;
    // ESC
    if Key=27 then Close;

   if (Key=112) or (Key=113) or (Key=120) or (Key=121) or (Key=27) then Key:=0;
end;
end;


procedure TForm_edit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    If fl_edit then
      if dialogs.MessageDlg('Изменения в НЕ будут СОХРАНЕНЫ !!!'+#13+'Продолжить выход ?',mtConfirmation,[mbYes,mbNO], 0)=7 then
        begin
          CloseAction := caNone;
          exit;
        end;
end;


//******************************* ВЫБРАТЬ ИЗ СОТРУДНИКОВ ******************************
procedure TForm_edit.BitBtn8Click(Sender: TObject);
var
 gender:string;
begin
  resid:=0;
  resstr:='';
  form_mode:=1;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);
 If (resid=0) or (trim(resstr)='') then exit;

   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('select tablename FROM pg_tables WHERE tablename=''av_1c_sotr'';');
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
  ZQuery1.SQL.add('SELECT distinct * FROM av_1c_sotr WHERE kod1c='+inttostr(resid)+' AND dolg='+quotedstr(resstr)+';');
  //showmessage(ZQuery1.SQL.text);
    try
      ZQuery1.open;
    except
        showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
       Zconnection1.disconnect;
       ZQuery1.Close;
    end;
   if ZQuery1.RecordCount>1 then
     begin
       showmessagealt('Найдено более одной записи с выбранными данными !!!');
       //ZQuery1.close;
       //ZConnection1.Disconnect;
       //exit;
     end;
   if ZQuery1.RecordCount<1 then
     begin
       ZQuery1.close;
       ZConnection1.Disconnect;
       exit;
     end;
//очищаем
    Edit2.Text:='';//имя
    Edit5.Text:='';//пароль
    memo1.Text:='';
//проставляем
    combobox2.ItemIndex:=0;//сотрудник
    Edit3.Text :=ZQuery1.FieldByName('name').AsString;
    Edit2.Text :=UTf8copy(Edit3.Text,1,utf8pos(#32,Edit3.Text)-1);
    Edit2.SetFocus;
    Edit6.Text :=ZQuery1.FieldByName('dolg').AsString;
    Edit8.Text :=ZQuery1.FieldByName('kod1c').AsString;
    //nkodpodr :=ZQuery1.FieldByName('kodpodr').AsString;
    //Edit10.Text:= nkodpodr;
    dateedit1.Text:=ZQuery1.FieldByName('datr').AsString;
    //combobox1.Items.Text:=ZQuery1.FieldByName('pol').AsString;
    gender:=utf8copy(Upperall(ZQuery1.FieldByName('pol').AsString),1,1);
    If (gender='М') then Combobox1.ItemIndex:=0 else Combobox1.ItemIndex:=1;
    ZQuery1.close;
    ZConnection1.Disconnect;
end;


//******************************* ВЫБРАТЬ ИЗ КоНТРАГЕНТОВ ******************************
procedure TForm_edit.BitBtn9Click(Sender: TObject);
begin
  resid:=0;
  resstr:='';
  form_mode:=2;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);
 If (resid=0) or (trim(resstr)='') then exit;

   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('select tablename FROM pg_tables WHERE tablename=''av_1c_contr'';');
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
  ZQuery1.SQL.add('SELECT distinct * FROM av_1c_contr WHERE kod1c='+inttostr(resid)+' AND polname='+quotedstr(resstr)+';');
  //showmessage(ZQuery1.SQL.text);
    try
      ZQuery1.open;
    except
        showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
       Zconnection1.disconnect;
       ZQuery1.Close;
    end;
   if ZQuery1.RecordCount>1 then
     begin
       showmessagealt('Найдено более одной записи с выбранными даннымы !!!');
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

   //очищаем
    Edit2.Text:='';//имя
    Edit5.Text:='';//пароль
    memo1.Text:='';
    //проставляем
    combobox2.ItemIndex:=1;//контрагент
    Edit3.Text :=ZQuery1.FieldByName('polname').AsString;
    Edit2.Text :=UTf8copy(Edit3.Text,1,utf8pos(#32,Edit3.Text)-1);
    Edit2.SetFocus;
    Edit6.Text :=ZQuery1.FieldByName('vidkontr').AsString;
    Edit8.Text :=ZQuery1.FieldByName('kod1c').AsString;
    //nkodpodr :=ZQuery1.FieldByName('podr').AsString;
    //Edit10.Text:= nkodpodr;
    //dateedit1.Text:=ZQuery1.FieldByName('datr').AsString;
    //combobox1.Items.Text:=ZQuery1.FieldByName('pol').AsString;
end;


procedure TForm_edit.ComboBox1Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.ComboBox2Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.ComboBox3Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;


procedure TForm_edit.BitBtn1Click(Sender: TObject);
begin
  With form_edit do
begin
   OpenPictureDialog1.Execute;
   Edit11.Text:=OpenPictureDialog1.FileName;
   Image2.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;
end;

//************************************************* ВЫХОД *******************************************
procedure TForm_edit.BitBtn2Click(Sender: TObject);
begin
   if fl_edit then
    begin
      if MessageDlg('Все совершенные действия НЕ будут сохранены !'+#13+'Подтверждаете выход?',mtConfirmation, mbYesNo, 0)=6 then
       begin
         fl_edit:=false;
         Form_edit.Close;
       end;
      exit;
    end;
   Form_edit.Close;
end;


//*****************  кнопка СДЕЛАТЬ СНИМОК С WEВки ***************************************************************
procedure TForm_Edit.BitBtn4Click(Sender: TObject);
begin
  // Делаем фото
   {$IFDEF LINUX}
 fpsystem('ffmpeg -t 1 -f video4linux2 -s 640x480 -r 30 -i /dev/video0 -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s 640x480 -r 30 -i /dev/video0 -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s 640x480 -r 30 -i /dev/video0 -f image2 webcam.jpg');
    {$ENDIF}
 if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'webcam.jpg') then
   begin
 Form_edit.image2.Picture.LoadFromFile('webcam.jpg');
 form_edit.Edit11.text:=ExtractFilePath(Application.ExeName)+'webcam.jpg';
   end;
end;



//************************************************** СОХРАНИТЬ ***************************************************
procedure TForm_edit.BitBtn5Click(Sender: TObject);
var
 snol: string;
 BlobStream,FileStream: TStream;
 newid:integer=0;
 n:integer=0;
 lg:boolean=false;
begin
  with Form_Edit do
     begin
  //проверка заполнения обязательных полей и корректности ввода данных
       //имя

   If checkbox1.Checked then
     begin
        showmessagealt('Запрещено сохранять данные удаленного пользователя !');
       exit;
     end;
  if (trim(Edit2.text)='') then
  begin
       showmessagealt('Обязательно для заполнения поле - ИМЯ - пустое !');
       exit;
   end;
  if (trim(Edit5.text)='') then
  begin
       showmessagealt('Обязательно для заполнения поле - ПАРОЛЬ - пустое !');
       exit;
   end;

  for n:=0 to Stringgrid1.RowCount-1 do
    If Stringgrid1.Cells[2,Stringgrid1.Row]='1' then
      begin
        lg:=true;
        break;
      end;
 If not lg then
   begin
       showmessagealt('Выберите хотя бы одну группу для пользователя !');
       exit;
   end;

 If not fl_edit then
   begin
       showmessagealt('Сначала внесите изменения !');
       exit;
   end;

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
    snol:=QuotedStr('');

       If fl_open=1 then
         begin
      //****** проверяем на полный дубляж
       ZQuery1.SQL.Clear;
       ZQuery1.Sql.Add('Select id from av_users WHERE del=0 AND name='+QuotedStr(trim(edit2.text)));
       //IF trim(DateEdit1.Text)='' then ZQuery1.SQL.add(' AND birthday='+QuotedStr(trim(DateEdit1.Text)));
       //IF trim(Edit5.Text)<>'' then ZQuery1.SQL.add(' AND passw='+QuotedStr(trim(edit5.text)));
       //IF trim(Edit3.Text)<>'' then ZQuery1.SQL.add(' AND fullname='+QuotedStr(trim(edit3.text)));
       //IF trim(ComboBox1.Text)<>'' then ZQuery1.SQL.add(' AND pol='+QuotedStr(trim(ComboBox1.text)));
       //IF trim(Edit6.Text)<>'' then ZQuery1.SQL.add(' AND dolg='+QuotedStr(trim(edit6.text)));
       If trim(Edit8.Text)<>'' then ZQuery1.SQL.add(' AND kod1c='+Edit8.Text);
                                        //' AND tip='+ IntToStr(ComboBox2.ItemIndex));
       //IF (trim(Memo1.Text)<>'') then ZQuery1.SQL.add(' AND info='+QuotedStr(trim(Memo1.text)));
       ZQuery1.SQL.add(';');
       try
       ZQuery1.Open;
       except
         showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
         Zconnection1.disconnect;
         exit;
       end;
       If ZQuery1.RecordCount>0 then
         begin
          showmessagealt('Операция СОХРАНЕНИЯ невозможна !'+#13+'Пользователь с таким именем уже существует !');
          exit;
         end;
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

       //если режим добавления  рассчитываем новый id
       If fl_open=1 then
       begin
        ZQuery1.SQL.Clear;
        ZQuery1.Sql.Add('Select max(id) from av_users where id<99999;');
        ZQuery1.Open;
        If ZQuery1.Fields[0].AsString='' then nuser:='1'
        else
        begin
        nuser:=ZQuery1.Fields[0].AsString;
        Edit4.Text:=nuser;
        try
          newid := strtoint(nuser)
        except
          showmessagealt('Ошибка ! Некорректное ID !!!');
           ZConnection1.Rollback;
        end;
        newid := newid+1;
        nuser := inttostr(newid);
        end;
       end;
   //Если режим редактирования, сначала помечаем запись на удаление
    If fl_open=2 then
     begin
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_group SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_servers SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users_podr SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         ZQuery1.ExecSQL;
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_users SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+nuser+';');
         ZQuery1.ExecSQL;
     end;

    //записываем в таблицу группы-юзеры
    for n:=0 to Stringgrid1.RowCount-1 do
      begin
        If Stringgrid1.Cells[2,n]='1' then
          begin
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.add('INSERT INTO av_users_group(group_id, user_id, createdate, id_user, del, id_user_first, createdate_first) VALUES (');
        ZQuery1.SQL.add(Stringgrid1.Cells[0,n]+','+nuser+',now(),'+GLuser+',0,'+GLuser+',now())');
        ZQuery1.ExecSQL;
        end;
      end;
    //записываем в таблицу сервера-юзеры
    for n:=0 to Stringgrid2.RowCount-1 do
      begin
        If Stringgrid2.Cells[2,n]='1' then
          begin
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.add('INSERT INTO av_users_servers(server_id, user_id, createdate, id_user, del, id_user_first, createdate_first) VALUES (');
        ZQuery1.SQL.add(Stringgrid2.Cells[0,n]+','+nuser+',now(),'+GLuser+',0,'+GLuser+',now())');
        ZQuery1.ExecSQL;
        end;
      end;
    //записываем в таблицу подразделения-юзеры
    for n:=0 to Stringgrid3.RowCount-1 do
      begin
        If Stringgrid3.Cells[2,n]='1' then
          begin
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.add('INSERT INTO av_users_podr(podr_id, user_id, createdate, id_user, del, id_user_first, createdate_first) VALUES (');
        ZQuery1.SQL.add(Stringgrid3.Cells[0,n]+','+nuser+',now(),'+GLuser+',0,'+GLuser+',now())');
        ZQuery1.ExecSQL;
        end;
      end;

   //записываем в таблицу юзеров
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('INSERT INTO av_users(id,id_user,createdate,name,birthday,passw,foto,fullname,');
   ZQuery1.SQL.add('pol,dolg,status,kod1c,tip,info,category,id_user_first,createdate_first,del) VALUES (');
   ZQuery1.SQL.add(nuser+','+GLuser+',now(),');//id
   ZQuery1.SQL.add(QuotedStr(trim(edit2.text))+','+ IFTHEN(trim(DateEdit1.Text)='','NULL',QuotedStr(trim(DateEdit1.Text)))+','+
                                                           IFTHEN(trim(Edit5.Text)='',snol,QuotedStr(trim(edit5.text)))+','+'NULL,'+
                                                           IFTHEN(trim(Edit3.Text)='',snol,QuotedStr(trim(edit3.text)))+','+
                                                           IFTHEN(trim(ComboBox1.Text)='',ComboBox1.Items[1],QuotedStr(trim(ComboBox1.text)))+','+
                                                           IFTHEN(trim(Edit6.Text)='',snol,QuotedStr(trim(edit6.text)))+','+
                                                           //IFTHEN(trim(Edit12.Text)='','0',ngrup)+','+
                                                           IntToStr(ComboBox3.ItemIndex)+','+
                                                           IFTHEN(trim(Edit8.Text)='','0',Edit8.Text)+','+
                                                           IntToStr(ComboBox2.ItemIndex)+',');
  ZQuery1.SQL.add(IFTHEN(trim(Memo1.Text)='',snol,QuotedStr(trim(Memo1.text)))+','+inttostr(Combobox4.ItemIndex)+',');
   //режим добавления
   If fl_open=1 then
     ZQuery1.SQL.add(GLuser+',now(),0);');
   //режим редактирования
   If fl_open=2 then
     ZQuery1.SQL.add('NULL,NULL,0);');
  //showmessage(ZQuery1.SQL.text);
  ZQuery1.ExecSQL;


  // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     showmessage('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
 end;
     fl_edit := false; //флаг изменений

 // Записываем фотку если есть
 if FileExistsUTF8(trim(Edit11.text)) then
  begin
     //ZQuery1.SQL.Clear;
     //ZQuery1.SQL.Add('SELECT * from av_users WHERE del=0 AND id='+nuser+';');
     //  try
     //  ZQuery1.open;
     //except
     //  showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     //  ZQuery1.Close;
     //  Zconnection1.disconnect;
     //  exit;
     //end;
    ZQuery1.Close;
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.Add('update av_users set foto=:blob where del=0 AND id='+nuser+';');
       ZQuery1.ParamByName('blob').LoadFromFile(trim(Edit11.text),ftBlob);
       showmessage(ZQuery1.SQL.text);
  try
       ZQuery1.ExecSQL;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
       exit;
     end;

   //end;
   end;
   ZQuery1.close;
   Zconnection1.disconnect;
   showmessagealt('Транзакция завершена УСПЕШНО !');
   Bitbtn8.SetFocus;
   If fl_open=1 then ClearFields()
   else Form_edit.Close;

     end;
end;


procedure TForm_edit.BitBtn6Click(Sender: TObject);
begin
    ClearFields();//очистить поля
   fl_edit := true; //флаг изменений
end;


procedure TForm_edit.DateEdit1Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;


procedure TForm_edit.Edit11Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;


procedure TForm_edit.Edit2Change(Sender: TObject);
begin
  fl_edit := true; //флаг изменений
end;

procedure TForm_edit.Edit3Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.Edit5Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.Edit6Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.Edit8Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;


procedure TForm_edit.Memo1Change(Sender: TObject);
begin
   fl_edit := true; //флаг изменений
end;

procedure TForm_edit.StringGrid1SelectCell(Sender: TObject; aCol,  aRow: Integer; var CanSelect: Boolean);
begin
  //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  If (aCol<2) then CanSelect:= false;
end;

procedure TForm_edit.StringGrid1SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
begin
  //установка чеков в гриде
   with (Sender as TStringGrid) do
begin
  If RowCount<1 then exit;
  if cells[2,aRow]='1' then cells[2,arow]:='0' else cells[2,arow]:='1';
  fl_edit := true; //флаг изменений
  end;
end;

procedure TForm_edit.StringGrid2SelectCell(Sender: TObject; aCol,  aRow: Integer; var CanSelect: Boolean);
begin
    //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  If (aCol<2) then CanSelect:= false;
end;

procedure TForm_edit.StringGrid2SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
begin
    //установка чеков в гриде
   with (Sender as TStringGrid) do
begin
  If RowCount<1 then exit;
  if cells[2,aRow]='1' then cells[2,arow]:='0' else cells[2,arow]:='1';
  fl_edit := true; //флаг изменений
  end;
end;

procedure TForm_edit.StringGrid3SelectCell(Sender: TObject; aCol,  aRow: Integer; var CanSelect: Boolean);
begin
  //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  If (aCol<2) then CanSelect:= false;
end;

procedure TForm_edit.StringGrid3SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
begin
    //установка чеков в гриде
   with (Sender as TStringGrid) do
begin
  If RowCount<1 then exit;
  if cells[2,aRow]='1' then cells[2,arow]:='0' else cells[2,arow]:='1';
  fl_edit := true; //флаг изменений
  end;
end;

//*********************************            ВОЗНИКНОВЕНИЕ ФОРМЫ ***************************************
procedure TForm_edit.FormShow(Sender: TObject);
begin
  CentrForm(Form_Edit);

  with Form_edit do
begin
   StringGrid1.Columns[2].ValueChecked:='1';
    StringGrid1.Columns[2].ValueUnchecked:='0';
    StringGrid2.Columns[2].ValueChecked:='1';
    StringGrid2.Columns[2].ValueUnchecked:='0';
    StringGrid3.Columns[2].ValueChecked:='1';
    StringGrid3.Columns[2].ValueUnchecked:='0';

  If fl_open=2 then
    begin
     nuser:= Form_users.StringGrid1.Cells[0,Form_users.StringGrid1.row];

      //UpdateServers();    // обновить combo с серверами
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //запрос списка
    ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_users WHERE del='+Form_users.StringGrid1.Cells[5,Form_users.StringGrid1.row]+' AND id='+nuser);
   ZQuery1.SQL.add(' AND (date_part(''epoch'', timestamp_mi(createdate,timestamp'+QuotedStr(Form_users.StringGrid1.Cells[6,Form_users.StringGrid1.row])+'))<1);');
     try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
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
    Edit4.Text := nuser;//ZQuery1.FieldbyName('id').AsString;
    Edit2.Text := ZQuery1.FieldbyName('name').AsString;
    Label3.Caption := ZQuery1.FieldbyName('createdate').AsString;
    dateedit1.date:=ZQuery1.FieldbyName('birthday').Asdatetime;
    Edit5.Text:= ZQuery1.FieldbyName('passw').AsString;
    Edit3.Text:= ZQuery1.FieldbyName('fullname').AsString;
            //*** определяем пол ******
    If UPPERALL(copy(trim(ZQuery1.FieldbyName('pol').AsString),1,2))=UPPERALL(copy(Combobox1.Items[1],1,2)) then
          Combobox1.ItemIndex:=1  else  Combobox1.ItemIndex:=0;
    Edit6.Text:= ZQuery1.FieldbyName('dolg').AsString;
    ComboBox3.ItemIndex:=ZQuery1.FieldbyName('status').AsInteger;
    Edit8.Text:= ZQuery1.FieldbyName('kod1c').AsString;
    ComboBox2.ItemIndex:=ZQuery1.FieldbyName('tip').AsInteger;//tip   сотрудник - контрагент
    memo1.Text:=ZQuery1.FieldbyName('info').AsString;//info
    If ZQuery1.FieldbyName('del').AsInteger=2 then // признак удаления
                begin
                Label1.Visible:=true;
                checkbox1.Visible:=true;
                checkbox1.Checked:=true;
                end
             else
                begin
                Label1.Visible:=false;
                checkbox1.Checked:=false;
                checkbox1.Visible:=false;
                end;

   //******************ЗАГРУЗИТЬ ФОТКУ
    //ZQuery1.SQL.Clear;
    //   ZQuery1.SQL.text:=('SELECT * from av_users where del=0 AND id='+ nuser+';');
    //  try
    //     ZQuery1.open;
    //  except
    //     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
    //      Zconnection1.disconnect;
    //      ZQuery1.Close;
    //   end;
      if (ZQuery1.FieldByName('foto').IsBlob) then
         begin
         BlobStream :=  ZQuery1.CreateBlobStream( ZQuery1.FieldByName('foto'), bmRead);
          If BlobStream.Size>10 then
             begin
           try
             FileStream:= TFileStream.Create('foto.jpg', fmCreate);
               try
                FileStream.CopyFrom(BlobStream, BlobStream.Size);
               finally
                FileStream.Free;
               end;
           finally
            BlobStream.Free;
           end;
            image2.Picture.LoadFromFile('foto.jpg');
            Edit11.Text:= ExtractFilePath(Application.ExeName)+'foto.jpg';;
             end;
        end;
       //принадлежность пользователя
       ComboBox4.ItemIndex:= ZQuery1.FieldByName('category').AsInteger;
    end;
  UpdateGrup();//группы
  UpdateServers();    // обновить grid с серверами
  UpdateFilial(); //обновить grid с подразделениями
   //Инициализируем флаг наличия изменений
  fl_edit:=false;
end;

end;


end.


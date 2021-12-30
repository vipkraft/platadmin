unit LocalSettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IniPropStorage, point_main;

type

  { TFormSets }

  TFormSets = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn21: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn34: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn8: TBitBtn;
    Dialog1: TSelectDirectoryDialog;
    Edit1: TEdit;
    Edit11: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image1: TImage;
    Image3: TImage;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label5: TLabel;
    Label54: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RadioGroup1: TRadioGroup;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn34Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Sets(path:widestring);//Проверка наличия файла настроек и определение элементов формы
    procedure readini(); // Процедура чтения INI файла **************************

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormSets: TFormSets;

implementation
uses
  main,platproc;

var
  pnt:string='';

{$R *.lfm}

{ TFormSets }


//***************************    Процедура чтения INI файла **************************
procedure TFormSets.readini();
begin
//Определяем начальные установки соединения с сервером
  if not ReadIniLocal(formSets.IniPropStorage1,inipath+'local.ini') then
     begin
       showmessagealt('Не найден файл настроек по заданному пути!');
       exit;
     end;

    // Чтение из INI
  With formSets do
   begin
    // central
    edit2.text:= ConnectINI[1];//c_ip
    Edit13.Text:=ConnectINI[2];//c_port
    edit4.text:= ConnectINI[3];//c_name
    //local
    edit3.text:= ConnectINI[4];//l_ip
    Edit14.Text:=ConnectINI[5];//l_port
    edit17.text:=ConnectINI[6];//l_name
   //emu
    edit5.text:= ConnectINI[8];//c_ip
    Edit15.Text:=ConnectINI[9];//c_port
    edit7.text:= ConnectINI[10];//c_name
    edit6.text:= ConnectINI[11];//l_ip
    Edit16.Text:=ConnectINI[12];//l_port
    edit18.text:=ConnectINI[13];//l_name
   //local settings
    edit11.text:=ConnectINI[7];
    pnt :=  ConnectINI[14];
    edit20.text:= pnt;
    If ConnectINI[15]='CENTRAL' then RadioGroup1.ItemIndex:=0;
    If ConnectINI[15]='LOCAL' then RadioGroup1.ItemIndex:=1;

  end;
end;


//*************************    Проверка наличия файла настроек и определение элементов формы  *****************************
procedure TFormSets.Sets(path: widestring);
begin
  if trim(path)='' then
    begin
      // put:= getcurrentdirutf8();
      path:=ExtractFilePath(Application.ExeName);
    end;
  if FileExistsUTF8(ExtractFilePath(path)+'local.ini') then
   begin
      formSets.edit1.text:=path;
      inipath:= path;
       //чтение из файла
      ReadIni();
      BitBtn5.enabled:=false;
      BitBtn4.enabled:=true;
      GroupBox1.Enabled:=true;
      GroupBox2.Enabled:=true;
      GroupBox3.Enabled:=true;
    end
  else
  begin
     showmessagealt('Не найден файл настроек по заданному пути!');
     BitBtn5.enabled:=true;
  end;
end;


procedure TFormSets.BitBtn14Click(Sender: TObject);
begin
  FormSets.Close;
end;

//******************************************* УКАЗАТЬ ПУТЬ К ФАЙЛУ НАСТРОЕК ************************************
procedure TFormSets.BitBtn1Click(Sender: TObject);
begin
  FormSets.dialog1.Execute;
   //Добавляем черту, если надо
  formSets.edit1.Text:=IncludeTrailingPathDelimiter(FormSets.dialog1.FileName); //для Win ='\' Linux='/'
  FormSets.Sets(formSets.edit1.Text);
end;

//**************************************************  ЗАГРУЗИТЬ ИЗ ФАЙЛА *********************************************************
procedure TFormSets.BitBtn21Click(Sender: TObject);
begin
  readini();
end;

// ********************************************   ТЕСТ соединения РЕАЛЬНЫЙ **********************************************
procedure TformSets.BitBtn2Click(Sender: TObject);
 var
   log_test:string;
begin
   log_test:='';

   //Соединяемся с Центральным сервером
   try
     MConnect(Zconnection1,formSets.Edit2.text,strtoint(formSets.Edit13.text),formSets.Edit4.text);
     formSets.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit2.text+':'+formSets.Edit13.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit2.text+':'+formSets.Edit13.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   formSets.Zconnection1.disconnect;

    //Соединяемся с Локальным сервером
   MConnect(Zconnection1,formSets.Edit3.text,strtoint(formSets.Edit14.text),formSets.Edit17.text);
   //formSets.ZConnection1.hostname:=formSets.Edit3.text;
   try
     formSets.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit3.text+':'+formSets.Edit14.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit3.text+':'+formSets.Edit14.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   formSets.Zconnection1.disconnect;

   showmessagealt(log_test);
end;

//выбрать остановочный пункт из списка серверов ******************************
procedure TFormSets.BitBtn34Click(Sender: TObject);
begin
    // //ОСТАНОВОЧНЫЕ ПУНКТЫ
     form9:=Tform9.create(self);
     form9.ShowModal;
     FreeAndNil(form9);
     //Добавляем остановочный пункт
     if (result_name_point='') then exit;
      pnt := result_name_point; //id остановочного пункта
    formSets.Edit20.Text := name_pnt; // наименование остановочного пункта сервера
end;


// ********************************************   ТЕСТ соединения ЭМУЛИРУЕМЫЙ **********************************************
procedure TformSets.BitBtn3Click(Sender: TObject);
 var
   log_test:string;
begin
   log_test:='';

   //Соединяемся с Центральным Тестовым сервером Postgree
   try
     MConnect(Zconnection1,formSets.Edit5.text,strtoint(formSets.Edit15.text),formSets.Edit7.text);
     formSets.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit5.text+':'+formSets.Edit15.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit5.text+':'+formSets.Edit15.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   formSets.Zconnection1.disconnect;

   //Соединяемся с Локальным Тестовым сервером Postgree
   try
     MConnect(Zconnection1,formSets.Edit6.text,strtoint(formSets.Edit16.text),formSets.Edit18.text);
     formSets.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit6.text+':'+formSets.Edit16.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+formSets.Edit6.text+':'+formSets.Edit16.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   formSets.Zconnection1.disconnect;

   showmessagealt(log_test);
end;

// *********************************      ЗАПИСАТЬ ini       ***************************************************
procedure TFormSets.BitBtn4Click(Sender: TObject);
begin
  //Обновление записей ini файла
  with FormSets.IniPropStorage1 do
   begin
     inifilename:=formSets.edit1.Text+'local.ini';
     IniSection:='CENTRAL SERVER SQL'; //указываем секцию
     WriteString('ip_central',formSets.edit2.text);
     WriteString('port_central',formSets.Edit13.Text);
     WriteString('name_base',formSets.edit4.text);
     IniSection:='LOCAL SERVER SQL'; //указываем секцию
     WriteString('ip_local',formSets.edit3.text);
     WriteString('port_local',formSets.Edit14.Text);
     WriteString('name_base_local',formSets.edit17.text);
     IniSection:='EMU SERVER SQL'; //указываем секцию
     WriteString('ip_central',formSets.edit5.text);
     WriteString('port_central',formSets.Edit15.Text);
     WriteString('ip_local',formSets.edit6.text);
     WriteString('port_local',formSets.Edit16.Text);
     WriteString('name_base_local',formSets.edit18.text);
     IniSection:='LOCAL SETTINGS'; //указываем секцию
     WriteString('load_1c',formSets.edit11.text);
     WriteString('id_point_local',pnt);
     If RadioGroup1.ItemIndex=0 then
        WriteString('Auth_server','CENTRAL') //сервер аутентификации
     else
        WriteString('Auth_server','LOCAL');//сервер аутентификации
   end;
   inipath := formSets.edit1.Text;//обновляем глобальную переменную
   showmessagealt('Файл local.ini успешно обновлен');
end;


//  ******************************************** СОЗДАТЬ  ********************************************
procedure TFormSets.BitBtn5Click(Sender: TObject);
var
  path:string='';
begin
  // Проверяем что путь задан для создания local.ini
  path:=formSets.edit1.Text;
  if trim(path)='' then
    begin
       path:=ExtractFilePath(Application.ExeName);
   begin
     If MessageDlg('НЕ УКАЗАН ПУТЬ К ФАЙЛУ НАСТРОЕК !'+#13+'Файл будет создан в папке с программой...'+#13+'    Продолжить ?',mtConfirmation, mbYesNo, 0)=7 then  exit;
   end;
    end;

  if FileExistsUTF8(ExtractFilePath(path)+'local.ini') then
   If MessageDlg('Вы действительно хотите переписать файл настроек значениями по умолчанию?',mtConfirmation, mbYesNo, 0)=7 then exit;

  // Создаем local.ini с значениями по дефолту
  // Запись в INI
   with formSets.IniPropStorage1 do
    begin
      inifilename:=formSets.edit1.Text+'local.ini';
      IniSection:='CENTRAL SERVER SQL'; //указываем секцию
      WriteString('ip_central','10.10.10.10');
      WriteString('port_central','5432');
      WriteString('name_base','platforma');
      IniSection:='LOCAL SERVER SQL'; //указываем секцию
      WriteString('ip_local','172.27.1.5');
      WriteString('port_local','5432');
      WriteString('name_base_local','platforma');
      IniSection:='EMU SERVER SQL'; //указываем секцию
      WriteString('ip_central','30.30.30.30');
      WriteString('port_central','5432');
       WriteString('name_base','platforma_emu');
      WriteString('ip_local','31.31.31.31');
      WriteString('port_local','5432');
      WriteString('name_base_local','platforma');
      IniSection:='LOCAL SETTINGS'; //указываем секцию
      WriteString('load_1c','/home/egor'); //путь загрузки из 1с
      WriteString('id_point_local','0'); //место продажи
      WriteString('Auth_server','LOCAL');//сервер аутентификации

    end;
    // Активируем эелементы
    with formSets do
    begin
    BitBtn5.enabled:=false;
    BitBtn4.enabled:=true;
    GroupBox1.Enabled:=true;
    GroupBox2.Enabled:=true;
    GroupBox3.Enabled:=true;
    readini();
    end;

end;


//******************************************* УКАЗАТЬ ПУТЬ К ФАЙЛУ C DBF ************************************
procedure TFormSets.BitBtn8Click(Sender: TObject);
begin
   FormSets.dialog1.Execute;
  formSets.edit11.Text:=FormSets.dialog1.FileName;
    formSets.bitbtn5.Enabled:=true;
end;

//проверка на закрытии формы
procedure TFormSets.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
If formSets.bitbtn5.Enabled then
      if dialogs.MessageDlg('Сохранить изменения в настройках ?',mtConfirmation,[mbYes,mbNO], 0)=6 then
        begin
          //CloseAction := caNone;
          //exit;
          FormSets.BitBtn4.Click;
        end;
end;


procedure TFormSets.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  //************************************************ HOT KEYS  ****************************************
 // F1
    if (Key=112) then showmessagealt('[F1] - Справка'+#13+'[F5] - Обновить'+#13+'[ESC] - Выход');
    //F5 - Добавить
    //if (Key=116) then FormLog.BitBtn30.Click;
    // ESC
    if (Key=27) then FormSets.Close;

    If (Key=27) OR (Key=112) OR (Key=116) then Key:=0;
end;

procedure TFormSets.FormShow(Sender: TObject);
begin
  centrform(FormSets);
  FormSets.Sets(inipath);
end;


end.


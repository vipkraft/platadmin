unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, LazUTF8, IniPropStorage, DateUtils, Accesslog, Consol, point_main, spr_grup, spr_menu,
  spr_option, spr_arms, arm, webka, sync_table, spr_otd_podr, localsettings, Dbf_import, users_main, Servers, ExtPersonal, spr_vars, message_idle,
  sync_log, spr_update, version_info, genagent, web_users, web_options, auth;

type

  { TFormMain }

  TFormMain = class(TForm)
    Dialog1: TSelectDirectoryDialog;
    GroupBox4: TGroupBox;
    IdleTimer1: TIdleTimer;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    Timer1: TTimer;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1Exit(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid2DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid2Exit(Sender: TObject);
    procedure StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid2Selection(Sender: TObject; aCol, aRow: Integer);
    procedure subMenuLoad();//Загрузка подменю выбранного меню
    procedure Timer1Timer(Sender: TObject);
    procedure run_form();//Разбираем и запускаем пункты меню  *******************************************
    procedure ShowSettings();//показать окно файла настроек
    function wlog(M1:TMemo; str1:string): boolean;//запись лога в мемо и файл

  private
    { private declarations }
  public
    { public declarations }
    procedure MyExceptionHandler(Sender : TObject; E : Exception); //ОБРАБОТЧИК ИСКЛЮЧЕНИЙ  *********
  end;

 const
    timeout_signal=300; //предудпреждение перед закрытием

var
  FormMain: TFormMain;
  GLuser, GLarm,sgrup,ngrup : string;
  flag_access,flagprofile:byte;
  fl_edit_option:integer=0;
  inipath : widestring='';
  form_mode: byte=0;
  users_mode: byte=0;
  skodpodr,nserv_id,nkodpodr: string;
  resid : integer=0;
  resstr : string='';
  //webname:string;
  webid:integer;
  // masedit: array[0..20] of string;
  // nUserFlag : integer;
  timeout_global:integer=0;  //счетчик таймер бездействия (перед окном закрытия форм операций)
  timeout_local:integer=0;
  Info:string='';
  flclose:boolean=true; //закрывать формы
  skodotd,nkodotd: string;
  namelog:string;

implementation
uses platproc;

{$R *.lfm}

{ TFormMain }

// Альтернативный ShowMessage
function TFormMain.wlog(M1:TMemo; str1:string): boolean;
var
//i:integer;
//MyMesDlg:TForm;
//MyComponent:TButton;
//E:TBitBtn;
//log_file: textfile;
ns:integer;
fsOut: TFileStream;
//namelog:string='';
mempos:tpoint;
begin

// По умолчанию результат неудачный
result := false;

M1.Lines.Add(trim(str1));
mempos.x:=0;
mempos.y:=M1.Lines.Count-1;
M1.CaretPos:=mempos;
M1.SelStart:=length(M1.Text);
M1.SelLength:=0;
//application.ProcessMessages;
  str1:=str1+#13;
  // Записать данную строку в файл, перехватывая ошибки в процессе записи.
  try
    fsOut := TFileStream.Create(namelog,fmOpenWrite );
    fsOut.Position:=fsOut.Size;
    fsOut.Write(Str1[1], length(Str1));
    fsOut.Free;

    // На данном этапе известно, что запись прошла успешно.
    result := true

  except
    on E:Exception do
      M1.Lines.Add('Строка не записана. Детали: '+E.ClassName+': '+ E.Message);
  end
end;


//************************************ ОБРАБОТЧИК ИСКЛЮЧЕНИЙ  **************************************
procedure TFormMain.MyExceptionHandler(Sender : TObject; E : Exception);
begin
  showmessagealt('Ошибка программы !!!'+#13+'Сообщение: '+E.Message+#13+'Модуль: '+E.UnitName);
  E.Free;
end;


//*******************      показать окно файла настроек    **************************
procedure TFormMain.ShowSettings();
begin
  formSets:=TformSets.create(self);
  formSets.Showmodal;
  FreeAndNil(formSets);
end;

//**********  ***************    Разбираем и запускаем пункты меню   *******************************************
procedure TFormMain.run_form();
begin
  with FormMain do
begin
    //Определяем доступ
   flag_access:=1; //только чтение
  if trim( Stringgrid2.Cells[0, Stringgrid2.row])='2' then
     begin
       flag_access:=2; //доступ на чтение и запись
     end;

// Запускаем модули
 //******* СИСТЕМНЫЕ СПРАВОЧНИКИ *****************
//  // ПОЛЬЗОВАТЕЛИ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='39') then
     begin
       users_mode:=0;
        form_users:=Tform_users.create(self);
        form_users.Showmodal;
        FreeAndNil(form_users);
     end;
//  // ЛОКАЛЬНЫЕ СЕРВЕРА
  if (trim( stringgrid1.Cells[2,stringgrid1.row])='40') then
     begin
         formServers:=TformServers.create(self);
         formServers.Showmodal;
         FreeAndNil(formServers);
     end;
//  // АРМ-Ы
  if (trim( stringgrid1.Cells[2,stringgrid1.row])='41') then
     begin
       form6:=Tform6.create(self);
       form6.Showmodal;
       FreeAndNil(form6);
     end;//
//    // ОПЦИИ АРМ-В
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='42') then
     begin
       fl_edit_option:=2;
       Form7:=TForm7.Create(self);
       form7.showmodal;
       FreeAndNil(form7);
     end;
//
//  //МЕНЮ АРМ-В
  if (trim( stringgrid1.Cells[2, stringgrid1.row])='43') then
     begin
        FormMenu:=TFormMenu.Create(self);
        formMenu.showmodal;
        FreeAndNil(formMenu);
     end;
//
//  // ГРУППЫ ПОЛЬЗОВАТЕЛЕЙ
 if (trim( stringgrid1.Cells[2,stringgrid1.row])='44') then
    begin
      FormGroups:=TFormGroups.Create(self);
      formGroups.showmodal;
      FreeAndNil(formGroups);
    end;
//
// //ОСТАНОВОЧНЫЕ ПУНКТЫ
if (trim(stringgrid1.Cells[2,stringgrid1.row])='45') then
   begin
     form9:=Tform9.create(self);
     form9.ShowModal;
     FreeAndNil(form9);
   end;
//
//// ЗАПРЕЩЕННЫЕ ДЛЯ СЕРВЕРОВ ЮЗЕРЫ
if (trim( stringgrid1.Cells[2, stringgrid1.row])='46') then
  begin
    Users_mode:=1;
    form_Users:=Tform_users.create(self);
    form_Users.ShowModal;
    FreeAndNil(form_users);
  end;
//
//// ЗАПРЕЩЕННЫЕ ДЛЯ РАСПИСАНИЙ ПОЛЬЗОВАТЕЛИ
if (trim( stringgrid1.Cells[2,stringgrid1.row])='47') then
  begin
    Users_mode:=2;
    form_users:=Tform_users.create(self);
    form_users.ShowModal;
    FreeAndNil(form_users);
  end;
//// ПЕРЕМЕННЫЕ ШАБЛОНОВ ВЫХОДНЫХ ЧЕКОВ
if (trim(stringgrid1.Cells[2,stringgrid1.row])='58') then
  begin
    formVars:=TformVars.create(self);
    formVars.ShowModal;
    FreeAndNil(formVars);
  end;
//========================================
//=========== СПРАВОЧНИКИ ОРГАНИЗАЦИИ ============
//// Справочник СОТРУДНИКИ
if (trim(stringgrid1.Cells[2,stringgrid1.row])='48') then
  begin
    form_mode:=1;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);
  end;
//
  // СПРАВОЧНИК КОНТРАГЕНТОВ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='49') then
     begin
       form_mode:=2;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);
     end;

    // СПРАВОЧНИК ПЕРЕВОЗЧИКОВ ПЛАТФОРМА
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='114') then
     begin
       form_mode:=3;
    FormSpr:=TFormSpr.create(self);
    FormSpr.ShowModal;
    FreeAndNil(FormSpr);
     end;

//  // ОТДЕЛЕНИЯ/ПОДРАЗДЕЛЕНИЯ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='50') then
     begin
       formOtd:=TformOtd.create(self);
       formOtd.Showmodal;
       FreeAndNil(formOtd);
     end;
  //===============================================================
//=========================== WEB ===========================
  //web пользователи
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='112') then
     begin
       form_Webusr:=Tform_Webusr.create(self);
       form_Webusr.Showmodal;
       FreeAndNil(form_Webusr);
     end;

  //  //web услуги
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='113') then
     begin
       //ShowSettings();
       webid:=0;
       //webname:='';
       formWO:=TformWO.create(self);
       formWO.Showmodal;
       FreeAndNil(formWO);
     end;
//===============================================================
//=========================== НАСТРОЙКИ ===========================
  // Синхронизация данных
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='51') then
     begin
       form8:=Tform8.create(self);
       form8.Showmodal;
       FreeAndNil(form8);
     end;

  //  // Локальные настройки
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='52') then
     begin
       ShowSettings();
     end;
//===================================================================
//========================== ДОПОЛНИТЕЛЬНО  ==========================
//    // ЗАГРУЗКА ДАННЫХ ИЗ dbf
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='53') then
     begin
       FormDbf:=TFormDbf.create(self);
       FormDbf.Showmodal;
       FreeAndNil(FormDbf);
     end;
//    // КОНСОЛЬ СКЮЛ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='54') then
     begin
       FormC:=TFormC.create(self);
       FormC.Showmodal;
       FreeAndNil(FormC);
     end;
    // ТЕСТ ВЕБКИ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='55') then
     begin
       FormCam:=TFormCam.create(self);
       FormCam.Showmodal;
       FreeAndNil(FormCam);
     end;
     // Обновление справочников
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='56') then
     begin
       FormUpdate:=TFormUpdate.create(self);
       FormUpdate.Showmodal;
       FreeAndNil(FormUpdate);
     end;
  // генерация ini
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='111') then
     begin
       Form1:=TForm1.create(self);
       Form1.Showmodal;
       FreeAndNil(Form1);
     end;
//===============================================================
//======================ЖУРНАЛЫ===============================
  // ЖУРНАЛ ВХОДА
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='57') then
     begin
       FormLog:=TFormLog.create(self);
       FormLog.Showmodal;
       FreeAndNil(FormLog);
     end;
  // ЖУРНАЛ СИНХРОНИЗАЦИИ И ОБМЕНА ДАННЫМИ
  if (trim(stringgrid1.Cells[2,stringgrid1.row])='59') then
     begin
       Form88:=TForm88.create(self);
       Form88.Showmodal;
       FreeAndNil(Form88);
     end;

  end;
end;

//******************************* ЗАГРУЗКА ПОДМЕНЮ ДЛЯ ВЫБРАННОГО МЕНЮ  *****************************
procedure TFormMain.SubMenuLoad;
var
  n:integer=0;
begin
  With FormMain do
begin
  //проверка грида
  IF StringGrid2.RowCount<2 then exit;
      //Основное меню
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

    //Основное меню > Дополнительное меню
    ZQuery1.sql.Clear;
    ZQuery1.SQL.add('SELECT b.loc_name as name,b.tab_pub,b.id_local ');
    ZQuery1.SQL.add(',coalesce((select a.permition from av_users_menu_perm a where a.id='+GLuser+' and a.del=0 and a.id_menu_loc=b.id_local ');
    ZQuery1.SQL.add('AND a.id_arm=b.id_arm AND a.id_menu_loc>0 order by a.createdate desc limit 1),0) permition ');
    ZQuery1.SQL.add('FROM av_arm_menu b ');
    ZQuery1.SQL.add('WHERE b.id_arm='+GLarm+' AND b.id_public='+trim(Stringgrid2.Cells[2,Stringgrid2.Row])+' and b.del=0 and b.id_local>0 and b.loc_name!='+quotedstr('Удаленное администрирование')+' order by b.tab_loc;');

    //ZQuery1.SQL.add('SELECT distinct(a.id_menu_loc),a.permition,b.loc_name as name,b.tab_loc ');
    //ZQuery1.SQL.add('FROM av_arm_menu b,av_users_menu_perm a ');
    //ZQuery1.SQL.add('WHERE a.id_menu_loc = b.id_local AND a.id_arm = b.id_arm AND a.permition>0 AND a.id_menu_loc>0');
    //ZQuery1.SQL.add(' AND b.id_arm='+GLarm+' AND a.id='+GLuser+' AND a.id_menu_pub='+trim(Stringgrid2.Cells[2,Stringgrid2.Row])+' and b.del=0 AND a.del=0 order by b.tab_loc;');
    //showmessage(ZQuery1.SQL.text);//$
    try
      ZQuery1.open;
     except
       showmessagealt('ОШИБКА ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
       exit;
     end;
    if ZQuery1.RecordCount>0 then
       begin
          //Заполнение и доступы к меню LOCAL(начальная загрузка)
            Stringgrid1.RowCount := ZQuery1.RecordCount;
            for n:=0 to ZQuery1.RecordCount-1 do
              begin
                Stringgrid1.Cells[2,n]:=ZQuery1.FieldByName('id_local').AsString;
                Stringgrid1.Cells[1,n]:=ZQuery1.FieldByName('Name').AsString;
                Stringgrid1.Cells[0,n]:=ZQuery1.FieldByName('permition').AsString;
                ZQuery1.Next;
              end;
       end
    else
       begin
          StringGrid1.RowCount:=1;
         StringGrid1.cells[0,0]:='';
         StringGrid1.cells[1,0]:='';
         StringGrid1.cells[2,0]:='';
       end;
     ZQuery1.close;
     ZConnection1.Disconnect;

     Stringgrid1.ColWidths[0]:=10;
     StringGrid1.Row:=0;
    end;
end;


//************************ DATE AND TIME  *******************************************
procedure TFormMain.Timer1Timer(Sender: TObject);
var
    myYear, myMonth, myDay : Word;
begin
  // Часы + Дата
  DecodeDate(Date, myYear, myMonth, myDay);
  FormMain.label1.caption:=TimeToStr(Time);
  FormMain.label2.caption:=GetDayName(DayOfWeek(Date))+'  '+IntToStr(myDay)+' '+GetMonthName(MonthOfTheYear(Date));
end;

//*************************************************    HOT KEYS  *************************************************
procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
   // tab
   if (Key=9) then
     begin
         if FormMain.StringGrid1.Focused then FormMain.Stringgrid2.col:=1;
         if FormMain.Stringgrid2.Focused then FormMain.StringGrid1.col:=1;
     end;

    // F1
    if Key=112 then
    begin
      showmessagealt('[F1] - Справка'+#13+'[ENTER] - Выбор'+#13+'[TAB] - Переход на левое\правое меню'+#13+'1 - Пункт [Основное]'+#13+
    '2 - Пункт [Сервер БД]'+#13+'3 - Пункт [Активные пользователи]'+#13+'4 - Пункт [Задачи]'+#13+'[F9] - Настройки'+#13+'[F10] - Консоль SQL'+#13+'[ESC] - Отмена\Выход');
       Key:=0;
    end;
    // ESC выход
    if (Key=27) and (stringgrid2.Focused) then
      begin
          Key:=0;
          halt;
          exit;
        //FormMain.close;
      end;
    // ESC на StringGrid1
    if (Key=27) and (stringgrid1.Focused) then
      begin
          Key:=0;
          StringGrid2.SetFocus;
      end;
     //F9 - Настройки
    if (Key=120)  then
      begin
           Key:=0;
         ShowSettings();
      end;

    //F10 - Консоль SQL
    if (Key=121)  then
      begin
          Key:=0;
        FormC:=TFormC.create(self);
       FormC.Showmodal;
       FreeAndNil(FormC);
       exit;
      end;

    // ENTER - выбор пункта
    if (Key=13) AND (FormMain.StringGrid1.Focused) then
      begin
        Key:=0;
         // Разбираем меню
        run_form();
        exit;
      end;

    // ENTER - переход на подменю
    if (Key=13) AND (FormMain.StringGrid2.Focused) then
      begin
         Key:=0;
         FormMain.StringGrid1.Setfocus;
         exit;
      end;
end;


procedure TFormMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 //If dialogs.MessageDlg('Вы действительно хотите завершить работу с программой ?',mtConfirmation,[mbYes,mbNO], 0)=7 then
     //CloseAction := caNone;
end;

//************************************************** ПОТЕРЯ ФОКУСА 2 ГРИДОМ МЕНЮ ***************************************
procedure TFormMain.Stringgrid2Exit(Sender: TObject);
begin
  with FormMain do
begin
  Stringgrid2.Color:=clWhite;
  Stringgrid2.Options:=[];
  StringGrid1.Color:=clCream;
  StringGrid1.Options:=[goRowSelect];
  end;
end;


procedure TFormMain.StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;  var CanSelect: Boolean);
begin
  if (aCol=0) or (aCol=2) then FormMain.Stringgrid2.Col:=1;
end;


//***********************************************   ВЫБОР ПУНКТА МЕНЮ  **********************************************
procedure TFormMain.StringGrid2Selection(Sender: TObject; aCol, aRow: Integer);
begin
  SubMenuLoad(); //загрузка подменю
end;



//*********************************************   ВОЗНИКНОВЕНИЕ ФОРМЫ ********************************************
procedure TFormMain.FormShow(Sender: TObject);
var
  n:integer=0;
  log_file: textfile;
begin
  with FormMain do
begin
   CentrForm(FormMain);
   ////////////////////////////////////////////////////////////////////
   //                             Загрузка меню                      //
   ////////////////////////////////////////////////////////////////////
   //Основное меню
   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      //открываем форму настроек соединения
      ShowSettings();
      // Подключаемся к серверу
      If not(Connect2(Zconnection1, flagProfile)) then
        begin
          showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
          exit;
          end;
     end;

    //if flagprofile=1 then MConnect(FormMain.Zconnection1,ConnectINI[3],ConnectINI[1]);
    //if flagprofile=2 then MConnect(FormMain.Zconnection1,ConnectINI[6],ConnectINI[4]);
    //try
    //    FormMain.Zconnection1.connect;
    //  except
    //    showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
    //    halt;
    //  end;
    ZQuery1.sql.Clear;
    ZQuery1.SQL.add('SELECT b.pub_name as name,b.tab_pub,b.id_public ');
    ZQuery1.SQL.add(',coalesce((select a.permition from av_users_menu_perm a where a.id='+GLuser+' and a.del=0 and a.id_menu_pub=b.id_public ');
    ZQuery1.SQL.add('AND a.id_arm=b.id_arm AND a.id_menu_loc=0 order by a.createdate desc limit 1),0) permition ');
    ZQuery1.SQL.add('FROM av_arm_menu b ');
    ZQuery1.SQL.add('WHERE b.id_arm='+GLarm+' and b.del=0 and b.id_local=0 order by b.tab_pub;');
    //showmessage(ZQuery1.SQL.Text);//$
    try
        ZQuery1.open;
    except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
       halt;
    end;
    if ZQuery1.RecordCount<1 then
       begin
         showmessagealt('Нет доступного меню для выбранного пользователя !');
         ZConnection1.Disconnect;
         halt;
       end;
    //Заполнение и доступы к меню PUBLIC(начальная загрузка)
  // Соединяемся с сервером и выбираем список доступных меню для пользователя + АРМ
   Stringgrid2.RowCount := ZQuery1.RecordCount;
  for n:=0 to ZQuery1.RecordCount-1 do
    begin
      Stringgrid2.Cells[2,n]:=ZQuery1.FieldByName('id_public').AsString;
      Stringgrid2.Cells[1,n]:=ZQuery1.FieldByName('Name').AsString;
      Stringgrid2.Cells[0,n]:=ZQuery1.FieldByName('permition').AsString;
     ZQuery1.Next;
    end;

  Stringgrid2.ColWidths[0]:=10;
  Stringgrid2.ColWidths[1]:=Stringgrid2.Width-Stringgrid2.ColWidths[0]-Stringgrid2.ColWidths[2]-1;
  SubMenuLoad();//загрузка дополнительного меню

  Stringgrid2.SetFocus;
end;

end;

procedure TFormMain.StringGrid1DblClick(Sender: TObject);
begin
  FormMain.run_form();
end;

procedure TFormMain.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
begin
  SetRowColorMenu(FormMain.stringgrid1,aCol,aRow,aRect);
end;

// ***************************************   ПОТЕРЯ ФОКУСА 1 ГРИДА ПОДМЕНЮ **********************************************
procedure TFormMain.StringGrid1Exit(Sender: TObject);
begin
with FormMain do
begin
  StringGrid1.Color:=clWhite;
  StringGrid1.Options:=[];
  Stringgrid2.Color:=clCream;
  Stringgrid2.Options:=[goRowSelect];
end;
end;

// ******************************************************  ПОТЕРЯ ФОКУСА ГРИДОМ ПОДМЕНЮ *************************************
procedure TFormMain.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;  var CanSelect: Boolean);
begin
    if (aCol=0) or (aCol=2) then FormMain.StringGrid1.Col:=1;
end;

procedure TFormMain.StringGrid2DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
begin
   SetRowColorMenu(FormMain.Stringgrid2,aCol,aRow,aRect);
end;


// ********************************   СОЗДАНИЕ формы *************************************************************
procedure TFormMain.FormCreate(Sender: TObject);
Var
  MajorNum : String;
  MinorNum : String;
  RevisionNum : String;
  BuildNum : String;
  Info: TVersionInfo;
  flstop:boolean=true;
  fpath:string;
  log_file: textfile;
begin
 //взять номер версии
 // initialize a bunch of stuff for this app when the form is first opened
// [0] = Major version, [1] = Minor ver, [2] = Revision, [3] = Build Number
// The above values can be found in the menu: Project > Project Options > Version Info
  Info := TVersionInfo.Create;
  Info.Load(HINSTANCE);
  // grab just the Build Number
  MajorNum := IntToStr(Info.FixedInfo.FileVersion[0]);
  MinorNum := IntToStr(Info.FixedInfo.FileVersion[1]);
  RevisionNum := IntToStr(Info.FixedInfo.FileVersion[2]);
  BuildNum := IntToStr(Info.FixedInfo.FileVersion[3]);
  Info.Free;
 Label3.Caption := 'Версия:'+MajorNum+'.'+MinorNum+'.'+RevisionNum+'.'+BuildNum;//версия программы
    // Обработчик исключений
  Application.OnException:=@MyExceptionHandler;


   // ОПРЕДЕЛЯЕМ ПАРАМЕТРЫ ДОСТУПА *******************
  flag_access := 2; //полный доступ

  inipath:= ExtractFilePath(Application.ExeName);

while flstop do
begin

  //Определяем начальные установки соединения с сервером
  if not ReadIniLocal(FormMain.IniPropStorage1,inipath+'local.ini') then
     begin
       If dialogs.MessageDlg('Подключение к базе данных невозможно !'+#13+'Не найден файл настроек по заданному пути !'+
       'Желаете указать путь к файлу самостоятельно ?',mtConfirmation,[mbYes,mbNO], 0)=6 then
       begin
         FormMain.dialog1.Execute;
         inipath:= IncludeTrailingPathDelimiter(FormMain.dialog1.FileName); //для Win ='\' Linux='/'
       end
       else
         begin
           //запустить форму с настройками подключения
           ShowSettings();
         end;
     end
  else
    flstop:=false;
end;


  //профиль по умолчанию центральный реальный сервер
  flagprofile := 1;
  gluser := '5555';
  glarm  := '1';


     //принимаем начальные параметры
  If trim(ParamStr(1))<>'' then
  begin
  try
     GLuser:=trim(utf8copy(trim(ParamStr(1)),1,utf8pos('+',ParamStr(1))-1));
     GLarm:=trim(copy(ParamStr(1),pos('+',ParamStr(1))+1,pos('_',ParamStr(1))-1-pos('+',ParamStr(1))));
  //id_arm:=strtoint(copy(ParamStr(1),pos('+',ParamStr(1))+1,pos('_',ParamStr(1))-1-pos('+',ParamStr(1))));
  //flagProfile:=flagProfile+strtoint(copy(trim(ParamStr(1)),pos('_',ParamStr(1))+1,1));
  except
       on exception: EConvertError do
  begin
       showmessagealt('ОШИБКА КОНВЕРТАЦИИ !!!'+#13+'НЕВЕРНОЕ ЗНАЧЕНИЕ ПАРАМЕТРА ПРИЛОЖЕНИЯ !');
       halt;
       exit;
  end;
  end;
  end
  else
  begin
    {$IFDEF WINDOWS}
     GLuser:='0';
     //открыть форму регистрации
     FormAuth:=TFormAuth.create(self);
     FormAuth.ShowModal;
     FreeAndNil(FormAuth);
    {$ENDIF}
   end;

  If GLuser='' then
  begin
    halt;
    exit;
  end;



//установить формат даты и времени
  //глобальные установки
    decimalseparator:='.';
    DateSeparator := '.';
    ShortDateFormat := 'dd.mm.yyyy';
    LongDateFormat  := 'dd.mm.yyyy';
    ShortTimeFormat := 'hh:mm:ss';
    LongTimeFormat  := 'hh:mm:ss';


 //ведение лога
  namelog:=ExtractFilePath(Application.ExeName)+'log/'+FormatDateTime('yy-mm-dd', now())+'.log';
// --------Проверяем что уже есть каталог LOG если нет то создаем
If Not DirectoryExistsUTF8(ExtractFilePath(Application.ExeName)+'log') then
  begin
   CreateDir(ExtractFilePath(Application.ExeName)+'log');
  end;
//--------- Создаем log: ..log/log_01.01.2012.log
//if fileexistsUTF8(namelog) then
 //begin
  //fileutil.RenameFileUTF8(namelog, ExtractFilePath(Application.ExeName)+'log/'+FormatDateTime('yy-mm-dd_hh_nn', now())+'.log');
 //end;
{$I-} // отключение контроля ошибок ввода-вывода
 AssignFile(log_file,namelog);
 if fileexistsUTF8(namelog) then
     Append(log_file) else
     Rewrite(log_file); // открытие файла для записи
{$I+} // включение контроля ошибок ввода-вывода
if IOResult<>0 then // если есть ошибка открытия, то
 begin
   Exit;
 end;
 writeln(log_file,'+Version: '+MajorNum+'.'+MinorNum+'.'+RevisionNum+'.'+BuildNum);
// id_user+datetime
 //writeln(log_file,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
 //writeln(log_file,user_ip+'; ['+(inttostr(id_user))+'] '+name_user_active+'; '+FormatDateTime('dd/mm/yyyy hh:mm:ss', now()));
 //writeln(log_file,FormatDateTime('dd/mm/yyyy hh:mm:ss', now()));
 //writeln(log_file,trim(s));
 // --------- Закрываем текстовый файл
CloseFile(log_file);

end;


//******************************* УНИЧТОЖЕНИЕ ФОРМЫ - ЗАПИСЬ В ЖУРНАЛ ВХОДА-ВЫХОДА **************************************************
procedure TFormMain.FormDestroy(Sender: TObject);
begin
   formmain.Timer1.Enabled:=false;
   formmain.IdleTimer1.Enabled:=false;
   formmain.Timer1:=nil;
   formmain.IdleTimer1:=nil;
   //out_user_sql(FormMain.ZConnection1,FormMain.ZQuery1);
end;


end.


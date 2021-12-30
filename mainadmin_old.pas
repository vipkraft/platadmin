unit mainadmin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  IniPropStorage, StdCtrls, Buttons, ExtCtrls, types, dbf, ZConnection,
  ZDataset, LConvEncoding, Grids, FileCtrl, DBGrids, Spin, EditBtn, Load_DBF,
  Unit3, Unit4, arm, Variants, platproc, unix, DB, RtfDoc, RtfPars, point_main, StrUtils, users_main,sync_table, main;

{  Calendar, fullmap,
  profilerun, ZConnection, ZDataset, sprregion, nas, getopts;}

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn20: TBitBtn;
    BitBtn21: TBitBtn;
    BitBtn22: TBitBtn;
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    BitBtn25: TBitBtn;
    BitBtn26: TBitBtn;
    BitBtn27: TBitBtn;
    BitBtn28: TBitBtn;
    BitBtn29: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn30: TBitBtn;
    BitBtn31: TBitBtn;
    BitBtn32: TBitBtn;
    BitBtn33: TBitBtn;
    BitBtn34: TBitBtn;
    BitBtn35: TBitBtn;
    BitBtn36: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    DateEdit1: TDateEdit;
    Dbf1: TDbf;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label4: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label5: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo4: TMemo;
    PageControl1: TPageControl;
    Dialog1: TSelectDirectoryDialog;
    ProgressBar1: TProgressBar;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape9: TShape;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    SpinEdit9: TSpinEdit;
    StringGrid1: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    StringGrid5: TStringGrid;
    StringGrid6: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    Timer1: TTimer;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn19Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn20Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure BitBtn22Click(Sender: TObject);
    procedure BitBtn23Click(Sender: TObject);
    procedure BitBtn24Click(Sender: TObject);
    procedure BitBtn25Click(Sender: TObject);
    procedure BitBtn26Click(Sender: TObject);
    procedure BitBtn27Click(Sender: TObject);
    procedure BitBtn28Click(Sender: TObject);
    procedure BitBtn29Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn30Click(Sender: TObject);
    procedure BitBtn32Click(Sender: TObject);
    procedure BitBtn33Click(Sender: TObject);
    procedure BitBtn34Click(Sender: TObject);
    procedure BitBtn35Click(Sender: TObject);
    procedure BitBtn36Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure Edit13Exit(Sender: TObject);
    procedure Edit14Exit(Sender: TObject);
    procedure Edit15Exit(Sender: TObject);
    procedure Edit16Exit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReadINI();
    procedure ExportALLDBF();
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid3BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid3MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure StringGrid3Selection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid6DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid6MouseDown(Sender: TObject; Button: TMouseButton;      Shift: TShiftState; X, Y: Integer);
    procedure TabSheet4Enter(Sender: TObject);
    procedure TabSheet6Show(Sender: TObject);
    procedure UsrParam(); // Отображение данных пользователей
    procedure Sets(flag: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure UpdateServers(); //обновление гридов на вкладке СЕРВЕРОВ
    procedure SaveToMas(); //сохранить данные серверов с формы в массивы

  private
    { private declarations }
  public
    { public declarations }
  end; 



var
  Form1: TForm1;
  id_user_global, id_user_name, GLuser, GLarm : string;
  n, nUserFlag : integer;
  masedit: array[0..20] of string;
  Lexp: Boolean;
  flag_access,flagprofile:byte;

implementation

{$R *.lfm}

{ TForm1 }
var
  ar_access, ar_deny, ar_srv : Array of Array of String; // массивы для вкладки СЕРВЕРА
  masuser : array of array of string;
  razbor : string;
  new_id : integer;

//***************************    Процедура чтения INI файла **************************
procedure TForm1.readini();
begin
//Определяем начальные установки соединения с сервером
  if  ReadIniLocal(form1.IniPropStorage1,trim(form1.Edit1.Text)+'local.ini')=false then
     begin
       showmessage('Не найден файл настроек по заданному пути!');
       exit;
     end;

    // Чтение из INI
  With form1 do
   begin
    // real
    edit2.text:=ConnectINI[1];
    edit3.text:=ConnectINI[2];
    edit4.text:=ConnectINI[3];
    Edit13.Text:=ConnectINI[8];
    Edit14.Text:=ConnectINI[9];
    edit17.text:=ConnectINI[12];
   //emu
   edit5.text:=ConnectINI[4];
   edit6.text:=ConnectINI[5];
   Edit15.Text:=ConnectINI[10];
   Edit16.Text:=ConnectINI[11];
   edit7.text:=ConnectINI[6];
   edit18.text:=ConnectINI[13];
   //local settings
   edit11.text:=ConnectINI[7];
   edit20.text:=ConnectINI[14];
  end;
end;


//*******************************    Отображение данных пользователей  ************************************************
procedure TForm1.UsrParam();
 var
 BlobStream: TStream;
 FileStream: TStream;
begin
    with form1 do
         begin
           If (Stringgrid1.RowCount<2) or (Stringgrid1.Cells[1,Stringgrid1.row]='') then exit;
              label34.Caption:=masuser[StringGrid1.row,2];//createdate
              label21.Caption:=masuser[StringGrid1.row,3];//
             // label34.Text:=masuser4[n]:=FieldbyName('kodpodr').AsWideString;
              label17.Caption:=masuser[StringGrid1.row,5];//birthday
              label15.Caption:=masuser[StringGrid1.row,7];//fio
              label19.Caption:=masuser[StringGrid1.row,8];//pol
              label25.Caption:=masuser[StringGrid1.row,9];//dolg
              IF strToint(masuser[StringGrid1.row,11])=1 then
                 label35.Caption:='АКТИВЕН'
              else label35.Caption:='НЕ Активен'; //активность
              label32.Caption:=masuser[StringGrid1.row,12];//kod1c
              IF strToint(masuser[StringGrid1.row,13])=0 then
                 label30.Caption:='Сотрудник'
              else label30.Caption:='Котрагент'; //tip
              label23.Caption:=masuser[StringGrid1.row,15];//имя подразделения
              label21.Caption:=masuser[StringGrid1.row,16];//имя отделения

      // Загрузка фото
     MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
      form1.ZQuery1.SQL.Clear;
      form1.ZQuery1.SQL.text:=('SELECT foto from av_users where id='+form1.StringGrid1.Cells[1,form1.StringGrid1.row]+';');
      try
        form1.ZQuery1.open;
      except
        showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
        form1.Zconnection1.disconnect;
        exit;
       end;
      if not(form1.ZQuery1.FieldByName('foto').IsBlob) then exit;
      BlobStream := form1.ZQuery1.CreateBlobStream(form1.ZQuery1.FieldByName('foto'), bmRead);
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
           form1.image2.Picture.LoadFromFile('foto.jpg');

         end;
end;

//******************************* Процедура экспорта таблиц *.DBF в SQL: из 1C  *******************************************
procedure TForm1.ExportALLDBF();
 var
    tmp_file_1,local_dbf_txt,local_dbf_txt2:TextFile;
    j: variant;
    k,t_mem,t_sql,strTemp,strsql,strsql2,strsql3,t_str: string;
    t_kodotd,t_kodpodr,t_name,t_fullname,t_adress: string;
    List:TStringList;
    n_tmp,t_str_kol,t_scet,tmp_i,kol_strok,ttt:integer;
    tmp_array:array of array of widestring;
    mas1:Array of String;
    mas2:Array of String;
    SQL_TABLE,SQL_DELETE:string;
begin
    form1.Repaint;
    // Ищем основной файл настроек
    form1.memo1.Append('=======================================================================');
    form1.memo1.Append('Проверяем наличие файла настроек выгрузки list_dbf.txt');
    if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf.txt') then
     begin
       form1.memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - OK');
     end
  else
     begin
      form1.memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - Файл отсутствует');
      form1.memo1.Append('=======================================================================');
      form1.memo1.Append(' ');
      exit;
     end;
  form1.memo1.Append('Считываем данные из list_dbf.txt...');
  // проверяем что есть список DBF
  if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf.txt')=0 then
   begin
    form1.memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - Файл пустой !');
    form1.memo1.Append('=======================================================================');
    form1.memo1.Append(' ');
    exit;
   end;
  //проверяем что хоть что то выбрано
    if not(FileExistsUTF8(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt')) then
     begin
      form1.memo1.Append('Нет файла выбранного списка для загрузки listbox_dbf.txt !');
      form1.memo1.Append('=======================================================================');
      form1.memo1.Append(' ');
      exit;
     end;
    if  kol_row_file(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt')=0 then
      begin
        form1.memo1.Append('Нет выбранных файлов для загрузки !');
        form1.memo1.Append('=======================================================================');
        form1.memo1.Append(' ');
        exit;
      end;

    //Создаем массив с загружаемыми и выбранными DBF
     AssignFile(local_dbf_txt,ExtractFilePath(Application.ExeName)+'listbox_dbf.txt');
     reset(local_dbf_txt);
     AssignFile(local_dbf_txt2,ExtractFilePath(Application.ExeName)+'list_dbf.txt');
     reset(local_dbf_txt2);

     // Загружаем список всех доступных DBF в mas1
     SetLength(mas1, kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf.txt'));
     t_str_kol:=-1;
     while not Eof(local_dbf_txt2) do
        begin
          t_str_kol:=t_str_kol+1;
          readln(local_dbf_txt2,t_str);
          mas1[t_str_kol]:=t_str;
        end;
     closefile(local_dbf_txt2);
     SetLength(mas2, kol_row_file(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt'));
     t_str_kol:=-1;
     while not Eof(local_dbf_txt) do
        begin
          t_str_kol:=t_str_kol+1;
          readln(local_dbf_txt,t_str);
          mas2[t_str_kol]:=mas1[strtoint(t_str)];
        end;
        closefile(local_dbf_txt);


 for t_scet:=0 to kol_row_file(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt')-1 do
   begin
    SQL_TABLE:=copy(mas2[t_scet],1,length(mas2[t_scet])-4);
   // Ищем локальный файл настроек
   form1.memo1.Append('Проверяем наличие файла локальных настроек выгрузки list_dbf_'+SQL_TABLE+'.DBF.txt');
     if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') then
      begin
        form1.memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt'+' - OK');
      end
   else
      begin
       form1.memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt'+' - Файл отсутствует');
       form1.memo1.Append('=======================================================================');
       form1.memo1.Append(' ');
       exit;
      end;
     form1.memo1.Append('Считываем данные из list_dbf'+SQL_TABLE+'.DBF.txt...');

   // Определяем количество перебрасываемых полей
   if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt')=0 then
     begin
       form1.memo1.Append('Нет данных в list_dbf_'+SQL_TABLE+'.DBF.txt - ОШИБКА');
       form1.memo1.Append('=======================================================================');
       form1.memo1.Append(' ');
       exit;
     end;

   // Определяем динамический масси с настройками полей и заполняем его
   SetLength(tmp_array,0,0);
   n_tmp:=(kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') div 4);
   SetLength(tmp_array,kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') div 4,4);
  // showmessage(IntToStr(length(tmp_array)));
   AssignFile(tmp_file_1, ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt');
   Reset(tmp_file_1);
   n_tmp:=-1;
   while not Eof(tmp_file_1) do
        begin
          Readln(tmp_file_1,strTemp);
          n_tmp:=n_tmp+1;
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,1]:=trim(strTemp);
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,2]:=trim(strTemp);
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,3]:=trim(strTemp);
        end;
    closefile(tmp_file_1);


    //TDBF
     form1.dbf1.FilePath:=form1.edit8.Text+'/';
     form1.dbf1.FilePathFull:=form1.edit8.Text+'/';
     form1.dbf1.tablename:=SQL_TABLE+'.DBF';
     form1.dbf1.Active:=true;
     //Количество записей
     form1.memo1.Append('Всего записей в DBF: '+inttostr(form1.Dbf1.ExactRecordCount));
     form1.Memo1.Refresh;

   //Определяем SQL_DELETE
   SQL_DELETE:='';
   if not(FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt')) then
     begin
       form1.memo1.Append('Нет файла настроек операции для '+ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt');
       form1.memo1.Append('Продолжение невозможно - ВЫХОД !!!');
       form1.memo1.Append('=======================================================================');
       form1.memo1.Append(' ');
       exit;
     end;
    if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt')=2 then
       begin
         AssignFile(local_dbf_txt,ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt');
         reset(local_dbf_txt);
         readln(local_dbf_txt,t_str);
         readln(local_dbf_txt,t_str);
         SQL_DELETE:=trim(t_str);
         closefile(local_dbf_txt);
       end;

   //Удаляем все записи
   if not(SQL_DELETE = '') then
     begin
          MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
          try
             form1.Zconnection1.connect;
             form1.memo1.Append('Соединение с сервером SQL - OK');
          except
             form1.memo1.Append('Соединение с сервером SQL - ОШИБКА');
             form1.dbf1.Active:=false;
             form1.memo1.Append('=======================================================================');
             form1.memo1.Append(' ');
             exit;
          end;
          form1.ZQuery1.SQL.Clear;
          form1.ZQuery1.SQL.add(SQL_DELETE);
          try
          form1.ZQuery1.execSQL;
          form1.memo1.Append('Выполнение '+SQL_DELETE+' - OK');
          except
             form1.memo1.Append('ОШИБКА выполнения запроса! - '+ form1.ZQuery1.SQL.Text);
             form1.dbf1.Active:=false;
             form1.memo1.Append('=======================================================================');
             form1.memo1.Append(' ');
             exit;
          end;
     end
   else
       begin
       form1.memo1.Append('ОШИБКА ! В файле list_dbf_'+SQL_TABLE+'.DBF2.txt не найдено строки запроса !');
       form1.dbf1.Active:=false;
       form1.memo1.Append('=======================================================================');
       form1.memo1.Append(' ');
       exit;
       end;


   form1.memo1.Append('Производим добавление новых записей...');

   //Сканируем *.dbf
   form1.DBF1.First;
   form1.DBF1.DisableControls;

   //Прогресс бар
   form1.ProgressBar1.Max:=form1.Dbf1.ExactRecordCount;
   form1.ProgressBar1.Position:=0;

   // Формируем строки SQL
   while not form1.DBF1.Eof do
     begin
       form1.ProgressBar1.stepit;
       form1.ProgressBar1.Refresh;
       strsql:='';
       form1.ZQuery1.SQL.Clear;
       // Формируем первоначальную строку INSERT
      strsql2:='INSERT INTO ';
      strsql3:='';
      if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt')>0 then
       begin
         AssignFile(local_dbf_txt,ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt');
         reset(local_dbf_txt);
         readln(local_dbf_txt,t_str);
         strsql2:=strsql2+trim(t_str);
         closefile(local_dbf_txt);
       end;
       strsql2:=strsql2+' (';
       form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql2));
       strsql3:=strsql3+strsql2;

       // Цикл по добавление полей в INSERT
       strsql2:='';
       AssignFile(local_dbf_txt,ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt');
       reset(local_dbf_txt);
       tmp_i:=0;
       while not Eof(local_dbf_txt) do
        begin
          tmp_i:=tmp_i+1;
          readln(local_dbf_txt,t_str);
          if not(trim(t_str)='') then
          begin
             form1.ZQuery1.SQL.add(CP1251ToUTF8(trim(t_str)));
             strsql3:=strsql3+t_str;
          end;
          if tmp_i<(kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') div 4) then
            begin
             form1.ZQuery1.SQL.add(CP1251ToUTF8(','));
             strsql3:=strsql3+',';
            end;
          readln(local_dbf_txt,t_str);
          readln(local_dbf_txt,t_str);
          readln(local_dbf_txt,t_str);
        end;
        closefile(local_dbf_txt);
        form1.ZQuery1.SQL.add(CP1251ToUTF8(') VALUES ('));
        strsql3:=strsql3+') VALUES (';

       strsql2:=CP1251ToUTF8(strsql3);
       strsql2:='';

       kol_strok:=kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt');

      //Цикл добавления значений полей из DBF
       for n_tmp:=0 to (kol_strok div 4)-1 do
        begin
          //ttt:=n_tmp;
          k:=tmp_array[n_tmp,1];
          //ttt:=strtoint(tmp_array[n_tmp,1]);
          //ttt:=form1.Dbf1.FieldCount;
          j:=form1.Dbf1.Fields[strtoint(tmp_array[n_tmp,1])].value;

          // Простое текстовое поле
          if (tmp_array[n_tmp,2]='0') and (tmp_array[n_tmp,3]='0') then
            begin
              if j=NULL then j:=' '; //проверка на NULL
              strsql:=strsql+QuotedStr(j);
              if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
              form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
              strsql2:=strsql2+CP1251ToUTF8(strsql);
              strsql:='';
            end;

          // Простое числовое поле
          if (tmp_array[n_tmp,2]='1') and (tmp_array[n_tmp,3]='0') then
            begin
              if j=NULL then j:='0'; //проверка на NULL
              if (vartype(j)=3) or (vartype(j)=5)  then
                 j:=inttostr(j);
              strsql:=strsql+j;
              if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
              form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
              strsql2:=strsql2+CP1251ToUTF8(strsql);
              strsql:='';
            end;

          // Простое поле дата
          if (tmp_array[n_tmp,2]='2') and (tmp_array[n_tmp,3]='0') then
            begin
               if j=NULL then
                 begin
                  j:='NULL'; //проверка на NULL
                 end
               else
                 begin
                  j:=QuotedStr(datetostr(j));
                 end;
               strsql:=strsql+j;
               if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
               form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
               strsql2:=strsql2+CP1251ToUTF8(strsql);
               strsql:='';
            end;
          // kodotd
          if tmp_array[n_tmp,3]='1' then
            begin
             if j=NULL then j:='0'; //проверка на NULL
             if LastDelimiter('/',j)>0 then
               begin
                strsql:=strsql+copy(j,1,LastDelimiter('/',j)-1);
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql:='';
               end
             else
               begin
                strsql:=strsql+j;
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql2:=strsql2+CP1251ToUTF8(strsql);
                strsql:='';
                end;
            end;
          // kodpodr
          if tmp_array[n_tmp,3]='2' then
            begin
             if j=NULL then j:='0'; //проверка на NULL
             if LastDelimiter('/',j)>0 then
               begin
                strsql:=strsql+copy(j,LastDelimiter('/',j)+1,100);
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql2:=strsql2+strsql;
                strsql:='';
               end
             else
               begin
                strsql:=strsql+'0';
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                form1.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql2:=strsql2+CP1251ToUTF8(strsql);
                strsql:='';
               end;
            end;

        end;

       //отображаем запрос в мемо
       if form1.CheckBox1.Checked = True then
       begin
        form1.Memo1.append(strsql2+');');
        form1.Memo1.Refresh;
       end;

  // ********* Пишем в базу
      //////////////////////////////////////
       //1.Соединяемся с сервером SQL
       MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
       try
          //Соединяемся с сервером Postgree
         form1.Zconnection1.connect;
        except
         form1.memo1.Append('Соединение с сервером SQL - ОШИБКА');
         form1.dbf1.Active:=false;
         form1.memo1.Append('=======================================================================');
         form1.memo1.Append(' ');
         exit;
       end;
        //2.Выполняем SQL запрос Insert
        form1.ZQuery1.SQL.add(CP1251ToUTF8(');'));
        form1.ZQuery1.ExecSQL;
        form1.Zconnection1.disconnect;
     //////////////////////////////////////////////////////
       //Следующая строка
       form1.Dbf1.Next;
      end;
      form1.DBF1.EnableControls;
      //Освобождаем TDBF
      form1.dbf1.Active:=false;
      form1.Dbf1.close;
      form1.memo1.Append('=======================================================================');
      form1.memo1.Append(' ');
 end;
 form1.ProgressBar1.Position:=0;
 form1.ProgressBar1.Refresh;
 //освободить память от массива
  SetLength(tmp_array,0,0);
  tmp_array := nil;
end;




//***************************************************         Отрисовка Грида ****************************************************************************
procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
    clFore,clBack: TColor;
begin
with (Sender as TStringGrid) do
 begin
   clBack:=clSilver;
   clFore:=clWindow;
  //Если ячейка выбрана, то нам надо закрасить её другими цветами
  if (gdSelected in aState) then
  begin
    Canvas.Brush.Color := clHighLight;
    Canvas.Font.Color := clYellow;
    Canvas.Font.Size:=10;
  end
  else
    begin
     Canvas.Font.Size:=9;
    //Если пользователь удален, закрашиваем строку серым цветом
    If length(masuser)>0 then
    if trim(masuser[aRow,17])='0' then
      Canvas.Brush.color := clFore
    else
      canvas.brush.Color := clBack;
    end;
 //Закрашиваем грид
  if (ARow > 0) then
  begin
    //Закрашиваем бэкграунд
    Canvas.FillRect(aRect);
    //Закрашиваем текст (Text). Также здесь можно добавить выравнивание и т.д..
    Canvas.TextOut(aRect.Left+5, aRect.Top, Cells[ACol, ARow]);
  end;
 end;
end;


//Движение по гриду  ПОЛЬЗОВАТЕЛЕЙ
procedure TForm1.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
begin
  If Pagecontrol1.Pages[2].Enabled=false then exit;
  UsrParam();
end;


// *************************** Нажатие клавиши на вкладке ПОЛЬЗОВАТЕЛЕЙ *********************************
procedure TForm1.TabSheet4Enter(Sender: TObject);
begin
  //Form1.BitBtn16.Click;
end;



//******************************************* УКАЗАТЬ ПУТЬ К ФАЙЛУ НАСТРОЕК ************************************
procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  Form1.dialog1.Execute;
  form1.edit1.Text:=Form1.dialog1.FileName;
  Form1.Sets(true);
end;

//**************************************************  ЗАГРУЗИТЬ ИЗ ФАЙЛА *********************************************************
procedure TForm1.BitBtn21Click(Sender: TObject);
var
   defpath : string;
begin
  readini();
end;

procedure TForm1.BitBtn14Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.BitBtn15Click(Sender: TObject);
begin
  //Печать списка пользователей

end;


//*****************************************   Кнопка ОБНОВИТЬ *********************************************************************
procedure TForm1.BitBtn16Click(Sender: TObject);
var
 n,j: integer;
 massize: string;
 CurrentColor: TFont;
begin
   MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
   // Выбор пользователей
     with form1 do
     begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.id,u.name,u.createdate,u.kodotd,u.kodpodr,u.birthday,u.passw,u.fullname,u.pol,u.dolg,u.status,u.kod1c,u.tip,u.info,u.del,u.foto,p.name as namepodr,f.name as nameotd,u.group_id,g.grupa ');
       ZQuery1.SQL.add('from av_users as u ');
       ZQuery1.SQL.add('join av_users_groups as g ON u.group_id=g.id ');
       ZQuery1.SQL.add('LEFT JOIN av_1c_otd_podr as p ON u.kodotd=p.kodotd and u.kodpodr=p.kodpodr ');
       ZQuery1.SQL.add('left join av_1c_otd_podr as f ON f.kodotd=u.kodotd and f.kodpodr=0 ');
         //Выбирать удаленных или нет
         If not(CheckBox3.Checked) then   ZQuery1.SQL.add('WHERE u.del=0 ');
         ZQuery1.SQL.add('ORDER BY u.id; ');
     //showmessage(ZQuery1.sql.Text);
   try
      ZQuery1.open;
   except
     ZQuery1.Close;
     Zconnection1.disconnect;
     showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
     exit;
   end;

   //n:= RecordCount;

   // Если нет пользователей
    if ZQuery1.RecordCount<1 then
     begin
      showmessage('В системе нет зарегистрированных пользоватей !');
      ZQuery1.Close;
      Zconnection1.disconnect;
      exit;
     end;
   Setlength(masuser,0,20);
   Setlength(masuser,ZQuery1.recordcount+1,20);
   // Заполняем STRINGGRID и массив данными о пользователях
   stringgrid1.RowCount := 1;
   //form1.stringgrid1.RowCount := form1.ZQuery1.recordcount+1;
   for n:=1 to ZQuery1.Recordcount do
       begin
            //Закрашиваем строчку в серый цвет, если пользователь удален
            //заполняем массив
              masuser[n,0]:=ZQuery1.FieldbyName('id').AsString;
              masuser[n,1]:=ZQuery1.FieldbyName('name').AsString;
              masuser[n,2]:=ZQuery1.FieldbyName('createdate').AsString;
              masuser[n,3]:=ZQuery1.FieldbyName('kodotd').AsString;
              masuser[n,4]:=ZQuery1.FieldbyName('kodpodr').AsString;
              masuser[n,5]:=ZQuery1.FieldbyName('birthday').AsString;
              masuser[n,6]:=ZQuery1.FieldbyName('passw').AsString;
              masuser[n,7]:=ZQuery1.FieldbyName('fullname').AsString;
              masuser[n,8]:=ZQuery1.FieldbyName('pol').AsString;
              masuser[n,9]:=ZQuery1.FieldbyName('dolg').AsString;
              masuser[n,10]:=ZQuery1.FieldbyName('grupa').AsString;
              masuser[n,11]:=ZQuery1.FieldbyName('status').AsString;
              masuser[n,12]:=ZQuery1.FieldbyName('kod1c').AsString;
              masuser[n,13]:=ZQuery1.FieldbyName('tip').AsString;
              masuser[n,14]:=ZQuery1.FieldbyName('info').AsString;
              masuser[n,15]:=ZQuery1.FieldbyName('namepodr').AsString;
              masuser[n,16]:=ZQuery1.FieldbyName('nameotd').AsString;
              masuser[n,17]:=ZQuery1.FieldbyName('del').AsString;
              masuser[n,18]:=ZQuery1.FieldbyName('group_id').AsString;

              //заполняем грид
            form1.stringgrid1.RowCount:=form1.stringgrid1.RowCount+1;
            form1.StringGrid1.cells[1,n]:=masuser[n,0];
            form1.StringGrid1.cells[2,n]:=masuser[n,1];
            form1.StringGrid1.cells[3,n]:=masuser[n,10];
            form1.StringGrid1.cells[4,n]:=masuser[n,9];
            form1.StringGrid1.cells[5,n]:=masuser[n,15];
            //Рисуем статус пользователя активен\не активен
            if masuser[n,11]='0' then
              StringGrid1.cells[6,n]:=''
            else
               StringGrid1.cells[6,n]:='*';

            ZQuery1.Next;
       end;
   UsrParam();
//   StringGrid1.Col:=1;
   Form1.StringGrid1.SetFocus;
    end;
end;

// *************************************         Активация  ***********************************************************************************
procedure TForm1.BitBtn17Click(Sender: TObject);
begin
 with form1.StringGrid1 do
  begin
  //проверка, что выбрана запись
  IF (Cells[1,row]=emptystr) or (Cells[1,row]='ID') then
    begin
     showmessage('Сначала выберите пользователя!');
     exit;
     end;
  //проверка, не удаленный пользователь
  If strToInt(masuser[row,17])>0 then
    begin
     showmessage('Невозможно Активировать удаленного пользователя!');
     exit;
    end;

  MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
   // Выбор пользователей
   form1.ZQuery1.SQL.Clear;
   form1.ZQuery1.SQL.add('Update av_users SET status=1 WHERE del=0 AND id='+Cells[1,row]+';');

   try
      form1.ZQuery1.open;
   except
     form1.ZQuery1.Close;
     form1.Zconnection1.disconnect;
     showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
     exit;
   end;
   form1.Zconnection1.disconnect;
   showmessage('Пользователь '+Cells[2,row]+' успешно АКТИВИРОВАН !');
   BitBtn16.Click;   //обновляем повторно
   end;
end;

//***********************************************   ДЕАКТИВАЦИЯ  *********************************************
procedure TForm1.BitBtn22Click(Sender: TObject);
begin
  with form1.StringGrid1 do
  begin
  //проверка, что выбрана запись
  IF (Cells[1,row]=emptystr) or (Cells[1,row]='ID') then
    begin
     showmessage('Сначала выберите пользователя!');
     exit;
     end;
  //проверка,что не удаленный пользователь
  If strToInt(masuser[row,17])>0 then
    begin
     showmessage('Операция невозможна для удаленного пользователя!');
     exit;
    end;

  MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
   // Выбор пользователей
   form1.ZQuery1.SQL.Clear;
   form1.ZQuery1.SQL.add('Update av_users SET status=0 WHERE del=0 AND id='+Cells[1,row]+';');

   try
      form1.ZQuery1.open;
   except
     form1.ZQuery1.Close;
     form1.Zconnection1.disconnect;
     showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
     exit;
   end;
   form1.Zconnection1.disconnect;
   showmessage('Пользователь '+Cells[2,row]+' успешно ДЕАКТИВИРОВАН !');
   BitBtn16.Click;   //обновляем повторно
   end;
end;

// *************************  ПЕРЕХОД НА ВКЛАДКУ СЕРВЕРОВ *************************************************
procedure TForm1.TabSheet6Show(Sender: TObject);
var
   n,k,m,j:integer;
   ttt: string;
begin
  Centrform(form1);
 with Form1 do
 begin
  If Pagecontrol1.Pages[1].Enabled=false then exit;
  //открыть кнопку СОХРАНИТЬ
  if flag_access=2 then  Form1.BitBtn23.Enabled:=true;

  // Обнуляем данные на вкладке
   StringGrid3.RowCount := 1;
   StringGrid4.RowCount := 1;
   StringGrid5.RowCount := 1;
  // Подключаемся к серверу
  MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
  try
      Zconnection1.connect;
  except
     showmessage('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
     PageControl1.ActivePageIndex := 0;
     exit;
  end;
   // запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT a.id,b.name,a.active,a.activedate,a.usetarif,a.point_id,a.ip,a.ip2,a.info,a.base_name FROM av_servers AS a, av_spr_point AS b WHERE a.del=0 AND b.del=0 AND a.point_id=b.id ORDER BY b.name;');
     try
       ZQuery1.open;
     except
       showmessage('Выполнение команды SQL - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
       ZQuery1.Close;
       Zconnection1.disconnect;
     end;
   if ZQuery1.RecordCount=0 then
     begin
      ZQuery1.Close;
      Zconnection1.disconnect;
      exit;
     end;
    SetLength(ar_access, 0, 2);
    SetLength(ar_deny, 0, 4);
    SetLength(ar_srv, 0, 11);
   // Заполняем массивы
   Stringgrid3.RowCount := ZQuery1.RecordCount+1;
   SetLength(ar_srv, ZQuery1.RecordCount, 11);
   SetLength(ar_access, Length(ar_srv)*(Length(ar_srv)-1), 2);
   k:=0;
   for n:=0 to ZQuery1.RecordCount-1 do
    begin
      ar_srv[n,0] := ZQuery1.FieldByName('point_id').asString;
      ar_srv[n,1] := ZQuery1.FieldByName('name').asString;
      ar_srv[n,2]:=ZQuery1.FieldByName('id').asString;
      ar_srv[n,3]:=ZQuery1.FieldByName('active').asString;
      ar_srv[n,4]:=ZQuery1.FieldByName('activedate').asString;
      ar_srv[n,5]:=ZQuery1.FieldByName('usetarif').asString;
      ar_srv[n,6]:=ZQuery1.FieldByName('ip').asString;
      ar_srv[n,7]:=ZQuery1.FieldByName('ip2').asString;
      ar_srv[n,8]:=ZQuery1.FieldByName('info').asString;
      ar_srv[n,9]:= '0' ; // флаг редактирования
      ar_srv[n,10]:=ZQuery1.FieldByName('base_name').asString;

      //заполняем массив доступных пустыми значениями для каждого сервера
      for m:=0 to ZQuery1.RecordCount-2 do
       begin
          If k>length(ar_access) then
            begin
             showmessage('Переполнение массива доступных серверов !'+ar_srv[n,1]);
             continue;
            end;
          ar_access[k,0] := ar_srv[n,0];
          ar_access[k,1] := '';
          k := k + 1;
       end;
       //заполняем грид - серверы
      Stringgrid3.Cells[0,n+1] := ar_srv[n,0];
      Stringgrid3.Cells[1,n+1] := ar_srv[n,1];
      ZQuery1.next;
    end;

   j:=0;
   for n:=low(ar_srv) to high(ar_srv) do
    begin
         //заполяем массив доступных серверов реальными значениями
           // запрос
            ZQuery1.SQL.Clear;
            ZQuery1.SQL.add('SELECT destination_id FROM av_servers_access WHERE del=0 AND server_id='+ar_srv[n,0]+';');
            //     showmessage(ZQuery1.SQL.text);
            try
            ZQuery1.open;
            except
              showmessage('Выполнение команды SQL - ОШИБКА !'+#13+'Команда: '+ ZQuery1.SQL.Text);
              break;
            end;
           if ZQuery1.RecordCount>0 then
             begin
            For k:=0 to Length(ar_access)-1 do
             begin
              If ar_access[k,0] = ar_srv[n,0] then
              begin
               ar_access[k,1] := ZQuery1.FieldByName('destination_id').asString;
               ZQuery1.next;
              end;
             end;
            end;

            //ЗАПОЛНЯЕМ массив запрещенных пользователей для данного сервера
            ZQuery1.SQL.Clear;
            ZQuery1.SQL.add('SELECT a.denyuser_id, b.name, b.dolg FROM av_servers_denyuser AS a ');
            ZQuery1.SQL.add('JOIN av_users AS b ON b.id=a.denyuser_id AND b.del=0 WHERE a.del=0 AND server_id='+ar_srv[n,0]+' ORDER BY b.name;');
            //showmessage(ZQuery1.SQL.text);
            try
            ZQuery1.open;
            except
              showmessage('Выполнение команды SQL - ОШИБКА !'+#13+'Команда: '+ ZQuery1.SQL.Text);
              break;
            end;
            if ZQuery1.RecordCount<1 then continue;

             SetLength(ar_deny, Length(ar_deny)+ZQuery1.RecordCount, 4);
             For k:=0 to ZQuery1.RecordCount-1 do
             begin
               ar_deny[j+k,0] := ar_srv[n,0];
               ar_deny[j+k,1] := ZQuery1.FieldByName('denyuser_id').asString;
               ar_deny[j+k,2] := ZQuery1.FieldByName('name').asString;
               ar_deny[j+k,3] := ZQuery1.FieldByName('dolg').asString;
               ZQuery1.next;
             end;
             j:=j+k+1;
       end;
  ZQuery1.Close;
  Zconnection1.disconnect;
  end;
  UpdateServers();
end;



procedure TForm1.Button1Click(Sender: TObject);
var
  s: string;
  m:integer;
begin
  s:='';
  for n:=low(ar_deny) to high(ar_deny) do
     begin
       for m:=low(ar_deny[1]) to high(ar_deny[1]) do
         begin
           s:= s+ ar_deny[n,m]+' | ';
      //for m:=0 to 1 do
      //   begin
      //     s:=s+' | '+ar_access[n,m];
         end;
        s:=s+#13;
     end;
  showmessage(s);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //FormMain:=TFormMain.Create(self);
  //formMain.showmodal;
  //FreeAndNil(formMain);
end;



//******************************* до обновления гридов *******************************************
procedure TForm1.StringGrid3BeforeSelection(Sender: TObject; aCol, aRow: Integer);
begin
  SaveToMas();
end;

procedure TForm1.StringGrid3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  exit;
end;

//******************************** СОХРАНИТЬ ДАННЫЕ С ФОРМЫ В МАССИВ ******************************
procedure TForm1.SaveToMas();
var
   sss: string;
   l: byte=0;
   m:integer=0;
begin
 with Form1 do
 begin
 If StringGrid3.RowCount<2 then exit;
 If StringGrid3.Row <1 then exit;
 If StringGrid3.Row > (Length(ar_srv)+1) then exit;

 //ищем строчку грида сервера в массиве
 for n:=low(ar_srv) to high(ar_srv) do
  begin
    If ar_srv[n,0] = Stringgrid3.Cells[0,Stringgrid3.Row] then
      begin
       l := 1;
       m := n;
       break;
      end;
  end;
 If l=0 then
   begin
    showmessage('Ошибка! Массив данных не соответствует отображаемым данным !');
    exit;
   end;
 //признак активации
   If Checkbox4.checked then ar_srv[m,3]:='1' else ar_srv[m,3]:='0';
 //дата активации
   ar_srv[m,4] := DateEdit1.Text;
   //использовать при расчетах
   If Checkbox5.checked then ar_srv[m,5]:='1' else ar_srv[m,5]:='0';

   //ip-адрес **********************
   razbor:='';
   razbor:=razbor+padl(inttostr(SpinEdit2.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit3.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit4.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit5.Value),'0',3);
   ar_srv[m,6]:= razbor;
   //ip-адрес2 ************************
   razbor:='';
   razbor:=razbor+padl(inttostr(SpinEdit6.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit7.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit8.Value),'0',3)+'.';
   razbor:=razbor+padl(inttostr(SpinEdit9.Value),'0',3);
   ar_srv[m,7]:= razbor;
   //дополнительная информация
   ar_srv[m,8]:=trim(Memo4.Text);
   //база данных - наименование
   ar_srv[m,10]:=trim(Edit19.Text);


  //обнуляем массив доступных серверов для этого сервера
  m:=0;
  sss := '';
  For n:=0 to Length(ar_access)-1 do
     begin
    //  sss :=  sss+ ar_access[n,0]+'-'+ar_access[n,1]+', ';
       If trim(ar_access[n,0]) = Stringgrid3.Cells[0,Stringgrid3.row] then
         begin
            ar_access[n,1] := '';
            m := m+1;
            If m < StringGrid4.RowCount then
              begin
                 If Stringgrid4.Cells[2,m] = '1' then
                   begin
                    ar_access[n,1] := Stringgrid4.Cells[0,m];
                   end;
              end;
         end;
     end;
 // showmessage(sss);
end;
end;

// обновить гриды
procedure TForm1.StringGrid3Selection(Sender: TObject; aCol, aRow: Integer);
begin
    UpdateServers();
end;

// **************************** ОТРИСОВКА ГРИДА ЖУРНАЛА ВХОДА ПОЛЬЗОВАТЕЛЕЙ *****************
procedure TForm1.StringGrid6DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
     with Sender as TStringGrid, Canvas do
  begin
       Brush.Color:=clWhite;
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
            font.Size:=12;
            font.Style:= [];
           end
         else
          begin
            font.Style:= [];
            Font.Color := clBlack;
            font.Size:=11;
          end;

       // Остальные поля
    // if (aRow>0) and not(aCol=1) and not(aCol=2) and not(aCol=0) then
     if (aRow>0) and not(aCol=3) then
         begin
     //     Font.Size:=10;
     //     Font.Color := clBlack;
          TextOut(aRect.Left + 10, aRect.Top+8, Cells[aCol, aRow]);
         end;

      // АРМ
      if (aRow>0) and (aCol=3) then
         begin
          Font.Size:=8;
         // Font.Color := clBlack;
          TextOut(aRect.Left + 3, aRect.Top+8, Cells[aCol, aRow]);
         end;

      // Заголовок
       if aRow=0 then
         begin
           RowHeights[aRow]:=30;
           Brush.Color:=clCream;
           FillRect(aRect);
           Font.Color := clBlack;
           font.Size:=8;
           font.Style:=[fsBold];
           TextOut(aRect.Left + 5, aRect.Top+15, Cells[aCol, aRow]);
           //Рисуем значки сортировки и активного столбца
            DrawCell_header(aCol,Canvas,aRect.left,(Sender as TStringgrid));
          end;
     end;
end;

procedure TForm1.StringGrid6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Click_Header((Sender as TStringgrid),X,Y,Self.ProgressBar1);
end;

 //***************************** обновить гриды на вкладке СЕРВЕРА *****************************
procedure TForm1.UpdateServers();
var
   k,l : integer;
   m:integer=0;
begin
 With Form1 do
 begin
 If StringGrid3.RowCount<2 then exit;
 If StringGrid3.Row <1 then exit;
 If StringGrid3.Row > (Length(ar_srv)+1) then exit;
 l:=0;
 //поиск массиве строчки грида сервера
 For n:=0 to Length(ar_srv)-1 do
  begin
    If ar_srv[n,0] = Stringgrid3.Cells[0,Stringgrid3.row] then
      begin
        l:=1;
        k:=n;
        break;
      end;
   end;
 If l=0 then exit; //если не нашли - выход

 //определяем данные на форме
   If ar_srv[k,3] = '1' then
      Checkbox4.Checked:= true
      else Checkbox4.Checked:= false;
   If ar_srv[k,5] = '1' then
      Checkbox5.Checked:= true
      else Checkbox5.Checked:= false;
   DateEdit1.Text:= ar_srv[k,4];
   SpinEdit2.Value:=0;
   SpinEdit3.Value:=0;
   SpinEdit4.Value:=0;
   SpinEdit5.Value:=0;
   SpinEdit6.Value:=0;
   SpinEdit7.Value:=0;
   SpinEdit8.Value:=0;
   SpinEdit9.Value:=0;

   razbor:=trim(ar_srv[k,6]);
   If razbor <> '' then
     begin
   If ansipos('.',razbor)>0 then
   SpinEdit2.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If ansipos('.',razbor)>0 then
   SpinEdit3.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If ansipos('.',razbor)>0 then
   SpinEdit4.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   SpinEdit5.Value:=strtoint(copy(razbor,1,255));
   end;

   razbor:=trim(ar_srv[k,7]);
   If razbor <> '' then
     begin
   If ansipos('.',razbor)>0 then
   SpinEdit6.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If ansipos('.',razbor)>0 then
   SpinEdit7.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If ansipos('.',razbor)>0 then
   SpinEdit8.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   SpinEdit9.Value:=strtoint(copy(razbor,1,255));
   end;

   Memo4.Text := ar_srv[k,8];
   Edit19.Text := ar_srv[k,10];

  //заполняем гриды
   StringGrid4.RowCount := 1;
   StringGrid4.RowCount := StringGrid3.RowCount-1;
   StringGrid4.Columns[2].ValueChecked:='1';
   StringGrid4.Columns[2].ValueUnchecked:='0';
  // SetLength(ar_access, StringGrid3.RowCount-1, 2);
  // SetLength(ar_deny, StringGrid3.RowCount-1, 3);

   FOR n:=1 to StringGrid3.RowCount-1 do
     begin
        If n=StringGrid3.Row then continue;
        m:= m+1;
        StringGrid4.Cells[0,m]:=StringGrid3.Cells[0,n];
        StringGrid4.Cells[1,m]:=StringGrid3.Cells[1,n];
        StringGrid4.Cells[2,m]:='0';
     end;
   //определяем доступные сервера
    For n:=low(ar_access) to high(ar_access) do
      begin
       // определяем текущий сервер в массиве доступных
        If (trim(ar_access[n,0])<>'') AND (ar_access[n,0]=ar_srv[k,0]) then
          begin
            If  trim(ar_access[n,1]) <> ''  then
              begin
                for m:=1 to Stringgrid4.RowCount-1 do
                  begin
                   If StringGrid4.Cells[0,m]=ar_access[n,1] then
                     begin
                     StringGrid4.Cells[2,m]:='1';
                     break;
                     end;
                  end;
              end;
          end;
      end;

   //определяем запрещенных пользователей
   Stringgrid5.RowCount:=1;
    For n:=low(ar_deny) to high(ar_deny) do
      begin
        If (ar_deny[n,0]=ar_srv[k,0]) AND (trim(ar_deny[n,0])<>'') AND (trim(ar_deny[n,1])<>'') then
          begin
             Stringgrid5.RowCount := Stringgrid5.RowCount+1;
             Stringgrid5.Cells[0,Stringgrid5.RowCount-1]:= ar_deny[n,1]; //id юзера
             Stringgrid5.Cells[1,Stringgrid5.RowCount-1]:= ar_deny[n,2]; //имя
             Stringgrid5.Cells[2,Stringgrid5.RowCount-1]:= ar_deny[n,3]; //должность
          end;
      end;
  end;
 end;



// **************************************  ДОБАВИТЬ СЕРВЕР ПРОДАЖИ ****************************************
procedure TForm1.BitBtn25Click(Sender: TObject);
var
  m:integer=0;
begin
  form9:=Tform9.create(self);
  form9.ShowModal;
  FreeAndNil(form9);
  //Добавляем остановочный пункт
  if (result_name_point='') then exit;
  with Form1 do
  begin
   // проверка на дубликат
   for n:=1 to StringGrid3.RowCount-1 do
    begin
     If trim(StringGrid3.Cells[0,n]) = result_name_point then
       begin
        showmessage('Данный остановочный пункт уже есть в списке серверов !');
        exit;
       end;
    end;

    SetLength(ar_srv, Length(ar_srv)+1, 10);
    m := Length(ar_srv);
    ar_srv[m-1,0] := result_name_point; //id остановочного пункта
    ar_srv[m-1,1] := name_pnt; // наименование остановочного пункта сервера
    ar_srv[m-1,2] := ''; // id
    ar_srv[m-1,4] := DateToStr(Date());
    ar_srv[m-1,5] := '1'; //использовать при расчете тарифов по умолчанию
    ar_srv[m-1,9] := '1'; // флаг добавления записи

   //определяем массив доступных серверов
   n := (StringGrid3.RowCount) * (StringGrid3.RowCount-1);
   If n > Length(ar_access) then
   begin
    m := Length(ar_access);
    SetLength(ar_access, n, 2);
    for n:=1 to StringGrid3.RowCount-1 do
     begin
      ar_access[m+n-1,0]:= StringGrid3.cells[0,n];
     end;
    for n:=1 to StringGrid3.RowCount-1 do
     begin
      ar_access[Length(ar_access)-n,0]:= result_name_point;
     end;
   end;
  //  showmessage(inttostr(length(ar_access)));
   StringGrid3.RowCount := StringGrid3.RowCount+1;
   Stringgrid3.Cells[0,StringGrid3.RowCount-1] := result_name_point;
   Stringgrid3.Cells[1,StringGrid3.RowCount-1] := name_pnt;
   StringGrid3.Row := StringGrid3.RowCount-1;
   UpdateServers();
  // StringGrid3.SetFocus;
  end;
end;

// ***************************************** УДАЛИТЬ СЕРВЕР ПРОДАЖИ *************************************
procedure TForm1.BitBtn26Click(Sender: TObject);
var
   l: integer=0;
   m:integer=0;
begin
 With Form1 do
 begin
  If  trim(StringGrid3.Cells[0,StringGrid3.Row])='' then exit;
  If StringGrid3.RowCount < 2 then exit;
  //ищем строку в массиве
  for n:=0 to length(ar_srv)-1 do
   begin
    If ar_srv[n,0] = Stringgrid3.cells[0,Stringgrid3.Row] then
     begin
      l:=1;
      m:=n;
      break;
     end;
   end;
  If l=0 then
   begin
      showmessage('Ошибка! Массив данных не соответствует отображаемым данным !');
      exit;
    end;
  //очищаем массив доступных от удаляемого сервера
  for n:=0 to Length(ar_access)-1 do
   begin
     If ar_access[n,0] = ar_srv[m,0] then
       begin
          ar_access[n,0] := '';
          ar_access[n,1] := '';
       end;
   end;
  //очищаем массив запрещенных пользователей
  for n:=0 to Length(ar_deny)-1 do
   begin
     If ar_deny[n,0] = ar_srv[m,0] then
       begin
          ar_deny[n,0] := '';
          ar_deny[n,1] := '';
       end;
   end;

   DelStringGrid(form1.StringGrid3,form1.StringGrid3.Row);
  //если удаляется сервер из базы, то пометить на удаление
  If ar_srv[m,9] = '0' then
    begin
      ar_srv[m,9] := '2';
      ar_srv[m,1] := '';
    end;
  //если удаляется сервер, созданный в этом сеансе, удалить из массива следы о нем
  If ar_srv[m,9] = '1' then
    begin
     ar_srv[m,0] := '';
     ar_srv[m,1] := '';
    end;
  end;
 UpdateServers();
end;


//************************************************  ДОБАВИТЬ ЗАПРЕЩЕННОГО ПОЛЬЗОВАТЕЛЯ *******************
procedure TForm1.BitBtn24Click(Sender: TObject);
begin
  //ОТКРЫВАЕМ справочник юзеров
  form_Users:=Tform_users.create(self);
  form_Users.ShowModal;
  FreeAndNil(form_users);
 //обрабатываем выбор
  if (result_user = '') then exit;
 //проверка на совпадающие
  with Form1 do
  begin
  for n:=1 to Stringgrid5.RowCount-1 do
    begin
      If Stringgrid5.Cells[0,n]=result_user then
      begin
       showmessage('Добавляемый пользователь уже есть в списке !');
       exit;
      end;
    end;
  // Подключаемся к серверу
  MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
  try
      Zconnection1.connect;
  except
     showmessage('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
     exit;
  end;
   // запрос
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT name, dolg FROM av_users WHERE del=0 AND id='+result_user+';');
  try
    ZQuery1.open;
  except
     showmessage('Выполнение команды SQL - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
  end;
  if ZQuery1.RecordCount<>1 then
     begin
      showmessage('Ошибка выбора реквизитов пользователя из справочника!');
     end;
  SetLength(ar_deny, Length(ar_deny)+1,4);
  ar_deny[Length(ar_deny)-1,0] := form1.Stringgrid3.Cells[0,form1.Stringgrid3.Row];
  ar_deny[Length(ar_deny)-1,1] := result_user;
  ar_deny[Length(ar_deny)-1,2] := form1.ZQuery1.FieldByName('name').AsString;
  ar_deny[Length(ar_deny)-1,3] := form1.ZQuery1.FieldByName('dolg').AsString;
  Stringgrid5.RowCount := Stringgrid5.RowCount +1;
  Stringgrid5.Cells[0,Stringgrid5.RowCount-1] := result_user;
  Stringgrid5.Cells[1,Stringgrid5.RowCount-1] := form1.ZQuery1.FieldByName('name').AsString;
  Stringgrid5.Cells[2,Stringgrid5.RowCount-1] := form1.ZQuery1.FieldByName('dolg').AsString;

  end;
end;


//************************************** УДАЛИТЬ ЗАПРЕЩЕННОГО ПОЛЬЗОВАТЕЛЯ *********************************
procedure TForm1.BitBtn27Click(Sender: TObject);
begin
 With Form1 do
 begin
  If  trim(StringGrid5.Cells[0,StringGrid5.Row])='' then exit;
  If StringGrid5.RowCount < 2 then exit;
  for n:=0 to Length(ar_deny)-1 do
    begin
      IF ar_deny[n,0]= Stringgrid5.Cells[0,Stringgrid5.Row] then
      begin
          ar_deny[n,0]:='';
          ar_deny[n,1]:='';
          ar_deny[n,2]:='';
          ar_deny[n,3]:='';
       end;
    end;
  end;
  DelStringGrid(form1.StringGrid5,form1.StringGrid5.Row);
 end;


//*************************************  ДОБАВИТЬ ДОСТУПНЫЙ СЕРВЕР ПРОДАЖИ *****************************
procedure TForm1.BitBtn28Click(Sender: TObject);
begin
 With Form1 do
 begin
  //If  trim(StringGrid3.Cells[0,StringGrid3.Row])='' then exit;
  //StringGrid4.RowCount := StringGrid4.RowCount+1;
  //StringGrid4.Cells[0,StringGrid4.RowCount-1] := trim(StringGrid3.Cells[0,StringGrid3.Row]);
  //StringGrid4.Cells[1,StringGrid4.RowCount-1] := trim(StringGrid3.Cells[1,StringGrid3.Row]);
  //StringGrid4.Row := StringGrid4.RowCount-1;
  //StringGrid4.SetFocus;
  end;
end;

//*************************************  УдалИТЬ ДОСТУПНЫЙ СЕРВЕР ПРОДАЖИ *****************************
procedure TForm1.BitBtn29Click(Sender: TObject);
begin
 With Form1 do
 begin
  //If  trim(StringGrid4.Cells[0,StringGrid4.Row])='' then exit;
  //If StringGrid4.RowCount < 2 then exit;
  //DelStringGrid(form1.StringGrid4,form1.StringGrid4.Row);
  end;
end;


//******************************** СОХРАНИТЬ ДАННЫЕ ПО СЕРВЕРАМ ПРОДАЖИ ***********************************
procedure TForm1.BitBtn23Click(Sender: TObject);
var
   fl_edit : byte;
   m:integer=0;
begin
 SaveToMas();
 With Form1 do
 begin
  // Подключаемся к серверу
  MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
  try
      Zconnection1.connect;
  except
      showmessage('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
  end;

   for n:=0 to Length(ar_srv)-1 do
    begin
    //проверка введеных данных
   // If (SpinEdit2.Value=0) AND (SpinEdit3.Value=0) AND (SpinEdit4.Value=0) AND (SpinEdit5.Value=0) then
     If trim(ar_srv[n,6])='000.000.000.000' then
     begin
       showmessage('Некорректный IP-адрес у '+ar_srv[n,1]+' !');
       exit;
       end;
     If ar_srv[n,3]='1' then
     begin
       If trim(ar_srv[n,4])='' then
       begin
       showmessage('Некорректная Дата активации у '+ar_srv[n,1]+' !');
       exit;
       end;
     end;

    //если сервер был удален из массива, пропустить
     If (ar_srv[n,0]='') then continue;
     If ar_srv[n,9] = '4' then continue;
     IF (ar_srv[n,9]='0') then fl_edit:=0;
     IF (ar_srv[n,9]='1') then fl_edit:=1;
     IF (ar_srv[n,9]='2') then fl_edit:=2;

  //Открываем транзакцию
  try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      showmessage('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      ZConnection1.Rollback;
      exit;
     end;
   if (fl_edit<>1) AND (trim(ar_srv[n,2])='') then
    begin
      showmessage('Несоответствие в массиве серверов !');
      exit;
     end;
   //обрабатываем удаленные сервера
    If fl_edit=2 then
      begin
     //Маркируем запись на удаление (del=2) если сервер был удален
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_denyuser SET del=2,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.open;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_access SET del=2,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.open;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers SET del=2,createdate=now(),id_user='+gluser+' WHERE id='+ar_srv[n,2]+' AND del=0;');
       ZQuery1.open;
      end;

   //Маркируем запись на удаление (del=0) если режим редактирования
   if (fl_edit=0) then
      begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_denyuser SET del=1,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.open;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_access SET del=1,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.open;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers SET del=1,createdate=now(),id_user='+gluser+' WHERE id='+ar_srv[n,2]+' AND del=0;');
       ZQuery1.open;
     end;


   //если новый
  If fl_edit=1 then
     begin
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.add('SELECT MAX(id) as new_id FROM av_servers;');
        ZQuery1.open;
        new_id := ZQuery1.FieldByName('new_id').asInteger+1;
     end;
  //Производим запись новых данных
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('INSERT INTO av_servers(active,activedate,usetarif,point_id,ip,ip2,info,base_name,id,id_user,createdate,del,id_user_first,createdate_first) VALUES (');

  ZQuery1.SQL.add(ar_srv[n,3]+','+QuotedStr(ar_srv[n,4])+','+ar_srv[n,5]+','+ar_srv[n,0]+','+QuotedSTR(ar_srv[n,6])+',');
  ZQuery1.SQL.add(QuotedStr(ar_srv[n,7])+','+QuotedStr(ar_srv[n,8])+','+QuotedStr(ar_srv[n,10])+',');
  //если этот сервер уже был в базе
  IF fl_edit=0 then
     begin
      ZQuery1.SQL.add(ar_srv[n,2]+','+gluser+',now(),0,NULL,NULL);');
     end;
  //если новый
   If fl_edit=1 then
     begin
        //ZQuery1.SQL.add(ar_srv[n,3]+','+QuotedStr(ar_srv[n,4])+','+ar_srv[n,5]+','+ar_srv[n,0]+','+QuotedSTR(ar_srv[n,6])+','+QuotedStr(ar_srv[n,7])+','+QuotedStr(ar_srv[n,8])+',');
        ZQuery1.SQL.add(inttostr(new_id)+','+gluser+',now(),0,'+gluser+',now());');
     end;
   //showmessage(ZQuery1.SQL.text);
   ZQuery1.open;

   //Пишем доступные сервера
   for m:=0 to Length(ar_access)-1 do
    begin
      If ar_srv[n,0]=ar_access[m,0] then
        begin
         If trim(ar_access[m,1])<>'' then
           begin
             //Производим запись новых данных
            ZQuery1.SQL.Clear;
            ZQuery1.SQL.add('INSERT INTO av_servers_access(server_id,destination_id,id_user,createdate,del,id_user_first,createdate_first) VALUES (');
            //если этот сервер уже был в базе
            IF fl_edit=0 then
              begin
               ZQuery1.SQL.add(ar_access[m,0]+','+ar_access[m,1]+','+gluser+',now(),0,NULL,NULL);');
              end;
            //если новый
            If fl_edit=1 then
              begin
               ZQuery1.SQL.add(ar_access[m,0]+','+ar_access[m,1]+','+gluser+',now(),0,'+gluser+',now());');
              end;
            ZQuery1.open;
           end;
        end;
    end;

   //Пишем запрещенных пользователей
   for m:=low(ar_deny) to high(ar_deny) do
    begin
      If (ar_srv[n,0]=ar_deny[m,0]) AND (trim(ar_deny[m,1])<>'') then
        begin
            //Производим запись новых данных
            ZQuery1.SQL.Clear;
            ZQuery1.SQL.add('INSERT INTO av_servers_denyuser(server_id,denyuser_id,id_user,createdate,del,id_user_first,createdate_first) VALUES (');
            //если этот сервер уже был в базе
            IF fl_edit=0 then
              begin
               ZQuery1.SQL.add(ar_deny[m,0]+','+ar_deny[m,1]+','+gluser+',now(),0,NULL,NULL);');
              end;
            //если новый
            If fl_edit=1 then
              begin
               ZQuery1.SQL.add(ar_deny[m,0]+','+ar_deny[m,1]+','+gluser+',now(),0,'+gluser+',now());');
              end;
             //showmessage(ZQuery1.SQL.text);
            ZQuery1.open;
        end;
    end;

  // Завершение транзакции
  Zconnection1.Commit;
  ar_srv[n,9] := '4'; //убираем из списка несохраненных
 // Close;
 except
     ZConnection1.Rollback;
     showmessage('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 end;
 end;
  ZQuery1.Close;
  Zconnection1.disconnect;
  showmessage('Данные успешно сохранены !');
  UpdateServers();
end;
end;


//// ******   Кнопка СДлеать снимок ********** СФОТОГРАФИРОВАТЬ **********************************************************************
procedure TForm1.BitBtn18Click(Sender: TObject);
begin
 fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(form1.edit10.text)+'x'+trim(form1.edit12.text)+' -r 30 -i '+trim(form1.edit9.text)+' -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(form1.edit10.text)+'x'+trim(form1.edit12.text)+' -r 30 -i '+trim(form1.edit9.text)+' -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(form1.edit10.text)+'x'+trim(form1.edit12.text)+' -r 30 -i '+trim(form1.edit9.text)+' -f image2 webcam.jpg');
 form1.image3.Picture.LoadFromFile('webcam.jpg');
end;


// ******* старт видео *********************************************
procedure TForm1.BitBtn19Click(Sender: TObject);
begin
  form1.BitBtn20.Enabled:=true;
  form1.BitBtn19.Enabled:=false;
  form1.Timer1.Enabled:=not(form1.Timer1.Enabled);
end;


//*******************                         кнопка ДОБАВИТЬ юзера *******************************************************************
procedure TForm1.BitBtn10Click(Sender: TObject);
begin
  //показать все вкладки
  Form3:=TForm3.Create(self);
  //form3.pagecontrol1.Pages[0].TabVisible:=true;
  //form3.pagecontrol1.Pages[1].TabVisible:=true;
  //form3.PageControl1.ActivePageIndex:=0;
  nUserFlag:=1;
  form3.ShowModal;
  FreeAndNil(form3);
end;

//******************************************** СТОП ТЕСТА КАМЕРЫ******************************************************
procedure TForm1.BitBtn20Click(Sender: TObject);
begin
  form1.BitBtn20.Enabled:=false;
  form1.BitBtn19.Enabled:=true;
  form1.Timer1.Enabled:=not(form1.Timer1.Enabled);
end;

// ***************************           УДАЛИТЬ ЮЗЕРА ************************************************************************
procedure TForm1.BitBtn11Click(Sender: TObject);
var
 imes: integer;
begin
  //Подтверждение
  imes := MessageDlg('Действительно удалить запись?',mtConfirmation, mbYesNo, 0);
  if imes=6 then
    begin
     MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
     //Открываем транзакцию
     with Form1 do
     begin
       ZConnection1.StartTransaction;
       Zconnection1.AutoCommit:=false;
       //Удаляем запись из разрешенных пользователю армов
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('DELETE FROM av_users_arm WHERE id_user='+form1.StringGrid1.Cells[1,form1.StringGrid1.Row]+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление опции армов этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=2,createdate=DEFAULT,id_user='+gluser+' WHERE del=0 AND id='+form1.StringGrid1.Cells[1,form1.StringGrid1.Row]+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление разрешения меню этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2,createdate=DEFAULT,id_user='+gluser+' WHERE del=0 AND id='+form1.StringGrid1.Cells[1,form1.StringGrid1.Row]+';');
       ZQuery1.ExecSQL;

       //помечаем пользователя на удаление
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users SET del=2,status=0,createdate=DEFAULT,id_user='+Gluser+' WHERE del=0 AND id='+form1.StringGrid1.Cells[1,form1.StringGrid1.Row]);
       ZQuery1.ExecSQL;
      // Завершение транзакции
       Zconnection1.Commit;
       Zconnection1.AutoCommit:=true;
     if ZConnection1.InTransaction then
     begin
       showmessage('Данные НЕ обновлены !'+#13+'Не удается завершить транзакцию !!!');
       ZConnection1.Rollback;
       Zconnection1.disconnect;
       exit;
     end;
       showmessage('Запись завершена УСПЕШНО !!!');
       Zconnection1.disconnect;
    end;
    end;
end;

//*******************************          кнопка ИЗМЕНИТЬ  ЮЗЕРА ************************************************************************************
procedure TForm1.BitBtn12Click(Sender: TObject);
begin
  with form1.StringGrid1 do
  begin
  //проверка, что выбрана запись для редактирования
  IF (Cells[1,row]=emptystr) or (Cells[1,row]='ID') then
    begin
     showmessage('Сначала выберите запись для редактирования!');
     exit;
     end;
  Form3:=TForm3.Create(self);
  //скрыть остальные вкладки
  //form3.pagecontrol1.Pages[0].TabVisible:=false;
  //form3.pagecontrol1.Pages[1].TabVisible:=false;
  //form3.PageControl1.ActivePageIndex:=2;
  nUserFlag:=2;
   masedit[0]:=masuser[row,0];//FieldbyName('id').AsWideString;
   masedit[1]:=masuser[row,1];//FieldbyName('name').AsWideString;
   masedit[2]:=masuser[row,2];//FieldbyName('createdate').AsWideString;
   masedit[3]:=masuser[row,3];//FieldbyName('kodotd').AsWideString;
   masedit[4]:=masuser[row,4];//FieldbyName('kodpodr').AsWideString;
   masedit[5]:=masuser[row,5];//FieldbyName('birthday').AsWideString;
   masedit[6]:=masuser[row,6];//FieldbyName('passw').AsWideString;
   masedit[7]:=masuser[row,7];//FieldbyName('fullname').AsWideString;
   masedit[8]:=masuser[row,8];//FieldbyName('pol').AsWideString;
   masedit[9]:=masuser[row,9];//FieldbyName('dolg').AsWideString;
   masedit[10]:=masuser[row,10];//FieldbyName('grupa').AsWideString;
   masedit[11]:=masuser[row,11];//FieldbyName('status').AsWideString;
   masedit[12]:=masuser[row,12];//FieldbyName('kod1c').AsWideString;
   masedit[13]:=masuser[row,13];//FieldbyName('tip').AsWideString;
   masedit[14]:=masuser[row,14];//FieldbyName('info').AsWideString;
   masedit[15]:=masuser[row,15];//FieldbyName('namepodr').AsWideString;
   masedit[16]:=masuser[row,16];//имя отделения
   masedit[17]:=masuser[row,17];//УДАЛЕН
   masedit[18]:=masuser[row,18];//group_id
  end;
  form3.showmodal;
  FreeAndNil(form3);
  BitBtn16.Click;   //обновляем повторно
end;


// ********************           кнопка ДОСТУП      *******************************************************************
procedure TForm1.BitBtn13Click(Sender: TObject);
begin
   if not(form1.StringGrid1.RowCount>1) then
    begin
      showmessage('Нет выбранных пользователей системы');
      exit;
    end;
  id_user_global:=form1.StringGrid1.cells[1,form1.StringGrid1.row];
  id_user_name:=form1.StringGrid1.cells[2,form1.StringGrid1.row];
  Form5:=TForm5.Create(self);
  form5.showmodal;
  FreeAndNil(form5);
end;

// ********************************************   ТЕСТ соединения РЕАЛЬНЫЙ **********************************************
procedure TForm1.BitBtn2Click(Sender: TObject);
 var
   log_test:string;
begin
   log_test:='';
   MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
   //Соединяемся с сервером Postgree
   try
     form1.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit2.text+':'+form1.Edit4.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit2.text+':'+form1.Edit4.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   form1.Zconnection1.disconnect;

   MConnect(Zconnection1,ConnectINI[12],ConnectINI[2]);
   //form1.ZConnection1.hostname:=form1.Edit3.text;
   try
     form1.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit3.text+':'+form1.Edit4.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit3.text+':'+form1.Edit4.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   form1.Zconnection1.disconnect;

   showmessage(log_test);
end;

//*******************************************  обновить журнал входа
procedure TForm1.BitBtn30Click(Sender: TObject);
var
 n,j: integer;
begin
   MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
     try
       form1.Zconnection1.connect;
     except
       showmessage('Соединение с сервером SQL - ОШИБКА');
       exit;
     end;
   // Выбор пользователей
     with form1.ZQuery1 do
     begin
        SQL.Clear;
         SQL.add('Select u.indatetime,u.outdatetime,u.ipuser,u.id_user,u.id_arm,p.name,p.group_id,g.grupa,b.armname ');
         SQL.add('from av_login_log as u ');
         SQL.add('LEFT JOIN av_users as p ON u.id_user=p.id and p.del=0 ');
         SQL.add('LEFT JOIN av_users_groups as g ON p.group_id=g.id ');
         SQL.add('LEFT JOIN av_arm as b ON u.id_arm=b.id ');
         SQL.add('ORDER BY u.id ASC; ');
//         showmessage(SQL.text);
   try
      open;
   except
     Close;
     form1.Zconnection1.disconnect;
     showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
     exit;
   end;

   // Если нет записей
    if RecordCount<1 then
     begin
      showmessage('В системе нет зарегистрированных пользоватей !');
      Close;
      form1.Zconnection1.disconnect;
      exit;
     end;
   end;
   with form1.stringgrid6 do
   begin
   // Заполняем STRINGGRID и массив данными о пользователях
   RowCount:=form1.ZQuery1.recordcount+1;
   for n:=1 to form1.ZQuery1.Recordcount do
       begin
          cells[0,n]:=copy(form1.ZQuery1.FieldByName('indatetime').AsString,1,16);
          cells[1,n]:=copy(form1.ZQuery1.FieldByName('outdatetime').AsString,1,16);
          cells[2,n]:=form1.ZQuery1.FieldByName('ipuser').AsString;
          cells[3,n]:=form1.ZQuery1.FieldByName('armname').AsString;
          cells[4,n]:=form1.ZQuery1.FieldByName('id_user').AsString;
          cells[5,n]:=form1.ZQuery1.FieldByName('name').AsString;
          cells[6,n]:=form1.ZQuery1.FieldByName('grupa').AsString;
          form1.ZQuery1.next;
     end;
   SetFocus;
   end;
end;

procedure TForm1.BitBtn32Click(Sender: TObject);
begin
  //******************************************* УКАЗАТЬ ПУТЬ К базам 1С ************************************
  Form1.dialog1.Execute;
  form1.edit8.Text:=Form1.dialog1.FileName;
end;

procedure TForm1.BitBtn33Click(Sender: TObject);
begin
  Form8:=TForm8.Create(self);
  form8.showmodal;
  FreeAndNil(form8);
end;

//выбрать остановочный пункт из списка серверов ******************************
procedure TForm1.BitBtn34Click(Sender: TObject);
begin
  with Form1 do
begin
  PageControl1.Pages[0].Enabled:=false;
  PageControl1.Pages[2].Enabled:=false;
  PageControl1.Pages[3].Enabled:=false;
  PageControl1.Pages[4].Enabled:=false;
  PageControl1.Pages[5].Enabled:=false;
  PageControl1.Pages[6].Enabled:=false;
  //BitBtn23.Visible:= false;
  BitBtn25.Visible:= false;
  BitBtn26.Visible:= false;
  //GroupBox6.Visible:=false;
  //GroupBox7.Visible:=false;
  //GroupBox8.Visible:=false;
  GroupBox6.enabled:=false;
  GroupBox7.enabled:=false;
  GroupBox8.enabled:=false;
  BitBtn35.Visible:= true;
  BitBtn36.Visible:= true;
  //Stringgrid3.Visible:=true;
  Form1.PageControl1.ActivePage := TabSheet6;
  end;
end;


procedure TForm1.BitBtn35Click(Sender: TObject);
begin
//******************  выбрать остановочный пункт из списка серверов ******************************
  with Form1 do
begin
  If (Stringgrid3.Cells[0,Stringgrid3.Row]<>'') AND (Stringgrid3.RowCount>1) then
   Edit20.Text:=Stringgrid3.Cells[0,Stringgrid3.Row];

  PageControl1.Pages[0].Enabled:=true;
  PageControl1.Pages[2].Enabled:=true;
  PageControl1.Pages[3].Enabled:=true;
  PageControl1.Pages[4].Enabled:=true;
  PageControl1.Pages[5].Enabled:=true;
  PageControl1.Pages[6].Enabled:=true;
  //BitBtn23.Visible:= true;
  BitBtn25.Visible:= true;
  BitBtn26.Visible:= true;
  //GroupBox6.Visible:=true;
  //GroupBox7.Visible:=true;
  //GroupBox8.Visible:=true;
  GroupBox6.enabled:=true;
  GroupBox7.enabled:=true;
  GroupBox8.enabled:=true;
  BitBtn35.Visible:= false;
  BitBtn36.Visible:= false;
  Form1.PageControl1.ActivePage := TabSheet1;
end;
end;

procedure TForm1.BitBtn36Click(Sender: TObject);
begin
    with Form1 do
begin
  PageControl1.Pages[0].Enabled:=true;
  PageControl1.Pages[2].Enabled:=true;
  PageControl1.Pages[3].Enabled:=true;
  PageControl1.Pages[4].Enabled:=true;
  PageControl1.Pages[5].Enabled:=true;
  PageControl1.Pages[6].Enabled:=true;
  //BitBtn23.Visible:= true;
  BitBtn25.Visible:= true;
  BitBtn26.Visible:= true;
  //GroupBox6.Visible:=true;
  //GroupBox7.Visible:=true;
  //GroupBox8.Visible:=true;
  GroupBox6.enabled:=true;
  GroupBox7.enabled:=true;
  GroupBox8.enabled:=true;
  BitBtn35.Visible:= false;
  BitBtn36.Visible:= false;
  Form1.PageControl1.ActivePage := TabSheet1;
end;
end;


// ********************************************   ТЕСТ соединения ЭМУЛИРУЕМЫЙ **********************************************
procedure TForm1.BitBtn3Click(Sender: TObject);
 var
   log_test:string;
begin
   log_test:='';
   MConnect(Zconnection1,ConnectINI[6],ConnectINI[4]);
   //Соединяемся с сервером Postgree
   try
     form1.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit2.text+':'+form1.Edit4.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit2.text+':'+form1.Edit4.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   form1.Zconnection1.disconnect;

   MConnect(Zconnection1,ConnectINI[13],ConnectINI[5]);
   try
     form1.Zconnection1.connect;
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit3.text+':'+form1.Edit4.text+' - УСПЕШНО !!!'+chr(13);
   except
     log_test:=log_test+'Соединение с сервером SQL: '+form1.Edit3.text+':'+form1.Edit4.text+' - НЕУДАЧНО !!!'+chr(13);
   end;
   form1.Zconnection1.disconnect;

   showmessage(log_test);
end;


// *********************************      ЗАПИСАТЬ ini       ***************************************************
procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  //Обновление записей ini файла
  with Form1.IniPropStorage1 do
   begin
     inifilename:=form1.edit1.Text+'local.ini';
     IniSection:='REAL SERVER SQL'; //указываем секцию
     WriteString('ip_central',form1.edit2.text);
     WriteString('port_central',form1.Edit13.Text);
     WriteString('ip_local',form1.edit3.text);
     WriteString('port_local',form1.Edit14.Text);
     WriteString('name_base',form1.edit4.text);
     WriteString('name_base_local',form1.edit17.text);
     IniSection:='EMU SERVER SQL'; //указываем секцию
     WriteString('ip_central',form1.edit5.text);
     WriteString('port_central',form1.Edit15.Text);
     WriteString('ip_local',form1.edit6.text);
     WriteString('port_local',form1.Edit16.Text);
     WriteString('name_base',form1.edit7.text);
     WriteString('name_base_local',form1.edit18.text);
     IniSection:='LOCAL SETTINGS'; //указываем секцию
     WriteString('load_1c',form1.edit11.text);
     WriteString('id_point_local',form1.edit20.text);
     form1.edit8.Text:=form1.edit11.text;
   end;
   showmessage('Файл local.ini успешно обновлен');
end;


//  ******************************************** СОЗДАТЬ  ********************************************
procedure TForm1.BitBtn5Click(Sender: TObject);
var
  imes :integer;
begin
  // Проверяем что путь задан для создания local.ini
  if form1.edit1.Text='' then
    begin
     showmessage('Не введены параметры пути к файлу!');
     exit;
    end;

  imes:= MessageDlg('Вы действительно хотите переписать файл настроек значениями по умолчанию?',mtConfirmation, mbYesNo, 0);
  if imes=6 then
   begin
  // Создаем local.ini с значениями по дефолту
  // Запись в INI
   with Form1.IniPropStorage1 do
    begin
      inifilename:=form1.edit1.Text+'local.ini';
      IniSection:='REAL SERVER SQL'; //указываем секцию
      WriteString('ip_central','10.10.10.10');
      WriteString('port_central','5432');
      WriteString('ip_local','11.11.11.11');
      WriteString('port_local','5432');
      WriteString('name_base','platforma');
      WriteString('name_base_local','platforma');
      IniSection:='EMU SERVER SQL'; //указываем секцию
      WriteString('ip_central','30.30.30.30');
      WriteString('port_central','5432');
      WriteString('ip_local','31.31.31.31');
      WriteString('port_local','5432');
      WriteString('name_base','platforma_emu');
      WriteString('name_base_local','platforma');
      IniSection:='LOCAL SETTINGS'; //указываем секцию
      WriteString('load_1c','/home/egor');
    end;
    // Активируем эелементы
    with form1 do
    begin
    Shape1.Brush.Color:=clLime;
    BitBtn5.enabled:=false;
    BitBtn4.enabled:=true;
    GroupBox1.Enabled:=true;
    GroupBox2.Enabled:=true;
    GroupBox3.Enabled:=true;
    GroupBox10.Enabled:=true;
    //label3.Enabled :=true;
    //label4.Enabled :=true;
    //label5.Enabled :=true;
    //label6.Enabled :=true;
    //label7.Enabled :=true;
    //label8.Enabled :=true;
    //label12.Enabled :=true;
    //label54.Enabled :=true;
    //Edit2.Enabled :=true;
    //Edit3.Enabled :=true;
    //Edit4.Enabled :=true;
    //Edit5.Enabled :=true;
    //Edit6.Enabled :=true;
    //Edit7.Enabled :=true;
    //Edit11.Enabled :=true;
    //Edit20.Enabled :=true;
    //BitBtn2.enabled:=true;
    //BitBtn3.enabled:=true;
    //
    //BitBtn8.enabled:=true;
    //BitBtn34.enabled:=true;
    //Edit13.enabled:=true;
    //Edit14.enabled:=true;
    //Edit15.enabled:=true;
    //Edit16.enabled:=true;
    PageControl1.Pages[1].Enabled:=true;
    edit8.Text:=edit11.text;
    readini;
    end;
    end;
end;

//******************  Настройки   *****************************************************************
procedure TForm1.BitBtn6Click(Sender: TObject);
begin
  //Проверка файлов DBF в каталоге
  If FindAnyFIle(form1.Edit8.text,'*.DBF')=false then
    begin
    showmessage('Не обнаружено файлов DBF по данному пути!');
     exit;
    end;

  Form2:=TForm2.Create(self);
  form2.showmodal;
  FreeAndNil(form2);
end;

//*****************************    Загрузка справочников    ***************************************
procedure TForm1.BitBtn7Click(Sender: TObject);
begin
  //Сбрасываем флаг
  lExp:=false;
 //Очищаем memo
 form1.memo1.Clear;
 Form4:=TForm4.Create(self);
 form4.showmodal;
 FreeAndNil(form4);
 form1.memo1.clear;
 If lExp then
 form1.ExportALLDBF();
end;

procedure TForm1.BitBtn8Click(Sender: TObject);
begin
  Form1.dialog1.Execute;
  form1.edit11.Text:=Form1.dialog1.FileName;
end;


procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  form1.image3.Stretch:=form1.CheckBox2.Checked;
end;

//**************** Потеря фокуса ***************************************************************
procedure TForm1.Edit13Exit(Sender: TObject);
begin
  //Проверяем значение порта
  try
    StrToInt(Form1.Edit13.Text);
  except
    showmessage('Неправильное значение порта!');
    Form1.Edit13.Text := '';
  end;
  IF StrToInt(Form1.Edit13.Text)>64000 then
  begin
    showmessage('Неправильное значение порта!');
    Form1.Edit13.Text := '';
  end;
end;

//**************** Потеря фокуса ***************************************************************
procedure TForm1.Edit14Exit(Sender: TObject);
begin
  //Проверяем значение порта
  try
    StrToInt(Form1.Edit14.Text);
  except
    showmessage('Неправильное значение порта!');
    Form1.Edit14.Text := '';
  end;
  IF StrToInt(Form1.Edit14.Text)>64000 then
  begin
    showmessage('Неправильное значение порта!');
    Form1.Edit14.Text := '';
  end;
end;

//**************** Потеря фокуса ***************************************************************
procedure TForm1.Edit15Exit(Sender: TObject);
begin
  //Проверяем значение порта
  try
    StrToInt(Form1.Edit15.Text);
  except
    showmessage('Неправильное значение порта!');
    Form1.Edit15.Text := '';
  end;
  IF StrToInt(Form1.Edit15.Text)>64000 then
  begin
    showmessage('Неправильное значение порта!');
    Form1.Edit15.Text := '';
  end;
end;

//**************** Потеря фокуса ***************************************************************
procedure TForm1.Edit16Exit(Sender: TObject);
begin
   //Проверяем значение порта
  try
    StrToInt(Form1.Edit15.Text);
  except
    showmessage('Неправильное значение порта!');
    Form1.Edit15.Text := '';
  end;
  IF StrToInt(Form1.Edit15.Text)>64000 then
  begin
    showmessage('Неправильное значение порта!');
    Form1.Edit15.Text := '';
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //освободить память от массива
  SetLength(ar_access,0,0);
  ar_access := nil;
  SetLength(ar_deny,0,0);
  ar_deny := nil;
  SetLength(ar_srv,0,0);
  ar_srv := nil;
  SetLength(masuser,0,0);
  masuser := nil;
end;



//*************************    Проверка наличия файла настроек и определение элементов формы  *****************************
procedure TForm1.Sets(flag: Boolean);
var
 put: Ansistring;
begin
  if flag then
    begin
        put:= Form1.Edit1.Text;
    end
  else
   // put:= getcurrentdirutf8();
   put:=ExtractFilePath(Application.ExeName);
   showmessage(put);
  if FileExistsUTF8(put+'local.ini') then
    begin
      form1.edit1.text:=put;
      //чтение из файла
      ReadIni();
    with form1 do
      begin
      // Активируем эелементы
      form1.Shape1.Brush.Color:=clLime;
      BitBtn5.enabled:=false;
      BitBtn4.enabled:=true;
      GroupBox1.Enabled:=true;
      GroupBox2.Enabled:=true;
      GroupBox3.Enabled:=true;
      GroupBox10.Enabled:=true;
      //form1.label3.Enabled :=true;
      //form1.label4.Enabled :=true;
      //form1.label5.Enabled :=true;
      //form1.label6.Enabled :=true;
      //form1.label7.Enabled :=true;
      //form1.label8.Enabled :=true;
      //form1.label12.Enabled :=true;
      //form1.Edit2.Enabled :=true;
      //form1.Edit3.Enabled :=true;
      //form1.Edit4.Enabled :=true;
      //form1.Edit5.Enabled :=true;
      //form1.Edit6.Enabled :=true;
      //form1.Edit7.Enabled :=true;
      //form1.Edit11.Enabled :=true;
      //form1.BitBtn2.enabled:=true;
      //form1.BitBtn3.enabled:=true;
      //form1.BitBtn8.enabled:=true;
      form1.PageControl1.Pages[1].Enabled:=true;
      form1.PageControl1.Pages[2].Enabled:=true;
      form1.PageControl1.Pages[3].Enabled:=true;
      form1.PageControl1.Pages[4].Enabled:=true;
      form1.PageControl1.Pages[5].Enabled:=true;
      form1.PageControl1.Pages[6].Enabled:=true;
      edit8.Text:=edit11.text;

        //Edit13.enabled:=true;
        //Edit14.enabled:=true;
        //Edit15.enabled:=true;
        //Edit16.enabled:=true;
      end;
    end
  else
   begin
     form1.bitbtn5.Enabled:=true;
     showmessage('Не найден файл настроек по заданному пути!');
   end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
    fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(form1.edit10.text)+'x'+trim(form1.edit12.text)+' -r 30 -i '+trim(form1.edit9.text)+' -f image2 webcam.jpg');
    form1.image3.Picture.LoadFromFile('webcam.jpg');
    form1.Image3.Repaint;
end;


//********************************************************   HOT KEYS  *******************************************
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then halt;

   With form1 do
   begin
   //если вкладка ЛОКАЛЬНЫЕ НАСТРОЙКИ
   IF  PageControl1.ActivePageIndex=0 then
   begin
    // F1
    if Key=112 then showmessage('F1 - Справка'+#13+'F2 - Загрузить из файла'+#13+'F4 - Создать файл'+#13+'F5 - Записать в файл'+#13+
               'F9 - Указать путь к файлу настроек'+#13+'F10 - Указать путь к папке 1С'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');

    //F2 - Загрузить из файла
    if (Key=113) and (bitbtn21.enabled=true) then bitbtn21.click;
    //F4 - Создать файл
    if (Key=115) and (bitbtn5.enabled=true) then BitBtn5.Click;
    //F5 - Записать в файл
    if (Key=116) and (bitbtn4.enabled=true) then BitBtn4.Click;
    //F9 - Указать путь к файлу настроек
    if (Key=120) and (bitbtn1.enabled=true) then BitBtn1.Click;
    //F10 - Указать путь к папке 1С
    if (Key=121) and (bitbtn8.enabled=true) then BitBtn8.Click;
   end;

   //если вкладка пользователи
   IF  PageControl1.ActivePageIndex=1 then
   begin
    // F1
    if Key=112 then showmessage('F1 - Справка'+#13+'F2 - Обновить'+#13+'F3 - Доступ'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+
                    #13+'F6 - Печать'+#13+'F8 - Удалить'+#13+'F10 - Активация'+#13+'F11 - Деактивация'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Обновить
    if (Key=113) and (bitbtn16.enabled=true) then bitbtn16.click;
    //F3 - Доступ
    If (Key=114) and (BitBtn13.Enabled=true) then BitBtn13.click;
    //F4 - Изменить
    if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn10.enabled=true) then BitBtn10.Click;
    //F6 - Печать
    If (Key=117) AND (BitBtn15.Enabled=true) then BitBtn15.click;
    //F8 - Удалить
    if (Key=119) and (bitbtn11.enabled=true) then BitBtn11.Click;
    //F10 - Активация
    if (Key=121) and (bitbtn17.enabled=true) then BitBtn17.Click;
    //F11 - ДеАктивация
    if (Key=122) and (bitbtn22.enabled=true) then BitBtn22.Click;
     // ENTER
   // if Key=13 then
   end;

   end;
end;

//**********************************   Создание формы  ***************************************************************
procedure TForm1.FormCreate(Sender: TObject);
begin
  //установить формат даты и времени
  DateSeparator := '.';
  ShortDateFormat := 'dd.mm.yyyy';
  LongDateFormat  := 'dd.mm.yyyy';
  Form1.Sets(false);
  CentrForm(Form1);
 // ОПРЕДЕЛЯЕМ ПАРАМЕТРЫ ДОСТУПА *******************
 flag_access:=1; //всем просмотр
 //профиль по умолчанию реальный
 flagprofile := 1;
 with Form1 do
   begin
     PageControl1.ActivePage := TabSheet1;
 //по умолчанию блокируем все кнопки
      BitBtn6.Enabled:=false;
      BitBtn7.Enabled:=false;
      BitBtn10.Enabled:=false;
      BitBtn11.Enabled:=false;
      BitBtn12.Enabled:=false;
      BitBtn13.Enabled:=false;
      BitBtn17.Enabled:=false;
      gluser := '1';
      glarm  := '3';
   //GLuser:=trim(copy(trim(ParamStr(1)),1,ansipos('+',ParamStr(1))-1));
   //GLarm:=trim(copy(trim(ParamStr(1)),ansipos('+',ParamStr(1))+1,20));

 MConnect(Zconnection1,ConnectINI[3],ConnectINI[1]);
 try
   form1.Zconnection1.connect;
 except
   showmessage('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
   exit;
  // halt;
 end;
        ZQuery1.SQL.Clear;
        ZQuery1.SQL.Add('SELECT group_id FROM av_users WHERE del=0 AND id='+GLuser+';');
        try
         ZQuery1.open;
        except
          showmessage('Выполнение команды SQL SELECT - ОШИБКА !'+#13+'Команда: '+ZQuery1.SQL.Text);
          ZQuery1.Close;
          exit;
          //halt;
        end;
    if ZQuery1.RecordCount<1 then
       begin
         showmessage('Пользователь НЕ принадлежит ни одной группе в системе !');
         ZConnection1.Disconnect;
         ZQuery1.Close;
         exit;
       end;

   //если 1 - админ, нет - остальные
    IF ZQuery1.FieldByName('group_id').asInteger=1 then
    begin
      flag_access:=2;   //админам все разрешено
      BitBtn6.Enabled:=true;
      BitBtn7.Enabled:=true;
      BitBtn10.Enabled:=true;
      BitBtn11.Enabled:=true;
      BitBtn12.Enabled:=true;
      BitBtn13.Enabled:=true;
      BitBtn17.Enabled:=true;
    end;
   /////////////////////////////////////////////////////////////////////////
   end;

end;


end.


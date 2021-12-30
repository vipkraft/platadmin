unit ExtPersonal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons, LazUTF8, ComCtrls;

type

  { TFormSpr }

  TFormSpr = class(TForm)
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Edit1: TEdit;
    Image1: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;   aRect: TRect; aState: TGridDrawState);
    procedure UpdateGrid1(filter_type:byte; stroka:string);//обновить сотрудников
    procedure UpdateGrid2(filter_type:byte; stroka:string);//обновить контрагентов
    procedure UpdateGrid3(filter_type:byte; stroka:string); // ПЕРЕВОЗЧИКИ ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ
    procedure UpdateGrid4(filter_type:byte; stroka:string); // пользователи
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormSpr: TFormSpr;


implementation
uses
  platproc,main;


{$R *.lfm}

{ TFormSpr }

//******************************************************** ПОЛЬЗОВАТЕЛИ **********************************
procedure TFormSpr.UpdateGrid4(filter_type:byte; stroka:string);
 var
   n:integer;
begin
 with FormSpr do
  begin
  Stringgrid1.RowCount:=1;
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_users WHERE del=0 ');

 ////осуществлять контекстный поиск или нет
 //If filter_type=1 then
 //  begin
 //  ZQuery1.SQL.add(' AND (id='+stroka+') ');
 //  end;
 //If filter_type=2 then
 //  begin
 //  ZQuery1.SQL.add(' AND ((UPPER(substr(name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
 //  ZQuery1.SQL.add('OR (UPPER(substr(fullname,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  //ZQuery1.SQL.add('OR (UPPER(substr(dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  end;
 if (stroka<>'') and (filter_type=2) then
     begin
          ZQuery1.SQL.add('and (name ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or fullname ilike '+quotedstr(stroka+'%')+')');
     end;
   if (stroka<>'') and (filter_type=1) then ZQuery1.SQL.add('and cast(id as text) like '+quotedstr(stroka+'%'));

  ZQuery1.SQL.add(' ORDER BY id; ');
  //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;

  Label3.Caption := '-';
 StringGrid1.RowCount:=1;

   if FormSpr.ZQuery1.RecordCount=0 then
     begin
      FormSpr.ZQuery1.Close;
      FormSpr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
   StringGrid1.RowCount:=ZQuery1.RecordCount+1;

   stringgrid1.RowCount:= ZQuery1.recordcount+1;
   ProgressBar1.Max:=stringgrid1.RowCount;
   ProgressBar1.Position:=0;
   ProgressBar1.visible:=true;
      for n:=1 to ZQuery1.recordcount do
       begin
            ProgressBar1.Position:=ProgressBar1.Position+1;
            ProgressBar1.refresh;
            StringGrid1.cells[0,n]:=inttostr(n);
            StringGrid1.cells[1,n]:=ZQuery1.FieldByName('id').AsString;
            StringGrid1.cells[2,n]:=ZQuery1.FieldByName('fullname').AsString;
            StringGrid1.cells[3,n]:=ZQuery1.FieldByName('name').AsString;
            StringGrid1.cells[4,n]:=ZQuery1.FieldByName('dolg').AsString;
            StringGrid1.cells[5,n]:=ZQuery1.FieldByName('status').AsString;
            Zquery1.Next;
         end;
   ProgressBar1.visible:=false;
   FormSpr.ZQuery1.Close;
   FormSpr.Zconnection1.disconnect;
   FormSpr.StringGrid1.Row := FormSpr.StringGrid1.RowCount-1;
   Label3.Caption := inttostr(Stringgrid1.RowCount-1);
  // FormSpr.StringGrid1.SetFocus;

   end;
end;

//******************************************************** ПЕРЕВОЗЧИКИ ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
procedure TFormSpr.UpdateGrid3(filter_type:byte; stroka:string);
 var
   n:integer;
begin
 with FormSpr do
  begin
  Stringgrid1.RowCount:=1;
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_spr_kontragent WHERE del=0 ');

 ////осуществлять контекстный поиск или нет
 //If filter_type=1 then
 //  begin
 //  ZQuery1.SQL.add(' AND (id='+stroka+') ');
 //  end;
 //If filter_type=2 then
 //  begin
 //  ZQuery1.SQL.add(' AND ((UPPER(substr(name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
 //  ZQuery1.SQL.add('OR (UPPER(substr(polname,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  //ZQuery1.SQL.add('OR (UPPER(substr(dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  end;

 if (stroka<>'') and (filter_type=2) then
     begin
          ZQuery1.SQL.add('and (name ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or polname ilike '+quotedstr(stroka+'%')+')');
     end;
   if (stroka<>'') and (filter_type=1) then ZQuery1.SQL.add('and cast(id as text) like '+quotedstr(stroka+'%'));


  ZQuery1.SQL.add(' ORDER BY id; ');
  //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;

  Label3.Caption := '-';
 StringGrid1.RowCount:=1;

   if FormSpr.ZQuery1.RecordCount=0 then
     begin
      FormSpr.ZQuery1.Close;
      FormSpr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
   StringGrid1.RowCount:=ZQuery1.RecordCount+1;

   stringgrid1.RowCount:= ZQuery1.recordcount+1;
   ProgressBar1.Max:=stringgrid1.RowCount;
   ProgressBar1.Position:=0;
   ProgressBar1.visible:=true;
      for n:=1 to ZQuery1.recordcount do
       begin
            ProgressBar1.Position:=ProgressBar1.Position+1;
            ProgressBar1.refresh;
            StringGrid1.cells[0,n]:=inttostr(n);
            StringGrid1.cells[1,n]:=ZQuery1.FieldByName('id').AsString;
            StringGrid1.cells[2,n]:=ZQuery1.FieldByName('name').AsString;
            StringGrid1.cells[3,n]:=ZQuery1.FieldByName('polname').AsString;
            StringGrid1.cells[4,n]:=ZQuery1.FieldByName('vidkontr').AsString;
            StringGrid1.cells[5,n]:=ZQuery1.FieldByName('inn').AsString;
            StringGrid1.cells[6,n]:=ZQuery1.FieldByName('okpo').AsString;
            StringGrid1.cells[7,n]:=ZQuery1.FieldByName('adrur').AsString;
            StringGrid1.cells[8,n]:=ZQuery1.FieldByName('tel').AsString;
            Zquery1.Next;
         end;
   ProgressBar1.visible:=false;
   FormSpr.ZQuery1.Close;
   FormSpr.Zconnection1.disconnect;
   FormSpr.StringGrid1.Row := FormSpr.StringGrid1.RowCount-1;
   Label3.Caption := inttostr(Stringgrid1.RowCount-1);
  // FormSpr.StringGrid1.SetFocus;

   end;
end;

//******************************************************** КОНТРАГЕНТЫ ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
procedure TFormSpr.UpdateGrid2(filter_type:byte; stroka:string);
 var
   n:integer;
begin
 with FormSpr do
  begin
  Stringgrid1.RowCount:=1;
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


   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_1c_contr ');

 ////осуществлять контекстный поиск или нет
 //If filter_type=1 then
 //  begin
 //  ZQuery1.SQL.add('WHERE (kod1c='+stroka+') ');
 //  end;
 //If filter_type=2 then
 //  begin
 //  ZQuery1.SQL.add('WHERE ((UPPER(substr(name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
 //  ZQuery1.SQL.add('OR (UPPER(substr(polname,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  //ZQuery1.SQL.add('OR (UPPER(substr(dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
 //  end;

 if (stroka<>'') and (filter_type=2) then
     begin
          ZQuery1.SQL.add('WHERE (name ilike '+quotedstr(stroka+'%'));
          ZQuery1.SQL.add('or polname ilike '+quotedstr(stroka+'%')+')');
     end;
   if (stroka<>'') and (filter_type=1) then ZQuery1.SQL.add('WHERE kod like '+quotedstr('%'+stroka+'%'));

  ZQuery1.SQL.add('ORDER BY kod; ');
  //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;

  Label3.Caption := '-';
 StringGrid1.RowCount:=1;

   if FormSpr.ZQuery1.RecordCount=0 then
     begin
      FormSpr.ZQuery1.Close;
      FormSpr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
   StringGrid1.RowCount:=ZQuery1.RecordCount+1;

   stringgrid1.RowCount:= ZQuery1.recordcount+1;
   ProgressBar1.Max:=stringgrid1.RowCount;
   ProgressBar1.Position:=0;
   ProgressBar1.visible:=true;
      for n:=1 to ZQuery1.recordcount do
       begin
            ProgressBar1.Position:=ProgressBar1.Position+1;
            ProgressBar1.refresh;
            StringGrid1.cells[0,n]:=inttostr(n);
            StringGrid1.cells[1,n]:=ZQuery1.FieldByName('kod').AsString;
            StringGrid1.cells[2,n]:=ZQuery1.FieldByName('name').AsString;
            StringGrid1.cells[3,n]:=ZQuery1.FieldByName('polname').AsString;
            StringGrid1.cells[4,n]:=ZQuery1.FieldByName('vidkontr').AsString;
            StringGrid1.cells[5,n]:=ZQuery1.FieldByName('inn').AsString;
            StringGrid1.cells[6,n]:=ZQuery1.FieldByName('okpo').AsString;
            StringGrid1.cells[7,n]:=ZQuery1.FieldByName('adrur').AsString;
            StringGrid1.cells[8,n]:=ZQuery1.FieldByName('tel').AsString;
            StringGrid1.cells[9,n]:=ZQuery1.FieldByName('gorod').AsString;
            StringGrid1.cells[10,n]:=ZQuery1.FieldByName('podr').AsString;
            Zquery1.Next;
         end;
   ProgressBar1.visible:=false;
   FormSpr.ZQuery1.Close;
   FormSpr.Zconnection1.disconnect;
   FormSpr.StringGrid1.Row := FormSpr.StringGrid1.RowCount-1;
   Label3.Caption := inttostr(Stringgrid1.RowCount-1);
  // FormSpr.StringGrid1.SetFocus;

   end;
end;


//******************************************************** СОТРУДНИКИ ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
procedure TFormSpr.UpdateGrid1(filter_type:byte; stroka:string);
 var
   n:integer;
begin
 with FormSpr do
  begin
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


   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT distinct a.kod1c,a.name,a.datr,a.dolg,a.pol,a.kodotd,a.kodpodr,a.inn,a.tab ');
//   ,b.name as namepodr,c.name as nameotd
   ZQuery1.SQL.add('     FROM av_1c_sotr as a ');
//   ZQuery1.SQL.add('LEFT JOIN av_1c_otd_podr as b ON a.kodotd=b.kodotd AND a.kodpodr=b.kodpodr  ');
//   ZQuery1.SQL.add('LEFT JOIN av_1c_otd_podr as c ON a.kodotd=c.kodotd AND c.kodpodr=0 ');


 //осуществлять контекстный поиск или нет
 If filter_type=1 then
   begin
   ZQuery1.SQL.add('WHERE (a.kod1c='+stroka+') OR (a.kodpodr='+stroka+') OR (a.tab='+stroka+') ');
   end;
 If filter_type=2 then
   begin
   ZQuery1.SQL.add('WHERE (UPPER(substr(a.name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
   //ZQuery1.SQL.add('OR (UPPER(substr(u.fullname,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
   ZQuery1.SQL.add('OR (UPPER(substr(a.dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
   //ZQuery1.SQL.add('OR (UPPER(substr(c.name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
   //ZQuery1.SQL.add('OR (UPPER(substr(b.name,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+')) ');
   end;

  ZQuery1.SQL.add('ORDER BY a.kod1c; ');
  //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;
 Label3.Caption := '-';
 StringGrid1.RowCount:=1;

   if FormSpr.ZQuery1.RecordCount=0 then
     begin
      FormSpr.ZQuery1.Close;
      FormSpr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
   StringGrid1.RowCount:=ZQuery1.RecordCount+1;

   stringgrid1.RowCount:= ZQuery1.recordcount+1;
   ProgressBar1.Max:=stringgrid1.RowCount;
   ProgressBar1.Position:=0;
   ProgressBar1.visible:=true;
      for n:=1 to ZQuery1.recordcount do
       begin
            ProgressBar1.Position:=ProgressBar1.Position+1;
            ProgressBar1.refresh;
            StringGrid1.cells[0,n]:=inttostr(n);
            StringGrid1.cells[1,n]:=ZQuery1.FieldByName('kod1c').AsString;
            StringGrid1.cells[2,n]:=ZQuery1.FieldByName('name').AsString;
            StringGrid1.cells[3,n]:=ZQuery1.FieldByName('dolg').AsString;
            StringGrid1.cells[4,n]:=ZQuery1.FieldByName('kodpodr').AsString;
            //StringGrid1.cells[5,n]:=ZQuery1.FieldByName('namepodr').AsString;
            StringGrid1.cells[6,n]:=ZQuery1.FieldByName('kodotd').AsString;
            //StringGrid1.cells[7,n]:=ZQuery1.FieldByName('nameotd').AsString;
            StringGrid1.cells[8,n]:=ZQuery1.FieldByName('datr').AsString;
            StringGrid1.cells[9,n]:=ZQuery1.FieldByName('tab').AsString;
            StringGrid1.cells[10,n]:=ZQuery1.FieldByName('inn').AsString;
            StringGrid1.cells[11,n]:=ZQuery1.FieldByName('pol').AsString;
            zquery1.Next;
         end;
   ProgressBar1.visible:=false;
   FormSpr.ZQuery1.Close;
   FormSpr.Zconnection1.disconnect;
   FormSpr.StringGrid1.Row := FormSpr.StringGrid1.RowCount-1;
   Label3.Caption := inttostr(Stringgrid1.RowCount-1);
  // FormSpr.StringGrid1.Refresh;
  // FormSpr.StringGrid1.SetFocus;
   end;
end;



procedure TFormSpr.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //********************                    HOT KEYS  ******************************************
  With FormSpr do
begin
  //поле поиска
  If Edit1.Visible then
    begin
    // ESC поиск
   if (Key=27) then
     begin
       Edit1.Text:='';
       Edit1.Visible:=false;
       StringGrid1.SetFocus;
      exit;
     end;
  // Вверх по списку   // Вниз по списку
  if (Key=27) OR (Key=38) OR (Key=40) then
     begin
       Edit1.Visible:=false;
       StringGrid1.SetFocus;
       //key:=0;
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

    // Контекcтный поиск
   if Edit1.Visible=false then
     begin
       If ((get_type_char(key)>0) or (key=8) or (key=46) or (key=96)) and not((key=27) or (key=13) or (key=32)) then //8-backspace 46-delete 96- numpad 0
       begin
         Edit1.text:='';
         Edit1.Visible:=true;
         Edit1.SetFocus;
       end;
     end;

    // F1
     if Key=112 then showmessagealt('F1 - Справка'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
     //F5 - Обновить
    //if (Key=116) and (bitbtn1.enabled=true) then  BitBtn1.Click;
    //F7 - Поиск
    //if (Key=118) then FormSpr.ToolButton8.Click;
    // ESC
    if Key=27 then BitBtn3.Click;
    // пробел
    if (Key=32) then BitBtn2.Click;
end;
     if (Key=112) or (Key=116) or (Key=118) or (Key=27) or (Key=13) then Key:=0;
end;


//***************************************************** ВЫХОД ************************
procedure TFormSpr.BitBtn3Click(Sender: TObject);
begin
  resid:=0;
  formSpr.Close;
end;


//******************************** ВЫБРАТЬ  *****************************
procedure TFormSpr.BitBtn2Click(Sender: TObject);
begin
  // проверки *--------------
  with FormsPR.StringGrid1 do
  begin
  If (trim(Cells[1,Row])='') or (trim(Cells[2,Row])='') then
    begin
     showmessagealt('Сначала выберите запись !');
     exit;
    end;
  //---------------------------------------------------
  try
   resid  := strtoint(StringGrid1.Cells[1,StringGrid1.row]);
   resstr := StringGrid1.Cells[3,StringGrid1.row];//полное имя / должность сотрудника
  except
    showmessagealt('Ошибка ! Некорректное значение !');
    exit;
  end;
  end;

   FormSpr.close;
end;


procedure TFormSpr.Edit1Change(Sender: TObject);
var
  typ:byte=0;
  ss:string;
  n:integer=0;
begin
   with FOrmSpr do
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
         If form_mode=1 then
            if (typ=2) then  updategrid1(2,ss)
           else updategrid1(1,ss);
         If form_mode=2 then
            if (typ=2) then  updategrid2(2,ss)
           else updategrid2(1,ss);
         If form_mode=3 then
            if (typ=2) then  updategrid3(2,ss)
           else updategrid3(1,ss);
          If form_mode=4 then
            if (typ=2) then  updategrid4(2,ss)
           else updategrid4(1,ss);
       end
  else
     begin
       If form_mode=1 then  updategrid1(0,'');
       If form_mode=2 then  updategrid2(0,'');
       If form_mode=3 then  updategrid3(0,'');
       If form_mode=4 then  updategrid4(0,'');
      Edit1.Visible:=false;
     end;
end;
end;


//************************************************************
procedure TFormSpr.FormShow(Sender: TObject);
begin

   with FOrmSPr do
begin
   //form_mode =1 - справочник сотрудников 1c
   //form_mode =2 - справочник контрагентов 1c
   //form_mode =3 - справочник перевозчиков
   //form_mode =4 - справочник пользователей

   If form_mode=1 then
     begin
       Label2.Caption:='Справочник сотрудников 1С';
       Stringgrid1.ColCount:=12;
       StringGrid1.cells[0,0]:='№ п/п';
       StringGrid1.cells[1,0]:='код 1С';
       StringGrid1.cells[2,0]:='Ф.И.О.';
       StringGrid1.cells[3,0]:='Должность';
       StringGrid1.cells[4,0]:='подр.';
       StringGrid1.cells[5,0]:='Подразделение';
       StringGrid1.cells[6,0]:='отд.';
       StringGrid1.cells[7,0]:='Отделение';
       StringGrid1.cells[8,0]:='Дата рождения';
       StringGrid1.cells[9,0]:='Табельный';
       StringGrid1.cells[10,0]:='Инн';
       StringGrid1.cells[11,0]:='Пол';
       stringgrid1.ColWidths[2]:=250;
       stringgrid1.ColWidths[3]:=250;
       stringgrid1.ColWidths[5]:=200;
       stringgrid1.ColWidths[7]:=200;
       stringgrid1.ColWidths[8]:=90;
       stringgrid1.ColWidths[9]:=100;
       stringgrid1.ColWidths[10]:=110;
       UpdateGrid1(0,'');
     end;

   If form_mode=2 then
     begin
       Label2.Caption:='Справочник контрагентов 1С';
       Stringgrid1.ColCount:=11;
       StringGrid1.cells[0,0]:='№ п/п';
       StringGrid1.cells[1,0]:='код 1С';
       StringGrid1.cells[2,0]:='Наименование';
       StringGrid1.cells[3,0]:='Полное наименование';
       StringGrid1.cells[4,0]:='Вид';
       StringGrid1.cells[5,0]:='Инн';
       StringGrid1.cells[6,0]:='ОКПО';
       StringGrid1.cells[7,0]:='Адрес Юридический';
       StringGrid1.cells[8,0]:='Телефон';
       StringGrid1.cells[9,0]:='Город';
       StringGrid1.cells[10,0]:='Подразделение';
       stringgrid1.ColWidths[2]:=200;
       stringgrid1.ColWidths[3]:=200;
       UpdateGrid2(0,'');
     end;
   //Stringgrid1.AutoSizeColumns;

    If form_mode=3 then
     begin
       Label2.Caption:='Справочник Контрагентов / Перевозчиков';
       Stringgrid1.ColCount:=9;
       StringGrid1.cells[0,0]:='№ п/п';
       StringGrid1.cells[1,0]:='ID';
       StringGrid1.cells[2,0]:='Наименование';
       StringGrid1.cells[3,0]:='Полное наименование';
       StringGrid1.cells[4,0]:='Вид';
       StringGrid1.cells[5,0]:='ИНН';
       StringGrid1.cells[6,0]:='OКПО';
       StringGrid1.cells[7,0]:='Адрес Юридический';
       StringGrid1.cells[8,0]:='Телефон';
       stringgrid1.ColWidths[2]:=200;
       stringgrid1.ColWidths[3]:=200;
       UpdateGrid3(0,'');
     end;

      If form_mode=4 then
     begin
       Label2.Caption:='Справочник Пользователей ПЛАТФОРМА';
       Stringgrid1.ColCount:=6;
       StringGrid1.cells[0,0]:='№ п/п';
       StringGrid1.cells[1,0]:='ID';
       StringGrid1.cells[2,0]:='Полное наименование';
       StringGrid1.cells[3,0]:='Наименование';
       StringGrid1.cells[4,0]:='Должность';
       StringGrid1.cells[5,0]:='Статус';
       stringgrid1.ColWidths[2]:=300;
       stringgrid1.ColWidths[3]:=200;
       stringgrid1.ColWidths[4]:=200;
       UpdateGrid4(0,'');
     end;
   end;
end;


procedure TFormSpr.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
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
            font.Size:=10;
            font.Style:= [];
           end
         else
          begin
            font.Style:= [];
            Font.Color := clBlack;
            font.Size:=9;
          end;

   If aRow>0 then   DrawCellsAlign(FormSpr.StringGrid1,1,2,FormSpr.StringGrid1.Cells[aCol,aRow],aRect);
     // Заголовок
       if aRow=0 then
         begin
           RowHeights[aRow]:=30;
           Brush.Color:=clCream;
           FillRect(aRect);
           Font.Color := clBlack;
           font.Size:=9;
           font.Style:=[fsBold];
           DrawCellsAlign(FormSpr.StringGrid1,1,2,FormSpr.StringGrid1.Cells[aCol,aRow],aRect);
           //Рисуем значки сортировки и активного столбца
            DrawCell_header(aCol,Canvas,aRect.left,(Sender as TStringgrid));
          end;
  end;
end;

end.


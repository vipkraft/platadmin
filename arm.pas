unit ARM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Grids, Buttons, Spin, StrUtils,
//  LazUTF8,
  ComCtrls, TypInfo, LazUTF8;

type

  { TForm5 }

  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn9: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel3: TPanel;
    ProgressBar1: TProgressBar;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn19Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure ComboBox4Change(Sender: TObject);
    procedure ComboBox5Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure RefreshMenu(armid:String; userid:string); //вывод списка разрешений меню пользователя для данного АРМ-а
    procedure RefreshOPT(armid:String; userid:string); //вывод списка текущих значений опций пользователя для данного АРМ-а
    procedure StringGrid1BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1SetCheckboxState(Sender: TObject; ACol, ARow: Integer;      const Value: TCheckboxState);
    procedure StringGrid3DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid3SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure RefreshArms(iduser: string); //Заполняем Список АРМ-ов под юзера  **********************************
    procedure StringGrid4DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid4MouseDown(Sender: TObject; Button: TMouseButton;      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid4SelectCell(Sender: TObject; aCol, aRow: Integer;      var CanSelect: Boolean);
    procedure StringGrid4SetCheckboxState(Sender: TObject; ACol, ARow: Integer;      const Value: TCheckboxState);
    procedure UpdateCombo();//  обновить комбо значений опций **********************
    procedure UpdateGrups(); //обновить комбо с группами
    procedure UpdateServers(); //обновить комбо с серверами
    procedure UpdatePodr(); //обновить комбо с подразделениями
    procedure UpdateGrid4(); //обновить грид с пользователями
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form5: TForm5; 
  idarm, namearm,id_opt :string;
  id_user_global, id_user_name : string;


implementation
 uses spr_arms,spr_option,main,platproc,spr_menu,users_main;//,mainadmin;
{$R *.lfm}

{ TForm5 }
var
  lEditO :Boolean=false;
  lEditM :Boolean=false;
  chArm: boolean=false;
  n,m,Ch3 :integer;
  flag:boolean=false;//флаг ВЕРНУТЬ/ПРИМЕНИТЬ
  id_user:string;
  opttype:integer;//тип опции с текстовым параметром (1) или числовым (0)

  //***************************************** обновить грид 4 с ПОЛЬЗОВАТЕЛЯМИ      *************************************
procedure TForm5.UpdateGrid4();
var
  grp,srv,podr: string;
begin

   with Form5 do
  begin
    If flag then
      begin
       StringGrid4.RowCount:=0;
      end
      else
      begin
        StringGrid4.RowCount:=1;
        StringGrid4.ColWidths[2]:=40;
       Stringgrid4.Cells[0,0]:='  ID';
       Stringgrid4.Cells[1,0]:='   Пользователь             Отметить ВСЕ -->';
       Stringgrid4.Cells[2,0]:='0';
      end;

    grp:= UTF8copy(ComboBox3.Text,1,UTF8pos('-',ComboBox3.Text)-1);
    srv := copy(ComboBox4.Text,pos('[',ComboBox4.Text)+1,pos(']',ComboBox4.Text)-pos('[',ComboBox4.Text)-1);
    podr := Utf8copy(ComboBox5.Text,UTF8pos('--',ComboBox5.Text)+3,Utf8Length(ComboBox5.text));

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('Select Distinct a.id,a.name FROM av_users a ');
   ZQuery1.SQL.add('JOIN av_users_group b ON b.del=0 AND b.user_id=a.id AND group_id='+grp );
  IF (trim(srv)<>'') or (trim(srv)='0') then
     ZQuery1.SQL.add('JOIN av_users_servers c ON c.del=0 AND c.user_id=a.id AND server_id='+srv );
  IF (trim(podr)<>'') or (trim(podr)='0') then
    ZQuery1.SQL.add('JOIN av_users_podr e ON e.del=0 AND e.user_id=a.id AND podr_id='+podr );
   ZQuery1.SQL.add('WHERE a.del=0 ');
   ZQuery1.SQL.add('ORDER BY name;');
    //showmessage(ZQuery1.SQL.text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;

  if ZQuery1.RecordCount=0 then
     begin
       Stringgrid4.Enabled:=false;
      ZQuery1.Close;
      Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid
  Stringgrid4.Enabled:=true;

   for n:=1 to ZQuery1.RecordCount do
    begin
      StringGrid4.RowCount := StringGrid4.RowCount +1;
      StringGrid4.Cells[0,StringGrid4.RowCount -1]:=ZQuery1.FieldByName('id').asString;
      StringGrid4.Cells[1,StringGrid4.RowCount -1]:=ZQuery1.FieldByName('name').asString;
      StringGrid4.Cells[2,StringGrid4.RowCount -1]:='0';
      ZQuery1.Next;
    end;
   ZQuery1.Close;
   Zconnection1.disconnect;
   Stringgrid4.SetFocus;
   Stringgrid4.Row:= Stringgrid4.RowCount-1;
end;
end;


//*************************************** //обновить КОМБО С ПОДРАЗДЕЛЕНИЯМИ ********************************************
procedure TForm5.UpdatePodr();
var
  n : integer;
begin
  With Form5 do
  begin
    ComboBox5.Clear;

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
  ZQuery1.SQL.add('SELECT * FROM av_1c_otd_podr WHERE kodpodr!=0 AND kodotd>1200 ORDER by kodotd,kodpodr;');
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
      combobox5.Items.Add(ZQuery1.FieldByName('name').asString+' -- ' + ZQuery1.FieldByName('kodpodr').asString);
      ZQuery1.Next;
     end;
   combobox5.ItemIndex:=-1;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;


//*************************************** //обновить КОМБО С СЕРВЕРАМИ ********************************************
procedure TForm5.UpdateServers();
  var
  n : integer;
begin

  With Form5 do
  begin
    ComboBox4.Clear;

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
      combobox4.Items.Add(ZQuery1.FieldByName('pname').asString+'[' + ZQuery1.FieldByName('id').asString+']');
      ZQuery1.Next;
     end;
   combobox4.ItemIndex:=-1;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;


//*************************************** //обновить КОМБО С ГРУППАМИ ********************************************
procedure TForm5.UpdateGrups();
  var
  n : integer;
begin

  With Form5 do
  begin
    ComboBox3.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT id,grupa FROM av_group WHERE del=0 ORDER BY id ASC;');
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
      combobox3.Items.Add(ZQuery1.FieldByName('id').asString+' - ' + ZQuery1.FieldByName('grupa').asString);
      ZQuery1.Next;
     end;
   combobox3.ItemIndex:=0;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;


//***********************  обновить комбо значений опций **********************
procedure TForm5.UpdateCombo;
var
  n,i: integer;
  stemp:string='';
  stt:string='';
  num:integer=0;
begin

  With Form5 do
  begin

   num:=0;
   If trim(Stringgrid2.Cells[3,Stringgrid2.row])<>'' then begin
   try
     num:=strtoint(Stringgrid2.Cells[3,Stringgrid2.row])
   except
     on exception: EConvertError do exit;
   end;
    end;


    ComboBox2.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

 //запрос
 ZQuery1.SQL.clear;
 ZQuery1.SQL.add('SELECT optvalue FROM av_arm_options WHERE del=0 AND id='+Stringgrid2.Cells[1,Stringgrid2.Row]+';');
 //showmessage(ZQuery1.SQL.text);//$
 try
 ZQuery1.Open;
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



 // Заполняем combo
 stemp:= trim(ZQuery1.FieldByName('optvalue').asString);
 opttype:=0;
 for i:=1 to utf8length(stemp) do
   begin
     If not((UTF8copy(stemp,i,1)[1]) in ['0'..'9']) then
       If not((UTF8copy(stemp,i,1)[1]) in ['\','/','.',',',';']) then
         begin
         opttype:=1;
         break;
         end;
   end;
 //showmessage(
 If UTF8copy(stemp,utf8length(stemp),1)<>',' then stemp:=stemp+',';
 n:=0;
 while utf8pos(',',stemp)>0 do
   begin
     stt:= Utf8copy(stemp,1,utf8pos(',',stemp)-1);
     n:=n+1;
     ComboBox2.Items.Add(inttostr(n)+' - ' + stt);
     stemp:=Utf8copy(stemp,utf8pos(',',stemp)+1,utf8length(stemp));
     If opttype=1 then
        If num=n then
          begin
          ComboBox2.ItemIndex:=n-1;
          end;
     If opttype=0 then
      begin
      try
     If num=strtoint(stt) then
       begin
         ComboBox2.ItemIndex:=n-1;
       end;
     except
         on exception: EConvertError do
      ComboBox2.ItemIndex:=n-1;
        end;
     end;
   end;

  If ComboBox2.Items.Count=0 then ComboBox2.Items.Add(stemp);


    ZQuery1.Close;
    Zconnection1.disconnect;
  end;
end;

//*********************       Заполняем Список АРМ-ов под юзера  **********************************
procedure TForm5.RefreshArms(iduser: string);
begin
  With Form5 do
begin
  //Отобразить текущего пользователя
  form5.Label5.caption := id_user_global + ' - '+ id_user_name;
  StringGrid1.rowcount :=0;
    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT a.id_arm,a.id_user,b.armname FROM av_users_arm a, av_arm b WHERE a.del=0 AND b.del=0 AND a.id_arm=b.id AND a.id_user='+iduser+' ORDER BY a.id_arm ASC;');
  //showmessage(ZQuery1.SQL.text);
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
    form5.ZQuery1.Close;
    form5.Zconnection1.disconnect;
    exit;
   end;

   for n:=1 to ZQuery1.RecordCount do
     begin
       StringGrid1.rowcount:=StringGrid1.rowcount+1;
       StringGrid1.cells[0,StringGrid1.rowcount-1]:= ZQuery1.FieldByName('id_arm').asString;
       StringGrid1.cells[1,StringGrid1.rowcount-1]:= ZQuery1.FieldByName('armname').asString;
       StringGrid1.cells[2,StringGrid1.rowcount-1]:= '1';
       ZQuery1.next;
     end;

  //Form5.StringGrid1.ColWidths[0]:=30;
  //Form5.StringGrid1.ColWidths[1]:=395;
   form5.ZQuery1.Close;
   form5.Zconnection1.disconnect;
   //Загружаем локальные настройки для данного рабочего места
 RefreshOPT(form5.StringGrid1.cells[0,form5.StringGrid1.Row], iduser);
 //Загрузить разерешения меню пользователя для нового АРМа
 RefreshMenu(form5.StringGrid1.cells[0,form5.StringGrid1.Row], iduser);

  //If flag then
    //Stringgrid1.ColWidths[2]:=0
    //else Stringgrid1.ColWidths[2]:=30;
   form5.StringGrid1.SetFocus;
   form5.StringGrid1.Row:=0;
   end;
end;


procedure TForm5.StringGrid4DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
begin
  with Sender as TStringGrid, Canvas do
  begin
    Brush.color := clWhite;
    FillRect(aRect);
       if (gdSelected in aState) then
           begin
            pen.Width:=3;
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
      //If aCol<2 then
        //begin

      if (aRow>0) then
         begin
          //Font.Size:=1;
//        Font.Color := clBlack;
          TextOut(aRect.Left + 10, aRect.Top+5, Cells[aCol, aRow]);
         end;

      // Заголовок
       if (aRow=0)  then
         begin
           //RowHeights[aRow]:=30;
           Brush.Color:=clCream;
           FillRect(aRect);
           font.Size:=9;
           font.Style:=[fsBold];
           TextOut(aRect.Left + 5, aRect.Top+10, Cells[aCol, aRow]);
           //Рисуем значки сортировки и активного столбца
            DrawCell_header(aCol,Canvas,aRect.left,(Sender as TStringgrid));
         end;
        //end;
     end;
end;

procedure TForm5.StringGrid4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Click_Header((Sender as TStringgrid),X,Y,Self.ProgressBar1);
end;

//************************ запрет выбора ячейки ***********************************
procedure TForm5.StringGrid4SelectCell(Sender: TObject; aCol, aRow: Integer;  var CanSelect: Boolean);
begin
  If not flag then
  //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  If (aCol<2) then CanSelect:= false;
end;


//установка чеков на пользователях
procedure TForm5.StringGrid4SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
var
  n:integer=0;
begin
  If flag then exit;
  with (Sender as TStringGrid) do
begin
  //if Stringgrid5.cells[2,aRow]='1' then form5.StringGrid4.cells[2,m5.StringGrid4.row]:='0' else form5.StringGrid4.cells[2,form5.StringGrid4.row]:='1';
  If RowCount<2 then exit;

  if cells[2,aRow]='1' then cells[2,arow]:='0' else cells[2,arow]:='1';
  //отметить все
  If aRow=0 then
    begin
      for n:=1 to RowCount-1 do
        begin
          if cells[2,aRow]='1' then cells[2,n]:='1' else cells[2,n]:='0';
        end;
    end;
  end;
end;



//***********************   вывод списка разрешений меню пользователя для данного АРМ-а ***********************
 procedure TForm5.RefreshMenu(armid:String; userid:string);
begin
  with form5 do
  begin
   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
    // Выбираем нужную запись
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT * FROM av_arm_menu WHERE id_arm='+armid+' AND del=0 ORDER BY id_public,id_local;');
     try
     ZQuery1.Open;
    except
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
     exit;
    end;
     //Защита от дурака
    if ZQuery1.RecordCount>0 then
     begin

    //Заполнение Stringgrid3 значениями по умолчанию
   stringgrid3.RowCount:=ZQuery1.RecordCount+1;
   for n:=1 to ZQuery1.RecordCount do
      begin
       //Если это главное меню
           IF ZQuery1.FieldByName('id_local').AsInteger=0 then
            begin
            StringGrid3.cells[0,n]:='*';
            StringGrid3.cells[1,n]:=ZQuery1.FieldByName('id_public').AsString;
            StringGrid3.cells[2,n]:=ZQuery1.FieldByName('pub_name').AsString;
            StringGrid3.cells[3,n]:='Запрещено';
            StringGrid3.cells[4,n]:='0';
            end
           else
       //Если это подменю
              begin
               StringGrid3.cells[0,n]:=ZQuery1.FieldByName('id_public').AsString;
               StringGrid3.cells[1,n]:=ZQuery1.FieldByName('id_local').AsString;
               StringGrid3.cells[2,n]:=ZQuery1.FieldByName('loc_name').AsString;
               StringGrid3.cells[3,n]:='Запрещено';
               StringGrid3.cells[4,n]:='0';
              end;
           Zquery1.Next;
      end;

    // Выбираем нужную запись конкретной настройки пользователя
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT * FROM av_users_menu_perm WHERE del=0 AND id_arm='+armid+' AND id='+userid+'ORDER BY id_menu_pub,id_menu_loc;');
     try
     ZQuery1.Open;
    except
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     Zquery1.Close;
     Zconnection1.disconnect;
     exit;
    end;
   //Заполнение Stringgrid3 значениями для пользователя
   if ZQuery1.RecordCount<1 then exit;
    for m:=1 to ZQuery1.RecordCount do
       begin
        for n:=1 to StringGrid3.rowcount-1 do
          begin
               //Если это главное меню в обоих таблицах и оно совподает расставляем разрешение
                   if (trim(StringGrid3.cells[0,n])='*') AND
                      (strToInt(StringGrid3.Cells[1,n])=ZQuery1.FieldByName('id_menu_pub').AsInteger) AND
                      (ZQuery1.FieldByName('id_menu_loc').AsInteger=0) then
                    begin
                     StringGrid3.cells[4,n]:=ZQuery1.FieldByName('permition').asString;
                     case ZQuery1.FieldByName('permition').AsInteger of
                     0: StringGrid3.cells[3,n]:='Запрещено';
                     1: StringGrid3.cells[3,n]:='Просмотр';
                     2: StringGrid3.cells[3,n]:='Разрешено';
                     else
                       StringGrid3.cells[3,n]:='Запрещено';
                     end;
                    end;
               //Если это подменю в обоих таблицах и оно совпадает проставляем разерешение
                  if (trim(StringGrid3.cells[0,n])<>'*') AND
                      (strToInt(StringGrid3.Cells[1,n])=ZQuery1.FieldByName('id_menu_loc').AsInteger) AND
                     (ZQuery1.FieldByName('id_menu_loc').AsInteger<>0) then
                    begin
                     StringGrid3.cells[4,n]:=ZQuery1.FieldByName('permition').asString;
                     case ZQuery1.FieldByName('permition').AsInteger of
                     0: StringGrid3.cells[3,n]:='Запрещено';
                     1: StringGrid3.cells[3,n]:='Просмотр';
                     2: StringGrid3.cells[3,n]:='Разрешено';
                     else
                       StringGrid3.cells[3,n]:='Запрещено';
                     end;
                    end;
          end;
         zquery1.Next;
      end;
     end
    else
      stringgrid3.RowCount:=1;

   ZQuery1.close;
   Zconnection1.disconnect;
  end;
end;



//*********       вывод списка текущих значений опций пользователя для данного АРМ-а  *********************************
procedure Tform5.RefreshOPT(armid:string; userid:string);
var
  stm:string='';
begin
  form5.stringgrid2.RowCount:=1;

   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
    // Выбираем нужную запись
    //если у пользователя значение опции не определено, то ставится значение по умолчанию (первое значение)
      form5.ZQuery1.SQL.Clear;
      form5.ZQuery1.sql.add('select * from get_options('+quotedstr('opt')+','+userid+','+armid+');');
      form5.ZQuery1.sql.add('FETCH ALL IN opt;');
      //form5.ZQuery1.SQL.add('SELECT b.id,b.optvalue,b.optname,coalesce(a.opt_value,''1'') as opt_value FROM av_arm_options as b ');
      //form5.ZQuery1.SQL.add(' LEFT JOIN av_users_arm_options as a ON a.del=0 AND b.id_arm=a.id_arm AND a.option_id=b.id AND a.id='+userid );
      //form5.ZQuery1.SQL.add(' WHERE b.del=0 AND b.id_arm='+armid+' ORDER BY b.id;');
     //showmessage(form5.ZQuery1.SQL.text);//$
    try
     form5.ZQuery1.Open;
    except
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+form5.ZQuery1.SQL.Text);
     form5.ZQuery1.Close;
     form5.Zconnection1.disconnect;
     exit;
    end;
     //Защита от дурака
    if  form5.ZQuery1.RecordCount>0 then
    begin
    //Заполнение Грид опций АРМов для выбранного пользователя
   for n:=1 to form5.ZQuery1.RecordCount do
      begin
        form5.stringgrid2.RowCount:=form5.stringgrid2.RowCount+1;
           form5.StringGrid2.cells[0,form5.stringgrid2.RowCount-1]:='0';//тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового,4 -редактирование
           form5.StringGrid2.cells[1,form5.stringgrid2.RowCount-1]:=form5.ZQuery1.FieldByName('id').asString;
           form5.StringGrid2.cells[2,form5.stringgrid2.RowCount-1]:=form5.ZQuery1.FieldByName('optname').asString;
           form5.StringGrid2.cells[3,form5.stringgrid2.RowCount-1]:=form5.ZQuery1.FieldByName('opt_value').asString;
           form5.zquery1.Next;
      end;
   end;

      // Выбираем нужную запись конкретной настройки пользователя
   // try
   //  form5.ZQuery1.SQL.Clear;
   //  form5.ZQuery1.SQL.add('SELECT * FROM av_users_arm_options WHERE del=0 AND id_arm='+armid+' AND id='+id_user_global+';');
   //  form5.ZQuery1.Open;
   // except
   //  showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+form5.ZQuery1.SQL.Text);
   //  form5.Zconnection1.disconnect;
   //  exit;
   // end;
   ////Заполнение Stringgrid2 значениями для пользователя
   //if form5.ZQuery1.RecordCount<1 then exit;
   //for n:=1 to form5.ZQuery1.RecordCount do
   //   begin
   //        for m:=1 to form5.StringGrid2.rowcount-1 do
   //           begin
   //                if trim(form5.StringGrid2.cells[1,m])=inttostr(form5.ZQuery1.FieldByName('id_opt').asInteger) then
   //                 begin
   //                  form5.StringGrid2.cells[3,m]:=form5.ZQuery1.FieldByName('optvalue').asString;
   //                 end;
   //           end;
   //        form5.zquery1.Next;
   //   end;

   form5.ZQuery1.close;
   form5.Zconnection1.disconnect;
end;


//*******************        Переход по строчкам СПИСКА АРМОВ   ******    *********************************** ***********************
procedure TForm5.StringGrid1BeforeSelection(Sender: TObject; aCol, aRow: Integer  );
begin
    If (form5.Stringgrid1.RowCount<2) or (trim(form5.Stringgrid1.Cells[0,form5.Stringgrid1.Row])='') then exit;
    If form5.Stringgrid1.Cells[2,aRow]='0' then exit;
    //Были изменения в опциях
  if lEditO AND not flag then
    begin
     If MessageDlg('Сохранить изменения в опциях для данного АРМ-а ?',mtConfirmation, mbYesNo, 0)=6 then
    //ДА
     begin
     form5.BitBtn5.Click;
     exit;
     end
    else
       lEditO:=false;
    end;

  //Были изменения в меню
  if lEditM AND not flag then
    begin
    If MessageDlg('Сохранить изменения в разрешениях меню пользователя для данного АРМ-а ?',mtConfirmation, mbYesNo, 0)=6 then
     begin
     //ДА
       form5.BitBtn5.Click;
       exit;
     end
    else
     begin
       //SetGridFocus(form5.StringGrid1,CH3,1);
        lEditM:=false;
       //exit;
     end;
    end;

   //Были изменения в АРм-ах
  //if chArm then
  //  begin
  //   If MessageDlg('Сохранить изменения списке АРМ-ов ?',mtConfirmation, mbYesNo, 0)=6 then
  //  //ДА
  //   begin
  //   form5.BitBtn5.Click;
  //   exit;
  //   end
  //  else
  //  begin
  //   chArm := false;
  //   DelStringGrid(Stringgrid1,aRow);
  //  end;
  //  end;
end;

procedure TForm5.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
begin
   //showmessagealt('3=== '+form5.StringGrid1.cells[0,form5.StringGrid1.Row]);
  RefreshOPT(form5.StringGrid1.cells[0,form5.StringGrid1.Row], id_user);
  RefreshMenu(form5.StringGrid1.cells[0,form5.StringGrid1.Row], id_user);
end;

//************************** установка чеков на армах **********************************************
procedure TForm5.StringGrid1SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
begin
 if form5.StringGrid1.cells[2,form5.StringGrid1.row]='1' then form5.StringGrid1.cells[2,form5.StringGrid1.row]:='0' else form5.StringGrid1.cells[2,form5.StringGrid1.row]:='1';
end;


//******************   Раскрашиваем грид3 ************************************************
procedure TForm5.StringGrid3DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
 var
    clFore,clBack: TColor;
begin
 with (Sender as TStringGrid) do
 begin
   clBack:=clSkyBlue;
   clFore:=clBackground;
  //Если ячейка выбрана, закрашиваем другим цветом
  if (gdSelected in aState) then
  begin
    Canvas.Brush.Color := clHighLight;
    Canvas.Font.Color := clYellow;
  end
  else //Если пользователь удален, закрашиваем строку
    if trim(Cells[0,aRow]) = '*' then
      Canvas.Brush.color := clBack
    else
      canvas.brush.Color := clFore;
 //Закрашиваем грид
  if (ARow > 0) then
  begin
    //Закрашиваем бэкграунд
    Canvas.FillRect(aRect);
    //Закрашиваем текст (Text). Также здесь можно добавить выравнивание и т.д..
    Canvas.TextOut(aRect.Left+3, aRect.Top, Cells[ACol, ARow]);
  end;
 end;

end;


// ************* Отображаем комбо при наведении на ячейку грида3  *********************************
procedure TForm5.StringGrid3SelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
var
  R: TRect;
begin
with form5 do
begin
  if ((aCol = 3) AND (aRow > 0)) then
  begin
   //Размер и расположение combobox подгоняем под ячейку
    R := StringGrid3.CellRect(aCol, aRow);
    R.Left := R.Left + StringGrid3.Left;
    R.Right := R.Right + StringGrid3.Left;
    R.Top := R.Top + StringGrid3.Top;
    R.Bottom := R.Bottom + StringGrid3.Top;
    ComboBox1.Left := R.Left + 1;
    ComboBox1.Top := R.Top + 1;
    ComboBox1.Width := (R.Right + 1) - R.Left;
    ComboBox1.Height := (R.Bottom + 1) - R.Top;

    ComboBox1.ItemIndex:= StrToInt(StringGrid3.Cells[4,aRow]);
    ComboBox1.Visible := True;
    ComboBox1.SetFocus;
  end;
  CanSelect := True;
end;
end;

// ************************      Изменение КОМБО ********************************************
procedure TForm5.ComboBox1Change(Sender: TObject);
begin
 with form5.StringGrid3 do
 begin
   //Групповая расстановка ЗАПРЕЩЕНО на все подменю данного меню
   // Если это главное меню
   If trim(Cells[0,row])='*' then
   begin
        // И  ЗАПРЕЩЕНО
        If form5.ComboBox1.ItemIndex=0 then
        begin
           for n:=1 to RowCount-1 do
              begin
                //Если это подменю главного меню, меняем тоже на ЗАПРЕЩЕНО
                If trim(Cells[0,n])=trim(Cells[1,row]) then
                begin
                   Cells[3,n] := form5.ComboBox1.Items[0];
                   Cells[4,n] := '0';
                end;
              end;
         end;

         Cells[3,Row] := form5.ComboBox1.Items[form5.ComboBox1.ItemIndex];
         Cells[4,Row] := inttoSTR(form5.ComboBox1.ItemIndex);
         form5.ComboBox1.Visible := False;
         SetGridFocus(form5.StringGrid3,form5.StringGrid3.Row,2);
         //Флаг изменения
         lEditM:=true;
   end;

   //Групповая расстановка ПРОСМОТР на все подменю данного меню
   // Если это главное меню
   If trim(Cells[0,row])='*' then
   begin
        // И  ПРОСМОТР
        If form5.ComboBox1.ItemIndex=1 then
        begin
           for n:=1 to RowCount-1 do
              begin
                //Если это подменю главного меню, меняем тоже на ПРОСМОТР
                If trim(Cells[0,n])=trim(Cells[1,row]) then
                begin
                   Cells[3,n] := form5.ComboBox1.Items[1];
                   Cells[4,n] := '1';
                end;
              end;
         end;

         Cells[3,Row] := form5.ComboBox1.Items[form5.ComboBox1.ItemIndex];
         Cells[4,Row] := inttoSTR(form5.ComboBox1.ItemIndex);
         form5.ComboBox1.Visible := False;
         SetGridFocus(form5.StringGrid3,form5.StringGrid3.Row,2);
         //Запомнить строчку грид1 АРМ
         CH3:=form5.StringGrid1.Row;
         //Флаг изменения
         lEditM:=true;
   end;

   //Контроль. Если на меню стоит ЗАПРЕЩЕНО, то на подменю нельзя ставить 1 или 2
   // Если НЕ это главное меню
   If trim(Cells[0,row])<>'*' then
   begin
        // И NOT ЗАПРЕЩЕНО
        If form5.ComboBox1.ItemIndex>0 then
        begin
           for n:=1 to RowCount-1 do
              begin
                //Если это подменю главного меню, которое ЗАПРЕЩЕНО, меняем тоже на ЗАПРЕЩЕНО
                If (strToInt(Cells[1,n])=strToInt(Cells[0,row])) and (trim(Cells[0,n])='*') AND (strToInt(Cells[4,n])=0) then
                begin
                   showmessagealt('Сначала измените разрешение главного меню!');
                   Cells[3,Row] := form5.ComboBox1.Items[0];
                   Cells[4,Row] := '0';
                   exit;
                end;
              end;
         end;
        Cells[3,Row] := form5.ComboBox1.Items[form5.ComboBox1.ItemIndex];
        Cells[4,Row] := inttoSTR(form5.ComboBox1.ItemIndex);
        form5.ComboBox1.Visible := False;
        SetGridFocus(form5.StringGrid3,form5.StringGrid3.Row,2);
        //Запомнить строчку грид1 АРМ
        CH3:=StringGrid1.Row;
        //Флаг изменения
        lEditM:=true;
   end;
  end;
  end;

procedure TForm5.ComboBox3Change(Sender: TObject);
begin
  UpdateGrid4(); //обновить грид с пользователями
end;

procedure TForm5.ComboBox4Change(Sender: TObject);
begin
  UpdateGrid4(); //обновить грид с пользователями
end;

procedure TForm5.ComboBox5Change(Sender: TObject);
begin
  UpdateGrid4(); //обновить грид с пользователями
end;

//************************ ЗАКРЫТИЕ *******************************************
procedure TForm5.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   if chArm OR lEditO or lEditM then
    begin
    If MessageDlg('Сохранить внесенные изменения для данного пользователя в АРМ ?',mtConfirmation, mbYesNo, 0)=6 then
       begin
         CloseAction := caNone;
         Form5.BitBtn5.Click;
       end;
    end;
end;


//*********************************************************************   HOT KEYS  ********************************************
procedure TForm5.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
   With form5 do
   begin
   // ======================    Если на панели выбора значения опции   ===================
   if (Panel3.Visible=true) then
      begin
        // ESC
        if (Key=27) then
           begin
            Panel3.Visible:=false;
            StringGrid2.SetFocus;
            key:=0;
           end;
        // ENTER - сменить опцию
       IF (Key=13) then
          begin
            form5.BitBtn11.click;
            key:=0;
          end;
       exit;
      end;
   If Stringgrid4.Focused then
     begin
       //ENTER или ПРОБЕЛ - выбрать пользователя
       If (key=32) or (key=13) then
         begin
           key:=0;
           If not flag OR (trim(Stringgrid4.Cells[0,Stringgrid4.Row])='') or (Stringgrid4.RowCount<1) then exit;
         //сменить состояния
           GroupBox4.Enabled:=false;
           GroupBox3.Enabled:=true;
           GroupBox2.Enabled:=true;
           GroupBox1.Enabled:=true;
           //StringGrid3.visible:=true;
           BitBtn5.Enabled:=true;
           BitBtn19.Enabled:=true;
           //показать настройки выбранного пользователя
           id_user:= Stringgrid4.Cells[0,Stringgrid4.Row];
           RefreshArms(id_user);
           Stringgrid1.ColWidths[2]:=30;
           //сбрасываем грид пользователей
           Stringgrid4.RowCount:=0;
           //ставим флаги изменений
           chArm:= true;
           lEditO:= true;
           lEditM:= true;
           exit;
         end;
     end;

  // ESC
   if Key=27 then Form5.Close;

    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F4 - Изменить значение опции'+#13+'F5 - Добавить'+
                    #13+'F8 - Удалить'+#13+'F9 - Справочник АРМов'+#13+'F10 - Справочник опций'+#13+'F11 - Справочник меню'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Сохранить
    if (Key=113) and (bitbtn5.enabled=true) then bitbtn5.click;
    //F4 - Изменить значение опции
    if (Key=115) and (bitbtn3.enabled=true) then BitBtn3.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn1.enabled=true) then BitBtn1.Click;
    //F6 - Печать
   // If (Key=117) AND (BitBtn2.Enabled=true) then BitBtn2.click;
    //F8 - Удалить
    //if (Key=119) and (bitbtn2.enabled=true) then BitBtn2.Click;
    //F9 - Справочник АРМов
    //if (Key=120) and (bitbtn8.enabled=true) then BitBtn8.Click;
    //F10 - Справочник опций
    //if (Key=121) and (bitbtn4.enabled=true) then BitBtn4.Click;
    //F11 - Справочник меню
    //if (Key=122) and (bitbtn7.enabled=true) then BitBtn7.Click;
    // ENTER
    //if Key=13 then
    If (Key=112) or (Key=113) or (Key=114) or (Key=115) or (Key=116) then key:=0;
   end;
end;



//****************** Добавить АРМ пользователю*********************************************************
procedure TForm5.BitBtn1Click(Sender: TObject);
var
  n:integer;
begin
  idarm:='0';
  Form6:=TForm6.Create(self);
  form6.showmodal;
  FreeAndNil(form6);
  //если не выбрано ничего, то выход
 if idarm='0' then exit;
  //Если получено значение ID
  //Читаем заново StringList и добавляем запись
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
    // Выбираем нужную запись
  form5.ZQuery1.SQL.Clear;
  form5.ZQuery1.SQL.add('SELECT * FROM av_arm WHERE id='+idarm+';');
  try
  form5.ZQuery1.Open;
 except
   showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+form5.ZQuery1.SQL.Text);
   form5.ZQuery1.Close;
   form5.Zconnection1.disconnect;
   exit;
 end;

 //Защита от дурака
 if  form5.ZQuery1.RecordCount<1 then
  begin
    showmessagealt('Не выбрано Автоматизированное рабочее место !');
    form5.Zconnection1.disconnect;
    exit;
  end;
 // Проверка АРМ с таким ID
 for n:=1 to form5.StringGrid1.RowCount-1 do
    begin
      if trim(form5.StringGrid1.cells[0,n])=trim(idarm) then
       begin
         showmessagealt('Такой АРМ уже существует ! Выберите другой...');
         exit;
       end;
    end;

 //Заполняем новую строку StringGrid
 form5.StringGrid1.RowCount:=form5.StringGrid1.RowCount+1;
 form5.StringGrid1.cells[0,form5.StringGrid1.RowCount-1]:=form5.ZQuery1.FieldByName('id').asString;
 form5.StringGrid1.cells[1,form5.StringGrid1.RowCount-1]:=form5.ZQuery1.FieldByName('armname').asString;
 form5.StringGrid1.cells[2,form5.StringGrid1.RowCount-1]:='1';
 form5.ZQuery1.close;
 form5.Zconnection1.disconnect;
 //Загружаем локальные настройки для данного рабочего места
 RefreshOPT(form5.StringGrid1.cells[0,form5.StringGrid1.Row],id_user);
 //Загрузить разерешения меню пользователя для нового АРМа
 RefreshMenu(form5.StringGrid1.cells[0,form5.StringGrid1.Row],id_user);

 //Определяем фокус на новом АРМ
 form5.StringGrid1.SetFocus;
 form5.StringGrid1.row:=form5.StringGrid1.rowcount-1;
 chArm:= true;
end;


//**************************                     УДАЛИТЬ ОПЦИЮ   ****************************************
procedure TForm5.BitBtn10Click(Sender: TObject);
begin
   With FOrm5 do
begin
  If (Stringgrid2.RowCount<2) or (trim(Stringgrid2.Cells[2,Stringgrid2.Row])='') then exit;
 //Подтверждение
  If MessageDlg('Подтверждаете удаление опции?',mtConfirmation, mbYesNo, 0)=7 then exit;
  Stringgrid2.Cells[2,Stringgrid2.Row]:= '<! НА УДАЛЕНИЕ !> ' + Stringgrid2.Cells[2,Stringgrid2.Row];
  If (Stringgrid2.Cells[0,Stringgrid2.Row]='0') OR (Stringgrid2.Cells[0,Stringgrid2.Row]='4') then
   Stringgrid2.Cells[0,Stringgrid2.Row]:= '2'
  else Stringgrid2.Cells[0,Stringgrid2.Row]:= '3';

  StringGrid2.row:=StringGrid2.row + 1;
  Stringgrid2.setfocus;
  lEditO:=true;  //флаг изменения
end;
end;


//**********************         ВЫБРАТЬ НОВУЮ ОПЦИЮ  ******************************* ********
procedure TForm5.BitBtn11Click(Sender: TObject);
begin
   form5.Panel3.Visible:=false;
   If opttype=1 then
    form5.StringGrid2.Cells[3,form5.stringgrid2.row]:=Utf8copy(form5.ComboBox2.Text,1,utf8pos('-',form5.ComboBox2.Text)-1)
   else
   form5.StringGrid2.Cells[3,form5.stringgrid2.row]:=Utf8copy(form5.ComboBox2.Text,utf8pos('-',form5.ComboBox2.Text)+2,utf8length(form5.ComboBox2.Text)-2);
   form5.StringGrid2.Cells[0,form5.stringgrid2.row]:='4';
   lEditO:=true;
end;


//**************************** ВЕРНУТЬ ОТ ***********************************
procedure TForm5.BitBtn18Click(Sender: TObject);
begin
  with Form5 do
begin
  flag:=true;
  chArm:=false;
  lEditO:=false;
  lEditM:=false;
  //Stringgrid1.ColWidths[2]:=0;
  GroupBox4.Enabled:=true;
  GroupBox3.Enabled:=false;
  GroupBox2.Enabled:=false;
  GroupBox1.Enabled:=false;
  //StringGrid3.visible:=false;
  BitBtn5.Enabled:=false;
  BitBtn19.Enabled:=false;
  UpdateGrid4(); //обновить грид пользователей
  StringGrid4.ColWidths[2]:=0;
  end;
end;

//**************************** ПРИМЕНИТЬ К ************************************
procedure TForm5.BitBtn19Click(Sender: TObject);
begin
  with form5 do
begin
 If chArm or lEditM or lEditO then
 begin
   showmessagealt('Прежде следует сохранить измененные настройки пользователя !');
   exit;
 end;
  flag:= false;
  GroupBox4.Enabled:=true;
  GroupBox3.Enabled:=false;
  //GroupBox2.Enabled:=false;
  GroupBox1.Enabled:=false;
  //StringGrid3.visible:=false;
  BitBtn5.Enabled:=false;
  UpdateGrid4(); //обновить грид пользователей
  Stringgrid1.ColWidths[2]:=30;
  end;
end;


//***********   ******************   Удалить рабочее место  *****************************************
procedure TForm5.BitBtn2Click(Sender: TObject);
var
 narm: string='';
begin
  //Подтверждение
  If MessageDlg('Действительно удалить запись?',mtConfirmation, mbYesNo,0)=7 then exit;

  //Открываем транзакцию
     with Form5 do
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
      Zconnection1.disconnect;
      exit;
     end;
       narm := form5.StringGrid1.Cells[0,form5.StringGrid1.Row];

       //Удаляем запись из разрешенных пользователю армов
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_arm SET del=2,createdate=now(),id_usr='+gluser+' WHERE del=0 AND id_user='+id_user_global+' AND id_arm='+narm+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление опции армов этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id='+id_user_global+' AND id_arm='+narm+';');
       ZQuery1.ExecSQL;
       //Помечаем на удаление разрешения меню этого пользователя удаляемого арма
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id='+id_user_global+' AND id_arm='+narm+';');
       ZQuery1.ExecSQL;
 // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     ZQuery1.Close;
     Zconnection1.disconnect;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     exit;
 end;
      //showmessagealt('Транзакция завершена УСПЕШНО !!!');
      ZQuery1.Close;
      Zconnection1.disconnect;
      DelStringGrid(form5.StringGrid1,form5.StringGrid1.Row);
      StringGrid2.rowcount:=1;
      StringGrid3.rowcount:=1;
     end;
end;


//****************   ****************** Редактировать опцию  *********************************************
procedure TForm5.BitBtn3Click(Sender: TObject);
var
  sm1,sm2: string;
begin
  // Проверяем что grid2 не пустой
  if form5.StringGrid2.rowcount<2 then
   begin
    showmessagealt('Список опций пуст !');
    exit;
   end;
  if trim(form5.StringGrid2.Cells[2,form5.stringgrid2.row])='' then exit;

  if (trim(form5.StringGrid2.Cells[3,form5.stringgrid2.row])='') OR (trim(form5.StringGrid2.Cells[3,form5.stringgrid2.row])='0') then
   begin
    showmessagealt('Данная опция не имеет параметров !');
    exit;
   end;

   UpdateCombo; //обновить данные на комбо
   //настройка и отображение панели со спином платформы
   Panel3.Left:=10;
   Panel3.Top :=50;
   Panel3.height:=710;
   Panel3.width :=1000;
   Shape3.Left:=236;
   Shape3.Top :=243;
   Shape3.height:=283;
   Shape3.width :=553;
   Label6.Caption := StringGrid2.Cells[2,stringgrid2.row];
   ComboBox2.Left:=284;
   ComboBox2.Top :=322;
   BitBtn11.Left:=480;
   BitBtn11.Top :=450;
   //ComboBox2.height:=25;
   ComboBox2.width :=465;
   Panel3.visible:=true;
   //ComboBox2.visible:=true;

   ComboBox2.Setfocus;
end;


//***********        СОХРАНИТЬ ********************************************************
procedure TForm5.BitBtn5Click(Sender: TObject);
var
  arms: string='';
  k,m : integer;
begin
 with form5 do
 begin
    // Выбираем нужную запись

    //Проверяем что Grid не пустой
    if StringGrid1.RowCount<1 then
     begin
       showmessagealt('Список АРМов пуст ! Нечего сохранять !');
       exit;
     end;

     // Сохраняем данные
  If chArm then
   begin
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   //for n:=1 to Stringgrid1.RowCount-1;
  //Сохраняем новый список АРМ
  //Удаляем старый список
  try
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.add('UPDATE av_users_arm SET del=1 WHERE del=0 AND id_user='+id_user_global+';');
    ZQuery1.ExecSQL;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
    exit;
  end;
   for n:=0 to Stringgrid1.RowCount-1 do
      begin
        If Stringgrid1.Cells[2,n]='0' then continue;
         //Добавляем новый список AРМ
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('INSERT INTO av_users_arm(id_user,id_arm,id_usr,createdate,del) VALUES ('+id_user_global+','+StringGrid1.Cells[0,n]+','+GLuser+',now(),0);');
         //showmessage(ZQuery1.SQL.Text);//$
       try
         ZQuery1.ExecSQL;
       except
         showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
         ZQuery1.close;
         Zconnection1.disconnect;
         exit;
       end;
      end;
     ZQuery1.close;
     Zconnection1.disconnect;
   end;

  //если не было изменений - выход
 If not(lEditO or lEditM) then exit;
 //Если была нажата кнопка ВЫБРАТЬ, то пробегаем по всем Арм-ам, иначе, сохраняем, только одну
 If flag then  m:= Stringgrid1.RowCount-1
 else m:= 0;
//, то цикл по всем строчкам грида
for k:=0 to m do
 begin
  If m>0 then Stringgrid1.Row:=k;
  If Stringgrid1.Cells[2,Stringgrid1.Row]='0' then continue;
     //текущая строка грид1
   arms := StringGrid1.Cells[0,StringGrid1.Row];
   //showmessage(arms);

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
      ZConnection1.Disconnect;
      exit;
     end;

  //Сохраняем список АРМ>Опция
  //Проверяем что Grid2 не пустой
  if lEditO AND (StringGrid2.RowCount>1) then
   begin
     for n:=1 to StringGrid2.rowcount-1 do
    begin
      If trim(StringGrid2.Cells[1,n])='' then continue;
      If trim(StringGrid2.Cells[2,n])='' then continue;
       ZQuery1.SQL.Clear;
   //Удаляем опцию
      If (StringGrid2.Cells[0,n]='2') or flag then
        begin
        ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=2,createdate=now(),id_user='+GLuser+' WHERE id='+id_user_global+' AND id_arm='+arms);
        ZQuery1.SQL.add(' AND del=0 AND option_id='+StringGrid2.Cells[1,n]+';');
        //showmessagealt('1 '+ZQuery1.SQL.Text);//$
        ZQuery1.ExecSQL;
        end;
    //Редактируем старую опцию
      If (StringGrid2.Cells[0,n]='4') or flag then
        begin
        ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=1,createdate=now(),id_user='+GLuser+' WHERE id='+id_user_global+' AND id_arm='+arms);
        ZQuery1.SQL.add(' AND del=0 AND option_id='+StringGrid2.Cells[1,n]+';');
        //showmessagealt('2 '+ZQuery1.SQL.Text);//$
        ZQuery1.ExecSQL;
        end;
   //Добавляем новую/отредактированную опцию
      If (StringGrid2.Cells[0,n]='1') OR (StringGrid2.Cells[0,n]='4') or flag then
       begin
         ZQuery1.SQL.Clear;
          ZQuery1.SQL.add('INSERT INTO av_users_arm_options(id_arm,id,option_id,opt_value,createdate_first,createdate,id_user_first,id_user,del) VALUES (');
          ZQuery1.SQL.add(arms+','+id_user_global+','+StringGrid2.Cells[1,n]+','+(Ifthen(StringGrid2.Cells[3,n]='','0',StringGrid2.Cells[3,n]))+',');
          ZQuery1.SQL.add('now(),now(),'+GLuser+','+GLuser+',0);');
          //showmessagealt('3 '+ZQuery1.SQL.Text);//$
          ZQuery1.ExecSQL;
       end;
    end;
    end;

  //Сохраняем список АРМ>разрешения МЕНЮ
  //Проверяем что Grid3 не пустой
  if lEditM AND (StringGrid3.RowCount>1) then
   begin
  //Удаляем старый список
    ZQuery1.SQL.Clear;
    ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+id_user_global+' AND id_arm='+arms+';');
    //showmessage(' '+ZQuery1.SQL.Text);//$
    ZQuery1.ExecSQL;

  //Добавляем новый список
  for n:=1 to StringGrid3.rowcount-1 do
    begin
     //СОхраняем, если не запрещено
      if strToInt(StringGrid3.Cells[4,n]) <> 0 then
       begin
       //Если это главное меню
       IF trim(StringGrid3.Cells[0,n])='*' then
        begin
          ZQuery1.SQL.Clear;
          ZQuery1.SQL.add('INSERT INTO av_users_menu_perm(id,id_arm,id_menu_pub,id_menu_loc,permition,createdate_first,createdate,id_user_first,id_user,del) VALUES (');
          ZQuery1.SQL.add(id_user_global+','+arms+','+StringGrid3.Cells[1,n]+',0,'+StringGrid3.Cells[4,n]+',');
          ZQuery1.SQL.add('now(),now(),'+GLuser+','+GLuser+',0);');
          //showmessage(ZQuery1.SQL.text);        //$
          ZQuery1.ExecSQL;
       end;

       //Если это подменю меню
       IF trim(StringGrid3.Cells[0,n])<>'*' then
        begin
          ZQuery1.SQL.Clear;
          ZQuery1.SQL.add('INSERT INTO av_users_menu_perm(id,id_arm,id_menu_pub,id_menu_loc,permition,createdate_first,createdate,id_user_first,id_user,del) VALUES (');
          ZQuery1.SQL.add(id_user_global+','+arms+','+StringGrid3.Cells[0,n]+','+StringGrid3.Cells[1,n]+','+StringGrid3.Cells[4,n]+',');
          ZQuery1.SQL.add('now(),now(),'+GLuser+','+GLuser+',0);');
          //showmessage(ZQuery1.SQL.text);//$
          ZQuery1.ExecSQL;
       end;
       end;
    end;
  end;

   // Завершение транзакции
  Zconnection1.Commit;
 except
     ZConnection1.Rollback;
     ZQuery1.Close;
     Zconnection1.disconnect;
      showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     exit;
 end;
 end;

 ZQuery1.Close;
 Zconnection1.disconnect;
  chArm:=false; //обнуляем флаг
  lEditO:=false;
  lEditM:=false;
  flag:=false;
  //showmessagealt('УСПЕШНОЕ завершение транзакции !');
  form5.Close;

   //Загружаем локальные настройки для данного рабочего места
 //RefreshOPT(form5.StringGrid1.cells[0,form5.StringGrid1.Row],id_user);
 //Загрузить разерешения меню пользователя для нового АРМа
 //RefreshMenu(form5.StringGrid1.cells[0,form5.StringGrid1.Row],id_user);
 end;
end;


//*-************************** ВЫХОД ****************************************************
procedure TForm5.BitBtn6Click(Sender: TObject);
begin
   Form5.Close;
end;

//********************************** СОХРАНИТЬ НАСТРОЙКИ ДЛЯ ДРУГИХ ********************************************
procedure TForm5.BitBtn7Click(Sender: TObject);
var
    n,m:integer;
    newUsr,narm:string;
begin
 If Stringgrid1.RowCount=0 then
 begin
   showmessagealt('Нет ни одного доступного АРМ-а для пользователя !');
   exit;
 end;
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //Идем по гриду пользователей
   for n:=1 to Stringgrid4.RowCount-1 do
     begin
       If Stringgrid4.Cells[2,n]='1' then
       begin
         newUsr := Stringgrid4.Cells[0,n];
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
       //идем по гриду АРМов
       for m:=0 to Stringgrid1.RowCount-1 do
         begin
         //если АРМ не отмечен, то пропускаем
          If Stringgrid1.Cells[2,m]='0' then continue;
           narm := Stringgrid1.Cells[0,m];
            //помечаем на удаление доступный пользователю АРМ
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('UPDATE av_users_arm SET del=1 WHERE del=0 AND id_user='+newUsr+' AND id_arm='+narm+';');
           ZQuery1.ExecSQL;
           //добавляем в доступ АРМ пользователю, если стоит галочка
           If Stringgrid1.Cells[2,Stringgrid1.Row]='1' then
           begin
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('INSERT INTO av_users_arm(id_user,id_arm,id_usr,createdate,del) VALUES ('+newUsr+','+narm+','+GLuser+',now(),0);');
           ZQuery1.ExecSQL;
          //Сохраняем список АРМ>Опция
           //Проверяем чекбокс
           if CheckBox2.Checked then
           begin
           //помечаем на удаление опции пользователя
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('UPDATE av_users_arm_options SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+newUsr+' AND id_arm='+narm);
           ZQuery1.ExecSQL;
           //добавляем опции пользователю
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('INSERT INTO av_users_arm_options(id_arm,id,option_id,opt_value,createdate_first,id_user_first,createdate,id_user,del) ');
           ZQuery1.SQL.add('SELECT '+narm+','+newUsr+',option_id,opt_value,now(),'+GLuser+',now(),'+GLuser+',0 FROM av_users_arm_options ');
           ZQuery1.SQL.add('WHERE del=0 AND id='+id_user_global+' AND id_arm='+narm+' ;');
           ZQuery1.ExecSQL;
           end;
          //Сохраняем список АРМ>разрешения МЕНЮ
            if CheckBox1.Checked then
           begin
           //помечаем на удаление разрешения меню пользователя
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+newUsr+' AND id_arm='+narm+';');
           ZQuery1.ExecSQL;
           //добавляем опции пользователю
           ZQuery1.SQL.Clear;
           ZQuery1.SQL.add('INSERT INTO av_users_menu_perm(id_arm,id,id_menu_pub,id_menu_loc,permition,createdate_first,createdate,id_user_first,id_user,del) ');
           ZQuery1.SQL.add('SELECT '+narm+','+newUsr+',id_menu_pub,id_menu_loc,permition,now(),now(),'+GLuser+','+GLuser+',0 FROM av_users_menu_perm ');
           ZQuery1.SQL.add('WHERE del=0 AND id='+id_user_global+' AND id_arm='+narm+' ;');
           ZQuery1.ExecSQL;
           end;
           end;
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
  end;
end;


 ZQuery1.Close;
 Zconnection1.disconnect;
 GroupBox4.Enabled:=false;
 GroupBox3.Enabled:=true;
 GroupBox1.Enabled:=true;
 BitBtn5.Enabled:=true;
 showmessagealt('Сохранено УСПЕШНО !');
end;


//*****************     Справочник опций   **********************************************************
procedure TForm5.BitBtn4Click(Sender: TObject);
begin
  idarm:=form5.StringGrid1.Cells[0,form5.StringGrid1.row];
  namearm:=form5.stringgrid1.Cells[1,form5.stringgrid1.row];
  fl_edit_option:=2;
  Form7:=TForm7.Create(self);
  form7.showmodal;
  FreeAndNil(form7);
end;


//********************************************* ДОБАВИТЬ ОПЦИЮ КОНКРЕТНОМУ ПОЛЬЗОВАТЕЛЮ ДЛЯ АРМ-а  *********************
procedure TForm5.BitBtn9Click(Sender: TObject);
begin
  namearm:=form5.stringgrid1.Cells[1,form5.stringgrid1.row];
  fl_edit_option:=1;
  id_opt:='';
  Form7:=TForm7.Create(self);
  form7.showmodal;
  FreeAndNil(form7);

  //если не выбрано ничего, то выход
  IF id_opt='' then exit;

  // Проверка что опция с таким ID уже есть
 for n:=1 to form5.StringGrid2.RowCount-1 do
    begin
      if trim(form5.StringGrid2.cells[1,n])=trim(id_opt) then
       begin
         showmessagealt('Такая ОПЦИЯ уже существует !');
         exit;
       end;
    end;

  //Если получено значение ID
  //Читаем заново StringList и добавляем запись
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

 //Выбираем нужную запись
  form5.ZQuery1.SQL.Clear;
  form5.ZQuery1.SQL.add('SELECT * FROM av_arm_options WHERE del=0 AND id='+id_opt+';');
 try
  form5.ZQuery1.Open;
 except
   showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+form5.ZQuery1.SQL.Text);
   form5.ZQuery1.Close;
   form5.Zconnection1.disconnect;
   exit;
 end;

 //Защита от дурака
 if form5.ZQuery1.RecordCount<>1 then
  begin
    showmessagealt('Такая опция не существует или задвоена !');
    form5.Zconnection1.disconnect;
    exit;
  end;

 //Заполняем новую строку StringGrid
 form5.StringGrid2.RowCount := form5.StringGrid2.RowCount+1;
 form5.StringGrid2.cells[0,form5.stringgrid2.RowCount-1]:='1';
 form5.StringGrid2.cells[1,form5.stringgrid2.RowCount-1]:=form5.ZQuery1.FieldByName('id').asString;
 form5.StringGrid2.cells[2,form5.stringgrid2.RowCount-1]:=form5.ZQuery1.FieldByName('optname').asString;
 If trim(ZQuery1.FieldByName('optvalue').asString)<>'' then form5.StringGrid2.cells[3,form5.stringgrid2.RowCount-1]:='1';
 form5.ZQuery1.close;
 form5.Zconnection1.disconnect;

 lEditO:= true;
 //Определяем фокус на новом АРМ
 form5.StringGrid2.SetFocus;
 form5.StringGrid2.row:=form5.StringGrid2.rowcount-1;
end;


procedure TForm5.CheckBox1Change(Sender: TObject);
begin
  If FOrm5.CheckBox1.Checked then Form5.Stringgrid3.Enabled:=true
  else Form5.Stringgrid3.Enabled:=false;
end;


procedure TForm5.CheckBox2Change(Sender: TObject);
begin
   If FOrm5.CheckBox2.Checked then Form5.GroupBox3.Enabled:=true
  else Form5.GroupBox3.Enabled:=false;
end;


//***************************   Возникновение формы   ******************************************************
procedure TForm5.FormShow(Sender: TObject);
var
  n:integer;
  grp:string='';
begin
 CentrForm(Form5);
 Form5.ComboBox1.Height:=Form5.StringGrid1.DefaultRowHeight;
 Form5.ComboBox1.Visible := False;
 StringGrid1.Columns[2].ValueChecked:='1';
 StringGrid1.Columns[2].ValueUnchecked:='0';
 Stringgrid1.ColWidths[2]:=0;
 StringGrid4.Columns[2].ValueChecked:='1';
 StringGrid4.Columns[2].ValueUnchecked:='0';

 //Stringgrid4.Col:=2;
 UpdateGrups(); //обновить комбо с группами
 UpdateServers(); //обновить комбо с серверами
 //UpdatePodr(); //обновить комбо с подразделениями


//Определяем имя пользователя
 // Подключаемся к серверу
 //  If not(Connect2(Zconnection1, flagProfile)) then
 //    begin
 //     showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
 //     exit;
 //    end;
 //   // Выбираем нужную запись
 //    form5.ZQuery1.SQL.Clear;
 //    form5.ZQuery1.SQL.add('SELECT name FROM av_users WHERE id='+id_user_global+';');
 //  try
 //    form5.ZQuery1.Open;
 //  except
 //    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
 //    form5.ZQuery1.Close;
 //    form5.Zconnection1.disconnect;
 //    exit;
 //  end;
 // if form5.ZQuery1.RecordCount<1 then
 //  begin
 //    showmessagealt('Нет данных по выбранному пользователю !');
 //    form5.Zconnection1.disconnect;
 //    exit;
 //  end;
 //
 //Отобразить текущего пользователя
  //form5.Label5.caption:=form5.ZQuery1.FieldByName('name').asString+'  id: - '+id_user_global;
 //
 //
 // form5.ZQuery1.close;
 // form5.Zconnection1.disconnect;

 id_user_global:=form_users.StringGrid1.cells[0,form_users.StringGrid1.row];
 id_user_name:=form_users.StringGrid1.cells[1,form_users.StringGrid1.row];
 id_user:= id_user_global;
  //Заполняем grid1 опции
  form5.RefreshArms(id_user_global);

    //Сбрасываем флаг изменений
  lEditO:=false;
  lEditM:=false;


  //устанавливаем комбо группы по данному пользователю
   If ComboBox3.Items.Count<1 then exit;

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //запрос списка
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('Select group_id from av_users_group where del=0 AND user_id='+id_user_global+ ' ORDER BY group_id ASC;' );
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
  end;
  if ZQuery1.RecordCount=0 then
     begin
       Stringgrid4.Enabled:=false;
      ZQuery1.Close;
      Zconnection1.disconnect;
      exit;
     end;

     for n:=0 to ComboBox3.Items.Count-1 do
        begin
        grp:= trim(UTF8copy(ComboBox3.Items[n],1,UTF8pos('-',ComboBox3.Items[n])-1));
        If grp=ZQuery1.FieldByName('group_id').asString then
        begin
          ComboBox3.ItemIndex:= n;
          break;
        end;
      //ZQuery1.Next;
        end;
   ZQuery1.Close;
   Zconnection1.disconnect;
end;

end.


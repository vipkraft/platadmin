unit spr_menu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, Buttons, ZConnection, ZDataset,LazUTF8;

type

  { TFormMenu }

  TFormMenu = class(TForm)
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    function GetNextId(Grid: TStringGrid; sid: String):integer;  //************* Генерация уникального ID
    procedure StringGrid1BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;      Shift: TShiftState);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;  var Editor: TWinControl);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid2KeyDown(Sender: TObject; var Key: Word;      Shift: TShiftState);
    procedure StringGrid2SelectEditor(Sender: TObject; aCol, aRow: Integer; var Editor: TWinControl);
    procedure UpdateMenu(); //обновить ГРИД МЕНЮ
    procedure UpdateGrid2();//обновить грид подменю
    procedure UpdateArr; //Переписать массив подменю с новым порядком
    procedure UpdateCombo(); //обновить список АРМ-ов
private
  { private declarations }
public
    { public declarations }
end;

var
  FormMenu: TFormMenu;


implementation

uses platproc,arm,main;

const
  arr_size = 6;

var
  new_id,n,m, ndel,ntab,ch1: integer;
  lChange:boolean= false;
  lCh2:Boolean=false;
  lDel1:boolean=false;
  masM: array of array of string;
  sm,sm1,stab,stab1: string;
  arr:array of array of string;
  numarm:string='0';

//====================== Массив arr  ===================================
  //     arr[length(arr)-1,0]:= tab_loc
  //     arr[length(arr)-1,1]:= loc_name
  //     arr[length(arr)-1,2]:= id_local
  //     arr[length(arr)-1,3]:= id меню
  //     arr[length(arr)-1,4]:= //тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового
  //     arr[length(arr)-1,5] menu_id

  { TFormMenu }

 //*************************************** //обновить список АРМ-ов********************************************
procedure TFormMenu.UpdateCombo();
  var
  n : integer;
begin

  With FormMenu do
  begin
    ComboBox1.Clear;

    // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT id,armname FROM av_arm WHERE del=0 ORDER BY id ASC;');
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
      combobox1.Items.Add(ZQuery1.FieldByName('id').asString+' - ' + ZQuery1.FieldByName('armname').asString);
      ZQuery1.Next;
     end;
   combobox1.ItemIndex:=0;
  ZQuery1.Close;
  Zconnection1.disconnect;
 end;
end;

//********************************   обновить ГРИД МЕНЮ      *********************************************
procedure TFormMenu.UpdateMenu();
begin
    //Заполняем StringGrid
with FormMenu do
  begin
  Stringgrid1.RowCount:=1;
  Stringgrid2.RowCount:=1;
    //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
  // Запрос
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_arm_menu where id_local=0 AND del=0 AND id_arm='+numarm+'ORDER BY tab_pub;');
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.close;
    Zconnection1.disconnect;
    exit;
  end;
   if ZQuery1.RecordCount<1 then
     begin
       ZQuery1.close;
       Zconnection1.disconnect;
       exit;
     end;
    Stringgrid1.RowCount:=1;
     // begin
      for n:=1 to ZQuery1.Recordcount do
      begin
        Stringgrid1.RowCount:= Stringgrid1.RowCount + 1;
        StringGrid1.cells[0,Stringgrid1.RowCount-1]:= ZQuery1.FieldByName('tab_pub').asString;
        StringGrid1.cells[1,Stringgrid1.RowCount-1]:= ZQuery1.FieldByName('pub_name').asString;
        StringGrid1.cells[2,Stringgrid1.RowCount-1]:= ZQuery1.FieldByName('id_public').asString;
        StringGrid1.cells[3,Stringgrid1.RowCount-1]:= '0';//тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового
        ZQuery1.Next;
      end;

 //Обнуляем массив arr
  setlength(arr,0,arr_size);

//заполняем массив подменю
for n:=1 to Stringgrid1.RowCount-1 do
  begin
   // Запрос
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT * FROM av_arm_menu where del=0 AND id_arm='+numarm+' and id_public='+Stringgrid1.Cells[2,n]+' AND id_local>0 ORDER BY tab_loc;');
   //showmessage(ZQuery1.SQL.text);//&
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
    Zconnection1.disconnect;
    exit;
  end;
  //Если нет -  выход
 if ZQuery1.RecordCount<1 then continue;
   //Заполняем массив arr
   for m:=1 to ZQuery1.Recordcount do
     begin
       SetLength(arr,length(arr)+1,arr_size);
        // Заполняем массив arr
       arr[length(arr)-1,0]:= ZQuery1.FieldByName('tab_loc').asString;
       arr[length(arr)-1,1]:= ZQuery1.FieldByName('loc_name').asString;
       arr[length(arr)-1,2]:= ZQuery1.FieldByName('id_local').asString;
       arr[length(arr)-1,3]:= Stringgrid1.Cells[2,n]; //id меню
       arr[length(arr)-1,4]:= '0';//тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового, 4-редактирование
       arr[length(arr)-1,5]:= ZQuery1.FieldByName('menu_id').asString;
       zquery1.Next;
      end;
  end;

   ZQuery1.close;
   Zconnection1.disconnect;
   //Определяем фокус на грид меню
    //Stringgrid1.ColWidths[3]:=0;
    Stringgrid1.Row:=1;
    Stringgrid1.SetFocus;
    UpdateGrid2();
   end;
end;


//***************************              Генерация уникального ID **********************************
function TFormMenu.GetNextId(Grid: TStringGrid; sid: String):integer;
begin
  Result:=0;
  with FormMenu do
  begin
  //Получаем максимальный Id в таблице
     //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
     ZQuery1.SQL.Clear;
     ZQuery1.Sql.Add('Select max('+sid+') from av_arm_menu;');
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


//*******************************************       Переписать массив подменю с новым порядком  *********************************
procedure TFormMenu.UpdateArr;
begin
   with FormMenu do
 begin
   If (Stringgrid1.RowCount<1) or (trim(Stringgrid1.Cells[2,Stringgrid1.Row])='') then exit;
   for m:=1 to Stringgrid2.RowCount-1 do
     begin
   for n:=low(arr) to high(arr) do
       begin
        If (trim(Stringgrid2.Cells[2,m])=arr[n,2]) then
          begin
            If (arr[n,0]<>inttostr(m)) then
              begin
               arr[n,0]:=inttostr(m);
               arr[n,1]:= Stringgrid2.Cells[1,m];
               arr[n,4]:='4';//флаг редактирования
              end;
            break;
          end;
       end;
     end;
 end;
end;


//************************************************************                    редактирование пункта меню
procedure TFormMenu.StringGrid1KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  //если стрелками, то не считается
  if (Key=38) then exit;
  if (Key=40) then exit;

    with formMenu do
begin
   If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[2,Stringgrid1.Row])='') then exit;

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
   lChange:=true;
end;
end;


//****************             ПЕРЕМЕЩЕНИЕ ФОКУСА НА ЯЧЕЙКУ НАИМЕНОВАНИЯ  МЕНЮ *******************************
procedure TFormMenu.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if (aCol<>1) then formMenu.StringGrid1.Col:=1;
end;

//****************             ПЕРЕМЕЩЕНИЕ ФОКУСА НА ЯЧЕЙКУ НАИМЕНОВАНИЯ  МЕНЮ 2*******************************
procedure TFormMenu.StringGrid2SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if (aCol<>1) then formMenu.StringGrid2.Col:=1;
end;

//*******************************************  Сохранение в массив перед переходом по меню  *********************************
procedure TFormMenu.StringGrid1BeforeSelection(Sender: TObject; aCol,  aRow: Integer);
begin
  UpdateArr;
end;

procedure TFormMenu.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
begin
  UpdateGrid2();
end;


//редактирование подменю
procedure TFormMenu.StringGrid2KeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
   //если стрелками, то не считается
  if (Key=38) then exit;
  if (Key=40) then exit;

    With FOrmMenu do
  begin
  //If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;
  If (Stringgrid2.RowCount<2) or (trim(Stringgrid2.Cells[2,Stringgrid2.Row])='') then exit;
 //Ищем запись грид2 в массиве
    for n:=low(arr) to high(arr) do
           begin
             if StringGrid2.Cells[2,stringGrid2.Row]=arr[n,2] then
               begin
                  //arr[n,0]:=inttostr(stringGrid2.Row+1);
                  arr[n,1]:=Stringgrid2.Cells[1,stringGrid2.Row];
                  If arr[n,4]<>'1' then
                     begin
                      arr[n,4]:='4';
                      StringGrid2.Cells[3,stringGrid2.Row]:='4';
                     end;
               end;
           end;
    //UpdateArr;
    lChange:=true;
    lCh2:=true;
     end;
end;


//********************       переход по Грид1  -  Выборка всех подменю выбранного меню    ***************************
procedure TFormMenu.UpdateGrid2;
var
  m,k,cnt,imes,nextid: integer;
  find : boolean;
begin
 with FormMenu do
 begin
   Stringgrid2.RowCount:=1;
   If (Stringgrid1.RowCount<1) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') OR (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='-') then exit;

  //Если были изменения в грид2
  //if lChange2 AND fl then
  //  begin
  //  imes := MessageDlg('Внесенные изменения НЕ будут сохранены !'+#13+'Продолжить ?',mtConfirmation, mbYesNo, 0);
  //  if imes=7 then
  //   begin
  //     fl:=false;
  //     StringGrid1.row:=CH1;
  //     Stringgrid1.SetFocus;
  //     exit;
  //   end;
  //  end;

//Если не было изменений или все равно продолжить
//********** загружаем услуги
  If Stringgrid1.Cells[2,Stringgrid1.Row]='37' then
    begin
        //showmas(arr);
        find := false;
        If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
        //получаем новый максимальный id
         nextid:= getNextId(stringgrid2,'id_local');
     ZQuery1.SQL.Clear;
     ZQuery1.Sql.Add('SELECT * from av_spr_uslugi WHERE del=0;');
     try
       ZQuery1.open;
     except
      showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
      Zconnection1.disconnect;
      exit;
     end;
     //new_id:=0;
     If ZQuery1.RecordCount>0 then
       begin

    //Получаем максимальный Id в массиве
    for n:=low(arr) to high(arr) do
        begin
          If nextid<StrToInt(arr[n,2]) then
             nextid:=StrToInt(arr[n,2]);
        end;

     cnt:=0;
          //*************** ищем услугу в массиве *** и определяем количество подменю для данного меню **********
        //for n:=low(arr) to high(arr) do
        //   begin
        //     If (arr[n,4]='2') or (arr[n,4]='3') then continue;
        //     find:=false;
        //    for m:=1 to ZQuery1.RecordCount do
        //       begin
        //        If (trim(Stringgrid1.Cells[2,Stringgrid1.row])=arr[n,3]) then
        //      begin
        //       If (ZQuery1.FieldByName('id').AsString=arr[n,5]) then
        //          begin
        //           find:= true;
        //           break;
        //          end;
        //      end;
        //       ZQuery1.next;
        //      end;
        //  If not find then arr[n,4]:='2';//помечаем пункт меню на удаление (услуга может быть удалена из справочника)
        //   end;
       //showmas(arr);
           //*************** ищем услугу в массиве *** и определяем количество подменю для данного меню **********
      for m:=1 to ZQuery1.RecordCount do
        begin
        cnt:= cnt+1;
        for n:=low(arr) to high(arr) do
           begin
             find:=false;
                If (trim(Stringgrid1.Cells[2,Stringgrid1.row])=arr[n,3]) then
              begin
               If (ZQuery1.FieldByName('id').AsString=arr[n,5]) then
                  begin
                   find:= true;
                   break;
                  end;
              end;
              end;
        If not find then
           begin
           nextid:=nextid+1;
           SetLength(arr,length(arr)+1,arr_size);
           arr[length(arr)-1,0]:= inttostr(cnt+1);
           arr[length(arr)-1,1]:= ZQuery1.FieldByName('name').AsString+' | '+utf8copy(ZQuery1.FieldByName('sposob').AsString,1,6);
           arr[length(arr)-1,2]:= inttostr(nextid);
           arr[length(arr)-1,3]:= Stringgrid1.Cells[2,Stringgrid1.Row]; //id меню
           arr[length(arr)-1,4]:= '1'; //тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового, 4-редактирование
           arr[length(arr)-1,5]:= ZQuery1.FieldByName('id').AsString;
           lChange:=true;
           lCh2 := true;
           end;
        ZQuery1.next;
           end;
       end;
        //showmas(arr);
       ZQuery1.close;
       Zconnection1.disconnect;
    end;



  //Заполняем StringGrid2 подменю
  k:=0;
  //Заполняем грид2
  for m:=low(arr) to high(arr) do
   begin
     k:= k+1;
     for n:=low(arr) to high(arr) do
       begin
        If (trim(Stringgrid1.Cells[2,Stringgrid1.row])=arr[n,3]) AND (arr[n,0]=inttostr(k)) then
          begin
            If (arr[n,4]='2') or (arr[n,4]='3') then continue;
            Stringgrid2.RowCount := Stringgrid2.RowCount+1;
            StringGrid2.cells[0,Stringgrid2.RowCount-1]:=arr[n,0];
            StringGrid2.cells[1,Stringgrid2.RowCount-1]:=arr[n,1];
            StringGrid2.cells[2,Stringgrid2.RowCount-1]:=arr[n,2];
            StringGrid2.cells[3,Stringgrid2.RowCount-1]:=arr[n,4];
            break;
          end;
       end;
     end;

end;
   end;


//*******************             Добавляем новую запись МЕНЮ  *******************************************
procedure TFormMenu.BitBtn6Click(Sender: TObject);
var
  nextid : integer;
begin
with FormMenu.Stringgrid1 do
  begin
    //получаем новый максимальный id
    nextid:= getNextId(stringgrid1,'id_public');
    //Получаем максимальный Id в гриде
     for n:=1 to Stringgrid1.RowCount-1 do
        begin
           If nextid<StrToInt(Stringgrid1.Cells[2,n]) then
             nextid:=StrToInt(Stringgrid1.Cells[2,n]);
       end;

    nextid:=nextid+1;

    RowCount:=RowCount+1;
    Cells[0,RowCount-1]:= inttostr(RowCount-1); //порядок
    Cells[1,RowCount-1]:= ''; //наименование
    Cells[2,RowCount-1]:= inttostr(nextid); //id
    Cells[3,RowCount-1]:= '1';//тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового

    SetFocus;
    Col:=1;
    Row:=RowCount-1;
  end;
//флаг внесения изменений
  lChange:=true;
  //if not(trim(Edit1.text)='') then sm:=trim(Edit1.text) else
  //   begin
  //       repeat
  //         sm:= InputBox('Добавление меню', 'Введите новое значение меню...','');
  //       until sm<>'';
  //  end;
  //
  //repeat
  //     stab:= InputBox('Порядок перехода меню', 'Введите новое значение порядка перехода...','0');
  //until stab<>'';
  //  try
  //    ntab := StrToInt(stab);
  //  except
  //    showmessagealt('Некорректное значение порядка перехода!');
  //    exit;
  //  end;
          //If TabCheck(1,ntab) then
               //begin
               //GetNextId(stringgrid1,'id_public');
               //stringgrid1.RowCount:=stringgrid1.RowCount+1;
               //StringGrid1.cells[1,stringgrid1.RowCount-1]:=inttostr(new_id);
               //StringGrid1.cells[2,stringgrid1.RowCount-1]:=sm;
               //StringGrid1.cells[3,stringgrid1.RowCount-1]:=stab;
               //добавляем строчку в массив
               //arr[stringgrid1.RowCount,1] := new_id;
               //arr[stringgrid1.RowCount,2] := 0;
               //arr[stringgrid1.RowCount,3] := 1;

               //SetGridFocus(StringGrid1,StringGrid1.rowcount-1,1); //Определяем фокус на грид меню
               //
               //lChange1:=true;
               //Edit1.text:='';
               //end;
            //else
    //          begin
    //           Edit1.text:=sm;
    //          end;
    //end;
  //ntab:=0
end;


// **********          Добавляем новую запись ПОДМЕНЮ          **************************************
procedure TFormMenu.BitBtn7Click(Sender: TObject);
var
  nextid : integer;
begin
  with FormMenu do
  begin
    If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.row])='') then exit;
    UpdateArr;
   //получаем новый максимальный id
    nextid:= getNextId(stringgrid2,'id_local');
    //Получаем максимальный Id в массиве
    for n:=low(arr) to high(arr) do
        begin
          If nextid<StrToInt(arr[n,2]) then
             nextid:=StrToInt(arr[n,2]);
        end;

    nextid:=nextid+1;
    SetLength(arr,length(arr)+1,arr_size);
     arr[length(arr)-1,0]:= inttostr(Stringgrid2.Rowcount);
     arr[length(arr)-1,1]:= '';
     arr[length(arr)-1,2]:= inttostr(nextid);
     arr[length(arr)-1,3]:= Stringgrid1.Cells[2,Stringgrid1.Row]; //id меню
     arr[length(arr)-1,4]:= '1'; //тип операции: 0-ничего, 1-добавление нового, 2-удаление старого, 3-удаление нового, 4-редактирование
     arr[length(arr)-1,5]:= '0'; //menu_id - актуально только для услуг

    UpdateGrid2;
    Stringgrid2.Row:=Stringgrid2.RowCount-1;
    lChange:=true;
    lCh2 := true;
  end;
end;


//************************************   Редактирование грид2 ************************************
 // procedure TFormMenu.StringGrid2DblClick(Sender: TObject);
 // begin
 // with FormMenu do
 // begin
 // sm := trim(StringGrid2.Cells[2,StringGrid2.row]);//замомнить текущую строчку грид2
 //     repeat
 //        sm1:= InputBox('Редактирование меню', 'Введите новое значение меню...',StringGrid2.Cells[2,StringGrid2.row]);
 //     until sm1<>'';
 // If sm<>sm1 then
 //    begin
 //         StringGrid2.cells[2,StringGrid2.row]:=sm1;
 //         sm:=sm1;
 //         CH1:=StringGrid1.Row; //Запоминаем строчку грид1
 //         lChange2:=true; //флаг
 //         Edit1.text:='';
 //    end;
 //
 // //Запоминаем
 //    stab:=trim(StringGrid2.cells[3,stringgrid2.Row]);
 //
 // repeat
 //      stab1:= trim(InputBox('Порядок перехода подменю', 'Введите новое значение порядка перехода...',StringGrid2.Cells[3,StringGrid2.row]));
 // until stab1<>'';
 // If stab1<>stab then
 //  begin
 //   try
 //     ntab := StrToInt(stab1);
 //   except
 //     showmessagealt('Некорректное значение порядка перехода!');
 //     exit;
 //   end;
 //         //If TabCheck(2,ntab) then
 //              begin
 //              StringGrid2.cells[3,StringGrid2.Row]:=stab1;
 //              SetGridFocus(StringGrid2,StringGrid2.row,2); //Определяем фокус на грид меню
 //              CH1:=StringGrid1.Row; //Запоминаем строчку грид1
 //              lChange2:=true;  //флаг
 //              Edit1.text:='';
 //              end;
 //           //else
 //             begin
 //              Edit1.text:=sm;
 //             end;
 //   end;
 //   end;
 // ntab:=0;
 // //ищем эту строку в массиве и изменяем
 //If lChange2 then
 //   begin
 //    for n:=1 to Length(arr) do
 //     begin
 //       If arr[n,1]=StringGrid2.cells[1,stringgrid2.Row] then
 //          begin
 //           arr[n,3]:='2'; //отметка о редактировании
 //          end;
 //     end;
 //   end;
 // end;


//************                УДАЛИТЬ МЕНЮ               ******************************************************
procedure TFormMenu.BitBtn5Click(Sender: TObject);
begin
  With FOrmMenu do
begin
  If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[0,Stringgrid1.Row])='') then exit;

 IF dialogs.MessageDlg('Удаление пункта меню приведет к удаление всех пунктов его подменю !!!'+#13
 +'Все равно продолжить ?',mtConfirmation, mbYesNo, 0)=7 then exit;

  Stringgrid1.Cells[1,Stringgrid1.Row]:= '<! НА УДАЛЕНИЕ !> ' + Stringgrid1.Cells[1,Stringgrid1.Row];
  If Stringgrid1.Cells[3,Stringgrid1.Row]='0' then
   Stringgrid1.Cells[3,Stringgrid1.Row]:= '2'
  else Stringgrid1.Cells[3,Stringgrid1.Row]:= '3';
 //Удаляем подменю у этого меню
   //Ищем записи грид2 связанные с удаляемой грид1 и помечаем на удаление
        for n:=low(arr) to high(arr) do
           begin
             if StringGrid1.Cells[2,stringGrid1.Row]=arr[n,3] then
                begin
                  If arr[n,4]='0' then
                    arr[n,4]:='2' else arr[n,4]:='3';
                end;
           end;

        StringGrid1.row:=StringGrid1.row + 1;
        Stringgrid1.setfocus;
        lChange:=true;  //флаг изменения
        ldel1:=true;
end;
end;


//***************************                УДАЛИТЬ ПОДМЕНЮ      **************************************************
procedure TFormMenu.BitBtn8Click(Sender: TObject);
begin
    With FOrmMenu do
begin
  If (Stringgrid1.RowCount<2) or (trim(Stringgrid1.Cells[1,Stringgrid1.Row])='') then exit;
  If (Stringgrid2.RowCount<2) or (trim(Stringgrid2.Cells[2,Stringgrid2.Row])='') then exit;
 //Ищем запись грид2 в массиве и помечаем на удаление
    for n:=low(arr) to high(arr) do
           begin
             if StringGrid2.Cells[2,stringGrid2.Row]=arr[n,2] then
                begin
                  If arr[n,4]='0' then
                    arr[n,4]:='2' else arr[n,4]:='3';
                end;
           end;
  DelStringGrid(StringGrid2, StringGrid2.Row);
    UpdateArr;

    UpdateGrid2;
    lChange:=true;
    lCh2:=true;
     end;
end;

procedure TFormMenu.Button1Click(Sender: TObject);
begin
  showmas(arr);
end;


procedure TFormMenu.ComboBox1Change(Sender: TObject);
begin
    FormMenu.Label2.Caption:=FormMenu.ComboBox1.Text;
   //назначить новый id arm
   numarm := UTF8copy(FormMenu.ComboBox1.Text,1,UTF8pos('-',FormMenu.ComboBox1.Text)-1);
   //showmessagealt(numarm);
   UpdateMenu();
end;


//************** ЗАКРЫТИЕ ФОРМЫ ********************************************
procedure TFormMenu.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  imes: integer;
begin
   if lChange then
    begin
    imes := dialogs.MessageDlg('Внесенные изменения НЕ будут сохранены !'+#13+'Продолжить выход ?',mtConfirmation, mbYesNo, 0);
    if imes=7 then CloseAction := caNone;
    end;
end;


// *********************************************************************  hot keys *****************************************
procedure TFormMenu.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  // ESC
   if Key=27 then FormMenu.Close;

   With FormMenu do
   begin
    // F1
    if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F4 - Изменить'+#13+'F5 - Добавить меню'+#13+
    'F6 - Добавить подменю'+#13+'F8 - Удалить меню'+#13+'F9 - Удалить подменю'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Сохранить
    if (Key=113) and (bitbtn3.enabled=true) then bitbtn3.click;
    //F3 - Выбрать
    If (Key=114) and (BitBtn5.Enabled=true) then BitBtn5.click;
    //F4 - Изменить
   // if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) and (bitbtn6.enabled=true) then BitBtn6.Click;
    //F6 - Добавить
    if (Key=117) and (bitbtn7.enabled=true) then BitBtn7.Click;
    //F8 - Удалить
    if (Key=119) and (bitbtn5.enabled=true) then BitBtn5.Click;
    //F9 - Удалить
    if (Key=120) and (bitbtn8.enabled=true) then BitBtn8.Click;
     // ENTER
   // if Key=13 then
   end;
end;


 //*****************    СОХРАНИТЬ  ****************************************************************
 procedure TFormMenu.BitBtn3Click(Sender: TObject);
 var
 squ,stt: string;
 begin
 with FormMenu do
 begin
   iF Stringgrid1.RowCount<2 then exit;
 //Если не было изменений, выход
   If not (lChange) then
      begin
       showmessagealt('Нечего сохранять, изменений не было!');
       exit;
      end;
   //
      //соединение с БД
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
  UpdateArr;

for m:=1 to Stringgrid1.RowCount-1 do
  begin
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
   //Если были удаления в меню
  If ldel1 then
     begin
         //УДАЛЕНИЕ
           If Stringgrid1.Cells[3,m]='2' then
             begin
               //Формируем запрос на удаление меню (И ПОДМЕНЮ В ТОМ ЧИСЛЕ)
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_arm_menu SET del=2, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_public='+(Stringgrid1.Cells[2,m])+';');
              ZQuery1.ExecSQL;
            //Формируем запрос на удаление разрешений данного меню
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_menu_pub='+Stringgrid1.Cells[2,m]+';');
              ZQuery1.ExecSQL;
             end;
    end;
          //РЕДАКТИРОВАНИЕ
           If Stringgrid1.Cells[3,m]='4' then
              begin
               //Формируем запрос на удаление меню
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_arm_menu SET del=1, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_public='+(Stringgrid1.Cells[2,m])+' AND id_local=0;');
              //showmessagealt(ZQuery1.SQL.text);
              ZQuery1.ExecSQL;
              end;

        //ФОрмируем запрос на добавление МЕНЮ
          If ((Stringgrid1.Cells[3,m]='4') or (Stringgrid1.Cells[3,m]='1')) and (UTF8copy(Stringgrid1.Cells[1,m],1,2)<>'<!') then
             begin
                   ZQuery1.SQL.Clear;
                   ZQuery1.SQL.add('INSERT INTO av_arm_menu(id_arm,id_public,pub_name,id_local,loc_name,tab_pub,tab_loc,createdate,del,id_user) VALUES (');
                   ZQuery1.SQL.add(numarm+','+StringGrid1.Cells[2,m]+','+QuotedStr(StringGrid1.Cells[1,m])+',0,'''',');
                   ZQuery1.SQL.add(StringGrid1.Cells[0,m]+',0,DEFAULT,0,'+GLuser+');');
                   //showmessagealt('2'+ZQuery1.SQL.text);//$
                   ZQuery1.ExecSQL;
             end;

  //Если были изменения удаления подменю
  If lCh2 then
     begin
      for n:=low(arr) to high(arr) do
         begin
           If (trim(Stringgrid1.Cells[2,m])=arr[n,3]) then
           begin
           //УДАЛЕНИЕ
            If (arr[n,4]='2') then
              begin
            //Формируем запрос на удаление данного подменю
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_arm_menu SET del=2, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_local='+(arr[n,2])+';');
              ZQuery1.ExecSQL;

              //Формируем запрос на удаление разрешений данного подменю
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=2, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_menu_loc='+(arr[n,2])+';');
              ZQuery1.ExecSQL;
              end;


           //РЕДАКТИРОВАНИЕ
            If (arr[n,4]='4') then
              begin
            //Формируем запрос на удаление данного подменю
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_arm_menu SET del=1, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_local='+(arr[n,2])+';');
              ZQuery1.ExecSQL;

              //Формируем запрос на удаление разрешений данного подменю
              ZQuery1.SQL.Clear;
              ZQuery1.SQL.add('UPDATE av_users_menu_perm SET del=1, createdate=DEFAULT, id_user='+GLuser+' WHERE del=0 AND id_arm='+numarm+' AND id_menu_loc='+(arr[n,2])+';');
              ZQuery1.ExecSQL;
              end;

         //формируем запрос на добавление ПОДМЕНЮ
          If (arr[n,4]='4') OR (arr[n,4]='1') then
             begin
                   ZQuery1.SQL.Clear;
                   ZQuery1.SQL.add('INSERT INTO av_arm_menu(id_arm,id_public,pub_name,id_local,loc_name,tab_pub,tab_loc,menu_id,createdate,del,id_user) VALUES (');
                   ZQuery1.SQL.add(numarm+','+StringGrid1.Cells[2,m]+','+QuotedStr(StringGrid1.Cells[1,m])+','+arr[n,2]+',');
                   ZQuery1.SQL.add(QuotedStr(arr[n,1])+','+StringGrid1.Cells[0,m]+','+arr[n,0]+','+arr[n,5]);
                   ZQuery1.SQL.add(',DEFAULT,0,'+GLuser+');');
                   //showmessage('1'+ZQuery1.SQL.Text);//$
                   ZQuery1.ExecSQL;
             end;
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
 //обнуляем строчку
  Stringgrid1.Cells[3,m]:='0';
//закрываем цикл по гриду меню
end;
 showmessagealt('Транзакция успешно завершена !');
 lChange:=false;
  lCh2:=false;
  lDel1:=false;
  ZQuery1.Close;
  Zconnection1.disconnect;
  UpdateMenu;
 end;
end;


//************ ПЕРЕМЕСТИТЬ СТРОЧКУ ГРИДА ВНИЗ *****************************
procedure TFormMenu.BitBtn11Click(Sender: TObject);
begin
  with FormMenu.StringGrid1 do
begin
  // Если нет пунктов или последний то ничего не делаем
   if (Row=RowCount-1) or (RowCount<2) then exit;
  Cells[3,Row] :='4';
  Cells[3,Row+1] :='4';
 end;
 GridRowDown(FormMenu.StringGrid1);
 lChange:=true;
end;


//*******************    ПЕРЕМЕСТИТЬ СТРОЧКУ ГРИДА ВВЕРХ          **********************************
procedure TFormMenu.BitBtn12Click(Sender: TObject);
begin
  with FormMenu.StringGrid1 do
begin
  // Если нет пунктов или первый то ничего не делаем
  if (Row=1) or (RowCount<2) then exit;
  Cells[3, Row] :='4';
  Cells[3, Row-1]:='4';
 end;
  GridRowUp(FormMenu.StringGrid1);
  lChange:=true;
end;

//************ ПЕРЕМЕСТИТЬ СТРОЧКУ ГРИДА ПОДМЕНЮ  ВНИЗ   *****************************
procedure TFormMenu.BitBtn13Click(Sender: TObject);
begin
  GridRowDown(FormMenu.StringGrid2);
  UpdateArr;
  lCh2:=true;
end;


procedure TFormMenu.BitBtn14Click(Sender: TObject);
begin
  GridRowUp(FormMenu.StringGrid2);
  UpdateArr;
  lCh2:=true;
end;


//**********************************      ВЫХОД        **********************************************
procedure TFormMenu.BitBtn4Click(Sender: TObject);
begin
    FormMenu.Close;
end;


//**************************       ВОзникновение  формы *********************************************
procedure TFormMenu.FormShow(Sender: TObject);
begin
  CentrForm(FormMenu);
  //инициализация переменных
    lChange:=false;
    lCh2:=false;
    ndel:=0;
    ch1:=0;
    //ch2:=0;

    UpdateCombo(); //обновить список АРМ-ов
    FormMenu.Label2.Caption:=FormMenu.ComboBox1.Text;
    numarm := UTF8copy(FormMenu.ComboBox1.Text,1,UTF8pos('-',FormMenu.ComboBox1.Text)-1);
    UpdateMenu();
end;


{$R *.lfm}

end.


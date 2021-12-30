unit Servers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Spin, ExtCtrls, EditBtn, Buttons, Grids, Users_main, point_main;

type

  { TFormServers }

  TFormServers = class(TForm)
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    BitBtn25: TBitBtn;
    BitBtn26: TBitBtn;
    BitBtn27: TBitBtn;
    BitBtn28: TBitBtn;
    BitBtn29: TBitBtn;
    BitBtn35: TBitBtn;
    BitBtn36: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    DateEdit1: TDateEdit;
    Edit19: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    Image1: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label9: TLabel;
    Memo4: TMemo;
    Shape9: TShape;
    SpinEdit10: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    SpinEdit8: TSpinEdit;
    SpinEdit9: TSpinEdit;
    StringGrid3: TStringGrid;
    StringGrid4: TStringGrid;
    StringGrid5: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn23Click(Sender: TObject);
    procedure BitBtn24Click(Sender: TObject);
    procedure BitBtn25Click(Sender: TObject);
    procedure BitBtn26Click(Sender: TObject);
    procedure BitBtn27Click(Sender: TObject);
    procedure BitBtn35Click(Sender: TObject);
    procedure BitBtn36Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure CheckBox5Change(Sender: TObject);
    procedure Edit19Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid3BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid3MouseMove(Sender: TObject; Shift: TShiftState; X,      Y: Integer);
    procedure StringGrid3Selection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid4SetCheckboxState(Sender: TObject; ACol, ARow: Integer; const Value: TCheckboxState);
    procedure UpdateServers();// обновить гриды на вкладке СЕРВЕРА *****************************
    procedure SaveToMas(flg:boolean); //сохранить данные серверов с формы в массивы
    procedure Server_del(); //удалить сервер продажи
    procedure updateGrid3;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormServers: TFormServers;

implementation
uses
  platproc,main;

const
    arsrv_size=16; //размерность массива серверов
var
  ar_access, ar_deny, ar_srv : Array of Array of String; // массивы для вкладки СЕРВЕРА
  razbor: string='';
  new_id : integer=0;
  fl_change,fl_user,fl_access:boolean;

      //ar_srv[n,0] :=  point_id
      //ar_srv[n,1] :=  name
      //ar_srv[n,2]:= id
      //ar_srv[n,3]:= active
      //ar_srv[n,4]:= activedate
      //ar_srv[n,5]:= usetarif
      //ar_srv[n,6]:= ip
      //ar_srv[n,7]:= ip2
      //ar_srv[n,8]:= info
      //ar_srv[n,9]:= '0' // флаг редактирования
      //ar_srv[n,10]:= base_name
      //ar_srv[n,11]:= login
      //ar_srv[n,12]:= password
      //ar_srv[n,13]:= port
      //ar_srv[n,14]:= real/virtual
      //ar_srv[n,15]:= edit_access

{$R *.lfm}

{ TFormServers }


procedure TFormServers.updateGrid3;
var
  n:integer;
begin
     Stringgrid3.RowCount:=1;
     //заполняем грид - серверы
     for n:=low(ar_srv) to high(ar_srv) do
     begin
      //пропускать, если отоборажаются только реальные сервера
       If FormServers.CheckBox2.Checked and (ar_srv[n,14]='0') then continue;
      Stringgrid3.RowCount:= Stringgrid3.RowCount+1;
      Stringgrid3.Cells[0,Stringgrid3.RowCount-1] := ar_srv[n,0];
      Stringgrid3.Cells[1,Stringgrid3.RowCount-1] := ar_srv[n,1];
    end;
     updateServers();
end;

procedure TFormServers.Server_del;
var
   n,m,l:integer;
begin
   // ***************************************** УДАЛИТЬ СЕРВЕР ПРОДАЖИ *************************************
 With formServers do
 begin
  If  trim(StringGrid3.Cells[0,StringGrid3.Row])='' then exit;
  If StringGrid3.RowCount < 2 then exit;
  n:=0;
  m:=0;
  l:=0;
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
      showmessagealt('Ошибка! Массив данных не соответствует отображаемым данным !');
      exit;
    end;

   if dialogs.MessageDlg('ВНИМАНИЕ, УДАЛЕНИЕ сервера приведет к '+#13+'удалению ТАРИФОВ по этому серверу'+#13+'и удалене записей в других связанных таблицах'
   +#13+' Все равно продолжить удаление ?',mtConfirmation,[mbYes,mbNO],0)=7 then exit;

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
  DelStringGrid(formServers.StringGrid3,formServers.StringGrid3.Row);
 //UpdateServers();
  fl_change:=true; //флаг внесения изменений
end;


//******************************** СОХРАНИТЬ ДАННЫЕ С ФОРМЫ В МАССИВ ******************************
procedure TformServers.SaveToMas(flg:boolean);
var
   sss: string;
   l: byte=0;
   n,m:integer;
begin
 with formServers do
 begin
 If StringGrid3.RowCount<2 then exit;
 If StringGrid3.Row <1 then exit;
 If StringGrid3.Row > (Length(ar_srv)+1) then exit;
 If trim(Stringgrid3.Cells[0,StringGrid3.Row])='' then exit;
 //showmas(ar_srv);
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
    showmessagealt('Ошибка! Массив данных не соответствует отображаемым данным !');
    fl_access:=false;
    exit;
   end;
 //признак реальный/виртуальный
   If Checkbox1.checked then ar_srv[m,14]:='1' else ar_srv[m,14]:='0';
 //признак активации
   If Checkbox4.checked then ar_srv[m,3]:='1' else ar_srv[m,3]:='0';
 //дата активации
   ar_srv[m,4] := DateEdit1.Text;
   //использовать при расчетах
   If Checkbox5.checked then ar_srv[m,5]:='1' else ar_srv[m,5]:='0';

    If flg and fl_access then ar_srv[m,15]:='1';
   fl_access:=false;
   //ip-адрес **********************
   razbor:='';
   razbor:=razbor+padl(SpinEdit2.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit3.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit4.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit5.Text,'0',3);
   // razbor:=razbor+padl(inttostr(SpinEdit2.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit3.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit4.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit5.Value),'0',3);
   ar_srv[m,6]:= razbor;
   //ip-адрес2 ************************
   razbor:='';
   razbor:=razbor+padl(SpinEdit6.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit7.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit8.Text,'0',3)+'.';
   razbor:=razbor+padl(SpinEdit9.Text,'0',3);
   // razbor:=razbor+padl(inttostr(SpinEdit6.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit7.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit8.Value),'0',3)+'.';
   //razbor:=razbor+padl(inttostr(SpinEdit9.Value),'0',3);

   ar_srv[m,7]:= razbor;
   //дополнительная информация
   ar_srv[m,8]:=trim(Memo4.Text);
   //база данных - наименование
   ar_srv[m,10]:=trim(Edit19.Text);
   //база данных - логин
   ar_srv[m,11]:=trim(Edit20.Text);
   //база данных - пароль
   ar_srv[m,12]:=trim(Edit21.Text);
   //база данных - порт
   ar_srv[m,13]:=trim(SpinEdit10.Text);

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
 //записываем
end;
end;


//***************************** обновить гриды на вкладке СЕРВЕРА *****************************
procedure TformServers.UpdateServers();
var
   k,n : integer;
   m:integer=0;
   find:boolean;
begin
 With formServers do
 begin
 If StringGrid3.RowCount<2 then exit;
 If StringGrid3.Row <1 then exit;
 If StringGrid3.Row > (Length(ar_srv)+1) then exit;
 find:= false;
 k:=0;
 //поиск массиве строчки грида сервера
 For n:=0 to Length(ar_srv)-1 do
  begin
    If ar_srv[n,0] = Stringgrid3.Cells[0,Stringgrid3.row] then
      begin
        find:= true;
        k:= n;
        break;
      end;
   end;
 If not find then exit; //если не нашли - выход

 //определяем данные на форме
  //реальный/виртуальный
   If ar_srv[k,14] = '1' then
      Checkbox1.Checked:= true
      else Checkbox1.Checked:= false;
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
       try
   If Pos('.',razbor)>0 then
   SpinEdit2.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If Pos('.',razbor)>0 then
   SpinEdit3.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If Pos('.',razbor)>0 then
   SpinEdit4.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   SpinEdit5.Value:=strtoint(copy(razbor,1,255));
        except
         on exception: ECOnvertError do showmessagealt('Ошибка отображения ip-адреса №1 !');
       end;
   end;

   razbor:=trim(ar_srv[k,7]);
   If razbor <> '' then
     begin
       try
   If Pos('.',razbor)>0 then
   SpinEdit6.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If Pos('.',razbor)>0 then
   SpinEdit7.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   If Pos('.',razbor)>0 then
   SpinEdit8.Value:=strtoint(copy(razbor,1,pos('.',razbor)-1));
   razbor:=copy(razbor,pos('.',razbor)+1,255);
   SpinEdit9.Value:=strtoint(copy(razbor,1,255));
       except
         on exception: ECOnvertError do showmessagealt('Ошибка отображения ip-адреса №2 !');
       end;
   end;

   Memo4.Text := ar_srv[k,8];
   Edit19.Text := ar_srv[k,10];
   Edit20.Text := ar_srv[k,11];
   Edit21.Text := ar_srv[k,12];
    try
   SpinEdit10.Value := strtoint(ar_srv[k,13]); //порт
    except
         on exception: ECOnvertError do showmessagealt('Ошибка отображения порта !');
       end;

  //заполняем гриды
   StringGrid4.RowCount := 1;
  // SetLength(ar_access, StringGrid3.RowCount-1, 2);
  // SetLength(ar_deny, StringGrid3.RowCount-1, 3);
   FOR n:=1 to StringGrid3.RowCount-1 do
     begin
        If n=StringGrid3.Row then continue;
        StringGrid4.RowCount := StringGrid4.RowCount+1;
        StringGrid4.Cells[0,StringGrid4.RowCount-1]:=StringGrid3.Cells[0,n];
        StringGrid4.Cells[1,StringGrid4.RowCount-1]:=StringGrid3.Cells[1,n];
        StringGrid4.Cells[2,StringGrid4.RowCount-1]:='0';
     end;
   //определяем доступные сервера
    For n:=low(ar_access) to high(ar_access) do
      begin
       // определяем текущий сервер в массиве доступных
        If (trim(ar_access[n,0])<>'') AND (ar_access[n,0]=ar_srv[k,0]) then
          begin
            If  trim(ar_access[n,1])<>''  then
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


//*******************************************************  HOT  KEYS ****************************************
procedure TFormServers.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState  );
begin
   with FormServers do
begin
   // F1
     if Key=112 then showmessagealt('[F1] - Справка'+#13+'[F2] - Сохранить'+#13+'[F5] - Добавить'+#13+'[F8] - Удалить'+#13+'[ПРОБЕЛ] - Выбрать'+#13+'[ESC] - Отмена\Выход');
   //F2 - Сохранить
    if (Key=113) AND (BitBtn23.enabled=true) then BitBtn23.Click;
   //Пробел
    if (Key=32) AND (BitBtn35.Visible=true) then BitBtn35.Click;
   //F5 - Добавить
    if (Key=116) then BitBtn25.Click;
   //F8 - Удалить
    if (Key=119) then BitBtn26.Click;
   // ESC
    if (Key=27) then Close;
end;
    If (Key=27) OR (Key=112) OR (Key=113) OR (Key=116) OR (Key=119) then Key:=0;
end;


//************************* УДАЛИТЬ ПОЛЬЗОВАТЕЛЯ ИЗ СПИСКА ЗАПРЕЩЕННЫХ НА ДАННОМ СЕРВЕРЕ ************************
procedure TformServers.BitBtn27Click(Sender: TObject);
var
  flf:boolean;
  n:integer;
begin
  flf := false;
  with FOrmServers do
  begin
  for n:=low(ar_deny) to high(ar_deny) do
    begin
      If ar_deny[n,1]=Stringgrid5.Cells[0,Stringgrid5.Row] then
      begin
       ar_deny[n,0]:='';
       flf := true;
       break;
      end;
   end;
  end;
  If flf then
  begin
  fl_user:= true;
   DelStringGrid(formServers.StringGrid5,formServers.StringGrid5.Row);
  end;
end;


//******************************** СОХРАНИТЬ ДАННЫЕ ПО СЕРВЕРАМ ПРОДАЖИ ***********************************
procedure TformServers.BitBtn23Click(Sender: TObject);
var
   fl_edit : byte;
  n, m:integer;
begin
 SaveToMas(fl_access);
 With formServers do
 begin
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   if not (fl_change or fl_user) then
         begin
          showmessagealt('Сначала внесите изменения !');
          exit;
         end;

   for n:=0 to Length(ar_srv)-1 do
    begin
    //проверка введеных данных
   // If (SpinEdit2.Value=0) AND (SpinEdit3.Value=0) AND (SpinEdit4.Value=0) AND (SpinEdit5.Value=0) then
     If trim(ar_srv[n,6])='000.000.000.000' then
     begin
       showmessagealt('Некорректный IP-адрес у '+ar_srv[n,1]+' !');
       exit;
       end;
     If ar_srv[n,3]='1' then
     begin
       If trim(ar_srv[n,4])='' then
       begin
       showmessagealt('Некорректная Дата активации у '+ar_srv[n,1]+' !');
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
      showmessagealt('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      ZConnection1.Rollback;
      exit;
     end;
   if (fl_edit<>1) AND (trim(ar_srv[n,2])='') then
    begin
      showmessagealt('Несоответствие в массиве серверов !');
      exit;
     end;
   //обрабатываем удаленные сервера
    If fl_edit=2 then
      begin
         //удаляем сервера из тарифов предварительной продажи
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_tarif_uslugi SET del=2,createdate=now(),id_user='+gluser+' WHERE id_point='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

      //удаляем сервера из тарифов предварительной продажи
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_tarif_predv SET del=2,createdate=now(),id_user='+gluser+' WHERE id_point='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

      //удаляем сервера из тарифов серверов
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_tarif_local SET del=2,createdate=now(),id_user='+gluser+' WHERE id_point='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

       //удаляем сервера из тарифов багажа
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_tarif_bagag SET del=2,createdate=now(),id_user='+gluser+' WHERE id_point='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

        //удаляем сервера из доступных пользователям
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_users_servers SET del=2,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,2]+' AND del=0;');
       ZQuery1.ExecSQL;

     //Маркируем запись на удаление (del=2) если сервер был удален
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_denyuser SET del=2,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_access SET del=2,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers SET del=2,createdate=now(),id_user='+gluser+' WHERE id='+ar_srv[n,2]+' AND del=0;');
       ZQuery1.ExecSQL;
       // Завершение транзакции
  Zconnection1.Commit;
  continue;
      end;

   //Маркируем запись на удаление (del=1) если режим редактирования
   if (fl_edit=0) then
      begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers SET del=1,createdate=now(),id_user='+gluser+' WHERE id='+ar_srv[n,2]+' AND del=0;');
       ZQuery1.ExecSQL;
       //showmessage(ZQuery1.SQL.text);//$
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
  ZQuery1.SQL.add('INSERT INTO av_servers(active,activedate,usetarif,point_id,ip,ip2,info,base_name,login,pwd,port,real_virtual,id,id_user,createdate,del,id_user_first,createdate_first) VALUES (');

  ZQuery1.SQL.add(ar_srv[n,3]+','+QuotedStr(ar_srv[n,4])+','+ar_srv[n,5]+','+ar_srv[n,0]+','+QuotedSTR(ar_srv[n,6])+',');
  ZQuery1.SQL.add(QuotedStr(ar_srv[n,7])+','+QuotedStr(ar_srv[n,8])+','+QuotedStr(ar_srv[n,10])+','+QuotedStr(ar_srv[n,11])+','+QuotedStr(ar_srv[n,12])+','+ar_srv[n,13]+','+ar_srv[n,14]+',');
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
   //showmessage(ZQuery1.SQL.text);//$
   ZQuery1.ExecSQL;


   //Пишем доступные сервера
   if ar_srv[n,15]='1' then
      begin
       //Маркируем запись на удаление (del=1) если записи редактировались
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_access SET del=1,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
    //showmessage(ZQuery1.SQL.text);//$
       ZQuery1.ExecSQL;

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
     //showmessage(ZQuery1.SQL.text);//$
            ZQuery1.ExecSQL;
           end;
        end;
    end;
      end;

   //Пишем запрещенных пользователей
   If fl_user then
     begin
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('UPDATE av_servers_denyuser SET del=1,createdate=now(),id_user='+gluser+' WHERE server_id='+ar_srv[n,0]+' AND del=0;');
       ZQuery1.ExecSQL;

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
            ZQuery1.ExecSQL;
        end;
    end;
     end;

  // Завершение транзакции
  Zconnection1.Commit;
  ar_srv[n,9] := '4'; //убираем из списка несохраненных
  ar_srv[n,15]:= ''; //сбросить флаг редактирования доступа
 // Close;
 except
     ZConnection1.Rollback;
     showmessagealt('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 end;
 end;
  ZQuery1.Close;
  Zconnection1.disconnect;
  fl_change:= false;
  fl_user:= false;
  //showmessagealt('Данные успешно сохранены !');
  FormServers.Close;
  //UpdateServers();
end;
end;


//************************************************  ДОБАВИТЬ ЗАПРЕЩЕННОГО ПОЛЬЗОВАТЕЛЯ *******************
procedure TformServers.BitBtn24Click(Sender: TObject);
var
  n:integer;
begin
  //ОТКРЫВАЕМ справочник юзеров
  form_Users:=Tform_users.create(self);
  form_Users.ShowModal;
  FreeAndNil(form_users);
 //обрабатываем выбор
  if (result_user = '') then exit;
 //проверка на совпадающие
  with formServers do
  begin
  for n:=1 to Stringgrid5.RowCount-1 do
    begin
      If Stringgrid5.Cells[0,n]=result_user then
      begin
       showmessagealt('Добавляемый пользователь уже есть в списке !');
       exit;
      end;
    end;
 // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   // запрос
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT name, dolg FROM av_users WHERE del=0 AND id='+result_user+';');
  try
    ZQuery1.open;
  except
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     ZQuery1.Close;
     Zconnection1.disconnect;
  end;
  if ZQuery1.RecordCount<>1 then
     begin
      showmessagealt('Ошибка выбора реквизитов пользователя из справочника!');
     end;
  SetLength(ar_deny, Length(ar_deny)+1,4);
  ar_deny[Length(ar_deny)-1,0] := formServers.Stringgrid3.Cells[0,formServers.Stringgrid3.Row];
  ar_deny[Length(ar_deny)-1,1] := result_user;
  ar_deny[Length(ar_deny)-1,2] := formServers.ZQuery1.FieldByName('name').AsString;
  ar_deny[Length(ar_deny)-1,3] := formServers.ZQuery1.FieldByName('dolg').AsString;
  Stringgrid5.RowCount := Stringgrid5.RowCount +1;
  Stringgrid5.Cells[0,Stringgrid5.RowCount-1] := result_user;
  Stringgrid5.Cells[1,Stringgrid5.RowCount-1] := formServers.ZQuery1.FieldByName('name').AsString;
  Stringgrid5.Cells[2,Stringgrid5.RowCount-1] := formServers.ZQuery1.FieldByName('dolg').AsString;

   ZQuery1.Close;
   Zconnection1.disconnect;

  end;
  fl_user:= true;
end;


procedure TFormServers.BitBtn35Click(Sender: TObject);
begin
    //******************  выбрать остановочный пункт из списка серверов ******************************
  with FormServers do
begin
  If (Stringgrid3.Cells[0,Stringgrid3.Row]<>'') AND (Stringgrid3.RowCount>1) then
   ConnectINI[14] :=Stringgrid3.Cells[0,Stringgrid3.Row];

  FormServers.Close;
  //BitBtn23.Visible:= true;
  //BitBtn25.Visible:= true;
  //BitBtn26.Visible:= true;
  //BitBtn35.Visible:= false;
  //BitBtn36.Visible:= false;
end;
end;


// **************************************  ДОБАВИТЬ СЕРВЕР ПРОДАЖИ ****************************************
procedure TformServers.BitBtn25Click(Sender: TObject);
var
  m,n:integer;
begin
  result_name_point:='';

  form9:=Tform9.create(self);
  form9.ShowModal;
  FreeAndNil(form9);
  //Добавляем остановочный пункт
  if (result_name_point='') then exit;
  with formServers do
  begin
    n:=1;
    //проверка на дубликат
   for n:=1 to StringGrid3.RowCount-1 do
    begin
     If trim(StringGrid3.Cells[0,n]) = result_name_point then
       begin
        showmessagealt('Данный остановочный пункт уже есть в списке серверов !');
        exit;
       end;
    end;

     m := Length(ar_srv);
    SetLength(ar_srv, Length(ar_srv)+1, arsrv_size);
      //ar_srv[n,0] :=  point_id
      //ar_srv[n,1] :=  name
      //ar_srv[n,2]:= id
      //ar_srv[n,3]:= active
      //ar_srv[n,4]:= activedate
      //ar_srv[n,5]:= usetarif
      //ar_srv[n,6]:= ip
      //ar_srv[n,7]:= ip2
      //ar_srv[n,8]:= info
      //ar_srv[n,9]:= '0' // флаг редактирования
      //ar_srv[n,10]:= base_name
      //ar_srv[n,11]:= login
      //ar_srv[n,12]:= password
      //ar_srv[n,13]:= port

    ar_srv[m,0] := result_name_point; //id остановочного пункта
    ar_srv[m,1] := name_pnt; // наименование остановочного пункта сервера
    ar_srv[m,2] := ''; // id
    ar_srv[m,4] := DateToStr(Date());
    ar_srv[m,5] := '1'; //использовать при расчете тарифов по умолчанию
    ar_srv[m,9] := '1'; // флаг добавления записи
    ar_srv[n,10]:= 'platforma';
    ar_srv[n,11]:= Cuser;
    ar_srv[n,12]:= Cpass;
    ar_srv[n,13]:= '5432';
    ar_srv[n,14]:= '0';
   //увеличиваем массив доступных серверов на количество текущих серверов -1
   SetLength(ar_access,length(ar_access)+m,2);
    for n:=0 to m do
     begin
      ar_access[length(ar_access)-m+n-1,0]:= result_name_point;
     end;
  //showmas(ar_access);
  //  showmessage(inttostr(length(ar_access)));
   StringGrid3.RowCount := StringGrid3.RowCount+1;
   Stringgrid3.Cells[0,StringGrid3.RowCount-1]:= result_name_point;
   Stringgrid3.Cells[1,StringGrid3.RowCount-1]:= name_pnt;
   StringGrid3.Row := StringGrid3.RowCount-1;
   //UpdateServers();
   StringGrid3.SetFocus;
   fl_change:=true; //флаг внесения изменений

    label4.Caption:=inttostr(strtoint(label4.Caption)+1);
  end;
end;

procedure TFormServers.BitBtn26Click(Sender: TObject);
begin
  server_del(); //удалить сервер продажи
end;


//********************** ОТМЕНА *********************************
procedure TFormServers.BitBtn36Click(Sender: TObject);
begin
 FormServers.Close;
end;

procedure TFormServers.CheckBox1Change(Sender: TObject);
begin
  fl_change:=true; //флаг внесения изменений
end;

//переключение отображения серваков
procedure TFormServers.CheckBox2Change(Sender: TObject);
begin
  updateGrid3();
end;

procedure TFormServers.CheckBox4Change(Sender: TObject);
begin
  fl_change:=true; //флаг внесения изменений
end;

procedure TFormServers.CheckBox5Change(Sender: TObject);
begin
  fl_change:=true; //флаг внесения изменений
end;

procedure TFormServers.Edit19Change(Sender: TObject);
begin
  fl_change:=true; //флаг внесения изменений
end;

procedure TFormServers.FormClose(Sender: TObject; var CloseAction: TCloseAction  );
begin
  If fl_change or fl_user then
   if dialogs.MessageDlg('Внесенные изменения НЕ будут СОХРАНЕНЫ !!!'+#13+'Продолжить выход ?',mtConfirmation,[mbYes,mbNO],0)=7 then
        begin
          CloseAction := caNone;
          exit;
        end;
  //освобождение памяти, занимаемой массивами
  Setlength(ar_access,0,0);
  ar_access := nil;
  Setlength(ar_deny,0,0);
  ar_deny := nil;
  Setlength(ar_srv,0,0);
  ar_srv := nil;
end;


procedure TFormServers.FormShow(Sender: TObject);
var
   n,k,m,j:integer;
   ttt: string;
begin
  Centrform(FormServers);
 with FormServers do
 begin
  //открыть кнопку СОХРАНИТЬ
  if flag_access=2 then  FormServers.BitBtn23.Enabled:=true;

  // Обнуляем данные на вкладке
   StringGrid3.RowCount := 1;
   StringGrid4.RowCount := 1;
   StringGrid5.RowCount := 1;
   StringGrid4.Columns[2].ValueChecked:='1';
   StringGrid4.Columns[2].ValueUnchecked:='0';

    fl_change:= false;
  fl_user:= false;
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
   // запрос
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT get_servers_list('+quotedstr('srvs')+',2,2,'+quotedstr('')+');');
     ZQuery1.SQL.add('FETCH ALL IN srvs;');
     try
       ZQuery1.open;
     except
       showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
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
    SetLength(ar_srv, 0, arsrv_size);
   // Заполняем массивы
   SetLength(ar_srv, ZQuery1.RecordCount,arsrv_size);
   SetLength(ar_access, Length(ar_srv)*(Length(ar_srv)-1), 2);
   k:=0;
   label4.Caption:=inttostr(ZQuery1.RecordCount);

   for n:=0 to ZQuery1.RecordCount-1 do
    begin
      ar_srv[n,0] := ZQuery1.FieldByName('point_id').asString;
      ar_srv[n,1] := ZQuery1.FieldByName('pname').asString;
      ar_srv[n,2]:=ZQuery1.FieldByName('id').asString;
      ar_srv[n,3]:=ZQuery1.FieldByName('active').asString;
      ar_srv[n,4]:=ZQuery1.FieldByName('activedate').asString;
      ar_srv[n,5]:=ZQuery1.FieldByName('usetarif').asString;
      ar_srv[n,6]:=ZQuery1.FieldByName('ip').asString;
      ar_srv[n,7]:=ZQuery1.FieldByName('ip2').asString;
      ar_srv[n,8]:=ZQuery1.FieldByName('info').asString;
      ar_srv[n,9]:= '0' ; // флаг редактирования
      ar_srv[n,10]:=ZQuery1.FieldByName('base_name').asString;
      ar_srv[n,11]:=ZQuery1.FieldByName('login').asString;
      ar_srv[n,12]:=ZQuery1.FieldByName('pwd').asString;
      ar_srv[n,13]:=ZQuery1.FieldByName('port').asString;
      ar_srv[n,14]:=ZQuery1.FieldByName('real_virtual').asString;

      //заполняем массив доступных пустыми значениями для каждого сервера
      for m:=0 to ZQuery1.RecordCount-2 do
       begin
          If k>length(ar_access) then
            begin
             showmessagealt('Переполнение массива доступных серверов !'+ar_srv[n,1]);
             continue;
            end;
          ar_access[k,0] := ar_srv[n,0];
          ar_access[k,1] := '';
          k := k + 1;
       end;
       //заполняем грид - серверы
      Stringgrid3.RowCount:= Stringgrid3.RowCount+1;
      Stringgrid3.Cells[0,Stringgrid3.RowCount-1] := ar_srv[n,0];
      Stringgrid3.Cells[1,Stringgrid3.RowCount-1] := ar_srv[n,1];
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
              showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
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
              showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ ZQuery1.SQL.Text);
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

procedure TFormServers.StringGrid3BeforeSelection(Sender: TObject; aCol,  aRow: Integer);
begin
   SaveToMas(fl_access);
end;

procedure TFormServers.StringGrid3MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  exit;
end;

procedure TFormServers.StringGrid3Selection(Sender: TObject; aCol, aRow: Integer  );
begin
  UpdateServers();
end;

procedure TFormServers.StringGrid4SetCheckboxState(Sender: TObject; ACol, ARow: Integer; const Value: TCheckboxState);
begin
  fl_access:=true;
  If stringgrid4.Cells[2,aRow]='0' then stringgrid4.Cells[2,aRow]:='1' else stringgrid4.Cells[2,aRow]:='0';
end;

end.


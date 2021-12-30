unit web_users;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, Grids, Buttons, ComCtrls, StdCtrls, ExtCtrls, LazUTF8, PairSplitter,
  EditBtn, Spin, ExtPersonal, web_options, web_usr_opt, web_usr_kontr, webrep;

type

  { TForm_webusr }

  TForm_webusr = class(TForm )
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    ComboBox1: TComboBox;
    DateEdit2: TDateEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    Image1: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure StringGrid1BeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure UpdateGrid(filter_type:byte; stroka:string); // ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
    procedure UsrParam();//показать доп инфу
    procedure PresetEdit(); //пресет элементов
    procedure PresetShow(); //пресет элементов
  private
    { private declarations }
  public
    { public declarations }
  end; 


var
  Form_webusr : TForm_webusr;


  //flag_edit_point : integer;
  //result_user, result_usname : string;


implementation
uses
  platproc,main;
{$R *.lfm}

{ TForm_webusr }
var
  fledit,n: integer;
  nrow:integer=0;
  nuser:string='';
  oldopt:string;
  lchange:boolean;


//Отображение
procedure TForm_webusr.PresetShow();
begin
    fledit:=0;
  with Form_webusr do
  begin
   lchange:=false;
   //panel1.Enabled:=false;
     label6.Caption:='';
     Edit2.Text:='';
     Edit3.Text:='';
     Edit4.Text:='';
     Edit6.Text:='';
     Edit7.Text:='';
     label23.Font.Color:=clBlack;
     label23.Caption:='';
     label24.Caption:='';
     combobox1.ItemIndex:=-1;
     combobox1.Text:='';
     CheckBox1.Checked:=false;
     CheckBox2.Checked:=false;
     CheckBox3.Checked:=false;
     CheckBox4.Checked:=false;
     CheckBox5.Checked:=false;
     DateEdit2.Text:='';
     label20.Caption:='';
     BitBtn5.Enabled:=false;
     BitBtn13.Enabled:=false;
     BitBtn9.Enabled:=true;
     BitBtn17.Enabled:=true;
     Spinedit1.Value:=0;
     Spinedit2.Value:=0;
     floatSpinedit1.Value:=0;
  end;
end;

//пресет элементов
procedure TForm_webusr.PresetEdit();
begin
  with Form_webusr do
  begin
     Label6.Caption:=nuser;
     BitBtn5.Enabled:=true;
     BitBtn9.Enabled:=true;
     BitBtn17.Enabled:=true;
     BitBtn13.Enabled:=true;

  end;
end;


//*******************************    Отображение данных пользователей  ************************************************
procedure TForm_webusr.UsrParam();
 var
 timeC : TDateTime;
 nrow,n:integer;
begin
   presetShow();
   with Form_webusr do
     begin
       webid:=0;
       nrow:=Stringgrid1.row;
  If (Stringgrid1.RowCount<2) or (nrow<1) or (Stringgrid1.Cells[1,nrow]='') then exit;
     label6.Caption:=Stringgrid1.Cells[0,nrow];//id
     If trim(label6.Caption)<>'' then
       begin
     try
      webid:=strtoint(Form_webusr.label6.Caption);
     except
      showmessagealt('1.Ошибка преобразования ID web-пользователя !');
      exit;
     end;
       end;

      // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.* ');
       ZQuery1.SQL.add('FROM av_web_users as u ');
       ZQuery1.SQL.add('WHERE u.del=0 AND u.id='+inttostr(webid)+' ORDER BY u.createdate desc limit 1;');

 try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
    exit;
  end;

   if Form_webusr.ZQuery1.RecordCount=0 then
     begin
      Form_webusr.ZQuery1.Close;
      Form_webusr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid

     Edit2.Text:=ZQuery1.FieldByName('fullname').asString;
     Edit3.Text:=Stringgrid1.Cells[1,nrow];
     Edit4.Text:=ZQuery1.FieldByName('passw').asString;
     Edit7.Text:=ZQuery1.FieldByName('tel').asString;
     label23.caption:=Stringgrid1.Cells[3,nrow];
     label24.caption:=Stringgrid1.Cells[4,nrow];
     edit6.text:=ZQuery1.FieldByName('email').asString;   ;//email
     //showmessage(trim(Stringgrid1.Cells[2,nrow]));

     Combobox1.ItemIndex:=Combobox1.Items.IndexOf(trim(Stringgrid1.Cells[2,nrow]));
     //iF ='ПЕРЕВОЗЧИК' then combobox1.ItemIndex:=0;
     //iF trim(Stringgrid1.Cells[2,nrow])='СОТРУДНИК' then combobox1.ItemIndex:=1;
     //try
     //combobox1.ItemIndex:=strtoint(Stringgrid1.Cells[2,nrow])-1;
     //except
     //    showmessagealt('Некорректный тип пользователя !');
     //    exit;
     //end;
     If ZQuery1.FieldByName('status').asInteger=1 then CheckBox1.Checked:=true else CheckBox1.Checked:=false;
     DateEdit2.Text:=formatdatetime('dd-mm-yyyy',ZQuery1.FieldByName('expire').asDatetime);
     label20.Caption:=formatdatetime('dd-mm-yyyy hh:nn:ss',ZQuery1.FieldByName('createdate').asDatetime);   //createdate
     SpinEdit1.Value:=ZQuery1.FieldByName('sale_before').asInteger;
     SpinEdit2.Value:=ZQuery1.FieldByName('percent').asInteger;
     If ZQuery1.FieldByName('sbor').asInteger=1 then
       begin
         CheckBox2.Checked:=true;
         floatSpinEdit1.Value:=ZQuery1.FieldByName('sbor_sum').asfloat;
       end;
     If ZQuery1.FieldByName('trip_zakaz').asInteger=1 then CheckBox3.Checked:=true else CheckBox3.Checked:=false;
     If ZQuery1.FieldByName('trip_transit').asInteger=1 then CheckBox4.Checked:=true else CheckBox4.Checked:=false;
     If ZQuery1.FieldByName('trip_virt').asInteger=1 then CheckBox5.Checked:=true else CheckBox5.Checked:=false;

     ZQuery1.close;
     Zconnection1.disconnect;
   end;
end;


//******************************************************** ОБНОВИТЬ ДАННЫЕ НА ГРИДЕ **********************************
procedure TForm_webusr.UpdateGrid(filter_type:byte; stroka:string);
 var
   n:integer;
  grp,srv,podr: string;
begin
   with Form_webusr do
  begin
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
   //* просто все юзеры
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.* ');
       ZQuery1.SQL.add(',(Select a.name from av_users a where a.del=0 and a.id=u.kod order by a.createdate desc limit 1) uname ');
       ZQuery1.SQL.add('FROM av_web_users as u ');
       ZQuery1.SQL.add('WHERE u.del=0 ');

 //осуществлять контекстный поиск или нет
 If filter_type=1 then
   begin
   ZQuery1.SQL.add('AND ((u.id='+stroka+') OR (u.kod='+stroka+')) '); //OR (u.kodpodr='+stroka+')
   end;
 If filter_type=2 then
   begin
   ZQuery1.SQL.add('AND ((u.login ilike '+Quotedstr(stroka+'%')+') ');
   ZQuery1.SQL.add('OR (u.fullname ilike '+Quotedstr(stroka+'%')+')) ');
   //ZQuery1.SQL.add('OR (UPPER(substr(u.dolg,1,'+inttostr(Utf8length(stroka))+'))=UPPER('+Quotedstr(stroka)+'))) ');
   end;

  ZQuery1.SQL.add('ORDER BY u.id; ');
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

   if Form_webusr.ZQuery1.RecordCount=0 then
     begin
      Form_webusr.ZQuery1.Close;
      Form_webusr.Zconnection1.disconnect;
      exit;
     end;
   // Заполняем stringgrid

   for n:=1 to ZQuery1.RecordCount do
    begin
      StringGrid1.RowCount:=StringGrid1.RowCount+1;
      StringGrid1.Cells[0,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('id').asString;
      StringGrid1.Cells[1,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('login').asString;
      StringGrid1.Cells[2,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('category').asString;
      StringGrid1.Cells[3,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('kod').asString;
      StringGrid1.Cells[4,StringGrid1.RowCount-1]:=ZQuery1.FieldByName('uname').asString;

      ZQuery1.Next;
    end;
   Form_webusr.ZQuery1.Close;
   Form_webusr.Zconnection1.disconnect;
   Stringgrid1.ColWidths[4]:=0;
   Label3.Caption := inttostr(StringGrid1.RowCount-1);
   //Form_webusr.StringGrid1.SetFocus;
   end;
end;


//**************** СОХРАНИТЬ **********************
procedure TForm_webusr.BitBtn5Click(Sender: TObject);
 var
  snol: string;
  n:integer=0;
  lg:boolean=false;
begin
   If fledit=0 then exit;

  with Form_webusr do
   begin
  //проверка заполнения обязательных полей и корректности ввода данных
       //имя

   If (Combobox1.itemindex<0) or (Combobox1.text='') then
     begin
        showmessagealt('Не выбран тип пользователя !');
       exit;
     end;
  //if (trim(Edit2.text)='') then
  //begin
       //showmessagealt('Обязательно для заполнения поле - НАИМЕНОВАНИЕ - пустое !');
       //exit;
   //end;
  if (trim(Edit3.text)='') then
  begin
       showmessagealt('Обязательно для заполнения поле - ЛОГИН - пустое !');
       exit;
   end;
  if (trim(Edit4.text)='') then
  begin
       showmessagealt('Обязательно для заполнения поле - ПАРОЛЬ - пустое !');
       exit;
   end;
  //if (trim(dATEEdit2.text)='') then
  //begin
       //showmessagealt('Обязательно для заполнения поле - АКТИВЕН ДО - пустое !');
       //exit;
   //end;
  //if (label23.caption='') then
  //begin
       //showmessagealt('Обязательно для заполнения поле'+#13+'Пользователь Platforma AV - пустое !');
       //exit;
   //end;
 try
     strtoint(label23.caption);
 except
   //showmessagealt('Ошибка! Поле КОД должно содержать только цифры !');
   label23.Caption:='0';
    //exit;
  end;
//if (trim(Edit4.text)<>trim(Edit5.text)) then
 //begin
      //showmessagealt('ПАРОЛИ НЕ СОВПАДАЮТ !');
      //exit;
  //end;

  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;
    snol:=QuotedStr('');

       If fledit=2 then
         begin
      //****** проверяем на полный дубляж
       ZQuery1.SQL.Clear;
       ZQuery1.Sql.Add('Select id from av_web_users WHERE del=0 AND  ');
       ZQuery1.SQL.add('login='+QuotedStr(trim(edit3.text)));
       //ZQuery1.SQL.add('OR fullname='+QuotedStr(trim(edit2.text)));
       //ZQuery1.SQL.add('OR passw='+QuotedStr(trim(edit4.text)));
       //ZQuery1.SQL.add('OR kod='+label23.caption);
       ZQuery1.SQL.add(';');
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
          showmessagealt('Операция СОХРАНЕНИЯ невозможна !'+#13+'Пользователь с такими параметрами уже существует !');
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
       //If fledit=2 then
       //begin
       // ZQuery1.SQL.Clear;
       // ZQuery1.Sql.Add('Select max(id) from av_web_users;');
       // ZQuery1.Open;
       // If ZQuery1.Fields[0].AsString='' then
       //    begin
       //      nuser:='1';
       //    end
       // else
       // begin
       // nuser:=ZQuery1.Fields[0].AsString;
       // Label6.Caption:=nuser;
       // try
       //   newid := strtoint(nuser)
       // except
       //   showmessagealt('Ошибка ! Некорректное ID !!!');
       //    ZConnection1.Rollback;
       //    exit;
       // end;
       // newid := newid+1;
       // nuser := inttostr(newid);
       // end;
       //end;

   //Если режим редактирования, сначала помечаем запись на удаление
    If fledit=1 then
     begin
        //  try
        //  newid := strtoint(nuser)
        //except
        //  ZConnection1.Rollback;
        //  ZQuery1.Close;
        //  Zconnection1.disconnect;
        //  showmessagealt('Ошибка ! Некорректное ID !!!');
        //   exit;
        //end;

         ZQuery1.SQL.Clear;
         //ZQuery1.SQL.add('UPDATE av_users_group SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         //ZQuery1.ExecSQL;
         //ZQuery1.SQL.Clear;
         //ZQuery1.SQL.add('UPDATE av_users_servers SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         //ZQuery1.ExecSQL;
         //ZQuery1.SQL.Clear;
         //ZQuery1.SQL.add('UPDATE av_users_podr SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND user_id='+nuser+';');
         //ZQuery1.ExecSQL;
         //ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('UPDATE av_web_users SET del=1,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+nuser+';');
         ZQuery1.ExecSQL;
     end;

   //записываем в таблицу юзеров
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('INSERT INTO av_web_users(id,id_user,createdate,login,expire,passw,fullname,email,tel,');
   ZQuery1.SQL.add('category,status,kod,');
   ZQuery1.SQL.add('sale_before,percent,sbor,sbor_sum,trip_zakaz,trip_transit,trip_virt,id_user_first,createdate_first,del) VALUES (');
   ZQuery1.SQL.add(nuser+','+GLuser+',now(),');//id
   ZQuery1.SQL.add(QuotedStr(trim(edit3.text))+','+ QuotedStr(DateEdit2.Text)+',');
   ZQuery1.SQL.add(                                                        QuotedStr(trim(edit4.text))+',');
   ZQuery1.SQL.add(                                                        QuotedStr(trim(edit2.text))+',');
   ZQuery1.SQL.add(                                                        QuotedStr(trim(edit6.text))+',');
   ZQuery1.SQL.add(                                                        QuotedStr(trim(edit7.text))+',');
   ZQuery1.SQL.add(                                                        QuotedStr(trim(ComboBox1.text))+',');
   //активность
   If checkbox1.Checked then
   ZQuery1.SQL.add('1,')
   else ZQuery1.SQL.add('0,');
  ZQuery1.SQL.add(label23.caption+','+inttostr(SpinEdit1.Value)+','+inttostr(SpinEdit2.Value)+',');
  If checkbox2.Checked then
  ZQuery1.SQL.add('true,') else ZQuery1.SQL.add('false,');
  ZQuery1.SQL.add(floattostrf(FloatSpinEdit1.Value,fffixed,10,2)+',');
  If checkbox3.Checked then
  ZQuery1.SQL.add('true,') else ZQuery1.SQL.add('false,');
  If checkbox4.Checked then
  ZQuery1.SQL.add('true,') else ZQuery1.SQL.add('false,');
  If checkbox5.Checked then
  ZQuery1.SQL.add('true,') else ZQuery1.SQL.add('false,');
   //режим добавления
   If fledit=2 then
     ZQuery1.SQL.add(GLuser+',now(),0);');
   //режим редактирования
   If fledit=1 then
     ZQuery1.SQL.add('NULL,NULL,0);');
  //showmessage(ZQuery1.SQL.text);//$
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
  lChange:=false;

  Form_webusr.UpdateGrid(0,'');
  If fledit=1 then
      Form_webusr.StringGrid1.Row := nRow;
  If fledit=2 then
      Form_webusr.StringGrid1.Row := Form_webusr.StringGrid1.RowCount-1;
 Form_webusr.StringGrid1.SetFocus;

end;
end;

//выбрать пользователя
procedure TForm_webusr.BitBtn6Click(Sender: TObject);
begin
  with Form_webusr do
    begin
    form_mode:=4;
      resid:=0;
      FormSpr:=TFormSpr.create(self);
      FormSpr.ShowModal;
      FreeAndNil(FormSpr);

      If resid=0 then exit;
      label23.Font.Color:=clBlack;
      Label23.Caption:=inttostr(resid);
      Label24.Caption:='';
       // Подключаемся к серверу
     If not(Connect2(Zconnection1, flagProfile)) then
       begin
        showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
        exit;
       end;
       //проверка на дубляж

        //****** проверяем на полный дубляж
         ZQuery1.SQL.Clear;
         ZQuery1.Sql.Add('Select name from av_users WHERE del=0 AND id='+inttostr(resid)+' order by createdate desc limit 1; ');
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
             label24.Caption:=ZQuery1.FieldByName('name').AsString;
           end;
         //**************************************************************

     ZQuery1.close;
     Zconnection1.disconnect;
  end;
end;

procedure TForm_webusr.BitBtn7Click(Sender: TObject);
begin
  label23.Font.Color:=clRed;
  label23.Caption:='0';
  label24.Caption:='';
end;

//Печать отчета
procedure TForm_webusr.BitBtn8Click(Sender: TObject);
begin
   formRep:=TformRep.create(self);
   formRep.Showmodal;
   FreeAndNil(formRep);
end;


//****************  ОПЦИИ  *****************
procedure TForm_webusr.BitBtn9Click(Sender: TObject);
begin
  try
   webid:=strtoint(Form_webusr.label6.Caption);
  except
   showmessagealt('2.Ошибка преобразования ID web-пользователя !');
   exit;
  end;
   //webname:=Form_webusr.Edit3.text;
   formU:=TformU.create(self);
   formU.Showmodal;
   FreeAndNil(formU);

end;




//********************************** отфильтровать грид ******************
procedure TForm_webusr.Edit1Change(Sender: TObject);
var
  typ:byte=0;
  ss:string='';
  n:integer=0;
begin
  with Form_webusr do
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
     end;
end;
end;

// выбрать
procedure TForm_webusr.BitBtn2Click(Sender: TObject);
begin
  // проверки *--------------
  //with Form_webusr.StringGrid1 do
  //begin
  //If (trim(Cells[1,Row])='') or (trim(Cells[2,Row])='') then
  //  begin
  //   showmessagealt('Сначала выберите пользователя !');
  //   exit;
  //  end;
  //If (trim(Cells[4,Row])='0') then
  //  begin
  //   showmessagealt('Нельзя выбрать неактивного пользователя!'+#13+'Обратитесь к Администратору системы !');
  //   exit;
  //  end;
  //If (trim(Cells[5,Row])<>'0') then
  //  begin
  //   showmessagealt('Нельзя выбрать удаленного пользователя!'+#13+'Обратитесь к Администратору системы !');
  //   exit;
  //  end;
  ////---------------------------------------------------
  //end;
  // result_user:= Form_webusr.StringGrid1.Cells[0,Form_webusr.StringGrid1.row];
  // result_usname:= Form_webusr.stringgrid1.cells[1,Form_webusr.StringGrid1.Row];
   Form_webusr.close;
end;

procedure TForm_webusr.BitBtn3Click(Sender: TObject);
begin
  Form_webusr.Close;
end;

// показать пароль


//Form_webusr.UpdateGrid(0,'');

//************************************************   УДАЛИТЬ ********************************
procedure TForm_webusr.BitBtn11Click(Sender: TObject);
//var
  //nuser:string='';
begin
  with Form_webusr do
  begin
    nuser:=trim(Stringgrid1.Cells[0,Stringgrid1.Row]);
    If (nuser='') OR (Stringgrid1.rowcount<2) then
    begin
      showmessagealt('Сначала выберите запись для удаления !');
      exit;
      end;
   //Подтверждение
  If MessageDlg('Удаление приведет к обнулению списков '+#13+'опций и перевозчиков данного пользователя !!!'+#13+'Подтверждаете удаление ?',mtConfirmation, mbYesNo, 0)=7 then exit;

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
     ZQuery1.SQL.Clear;
     ZQuery1.Sql.Add('Update av_web_users_kontr set del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id_web='+nuser+';');
    //showmessage(ZQuery1.SQL.Text);//$
     ZQuery1.ExecSQL;

      ZQuery1.SQL.Clear;
     ZQuery1.Sql.Add('Update av_web_users_agent set del=2,createdate=now(),id_user='+gluser+' WHERE del=0 AND id_web='+nuser+';');
    //showmessage(ZQuery1.SQL.Text);//$
     ZQuery1.ExecSQL;

     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('UPDATE av_web_user_options SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id_web='+nuser+';');
      //showmessage(ZQuery1.SQL.Text);//$
     ZQuery1.ExecSQL;

     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('UPDATE av_web_users SET del=2,createdate=now(),id_user='+GLuser+' WHERE del=0 AND id='+nuser+';');
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
 ZQuery1.Close;
 Zconnection1.disconnect;
 UpdateGrid(0,'');
    end;
end;

//************************** ИЗМЕНИТЬ *********************************
procedure TForm_webusr.BitBtn12Click(Sender: TObject);
begin
   nRow:= Form_webusr.StringGrid1.Row;
   fledit:=1;
   nuser:= StringGrid1.Cells[0,StringGrid1.row];
   presetedit();
   Form_webusr.Edit2.SetFocus;
end;

//отмена изменений
procedure TForm_webusr.BitBtn13Click(Sender: TObject);
begin
//    with Form_webusr do
//begin
//
//end;
   PresetShow();
  If fledit=1 then
       Form_webusr.StringGrid1.Row := nRow;
  Form_webusr.StringGrid1.SetFocus;
end;


//перевозчики/пользователи
procedure TForm_webusr.BitBtn17Click(Sender: TObject);
begin
  with Form_webusr do
  begin
  //режим перевозчиков
  If Combobox1.ItemIndex=0 then form_mode:=3;
  //режим агентов
  If Combobox1.ItemIndex>0 then form_mode:=4;

    FormK:=TFormK.create(self);
    FormK.ShowModal;
    FreeAndNil(FormK);
 end;
end;


//***************************** ДОБАВИТЬ ********************************
procedure TForm_webusr.BitBtn10Click(Sender: TObject);
var
  newid:integer=0;
begin
   presetshow();
   fledit:=2;

  with Form_webusr do
  begin
        //если режим добавления  рассчитываем новый id
     // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

        ZQuery1.SQL.Clear;
        ZQuery1.Sql.Add('Select max(id) from av_web_users;');
        ZQuery1.Open;
        If ZQuery1.Fields[0].AsString='' then
           begin
             nuser:='1';
           end
        else
        begin
        nuser:=ZQuery1.Fields[0].AsString;
        try
          newid := strtoint(nuser)
        except
          ZQuery1.close;
          ZConnection1.Disconnect;
          showmessagealt('Ошибка ! Некорректное ID !!!');
           exit;
        end;
        newid := newid+1;
        nuser := inttostr(newid);
        end;
    ZQuery1.close;
    ZConnection1.Disconnect;
  end;


   presetedit();
   Form_webusr.ComboBox1.ItemIndex:=0;
   Form_webusr.DateEdit2.Date:=date()+30;
   Form_webusr.Edit2.SetFocus;

end;


procedure TForm_webusr.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
//********************                    HOT KEYS  ******************************************
  With Form_webusr do
begin
  //поле поиска
  If Edit1.Visible then
    begin
    // ESC поиск // Вверх по списку   // Вниз по списку
  if (Key=27) OR (Key=38) OR (Key=40) then
     begin
       Edit1.Visible:=false;
       StringGrid1.SetFocus;
      exit;
     end;
      // ENTER - остановить контекстный поиск
   if (Key=13) then
     begin
       StringGrid1.SetFocus;
       //exit;
     end;
    end;
    // F1
     if Key=112 then showmessagealt('F1 - Справка'+#13+'F2 - Сохранить'+#13+'F4 - Изменить'+#13+'F5 - Добавить'+#13+'F8 - Удалить'+#13+'ENTER - Выбор'+#13+'ESC - Отмена\Выход');
    //F2 - Сохранить
    if (Key=113) and (bitbtn5.enabled=true) then BitBtn5.Click;
     //F4 - Изменить
    if (Key=115) and (bitbtn12.enabled=true) then BitBtn12.Click;
    //F5 - Добавить
    if (Key=116) then
      begin
           If (bitbtn10.enabled=true) then BitBtn10.Click;
      end;
    //F8 - Удалить
    if (Key=119) then
     begin
        If (bitbtn11.enabled=true) then BitBtn11.Click;
      end;
    //F9 - Доступ
    //if (Key=120) and (bitbtn14.enabled=true) then BitBtn14.Click;
    // ПРОБЕЛ
    if (Key=32) and  (StringGrid1.Focused) then BitBtn2.Click;
    // ESC
    if Key=27 then
      begin
        If BitBtn5.Enabled then BitBtn13.Click
        else BitBtn3.Click;
      end;
    // ENTER
    if (Key=13) and  (StringGrid1.Focused) then BitBtn2.Click;
     if (Key>111) and (Key<124) then Key:=0;

      // Контекcтный поиск
   if Stringgrid1.Focused and (fledit=0) AND (Edit1.Visible=false) then
     begin
       If (get_type_char(key)>0) or (key=8) or (key=46) or (key=96) then //8-backspace 46-delete 96- numpad 0
       begin
         Edit1.text:='';
         Edit1.Visible:=true;
         Edit1.SetFocus;
       end;
     end;
end;
    //if (Key=27) or (Key=32) or (Key=13) then Key:=0;
end;


procedure TForm_webusr.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
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


procedure TForm_webusr.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer  );
begin
  UsrParam();
end;


procedure TForm_webusr.Timer1Timer(Sender: TObject);
begin
  form_webusr.Edit4.PasswordChar:=#42;
  form_webusr.Timer1.Enabled:=false;
end;


procedure TForm_webusr.FormShow(Sender: TObject);
begin
   Centrform(Form_webusr);
   presetShow();
   Form_webusr.UpdateGrid(0,'');
   If Form_webusr.StringGrid1.RowCount>1 then
        Form_webusr.StringGrid1.Row:=Form_webusr.StringGrid1.RowCount-1;
   Form_webusr.StringGrid1.SetFocus;
   //UsrParam();
   {if flag_access=1 then
     begin
      with Form_webusr do
       begin
        BitBtn1.Enabled:=false;
        BitBtn2.Enabled:=false;
        BitBtn12.Enabled:=false;
       end;
     end;
     }
end;

// показать пароль
procedure TForm_webusr.Label9Click(Sender: TObject);
begin
   form_webusr.Edit4.PasswordChar:=#0;
  form_webusr.Timer1.Enabled:=true;
end;

procedure TForm_webusr.StringGrid1BeforeSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
  If lChange then
    begin
       If MessageDlg('Сохранить внесенные изменения ?',mtConfirmation, mbYesNo, 0)=6 then form_webusr.BitBtn5.Click ;
      //exit;
    end;
end;


end.


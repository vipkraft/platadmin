unit Dbf_import;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, Grids,
  IniPropStorage, XMLPropStorage, CheckLst,
  //IniPropStorage,
  LConvEncoding,  Variants,  dbf,  Load_Dbf,
  LazUTF8,
  Unit4,  messages, Types, db;

type

  { TFormDbf }

  TFormDbf = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn32: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    CheckBox1: TCheckBox;
    CheckListBox1: TCheckListBox;
    Dbf1: TDbf;
    Dialog1: TSelectDirectoryDialog;
    Edit8: TEdit;
    Image1: TImage;
    Image3: TImage;
    IniProp: TIniPropStorage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    ProgressBar1: TProgressBar;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn32Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1SetCheckboxState(Sender: TObject; ACol, ARow: Integer;
      const Value: TCheckboxState);
    procedure UpdateGrid(mode: byte);//вывод списка обновляемых таблиц
    procedure ExportALLDBF();// Процедура экспорта таблиц *.DBF в SQL: из 1C
    procedure loadDB();// Процедура экспорта таблиц *.DBF в SQL: из 1C
    procedure update_sprav();
    function ShowTypeField(const curTField : TFieldType) : string;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormDbf: TFormDbf;
  Lexp: Boolean=false;
  //массив названий обновляемых справочников (секций ini файла с настройками обновления)
  arrspr: array of string;

implementation
uses
  main,platproc;

{ TFormDbf }


function TFormDbf.ShowTypeField( const curTField : TFieldType) : string;
begin
 case curTField of
    ftUnknown: Result := 'ftUnknown';
    ftString: Result := 'ftString';
    ftSmallint: Result := 'ftSmallint';
    ftInteger: Result := 'ftInteger';
    ftWord: Result := 'ftWord';
    ftBoolean: Result := 'ftBoolean';
    ftFloat: Result := 'ftFloat';
    ftCurrency: Result := 'ftCurrency';
    ftBCD: Result := 'ftBCD';
    ftDate: Result := 'ftDate';
    ftTime: Result := 'ftTime';
    ftDateTime: Result := 'ftDateTime';
    ftBytes: Result := 'ftBytes';
    ftVarBytes: Result := 'ftVarBytes';
    ftAutoInc: Result := 'ftAutoInc';
    ftBlob: Result := 'ftBlob';
    ftMemo: Result := 'ftMemo';
    ftGraphic: Result := 'ftGraphic';
    ftFmtMemo: Result := 'ftFmtMemo';
    ftParadoxOle: Result := 'ftParadoxOle';
    ftDBaseOle: Result := 'ftDBaseOle';
    ftTypedBinary: Result := 'ftTypedBinary';
    ftCursor: Result := 'ftCursor';
    ftFixedChar: Result := 'ftFixedChar';
    ftWideString: Result := 'ftWideString';
    ftLargeInt: Result := 'ftLargeInt';
    ftADT: Result := 'ftADT';
    ftArray: Result := 'ftArray';
    ftReference: Result := 'ftReference';
    ftDataSet: Result := 'ftDataSet';
    ftOraBlob: Result := 'ftOraBlob';
    ftOraClob: Result := 'ftOraClob';
    ftVariant: Result := 'ftVariant';
    ftInterface: Result := 'ftInterface';
    ftIDispatch: Result := 'ftIDispatch';
    ftGuid: Result := 'ftGuid';
  end;
end;

procedure TFormDbf.update_sprav();
//********************************************** ОБНОВИТЬ ИЗ 1С **************************************************
 var
  slog,szap,comma,stim,ssd,ttabl1,ttabl2: string;
  //widezap: widestring;
  bCH,bDog,bVid,bLic: byte;
  chislo : longint;
  kolvo, n, y: integer;
  sstr:string;
  pos : tpoint;
  //filetxt : TextFile;
begin
  if not(dialogs.MessageDlg('Подтверждаете обновление данных ?',mtConfirmation,[mbYes,mbNO], 0)=6) then
     begin
       exit;
     end;
   bCH:=0;
   bDog:=0;
   bVid:=0;
   bLic:=0;
   kolvo:=0;
   szap:='';
   comma:=',';

   ////log := ExtractFilePath(Application.ExeName)+'spr_update.log';
   //log := 'spr_update.log';
   //AssignFile(filetxt,log);
   //{$I-} // отключение контроля ошибок ввода-вывода
   //////открываем файл лога
   //if FileExistsUTF8(log) then
   //     Append(filetxt) // открытие существулющего файла для записи
   //else
   //     Rewrite(filetxt); // создание и открытие файла для записи
   //{$I+} // включение контроля ошибок ввода-вывода
   //     if IOResult<>0 then // если есть ошибка открытия, то
   //     begin
   //      showmessagealt('Ошибка записи лога !');
   //      Exit;
   //     end;
  with FormDbf do
   begin
     Memo1.Clear;
   formmain.wlog(Memo1,' ');
  FormMain.wlog(Memo1,'@@@@@@@@@@@@@@@@@@@@@@@@    ОБНОВЛЕНИЕ СПРАВОЧНИКОВ   @@@@@@@@@@@@@@@@@@@@@@@@@');
  FormMain.wlog(Memo1,'|||||||||||||||||||||    '+datetostr(date)+'  '+timetostr(time)+'  '+'      |||||||||||||||||||||');
  FormMain.wlog(Memo1,' обновление проводил пользователь с id= '+GLuser);


    //Memo1.Append('=================  Подлключаемся к базе данных ... ===============================');
   FormMain.wlog(Memo1,'=================  Подлключаемся к базе данных ... ===============================');
    Memo1.Append('-----------------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с основным сервером потеряно !'+#13+'Проверьте соединение и/или'+#13+' обратитесь к администратору.');
      Close;
      exit;
     end;

  FormMain.wlog(Memo1,'=================  Начат процесс ОБНОВЛЕНИЯ ! ПОДОЖДИТЕ ... ===============================');
   Memo1.Append('-----------------:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
    // Ставим курсов в конец строки
   //Memo1.SetFocus;
   //pos.x:=Utf8Length(memo1.Lines[memo1.CaretPos.x])-1;
   //pos.y:=memo1.Lines.Count-1;
   //Memo1.CaretPos:=pos;


//Идем по гриду
   for y:=1 to Stringgrid1.RowCount-1 do
    begin

       //showmessage(StringGrid1.Cells[2,y]);
      If (StringGrid1.Cells[2,y]<>'1') then continue;
     FormMain.wlog(Memo1,'count...'+inttostr(y));
//****************************************************************  обновление контрагентов **************
If (trim(Stringgrid1.Cells[0,y])='av_spr_kontragent') then
  begin
   //Memo1.Append('Обновление справочника контрагентов...');
  FormMain.wlog(Memo1,'Обновление справочника контрагентов...');

  //ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   IniProp.IniSection:='AV_SPR_KONTRAGENT';
   ZQuery1.SQL.add('SELECT upd_spr_1c_kontr_new(''tnew'','+quotedstr(IniProp.ReadString('loading_table','av_1c_contr'))+','+gluser+');');
   ZQuery1.SQL.add('FETCH all in tnew;');
  //showmessage(ZQuery1.SQL.Text);//$
   try
    ZQuery1.Open;
   except
    //Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    FormMain.wlog(Memo1,'ОШИБКА !!!'+#13+'Запрос SQL: '+#13+ZQuery1.SQL.Text);
    break;
   end;
   kolvo:=ZQuery1.RecordCount;
   if kolvo>0 then
   begin
    slog:='КОНТРАГЕНТЫ. Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ:';
     //Memo1.Append(slog);
    FormMain.wlog(Memo1,slog);
       ZQuery1.First;
       for n:=1 to kolvo do
        begin
           slog:= ZQuery1.FieldByName('id').AsString+' - '+ZQuery1.FieldByName('name').AsString+', kod1c: '+ZQuery1.FieldByName('kod1c').AsString;
          FormMain.wlog(Memo1,slog);
           ZQuery1.Next;
        end;
  end
   else
   begin
     slog:='КОНТРАГЕНТЫ. Новых записей НЕ обнаружено!';
     //Memo1.Append(slog);
    FormMain.wlog(Memo1,slog);
   end;

   //ищем отредактированные в 1с   ********************************************************
   ZQuery1.SQL.Clear;
    IniProp.IniSection:='AV_SPR_KONTRAGENT';
   ZQuery1.SQL.add('SELECT upd_spr_1c_kontr_edit(''tedit'','+quotedstr(IniProp.ReadString('loading_table','av_1c_contr'))+','+gluser+');');
   ZQuery1.SQL.add('FETCH all in tedit;');
  //showmessage(ZQuery1.SQL.Text);//$
   try
    ZQuery1.Open;
   except
      FormMain.wlog(Memo1,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
      break;
   end;
   kolvo:=ZQuery1.RecordCount;
   if kolvo>0 then
   begin
    slog:='КОНТРАГЕНТЫ. Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ:';
    FormMain.wlog(Memo1,slog);
       ZQuery1.First;
       for n:=1 to kolvo do
        begin
           slog:= ZQuery1.FieldByName('id').AsString+' - '+ZQuery1.FieldByName('name').AsString+', kod1c: '+ZQuery1.FieldByName('kod1c').AsString;
          FormMain.wlog(Memo1,slog);
           ZQuery1.Next;
        end;
  end
   else
   begin
     slog:='КОНТРАГЕНТЫ. Измененных записей НЕ обнаружено!';
     //Memo1.Append(slog);
    FormMain.wlog(Memo1,slog);
   end;
  end;

 //****************************************************************  обновление ДОГОВОРОВ **************
If (trim(Stringgrid1.Cells[0,y])='av_spr_kontr_dog') then
  begin
   //Memo1.Append('Обновление справочника контрагентов...');
  FormMain.wlog(Memo1,'Обновление справочника договоров.');

  //ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   IniProp.IniSection:='AV_SPR_KONTR_DOG';
   ZQuery1.SQL.add('SELECT upd_spr_1c_dog_new(''tnew'','+quotedstr(IniProp.ReadString('loading_table','av_1c_dog'))+','+gluser+');');
   ZQuery1.SQL.add('FETCH all in tnew;');
  //showmessage(ZQuery1.SQL.Text);//$
   try
    ZQuery1.Open;
   except
    //Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
   FormMain.wlog(Memo1,'ОШИБКА !!!'+#13+'Запрос SQL: '+#13+ZQuery1.SQL.Text);
    break;
   end;
   kolvo:=ZQuery1.RecordCount;
   if kolvo>0 then
   begin
    slog:='ДОГОВОРА. Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ:';
     //Memo1.Append(slog);
    FormMain.wlog(Memo1,slog);
       ZQuery1.First;
       for n:=1 to kolvo do
        begin
           slog:= ZQuery1.FieldByName('id').AsString+' - '+ZQuery1.FieldByName('name').AsString+', kodkont: '+ZQuery1.FieldByName('kodkont').AsString;
           //Memo1.Append(slog);
          FormMain.wlog(Memo1,slog);
           ZQuery1.Next;
        end;
  end
   else
   begin
     slog:='ДОГОВОРА. Новых записей НЕ обнаружено!';
     //Memo1.Append(slog);
    FormMain.wlog(Memo1,slog);
   end;

   //ищем отредактированные в 1с   ********************************************************
   ZQuery1.SQL.Clear;
   IniProp.IniSection:='AV_SPR_KONTR_DOG';
   ZQuery1.SQL.add('SELECT upd_spr_1c_dog_edit(''tedit'','+quotedstr(IniProp.ReadString('loading_table','av_1c_dog'))+','+gluser+');');
   ZQuery1.SQL.add('FETCH all in tedit;');
  //showmessage(ZQuery1.SQL.Text);//$
   try
    ZQuery1.Open;
   except
   FormMain.wlog(Memo1,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
    break;
   end;
   kolvo:=ZQuery1.RecordCount;
   if kolvo>0 then
   begin
    slog:='ДОГОВОРА. Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ:';
    FormMain.wlog(Memo1,slog);
       ZQuery1.First;
       for n:=1 to kolvo do
        begin
           slog:= ZQuery1.FieldByName('id').AsString+' - '+ZQuery1.FieldByName('name').AsString+', kodkont: '+ZQuery1.FieldByName('kodkont').AsString;
           //Memo1.Append(slog);
          FormMain.wlog(Memo1,slog);
           ZQuery1.Next;
        end;


  end
   else
   begin
     slog:='ДОГОВОРА. Измененных записей НЕ обнаружено!';
     FormMain.wlog(Memo1,slog);
   end;
  end;
//************************************************************************************************************
  ZQuery1.close;
  Zconnection1.disconnect;
    end;


 FormMain.wlog(Memo1,'================= ОБНОВЛЕНИЕ СПРАВОЧНИКОВ. КОНЕЦ. ============================');

 end;
 //закончили идти по гриду
  UpdateGrid(1);
end;


//обновление списка обновляемых таблиц
procedure TFormDBF.UpdateGrid(mode: byte);
 //mode = 0  --до обновления
 //mode = 1 --после обновления
 var
   n,m:integer;
 begin
    If mode=0 then
        begin
         FormDBF.StringGrid1.RowCount:=1;
         FormDBF.StringGrid1.RowCount:=FormDBF.StringGrid1.RowCount+5;
         FormDBF.StringGrid1.Cells[0,1]:='av_spr_kontragent';
         FormDBF.StringGrid1.Cells[0,2]:='av_spr_kontr_dog';
         FormDBF.StringGrid1.Cells[0,3]:='av_spr_kontr_viddog';
         FormDBF.StringGrid1.Cells[0,4]:='av_spr_kontr_license';
         FormDBF.StringGrid1.Cells[0,5]:='av_users';
        end;
     //exit;
  //Соединяемся с сервером
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

   for n:=1 to Stringgrid1.RowCount-1 do
    begin
     //Текущий Список таблиц ЦС
   FormDBF.ZQuery1.SQL.clear;
   FormDBF.ZQuery1.SQL.add('SELECT table_name ');
   FormDBF.ZQuery1.SQL.add(',(SELECT c.description FROM pg_description AS c WHERE c.objoid = (select a.oid FROM pg_class a WHERE a.relname=table_name limit 1) limit 1) rem ');
   //FormDBF.ZQuery1.SQL.add(',(SELECT a.reltuples FROM pg_class a where a.relname=table_name) as nrows ');
   FormDBF.ZQuery1.SQL.add(',(SELECT count(id_user) FROM '+(formDbf.StringGrid1.Cells[0,n])+') as nrows ');
   FormDBF.ZQuery1.SQL.add('    FROM information_schema.tables ');
   FormDBF.ZQuery1.SQL.add('WHERE table_type = ''BASE TABLE'' ');
   FormDBF.ZQuery1.SQL.add('AND table_name = '+quotedstr(formDbf.StringGrid1.Cells[0,n]));
   //FormDBF.ZQuery1.SQL.add('AND substring(table_name,1,9) = ''av_spr_ko'' ');
   FormDBF.ZQuery1.SQL.add('    AND table_schema NOT IN ');
   FormDBF.ZQuery1.SQL.add('        (''pg_catalog'', ''information_schema'') ');
   FormDBF.ZQuery1.SQL.add('        order by table_name ');
  //showmessage(FormDBF.ZQuery1.SQL.Text);//$
   try
    FormDBF.ZQuery1.Open;
   except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    FormDBF.ZQuery1.Close;
    FormDBF.Zconnection1.disconnect;
    continue;
   end;

 if FormDBF.ZQuery1.RecordCount<1 then continue;

 // Заполняем Stringgrid
     //FormDBF.StringGrid1.Cells[0,n]:=trim(FormDBF.ZQuery1.FieldByName('table_name').asString);
     FormDBF.StringGrid1.Cells[1,n]:=trim(FormDBF.ZQuery1.FieldByName('rem').asString);

     formDbf.IniProp.IniSection:=FormDBF.StringGrid1.Cells[0,n];
     //Считать галочку об обновлении
     If mode=0 then
       begin
        FormDBF.StringGrid1.Cells[2,n]:=formDbf.IniProp.ReadString('update_check','0');
        //кол-во записей до обновления
        FormDBF.StringGrid1.Cells[3,n]:=FormDBF.ZQuery1.FieldByName('nrows').asString
       end;

   If mode=1 then
      begin
        IniProp.WriteString('update_check',FormDBF.StringGrid1.Cells[2,n]);
        FormDBF.StringGrid1.Cells[4,n]:=FormDBF.ZQuery1.FieldByName('nrows').asString;
     //If n>0 then FormDBF.StringGrid1.Cells[2,n+1]:='*';
     //ZQuery1.Next;
      end;
     end;
   FormDBF.ZQuery1.Close;
   FormDBF.Zconnection1.disconnect;
   FormDBF.StringGrid1.Repaint;
end;



//******************************* Процедура экспорта таблиц *.DBF в SQL: из 1C  *******************************************
procedure TformDbf.loadDB();
const maxt = 50;
 var
    //j: variant;
    //k,t_mem,t_sql,strsql,
    sourceDB, imptable, stmp:string;
    dlines, i, n, k, j:integer;
    dbcreate:boolean;
    //myt :TFieldType;
begin
   with FormDbf do
    begin

  FormMain.wlog(FormDbf.Memo1,'=============== Загрузка файлов DBF в SQL Platforma. НАЧАЛО ============');
    //1.Соединяемся с сервером SQL
       // Подключаемся к серверу
      If not(Connect2(formDbf.Zconnection1, flagProfile)) then
        begin
           FormMain.wlog(FormDbf.Memo1,'Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
           exit;
           //DBF1.Active:=false;
          end;
       FormMain.wlog(FormDbf.Memo1,'Соединение с сервером SQL - УСТАНОВЛЕНО !');


 for i:=low(arrspr) to high(arrspr) do
   begin
     //считываем секцию настроек
      IniProp.IniSection:=arrspr[i];
      //проверяем необходимость загрузки файла
      If IniProp.ReadBoolean('upload_check',false)=false then continue;

     FormMain.wlog(FormDbf.Memo1,'---- Обновление  '+arrspr[i]+' Начало ----------');

    sourceDB:=IniProp.ReadString('source_file','');
    If sourceDb='' then continue;
    if not fileexistsUTF8(IncludeTrailingPathDelimiter(formDbf.edit8.Text)+sourceDB+'.DBF') then
      begin
        FormMain.wlog(FormDbf.Memo1,'----!!! Не найден файл '+sourceDB+'.dbf ----------');
       continue;
      end;
      dlines:=0;
    //TDBF
     //DBF1.FilePath:=IncludeTrailingPathDelimiter(formDbf.edit8.Text);
     DBF1.FilePathFull:=IncludeTrailingPathDelimiter(formDbf.edit8.Text);
     DBF1.TableLevel := 4;
     DBF1.Exclusive := True;
     DBF1.tablename:=sourceDB+'.DBF';
     DBF1.Active:=true;

     FormMain.wlog(FormDbf.Memo1,'++++++++ Загрузка файла  '+IncludeTrailingPathDelimiter(formDbf.edit8.Text)+sourceDB+'.dbf ++++ Начало ++++');

     //for n:=0 to Dbf1.FieldCount-2 do
     //   stmp:= stmp+(Dbf1.Fields[n].FieldName)+',';
     //stmp:= stmp + Dbf1.Fields[Dbf1.FieldCount-1].FieldName;
     //showmessage(stmp);

     //Количество записей
     dlines:=DBF1.ExactRecordCount;
     FormMain.wlog(FormDbf.Memo1,'+++++Всего записей в файле '+sourcedb+':  '+inttostr(dlines));
     //formDbf.Memo1.Refresh;

     imptable:='av_1c_'+UTF8LowerCase(sourcedb);

      //проверка на наличие таблицы импорта в базе
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('SELECT 1 as tt FROM pg_tables WHERE tablename='+quotedstr(imptable)+';');
       try
          ZQuery1.open;
          except
             FormMain.wlog(FormDbf.Memo1,'ОШИБКА SQL запроса!!!!'+#13+formDbf.ZQuery1.SQL.Text);
             DBF1.Active:=false;
             continue;
          end;
     dbcreate:=false;

     If ZQuery1.RecordCount<1
        then dbcreate:=true
        else If ZQuery1.FieldByName('tt').AsInteger<>1 then
          dbcreate:=true;
     //создаем таблицу снуля
     If dbcreate then
       begin
         ZQuery1.SQL.Clear;
         ZQuery1.SQL.add('CREATE TABLE '+imptable);
         ZQuery1.SQL.add('(');
       for n:=0 to Dbf1.FieldCount-2 do
         //ZQuery1.SQL.add(Dbf1.Fields[n].FieldName+' character(300) NOT NULL, ');
         //ZQuery1.SQL.add(Dbf1.Fields[Dbf1.FieldCount-1].FieldName+' character(300) NOT NULL ');
         ZQuery1.SQL.add(Dbf1.Fields[n].FieldName+' text NOT NULL default '''', ');
         ZQuery1.SQL.add(Dbf1.Fields[Dbf1.FieldCount-1].FieldName+' text NOT NULL default '''' ');
         ZQuery1.SQL.add(') WITH (OIDS=FALSE);');
         ZQuery1.SQL.add('ALTER TABLE '+imptable+' OWNER TO platforma;');
         try
          ZQuery1.execsql;
          except
             FormMain.wlog(FormDbf.Memo1,'ОШИБКА SQL запроса!!!!'+#13+formDbf.ZQuery1.SQL.Text);
             DBF1.Active:=false;
             continue;
          end;
          FormMain.wlog(FormDbf.Memo1,'-------Создание таблицы '+imptable+' . УСПЕШНО !-------');
       end;

      //СОХРАНЯЕМ ДАННЫЕ НАЗВАНИЯ ТАБЛИЫ В INI
      IniProp.WriteString('loading_table',imptable);

   //Удаляем все записи
          formDbf.ZQuery1.SQL.Clear;
          formDbf.ZQuery1.SQL.add('Truncate '+imptable+';');
          try
          formDbf.ZQuery1.execSQL;
          except
             FormMain.wlog(FormDbf.Memo1,'ОШИБКА SQL запроса!!'+#13+formDbf.ZQuery1.SQL.Text);
             DBF1.Active:=false;
             continue;
          end;

          formDbf.ZQuery1.SQL.Clear;

         FormMain.wlog(FormDbf.Memo1,'-------Очистка таблицы '+imptable+' . УСПЕШНО !-------');

         FormMain.wlog(FormDbf.Memo1,'-------Загрузка данных в таблицу импорта. НАЧАЛО------');

   //Сканируем *.dbf
   //DBF1.First;
   //DBF1.DisableControls;

   //Прогресс бар
   formDbf.ProgressBar1.Max:=dlines;
   formDbf.ProgressBar1.Position:=0;
   k:=0;

   FormDbf.Memo1.Clear;                                               // clear the memo box
   //FormDbf.Memo1.Append('Всего строчек в dbf: '+inttostr(Dbf1.RecordCount));
   //Dbf1.AddIndex('DATAPOG', 'DTOS(DATAPOG)', []);
   //Dbf1.FilterOptions := [foCaseInsensitive];                   // set FilterOptions before Filter !
   //Dbf1.Filter := 'DTOS(datapog) =' + QuotedStr('20180402');

   //Dbf1.Filter := 'otcblm<>0';
   //Dbf1.Filtered := true;       // This selects the filtered set

   Dbf1.First;                  // moves the the first filtered data
//   while not DBF1.Eof do          // prints the titles that match the author to the memo box
//begin
//  FormDbf.memo1.Append(Dbf1.FieldByName('datapog').asstring+'|'+floattostrf(Dbf1.FieldByName('otcblm').AsFloat,fffixed,5,2));
//  dbf1.next;                                                 // use .next here NOT .findnext!
//end;
//  FormDbf.Memo1.Append(inttostr(memo1.Lines.Count-1));
//  DBF1.Active:=false;
// //Dbf1.Close;
//exit;
    dlines:=0;

   // Формируем строки SQL
   //for j:=0 to 100 do
  while not DBF1.Eof do
     begin
       //фильтруем по полю дата погашения договора
      for n:=0 to Dbf1.FieldCount-2 do
        begin
          If (Dbf1.Fields[n].FieldName)='datapog' then
            begin
             If (not Dbf1.FieldByName('datapog').isNull) and (Dbf1.FieldByName('datapog').Value < strtodate('02.04.2018'))
                then begin
                Dbf1.Next;
                continue;
                end;
            end;
       //If  ShowTypeField(Dbf1.FieldByName('datapog').DataType)='ftDate' then
           //If Dbf1.FieldByName('datapog').Value=NULL then
                    //memo1.append(datetostr(Dbf1.FieldByName('datapog').Value));
        end;


       inc(k);
       //If k>49 then break;//$
       formDbf.ProgressBar1.stepit;
       formDbf.ProgressBar1.Refresh;
     //****************** ПИШЕМ ПАРТИЯМИ ПО n-СТРОЧЕК
       If k=1 then
         begin
         application.ProcessMessages;
         //strsql:='';

         // Формируем первоначальную строку INSERT
         ZQuery1.SQL.add('INSERT INTO '+imptable+'(');
         //определяем заголовки dbf колонок
         stmp:='';
         for n:=0 to Dbf1.FieldCount-2 do
          stmp:= stmp+(Dbf1.Fields[n].FieldName)+',';
         stmp:= stmp + Dbf1.Fields[Dbf1.FieldCount-1].FieldName;

        If checkbox1.Checked and (k=1) then
           //Memo1.Append(stmp);
           FormMain.wlog(FormDbf.Memo1,stmp);
        ZQuery1.SQL.add(stmp);
        ZQuery1.SQL.add(') VALUES (');
         end;
        ///*************************

        If (k>1) and (k<=maxt) then ZQuery1.SQL.add('), (');

        stmp:='';
        for n:=0 to Dbf1.FieldCount-1 do
          begin
             If Dbf1.Fields[n].Value=NULL then
               stmp:=stmp+ quotedstr('')
             else
               begin
                  If  ShowTypeField(Dbf1.Fields[n].DataType)='ftFloat' then
                    stmp:= stmp+floattostrf(Dbf1.Fields[n].AsFloat,fffixed,5,2)
                    else
                    stmp:= stmp+quotedstr(trim(Dbf1.Fields[n].Text));

               end;
           If n<(Dbf1.FieldCount-1) then
               stmp:=stmp+',';
          end;

        If checkbox1.Checked then
          //Memo1.Append(CP1251ToUTF8(stmp));
          FormMain.wlog(FormDbf.Memo1,CP1251ToUTF8(stmp));

        ZQuery1.SQL.add(CP1251ToUTF8(stmp));
        inc(dlines);
        //ZQuery1.SQL.add((stmp));

       //отображаем запрос в мемо
       //if formDbf.CheckBox1.Checked then
       begin
        //Memo1.Append(strsql2+ '''');
        //formDbf.Memo1.Refresh;
       end;

  // ********* Пишем в базу
    //2.Выполняем SQL запрос Insert
      If k=maxt then
        begin
          ZQuery1.SQL.add(');');
           try
              ZQuery1.ExecSQL;
            except
              FormMain.wlog(FormDbf.Memo1,'ОШИБКА  ЗАПРОСА !!!'+#13+ ZQuery1.SQL.Text);
              DBF1.Active:=false;
              break;
            end;
            FormMain.wlog(FormDbf.Memo1,formatdatetime('hh:mm:ss.zzz',now())+'---Запись '+inttostr(k)+' записей в таблицу импорта. УСПЕШНО. ');
            ZQuery1.SQL.Clear;
            k:=0;
         end;
     //////////////////////////////////////////////////////
       //Следующая строка
       DBF1.Next;
      end;

   //дописываем остаток данных
   If (k>0) and dbf1.Active then
     begin
      ZQuery1.SQL.add(');');
           try
              ZQuery1.ExecSQL;
            except
              FormMain.wlog(FormDbf.Memo1,'ОШИБКА  ЗАПРОСА !!!'+#13+ ZQuery1.SQL.Text);
              DBF1.Active:=false;
              break;
            end;
       FormMain.wlog(FormDbf.Memo1,'---Запись '+inttostr(k)+' записей в таблицу импорта. УСПЕШНО. ');
     end;

       FormMain.wlog(FormDbf.Memo1,'-**-ВСЕГО '+inttostr(dlines)+' записей внесено в таблицу. ');

      If DBF1.Active then
         FormMain.wlog(FormDbf.Memo1,'============================== '+sourceDB+' УСПЕШНО ЗАГРУЖЕН =====================================');
      DBF1.EnableControls;
      //Освобождаем TDBF
      DBF1.Active:=false;
      DBF1.close;
 end;
  //отключаемся
    ZQuery1.Close;
    Zconnection1.disconnect;
 Memo1.Append('============================== ЗАГРУЗКА ДАННЫХ ИЗ ФАЙЛОВ DBF. КОНЕЦ =====================================');
 formDbf.ProgressBar1.Position:=0;
 formDbf.ProgressBar1.Refresh;

end;
end;

procedure TFormDbf.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
   with Sender as TStringGrid, Canvas do
    begin

       if (gdSelected in aState) then
           begin
            Brush.Color:=clCream;
            FillRect(aRect);
            pen.Width:=4;
            pen.Color:=clGray;
            MoveTo(aRect.left,aRect.bottom-1);
            LineTo(aRect.right,aRect.Bottom-1);
            MoveTo(aRect.left,aRect.top-1);
            LineTo(aRect.right,aRect.Top);
           end
         else
          begin
            Brush.Color:=clWhite;
            FillRect(aRect);
          end;

      // Наименование таблиц
      if (aRow>0) and (aCol=0) then
         begin
          font.Size:=14;
          font.Color:=clBlack;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;

      // Синхронизация
      if (aRow>0) and (aCol=2) then
         begin
          font.Size:=16;
          font.Color:=clRed;
          if trim(Cells[aCol, aRow])='1' then
             Brush.Color:=clRed
             else
                Brush.Color:=clWhite;
          Fillrect(aRect);
           pen.Width:=1;
           pen.Color:=clGray;
           MoveTo(aRect.left,aRect.bottom-1);
           LineTo(aRect.right,aRect.Bottom-1);
          //TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;


       // Остальные поля
      if (aRow>0) and (aCol<>0) and (aCol<>2) then
         begin
          font.Size:=12;
          font.Color:=clBlack;
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
         end;

       // Заголовок
       if aRow=0 then
         begin
           Brush.Color:=clWhite;
           FillRect(aRect);
           Font.Color := clBlack;
           font.Size:=10;
           TextOut(aRect.Left + 3, aRect.Top+4, Cells[aCol, aRow]);
          end;
    end;
end;

procedure TFormDbf.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
    //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  //If (aCol<>2) then CanSelect:= false;
end;

procedure TFormDbf.StringGrid1SetCheckboxState(Sender: TObject; ACol,
  ARow: Integer; const Value: TCheckboxState);
begin
  //If Value.cbChecked then StringGrid1.Cells[aCol,Arow]:='*' else StringGrid1.Cells[aCol,Arow]:='';
  // with FormDbf do
  //begin
  //if (StringGrid1.Col=2) and (StringGrid1.row>0) and (StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]='') then
  //   StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:='*'
  //else StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:='';
  //end;
end;


//******************************* Процедура экспорта таблиц *.DBF в SQL: из 1C  *******************************************
procedure TformDbf.ExportALLDBF();
 var
    tmp_file_1,local_dbf_txt,local_dbf_txt2:TextFile;
    j: variant;
    k,t_mem,t_sql,strTemp,strsql,strsql2,strsql3,t_str: string;
    t_kodotd,t_kodpodr,t_name,t_fullname,t_adress,sss: string;
    List:TStringList;
    n_tmp,ind,i,tmp_i,kol_strok,ttt:integer;
    tmp_array:array of array of widestring;
    mas1:Array of String;
    mas2:Array of String;
    SQL_TABLE,SQL_DELETE:string;
    dlines:integer;
begin
 with FormDbf do
  begin
    formDbf.Repaint;
    // Ищем основной файл настроек
    Memo1.Append('=======================================================================');
    Memo1.Append('Проверяем наличие файла настроек выгрузки list_dbf.txt');
    if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf.txt') then
     begin
       Memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - OK');
     end
  else
     begin
      Memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - Файл отсутствует');
      Memo1.Append('=======================================================================');

      exit;
     end;
  Memo1.Append('Считываем данные из list_dbf.txt...');
  // проверяем что есть список DBF
  if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf.txt')=0 then
   begin
    Memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf.txt'+' - Файл пустой !');
    Memo1.Append('=======================================================================');

    exit;
   end;
  //проверяем что хоть что то выбрано
    if not(FileExistsUTF8(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt')) then
     begin
      Memo1.Append('Нет файла выбранного списка для загрузки listbox_dbf.txt !');
      Memo1.Append('=======================================================================');

      exit;
     end;
    if  kol_row_file(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt')=0 then
      begin
        Memo1.Append('Нет выбранных файлов для загрузки !');
        Memo1.Append('=======================================================================');

        exit;
      end;

    //Создаем массив с загружаемыми и выбранными DBF
     AssignFile(local_dbf_txt,ExtractFilePath(Application.ExeName)+'listbox_dbf.txt');
     reset(local_dbf_txt);
     AssignFile(local_dbf_txt2,ExtractFilePath(Application.ExeName)+'list_dbf.txt');
     reset(local_dbf_txt2);

     // Загружаем список всех доступных DBF в mas1
     SetLength(mas1, kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf.txt'));
     ind:=-1;
     while not Eof(local_dbf_txt2) do
        begin
          ind:=ind+1;
          readln(local_dbf_txt2,t_str);
          mas1[ind]:=t_str;
        end;
     closefile(local_dbf_txt2);
     SetLength(mas2, kol_row_file(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt'));
     ind:=-1;
     while not Eof(local_dbf_txt) do
        begin
          ind:=ind+1;
          readln(local_dbf_txt,t_str);
          mas2[ind]:=mas1[strtoint(t_str)];
        end;
        closefile(local_dbf_txt);


 for i:=low(mas2) to high(mas2) do
   begin
     dlines:=0;
    SQL_TABLE:=copy(mas2[i],1,length(mas2[i])-4);
   // Ищем локальный файл настроек
   Memo1.Append('Проверяем наличие файла локальных настроек выгрузки list_dbf_'+SQL_TABLE+'.DBF.txt');
     if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') then
      begin
        Memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt'+' - OK');
      end
   else
      begin
       Memo1.Append(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt'+' - Файл отсутствует');
       Memo1.Append('=======================================================================');

       exit;
      end;
     Memo1.Append('Считываем данные из list_dbf'+SQL_TABLE+'.DBF.txt...');

   // Определяем количество перебрасываемых полей
   if kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt')=0 then
     begin
       Memo1.Append('Нет данных в list_dbf_'+SQL_TABLE+'.DBF.txt - ОШИБКА');
       Memo1.Append('=======================================================================');

       exit;
     end;

   // Определяем динамический масси с настройками полей и заполняем его
   SetLength(tmp_array,0,0);
   n_tmp:=(kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') div 4);
   SetLength(tmp_array,n_tmp,4);
  // showmessage(IntToStr(length(tmp_array)));
   AssignFile(tmp_file_1, ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt');
   Reset(tmp_file_1);
   n_tmp:=-1;
   while not Eof(tmp_file_1) do
        begin
          Readln(tmp_file_1,strTemp);
          //If n_tmp>41 then  sss:=sss+strTemp;
          n_tmp:=n_tmp+1;
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,1]:=trim(strTemp);
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,2]:=trim(strTemp);
          Readln(tmp_file_1,strTemp);
          tmp_array[n_tmp,3]:=trim(strTemp);
          //If n_tmp>41 then sss:=sss+'| '+tmp_array[n_tmp,1]+'| '+tmp_array[n_tmp,2]+'| '+tmp_array[n_tmp,3]+#13;
        end;
    closefile(tmp_file_1);
        //showmessagealt(sss);

    //TDBF
     formDbf.dbf1.FilePath:=IncludeTrailingPathDelimiter(formDbf.edit8.Text);
     formDbf.dbf1.FilePathFull:=IncludeTrailingPathDelimiter(formDbf.edit8.Text);
     formDbf.dbf1.tablename:=SQL_TABLE+'.DBF';
     formDbf.dbf1.Active:=true;
     //Количество записей
     dlines:=formDbf.Dbf1.ExactRecordCount;
     Memo1.Append('Всего записей в DBF: '+inttostr(dlines));
     formDbf.Memo1.Refresh;

   //Определяем SQL_DELETE
   SQL_DELETE:='';
   if not(FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt')) then
     begin
       Memo1.Append('Нет файла настроек операции для '+ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF2.txt');
       Memo1.Append('Продолжение невозможно - ВЫХОД !!!');
       Memo1.Append('=======================================================================');

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

      //1.Соединяемся с сервером SQL
       // Подключаемся к серверу
      If not(Connect2(formDbf.Zconnection1, flagProfile)) then
        begin
          showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
          exit;
           formDbf.dbf1.Active:=false;
           Memo1.Append('=======================================================================');

          end;
      Memo1.Append('Соединение с сервером SQL - УСТАНОВЛЕНО !');

   //Удаляем все записи
   if not(SQL_DELETE = '') then
     begin
          formDbf.ZQuery1.SQL.Clear;
          formDbf.ZQuery1.SQL.add(SQL_DELETE);
          try
          formDbf.ZQuery1.execSQL;
          Memo1.Append('Выполнение '+SQL_DELETE+' - OK');
          except
             Memo1.Append('ОШИБКА SQL запроса!!'+#13+formDbf.ZQuery1.SQL.Text);
             formDbf.dbf1.Active:=false;
             Memo1.Append('=======================================================================');

             exit;
          end;
     end
   else
       begin
       Memo1.Append('ОШИБКА ! В файле list_dbf_'+SQL_TABLE+'.DBF2.txt не найдено строки запроса !');
       formDbf.dbf1.Active:=false;
       Memo1.Append('=======================================================================');

       exit;
       end;


   Memo1.Append('Производим добавление новых записей...');

   //Сканируем *.dbf
   formDbf.DBF1.First;
   formDbf.DBF1.DisableControls;

   //Прогресс бар
   formDbf.ProgressBar1.Max:=dlines;
   formDbf.ProgressBar1.Position:=0;
   // Формируем строки SQL
   while not formDbf.DBF1.Eof do
     begin
       formDbf.ProgressBar1.stepit;
       formDbf.ProgressBar1.Refresh;
       strsql:='';
       formDbf.ZQuery1.SQL.Clear;
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
       formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql2));
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
             formDbf.ZQuery1.SQL.add(CP1251ToUTF8(trim(t_str)));
             strsql3:=strsql3+t_str;
          end;
          if tmp_i<(kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt') div 4) then
            begin
             formDbf.ZQuery1.SQL.add(CP1251ToUTF8(','));
             strsql3:=strsql3+',';
            end;
          readln(local_dbf_txt,t_str);
          readln(local_dbf_txt,t_str);
          readln(local_dbf_txt,t_str);
        end;
        closefile(local_dbf_txt);
        formDbf.ZQuery1.SQL.add(CP1251ToUTF8(') VALUES ('));
        strsql3:=strsql3+') VALUES (';

       strsql2:=CP1251ToUTF8(strsql3);
       strsql2:='';

       kol_strok:=kol_row_file(ExtractFilePath(Application.ExeName)+'list_dbf_'+SQL_TABLE+'.DBF.txt');

      //Цикл добавления значений полей из DBF
       for n_tmp:=0 to (kol_strok div 4)-1 do
        begin
          //ttt:=n_tmp;
          k:=tmp_array[n_tmp,1];
          //If strtoint(k)=43 then
            //begin
              //sleep(1);
             //end;
          //ttt:=strtoint(tmp_array[n_tmp,1]);
          //ttt:=formDbf.Dbf1.FieldCount;
          j:=formDbf.Dbf1.Fields[strtoint(tmp_array[n_tmp,1])].value;

          // Простое текстовое поле
          if (tmp_array[n_tmp,2]='0') and (tmp_array[n_tmp,3]='0') then
            begin
              if j=NULL then j:=' '; //проверка на NULL
              strsql:=strsql+QuotedStr(j);
              if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
              formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
              strsql2:=strsql2+CP1251ToUTF8(strsql);
              strsql:='';
            end;

          // Простое числовое поле
          if (tmp_array[n_tmp,2]='1') and (tmp_array[n_tmp,3]='0') then
            begin
              if j=NULL then j:='0'; //проверка на NULL

              if (vartype(j)=3) or (vartype(j)=5)  then
                begin
                 //If (trim(inttostr(strtoint(j)))<>'0') and (trim(inttostr(strtoint(j)))<>'1') then
                    //begin
                 If ((pos(#44,j)>0) or (pos(#46,j)>0)) then
                    j:=floattostr(j) //,fffixed,5,2)
                    else
                    j:=inttostr(j);
                 //If (ansipos(#44,j)>0) or (ansipos(#46,j)>0) then
                   //k:=inttostr(j);
                 //If (utf8pos(',',CP1251ToUTF8(j))>0) or (utf8pos('.',CP1251ToUTF8(j))>0) then
                   //k:=inttostr(j);
                 //If (pos(',',CP1251ToUTF8(j))>0) or (pos('.',CP1251ToUTF8(j))>0) then
                 //k:=inttostr(j);
                // If (ansipos(',',j)>0) or (ansipos('.',j)>0) then

                 //k:=inttostr(j);
                    //end;
                end;
              strsql:=strsql+j;
              if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
              formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
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
               formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
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
                If trim(strsql)='' then strsql:='0';
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql:='';
               end
             else
               begin
                strsql:=strsql+j;
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
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
                If trim(strsql)='' then strsql:='0';
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql2:=strsql2+strsql;
                strsql:='';
               end
             else
               begin
                strsql:=strsql+'0';
                if n_tmp<(kol_strok div 4)-1 then strsql:=strsql+',';
                formDbf.ZQuery1.SQL.add(CP1251ToUTF8(strsql));
                strsql2:=strsql2+CP1251ToUTF8(strsql);
                strsql:='';
               end;
            end;

        end;

       //отображаем запрос в мемо
       if formDbf.CheckBox1.Checked = True then
       begin
        Memo1.Append(strsql2+ '''');
        formDbf.Memo1.Refresh;
       end;

  // ********* Пишем в базу
      //////////////////////////////////////

        //2.Выполняем SQL запрос Insert
        formDbf.ZQuery1.SQL.add(CP1251ToUTF8(');'));
        //showmessagealt(       formDbf.ZQuery1.SQL.text); //$
        formDbf.ZQuery1.ExecSQL;
     //////////////////////////////////////////////////////
       //Следующая строка
       formDbf.Dbf1.Next;
      end;
   //отключаемся
   formdbf.ZQuery1.Close;
      formDbf.Zconnection1.disconnect;
      formDbf.DBF1.EnableControls;
      //Освобождаем TDBF
      formDbf.dbf1.Active:=false;
      formDbf.Dbf1.close;
      Memo1.Append('=======================================================================');

 end;
 formDbf.ProgressBar1.Position:=0;
 formDbf.ProgressBar1.Refresh;
 //освободить память от массива
  SetLength(tmp_array,0,0);
  tmp_array := nil;
  end;
end;

procedure TFormDbf.BitBtn14Click(Sender: TObject);
begin
  formDbf.Close;
end;

procedure TFormDbf.BitBtn1Click(Sender: TObject);
begin
  update_sprav();
end;



procedure TFormDbf.BitBtn32Click(Sender: TObject);
begin
   //******************************************* УКАЗАТЬ ПУТЬ К базам 1С ************************************
  FormDbf.dialog1.Execute;
  formDbf.edit8.Text:=FormDbf.dialog1.FileName;
end;

//******************  Настройки   *****************************************************************
procedure TFormDbf.BitBtn6Click(Sender: TObject);
begin
  //Проверка файлов DBF в каталоге
  If FindAnyFIle(formDBF.Edit8.text,'*.DBF')=false then
    begin
    showmessagealt('Не обнаружено файлов DBF по данному пути!');
     exit;
    end;

  //Form2:=TForm2.Create(self);
  //form2.showmodal;
  //FreeAndNil(form2);
end;

//*****************************    Загрузка справочников    ***************************************
procedure TFormDbf.BitBtn7Click(Sender: TObject);
begin
  If formdbf.Panel1.Visible then exit;
  FormDbf.BitBtn1.Enabled:=false;
  FormDbf.BitBtn14.Enabled:=false;
  //Сбрасываем флаг
  lExp:=false;
 //Очищаем memo
 formDBf.memo1.Clear;
 formDbf.Panel1.Visible:=true;
 formDbf.BitBtn2.SetFocus;

 //Form4:=TForm4.Create(self);
 //form4.showmodal;
 //FreeAndNil(form4);
 //If lExp then

 //formDbf.ExportALLDBF();

end;

 //панель файлов загрузки
procedure TFormDbf.BitBtn2Click(Sender: TObject);
var
   n,i:integer;
begin
  lExp:=true;
   //сохраняем настройки загрузки
      for n:=0 to formdbf.CheckListBox1.Count-1 do
       begin
         for i:=low(arrspr) to high(arrspr) do
          begin
           IniProp.IniSection:=arrspr[i]; //указываем секцию
            If utf8pos(IniProp.ReadString('source_file','-'), CheckListBox1.Items[n])>0 then
              begin
               IniProp.WriteBoolean('upload_check',CheckListBox1.Checked[n]);
               continue;
              end;
           end;
       end;

  formDbf.Panel1.Visible:=false;
  formDbf.loadDB();
  FormDbf.BitBtn1.Enabled:=true;
  FormDbf.BitBtn14.Enabled:=true;
end;


procedure TFormDbf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
   fpath: string;
begin
 with FormDBF do begin
  fpath:=IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))+'DBF.ini';
 If not FileExistsUTF8(fpath)
    then
      begin
       FileCreateUTF8(fpath);
       end;
       IniProp.iniFileName:=fpath;
       IniProp.IniSection:='MAIN'; //указываем секцию
     IniProp.WriteString('sprav_path',edit8.Text);
     IniProp.WriteString('logs_show',Booltostr(Checkbox1.Checked));
     //IniProp.WriteString('port_central',formSets.Edit13.Text);
     //IniProp.WriteString('name_base',formSets.edit4.text);
       //IniProp.IniSection:='AV_SPR_KONTRAGENT'; //указываем секцию
     //IniProp.WriteString('source_file','Contr');
     //IniProp.WriteString('loading_table','av_1c_kontr');
     //IniProp.WriteString('upload_check','1');
     //IniProp.WriteString('update_check','1');
     //  IniProp.IniSection:='AV_SPR_KONTR_DOG'; //указываем секцию
     //IniProp.WriteString('source_file','Dog');
     //IniProp.WriteString('loading_table','av_1c_dog');
     //IniProp.WriteString('upload_check','1');
     //IniProp.WriteString('update_check','1');
     //  IniProp.IniSection:='AV_SPR_KONTR_VIDDOG'; //указываем секцию
     //IniProp.WriteString('source_file','Viddog');
     //IniProp.WriteString('loading_table','av_1c_viddog');
     //IniProp.WriteString('upload_check','0');
     //IniProp.WriteString('update_check','0');
     //  IniProp.IniSection:='AV_SPR_KONTR_LICENSE'; //указываем секцию
     //IniProp.WriteString('source_file','Lic');
     //IniProp.WriteString('loading_table','av_1c_license');
     //IniProp.WriteString('upload_check','0');
     //IniProp.WriteString('update_check','0');
     //  IniProp.IniSection:='AV_USERS'; //указываем секцию
     //IniProp.WriteString('source_file','Sotr');
     //IniProp.WriteString('loading_table','av_1c_stuff');
     //IniProp.WriteString('upload_check','0');
     //IniProp.WriteString('update_check','0');
     //IniProp.Save;
      end
end;




  //*************************************************    HOT KEYS  *************************************************
procedure TFormDbf.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  with FormDbf do
begin
   // F1
    if (Key=112) then showmessagealt('[F1] - Справка'+#13+'[F2] - Указать путь'+#13+'[F4] - Настройки'+#13+'[F5] - Загрузить'+#13+'[ESC] - Отмена\Выход');
   //F2 - Указать путь
    if (Key=113) then BitBtn6.Click;
   //F4 - Загрузить
    if (Key=115) then BitBtn7.Click;
   //F5 - Обновить
    if (Key=116) then BitBtn1.Click;
   //закрыть панель
    if (Key=27) and Panel1.Visible then
  begin
    key:=0;
    Panel1.Visible:=false;
    FormDbf.BitBtn1.Enabled:=true;
    FormDbf.BitBtn14.Enabled:=true;
    end;
   // ESC
    if (Key=27) then Close;
  end;

    If (Key=27) OR (Key=112) OR (Key=116) then Key:=0;
end;

procedure TFormDbf.FormShow(Sender: TObject);
  var
   fpath, dbname :string;
   n,i:integer;
begin
   //массив названий обновляемых справочников (секций ini файла с настройками обновления)
  setlength(arrspr,5);
  arrspr[0]:= 'AV_SPR_KONTRAGENT';
  arrspr[1]:= 'AV_SPR_KONTR_DOG';
  arrspr[2]:= 'AV_SPR_KONTR_VIDDOG';
  arrspr[3]:= 'AV_SPR_KONTR_LICENSE';
  arrspr[4]:= 'AV_USERS';

   with FormDbf do
    begin
 //считываем настройки
   FormDbf.Edit8.text := ConnectINI[7];

   fpath:=IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))+'DBF.ini';
 If not FileExistsUTF8(fpath)
    then
      begin
       FileCreateUTF8(fpath);
       IniProp.iniFileName:=fpath;
       IniProp.IniSection:='MAIN'; //указываем секцию
     IniProp.WriteString('sprav_path',ConnectINI[7]);
     //IniProp.WriteString('logs_show',Booltostr(Checkbox1.Checked));
     //IniProp.WriteString('port_central',formSets.Edit13.Text);
     //IniProp.WriteString('name_base',formSets.edit4.text);
       IniProp.IniSection:='AV_SPR_KONTRAGENT'; //указываем секцию
     IniProp.WriteString('source_file','Contr');
     IniProp.WriteString('loading_table','av_1c_contr');
     IniProp.WriteString('upload_check','1');
     IniProp.WriteString('update_check','1');
       IniProp.IniSection:='AV_SPR_KONTR_DOG'; //указываем секцию
     IniProp.WriteString('source_file','Dog');
     IniProp.WriteString('loading_table','av_1c_dog');
     IniProp.WriteString('upload_check','1');
     IniProp.WriteString('update_check','1');
       IniProp.IniSection:='AV_SPR_KONTR_VIDDOG'; //указываем секцию
     IniProp.WriteString('source_file','Viddog');
     IniProp.WriteString('loading_table','av_1c_viddog');
     IniProp.WriteString('upload_check','0');
     IniProp.WriteString('update_check','0');
       IniProp.IniSection:='AV_SPR_KONTR_LICENSE'; //указываем секцию
     IniProp.WriteString('source_file','Lic');
     IniProp.WriteString('loading_table','av_1c_license');
     IniProp.WriteString('upload_check','0');
     IniProp.WriteString('update_check','0');
       IniProp.IniSection:='AV_USERS'; //указываем секцию
     IniProp.WriteString('source_file','Sotr');
     IniProp.WriteString('loading_table','av_1c_stuff');
     IniProp.WriteString('upload_check','0');
     IniProp.WriteString('update_check','0');
     //IniProp.Save;
       //exit;
      end
   else
     begin
      //showmessage(fpath);
       //If IniProp.Active then showmessage('1');
      //IniProp.Active:=false;
      IniProp.inifilename:=fpath;
        //IniProp.IniSection:='CENTRAL SERVER SQL'; //указываем секцию
        //ConnectINI[1]:=IniProp.ReadString('ip_central','нет значения');
        //ConnectINI[2]:=IniProp.ReadString('port_central','0');
        //ConnectINI[3]:=IniProp.ReadString('name_base','нет значения');
      IniProp.IniSection:='MAIN'; //указываем секцию
      Edit8.Text:= IniProp.ReadString('sprav_path',fpath);

      //проставляем настройки загрузки
      for n:=0 to formdbf.CheckListBox1.Count-1 do
       begin
         //dbname:= py(utf8pos('(' CheckListBox1.Items[n];
         //Memo1.Append(dbname);
         for i:=low(arrspr) to high(arrspr) do
          begin
             IniProp.IniSection:=arrspr[i]; //указываем секцию
              If utf8pos(IniProp.ReadString('source_file','-'), CheckListBox1.Items[n])>0 then
                begin
                 //Memo1.Append(utf8copy(CheckListBox1.Items[n],utf8pos(IniProp.ReadString('source_file','-'), CheckListBox1.Items[n]),100));
                 CheckListBox1.Checked[n]:=strtoBool(IniProp.ReadString('upload_check','false'));
                 continue;
                end;
          end;
       end;
     end;

   UpdateGrid(0);
   FormDbf.Memo1.Clear;
  end;
end;

{$R *.lfm}

end.


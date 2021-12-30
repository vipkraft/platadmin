unit spr_update;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, Buttons, ExtCtrls, LazUTF8, dateutils;

type

  { TFormUpdate }

  TFormUpdate = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn14: TBitBtn;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Image3: TImage;
    Label2: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    StringGrid1: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1SetCheckboxState(Sender: TObject; ACol, ARow: Integer;
      const Value: TCheckboxState);
    procedure UpdateGrid(mode: byte);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormUpdate: TFormUpdate;

implementation
uses platproc,main;

{$R *.lfm}

{ TFormUpdate }


procedure TFormUpdate.UpdateGrid(mode: byte);
 var
   n,m:integer;
 begin
  //Соединяемся с сервером
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

     //Текущий Список таблиц ЦС
   FormUpdate.ZQuery1.SQL.clear;
   //FormUpdate.ZQuery1.SQL.add('SELECT a.relname, c.description,a.reltuples FROM pg_class AS a ');
   //FormUpdate.ZQuery1.SQL.add('JOIN pg_namespace as d ON d.oid=a.relnamespace AND d.nspname=current_schema() ');
   //FormUpdate.ZQuery1.SQL.add('LEFT JOIN pg_description AS c ON c.objoid = a.oid AND c.objsubid=0 ');
   //FormUpdate.ZQuery1.SQL.add('WHERE substring(a.relname, 1, 8) = ''av_spr_k'' and not(a.relname LIKE ''%id_seq%'') ');
   //FormUpdate.ZQuery1.SQL.add('ORDER by a.relname ;');

   FormUpdate.ZQuery1.SQL.add('SELECT table_name ');
   FormUpdate.ZQuery1.SQL.add(',(SELECT c.description FROM pg_description AS c WHERE c.objoid = (select a.oid FROM pg_class a WHERE a.relname=table_name limit 1) limit 1) rem ');
   FormUpdate.ZQuery1.SQL.add(',(SELECT a.reltuples FROM pg_class a where a.relname=table_name) as nrows ');
   FormUpdate.ZQuery1.SQL.add('    FROM information_schema.tables ');
   FormUpdate.ZQuery1.SQL.add('WHERE table_type = ''BASE TABLE'' ');
   FormUpdate.ZQuery1.SQL.add('AND substring(table_name,1,9) = ''av_spr_ko'' ');
   FormUpdate.ZQuery1.SQL.add('    AND table_schema NOT IN ');
   FormUpdate.ZQuery1.SQL.add('        (''pg_catalog'', ''information_schema'') ');
   FormUpdate.ZQuery1.SQL.add('        order by table_name ');
  //showmessage(FormUpdate.ZQuery1.SQL.Text);//$
   try
    FormUpdate.ZQuery1.Open;
   except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    FormUpdate.ZQuery1.Close;
    FormUpdate.Zconnection1.disconnect;
    exit;
   end;

 if FormUpdate.ZQuery1.RecordCount<1 then
     begin
       FormUpdate.ZQuery1.close;
       FormUpdate.ZConnection1.Disconnect;
       exit;
     end;


 // Заполняем Stringgrid
  If mode=0 then
      begin
  FormUpdate.StringGrid1.RowCount:=1;

  //SetLength(arTables,FormDLog.ZQuery1.RecordCount,2);
  for n:=0 to FormUpdate.ZQuery1.RecordCount-1 do
   begin
     FormUpdate.StringGrid1.RowCount:=FormUpdate.StringGrid1.RowCount+1;
     FormUpdate.StringGrid1.Cells[0,n+1]:=trim(FormUpdate.ZQuery1.FieldByName('table_name').asString);
     FormUpdate.StringGrid1.Cells[1,n+1]:=trim(FormUpdate.ZQuery1.FieldByName('rem').asString);
     FormUpdate.StringGrid1.Cells[2,n+1]:='';
     //кол-во записей до обновления
     FormUpdate.StringGrid1.Cells[3,n+1]:=FormUpdate.ZQuery1.FieldByName('nrows').asString;
     //If n>0 then FormUpdate.StringGrid1.Cells[2,n+1]:='*';
     ZQuery1.Next;
   end;
     end
  else
  begin
    for n:=0 to FormUpdate.ZQuery1.RecordCount-1 do
   begin
     //кол-во записей после обновления
      FormUpdate.StringGrid1.Cells[4,n+1]:=FormUpdate.ZQuery1.FieldByName('nrows').asString;
      ZQuery1.Next;
     end;
    end;
  FormUpdate.StringGrid1.Repaint;
  end;


procedure TFormUpdate.BitBtn14Click(Sender: TObject);
begin
  FormUpdate.Close;
end;


procedure TFormUpdate.BitBtn1Click(Sender: TObject);
//********************************************** ОБНОВИТЬ ИЗ 1С **************************************************
var
 szap,comma,stim,ssd,ttabl1,ttabl2: string;
 widezap: widestring;
 bCH,bDog,bVid,bLic: byte;
 chislo : longint;
 kolvo, n, y: integer;
 sstr,log:string;
 pos : tpoint;
 filetxt : TextFile;
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

   //log := ExtractFilePath(Application.ExeName)+'spr_update.log';
   log := 'spr_update.log';
   AssignFile(filetxt,log);
   ////открываем файл лога
   if FileExistsUTF8(log) then
      begin
        {$I-} // отключение контроля ошибок ввода-вывода
        Append(filetxt); // открытие существулющего файла для записи
        {$I+} // включение контроля ошибок ввода-вывода
        if IOResult<>0 then // если есть ошибка открытия, то
        begin
         showmessagealt('Ошибка отрытия лога !');
         Exit;
        end;
        //seek(filetxt,filesize(filetxt));  //сдвигаем указатель в конец файла
      end
   else
      begin
        {$I-} // отключение контроля ошибок ввода-вывода
        Rewrite(filetxt); // создание и открытие файла для записи
        {$I+} // включение контроля ошибок ввода-вывода
        if IOResult<>0 then // если есть ошибка открытия, то
        begin
         showmessagealt('Ошибка создания лога !');
         Exit;
        end;
      end;

   writeln(filetxt,' ');
   writeln(filetxt,' ');
   writeln(filetxt,'@@@@@@@@@@@@@@@@@@@@@@@@    ОБНОВЛЕНИЕ СПРАВОЧНИКОВ   @@@@@@@@@@@@@@@@@@@@@@@@@');
   writeln(filetxt,'|||||||||||||||||||||    '+datetostr(date)+'  '+timetostr(time)+'  '+ GetDayName(DayOftheWeek(Date)) +'      |||||||||||||||||||||');
   writeln(filetxt,' обновление проводил пользователь с id= '+GLuser);

   with FormUpdate do
   begin
     Memo1.Clear;
    Memo1.Append('=================  Подлключаемся к базе данных ... ===============================');
    writeln(filetxt,'=================  Подлключаемся к базе данных ... ===============================');
    Memo1.Append(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с основным сервером потеряно !'+#13+'Проверьте соединение и/или'+#13+' обратитесь к администратору.');
      closefile(filetxt);
      Close;
      exit;
     end;

   Memo1.Append('=================  Начат процесс ОБНОВЛЕНИЯ ! ПОДОЖДИТЕ ... ===============================');
   writeln(filetxt,'=================  Начат процесс ОБНОВЛЕНИЯ ! ПОДОЖДИТЕ ... ===============================');
   Memo1.Append(':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
    // Ставим курсов в конец строки
   //Memo1.SetFocus;
   //pos.x:=Utf8Length(memo1.Lines[memo1.CaretPos.x])-1;
   //pos.y:=memo1.Lines.Count-1;
   //Memo1.CaretPos:=pos;


//Идем по гриду
   for y:=1 to Stringgrid1.RowCount-1 do
    begin

//****************************************************************  обновление контрагентов **************
If (trim(Stringgrid1.Cells[0,y])='av_spr_kontragent') AND (StringGrid1.Cells[StringGrid1.Col,y]='*') then
  begin
   Memo1.Append('Обновление справочника контрагентов...');
   writeln(filetxt,'Обновление справочника контрагентов...');
 //ищем удаленных из 1С   ****************************************
   szap:='Select a.id,a.name,a.kod1c FROM av_spr_kontragent as a WHERE a.del=0 AND a.kod1c>0 AND NOT EXISTS (SELECT kod1c FROM av_1c_kontr AS b WHERE b.kod1c=a.kod1c)';
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.Add(szap+';');
   //showmessage(ZQuery1.SQL.Text);//$
   try
      ZQuery1.Open;
   except
       Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
       writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
       closefile(filetxt);
       ZQuery1.close;
    Zconnection1.disconnect;
    exit;
   end;
  if ZQuery1.RecordCount>0 then
  begin
  writeln(filetxt,'!!! В ЗАГРУЖАЕМОМ СПРАВОЧНИКЕ ОТСУТСТВУЮТ СЛЕДУЮЩИЕ ЗАПИСИ... !!!');
  for n:=1 to ZQuery1.RecordCount do
     begin
       writeln(filetxt,ZQuery1.FieldByName('id').AsString+'  '+ZQuery1.FieldByName('name').AsString+'  kod1c='+ZQuery1.FieldByName('kod1c').AsString);
       ZQuery1.Next;
     end;
  writeln(filetxt,'===================================================================');
   //Открываем транзакцию
 //try
 //  If not Zconnection1.InTransaction then
 //     Zconnection1.StartTransaction
 //  else
 //    begin
 //     Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
 //     writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
 //     closefile(filetxt);
 //     ZConnection1.Rollback;
 //     ZQuery1.Close;
 //     ZConnection1.Disconnect;
 //     exit;
 //    end;
 //  kolvo:=ZQuery1.RecordCount;
 //  //помечаем на удаление
 //  ZQuery1.SQL.Clear;
 //  ZQuery1.SQL.Add('UPDATE av_spr_kontragent SET del=2,id_user='+gluser+',createdate=default WHERE del=0 AND id IN ('+szap+');');
 //  szap:='';
 //  ZQuery1.ExecSQL;
 //
 // // Завершение транзакции
 //  Zconnection1.Commit;
 //   Memo1.Append('КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
 //   writeln(filetxt,'КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
 //   bCH:=1;
 //  except
 //    Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 //    writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 //    closefile(filetxt);
 //     ZConnection1.Rollback;
 //     ZQuery1.Close;
 //     ZConnection1.Disconnect;
 //     exit;
 //  end;
   ZQuery1.close;
  end;

  //ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT kod1c FROM av_1c_kontr AS a ');
   szap:='WHERE a.kod1c>0 AND NOT EXISTS (SELECT distinct kod1c FROM av_spr_kontragent AS b WHERE a.kod1c=b.kod1c AND b.kod1c>0);'; //2017.03.24 убрал 'AND b.del=0'
   ZQuery1.SQL.add(szap);
  //showmessage(ZQuery1.SQL.Text);//$
   try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;
   if ZQuery1.RecordCount>0 then
   begin
 //Открываем транзакцию
 try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x01'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x01'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmp1K'+stim; //IntToStr(chislo);

  //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
  //ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL,polname character(200) NOT NULL,vidkontr character(100) NOT NULL,inn character(20) NOT NULL,okpo character(15) NOT NULL,adrur character(200) NOT NULL,');
  ZQuery1.SQL.Add('CREATE TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL,polname character(200) NOT NULL,vidkontr character(100) NOT NULL,inn character(20) NOT NULL,okpo character(15) NOT NULL,adrur character(200) NOT NULL,');
  ZQuery1.SQL.Add('tel character(100) NOT NULL,docsr character(30) NOT NULL,docnom character(30) NOT NULL,docorgv character(100) NOT NULL,');//2017.03.24 убрал 'adrpos
  ZQuery1.SQL.Add('docdatv date,grprosv smallint NOT NULL DEFAULT 0,gorod character(60) NOT NULL,podr character(60) NOT NULL) WITH (OIDS=FALSE);');
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;
  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl1+' SELECT row_number() over (order by a.kod1c)+coalesce((select max(id) from av_spr_kontragent),0) as id, ');
  ZQuery1.SQL.Add('kod1c, name, polname, vidkontr, inn, okpo, adrur, tel, docsr, docnom, docorgv, docdatv, grprosv, gorod, podr FROM av_1c_kontr AS a '+szap);
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;
  //добавляем новые записи в таблицу контрагентов
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontragent(id,createdate,del,id_user,name,polname,kod1c,vidkontr,inn,okpo,adrur,adrpos,tel,document,createdate_first,id_user_first) ');
  ZQuery1.SQL.Add('SELECT id,now(),0,'+GLuser+',name,polname,kod1c,vidkontr,inn,okpo,adrur,'''' as adrpos,tel,docsr || '+QuotedStr(comma)+' || docnom || '+QuotedStr(comma)+' || docorgv || '); //2017.03.24 убрал 'adrpos'
  ZQuery1.SQL.Add(QuotedStr(comma)+' || coalesce('''' || docdatv || '''','''') AS document,now(),'+GLuser+' FROM '+ttabl1+';');
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSql;
  //showmessage('все');//$
   // Завершение транзакции
   Zconnection1.Commit;
    Memo1.Append('КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
    writeln(filetxt,'КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bCH:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   Zconnection1.disconnect;
  end;

   //ищем отредактированные в 1с   ********************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT a.kod1c FROM av_1c_kontr AS a,av_spr_kontragent AS b ');
   ZQuery1.SQL.add('WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0 AND NOT(a.name=b.name AND a.polname=b.polname AND a.vidkontr=b.vidkontr AND a.inn=b.inn AND a.okpo=b.okpo ');
   ZQuery1.SQL.add('AND a.tel=b.tel AND a.adrur=b.adrur AND a.tel=b.tel ');//2017.03.24 убрал 'AND a.adrpos=b.adrpos'
   ZQuery1.SQL.add('AND (a.docsr || '+QuotedStr(comma)+' || a.docnom || '+QuotedStr(comma)+' || a.docorgv || '+QuotedStr(comma)+' || coalesce('''' || a.docdatv || '''',''''))=b.document);');
  //showmessage(ZQuery1.SQL.text);//$
  try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;
   kolvo:=0;

   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
   try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
  kolvo:=ZQuery1.RecordCount;
  DateTimeToString(stim,'yymmdd_hhnnzzz',now);
  //Randomize;
  //chislo:=Random(200)+1;
  //try
  //chislo:=ABS(chislo*StrToInt(stim));
  //except
  //     on exception: EConvertError do
  //     begin
  //     Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x02'+#13+'Значение: ' + stim);
  //     writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x02'+#13+'Значение: ' + stim);
  //     closefile(filetxt);
  //    ZConnection1.Rollback;
  //    ZQuery1.Close;
  //    ZConnection1.Disconnect;
  //     exit;
  //     end;
  // end;
  ttabl2:='tmp2K'+stim; //IntToStr(chislo);
  ZQuery1.SQL.Clear;
  //cоздаем временную таблицу для новых записей
  //ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY  TABLE '+ttabl2+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL,polname character(200) NOT NULL,');
  ZQuery1.SQL.Add('CREATE TABLE '+ttabl2+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL,polname character(200) NOT NULL,');
  ZQuery1.SQL.Add('vidkontr character(100) NOT NULL,inn character(20) NOT NULL,okpo character(15) NOT NULL,adrur character(200) NOT NULL,');
  ZQuery1.SQL.Add('tel character(100) NOT NULL,document character(200) NOT NULL) WITH (OIDS=FALSE);');//2017.03.24 убрал 'adrpos character(200) NOT NULL'
  ZQuery1.ExecSQL;

  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl2+' SELECT b.id,a.kod1c,a.name,a.polname,a.vidkontr,a.inn,a.okpo,a.adrur,a.tel,a.docsr || '+QuotedStr(comma));
  ZQuery1.SQL.Add(' || a.docnom || '+QuotedStr(comma)+' || a.docorgv || '+QuotedStr(comma)+' || coalesce('''' || a.docdatv || '''','''') AS document FROM av_1c_kontr AS a ');
  ZQuery1.SQL.Add('LEFT JOIN av_spr_kontragent AS b USING (kod1c) ');
  ZQuery1.SQL.Add('WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0 AND NOT(a.name=b.name AND a.polname=b.polname ');
  ZQuery1.SQL.Add('AND a.vidkontr=b.vidkontr AND a.inn=b.inn AND a.okpo=b.okpo AND a.adrur=b.adrur AND a.tel=b.tel ');//2017.03.24 убрал 'AND a.adrpos=b.adrpos
  ZQuery1.SQL.Add('AND (a.docsr || '+QuotedStr(comma)+' || a.docnom || '+QuotedStr(comma)+' || a.docorgv || '+QuotedStr(comma)+' || coalesce('''' || a.docdatv || '''',''''))=b.document);');
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;

  //помечаем на удаление прежние записи
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('UPDATE av_spr_kontragent SET del=1,id_user='+GLuser+',createdate=default WHERE del=0 AND id IN (SELECT id FROM '+ttabl2+');');
  ZQuery1.ExecSQL;
 //
  //добавляем новые записи в таблицу контрагентов
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontragent(id,createdate,del,id_user,name,polname,kod1c,vidkontr,inn,okpo,adrur,adrpos,tel,document,createdate_first,id_user_first) ');
  ZQuery1.SQL.Add('SELECT id,now(),0,'+GLuser+',name,polname,kod1c,vidkontr,inn,okpo,adrur,'''',tel,document,NULL,NULL FROM '+ttabl2+';');//2017.03.24 убрал 'adrpos
  //showmessage(ZQuery1.SQL.Text);//$
  ZQuery1.ExecSQL;

  //showmessage('ВСЁ');//$
   // Завершение транзакции
   //Zconnection1.Commit;
    Memo1.Append('КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
    writeln(filetxt,'КОНТРАГЕНТЫ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bCH:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   Zconnection1.disconnect;
   end;
   If bCH=0 then
   begin
  Memo1.Append('Изменений в справочнике контрагентов НЕ ОБНАРУЖЕНО!');
  writeln(filetxt,'Изменений в справочнике контрагентов НЕ ОБНАРУЖЕНО!');
  end;
end;
// *************************************************************


// ************************************************  обновление договоров ***************************
If (trim(Stringgrid1.Cells[0,y])='av_spr_kontr_dog') AND (StringGrid1.Cells[StringGrid1.Col,y]='*') then
begin
Memo1.Append('Обновление справочника ДОГОВОРОВ...');
  writeln(filetxt,'Обновление справочника ДОВОГОВОР...');
//ищем удаленных из 1С   ****************************************
   szap:='Select a.id,a.id_kontr,a.kod1c FROM av_spr_kontr_dog as a WHERE a.del=0 AND a.kod1c>0 AND NOT EXISTS (SELECT kod1c FROM av_1c_kontr_dog AS b '+
   'WHERE trim(b.viddog)<>''''  and b.kod1c=a.kod1c AND b.kodkont=a.kodkont AND a.kod1c>0)';
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.Add(szap+';');
 //showmessage(ZQuery1.SQL.Text);//$
   //try
   //   ZQuery1.Open;
   //except
   //    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
   //    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
   //    closefile(filetxt);
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   // exit;
   //end;

  //if ZQuery1.RecordCount>0 then
  begin
  // writeln(filetxt,'!!! В ЗАГРУЖАЕМОМ СПРАВОЧНИКЕ ОТСУТСТВУЮТ СЛЕДУЮЩИЕ ЗАПИСИ... !!!');
  //for n:=1 to ZQuery1.RecordCount do
  //   begin
  //     writeln(filetxt,ZQuery1.FieldByName('id').AsString+'  id_kontr='+ZQuery1.FieldByName('id_kontr').AsString+'  kod1c='+ZQuery1.FieldByName('kod1c').AsString);
  //     ZQuery1.Next;
  //   end;
  //writeln(filetxt,'===================================================================');
  // //Открываем транзакцию
  // try
  // If not Zconnection1.InTransaction then
  //    Zconnection1.StartTransaction
  // else
  //   begin
  //    Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
  //    writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
  //    closefile(filetxt);
  //    ZConnection1.Rollback;
  //    ZQuery1.Close;
  //    ZConnection1.Disconnect;
  //    exit;
  //   end;
  // kolvo:=ZQuery1.RecordCount;
  // //помечаем на удаление
  // ZQuery1.SQL.Clear;
  // ZQuery1.SQL.Add('UPDATE av_spr_kontr_dog SET del=2,id_user='+GLuser+',createdate=default WHERE del=0 AND id IN ('+szap+');');
  // szap:='';
  // ZQuery1.ExecSQL;
  //
  //// Завершение транзакции
  // Zconnection1.Commit;
  //  Memo1.Append('ДОГОВОРА. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
  //  writeln(filetxt,'ДОГОВОРА. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
  //     bDog:=1;
  //     ZQuery1.Close;
  // except
  //   ZConnection1.Rollback;
  //   Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
  //   writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
  // end;
   //ZQuery1.close;
  end;

 //ищем отредактированные в 1С  ************************************************
//
//If 1<>1 then //$
begin
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('Select a.kodkont,a.kod1c FROM av_1c_kontr_dog AS a ');
  widezap :='WHERE EXISTS (SELECT distinct b.kodkont,b.kod1c FROM av_spr_kontr_dog AS b WHERE b.kodkont=a.kodkont AND b.kod1c=a.kod1c AND b.del=0) '+
  'AND NOT EXISTS (SELECT distinct b.kodkont,b.kod1c FROM av_spr_kontr_dog AS b WHERE '+
  'b.kodkont=a.kodkont AND b.kod1c=a.kod1c AND b.del=0 AND coalesce(a.datapog,''1.1.1970'')=coalesce(b.datapog,''1.1.1970'') AND coalesce(a.datazak,''1.1.1970'')=coalesce(b.datazak,''1.1.1970'') '+
  'AND coalesce(a.datavoz,''1.1.1970'')=coalesce(b.datavoz,''1.1.1970'') AND coalesce(a.datanacsh,''1.1.1970'')=coalesce(b.datanacsh,''1.1.1970'') AND coalesce(a.dataprsh,''1.1.1970'')=coalesce(b.dataprsh,''1.1.1970'') '+
  'AND a.name=b.name AND a.stav=b.stav AND a.val=b.val AND a.viddog=b.viddog '+
  'AND a.podr=b.podr AND a.otcblm=b.otcblm AND a.otcbagm=b.otcbagm AND a.otcblp=b.otcblp AND a.otcbagp=b.otcbagp AND a.otcblr=b.otcblr AND a.otcbagr=b.otcbagr AND a.otcblg=b.otcblg AND a.otcbagg=b.otcbagg '+
  'AND a.komotd=b.komotd AND a.med=b.med AND a.ubor=b.ubor AND a.stop=b.stop AND a.disp=b.disp AND a.voin=b.voin AND ' +
  'a.lgot=b.lgot AND a.dopus=b.dopus AND a.vidar=b.vidar AND a.sumar=b.sumar AND a.shtr1=b.shtr1 AND a.shtr2=b.shtr2 AND a.shtr11=b.shtr11 AND a.shtr12=b.shtr12 AND a.shtr13=b.shtr13 AND '+
  'a.shtr21=b.shtr21 AND a.shtr22=b.shtr22 AND a.shtr23=b.shtr23 AND a.shtr24=b.shtr24 AND a.shtr42=b.shtr42 AND a.shtr43=b.shtr43 AND a.shtr44=b.shtr44 AND a.shtr45=b.shtr45 AND '+
  'a.shtr3=b.shtr3 AND a.shtr4=b.shtr4 AND a.shtr41=b.shtr41 AND a.shtr5=b.shtr5 AND a.shtr6=b.shtr6 AND a.shtr7=b.shtr7 AND a.shtr8=b.shtr8 AND '+
  'btrim(a.edizm1)=btrim(b.edizm1) AND btrim(a.edizm11)=btrim(b.edizm11) AND btrim(a.edizm2)=btrim(b.edizm2) AND btrim(a.edizm3)=btrim(b.edizm3) AND '+
  'btrim(a.edizm4)=btrim(b.edizm4) AND btrim(a.edizm41)=btrim(b.edizm41) AND btrim(a.edizm5)=btrim(b.edizm5) AND btrim(a.edizm6)=btrim(b.edizm6) AND '+
  'btrim(a.edizm7)=btrim(b.edizm7) AND btrim(a.edizm8)=btrim(b.edizm8) AND btrim(a.edizm12)=btrim(b.edizm12) AND btrim(a.edizm13)=btrim(b.edizm13) AND '+
  'btrim(a.edizm21)=btrim(b.edizm21) AND btrim(a.edizm22)=btrim(b.edizm22) AND btrim(a.edizm23)=btrim(b.edizm23) AND btrim(a.edizm24)=btrim(b.edizm24) AND '+
  'btrim(a.edizm42)=btrim(b.edizm42) AND btrim(a.edizm43)=btrim(b.edizm43) AND btrim(a.edizm44)=btrim(b.edizm44) AND btrim(a.edizm45)=btrim(b.edizm45)) '+
  'and a.datapog>current_date '+
  //'and ((case when trim(viddog)='''' then ''0'' else viddog end)::integer)=2 '+
  'and kodkont in (select distinct kod1c from av_spr_kontragent where del=0); ';
  ZQuery1.SQL.add(widezap);
  //ZQuery1.SQL.add('limit 1; ');
  //showmessage(ZQuery1.SQL.text);//$

  try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;

   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
   try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x04'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x04'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmp1Dog'+stim; //IntToStr(chislo);
  //showmessagealt(ttabl1);
   //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
  //CREATE LOCAL TEMPORARY TABLE
  ZQuery1.SQL.Add('CREATE TABLE '+ ttabl1 +' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,del smallint NOT NULL DEFAULT 0, createdate timestamp without time zone NOT NULL DEFAULT now(),');
                //ZQuery1.SQL.Add('CREATE TABLE '+ ttabl1 +' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,del smallint NOT NULL DEFAULT 0, createdate timestamp without time zone NOT NULL DEFAULT now(),');
  ZQuery1.SQL.Add('id_user integer NOT NULL DEFAULT 0, createdate_first timestamp without time zone,id_user_first integer,');
  ZQuery1.SQL.Add('kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(200) NOT NULL,datazak date,datavoz date,datapog date,');
  ZQuery1.SQL.Add('val character(20) NOT NULL,datanacsh date,dataprsh date,stav numeric(5,2) NOT NULL DEFAULT 0,viddog character(20) NOT NULL,podr character(100) NOT NULL,otcblm numeric(5,2) NOT NULL DEFAULT 0,otcbagm numeric(5,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('otcblp numeric(5,2) NOT NULL DEFAULT 0,otcbagp numeric(5,2) NOT NULL DEFAULT 0,otcblr numeric(5,2) NOT NULL DEFAULT 0,otcbagr numeric(5,2) NOT NULL DEFAULT 0,otcblg numeric(5,2) NOT NULL DEFAULT 0,otcbagg numeric(5,2) NOT NULL DEFAULT 0,komotd numeric(10,2) NOT NULL DEFAULT 0,med numeric(10,2) NOT NULL DEFAULT 0,ubor numeric(10,2) NOT NULL DEFAULT 0,stop numeric(10,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('disp numeric(10,2) NOT NULL DEFAULT 0,voin numeric(5,2) NOT NULL DEFAULT 0,lgot numeric(5,2) NOT NULL DEFAULT 0,dopus numeric(5,2) NOT NULL DEFAULT 0,vidar character(200) NOT NULL,sumar numeric(20,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('shtr1 numeric(10,2) NOT NULL DEFAULT 0,shtr11 numeric(10,2) NOT NULL DEFAULT 0,shtr12 numeric(10,2) NOT NULL DEFAULT 0,shtr13 numeric(10,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('shtr2 numeric(10,2) NOT NULL DEFAULT 0,shtr21 numeric(10,2) NOT NULL DEFAULT 0,shtr22 numeric(10,2) NOT NULL DEFAULT 0,shtr23 numeric(10,2) NOT NULL DEFAULT 0,shtr24 numeric(10,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('shtr3 numeric(10,2) NOT NULL DEFAULT 0,shtr4 numeric(10,2) NOT NULL DEFAULT 0,shtr41 numeric(10,2) NOT NULL DEFAULT 0,shtr42 numeric(10,2) NOT NULL DEFAULT 0,shtr43 numeric(10,2) NOT NULL DEFAULT 0,shtr44 numeric(10,2) NOT NULL DEFAULT 0,shtr45 numeric(10,2) NOT NULL DEFAULT 0,');
  //ZQuery1.SQL.Add('shtr5 numeric(10,2) NOT NULL DEFAULT 0,shtr6 numeric(10,2) NOT NULL DEFAULT 0,shtr7 numeric(10,2) NOT NULL DEFAULT 0,edizm1 character(20) NOT NULL,edizm11 character(20) NOT NULL,edizm12 character(20) NOT NULL,edizm13 character(20) NOT NULL,');
  //ZQuery1.SQL.Add('edizm2 character(20) NOT NULL,edizm21 character(20) NOT NULL,edizm22 character(20) NOT NULL,edizm23 character(20) NOT NULL,edizm24 character(20) NOT NULL,edizm3 character(20) NOT NULL,');
  //ZQuery1.SQL.Add('edizm4 character(20) NOT NULL,edizm41 character(20) NOT NULL,edizm42 character(20) NOT NULL,edizm43 character(20) NOT NULL,edizm44 character(20) NOT NULL,edizm45 character(20) NOT NULL,');
  //ZQuery1.SQL.Add('edizm5 character(20) NOT NULL,edizm6 character(20) NOT NULL,edizm7 character(20) NOT NULL,shtr8 numeric(10,2) NOT NULL DEFAULT 0,edizm8 character(20) NOT NULL
  ZQuery1.SQL.Add('otcblp numeric(5,2) NOT NULL DEFAULT 0,otcbagp numeric(5,2) NOT NULL DEFAULT 0,komotd numeric(10,2) NOT NULL DEFAULT 0,med numeric(10,2) NOT NULL DEFAULT 0,ubor numeric(10,2) NOT NULL DEFAULT 0,stop numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('disp numeric(10,2) NOT NULL DEFAULT 0,voin numeric(5,2) NOT NULL DEFAULT 0,lgot numeric(5,2) NOT NULL DEFAULT 0,dopus numeric(5,2) NOT NULL DEFAULT 0,vidar character(200) NOT NULL,sumar numeric(20,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr1 numeric(10,2) NOT NULL DEFAULT 0,shtr11 numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr2 numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr3 numeric(10,2) NOT NULL DEFAULT 0,shtr4 numeric(10,2) NOT NULL DEFAULT 0,shtr41 numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr5 numeric(10,2) NOT NULL DEFAULT 0,shtr6 numeric(10,2) NOT NULL DEFAULT 0,shtr7 numeric(10,2) NOT NULL DEFAULT 0,edizm1 character(20) NOT NULL,edizm11 character(20) NOT NULL,');
  ZQuery1.SQL.Add('edizm2 character(20) NOT NULL,edizm3 character(20) NOT NULL,');
  ZQuery1.SQL.Add('edizm4 character(20) NOT NULL,edizm41 character(20) NOT NULL,');
  ZQuery1.SQL.Add('edizm5 character(20) NOT NULL,edizm6 character(20) NOT NULL,edizm7 character(20) NOT NULL,shtr8 numeric(10,2) NOT NULL DEFAULT 0,edizm8 character(20) NOT NULL,');
  ZQuery1.SQL.Add('otcblr numeric(5,2) NOT NULL DEFAULT 0,otcbagr numeric(5,2) NOT NULL DEFAULT 0,otcblg numeric(5,2) NOT NULL DEFAULT 0,otcbagg numeric(5,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr12 numeric(10,2) NOT NULL DEFAULT 0,shtr13 numeric(10,2) NOT NULL DEFAULT 0,shtr21 numeric(10,2) NOT NULL DEFAULT 0,shtr22 numeric(10,2) NOT NULL DEFAULT 0,shtr23 numeric(10,2) NOT NULL DEFAULT 0,shtr24 numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('shtr42 numeric(10,2) NOT NULL DEFAULT 0,shtr43 numeric(10,2) NOT NULL DEFAULT 0,shtr44 numeric(10,2) NOT NULL DEFAULT 0,shtr45 numeric(10,2) NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('edizm12 character(20) NOT NULL,edizm13 character(20) NOT NULL,edizm21 character(20) NOT NULL,edizm22 character(20) NOT NULL,edizm23 character(20) NOT NULL,edizm24 character(20) NOT NULL,');
  ZQuery1.SQL.Add('edizm42 character(20) NOT NULL,edizm43 character(20) NOT NULL,edizm44 character(20) NOT NULL,edizm45 character(20) NOT NULL');
  ZQuery1.SQL.Add(') WITH (OIDS=FALSE);');
  ZQuery1.ExecSQL;

  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('insert into '+ ttabl1+' SELECT (select c.id from av_spr_kontr_dog c where c.del=0 and c.kod1c=a.kod1c and c.kodkont=a.kodkont order by c.createdate limit 1) as id ');
  ZQuery1.SQL.Add(',(select c.id from av_spr_kontragent c where c.del=0 and c.kod1c=kodkont order by c.createdate limit 1) as id_kontr ');
  ZQuery1.SQL.Add(',0 as del,now() as createdate,'+GLuser+' as id_user,NULL as createdate_first,NULL as id_user_first,* ');
  ZQuery1.SQL.add('FROM av_1c_kontr_dog as a '+widezap);
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

   //*** помечаем на удаление устаревшие записи
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('UPDATE av_spr_kontr_dog SET del=1,id_user='+GLuser+',createdate=default WHERE del=0 AND kod1c>0 AND id IN (');
  ZQuery1.SQL.add('Select id FROM av_spr_kontr_dog AS a WHERE EXISTS(');
  ZQuery1.SQL.add('Select kodkont,kod1c from '+ ttabl1+' AS b WHERE a.kod1c=b.kod1c AND b.kodkont=a.kodkont));');
  //showmessage(ZQuery1.SQL.text);//$
  //ZQuery1.ExecSQL;

  //добавляем новые записи в таблицу договоров
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('INSERT INTO av_spr_kontr_dog (id,del,createdate,id_user,createdate_first,id_user_first,kodkont,kod1c,name,datazak,datavoz,datapog,val,datanacsh,dataprsh,stav,viddog,podr,otcblm,');
  ZQuery1.SQL.add('otcbagm,otcblp,otcbagp,otcblr,otcbagr,otcblg,otcbagg,komotd,med,ubor,stop,disp,voin,lgot,dopus,vidar,sumar,shtr1,shtr11,shtr12,shtr13,shtr2,shtr21,shtr22,shtr23,shtr24,shtr3,');
  ZQuery1.SQL.add('shtr4,shtr41,shtr42,shtr43,shtr44,shtr45,shtr5,shtr6,shtr7,shtr8,edizm1,edizm11,edizm12,edizm13,edizm2,edizm21,edizm22,edizm23,edizm24,edizm3,edizm4,edizm41,edizm42,edizm43,edizm44,edizm45,edizm5,edizm6,edizm7,edizm8,id_kontr) ');
  ZQuery1.SQL.add('SELECT a.id,0,a.createdate,a.id_user,NULL,NULL,a.kodkont,a.kod1c,a.name,a.datazak,a.datavoz,a.datapog,a.val,a.datanacsh,a.dataprsh,a.stav,a.viddog,a.podr,a.otcblm,a.otcbagm,a.otcblp,a.otcbagp,a.otcblr,a.otcbagr,a.otcblg,a.otcbagg,');
  ZQuery1.SQL.add('a.komotd,a.med,a.ubor,a.stop,a.disp,a.voin,a.lgot,a.dopus,a.vidar,a.sumar,a.shtr1,a.shtr11,a.shtr12,a.shtr13,a.shtr2,a.shtr21,a.shtr22,a.shtr23,a.shtr24,a.shtr3,a.shtr4,a.shtr41,');
  ZQuery1.SQL.add('a.shtr42,a.shtr43,a.shtr44,a.shtr45,a.shtr5,a.shtr6,a.shtr7,a.shtr8,a.edizm1,a.edizm11,a.edizm12,a.edizm13,a.edizm2,a.edizm21,a.edizm22,a.edizm23,a.edizm24,a.edizm3,a.edizm4,a.edizm41,a.edizm42,a.edizm43,a.edizm44,a.edizm45,a.edizm5,a.edizm6,a.edizm7,a.edizm8 ');
  //ZQuery1.SQL.Add(',(SELECT id FROM av_spr_kontragent WHERE a.kodkont=kod1c AND del=0 ORDER BY createdate desc limit 1) as id_kontr');
  ZQuery1.SQL.add(',id_kontr FROM '+ ttabl1+' as a '); //JOIN av_spr_kontragent AS b ON a.kodkont=b.kod1c AND b.del=0
  ZQuery1.SQL.add('order by a.id;');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  // Завершение транзакции
   //Zconnection1.Commit;//$
   Memo1.Append('ДОГОВОРА. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   writeln(filetxt,'ДОГОВОРА. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bDog:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;

  If bDog=0 then
  begin
     Memo1.Append('Изменений в справочнике договоров НЕ ОБНАРУЖЕНО!');
     writeln(filetxt,'Изменений в справочнике договоров НЕ ОБНАРУЖЕНО!');
   end;

  end;//$
   //****************  ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT kodkont,kod1c ');
   ZQuery1.SQL.add('FROM av_1c_kontr_dog a WHERE');
   szap:=' NOT EXISTS'
   +' (SELECT distinct b.kodkont,b.kod1c FROM av_spr_kontr_dog AS b WHERE b.kodkont=a.kodkont AND b.kod1c=a.kod1c AND b.del=0) '
//   +' AND ((case when trim(a.viddog)='''' then ''0'' else a.viddog end)::integer)=2'
   +' and a.kodkont in (select distinct kod1c from av_spr_kontragent where del=0) '
   +' AND a.datapog>=current_date '
   +' order by a.kodkont';
   ZQuery1.SQL.add(szap);
   ZQuery1.SQL.add(' limit 1;');
  //showmessage(ZQuery1.SQL.text);//$
   try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;
   if ZQuery1.RecordCount=0 then Memo1.Append('Новых договоров НЕ ОБНАРУЖЕНО !');
   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
   try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x03'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x03'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmp2Dog'+stim; //+IntToStr(chislo);

  //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
                //ZQuery1.SQL.Add('CREATE TABLE '+ ttabl1 +' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(200) NOT NULL,datazak date,datavoz date,datapog date,');
  ZQuery1.SQL.Add('CREATE TABLE '+ ttabl1 +' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(200) NOT NULL,datazak date,datavoz date,datapog date,');
   ZQuery1.SQL.Add('val character(20) NOT NULL,datanacsh date,dataprsh date,stav numeric(5,2) NOT NULL DEFAULT 0,viddog character(20) NOT NULL,podr character(100) NOT NULL,otcblm numeric(5,2) NOT NULL DEFAULT 0,otcbagm numeric(5,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('otcblp numeric(5,2) NOT NULL DEFAULT 0,otcbagp numeric(5,2) NOT NULL DEFAULT 0,komotd numeric(10,2) NOT NULL DEFAULT 0,med numeric(10,2) NOT NULL DEFAULT 0,ubor numeric(10,2) NOT NULL DEFAULT 0,stop numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('disp numeric(10,2) NOT NULL DEFAULT 0,voin numeric(5,2) NOT NULL DEFAULT 0,lgot numeric(5,2) NOT NULL DEFAULT 0,dopus numeric(5,2) NOT NULL DEFAULT 0,vidar character(200) NOT NULL,sumar numeric(20,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr1 numeric(10,2) NOT NULL DEFAULT 0,shtr11 numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr2 numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr3 numeric(10,2) NOT NULL DEFAULT 0,shtr4 numeric(10,2) NOT NULL DEFAULT 0,shtr41 numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr5 numeric(10,2) NOT NULL DEFAULT 0,shtr6 numeric(10,2) NOT NULL DEFAULT 0,shtr7 numeric(10,2) NOT NULL DEFAULT 0,edizm1 character(20) NOT NULL,edizm11 character(20) NOT NULL,');
   ZQuery1.SQL.Add('edizm2 character(20) NOT NULL,edizm3 character(20) NOT NULL,');
   ZQuery1.SQL.Add('edizm4 character(20) NOT NULL,edizm41 character(20) NOT NULL,');
   ZQuery1.SQL.Add('edizm5 character(20) NOT NULL,edizm6 character(20) NOT NULL,edizm7 character(20) NOT NULL,shtr8 numeric(10,2) NOT NULL DEFAULT 0,edizm8 character(20) NOT NULL,');
   ZQuery1.SQL.Add('otcblr numeric(5,2) NOT NULL DEFAULT 0,otcbagr numeric(5,2) NOT NULL DEFAULT 0,otcblg numeric(5,2) NOT NULL DEFAULT 0,otcbagg numeric(5,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr12 numeric(10,2) NOT NULL DEFAULT 0,shtr13 numeric(10,2) NOT NULL DEFAULT 0,shtr21 numeric(10,2) NOT NULL DEFAULT 0,shtr22 numeric(10,2) NOT NULL DEFAULT 0,shtr23 numeric(10,2) NOT NULL DEFAULT 0,shtr24 numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('shtr42 numeric(10,2) NOT NULL DEFAULT 0,shtr43 numeric(10,2) NOT NULL DEFAULT 0,shtr44 numeric(10,2) NOT NULL DEFAULT 0,shtr45 numeric(10,2) NOT NULL DEFAULT 0,');
   ZQuery1.SQL.Add('edizm12 character(20) NOT NULL,edizm13 character(20) NOT NULL,edizm21 character(20) NOT NULL,edizm22 character(20) NOT NULL,edizm23 character(20) NOT NULL,edizm24 character(20) NOT NULL,');
   ZQuery1.SQL.Add('edizm42 character(20) NOT NULL,edizm43 character(20) NOT NULL,edizm44 character(20) NOT NULL,edizm45 character(20) NOT NULL');
   ZQuery1.SQL.Add(') WITH (OIDS=FALSE);');
    //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('insert into '+ttabl1+' SELECT row_number() over (order by kodkont)+coalesce((select max(id) from av_spr_kontr_dog),0) as id, c.id as id_kontr,');
  ZQuery1.SQL.Add('a.kodkont,a.kod1c,a.name,a.datazak,a.datavoz,a.datapog,a.val,a.datanacsh,dataprsh,a.stav,a.viddog,a.podr,a.otcblm,a.otcbagm,a.otcblp,a.otcbagp,');
  ZQuery1.SQL.Add('a.komotd,a.med,a.ubor,a.stop,a.disp,a.voin,a.lgot,a.dopus,a.vidar,a.sumar,shtr1,a.shtr11,a.shtr2,a.shtr3,a.shtr4,a.shtr41,a.shtr5,a.shtr6,a.shtr7,');
  ZQuery1.SQL.Add('a.edizm1,a.edizm11,a.edizm2,a.edizm3,a.edizm4,a.edizm41,a.edizm5,a.edizm6,a.edizm7,a.shtr8,a.edizm8,a.otcblr,a.otcbagr,a.otcblg,a.otcbagg,a.shtr12,');
  ZQuery1.SQL.Add('a.shtr13,a.shtr21,a.shtr22,a.shtr23,a.shtr24,a.shtr42,a.shtr43,a.shtr44,a.shtr45,a.edizm12,a.edizm13,a.edizm21,a.edizm22,a.edizm23,a.edizm24,a.edizm42,a.edizm43,a.edizm44,a.edizm45');
  ZQuery1.SQL.Add(' FROM av_1c_kontr_dog a,av_spr_kontragent c WHERE c.del=0 and c.kod1c=a.kodkont and '+szap);
   //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  //кол-во строк до заполнения
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT COUNT(*) FROM av_spr_kontr_dog;');
  ZQuery1.Open;
  kolvo:=0;
  if ZQuery1.RecordCount>0 then
   kolvo:= ZQuery1.FieldByName('count').AsInteger;

  //добавляем новые записи в таблицу договоров
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('INSERT INTO av_spr_kontr_dog (id,del,createdate,id_user,createdate_first,id_user_first,kodkont,kod1c,name,datazak,datavoz,datapog,val,datanacsh,dataprsh,stav,viddog,podr,otcblm,');
  ZQuery1.SQL.add('otcbagm,otcblp,otcbagp,komotd,med,ubor,stop,disp,voin,lgot,dopus,vidar,sumar,shtr1,shtr11,shtr2,shtr3,shtr4,shtr41,shtr5,shtr6,shtr7,shtr8,edizm1,edizm11,edizm2,edizm3,edizm4,edizm41,edizm5,edizm6,edizm7,edizm8,id_kontr,');
  ZQuery1.SQL.add('otcblr,otcbagr,otcblg,otcbagg,shtr12,shtr13,shtr21,shtr22,shtr23,shtr24,shtr42,shtr43,shtr44,shtr45,edizm12,edizm13,edizm21,edizm22,edizm23,edizm24,edizm42,edizm43,edizm44,edizm45) ');
  ZQuery1.SQL.add('SELECT a.id,0,now(),'+GLuser+',now(),'+GLuser+',a.kodkont,a.kod1c,a.name,a.datazak,a.datavoz,a.datapog,a.val,a.datanacsh,a.dataprsh,a.stav,a.viddog,a.podr,a.otcblm,a.otcbagm,a.otcblp,a.otcbagp,');
  ZQuery1.SQL.add('a.komotd,a.med,a.ubor,a.stop,a.disp,a.voin,a.lgot,a.dopus,a.vidar,a.sumar,a.shtr1,a.shtr11,a.shtr2,a.shtr3,a.shtr4,a.shtr41,a.shtr5,a.shtr6,a.shtr7,a.shtr8,a.edizm1,a.edizm11,a.edizm2,a.edizm3,a.edizm4,a.edizm41,a.edizm5,a.edizm6,a.edizm7,a.edizm8,id_kontr, ');
  ZQuery1.SQL.add('a.otcblr,a.otcbagr,a.otcblg,a.otcbagg,a.shtr12,a.shtr13,a.shtr21,a.shtr22,a.shtr23,a.shtr24,a.shtr42,a.shtr43,a.shtr44,a.shtr45,a.edizm12,a.edizm13,a.edizm21,a.edizm22,a.edizm23,a.edizm24,a.edizm42,a.edizm43,a.edizm44,a.edizm45 ');
  ZQuery1.SQL.add(' FROM '+ ttabl1 +' as a order by a.id;');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  // Завершение транзакции
   Zconnection1.Commit;
   Memo1.Append('ДОГОВОРА. Транзакция завершена УСПЕШНО !');


       bDog:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;

   ZQuery1.close;

   //кол-во строк after заполнения
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('SELECT COUNT(*) FROM av_spr_kontr_dog;');
  ZQuery1.Open;
  if ZQuery1.RecordCount>0 then
   kolvo:= ZQuery1.FieldByName('count').AsInteger - kolvo;
  ZQuery1.close;
  Memo1.Append('ДОГОВОРА. Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
  writeln(filetxt,'ДОГОВОРА. Транзакция завершена УСПЕШНО !'+#13+'Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   //Zconnection1.disconnect;
   kolvo:=0;
  end;
 //  **************************************************


  end;
//**************************************************


 //***************************************************************** ВИДЫ ДОГОВОРОВ ***************************************************
 If (trim(Stringgrid1.Cells[0,y])='av_spr_kontr_viddog') AND (StringGrid1.Cells[StringGrid1.Col,y]='*') then
 begin
  Memo1.Append('Обновление справочника ВИДОВ договоров...');
   writeln(filetxt,'Обновление справочника ВИДОВ договоров...');
 //ищем удаленных из 1С   ****************************************
   szap:='Select a.id,a.name,a.kod1c FROM av_spr_kontr_viddog as a WHERE a.del=0 AND a.kod1c>0 AND NOT EXISTS (SELECT kod1c FROM av_1c_viddog AS b WHERE b.kod1c=a.kod1c AND a.kod1c>0)';
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.Add(szap+';');
   //showmessage(ZQuery1.SQL.Text);//$
   try
      ZQuery1.Open;
   except
       Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
       writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
       closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;

  if ZQuery1.RecordCount>0 then
  begin
  writeln(filetxt,'!!! В ЗАГРУЖАЕМОМ СПРАВОЧНИКЕ ОТСУТСТВУЮТ СЛЕДУЮЩИЕ ЗАПИСИ... !!!');
  for n:=1 to ZQuery1.RecordCount do
     begin
       writeln(filetxt,ZQuery1.FieldByName('id').AsString+'  '+ZQuery1.FieldByName('name').AsString+'  kod1c='+ZQuery1.FieldByName('kod1c').AsString);
       ZQuery1.Next;
     end;
  writeln(filetxt,'===================================================================');

   //Открываем транзакцию
  // try
  // If not Zconnection1.InTransaction then
  //    Zconnection1.StartTransaction
  // else
  //   begin
  //    Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
  //    writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
  //    closefile(filetxt);
  //    ZConnection1.Rollback;
  //    ZQuery1.Close;
  //    ZConnection1.Disconnect;
  //    exit;
  //   end;
  // kolvo:=ZQuery1.RecordCount;
  // //помечаем на удаление
  // ZQuery1.SQL.Clear;
  // ZQuery1.SQL.Add('UPDATE av_spr_kontr_viddog SET del=2,id_user='+GLuser+',createdate=default WHERE del=0 AND id IN ('+szap+');');
  // szap:='';
  // ZQuery1.ExecSQL;
  //
  ////Завершение транзакции
  //Zconnection1.Commit;
  // Memo1.Append('Виды ДОГОВОРОВ. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
  // writeln(filetxt,'Виды ДОГОВОРОВ. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
  //     kolvo:=0;
  //     bDog:=1;
  //     ZQuery1.Close;
  // except
  //   ZConnection1.Rollback;
  //   Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
  //   writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
  // end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;

  //ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT kod1c FROM av_1c_viddog AS a ');
   szap:='WHERE a.kod1c>0 AND trim(a.name)!='''' AND NOT EXISTS (SELECT kod1c FROM av_spr_kontr_viddog AS b WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0);';
   ZQuery1.SQL.add(szap);
  // showmessagealt(ZQuery1.SQL.text);
   try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;
   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
   try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x05'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x05'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmpViddog'+stim; //IntToStr(chislo);

  //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
  //ZQuery1.SQL.Add('CREATE TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL) WITH (OIDS=FALSE);');
  ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL) WITH (OIDS=FALSE);');
   //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;
  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl1+' SELECT row_number() over (order by a.kod1c)+coalesce((select max(id) from av_spr_kontr_viddog),0) as id,* FROM av_1c_viddog AS a '+szap);
  ZQuery1.ExecSQL;
  //добавляем новые записи в таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontr_viddog(id,kod1c,name,id_user,createdate,id_user_first,createdate_first,del) ');
  ZQuery1.SQL.Add('SELECT id,kod1c,name,'+GLuser+',now(),'+GLuser+',now(),0 as del FROM '+ttabl1+';');
  ZQuery1.ExecSQL;

  //Завершение транзакции
  Zconnection1.Commit;
   Memo1.Append('Виды Договоров. Транзакция завершена УСПЕШНО !'+#13+'Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   writeln(filetxt,'Виды Договоров. Транзакция завершена УСПЕШНО !'+#13+'Добавлено  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bVid:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;
//****************************************************************************************************************
//ищем отредактированные в 1С  ************************************************

  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('Select a.kodkont,a.kod1c FROM av_1c_kontr_dog AS a ');
   szap :='WHERE NOT EXISTS (SELECT b.kodkont FROM av_spr_kontr_viddog AS b WHERE b.name=a.name AND b.kod1c=a.kod1c AND b.kod1c>0 AND b.del=0 );';
  ZQuery1.SQL.add(widezap);
 // showmessagealt(ZQuery1.SQL.text);

  try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;

   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
   try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x06'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x06'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmpViddog'+stim; //+IntToStr(chislo);

  //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
//  ZQuery1.SQL.Add('CREATE TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL) WITH (OIDS=FALSE);');
  ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,name character(100) NOT NULL) WITH (OIDS=FALSE);');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl1+' SELECT 0 as id,kod1c,name FROM av_1c_viddog AS a '+szap);
  ZQuery1.ExecSQL;

   //*** помечаем на удаление устаревшие записи
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.add('UPDATE av_spr_kontr_viddog SET del=1,id_user='+GLuser+',createdate=default WHERE del=0 AND kod1c>0 AND id IN (');
  ZQuery1.SQL.add('Select id FROM av_spr_kontr_viddog AS a WHERE EXISTS(');
  ZQuery1.SQL.add('Select kod1c from '+ ttabl1+' AS b WHERE a.kod1c=b.kod1c));');
  ZQuery1.ExecSQL;

  //добавляем новые записи в таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontr_viddog(id,kod1c,name,id_user,createdate,id_user_first,createdate_first,del) ');
  ZQuery1.SQL.Add('SELECT b.id,a.kod1c,a.name,'+GLuser+',now(),NULL,NULL,0 as del FROM '+ttabl1+' as a ');
  ZQuery1.SQL.add('JOIN av_spr_kontr_viddog AS b ON a.kod1c=b.kod1c AND b.del=0 order by a.id;');
  ZQuery1.ExecSQL;

  //Завершение транзакции
  Zconnection1.Commit;
   Memo1.Append('Виды ДОГОВОРОВ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   writeln(filetxt,'Виды ДОГОВОРОВ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bVid:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;
  If bVid=0 then
  begin
     Memo1.Append('Изменений в справочнике видов договоров НЕ ОБНАРУЖЕНО!');
    writeln(filetxt,'Изменений в справочнике видов договоров НЕ ОБНАРУЖЕНО!');
    end;
   end;
 //===============================================================================

//***************************************************************** ЛИЦЕНЗИИ ***************************************************
If (trim(Stringgrid1.Cells[0,y])='av_spr_kontr_license') AND (StringGrid1.Cells[StringGrid1.Col,y]='*') then
begin
   Memo1.Append('Обновление справочника ЛИЦЕНЗИЙ...');
   writeln(filetxt,'Обновление справочника ЛИЦЕНЗИЙ...');
//ищем удаленных из 1С   ****************************************
  szap:='Select a.id,a.id_kontr,a.kod1c FROM av_spr_kontr_license as a WHERE a.del=0 AND a.kod1c>0 AND '+
  'a.kod1c not in (SELECT kod1c FROM av_1c_license AS b WHERE b.kod1c=a.kod1c AND b.kodkont=a.kodkont AND a.kod1c>0)';
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add(szap+';');
  //showmessage(ZQuery1.SQL.text);//$
  try
     ZQuery1.Open;
  except
      Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
      writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
      closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
  end;

 if ZQuery1.RecordCount>0 then
 begin
 writeln(filetxt,'!!! В ЗАГРУЖАЕМОМ СПРАВОЧНИКЕ ОТСУТСТВУЮТ СЛЕДУЮЩИЕ ЗАПИСИ... !!!');
  for n:=1 to ZQuery1.RecordCount do
     begin
       writeln(filetxt,ZQuery1.FieldByName('id').AsString+'  id_kontr='+ZQuery1.FieldByName('id_kontr').AsString+'  kod1c='+ZQuery1.FieldByName('kod1c').AsString);
       ZQuery1.Next;
     end;
  writeln(filetxt,'===================================================================');
  //Открываем транзакцию
 // try
 //  If not Zconnection1.InTransaction then
 //     Zconnection1.StartTransaction
 //  else
 //    begin
 //     Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
 //     writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
 //     closefile(filetxt);
 //     ZConnection1.Rollback;
 //     ZQuery1.Close;
 //     ZConnection1.Disconnect;
 //     exit;
 //    end;
 // kolvo:=ZQuery1.RecordCount;
 // //помечаем на удаление
 // ZQuery1.SQL.Clear;
 // ZQuery1.SQL.Add('UPDATE av_spr_kontr_license SET del=2,id_user='+GLuser+',createdate=default WHERE del=0 AND id IN ('+szap+');');
 // szap:='';
 // ZQuery1.ExecSQL;
 //
 //// Завершение транзакции
 //Zconnection1.Commit;
 // Memo1.Append('Лицензии. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' записей !');
 // writeln(filetxt,'Лицензии. Транзакция завершена УСПЕШНО !'+#13+'УДАЛЕНО  '+intToStr(kolvo)+' записей !');
 //      kolvo:=0;
 //      bLic:=1;
 //      ZQuery1.Close;
 //  except
 //    ZConnection1.Rollback;
 //    Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 //    writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
 //  end;
   ZQuery1.close;
   //Zconnection1.disconnect;
 end;



//****************************************************************************************************************
//ищем отредактированные в 1С с датой окончания только больше/равно текущей ************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT a.kod1c,a.kodkont FROM av_spr_kontr_license AS b,av_1c_license AS a ');
   szap:='WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0 AND b.kodkont=a.kodkont AND trim(a.name)<>'''''+
   ' AND (coalesce(a.datanach,''01.01.2100'')<>coalesce(b.datanach,''01.01.2100'') OR a.name<>b.name '+
   ' OR coalesce(a.dataok,''01.01.2100'')>coalesce(b.dataok,''01.01.2100'')) ORDER BY kod1c;';
   //szap:='WHERE a.kod1c>0 AND trim(a.name)!='''' AND NOT EXISTS (SELECT kod1c FROM av_spr_kontr_license AS b WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0 AND '+
   //'b.kodkont=a.kodkont AND coalesce(a.datanach,''1.1.1970'')=coalesce(b.datanach,''1.1.1970'') AND coalesce(a.dataok,''1.1.1970'')=coalesce(b.dataok,''1.1.1970'')) ORDER BY kod1c;';
  ZQuery1.SQL.add(szap);
  //showmessage(ZQuery1.SQL.text);//$

  try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;

   if ZQuery1.RecordCount>0 then
   begin
   //Открываем транзакцию
  try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=chislo*StrToInt(stim);
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x08'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x08'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmp2Lic'+stim; //IntToStr(chislo);

   //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
  //ZQuery1.SQL.Add('CREATE TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('name character(200) NOT NULL,datanach date,dataok date not null default ''01-01-2100'') WITH (OIDS=FALSE);');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;
  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl1+' SELECT b.id,0 as id_kontr,a.kodkont,a.kod1c,a.name,a.datanach,coalesce(a.dataok,''01-01-2100'') FROM av_1c_license AS a, av_spr_kontr_license AS b '+szap);
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

   //*** помечаем на удаление устаревшие записи
  ZQuery1.SQL.Clear;
  //ZQuery1.SQL.add('UPDATE av_spr_kontr_license SET del=1,id_user='+GLuser+',createdate=default WHERE del=0 AND kod1c>0 AND id IN (');
  //ZQuery1.SQL.add('Select id FROM av_spr_kontr_license AS a WHERE EXISTS(');
  ZQuery1.SQL.add('UPDATE av_spr_kontr_license SET del=1,id_user='+GLuser+',createdate=default WHERE del=0 AND kod1c>0 AND EXISTS (');
  ZQuery1.SQL.add('Select kodkont,kod1c from '+ ttabl1+' AS b);');
  //WHERE kod1c=b.kod1c AND b.kodkont=kodkont and b.dataok>=dataok) ');
  //ZQuery1.SQL.add('AND kod1c IN (Select kod1c from '+ ttabl1+' AS b WHERE kod1c=b.kod1c AND b.kodkont=kodkont and b.dataok>=dataok); ');
 //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

   //добавляем новые записи в таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontr_license(id,kodkont,kod1c,name,datanach,dataok,id_user,createdate,id_user_first,createdate_first,del,id_kontr) ');
  ZQuery1.SQL.Add('SELECT a.id,a.kodkont,a.kod1c,a.name,a.datanach,a.dataok,'+GLuser+',now(),'+GLuser+',now(),0 as del ');
  ZQuery1.SQL.Add(',(SELECT id FROM av_spr_kontragent WHERE a.kodkont=kod1c AND del=0 ORDER BY createdate desc limit 1) as id_kontr ');
  ZQuery1.SQL.Add('FROM '+ttabl1+' as a WHERE a.dataok order by a.id;');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

   // Завершение транзакции
 Zconnection1.Commit;
   Memo1.Append('ЛИЦЕНЗИИ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   writeln(filetxt,'ЛИЦЕНЗИИ. Транзакция завершена УСПЕШНО !'+#13+'Отредактировано  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bLic:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;

  If bLic=0 then
  begin
     Memo1.Append('Изменений в справочнике лицензий НЕ ОБНАРУЖЕНО!');
   writeln(filetxt,'Изменений в справочнике лицензий НЕ ОБНАРУЖЕНО!');
   end;

  //ищем новые из 1С  ************************************************
   ZQuery1.SQL.Clear;
   ZQuery1.SQL.add('SELECT kod1c FROM av_1c_license AS a ');
   szap:='WHERE a.kod1c>0 AND trim(a.name)!='''' AND a.kod1c NOT IN (SELECT kod1c FROM av_spr_kontr_license AS b WHERE a.kod1c=b.kod1c AND b.del=0 AND b.kod1c>0) ORDER BY kod1c;';
   ZQuery1.SQL.add(szap);
  //showmessage(ZQuery1.SQL.text);//$
   try
    ZQuery1.Open;
   except
    Memo1.Append('ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    writeln(filetxt,'ОШИБКА  ЗАПРОСА !!!'+#13+ZQuery1.SQL.Text);
    closefile(filetxt);
      ZQuery1.Close;
      ZConnection1.Disconnect;
    exit;
   end;
   if ZQuery1.RecordCount>0 then
   begin
  //Открываем транзакцию
  try
   If not Zconnection1.InTransaction then
      Zconnection1.StartTransaction
   else
     begin
      Memo1.Append('Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      writeln(filetxt,'Ошибка ! Незавершенная транзакция !'+#13+'Попробуйте снова !');
      closefile(filetxt);
      ZConnection1.Rollback;
      ZQuery1.Close;
      ZConnection1.Disconnect;
      exit;
     end;
   kolvo:=ZQuery1.RecordCount;
   DateTimeToString(stim,'yymmdd_hhnnzzz',now);
   //Randomize;
   //chislo:=Random(200)+1;
   //try
   //chislo:=ABS(chislo*StrToInt(stim));
   //except
   //    on exception: EConvertError do
   //    begin
   //    Memo1.Append('ОШИБКА КОНВЕРТАЦИИ !!!'+'x07'+#13+'Значение: ' + stim);
   //    writeln(filetxt,'ОШИБКА КОНВЕРТАЦИИ !!!'+'x07'+#13+'Значение: ' + stim);
   //    closefile(filetxt);
   //   ZConnection1.Rollback;
   //   ZQuery1.Close;
   //   ZConnection1.Disconnect;
   //    exit;
   //    end;
   //end;
   ttabl1:='tmpLic'+stim; //IntToStr(chislo);

  //cоздаем временную таблицу для новых записей
  ZQuery1.SQL.Clear;
  //ZQuery1.SQL.Add('CREATE TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('CREATE LOCAL TEMPORARY TABLE '+ttabl1+' (id integer NOT NULL DEFAULT 0,id_kontr integer NOT NULL DEFAULT 0,kodkont integer NOT NULL DEFAULT 0,kod1c integer NOT NULL DEFAULT 0,');
  ZQuery1.SQL.Add('name character(200) NOT NULL,datanach date,dataok date not null default ''01-01-2100'') WITH (OIDS=FALSE);');
  ZQuery1.ExecSQL;
  //добавляем новые записи во временную таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO '+ttabl1+' SELECT row_number() over (order by a.kod1c)+coalesce((select max(id) from av_spr_kontr_license),0) as id,0 as id_kontr,a.kodkont,a.kod1c,a.name,a.datanach,Coalesce(a.dataok,''01-01-2100'') FROM av_1c_license AS a '+szap);
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;
  //добавляем новые записи в таблицу
  ZQuery1.SQL.Clear;
  ZQuery1.SQL.Add('INSERT INTO av_spr_kontr_license(id,kodkont,kod1c,name,datanach,dataok,id_user,createdate,id_user_first,createdate_first,del,id_kontr) ');
  ZQuery1.SQL.Add('SELECT a.id,a.kodkont,a.kod1c,a.name,a.datanach,a.dataok,'+GLuser+',now(),'+GLuser+',now(),0 as del ');
  ZQuery1.SQL.Add(',(SELECT id FROM av_spr_kontragent WHERE a.kodkont=kod1c AND del=0 ORDER BY createdate desc limit 1) as id_kontr');
  ZQuery1.SQL.Add('FROM '+ttabl1+' as a order by a.id;');
  //showmessage(ZQuery1.SQL.text);//$
  ZQuery1.ExecSQL;

  // Завершение транзакции
 Zconnection1.Commit;
   Memo1.Append('ЛИЦЕНЗИИ. Транзакция завершена УСПЕШНО !'+#13+'ДОБАВЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
   writeln(filetxt,'ЛИЦЕНЗИИ. Транзакция завершена УСПЕШНО !'+#13+'ДОБАВЛЕНО  '+intToStr(kolvo)+' ЗАПИСЕЙ !');
       kolvo:=0;
       bLic:=1;
       ZQuery1.Close;
   except
     ZConnection1.Rollback;
     Memo1.Append('Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
     writeln(filetxt,'Данные не записаны !'+#13+'Не удается завершить транзакцию !!!'+#13+'Запрос SQL: '+ZQuery1.SQL.Text);
   end;
   ZQuery1.close;
   //Zconnection1.disconnect;
  end;

   end;
//=======================================================================

//************************************************************************************************************
  ZQuery1.close;
  Zconnection1.disconnect;
    end;
   end;
  closefile(filetxt);
 //закончили идти по гриду
  UpdateGrid(1);
end;



procedure TFormUpdate.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState );
begin
 with FOrmUpdate do
 begin
    // F1
    if Key=112 then showmessagealt('[F1] - Справка'+#13+'[F5] - ОБНОВИТЬ'+#13+'[ESC] - Отмена\Выход');
    // F5 - ОБНОВИТЬ
    if (Key=116) and (BitBtn1.Enabled=true) then BitBtn1.Click;
    // ESC
    if Key=27 then FormUpdate.close;

   if (Key=112) or (Key=113) or (Key=120) or (Key=121) or (Key=27) then Key:=0;
 end;
end;

procedure TFormUpdate.FormShow(Sender: TObject);
begin
  centrform(FormUpdate);
  UpdateGrid(0);
  FormUpdate.memo1.clear;
end;

procedure TFormUpdate.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;  aRect: TRect; aState: TGridDrawState);
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
          TextOut(aRect.Left + 5, aRect.Top+5, Cells[aCol, aRow]);
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

procedure TFormUpdate.StringGrid1SelectCell(Sender: TObject; aCol,  aRow: Integer; var CanSelect: Boolean);
begin
  //************************ запрет выбора других ячеек кроме чекбокса ***********************************
  If (aCol<>2) then CanSelect:= false;
end;

procedure TFormUpdate.StringGrid1SetCheckboxState(Sender: TObject; ACol,  ARow: Integer; const Value: TCheckboxState);
begin
 with formUpdate do
  begin
  if (StringGrid1.Col=2) and (StringGrid1.row>0) and (StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]='') then
     StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:='*'
  else StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:='';
  end;
end;


end.


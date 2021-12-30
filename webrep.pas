unit webrep;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons,  ZConnection, ZDataset, LazUTF8;

type

  { TFormRep }

  TFormRep = class(TForm)
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormRep: TFormRep;

implementation
uses main,platproc,web_users;

var
  n:integer;
{$R *.lfm}

{ TFormRep }

procedure TFormRep.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //********************                    HOT KEYS  ******************************************
  With FormRep do
begin
    // F1
     if Key=112 then showmessage('F1 - Справка'+#13+'F2 - Печать'+#13+'ESC - Отмена\Выход');
       // ESC
    if Key=27 then BitBtn2.Click;
    if Key=113 then BitBtn1.Click;//сохранить в файл
  end;
end;


procedure TFormRep.FormShow(Sender: TObject);
const
  lenar=13;
  nlogin=15;
  nfull=30;
  nuname=20;
  nemail=30;
  nopt=40;
  nper=20;
  nusr=15;
var
  arweb: array of array of string;
  arkontr,arusr,aropt: array of string;
  m,i,len1,len2,len3,k,allstr:integer;
  str,stradd:string;
begin
   setlength(arweb,0,0);
 with FormRep do
   begin
     Memo1.Clear;

      // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      exit;
     end;

       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('Select u.* ');
       ZQuery1.SQL.add(',(Select a.name from av_users a where a.del=0 and a.id=u.kod order by a.createdate desc limit 1) uname ');
       ZQuery1.SQL.add('FROM av_web_users as u ');
       ZQuery1.SQL.add('WHERE u.del=0 ORDER BY u.id;');
    //showmessage(ZQuery1.SQL.Text);
 try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    Zconnection1.disconnect;
    exit;
  end;

   if ZQuery1.RecordCount=0 then
     begin
      ZQuery1.Close;
      Zconnection1.disconnect;
      exit;
     end;

 setlength(arweb,0,lenar);


   for n:=1 to ZQuery1.RecordCount do
   begin
      setlength(arweb,length(arweb)+1,lenar);
      arweb[length(arweb)-1,0]:=PADR(ZQuery1.FieldByName('id').asString,#32,3);
      arweb[length(arweb)-1,1]:=PADR(ZQuery1.FieldByName('login').asString,#32,nlogin);
      arweb[length(arweb)-1,2]:=PADR(utf8copy(ZQuery1.FieldByName('fullname').asString,1,30),#32,nfull);
      If ZQuery1.FieldByName('status').asinteger=1 then
      arweb[length(arweb)-1,3]:='  ДА  '
      else arweb[length(arweb)-1,3]:=' НЕТ  ';
      arweb[length(arweb)-1,4]:=PADR(utf8copy(ZQuery1.FieldByName('uname').asString,1,20),#32,nuname);
      arweb[length(arweb)-1,5]:=PADR(ZQuery1.FieldByName('category').asString,#32,12);
      arweb[length(arweb)-1,6]:=PADR(utf8copy(ZQuery1.FieldByName('email').asString,1,30),#32,nemail);
      arweb[length(arweb)-1,7]:=PADL(ZQuery1.FieldByName('sale_before').asString,#32,11);
      arweb[length(arweb)-1,8]:=PADL(ZQuery1.FieldByName('percent').asString,#32,3);
      arweb[length(arweb)-1,9]:=PADL(ZQuery1.FieldByName('sbor_sum').asString,#32,7);
      If ZQuery1.FieldByName('trip_zakaz').asBoolean then
            arweb[length(arweb)-1,10]:=stringofchar('*',8)
      else  arweb[length(arweb)-1,10]:=stringofchar(#32,8);
       If ZQuery1.FieldByName('trip_transit').asBoolean then
            arweb[length(arweb)-1,11]:=stringofchar('*',8)
      else  arweb[length(arweb)-1,11]:=stringofchar(#32,8);
        If ZQuery1.FieldByName('trip_virt').asBoolean then
            arweb[length(arweb)-1,12]:=stringofchar('*',8)
      else  arweb[length(arweb)-1,12]:=stringofchar(#32,8);

     ZQuery1.Next;
   end;
   //ZQuery1.Close;

     allstr:=length(StringOfChar(#32,3)+'|'+StringOfChar(#32,nlogin)+'|'+StringOfChar(#32,nfull)+'|'+StringOfChar(#32,6)+'|'+StringOfChar(#32,nuname)+'|'+StringOfChar(#32,12)+'|'+StringOfChar(#32,nemail)+'|'+StringOfChar(#32,11)+'|'+StringOfChar(#32,3)+'|'+StringOfChar(#32,7)+'|'+PADC('перевозчики',#32,nper)+'|'+PADC('пользователи',#32,nusr)+'|'+PADC('web-опции',#32,nopt));

     memo1.Append(StringOfChar('_', allstr));
     memo1.Append(' id|'+PADC('логин',#32,nlogin)+'|'+PADC('полное',#32,nfull)+'|актив-|'+PADC('пользователь',#32,nuname)+'|'+PADC('категория',#32,12)+'|'+PADC('почта',#32,nemail)+'|'+PADC('минут до',#32,11)+'|'+PADC('%',#32,3)+'|'+PADC('предвар',#32,7)+'|'+PADC('продажа на рейсы',#32,26)+'|'+PADC('перевозчики',#32,nper)+'|'+PADC('пользователи',#32,nusr)+'|'+PADC('web-опции',#32,nopt)+'|');
     memo1.Append(StringOfChar(#32,3)+'|'+StringOfChar(#32,nlogin)+'|'+PADC('наименование',#32,nfull)+'|ность |'+StringOfChar(#32,nuname)+'|'+StringOfChar(#32,12)+'|'+StringOfChar(#32,nemail)+'|'+PADC('отправления',#32,11)+'|'+PADC('%',#32,3)+'|'+PADC('сбор',#32,7)+'|'+'заказной| транзит|виртуал |'+PADC('platforma',#32,nper)+'|'+PADC('platforma',#32,nusr)+'|'+stringofchar(#32,nopt)+'|');

    for n:=low(arweb) to high(arweb) do
   begin
     memo1.Append(StringOfChar('-',allstr));
     str:='';
     setlength(arkontr,0);
     setlength(aropt,0);
     setlength(arusr,0);
     len1:=0;
     len2:=0;
     len3:=0;
     stradd:='';

     for m:=0 to lenar-1 do
     begin
       str:=str+arweb[n,m]+'|';
     end;
      memo1.Append(str);

     //перевозчики
       ZQuery1.SQL.Clear;
       ZQuery1.SQL.add('SELECT id_kontr as id,(select c.name from av_spr_kontragent c where c.del=0 and c.id=id_kontr order by c.createdate desc limit 1) cname ');
       ZQuery1.SQL.add('FROM av_web_users_kontr WHERE del=0 AND id_web='+arweb[n,0]);
    //showmessage(ZQuery1.SQL.Text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    continue;
  end;

   if ZQuery1.RecordCount>0 then
     begin
       len1:=ZQuery1.RecordCount;
      for i:=1 to len1 do
      begin
       setlength(arkontr,length(arkontr)+1);
       arkontr[length(arkontr)-1]:=PADR(utf8copy(ZQuery1.FieldByName('cname').asString,1,nper),#32,nper);
       ZQuery1.next;
      end;
     end;

     //пользователи
     ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT id_agent as id,(select c.name from av_users c where c.del=0 and c.id=id_agent order by c.createdate desc limit 1) cname ');
     ZQuery1.SQL.add('FROM av_web_users_agent WHERE del=0 AND id_web='+arweb[n,0]);
    //showmessage(ZQuery1.SQL.Text);
  try
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    ZQuery1.Close;
    continue;
  end;

   if ZQuery1.RecordCount>0 then
     begin
      len2:=ZQuery1.RecordCount;
      for i:=1 to len2 do
      begin
       setlength(arusr,length(arusr)+1);
       arusr[length(arusr)-1]:=PADR(utf8copy(ZQuery1.FieldByName('cname').asString,1,nusr),#32,nusr);
       ZQuery1.next;
      end;
     end;

   // опции
  try
   ZQuery1.SQL.Clear;
     ZQuery1.SQL.add('SELECT b.option_id, b.val1, b.val2 ');
     ZQuery1.SQL.add(',coalesce((SELECT a.oname FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(',''1'') as cname ');
     ZQuery1.SQL.add(',coalesce((SELECT a.rem1 FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(','''') as remark1 ');
     ZQuery1.SQL.add(',coalesce((SELECT a.rem2 FROM av_web_options as a where a.del=0 AND b.option_id=a.id ORDER BY a.createdate DESC Limit 1) ');
     ZQuery1.SQL.add(','''') as remark2 ');
     ZQuery1.SQL.add(' FROM av_web_user_options as b where b.del=0 and b.id_web='+arweb[n,0]);
     ZQuery1.SQL.add(' order by b.option_id ;');
  //If n=high(arweb) then showmessage(ZQuery1.SQL.Text);//$
   ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    continue;
  end;

  if ZQuery1.recordcount>0 then
      begin
       for i:=1 to ZQuery1.recordcount do
          begin
          len3:=len3+1;
          setlength(aropt,length(aropt)+1);
          aropt[length(aropt)-1]:=PADR(utf8copy(inttostr(i)+'. '+ZQuery1.FieldByName('cname').asString,1,nopt),#32,nopt);
        If trim(ZQuery1.FieldByName('val1').asString)<>'' then
            begin
             len3:=len3+1;
             setlength(aropt,length(aropt)+1);
              aropt[length(aropt)-1]:=PADR(utf8copy(ZQuery1.FieldByName('val1').asString+' :'+ZQuery1.FieldByName('remark1').asString,1,nopt),#32,nopt);
            end;
          If trim(ZQuery1.FieldByName('val2').asString)<>'' then
              begin
               len3:=len3+1;
               setlength(aropt,length(aropt)+1);
              aropt[length(aropt)-1]:=PADR(utf8copy(ZQuery1.FieldByName('val2').asString+' :'+ZQuery1.FieldByName('remark2').asString,1,nopt),#32,nopt);
              end;
            zquery1.Next;
          end;
      end;
//If n=high(arweb) then
  //for i:=1 to length(aropt) do
     //begin
         //showmessage(aropt[i-1]);
     //end;

   If len1>len2 then k:=len1 else k:=len2;
   If len3>k then k:=len3;
    if k=0 then continue;

   for i:=1 to k do
   begin
     stradd:=StringOfChar(#32,3)+'|'+StringOfChar(#32,nlogin)+'|'+StringOfChar(#32,nfull)+'|'+StringOfChar(#32,6)+'|'+StringOfChar(#32,nuname)+'|'+StringOfChar(#32,12)+'|'+StringOfChar(#32,nemail)+'|'+StringOfChar(#32,11)+'|'+StringOfChar(#32,3)+'|'+StringOfChar(#32,7)+'|'+StringOfChar(#32,8)+'|'+StringOfChar(#32,8)+'|'+StringOfChar(#32,8)+'|';
     If i<=len1 then
       stradd:=stradd+arkontr[i-1]+'|'
     else stradd:=stradd+stringofchar(#32,nper)+'|';
     If i<=len2 then
       stradd:=stradd+arusr[i-1]+'|'
     else stradd:=stradd+stringofchar(#32,nusr)+'|';
      If i<=len3 then
       stradd:=stradd+aropt[i-1]+'|'
     else stradd:=stradd+stringofchar(#32,nopt)+'|';

      memo1.Append(stradd);
   end;


   end;


    ZQuery1.Close;
   Zconnection1.disconnect;
   setlength(arweb,0,0);
   FreeAndNil(arweb);
   end;
end;


//СОХРАНИТЬ В ФАЙЛ
procedure TFormRep.BitBtn1Click(Sender: TObject);
begin
  formrep.SaveDialog1.Execute;
  formrep.Memo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TFormRep.BitBtn2Click(Sender: TObject);
begin
  FormRep.Close;
end;

end.


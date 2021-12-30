unit genagent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, IniPropStorage,LazUTF8;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn14: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Image1: TImage;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    selectpath1: TSelectDirectoryDialog;
    procedure BitBtn14Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
uses platproc,main;
{$R *.lfm}

{ TForm1 }

procedure TForm1.BitBtn14Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   n:integer;
   s:string='';
   s2:string='';
   k:integer=0;
   z:string='qwertyuiopasdfghjklzxcvbnm';
   tek:string='';
   mas_kod:array of string;
   mystr:string='';
begin
  if (trim(form1.Edit1.Text)='') or
     (trim(form1.Edit2.Text)='') or
     (trim(form1.Edit4.Text)='') or
     (trim(form1.Edit5.Text)='') or
     (trim(form1.Edit7.Text)='') or
     (trim(form1.Edit6.Text)='') then
     begin
       showmessage('Введены не все параметры для расчета HASH !!!');
       form1.Label8.Caption:='';
       exit;
     end;
  mystr:=trim(form1.Edit1.text)+'*'+trim(form1.Edit2.text)+'*'+trim(form1.Edit4.text)+'*'+trim(form1.Edit5.text)+'*'+trim(form1.Edit6.text)+'*'+trim(form1.Edit7.text)+'*';
  for n:=1 to UTF8length(trim(mystr)) do
     begin
       s:=s+inttostr(ord(UTF8copy(trim(mystr),n,1)[1]))+UTF8Copy(z,random(25)+1,1);
     end;
  SetLength(mas_kod,0);
  for n:=1 to UTF8length(s) do
     begin
           if not((UTF8copy(s,n,1)[1]) in ['0'..'9']) then
             begin
               SetLength(mas_kod,length(mas_kod)+1);
               mas_kod[length(mas_kod)-1]:=tek;
               tek:='';
             end
           else
             begin
              tek:=tek+UTF8copy(s,n,1);
             end;
     end;

  form1.Label8.Caption:=s;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if form1.selectpath1.Execute then
    begin
      if form1.selectpath1.FileName<>'' then form1.edit3.Text:=form1.selectpath1.FileName+'/agent.ini' else form1.edit3.Text:='';
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  form1.Button1.Click;
  if trim(form1.Label8.Caption)='' then
     begin
       showmessage('Невозможно создать файл , так как не заполнено поле HASH !');
       exit;
     end;
  if trim(form1.edit3.text)='' then
     begin
       showmessage('Выберите путь для сохранения файла agent.ini');
       exit;
     end;

  // Формируем agent.ini
  SaveAgentIni(form1.IniPropStorage1,trim(form1.edit3.text),form1.Label8.Caption);
  showmessage('Файл '+trim(form1.edit3.text)+' записан !');

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if trim(form1.edit3.text)='' then
     begin
       showmessage('Выберите путь для проверки файла agent.ini');
       exit;
     end;
  // Разбираем agent.ini
  showmessage(ReadAgentIni(form1.IniPropStorage1,trim(form1.edit3.text)));

end;

procedure TForm1.FormShow(Sender: TObject);
begin
    centrform(form1);
end;

end.


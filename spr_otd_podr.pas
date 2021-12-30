unit spr_otd_podr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZConnection, ZDataset, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, LazUTF8;

type

  { TFormOtd }

  TFormOtd = class(TForm)
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Label2: TLabel;
    Label9: TLabel;
    Shape2: TShape;
    TreeView1: TTreeView;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure TreeZapros();  //Заполнение TreeView

  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormOtd: TFormOtd;

implementation
uses main,platproc;
{$R *.lfm}

{ TFormOtd }
type
    TNodeHolder = class
    ContainsNode: TTreeNode;
    RequiresNode: TTreeNode;
    end;

var
  nNode: TTreeNode;
  otvet: integer;


//*** Заполнение TreeView *********************************************************************
procedure TFormOtd.TreeZapros();
var
   OtNode, CurItem: TTreeNode;
   ns,k,i,n,kodotd,kodpodr: integer;
   nameotd,podrfullname,podradress: string;
   sn,sn2: string;
   j: variant;
   Pt: Pointer;
begin
  kodotd:=0;
  kodpodr:=0;
  nameotd:='';
  podrfullname:='';
  podradress:='';

  with FormOtd.TreeView1 do
  begin
  Items.BeginUpdate();

     for n:=1 to FormOtd.ZQuery1.recordcount do
      begin
       kodotd:=FormOtd.ZQuery1.FieldByName('kodotd').asInteger;
       kodpodr:=FormOtd.ZQuery1.FieldByName('kodpodr').asInteger;
       nameotd:=FormOtd.ZQuery1.FieldValues['name'] ;//..FieldByName('name').asString;
       podrfullname:=FormOtd.ZQuery1.FieldByName('fullname').asString;
       podradress:=FormOtd.ZQuery1.FieldByName('adress').asString;

     //Сначала узлы - отделения
      if (kodpodr=0) then
       begin
       OtNode:=FormOtd.TreeView1.Items.AddObject(nil, inttoStr(kodotd)+': '+nameotd,@kodotd);
       OtNode:=nil;
       end;

     //Потом узлы - подразделения
      if (kodpodr>0) then
       begin
          OtNode:=nil;
           // Ищем узел с таким же кодом отделения
        //  OtNode:=Items.FindNodeWithData(Ptr);
        OtNode:=Items.GetFirstNode;
           //Если найденный узел является узлом-отделением
           while (OtNode <> nil) do
           begin
           IF (OtNode.Level=0)  then
            begin
            sn:=OtNode.text;
            //showmessage(inttostr(utf8Pos(':',sn)));
            //showmessage(utf8Copy(sn,1,2));
            ns:=StrToInt(utf8Copy(sn,1,utf8Pos(':',sn)-1));
            If kodotd=ns then
                 begin
                    CurItem:=Items.AddChildObject(OtNode, inttoStr(kodpodr)+': '+nameotd,@kodpodr);
                    break;
                 end;
            end;
            OtNode:=OtNode.GetNext;
           end;
        end;
       FormOtd.zquery1.Next;
      end;

      n:=Items.Count;
      //Нет вообще ничего
      If n=0 then  OtNode:=FormOtd.TreeView1.Items.Add(nil, 'НЕТ ЗАПИСЕЙ');
      Items.EndUpdate;

      end;
end;

//Кнопка ЗАКРЫТЬ
procedure TFormOtd.BitBtn4Click(Sender: TObject);
begin
  Formotd.Close;
end;

//Кнопка ВЫБРАТЬ
procedure TFormOtd.BitBtn5Click(Sender: TObject);
begin
 with FormOtd.TreeView1 do
 begin
  nNode:= Selected;
  If nNode.Level=0 then
   begin
  nkodotd:=utf8Copy(nNode.Text,0,utf8Pos(':',nNode.Text)-1);
  sKodotd:=nNode.Text;
  nKodpodr:='-1';
  sKodpodr:='';
   end;
  If nNode.Level>0 then
   begin
  nkodotd:=utf8Copy(nNode.Parent.Text,0,utf8Pos(':',nNode.Parent.Text)-1);
  sKodotd:=nNode.Parent.Text;
  nKodpodr:=utf8Copy(nNode.Text,0,utf8Pos(':',nNode.Text)-1);
  sKodpodr:=nNode.Text;
   end;

 end;
  Formotd.Close;
end;

procedure TFormOtd.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 With FormOtd do
 begin
  // ESC
    if Key=27 then Formotd.Close;
 end;
end;


//*** ВОзникновение формы ******************************************************
procedure TFormOtd.FormShow(Sender: TObject);
var
 n:integer;
begin

  //соединяемся
  // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
  //Запрос

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


  try
   FormOtd.ZQuery1.SQL.Clear;
   FormOtd.ZQuery1.SQL.add('SELECT * FROM av_1c_otd_podr order by kodpodr,kodotd;');
   FormOtd.ZQuery1.open;
  except
    showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
    exit;
  end;
  //Заполняем TreeView
  If FormOtd.ZQuery1.RecordCount > 1 then
    begin
       TreeZapros();
    end;

   FormOtd.ZQuery1.close;
   FormOtd.Zconnection1.disconnect;
end;



end.


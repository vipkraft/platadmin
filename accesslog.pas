unit Accesslog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, LazFileUtils, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons;

type

  { TFormLog }

  TFormLog = class(TForm)
    BitBtn14: TBitBtn;
    BitBtn30: TBitBtn;
    BitBtn31: TBitBtn;
    Image1: TImage;
    Image3: TImage;
    Label2: TLabel;
    Label9: TLabel;
    StringGrid6: TStringGrid;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn30Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure UpdateGrid;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormLog: TFormLog;

implementation

uses
  main,platproc;

{$R *.lfm}

{ TFormLog }

//******************* ОБНОВИТЬ  ******************
procedure TFormLog.BitBtn30Click(Sender: TObject);
begin
  UpdateGrid;
end;


//*************************************************    HOT KEYS  *************************************************
procedure TFormLog.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
   // F1
    if (Key=112) then showmessagealt('[F1] - Справка'+#13+'[F5] - Обновить'+#13+'[ESC] - Отмена\Выход');
    //F5 - Добавить
    if (Key=116) then FormLog.BitBtn30.Click;
    // ESC
    if (Key=27) then FormLog.Close;

    If (Key=27) OR (Key=112) OR (Key=116) then Key:=0;
end;

procedure TFormLog.BitBtn14Click(Sender: TObject);
begin
  formLog.Close;
end;

procedure TFormLog.FormShow(Sender: TObject);
begin
  centrform(FormLog);
  UpdateGrid();
end;

//*******************************************  обновить журнал входа
procedure TFormLog.UpdateGrid();
var
 n,j: integer;
begin
 with FormLog do
begin
   // Подключаемся к серверу
   If not(Connect2(Zconnection1, flagProfile)) then
     begin
      showmessagealt('Соединение с сервером базы данных отсутствует !'+#13+'Проверьте сетевое соединение и опции файла настроек системы...');
      Close;
      exit;
     end;
   // Выбор пользователей
     with FormLog.ZQuery1 do
     begin
        SQL.Clear;
         SQL.add('Select u.indatetime,u.outdatetime,u.ipuser,u.id_user,u.id_arm,p.name,p.id,g.grupa,b.armname ');
         SQL.add('from av_login_log as u ');
         SQL.add('LEFT JOIN av_users as p ON u.id_user=p.id and p.del=0 ');
         SQL.add('LEFT JOIN av_group as g ON p.id=g.id ');
         SQL.add('LEFT JOIN av_arm as b ON u.id_arm=b.id and b.del=0 ');
         SQL.add('ORDER BY u.id ASC; ');
//         showmessage(SQL.text);
   try
      open;
   except
     ZQuery1.Close;
     Zconnection1.disconnect;
     showmessagealt('ОШИБКА  ЗАПРОСА !!!'+#13+'Команда: '+ZQuery1.SQL.Text);
     Close;
     exit;
   end;

   // Если нет записей
    if RecordCount<1 then
     begin
      showmessagealt('В системе нет зарегистрированных пользоватей !');
      Close;
      FormLog.Zconnection1.disconnect;
      exit;
     end;
   end;
     end;
   with FormLog.stringgrid6 do
   begin
   // Заполняем STRINGGRID и массив данными о пользователях
   RowCount:=FormLog.ZQuery1.recordcount+1;
   for n:=1 to FormLog.ZQuery1.Recordcount do
       begin
          cells[0,n]:=copy(FormLog.ZQuery1.FieldByName('indatetime').AsString,1,16);
          cells[1,n]:=copy(FormLog.ZQuery1.FieldByName('outdatetime').AsString,1,16);
          cells[2,n]:=FormLog.ZQuery1.FieldByName('ipuser').AsString;
          cells[3,n]:=FormLog.ZQuery1.FieldByName('armname').AsString;
          cells[4,n]:=FormLog.ZQuery1.FieldByName('id_user').AsString;
          cells[5,n]:=FormLog.ZQuery1.FieldByName('name').AsString;
          cells[6,n]:=FormLog.ZQuery1.FieldByName('grupa').AsString;
          FormLog.ZQuery1.next;
     end;
   SetFocus;
   end;
end;

end.


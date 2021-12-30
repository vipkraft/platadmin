unit Load_DBF;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, Buttons, StdCtrls, ExtCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form2: TForm2;
  flag_edit:byte;
  flag_name:string;
implementation

{$R *.lfm}

{ TForm2 }
uses platproc,main;

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  form2.stringgrid1.RowCount:=form2.stringgrid1.RowCount+1;
  form2.stringgrid1.Cells[1,form2.stringgrid1.RowCount-1]:=form2.Edit4.text;
  flag_edit:=1;
  form2.bitbtn6.Enabled:=true;
end;

// Удаляем запись в текстовом файле
procedure del_str_txt1(txt_str:string);
var
  n,z:integer;
  tmp_str:integer;
  tmp_array:Array of string;
begin
   // Переписываем без выделенного значения
   SetLength(tmp_array,form2.stringgrid1.Rowcount);
   z:=0;
   for n:=1 to form2.stringgrid1.Rowcount-1 do
     begin
       if not(form2.StringGrid1.Cells[1,n]=txt_str) then
         begin
          z:=z+1;
          tmp_array[z]:=form2.StringGrid1.Cells[1,n];
         end;
     end;
   tmp_str:=z;
   form2.StringGrid1.Rowcount:=1;
   for n:=1 to tmp_str do
     begin
       form2.StringGrid1.RowCount:=form2.StringGrid1.RowCount+1;
       form2.StringGrid1.Cells[1,n]:=tmp_array[n];
     end;
end;

// Удаляем запись в текстовом файле (состав)
procedure del_str_txt2(nom_str:integer);
var
  n,z:integer;
  tmp_str:integer;
  tmp_array:array of array of string;
begin
   // Переписываем без выделенного значения
   SetLength(tmp_array,form2.stringgrid2.Rowcount-1,4);
   z:=0;
   for n:=1 to form2.stringgrid2.Rowcount-1 do
     begin
       if not(n=nom_str) then
         begin
          z:=z+1;
          tmp_array[z,0]:=form2.StringGrid2.Cells[1,n];
          tmp_array[z,1]:=form2.StringGrid2.Cells[2,n];
          tmp_array[z,2]:=form2.StringGrid2.Cells[3,n];
          tmp_array[z,3]:=form2.StringGrid2.Cells[4,n];
         end;
     end;
   tmp_str:=z;
   form2.StringGrid2.Rowcount:=1;
   for n:=1 to tmp_str do
     begin
       form2.StringGrid2.RowCount:=form2.StringGrid2.RowCount+1;
       form2.StringGrid2.Cells[1,n]:=tmp_array[n,0];
       form2.StringGrid2.Cells[2,n]:=tmp_array[n,1];
       form2.StringGrid2.Cells[3,n]:=tmp_array[n,2];
       form2.StringGrid2.Cells[4,n]:=tmp_array[n,3];
     end;
   //освобождаем память
   SetLength(tmp_array,0,0);
   tmp_array := nil;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
 var
   del_str:string;
begin
 del_str:=form2.StringGrid1.cells[form2.StringGrid1.Col,form2.StringGrid1.Row];
 del_str_txt1(del_str);
 flag_edit:=1;
 form2.bitbtn6.Enabled:=true;
end;

procedure TForm2.BitBtn3Click(Sender: TObject);
 var
   tmp_name:string;
   t,t2:TextFile;
   List:TStringList;
   kol_strok,k:integer;
   strtemp:string;
 begin

  //Файл локальных настроек полей
   tmp_name:=form2.stringgrid1.cells[1,form2.stringgrid1.row];
   flag_name:=tmp_name;

   // Состав DBF
   AssignFile(t,ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'.txt');
   if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'.txt') then
      begin
       Reset(t);
      end
   else
    begin
       Rewrite(t);
    end;

    //Определяем количество строк в файле
   List := TStringList.Create;
   try
     List.LoadFromFile(ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'.txt');
     kol_strok:=List.Count;
   finally
     List.Free;
   end;

   form2.Edit5.text:='';
   form2.Edit6.text:='';
   form2.StringGrid2.RowCount:=1;
   //Загружаем данные по списку настроек для DBF если строк больше 0
   if kol_strok>0 then
     begin
        form2.StringGrid2.RowCount := kol_strok+1;
        k:=0;
     while not Eof(t) do
        begin
          k:=k+1;
          Readln(t,strTemp);
          form2.StringGrid2.Cells[1, k] := strTemp;
          Readln(t,strTemp);
          form2.StringGrid2.Cells[2, k] := strTemp;
          Readln(t,strTemp);
          form2.StringGrid2.Cells[3, k] := strTemp;
          Readln(t,strTemp);
          form2.StringGrid2.Cells[4, k] := strTemp;
        end;
     end;
   CloseFile(t);

   // SQL Table-DELETE SQL
   AssignFile(t2, ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'2.txt');
   if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'2.txt') then
      begin
       Reset(t2);
      end
   else
    begin
       Rewrite(t2);
    end;

    kol_strok:=0;
   //Определяем количество строк в файле
   List := TStringList.Create;
   try
     List.LoadFromFile(ExtractFilePath(Application.ExeName)+'list_dbf_'+tmp_name+'2.txt');
     kol_strok:=List.Count;
   finally
     List.Free;
   end;
   if kol_strok>0 then
     begin
    while not Eof(t2) do
        begin
         readln(t2,strTemp);
         form2.Edit5.Text:=strTemp;
         readln(t2,strTemp);
         form2.Edit6.Text:=strTemp;
        end;
     end;
   CloseFile(t2);
   form2.stringgrid2.visible:=true;
   form2.label1.visible:=true;
   form2.label2.visible:=true;
   form2.label3.visible:=true;
   form2.bitbtn4.visible:=true;
   form2.bitbtn5.visible:=true;
   form2.edit1.visible:=true;
   form2.edit2.visible:=true;
   form2.edit3.visible:=true;
   form2.edit5.visible:=true;
   form2.edit6.visible:=true;
   form2.label5.visible:=true;
   form2.label6.visible:=true;
   form2.label8.visible:=true;
   form2.edit7.visible:=true;
   form2.label9.visible:=true;

 end;

procedure TForm2.BitBtn4Click(Sender: TObject);
begin
  form2.stringgrid2.RowCount:=form2.stringgrid2.RowCount+1;
  form2.stringgrid2.Cells[1,form2.stringgrid2.RowCount-1]:=form2.Edit7.text;
  form2.stringgrid2.Cells[2,form2.stringgrid2.RowCount-1]:=form2.Edit1.text;
  form2.stringgrid2.Cells[3,form2.stringgrid2.RowCount-1]:=form2.Edit2.text;
  form2.stringgrid2.Cells[4,form2.stringgrid2.RowCount-1]:=form2.Edit3.text;
  flag_edit:=1;
  form2.bitbtn6.Enabled:=true;
end;

procedure TForm2.BitBtn5Click(Sender: TObject);
begin
   del_str_txt2(form2.StringGrid2.Row);
   flag_edit:=1;
   form2.bitbtn6.Enabled:=true;
end;

procedure TForm2.BitBtn6Click(Sender: TObject);
 var
   n:integer;
   f:TextFile;

 begin
  //Сохраняем  настройки StringGrid1
   AssignFile(f, ExtractFilePath(Application.ExeName)+'list_dbf.txt');
   Rewrite(f);
   //Загружаем данные по списку настроек для DBF если строк больше 0
   for n:=2 to form2.StringGrid1.RowCount do
     begin
      writeln(f,form2.StringGrid1.cells[1,n-1]);
     end;
   CloseFile(f);

   //Сохраняем локальные настройки если активен StringGrid2
  if form2.stringgrid2.Visible=true then
    begin
      AssignFile(f,ExtractFilePath(Application.ExeName)+'list_dbf_'+flag_name+'.txt');
      Rewrite(f);
      for n:=2 to form2.StringGrid2.RowCount do
        begin
         if not(trim(form2.StringGrid2.cells[1,n-1])='') then
           begin
            writeln(f,form2.StringGrid2.cells[1,n-1]);
            writeln(f,form2.StringGrid2.cells[2,n-1]);
            writeln(f,form2.StringGrid2.cells[3,n-1]);
            writeln(f,form2.StringGrid2.cells[4,n-1]);
           end;
        end;
         CloseFile(f);
    end;
    //Сохраняем локальные настройки2 если активен StringGrid2
  if form2.stringgrid2.Visible=true then
    begin
      AssignFile(f,ExtractFilePath(Application.ExeName)+'list_dbf_'+flag_name+'2.txt');
      Rewrite(f);
      writeln(f,form2.edit5.text);
      writeln(f,form2.edit6.text);
      CloseFile(f);
    end;

  flag_edit:=0;
  form2.bitbtn6.Enabled:=false;
end;

// ********************************    ЗАГРУЗИТЬ ВСЕ *******************************************
procedure TForm2.BitBtn7Click(Sender: TObject);
   var
   f:TextFile;
   kol_strok,k:integer;
   strTemp:String;
   List:TstringList;
begin
   //Создаем\открываем файл для записи\чтения
   AssignFile(f,ExtractFilePath(Application.ExeName)+'list_dbf.txt');
   if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf.txt') then
      begin
       Reset(f);
      end
   else
    begin
       Rewrite(f);
    end;

   //Определяем количество строк в файле
   List := TStringList.Create;
   try
     List.LoadFromFile(ExtractFilePath(Application.ExeName)+'list_dbf.txt');
     kol_strok:=List.Count;
   finally
     List.Free;
   end;

   //Загружаем данные по списку настроек для DBF если строк больше 0
   if kol_strok>0 then
     begin
        form2.StringGrid1.RowCount := kol_strok+1;
        k:=0;
     while not Eof(f) do
        begin
          k:=k+1;
          Readln(f,strTemp);
          form2.StringGrid1.Cells[1, k] := strTemp;
        end;
     end;

   CloseFile(f);
   form2.bitbtn1.Enabled:=true;
   form2.bitbtn2.Enabled:=true;
   form2.bitbtn3.Enabled:=true;
   form2.label4.enabled:=true;
   form2.edit4.enabled:=true;
end;

procedure TForm2.BitBtn8Click(Sender: TObject);
begin
  form2.Close;
end;


// ВОзникновение формы
procedure TForm2.FormShow(Sender: TObject);
begin
  flag_edit:=0;
 CentrForm(Form2);
end;

procedure TForm2.StringGrid1Click(Sender: TObject);
begin
   form2.stringgrid2.visible:=false;
   form2.label1.visible:=false;
   form2.label2.visible:=false;
   form2.label3.visible:=false;
   form2.bitbtn4.visible:=false;
   form2.bitbtn5.visible:=false;
   form2.edit1.visible:=false;
   form2.edit2.visible:=false;
   form2.edit3.visible:=false;
   form2.edit5.visible:=false;
   form2.edit6.visible:=false;
   form2.edit7.visible:=false;
   form2.label9.visible:=false;
   form2.label5.visible:=false;
   form2.label6.visible:=false;
   form2.label8.visible:=false;
end;

end.


unit Unit4; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,  LazFileUtils, Forms, Controls, Graphics, Dialogs, CheckLst,
  Buttons, ExtCtrls;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckListBox1: TCheckListBox;
    Shape1: TShape;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form4: TForm4; 

implementation
uses platproc,dbf_import;

{$R *.lfm}

{ TForm4 }

procedure TForm4.FormShow(Sender: TObject);
 var
   t_file:TextFile;
   t_str,sdbf:string;
   i,m,n:integer;
  begin
   //CentrForm(Form4);
  //Загружаем список доступных для загрузки DBF
    AssignFile(t_file, ExtractFilePath(Application.ExeName)+'list_dbf.txt');
   if FileExistsUTF8(ExtractFilePath(Application.ExeName)+'list_dbf.txt') then
      begin
       Reset(t_file);
      end
   else
    begin
       showmessage('Список импортируемых DBF не найден ('+ExtractFilePath(Application.ExeName)+'list_dbf.txt) !');
       exit;
    end;

    n:=0;
    m:=0;
    //Загружаем данные по списку настроек для DBF если строк больше 0
    while not Eof(t_file) do
    begin
          readln(t_file,t_str);
          If (t_str[1]='C') or (t_str[1]='K') then
            form4.CheckListbox1.items.add('Контрагенты')
          else If (t_str[1]='D') or (t_str[1]='d') then
            form4.CheckListbox1.items.add('Договора')
          else If (t_str[1]='L') or (t_str[1]='l') then
            form4.CheckListbox1.items.add('Лицензии')
          else
            form4.CheckListbox1.items.add(t_str);
          form4.CheckListbox1.Checked[form4.CheckListbox1.Items.Count-1]:=false;
          //Если есть такой DBF в папке, добавить в чеклист
          If fileexists(IncludeTrailingPathDelimiter(formDbf.edit8.text)+t_str) then
          //i:=Find_All_Files(formDbf.edit8.text,t_str);
          //if i>0 then
              inc(m)
           else
             begin
             form4.CheckListbox1.ItemEnabled[form4.CheckListbox1.Items.Count-1]:=false;
             end;
        inc(n);
        //    showmessage('НЕ обнаружено файла '+t_str+' по пути: '+form1.edit8.text+' !');
    end;
    closefile(t_file);

    //Если нет DBF
    If m<1 then
       begin
        showmessage('Не обнаружено файлов DBF по данному пути!');
        exit;
       end;

//If 1<>1 then
   //begin
   AssignFile(t_file, ExtractFilePath(Application.ExeName)+'listbox_dbf.txt');
   if FileExists(ExtractFilePath(Application.ExeName)+'listbox_dbf.txt') then
      begin
       Reset(t_file);
       while not Eof(t_file) do
           begin
             readln(t_file,t_str);
             If trim(t_str)<>'' then
                begin
               try
               strtoint(t_str);//редактирование ячейки
               except
                 on exception: EConvertError do
                 begin
                   showmessage('ОШИБКА преобразования в целое!!!'+#13+'Файл listbox_dbf.txt');
                   continue;
                 end;
               end;
               If form4.CheckListbox1.ItemEnabled[strtoint(t_str)] then
                 form4.CheckListbox1.Checked[strtoint(t_str)]:=true;
            end;
           end;
       closefile(t_file);
      end
   else
    begin
       Rewrite(t_file);
    end;

   //end;
end;


procedure TForm4.BitBtn1Click(Sender: TObject);
 var
   t_file:TextFile;
   t_str:string;
   i:integer;
 begin
   AssignFile(t_file, ExtractFilePath(Application.ExeName)+'listbox_dbf.txt');
   Rewrite(t_file);
   for i := 0 to Checklistbox1.Items.Count - 1 do
    begin
      if form4.CheckListbox1.Checked[i]=true then writeln(t_file,inttostr(i));
    end;
    closefile(t_file);
     //Устанавливаем флаг
    lExp:=true;
    form4.Close;
//    form1.memo1.clear;
//    form1.ExportALLDBF();
end;

procedure TForm4.BitBtn2Click(Sender: TObject);
begin
   form4.close;
end;

end.


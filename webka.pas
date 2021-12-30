unit webka;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,
  {$IFDEF LINUX}
  unix,
  {$ENDIF}
  Buttons;

type

  { TFormCam }

  TFormCam = class(TForm)
    BitBtn14: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn20: TBitBtn;
    CheckBox2: TCheckBox;
    Edit10: TEdit;
    Edit12: TEdit;
    Edit9: TEdit;
    GroupBox5: TGroupBox;
    Image1: TImage;
    Image3: TImage;
    Image4: TImage;
    Label2: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label9: TLabel;
    Shape4: TShape;
    Timer1: TTimer;
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn19Click(Sender: TObject);
    procedure BitBtn20Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormCam: TFormCam;

implementation
uses
  main,platproc;

{$R *.lfm}

{ TFormCam }

//// ******   Кнопка СДлеать снимок ********** СФОТОГРАФИРОВАТЬ **********************************************************************
procedure TFormCam.BitBtn18Click(Sender: TObject);
begin
     {$IFDEF LINUX}

  fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(formCam.edit10.text)+'x'+trim(formCam.edit12.text)+' -r 30 -i '+trim(formCam.edit9.text)+' -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(formCam.edit10.text)+'x'+trim(formCam.edit12.text)+' -r 30 -i '+trim(formCam.edit9.text)+' -f image2 webcam.jpg');
 fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(formCam.edit10.text)+'x'+trim(formCam.edit12.text)+' -r 30 -i '+trim(formCam.edit9.text)+' -f image2 webcam.jpg');

  {$ENDIF}
 formCam.image3.Picture.LoadFromFile('webcam.jpg');
end;

procedure TFormCam.BitBtn14Click(Sender: TObject);
begin
  FormCam.Close;
end;

// ******* старт видео *********************************************
procedure TFormCam.BitBtn19Click(Sender: TObject);
begin
  formCam.BitBtn20.Enabled:=true;
  formCam.BitBtn19.Enabled:=false;
  formCam.Timer1.Enabled:=not(formCam.Timer1.Enabled);
end;

//******************************************** СТОП ТЕСТА КАМЕРЫ******************************************************
procedure TFormCam.BitBtn20Click(Sender: TObject);
begin
   formCam.BitBtn20.Enabled:=false;
  formCam.BitBtn19.Enabled:=true;
  formCam.Timer1.Enabled:=not(formCam.Timer1.Enabled);
end;


procedure TFormCam.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
//*************************************************    HOT KEYS  *************************************************
begin
   // F1
    if (Key=112) then showmessagealt('[F1] - Справка'+#13+'[F5] - Обновить'+#13+'[ESC] - Отмена\Выход');
    //F5 - Добавить
    //if (Key=116) then FormCam.BitBtn30.Click;
    // ESC
    if (Key=27) then FormCam.Close;

    If (Key=27) OR (Key=112) OR (Key=116) then Key:=0;

end;

procedure TFormCam.FormShow(Sender: TObject);
begin
  centrform(FormCam);
end;

procedure TFormCam.Timer1Timer(Sender: TObject);
begin
   {$IFDEF LINUX}
     fpsystem('ffmpeg -t 1 -f video4linux2 -s '+trim(formCam.edit10.text)+'x'+trim(formCam.edit12.text)+' -r 30 -i '+trim(formCam.edit9.text)+' -f image2 webcam.jpg');
    {$ENDIF}
   formCam.image3.Picture.LoadFromFile('webcam.jpg');
    formCam.Image3.Repaint;
end;


end.


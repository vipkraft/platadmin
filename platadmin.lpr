program platadmin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, dbflaz, platproc, dialogs, main, consol, sync_table,
  point_main, spr_grup, spr_menu, web_options, spr_arms, ARM, spr_otd_podr,
  Dbf_import, localsettings, Servers, users_main, ExtPersonal,
  usr_edit, spr_vars, spr_update, sync_log, version_info, genagent, web_users,
  spr_option, web_usr_kontr, web_usr_opt, webrep, zcomponent;

{$R *.res}

begin
  Application.Title:='PlatformaAV АРМ Администратора';

{ if ParamCount < 1 then
   begin
    showmessagealt('     !!!');
    halt;
  end;
 }
 Application.Initialize;
 Application.CreateForm(TFormMain, FormMain);
 Application.Run;
end.

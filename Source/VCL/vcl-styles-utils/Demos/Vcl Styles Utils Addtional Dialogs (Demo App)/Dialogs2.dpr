﻿program Dialogs2;

uses
  Windows,
  IOUTils,
  SysUtils,
  Types,
  Vcl.Forms,
  uMain in 'uMain.pas' {FrmMain},
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Styles.Utils.ComCtrls in '..\..\Common\Vcl.Styles.Utils.ComCtrls.pas',
  Vcl.Styles.Utils.Forms in '..\..\Common\Vcl.Styles.Utils.Forms.pas',
  Vcl.Styles.Utils.Menus in '..\..\Common\Vcl.Styles.Utils.Menus.pas',
  Vcl.Styles.Utils.ScreenTips in '..\..\Common\Vcl.Styles.Utils.ScreenTips.pas',
  Vcl.Styles.Utils.StdCtrls in '..\..\Common\Vcl.Styles.Utils.StdCtrls.pas',
  Vcl.Styles.Utils.SysControls in '..\..\Common\Vcl.Styles.Utils.SysControls.pas',
  Vcl.Styles.Utils.SysStyleHook in '..\..\Common\Vcl.Styles.Utils.SysStyleHook.pas',
  ObjSel in 'ObjSel.pas',
  Vcl.Styles.FontAwesome in '..\..\Common\Vcl.Styles.FontAwesome.pas',
  Vcl.Styles.Hooks in '..\..\Common\Vcl.Styles.Hooks.pas',
  Vcl.Styles.Utils.Graphics in '..\..\Common\Vcl.Styles.Utils.Graphics.pas',
  Vcl.Styles.Utils.Misc in '..\..\Common\Vcl.Styles.Utils.Misc.pas',
  Vcl.Styles.UxTheme in '..\..\Common\Vcl.Styles.UxTheme.pas';

{$R *.res}

function PathCanonicalize(lpszDst: PChar; lpszSrc: PChar): LongBool; stdcall; external 'shlwapi.dll' name 'PathCanonicalizeW';

function ResolvePath(const RelPath, BasePath: string): string;
var
  lpszDst: array[0..MAX_PATH-1] of char;
begin
  PathCanonicalize(@lpszDst[0], PChar(IncludeTrailingPathDelimiter(BasePath) + RelPath));
  Exit(lpszDst);
end;

procedure LoadVCLStyles;
var
  f, s : string;
  LFiles : TStringDynArray;
begin
  s:=ExtractFilePath(ParamStr(0));
  LFiles:=TDirectory.GetFiles(s, '*.vsf');
  if Length(LFiles)>0 then
  begin
   for f in TDirectory.GetFiles(s, '*.vsf') do
     if TStyleManager.IsValidStyle(f) then
       TStyleManager.LoadFromFile(f);
  end
  else
  begin
    s:=ResolvePath('..\..\..\Styles',ExtractFilePath(ParamStr(0)));
    for f in TDirectory.GetFiles(s, '*.vsf') do
     if TStyleManager.IsValidStyle(f) then
      TStyleManager.LoadFromFile(f);
  end;
end;


begin
  LoadVCLStyles;
  TStyleManager.TrySetStyle('Carbon');
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

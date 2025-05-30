﻿unit InstallWizards;

interface

uses
{$IFDEF WIN32}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, InstallFiles, ExtCtrls, StdCtrls, Buttons, ShellAPI, ComCtrls,
  Installers, PackmanExitCodesU, System.Zip, Vcl.Imaging.pngimage;
{$ENDIF}
{$IFDEF LINUX}
  SysUtils, Variants, Classes, QGraphics, QControls, QForms,
  QDialogs, InstallFiles, QExtCtrls, QStdCtrls, QButtons, QComCtrls,
  Installers, PackmanExitCodesU;
{$ENDIF}

type
  TInstallWizard = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    StepsPanel: TPanel;
    Bevel1: TBevel;
    PrevBtn: TBitBtn;
    NextBtn: TBitBtn;
    Cancel: TBitBtn;
    Notebook1: TNotebook;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ReadmeMemo: TMemo;
    Label6: TLabel;
    ProgressBar1: TProgressBar;
    Label7: TLabel;
    GroupBox1: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    LicenseMemo: TMemo;
    Label16: TLabel;
    GroupBox2: TGroupBox;
    Descr: TMemo;
    AboutBtn: TBitBtn;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    UrlLabel: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Step1: TLabel;
    Step2: TLabel;
    Step3: TLabel;
    Step4: TLabel;
    Step5: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    procedure Notebook1PageChanged(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure PrevBtnClick(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure CancelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AboutBtnClick(Sender: TObject);
    procedure UrlLabelClick(Sender: TObject);
    procedure Label22Click(Sender: TObject);
    procedure Label23Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FileName: AnsiString;
    InstallInfo: TInstallInfo;
    Installer: TInstaller;
    IsCompressed: Boolean;
    TempFilesDir: AnsiString;
    TempFiles, TempDirs: TStringList;
    procedure ChangeLabels;
    procedure StartInstall;
    procedure Progress(Sender: TObject; CurrentFile: TInstallFile; Progress, Max: Integer);

    procedure OnUnZipProgress(Sender: TObject; FileName: string; Header: TZipHeader; Position: Int64);
    procedure OnAbUnZipProgress(Sender: TObject; Progress: Byte; var Abort: boolean);
  public
    DontShowError: Boolean;
    PMExitCode: TPackmanExitCode;
    Quiet: Boolean;
    constructor Create(AOwner: TComponent); override;
    function SetFileName(AFileName: AnsiString): Boolean;
  end;

var
  InstallWizard: TInstallWizard;

implementation

uses
  LibTar, ExtractionProgressDialog, System.IOUtils, AbUnzper, AbArcTyp, Main;

const
  PageCount = 5;

var
  AppDir: AnsiString;
 //just referenceS for unzip callbacks
  bar: TProgressBar;
  app: TApplication;

{$R *.dfm}

procedure GetZipNameAndVersion( var zipname, zipversion: AnsiString);
//this proc gets a name of zip package i.e. glib-dev-2.4.7
//(of file glib-dev-2.4.7.zip) and attempts to resolve the name
//and the version of it: in this case 'glib-dev' and '2.4.7'
//this should take care of version formats like 'glib-dev-2.4.7',
//'jpeg-6b-1', 'ps-p17', can also end in one of: -bin.zip, -dep,
//-doc, -lib or -src (gnuwin32.sf.net format)
var
  tempStrs: TStrings;
  suffix: AnsiString;

  function checkIfVersion( const str: AnsiString): Boolean;
  //check for only numbers or dots, at most one char could also be a letter
  var
    i: Integer;
    wasLetter: Boolean;
  begin
    Result := False;
    wasLetter := False;
    if Length(str) = 0 then Exit;
    for i := 1 to Length(str) do
      if Not (str[i] in ['0'..'9', '.']) then
        if (Not wasLetter) and (str[i] in ['a'..'z', 'A'..'Z']) then
          wasLetter := True
        else
          Exit;
    Result := True;
  end;

begin
  zipversion := '';

  tempStrs := TStringList.Create;
  tempStrs.Delimiter := '-';
  tempStrs.DelimitedText := zipname;
  if tempStrs.Count = 0 then Exit; //no '-' - Exit

  //check for 'suffixes' like -bin, -dep, -doc, -lib, -src
  //for example: libintl-0.11.5-2-bin.zip
  suffix := '';
  if (tempStrs[tempStrs.Count-1] = 'bin')
  or (tempStrs[tempStrs.Count-1] = 'dep')
  or (tempStrs[tempStrs.Count-1] = 'doc')
  or (tempStrs[tempStrs.Count-1] = 'lib')
  or (tempStrs[tempStrs.Count-1] = 'src') then
  begin
    suffix := tempStrs[tempStrs.Count-1];
    tempStrs.Delete(tempStrs.Count-1);
  end;

  //check the last '-' before known version formats:
  //(glib-dev-2.4.7, jpeg-6b, LibW11-2001-12-01, ps-p17)
  while tempStrs.Count > 1 do
  begin
    if checkIfVersion(tempStrs[tempStrs.Count-1]) then
    begin
      if zipversion = '' then
        zipversion := tempStrs[tempStrs.Count-1]
      else
        zipversion := tempStrs[tempStrs.Count-1] + '-' + zipversion;
      tempStrs.Delete(tempStrs.Count-1);
      zipname := tempStrs.DelimitedText;
    end
    else
      break;
  end;

  tempStrs.Free;

  if suffix <> '' then
    zipname := zipname + '-' + suffix;
end;

procedure Mkdir(const DirName: AnsiString);
begin
  if not ForceDirectories(DirName) then
    raise Exception.Create('error creating folder "'+ DirName + '"');
end;

function ConvertSlashes(Path: AnsiString): AnsiString;
var
  i: Integer;
begin
  Result := Path;
  for i := 1 to Length(Result) do
      if Result[i] = '/' then
          Result[i] := '\';
end;

procedure CreateDevPackageFile(PackageFile, DevPakName, DevPakVer: AnsiString);
//this attempts to create a package description file (DevPackage)
//for generic packages (*.zip, *.tar.bz2 etc)
var
  DevPak: TextFile;
begin
  AssignFile(DevPak, PackageFile);
  Rewrite(DevPak);
  Writeln(DevPak, ''
    + '[Setup]' + #13#10
    + 'Version=2' + #13#10
    + 'AppName=' + DevPakName + #13#10
    + 'AppVerName=' + DevPakName + ' ' + DevPakVer + #13#10
    + 'AppVersion=' + DevPakVer + #13#10
    + 'MenuName=' + #13#10
    + 'Description=' + #13#10
    + 'Url=' + #13#10
    + 'Readme=' + #13#10
    + 'License=' + #13#10
    + 'Picture=' + #13#10
    + 'Dependencies=' + #13#10
    + 'Reboot=0' + #13#10
    + '[Files]' + #13#10
    + DevPakName + '=<app>\' + #13#10);
  CloseFile(DevPak);
end;

function TInstallWizard.SetFileName(AFileName: AnsiString): Boolean;
const
  BufSize = 1024 * 64;
var
  F: File;
  Buf: array [0 .. 3] of AnsiChar;
  BytesRead: LongInt;

  Tar: TTarArchive;
  DirRec: TTarDirRec;
  TarFile: AnsiString;
  ExtractedFile: TFileStream;

  FN, ExtractDir: AnsiString;
  PackageFile: AnsiString;

  i: Integer;
  EntryName: AnsiString;
  DepErrors: TStringList;

  IsZip: Boolean;

  DevPakName, DevPakVer: AnsiString; // for generic zip or tar.bz2 devpaks

  TarFileName: string;

  procedure cleanup;
  begin
    if TempFiles <> nil then
      FreeAndNil(TempFiles);
    if TempDirs <> nil then
      FreeAndNil(TempDirs);
    if DepErrors <> nil then
      FreeAndNil(DepErrors);
    RemoveDir(TempFilesDir);
  end;

begin
  IsCompressed := False;
  IsZip := False;

  Result := False;
  FileName := AFileName;

  { Check for signature }
  FileMode := 0;
  AssignFile(F, AFileName);
  Reset(F, 1);

  { Check for bzip2 signature }
  FillChar(Buf, SizeOf(Buf) - 1, #0);
  BlockRead(F, Buf, 3, BytesRead);
  if BytesRead = 3 then
    if Buf = 'BZh' then
      IsCompressed := True;

  { Check for zip signature }
  if not IsCompressed then
  begin
    Seek(F, 0);
    FillChar(Buf, SizeOf(Buf) - 1, #0);
    BlockRead(F, Buf, 4, BytesRead);
    if BytesRead = 4 then
      if Buf = 'PK' + #3 + #4 then
      begin
        IsCompressed := True;
        IsZip := True;
      end;
  end;

  CloseFile(F);

  { If compressed, extract the package to a temporary file }
  PackageFile := '';
  if IsCompressed then
  begin
    DevPakName := ChangeFileExt(ExtractFileName(AFileName), '');
    if ExtractFileExt(DevPakName) = '.tar' then
      DevPakName := ChangeFileExt(DevPakName, '');
    GetZipNameAndVersion(DevPakName, DevPakVer);
    if DevPakVer = '' then
      DevPakVer := '1.0';

    ExtractDir := System.IOUtils.TPath.GetTempPath + IntToStr(Random(1000)) +
      '-Dev-' + IntToStr(Random(1000)) + '-Package\';
    TempFilesDir := ExtractDir;
    ExtractDir := ExtractDir + DevPakName + '\';
    TempFiles := TStringList.Create;
    TempDirs := TStringList.Create;
    Mkdir(ExtractDir);

    // extract .devpak
    ExtractionProgress := TExtractionProgress.Create(Self);
    var
      AbUnZipper: TAbUnZipper;
    AbUnZipper := TAbUnZipper.Create(Self);
    try
      ExtractionProgress.Show;

      bar := ExtractionProgress.ProgressBar1;
      app := Application;

      try
        AbUnZipper.OnArchiveProgress := OnAbUnZipProgress;
        AbUnZipper.BaseDirectory := ExtractDir;
        AbUnZipper.FileName := AFileName;
        AbUnZipper.ExtractOptions := [eoCreateDirs];
        AbUnZipper.ExtractFiles('*.*');
        // save  filename for further processing...
        TarFileName := IncludeTrailingPathDelimiter(ExtractDir) +
          AbUnZipper.Items[0].FileName;
      except
        raise Exception.Create('error extracting for zip file "' +
          AFileName + '"');
        cleanup;
        Exit;
      end;

    finally
      AbUnZipper.Free;
      ExtractionProgress.Free;
    end;

    { Now extract the *.tar file }
    ExtractionProgress := TExtractionProgress.Create(Self);
    Tar := TTarArchive.Create(TarFileName);

    ExtractionProgress.ProgressBar1.Max := Tar.Stream.Size * 2;
    ExtractionProgress.ProgressBar1.Position := Tar.Stream.Position;

    try
      while Tar.FindNext(DirRec) do
      begin
        FN := ExtractDir + ConvertSlashes(DirRec.Name);
        if (DirRec.FileType = ftDirectory) then
        begin
          TempDirs.Add(FN);
          Continue;
        end;
        if not DirectoryExists(ExtractFileDir(FN)) then
          Mkdir(ExtractFileDir(FN));

        ExtractedFile := TFileStream.Create(FN, fmCreate);
        TempFiles.Add(FN);
        Tar.ReadFile(ExtractedFile);
        ExtractedFile.Free;

        if (not FileExists(PackageFile)) and
          (CompareText(ExtractFileExt(FN), '.DevPackage') = 0) then
          PackageFile := FN;

        ExtractionProgress.ProgressBar1.Position := Tar.Stream.Size +
          Tar.Stream.Position;
        Application.ProcessMessages;
      end; // while
    except
      ExtractionProgress.Free;
      Tar.Free;
      DeleteFile(TarFile);
      PMExitCode := PACKMAN_EXITCODE_INVALID_FORMAT;
      cleanup;
      Exit;
    end;
    ExtractionProgress.Free;
    Tar.Free;
    DeleteFile(TarFile);
  end; // if IsCompressed

  // it's now unpacked, deal with DevPackage file
  if LowerCase(ExtractFileExt(AFileName)) = '.devpak' then
  begin
    if not FileExists(PackageFile) then
    begin
      Application.MessageBox('A package description file (*.DevPackage) ' +
        'has not been found in this archive.', 'Error', MB_ICONHAND);
      DontShowError := True;
      PMExitCode := PACKMAN_EXITCODE_NO_PACKAGE_DESCRIPTION;
      cleanup;
      Exit;
    end
  end
  else
  // so this is generic package like *.tar.bz2 or *.zip
  begin
    // create a generic *.DevPackage
    PackageFile := TempFilesDir + DevPakName + '.DevPackage';
    CreateDevPackageFile(PackageFile, DevPakName, DevPakVer);
  end;
  FileName := PackageFile;

  { Go on with the installation }
  try
    InstallInfo := TInstallInfo.Create(FileName);
  except
    Application.MessageBox('This file is not a valid package file.', 'Error',
      MB_ICONERROR);
    Close;
    DontShowError := True;
    PMExitCode := PACKMAN_EXITCODE_INVALID_FORMAT;
    cleanup;
    Exit;
  end;

  if InstallInfo.Version > SupportedVersion then
  begin
    Application.MessageBox(PWideChar('This version of Package Manager only' +
      ' supports packages up to version ' + IntToStr(SupportedVersion) + '.' +
      #13#10 + 'The package you selected has version number ' +
      IntToStr(InstallInfo.Version) + '.' + #13#10#13#10 +
      'This means the package format has changed.' + #13#10 +
      'It is highly recommended to upgrade to the latest version of ' +
      'Embarcadero Dev-C++ and Package Manager.'), 'Incompatible version', MB_ICONERROR);
    Close;
    DontShowError := True;
    PMExitCode := PACKMAN_EXITCODE_VERSION_NOT_SUPPORTED;
    cleanup;
    Exit;
  end;

  AppDir := ExtractFileDir(ParamStr(0));
  DepErrors := TStringList.Create;
  for i := 0 to InstallInfo.Dependencies.Count - 1 do
  begin
    EntryName := ChangeFileExt(InstallInfo.Dependencies.Strings[i], '.entry');
    EntryName := AppDir + '\Packages\' + EntryName;
    if not FileExists(EntryName) then
      DepErrors.Add(InstallInfo.Dependencies.Strings[i]);
  end;
  if DepErrors.Count > 0 then
  begin
    Application.MessageBox(PWideChar('This package depends on some ' +
      'other packages, which are not installed on your system.' + #13#10 +
      'Please install them first. The required depencies are:' + #13#10 +
      DepErrors.Text), 'Dependency Error', MB_ICONERROR);
    Close;
    DontShowError := True;
    PMExitCode := PACKMAN_EXITCODE_DEPENDACIES_NOT_MET;
    cleanup;
    Exit;
  end;
  FreeAndNil(DepErrors);

  Installer := nil;
  Notebook1.PageIndex := 0;
  Label3.Caption := Format(Label3.Caption, [InstallInfo.AppVerName]);
  Label2.Caption := Format(Label2.Caption, [InstallInfo.AppName]);
  Label16.Caption := Format(Label16.Caption, [InstallInfo.AppName]);
  Label20.Caption := Format(Label20.Caption, [InstallInfo.AppName]);

  Label19.Visible := Length(InstallInfo.URL) > 0;
  UrlLabel.Visible := Length(InstallInfo.URL) > 0;
  UrlLabel.Caption := InstallInfo.URL;

  GroupBox2.Visible := Length(InstallInfo.Description) > 0;
  Descr.Text := InstallInfo.Description;

  if (Length(InstallInfo.Readme) = 0) and (Length(InstallInfo.License) = 0) then
    NextBtn.Caption := '&Install >';
  if Length(InstallInfo.Readme) = 0 then
    Step2.Font.Color := clSilver
  else
    ReadmeMemo.Text := InstallInfo.Readme;

  if Length(InstallInfo.License) = 0 then
    Step3.Font.Color := clSilver
  else
    LicenseMemo.Text := InstallInfo.License;

  if InstallInfo.Reboot then
  begin
    Label21.Show;
    RadioButton1.Show;
    RadioButton2.Show;
  end;

  PMExitCode := PACKMAN_EXITCODE_NO_ERROR;
  Result := True;

  if Quiet then
    StartInstall;
end;

procedure TInstallWizard.Notebook1PageChanged(Sender: TObject);
begin
  PrevBtn.Enabled := (Notebook1.PageIndex > 0) and
                     (Notebook1.PageIndex < PageCount - 1) and
                     (Notebook1.PageIndex <> 3);
  Cancel.Enabled := Notebook1.PageIndex < PageCount - 1;
  Cancel.Visible := Notebook1.PageIndex < PageCount - 1;
  NextBtn.Enabled := Notebook1.PageIndex <> 3;
  ChangeLabels;

  if Notebook1.PageIndex = 3 then
      StartInstall;
end;

procedure TInstallWizard.OnUnZipProgress(Sender: TObject; FileName: string;
  Header: TZipHeader; Position: Int64);
begin
  bar.Max :=  Header.UncompressedSize;
  bar.Position := Position;
end;

procedure TInstallWizard.OnAbUnZipProgress(Sender: TObject; Progress: Byte;
  var Abort: Boolean);
begin
  bar.Max := 100;
  bar.Position := Progress;
end;

procedure TInstallWizard.CancelClick(Sender: TObject);
begin
  if Assigned(Installer) then
  begin
      if Application.MessageBox('Do you really wish to abort the installation?',
        'Warning', MB_ICONQUESTION + MB_YESNO) = IDYES then begin
           Installer.Abort
      end
      else
          Exit;
  end;
  PMExitCode := PACKMAN_EXITCODE_INSTALL_CANCELLED;
  Close;
end;

procedure TInstallWizard.PrevBtnClick(Sender: TObject);
begin
  case Notebook1.PageIndex of
  3: if Length(InstallInfo.License) > 0 then
         Notebook1.PageIndex := 2
     else if Length(InstallInfo.Readme) > 0 then
         Notebook1.PageIndex := 1
     else
         Notebook1.PageIndex := 0;
  2: if Length(InstallInfo.Readme) > 0 then
         Notebook1.PageIndex := 1
     else
         Notebook1.PageIndex := 0;
  else Notebook1.PageIndex := Notebook1.PageIndex - 1;
  end;
  if (Length(InstallInfo.Readme) = 0) and (Length(InstallInfo.License) = 0) then
      NextBtn.Caption := '&Install >';
end;

procedure TInstallWizard.NextBtnClick(Sender: TObject);
begin
  case Notebook1.PageIndex of
  0: if Length(InstallInfo.Readme) > 0 then
         Notebook1.PageIndex := 1
     else if Length(InstallInfo.License) > 0 then
         Notebook1.PageIndex := 2
     else
         Notebook1.PageIndex := 3;
  1: if Length(InstallInfo.License) > 0 then
         Notebook1.PageIndex := 2
     else
         Notebook1.PageIndex := 3;
  PageCount - 1: Close;
  else Notebook1.PageIndex := Notebook1.PageIndex + 1;
  end;
end;

procedure TInstallWizard.ChangeLabels;
const
  Steps: array[0..PageCount - 1] of AnsiString = (
    'Welcome',
    'Readme',
    'License',
    'Installing',
    'Finished'
  );
var
  i: Integer;
  L: TLabel;
begin
  case Notebook1.PageIndex of
  2: NextBtn.Caption := '&Install >';
  4: NextBtn.Caption := '&Finish';
  else NextBtn.Caption := '&Next >';
  end;

  for i := 0 to StepsPanel.ControlCount - 2 do
  begin
      L := TLabel(StepsPanel.Controls[i + 1]);
      if Notebook1.PageIndex = i then
      begin
          L.Caption := '> ' + Steps[i];
          L.Font.Style := L.Font.Style + [fsBold];
      end else
      begin
          L.Caption := Steps[i];
          L.Font.Style := L.Font.Style - [fsBold];
      end;
  end;
end;

procedure TInstallWizard.CancelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
      if Application.MessageBox('Do you need help on this wizard?', 'Question',
        MB_ICONQUESTION + MB_YESNO) = IDYES then
          ShellExecute(GetDesktopWindow, nil,
            'http://catalog.dummies.com/product.asp?isbn=0764502611', nil, nil,
            1)
      else
          { Do something? }
  end;
end;

procedure TInstallWizard.AboutBtnClick(Sender: TObject);
begin
  Application.MessageBox(
    'Embarcadero Dev-C++ Package Installation Wizard' + #13#10 +
    'Copyright (c) 2002 Hongli Lai' + #13#10 + #13#10 +
    'Licensed under the GNU General Public License.',
    'About', MB_ICONASTERISK);
end;

procedure TInstallWizard.Progress(Sender: TObject; CurrentFile: TInstallFile; Progress, Max: Integer);
begin
  ProgressBar1.Position := Progress;
  Label7.Caption := 'Current progress (' +
    IntToStr(Round(Progress / (InstallInfo.Files(AppDir).Count / 100))) +
    '%):';
  Label10.Caption := CurrentFile.Source;
  Label13.Caption := IntToStr(Progress);
  Label14.Caption := IntToStr(InstallInfo.Files(AppDir).Count - Progress);
end;

procedure TInstallWizard.StartInstall;
begin
  Installer := TInstaller.Create(InstallInfo);
  Installer.OnProgress := Progress;
  ProgressBar1.Max := InstallInfo.Files(AppDir).Count;
  Label14.Caption := IntToStr(ProgressBar1.Max);
  Label18.Caption := IntToStr(ProgressBar1.Max);
  BorderIcons := BorderIcons - [biSystemMenu];
  ActiveControl := Cancel;

  Application.ProcessMessages;
  if not Installer.Install then
  begin
      Installer.Free;
      Installer := nil;
      Close;
  end;
  Installer.Free;
  Installer := nil;
  BorderIcons := BorderIcons + [biSystemMenu];
  Notebook1.PageIndex := Notebook1.PageIndex + 1;
  ActiveControl := NextBtn;
end;

procedure TInstallWizard.UrlLabelClick(Sender: TObject);
begin
  ShellExecuteA(GetDesktopWindow, nil, PAnsiChar(TLabel(Sender).Caption),
    nil, nil, 1);
end;

procedure TInstallWizard.Label22Click(Sender: TObject);
begin
  ShellExecuteA(Handle, nil, 'notepad.exe',
    PAnsiChar('"' + InstallInfo.ReadmeFile + '"'),
    nil, SW_MAXIMIZE);
end;

procedure TInstallWizard.Label23Click(Sender: TObject);
begin
  ShellExecuteA(Handle, nil, 'notepad.exe',
    PAnsiChar('"' + InstallInfo.LicenseFile + '"'),
    nil, SW_MAXIMIZE);
end;

procedure TInstallWizard.FormCreate(Sender: TObject);
begin
  DontShowError := False;
end;

procedure TInstallWizard.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i: Integer;
begin
  if IsCompressed and DirectoryExists(TempFilesDir) then
  begin
      if Assigned(TempFiles) then
        for i := TempFiles.Count - 1 downto 0 do
          DeleteFile(ConvertSlashes(TempFiles.Strings[i]));
      FreeAndNil(TempFiles);

      if Assigned(TempDirs) then
        for i := TempDirs.Count - 1 downto 0 do
          RemoveDir(ConvertSlashes(TempDirs.Strings[i]));
      FreeAndNil(TempDirs);
      RemoveDir(TempFilesDir);
  end;

  if (Assigned(InstallInfo)) and (InstallInfo.Reboot) and
    (RadioButton1.Checked) then
  begin
    FreeAndNil(InstallInfo);
    ExitWindowsEx(EWX_REBOOT, 0);
    Application.Terminate;
  end;

  if InstallInfo <> nil then
    FreeAndNil(InstallInfo);
  Action := caFree;
end;

constructor TInstallWizard.Create(AOwner: TComponent);
begin
  inherited;

  PMExitCode := PACKMAN_EXITCODE_ERRCODE_UNKNOWN;
  Quiet := False;
end;

end.

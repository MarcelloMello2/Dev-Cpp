﻿{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEditMiscClasses.pas, released 2000-04-07.
The Original Code is based on the mwSupportClasses.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Michael Hieke.
Unicode translation by Maël Hörz.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynEditMiscClasses.pas,v 1.35.2.9 2008/09/17 13:59:12 maelh Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

unit SynEditMiscClasses;

{$I SynEdit.inc}

interface

uses
  Windows,
  Messages,
  Registry,
  Consts,
  SysUtils,
  Classes,
  Math,
  Graphics,
  Controls,
  Forms,
  StdCtrls,
  Menus,
  ImgList,
  SynEditTypes,
  SynEditKeyConst,
  SynUnicode;

type
  TSynSelectedColor = class(TPersistent)
  private
    fBG: TColor;
    fFG: TColor;
    fOnChange: TNotifyEvent;
    procedure SetBG(Value: TColor);
    procedure SetFG(Value: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Background: TColor read fBG write SetBG default clHighLight;
    property Foreground: TColor read fFG write SetFG default clHighLightText;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynGutterBorderStyle = (gbsNone, gbsMiddle, gbsRight);

  TSynGutter = class(TPersistent)
  private
    fFont: TFont;
    fColor: TColor;
    fBorderColor: TColor;
    fWidth: integer;
    fShowLineNumbers: boolean;
    fDigitCount: integer;
    fLeadingZeros: boolean;
    fZeroStart: boolean;
    fLeftOffset: integer;
    fRightOffset: integer;
    fRightMargin: integer;
    fOnChange: TNotifyEvent;
    fCursor: TCursor;
    fVisible: boolean;
    fUseFontStyle: boolean;
    fAutoSize: boolean;
    fAutoSizeDigitCount: integer;
    fBorderStyle: TSynGutterBorderStyle;
    fLineNumberStart: Integer;
    fGradient: Boolean;
    fGradientStartColor: TColor;
    fGradientEndColor: TColor;
    fGradientSteps: Integer;
    procedure SetAutoSize(const Value: boolean);
    procedure SetBorderColor(const Value: TColor);
    procedure SetColor(const Value: TColor);
    procedure SetDigitCount(Value: integer);
    procedure SetLeadingZeros(const Value: boolean);
    procedure SetLeftOffset(Value: integer);
    procedure SetRightOffset(Value: integer);
    procedure SetRightMargin(Value: integer);
    procedure SetShowLineNumbers(const Value: boolean);
    procedure SetUseFontStyle(Value: boolean);
    procedure SetVisible(Value: boolean);
    procedure SetWidth(Value: integer);
    procedure SetZeroStart(const Value: boolean);
    procedure SetFont(Value: TFont);
    procedure OnFontChange(Sender: TObject);
    procedure SetBorderStyle(const Value: TSynGutterBorderStyle);
    procedure SetLineNumberStart(const Value: Integer);
    procedure SetGradient(const Value: Boolean);
    procedure SetGradientStartColor(const Value: TColor);
    procedure SetGradientEndColor(const Value: TColor);
    procedure SetGradientSteps(const Value: Integer);
    function GetWidth: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AutoSizeDigitCount(LinesCount: integer);
    function FormatLineNumber(Line: integer): string;
    function RealGutterWidth(CharWidth: integer): integer;
 //++ DPI-Aware
    procedure ChangeScale(M, D: Integer); virtual;
//-- DPI-Aware
  published
    property AutoSize: boolean read fAutoSize write SetAutoSize default FALSE;
    property BorderStyle: TSynGutterBorderStyle read fBorderStyle
      write SetBorderStyle default gbsMiddle;
    property Color: TColor read fColor write SetColor default clBtnFace;
    property BorderColor: TColor read fBorderColor write SetBorderColor default clWindow;
    property Cursor: TCursor read fCursor write fCursor default crDefault;
    property DigitCount: integer read fDigitCount write SetDigitCount
      default 4;
    property Font: TFont read fFont write SetFont;
    property LeadingZeros: boolean read fLeadingZeros write SetLeadingZeros
      default FALSE;
    property LeftOffset: integer read fLeftOffset write SetLeftOffset
      default 16;
    property RightOffset: integer read fRightOffset write SetRightOffset
      default 2;
    property RightMargin: integer read fRightMargin write SetRightMargin
      default 2;
    property ShowLineNumbers: boolean read fShowLineNumbers
      write SetShowLineNumbers default FALSE;
    property UseFontStyle: boolean read fUseFontStyle write SetUseFontStyle
      default True;
    property Visible: boolean read fVisible write SetVisible default TRUE;
    property Width: integer read GetWidth write SetWidth default 30;
    property ZeroStart: boolean read fZeroStart write SetZeroStart
      default False;
    property LineNumberStart: Integer read fLineNumberStart write SetLineNumberStart default 1;
    property Gradient: Boolean read fGradient write SetGradient default False;
    property GradientStartColor: TColor read fGradientStartColor write SetGradientStartColor default clWindow;
    property GradientEndColor: TColor read fGradientEndColor write SetGradientEndColor default clBtnFace;
    property GradientSteps: Integer read fGradientSteps write SetGradientSteps default 48;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynBookMarkOpt = class(TPersistent)
  private
    fBookmarkImages: TCustomImageList;
    fDrawBookmarksFirst: boolean;
    fEnableKeys: Boolean;
    fGlyphsVisible: Boolean;
    fLeftMargin: Integer;
    fOwner: TComponent;
    fXoffset: integer;
    fOnChange: TNotifyEvent;
    procedure SetBookmarkImages(const Value: TCustomImageList);
    procedure SetDrawBookmarksFirst(Value: boolean);
    procedure SetGlyphsVisible(Value: Boolean);
    procedure SetLeftMargin(Value: Integer);
    procedure SetXOffset(Value: integer);
  public
    constructor Create(AOwner: TComponent);
    procedure Assign(Source: TPersistent); override;
 //++ DPI-Aware
    procedure ChangeScale(M, D: Integer); virtual;
//-- DPI-Aware
  published
    property BookmarkImages: TCustomImageList
      read fBookmarkImages write SetBookmarkImages;
    property DrawBookmarksFirst: boolean read fDrawBookmarksFirst
      write SetDrawBookmarksFirst default True;
    property EnableKeys: Boolean
      read fEnableKeys write fEnableKeys default True;
    property GlyphsVisible: Boolean
      read fGlyphsVisible write SetGlyphsVisible default True;
    property LeftMargin: Integer read fLeftMargin write SetLeftMargin default 2;
    property Xoffset: integer read fXoffset write SetXOffset default 12;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynGlyph = class(TPersistent)
  private
    fVisible: boolean;
    fInternalGlyph, fGlyph: TBitmap;
    fInternalMaskColor, fMaskColor: TColor;
    fOnChange: TNotifyEvent;
    procedure SetGlyph(Value: TBitmap);
    procedure GlyphChange(Sender: TObject);
    procedure SetMaskColor(Value: TColor);
    procedure SetVisible(Value: boolean);
    function GetWidth : integer;
    function GetHeight : integer;
  public
    constructor Create(aModule: THandle; const aName: string; aMaskColor: TColor);
    destructor Destroy; override;
    procedure Assign(aSource: TPersistent); override;
    procedure Draw(aCanvas: TCanvas; aX, aY, aLineHeight: integer);
    property Width : integer read GetWidth;
    property Height : integer read GetHeight;
 //++ DPI-Aware
    procedure ChangeScale(M, D: Integer); virtual;
//-- DPI-Aware
  published
    property Glyph: TBitmap read fGlyph write SetGlyph;
    property MaskColor: TColor read fMaskColor write SetMaskColor default clNone;
    property Visible: boolean read fVisible write SetVisible default True;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  { TSynMethodChain }

  ESynMethodChain = class(Exception);
  TSynExceptionEvent = procedure (Sender: TObject; E: Exception;
    var DoContinue: Boolean) of object;

  TSynMethodChain = class(TObject)
  private
    FNotifyProcs: TList;
    FExceptionHandler: TSynExceptionEvent;
  protected
    procedure DoFire(const AEvent: TMethod); virtual; abstract;
    function DoHandleException(E: Exception): Boolean; virtual;
    property ExceptionHandler: TSynExceptionEvent read FExceptionHandler
      write FExceptionHandler;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(AEvent: TMethod);
    procedure Remove(AEvent: TMethod);
    procedure Fire;
  end;

  { TSynNotifyEventChain }

  TSynNotifyEventChain = class(TSynMethodChain)
  private
    FSender: TObject;
  protected
    procedure DoFire(const AEvent: TMethod); override;
  public
    constructor CreateEx(ASender: TObject);
    procedure Add(AEvent: TNotifyEvent);
    procedure Remove(AEvent: TNotifyEvent);
    property ExceptionHandler;
    property Sender: TObject read FSender write FSender;
  end;

  { TSynInternalImage }

  TSynInternalImage = class(TObject)
  private
    fImages : TBitmap;
    fWidth  : Integer;
    fHeight : Integer;
    fCount  : Integer;

  public
    constructor Create(aModule: THandle; const Name: string; Count: integer);
    destructor Destroy; override;
    procedure Draw(ACanvas: TCanvas; Number, X, Y, LineHeight: integer);
    procedure DrawTransparent(ACanvas: TCanvas; Number, X, Y,
      LineHeight: integer; TransparentColor: TColor);
 //++ DPI-Aware
    procedure ChangeScale(M, D: Integer); virtual;
//-- DPI-Aware
  end;

{ TSynHotKey }

const
  BorderWidth = 0;

type
  TSynBorderStyle = TBorderStyle;

  THKModifier = (hkShift, hkCtrl, hkAlt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  TSynHotKey = class(TCustomControl)
  private
    FBorderStyle: TSynBorderStyle;
    FHotKey: TShortCut;
    FInvalidKeys: THKInvalidKeys;
    FModifiers: THKModifiers;
    FPressedOnlyModifiers: Boolean;
    procedure SetBorderStyle(const Value: TSynBorderStyle);
    procedure SetHotKey(const Value: TShortCut);
    procedure SetInvalidKeys(const Value: THKInvalidKeys);
    procedure SetModifiers(const Value: THKModifiers);
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
     procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Font;
    property Color;
    property BorderStyle: TSynBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;
    property HotKey: TShortCut read FHotKey write SetHotKey default $0041; { Alt+A }
    property InvalidKeys: THKInvalidKeys read FInvalidKeys write SetInvalidKeys default [hcNone, hcShift];
    property Modifiers: THKModifiers read FModifiers write SetModifiers default [hkAlt];
  end;

  TSynEditSearchCustom = class(TComponent)
  protected
    function GetPattern: string; virtual; abstract;
    procedure SetPattern(const Value: string); virtual; abstract;
    function GetLength(Index: Integer): Integer; virtual; abstract;
    function GetResult(Index: Integer): Integer; virtual; abstract;
    function GetResultCount: Integer; virtual; abstract;
    procedure SetOptions(const Value: TSynSearchOptions); virtual; abstract;
  public
    function FindAll(const NewText: string): Integer; virtual; abstract;
    function Replace(const aOccurrence, aReplacement: string): string; virtual; abstract;
    property Pattern: string read GetPattern write SetPattern;
    property ResultCount: Integer read GetResultCount;
    property Results[Index: Integer]: Integer read GetResult;
    property Lengths[Index: Integer]: Integer read GetLength;
    property Options: TSynSearchOptions write SetOptions;
  end;

  TBetterRegistry = class(TRegistry)
    function OpenKeyReadOnly(const Key: string): Boolean;
  end;

//++ DPI-Aware
  procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth,
    NewHeight: integer);
//-- DPI-Aware


implementation

uses
  Winapi.Wincodec,
  SynEditMiscProcs;

//++ DPI-Aware
procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);
var
  Factory: IWICImagingFactory;
  Scaler: IWICBitmapScaler;
  Source : TWICImage;
begin
  //Bitmap.AlphaFormat := afDefined;
  Source := TWICImage.Create;
  try
    Source.Assign(Bitmap);
    Factory := TWICImage.ImagingFactory;
    Factory.CreateBitmapScaler(Scaler);
    try
      Scaler.Initialize(Source.Handle, NewWidth, NewHeight,
        WICBitmapInterpolationModeHighQualityCubic);
      Source.Handle := IWICBitmap(Scaler);
    finally
      Scaler := nil;
      Factory := nil;
    end;
    Bitmap.Assign(Source);
  finally
    Source.Free;
  end;
end;
//-- DPI-Aware

{ TSynSelectedColor }

constructor TSynSelectedColor.Create;
begin
  inherited Create;
  fBG := clHighLight;
  fFG := clHighLightText;
end;

procedure TSynSelectedColor.Assign(Source: TPersistent);
var
  Src: TSynSelectedColor;
begin
  if (Source <> nil) and (Source is TSynSelectedColor) then begin
    Src := TSynSelectedColor(Source);
    fBG := Src.fBG;
    fFG := Src.fFG;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited Assign(Source);
end;

procedure TSynSelectedColor.SetBG(Value: TColor);
begin
  if (fBG <> Value) then begin
    fBG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynSelectedColor.SetFG(Value: TColor);
begin
  if (fFG <> Value) then begin
    fFG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TSynGutter }
 //++ DPI-Aware
procedure TSynGutter.ChangeScale(M, D: Integer);
begin
  fWidth := MulDiv(fWidth, M, D);
  fLeftOffset := MulDiv(fLeftOffset, M, D);
  fRightOffset := MulDiv(fRightOffset, M, D);
  fRightMargin := MulDiv(fRightMargin, M, D);
  fFont.Height := Round(fFont.Height * M / D);
  if Assigned(fOnChange) then fOnChange(Self);
end;
//-- DPI-Aware

constructor TSynGutter.Create;
begin
  inherited Create;
  fFont := TFont.Create;
  fFont.Name := DefaultFontName;
  fFont.Size := 8;
  fFont.Style := [];
  fUseFontStyle := True;
  fFont.OnChange := OnFontChange;

  fColor := clBtnFace;
  fVisible := TRUE;
  fWidth := 30;
  fLeftOffset := 16;
  fDigitCount := 4;
  fAutoSizeDigitCount := fDigitCount;
  fRightOffset := 2;
  fRightMargin := 2;
  fBorderColor := clWindow;
  fBorderStyle := gbsMiddle;
  fLineNumberStart := 1;
  fZeroStart := False;
  fGradient := False;
  fGradientStartColor := clWindow;
  fGradientEndColor := clBtnFace;
  fGradientSteps := 48;
end;

destructor TSynGutter.Destroy;
begin
  fFont.Free;
  inherited Destroy;
end;

procedure TSynGutter.Assign(Source: TPersistent);
var
  Src: TSynGutter;
begin
  if Assigned(Source) and (Source is TSynGutter) then 
  begin
    Src := TSynGutter(Source);
    fFont.Assign(src.Font);
    fUseFontStyle := src.fUseFontStyle;
    fColor := Src.fColor;
    fVisible := Src.fVisible;
    fWidth := Src.fWidth;
    fShowLineNumbers := Src.fShowLineNumbers;
    fLeadingZeros := Src.fLeadingZeros;
    fZeroStart := Src.fZeroStart;
    fLeftOffset := Src.fLeftOffset;
    fDigitCount := Src.fDigitCount;
//++  Code Folding
    // Do not change RightOffset since it varies with Code Folding
    //fRightOffset := Src.fRightOffset;
//--  Code Folding
    fRightMargin := Src.fRightMargin;
    fAutoSize := Src.fAutoSize;
    fAutoSizeDigitCount := Src.fAutoSizeDigitCount;
    fLineNumberStart := Src.fLineNumberStart;
    fBorderColor := Src.fBorderColor;
    fBorderStyle := Src.fBorderStyle;
    fGradient := Src.fGradient;
    fGradientStartColor := Src.fGradientStartColor;
    fGradientEndColor := Src.fGradientEndColor;
    fGradientSteps := Src.fGradientSteps;
    if Assigned(fOnChange) then fOnChange(Self);
  end 
  else
    inherited;
end;

procedure TSynGutter.AutoSizeDigitCount(LinesCount: integer);
var
  nDigits: integer;
begin
  if fVisible and fAutoSize and fShowLineNumbers then 
  begin
    if fZeroStart then
      Dec(LinesCount)
    else if fLineNumberStart > 1 then
      Inc(LinesCount, fLineNumberStart - 1);

    nDigits := Max(Length(IntToStr(LinesCount)), fDigitCount);
    if fAutoSizeDigitCount <> nDigits then begin
      fAutoSizeDigitCount := nDigits;
      if Assigned(fOnChange) then fOnChange(Self);
    end;
  end else
    fAutoSizeDigitCount := fDigitCount;
end;

function TSynGutter.FormatLineNumber(Line: integer): string;
var
  i: integer;
begin
  if fZeroStart then
    Dec(Line)
  else if fLineNumberStart > 1 then
    Inc(Line, fLineNumberStart - 1);
  Result := Format('%*d', [fAutoSizeDigitCount, Line]);
  if fLeadingZeros then
    for i := 1 to fAutoSizeDigitCount - 1 do begin
      if (Result[i] <> ' ') then break;
      Result[i] := '0';
    end;
end;

function TSynGutter.RealGutterWidth(CharWidth: integer): integer;
begin
  if not fVisible then
    Result := 0
  else if fShowLineNumbers then
    Result := fLeftOffset + fRightOffset + fAutoSizeDigitCount * CharWidth + fRightMargin
  else if fAutoSize then
    Result := fLeftOffset + fRightOffset + fRightMargin
  else
    Result := fWidth;
end;

procedure TSynGutter.SetAutoSize(const Value: boolean);
begin
  if fAutoSize <> Value then begin
    fAutoSize := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetColor(const Value: TColor);
begin
  if fColor <> Value then begin
    fColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetFont(Value: TFont);
begin
  fFont.Assign(Value);
end;

procedure TSynGutter.OnFontChange(Sender: TObject);
begin
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGutter.SetDigitCount(Value: integer);
begin
  Value := MinMax(Value, 2, 12);
  if fDigitCount <> Value then begin
    fDigitCount := Value;
    fAutoSizeDigitCount := fDigitCount;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetLeadingZeros(const Value: boolean);
begin
  if fLeadingZeros <> Value then begin
    fLeadingZeros := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetLeftOffset(Value: integer);
begin
  Value := Max(0, Value);
  if fLeftOffset <> Value then begin
    fLeftOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetRightOffset(Value: integer);
begin
  Value := Max(0, Value);
  if fRightOffset <> Value then begin
    fRightOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetRightMargin(Value: integer);
begin
  Value := Max(0, Value);
  if fRightMargin <> Value then begin
    fRightMargin := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetShowLineNumbers(const Value: boolean);
begin
  if fShowLineNumbers <> Value then begin
    fShowLineNumbers := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetUseFontStyle(Value: boolean);
begin
  if fUseFontStyle <> Value then begin
    fUseFontStyle := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetVisible(Value: boolean);
begin
  if fVisible <> Value then begin
    fVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetWidth(Value: integer);
begin
  Value := Max(0, Value);
  if fWidth <> Value then begin
    fWidth := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetZeroStart(const Value: boolean);
begin
  if fZeroStart <> Value then begin
    fZeroStart := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetBorderStyle(const Value: TSynGutterBorderStyle);
begin
  fBorderStyle := Value;
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGutter.SetLineNumberStart(const Value: Integer);
begin
  if Value <> fLineNumberStart then
  begin
    fLineNumberStart := Value;
    if fLineNumberStart < 0 then
      fLineNumberStart := 0;
    if fLineNumberStart = 0 then
      fZeroStart := True
    else
      fZeroStart := False;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then 
  begin
    fBorderColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradient(const Value: Boolean);
begin
  if Value <> fGradient then
  begin
    fGradient := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientEndColor(const Value: TColor);
begin
  if Value <> fGradientEndColor then
  begin
    fGradientEndColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientStartColor(const Value: TColor);
begin
  if Value <> fGradientStartColor then
  begin
    fGradientStartColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientSteps(const Value: Integer);
begin
  if Value <> fGradientSteps then
  begin
    fGradientSteps := Value;
    if fGradientSteps < 2 then
      fGradientSteps := 2;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

function TSynGutter.GetWidth: integer;
begin
  if not Visible then
    Result := 0
  else
    Result := fWidth;
end;

{ TSynBookMarkOpt }

//++ DPI-Aware
procedure TSynBookMarkOpt.ChangeScale(M, D: Integer);
begin
  fLeftMargin := MulDiv(fLeftMargin, M, D);
  fXoffset := MulDiv(fXoffset, M, D);
end;
//-- DPI-Aware

constructor TSynBookMarkOpt.Create(AOwner: TComponent);
begin
  inherited Create;
  fDrawBookmarksFirst := TRUE;
  fEnableKeys := True;
  fGlyphsVisible := True;
  fLeftMargin := 2;
  fOwner := AOwner;
  fXOffset := 12;
end;

procedure TSynBookMarkOpt.Assign(Source: TPersistent);
var
  Src: TSynBookMarkOpt;
begin
  if (Source <> nil) and (Source is TSynBookMarkOpt) then begin
    Src := TSynBookMarkOpt(Source);
    fBookmarkImages := Src.fBookmarkImages;
    fDrawBookmarksFirst := Src.fDrawBookmarksFirst;
    fEnableKeys := Src.fEnableKeys;
    fGlyphsVisible := Src.fGlyphsVisible;
    fLeftMargin := Src.fLeftMargin;
    fXoffset := Src.fXoffset;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited Assign(Source);
end;

procedure TSynBookMarkOpt.SetBookmarkImages(const Value: TCustomImageList);
begin
  if fBookmarkImages <> Value then begin
    fBookmarkImages := Value;
    if Assigned(fBookmarkImages) then fBookmarkImages.FreeNotification(fOwner);
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetDrawBookmarksFirst(Value: boolean);
begin
  if Value <> fDrawBookmarksFirst then begin
    fDrawBookmarksFirst := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetGlyphsVisible(Value: Boolean);
begin
  if fGlyphsVisible <> Value then begin
    fGlyphsVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetLeftMargin(Value: Integer);
begin
  if fLeftMargin <> Value then begin
    fLeftMargin := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetXOffset(Value: integer);
begin
  if fXOffset <> Value then begin
    fXOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TSynGlyph }

//++ DPI-Aware
procedure TSynGlyph.ChangeScale(M, D: Integer);
begin
  ResizeBitmap(fInternalGlyph, MulDiv(fInternalGlyph.Width, M, D), MulDiv(fInternalGlyph.Height, M, D));
  if not fGlyph.Empty then
    ResizeBitmap(fGlyph, MulDiv(fGlyph.Width, M, D), MulDiv(fGlyph.Height, M, D));
end;
//-- DPI-Aware

constructor TSynGlyph.Create(aModule: THandle; const aName: string; aMaskColor: TColor);
begin
  inherited Create;

  if aName <> '' then
  begin
    fInternalGlyph := TBitmap.Create;
    fInternalGlyph.LoadFromResourceName(aModule, aName);
    fInternalMaskColor := aMaskColor;
  end
  else
    fInternalMaskColor := clNone;

  fVisible := True;
  fGlyph := TBitmap.Create;
  fGlyph.OnChange := GlyphChange;
  fMaskColor := clNone;
end;

destructor TSynGlyph.Destroy;
begin
  if Assigned(fInternalGlyph) then
    FreeAndNil(fInternalGlyph);

  fGlyph.Free;

  inherited Destroy;
end;

procedure TSynGlyph.Assign(aSource: TPersistent);
var
  vSrc : TSynGlyph;
begin
  if Assigned(aSource) and (aSource is TSynGlyph) then
  begin
    vSrc := TSynGlyph(aSource);
    fInternalGlyph := vSrc.fInternalGlyph;
    fInternalMaskColor := vSrc.fInternalMaskColor;
    fVisible := vSrc.fVisible;
    fGlyph := vSrc.fGlyph;
    fMaskColor := vSrc.fMaskColor;
    if Assigned(fOnChange) then fOnChange(Self);
  end
  else
    inherited;
end;

procedure TSynGlyph.Draw(aCanvas: TCanvas; aX, aY, aLineHeight: integer);
var
  rcSrc, rcDest : TRect;
  vGlyph : TBitmap;
  vMaskColor : TColor;
begin
  if not fGlyph.Empty then
  begin
    vGlyph := fGlyph;
    vMaskColor := fMaskColor;
  end
  else if Assigned(fInternalGlyph) then
  begin
    vGlyph := fInternalGlyph;
    vMaskColor := fInternalMaskColor;
  end
  else
    Exit;

  if aLineHeight >= vGlyph.Height then
  begin
    rcSrc := Rect(0, 0, vGlyph.Width, vGlyph.Height);
    Inc(aY, (aLineHeight - vGlyph.Height) div 2);
    rcDest := Rect(aX, aY, aX + vGlyph.Width, aY + vGlyph.Height);
  end
  else
  begin
    rcDest := Rect(aX, aY, aX + vGlyph.Width, aY + aLineHeight);
    aY := (vGlyph.Height - aLineHeight) div 2;
    rcSrc := Rect(0, aY, vGlyph.Width, aY + aLineHeight);
  end;

  aCanvas.BrushCopy(rcDest, vGlyph, rcSrc, vMaskColor);
end;

procedure TSynGlyph.SetGlyph(Value: TBitmap);
begin
  fGlyph.Assign(Value);
end;

procedure TSynGlyph.GlyphChange(Sender: TObject);
begin
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGlyph.SetMaskColor(Value: TColor);
begin
  if fMaskColor <> Value then
  begin
    fMaskColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGlyph.SetVisible(Value: boolean);
begin
  if fVisible <> Value then
  begin
    fVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

function TSynGlyph.GetWidth : integer;
begin
  if not fGlyph.Empty then
    Result := fGlyph.Width
  else
  if Assigned(fInternalGlyph) then
    Result := fInternalGlyph.Width
  else
    Result := 0;
end;

function TSynGlyph.GetHeight : integer;
begin
  if not fGlyph.Empty then
    Result := fGlyph.Height
  else
  if Assigned(fInternalGlyph) then
    Result := fInternalGlyph.Height
  else
    Result := 0;
end;

{ TSynMethodChain }

procedure TSynMethodChain.Add(AEvent: TMethod);
begin
  if not Assigned(@AEvent) then
    raise ESynMethodChain.CreateFmt(
      '%s.Entry : the parameter `AEvent'' must be specified.', [ClassName]);

  with FNotifyProcs, AEvent do
  begin
    Add(Code);
    Add(Data);
  end
end;

constructor TSynMethodChain.Create;
begin
  inherited;
  FNotifyProcs := TList.Create;
end;

destructor TSynMethodChain.Destroy;
begin
  FNotifyProcs.Free;
  inherited;
end;

function TSynMethodChain.DoHandleException(E: Exception): Boolean;
begin
  if not Assigned(FExceptionHandler) then
    raise E
  else
    try
      Result := True;
      FExceptionHandler(Self, E, Result);
    except
      raise ESynMethodChain.CreateFmt(
        '%s.DoHandleException : MUST NOT occur any kind of exception in '+
        'ExceptionHandler', [ClassName]);
    end;
end;

procedure TSynMethodChain.Fire;
var
  AMethod: TMethod;
  i: Integer;
begin
  i := 0;
  with FNotifyProcs, AMethod do
    while i < Count do
      try
        repeat
          Code := Items[i];
          Inc(i);
          Data := Items[i];
          Inc(i);

          DoFire(AMethod)
        until i >= Count;
      except
        on E: Exception do
          if not DoHandleException(E) then
            i := MaxInt;
      end;
end;

procedure TSynMethodChain.Remove(AEvent: TMethod);
var
  i: Integer;
begin
  if not Assigned(@AEvent) then
    raise ESynMethodChain.CreateFmt(
      '%s.Remove: the parameter `AEvent'' must be specified.', [ClassName]);

  with FNotifyProcs, AEvent do
  begin
    i := Count - 1;
    while i > 0 do
      if Items[i] <> Data then
        Dec(i, 2)
      else
      begin
        Dec(i);
        if Items[i] = Code then
        begin
          Delete(i);
          Delete(i);
        end;
        Dec(i);
      end;
  end;
end;

{ TSynNotifyEventChain }

procedure TSynNotifyEventChain.Add(AEvent: TNotifyEvent);
begin
  inherited Add(TMethod(AEvent));
end;

constructor TSynNotifyEventChain.CreateEx(ASender: TObject);
begin
  inherited Create;
  FSender := ASender;
end;

procedure TSynNotifyEventChain.DoFire(const AEvent: TMethod);
begin
  TNotifyEvent(AEvent)(FSender);
end;

procedure TSynNotifyEventChain.Remove(AEvent: TNotifyEvent);
begin
  inherited Remove(TMethod(AEvent));
end;


{ TSynInternalImage }

type
  TInternalResource = class (TObject)
    public
      UsageCount : Integer;
      Name       : string;
      Bitmap     : TBitmap;
  end;

procedure TSynInternalImage.ChangeScale(M, D: Integer);
begin
  if M = D then Exit;

  fWidth := MulDiv(fWidth, M, D);
  ResizeBitmap(fImages, fWidth * fCount, MulDiv(fImages.Height, M, D));
  fHeight := fImages.Height;
end;

constructor TSynInternalImage.Create(aModule: THandle; const Name: string; Count: integer);
begin
  inherited Create;
  fImages := TBitmap.Create;
  fImages.LoadFromResourceName(aModule, Name);
  fWidth := (fImages.Width + Count shr 1) div Count;
  fHeight := fImages.Height;
  fCount := Count;
end;

destructor TSynInternalImage.Destroy;
begin
  fImages.Free;
  inherited Destroy;
end;

procedure TSynInternalImage.Draw(ACanvas: TCanvas;
  Number, X, Y, LineHeight: integer);
var
  rcSrc, rcDest: TRect;
begin
  if (Number >= 0) and (Number < fCount) then
  begin
    if LineHeight >= fHeight then begin
      rcSrc := Rect(Number * fWidth, 0, (Number + 1) * fWidth, fHeight);
      Inc(Y, (LineHeight - fHeight) div 2);
      rcDest := Rect(X, Y, X + fWidth, Y + fHeight);
    end else begin
      rcDest := Rect(X, Y, X + fWidth, Y + LineHeight);
      Y := (fHeight - LineHeight) div 2;
      rcSrc := Rect(Number * fWidth, Y, (Number + 1) * fWidth,
        Y + LineHeight);
    end;
    ACanvas.CopyRect(rcDest, fImages.Canvas, rcSrc);
  end;
end;

procedure TSynInternalImage.DrawTransparent(ACanvas: TCanvas; Number, X, Y,
  LineHeight: integer; TransparentColor: TColor);
var
  rcSrc, rcDest: TRect;
begin
  if (Number >= 0) and (Number < fCount) then
  begin
    if LineHeight >= fHeight then begin
      rcSrc := Rect(Number * fWidth, 0, (Number + 1) * fWidth, fHeight);
      Inc(Y, (LineHeight - fHeight) div 2);
      rcDest := Rect(X, Y, X + fWidth, Y + fHeight);
    end else begin
      rcDest := Rect(X, Y, X + fWidth, Y + LineHeight);
      Y := (fHeight - LineHeight) div 2;
      rcSrc := Rect(Number * fWidth, Y, (Number + 1) * fWidth,
        Y + LineHeight);
    end;
    ACanvas.BrushCopy(rcDest, fImages, rcSrc, TransparentColor);
  end;
end;

{ TSynHotKey }

function KeySameAsShiftState(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := (Key = SYNEDIT_SHIFT) and (ssShift in Shift) or
            (Key = SYNEDIT_CONTROL) and (ssCtrl in Shift) or
            (Key = SYNEDIT_MENU) and (ssAlt in Shift);
end;

function ModifiersToShiftState(Modifiers: THKModifiers): TShiftState;
begin
  Result := [];
  if hkShift in Modifiers then Include(Result, ssShift);
  if hkCtrl in Modifiers then Include(Result, ssCtrl);
  if hkAlt in Modifiers then Include(Result, ssAlt);
end;

function ShiftStateToTHKInvalidKey(Shift: TShiftState): THKInvalidKey;
begin
  Shift := Shift * [ssShift, ssAlt, ssCtrl];
  if Shift = [ssShift] then
    Result := hcShift
  else if Shift = [ssCtrl] then
    Result := hcCtrl
  else if Shift = [ssAlt] then
    Result := hcAlt
  else if Shift = [ssShift, ssCtrl] then
    Result := hcShiftCtrl
  else if Shift = [ssShift, ssAlt] then
    Result := hcShiftAlt
  else if Shift = [ssCtrl, ssAlt] then
    Result := hcCtrlAlt
  else if Shift = [ssShift, ssCtrl, ssAlt] then
    Result := hcShiftCtrlAlt
  else
    Result := hcNone;
end;

function ShortCutToTextEx(Key: Word; Shift: TShiftState): string;
begin
  if ssCtrl in Shift then Result := SmkcCtrl;
  if ssShift in Shift then Result := Result + SmkcShift;
  if ssAlt in Shift then Result := Result + SmkcAlt;

  Result := Result + ShortCutToText(TShortCut(Key));
  if Result = '' then
    Result := srNone;
end;

constructor TSynHotKey.Create(AOwner: TComponent);
begin
  inherited;

  BorderStyle := bsSingle;
  ControlStyle := ControlStyle + [csNeedsBorderPaint];

  FInvalidKeys := [hcNone, hcShift];
  FModifiers := [hkAlt];
  SetHotKey($0041); { Alt+A }

  ParentColor := False;
  Color := clWindow;
  TabStop := True;
end;

procedure TSynHotKey.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TSynBorderStyle] of DWORD = (0, WS_BORDER);
  ClassStylesOff = CS_VREDRAW or CS_HREDRAW;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.Style := WindowClass.Style and not ClassStylesOff;
    Style := Style or BorderStyles[fBorderStyle] or WS_CLIPCHILDREN;

    if NewStyleControls and Ctl3D and (fBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TSynHotKey.DoExit;
begin
  inherited;
  if FPressedOnlyModifiers then
  begin
    Text := srNone;
    Invalidate;
  end;
end;

procedure TSynHotKey.KeyDown(var Key: Word; Shift: TShiftState);
var
  MaybeInvalidKey: THKInvalidKey;
  SavedKey: Word;
begin
  SavedKey := Key;
  FPressedOnlyModifiers := KeySameAsShiftState(Key, Shift);

  MaybeInvalidKey := ShiftStateToTHKInvalidKey(Shift);
  if MaybeInvalidKey in FInvalidKeys then
    Shift := ModifiersToShiftState(FModifiers);

  if not FPressedOnlyModifiers then
  begin
    FHotKey := ShortCut(Key, Shift)
  end
  else
  begin
    FHotKey := 0;
    Key := 0;
  end;

  if Text <> ShortCutToTextEx(Key, Shift) then
  begin
    Text := ShortCutToTextEx(Key, Shift);
    Invalidate;
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  end;

  Key := SavedKey;
end;

procedure TSynHotKey.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if FPressedOnlyModifiers then
  begin
    Text := srNone;
    Invalidate;
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  end;
end;

procedure TSynHotKey.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  SetFocus;
end;

procedure TSynHotKey.Paint;
var
  r: TRect;
begin
  r := ClientRect;
  
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  InflateRect(r, -BorderWidth, -BorderWidth);
  Canvas.FillRect(r);
  Canvas.Font := Font;
  Canvas.TextRect(r, BorderWidth + 1, BorderWidth + 1, Text);
end;

procedure TSynHotKey.SetBorderStyle(const Value: TSynBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TSynHotKey.SetHotKey(const Value: TShortCut);
var
  Key: Word;
  Shift: TShiftState;
  MaybeInvalidKey: THKInvalidKey;
begin
  ShortCutToKey(Value, Key, Shift);

  MaybeInvalidKey := ShiftStateToTHKInvalidKey(Shift);
  if MaybeInvalidKey in FInvalidKeys then
    Shift := ModifiersToShiftState(FModifiers);

  FHotKey := ShortCut(Key, Shift);
  Text := ShortCutToTextEx(Key, Shift);
  Invalidate;
  if not Visible then
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
end;

procedure TSynHotKey.SetInvalidKeys(const Value: THKInvalidKeys);
begin
  FInvalidKeys := Value;
  SetHotKey(FHotKey);
end;

procedure TSynHotKey.SetModifiers(const Value: THKModifiers);
begin
  FModifiers := Value;
  SetHotKey(FHotKey);
end;

procedure TSynHotKey.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTTAB or DLGC_WANTARROWS;
end;

procedure TSynHotKey.WMKillFocus(var Msg: TWMKillFocus);
begin
  DestroyCaret;
end;

procedure TSynHotKey.WMSetFocus(var Msg: TWMSetFocus);
begin
  Canvas.Font := Font;
  CreateCaret(Handle, 0, 1, -Canvas.Font.Height + 2);
  SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  ShowCaret(Handle);
end;

{ TBetterRegistry }

function TBetterRegistry.OpenKeyReadOnly(const Key: string): Boolean;

  function IsRelative(const Value: string): Boolean;
  begin
    Result := not ((Value <> '') and (Value[1] = '\'));
  end;

var
  TempKey: HKey;
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);

  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      KEY_READ, TempKey) = ERROR_SUCCESS;
  if Result then
  begin
    if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end; { TBetterRegistry.OpenKeyReadOnly }

end.

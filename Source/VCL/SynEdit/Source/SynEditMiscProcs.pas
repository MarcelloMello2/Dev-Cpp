﻿{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEditMiscProcs.pas, released 2000-04-07.
The Original Code is based on the mwSupportProcs.pas file from the
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

$Id: SynEditMiscProcs.pas,v 1.35.2.8 2009/09/28 17:54:20 maelh Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

unit SynEditMiscProcs;

{$I SynEdit.inc}

interface

uses
  Windows,
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
  Math,
  Classes;

const
  MaxIntArraySize = MaxInt div 16;

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxIntArraySize - 1] of Integer;

function MinMax(x, mi, ma: Integer): Integer;
procedure SwapInt(var l, r: Integer);
function MaxPoint(const P1, P2: TPoint): TPoint;
function MinPoint(const P1, P2: TPoint): TPoint;

function GetIntArray(Count: Cardinal; InitialValue: integer): PIntArray;

procedure InternalFillRect(dc: HDC; const rcPaint: TRect);

// Converting tabs to spaces: To use the function several times it's better
// to use a function pointer that is set to the fastest conversion function.
type
  TConvertTabsProc = function(const Line: string;
    TabWidth: Integer): string;

function GetBestConvertTabsProc(TabWidth: Integer): TConvertTabsProc;
// This is the slowest conversion function which can handle TabWidth <> 2^n.
function ConvertTabs(const Line: string; TabWidth: Integer): string;

type
  TConvertTabsProcEx = function(const Line: string; TabWidth: Integer;
    var HasTabs: Boolean): string;

function GetBestConvertTabsProcEx(TabWidth: Integer): TConvertTabsProcEx;
// This is the slowest conversion function which can handle TabWidth <> 2^n.
function ConvertTabsEx(const Line: string; TabWidth: Integer;
  var HasTabs: Boolean): string;

function GetExpandedLength(const aStr: string; aTabWidth: Integer): Integer;

function CharIndex2CaretPos(Index, TabWidth: Integer;
  const Line: string): Integer;
function CaretPos2CharIndex(Position, TabWidth: Integer; const Line: string;
  var InsideTabChar: Boolean): Integer;

// search for the first char of set AChars in Line, starting at index Start
function StrScanForCharInCategory(const Line: string; Start: Integer;
  IsOfCategory: TCategoryMethod): Integer;
// the same, but searching backwards
function StrRScanForCharInCategory(const Line: string; Start: Integer;
  IsOfCategory: TCategoryMethod): Integer;

function GetEOL(Line: PWideChar): PWideChar;

// Remove all '/' characters from string by changing them into '\.'.
// Change all '\' characters into '\\' to allow for unique decoding.
function EncodeString(s: string): string;

// Decodes string, encoded with EncodeString.
function DecodeString(s: string): string;

type
  THighlighterAttriProc = function (Highlighter: TSynCustomHighlighter;
    Attri: TSynHighlighterAttributes; UniqueAttriName: string;
    Params: array of Pointer): Boolean of object;

// Enums all child highlighters and their attributes of a TSynMultiSyn through a
// callback function.
// This function also handles nested TSynMultiSyns including their MarkerAttri.
function EnumHighlighterAttris(Highlighter: TSynCustomHighlighter;
  SkipDuplicates: Boolean; HighlighterAttriProc: THighlighterAttriProc;
  Params: array of Pointer): Boolean;

{$IFDEF SYN_HEREDOC}
// Calculates Frame Check Sequence (FCS) 16-bit Checksum (as defined in RFC 1171)
function CalcFCS(const ABuf; ABufSize: Cardinal): Word;
{$ENDIF}

procedure SynDrawGradient(const ACanvas: TCanvas; const AStartColor, AEndColor: TColor;
  ASteps: Integer; const ARect: TRect; const AHorizontal: Boolean);

function DeleteTypePrefixAndSynSuffix(S: string): string;

// In Windows Vista or later use the Consolas font
function DefaultFontName: string;

implementation

uses
  SysUtils,
  SynHighlighterMulti;

function MinMax(x, mi, ma: Integer): Integer;
begin
  x := Min(x, ma);
  Result := Max(x, mi);
end;

procedure SwapInt(var l, r: Integer);
var
  tmp: Integer;
begin
  tmp := r;
  r := l;
  l := tmp;
end;

function MaxPoint(const P1, P2: TPoint): TPoint;
begin
  if (P2.y > P1.y) or ((P2.y = P1.y) and (P2.x > P1.x)) then
    Result := P2
  else
    Result := P1;
end;

function MinPoint(const P1, P2: TPoint): TPoint;
begin
  if (P2.y < P1.y) or ((P2.y = P1.y) and (P2.x < P1.x)) then
    Result := P2
  else
    Result := P1;
end;

function GetIntArray(Count: Cardinal; InitialValue: Integer): PIntArray;
var
  p: PInteger;
begin
  Result := AllocMem(Count * SizeOf(Integer));
  if Assigned(Result) and (InitialValue <> 0) then
  begin
    p := PInteger(Result);
    while (Count > 0) do
    begin
      p^ := InitialValue;
      Inc(p);
      Dec(Count);
    end;
  end;
end;

procedure InternalFillRect(dc: HDC; const rcPaint: TRect);
begin
  ExtTextOut(dc, 0, 0, ETO_OPAQUE, @rcPaint, nil, 0, nil);
end;

// Please don't change this function; no stack frame and efficient register use.
function GetHasTabs(pLine: PWideChar; var CharsBefore: Integer): Boolean;
begin
  CharsBefore := 0;
  if Assigned(pLine) then
  begin
    while pLine^ <> #0 do 
    begin
      if pLine^ = #9 then break;
      Inc(CharsBefore);
      Inc(pLine);
    end;
    Result := pLine^ = #9;
  end
  else
    Result := False;
end;


function ConvertTabs1Ex(const Line: string; TabWidth: Integer;
  var HasTabs: Boolean): string;
var
  pDest: PWideChar;
  nBeforeTab: Integer;
begin
  Result := Line;  // increment reference count only
  if GetHasTabs(pointer(Line), nBeforeTab) then
  begin
    HasTabs := True;
    pDest := @Result[nBeforeTab + 1]; // this will make a copy of Line
    // We have at least one tab in the string, and the tab width is 1.
    // pDest points to the first tab char. We overwrite all tabs with spaces.
    repeat
      if (pDest^ = #9) then pDest^ := ' ';
      Inc(pDest);
    until (pDest^ = #0);
  end
  else
    HasTabs := False;
end;

function ConvertTabs1(const Line: string; TabWidth: Integer): string;
var
  HasTabs: Boolean;
begin
  Result := ConvertTabs1Ex(Line, TabWidth, HasTabs);
end;

function ConvertTabs2nEx(const Line: string; TabWidth: Integer;
  var HasTabs: Boolean): string;
var
  i, DestLen, TabCount, TabMask: Integer;
  pSrc, pDest: PWideChar;
begin
  Result := Line;  // increment reference count only
  if GetHasTabs(pointer(Line), DestLen) then
  begin
    HasTabs := True;
    pSrc := @Line[1 + DestLen];
    // We have at least one tab in the string, and the tab width equals 2^n.
    // pSrc points to the first tab char in Line. We get the number of tabs
    // and the length of the expanded string now.
    TabCount := 0;
    TabMask := (TabWidth - 1) xor $7FFFFFFF;
    repeat
      if pSrc^ = #9 then
      begin
        DestLen := (DestLen + TabWidth) and TabMask;
        Inc(TabCount);
      end
      else
        Inc(DestLen);
      Inc(pSrc);
    until (pSrc^ = #0);
    // Set the length of the expanded string.
    SetLength(Result, DestLen);
    DestLen := 0;
    pSrc := PWideChar(Line);
    pDest := PWideChar(Result);
    // We use another TabMask here to get the difference to 2^n.
    TabMask := TabWidth - 1;
    repeat
      if pSrc^ = #9 then
      begin
        i := TabWidth - (DestLen and TabMask);
        Inc(DestLen, i);
        //This is used for both drawing and other stuff and is meant to be #9 and not #32
        repeat
          pDest^ := #9;
          Inc(pDest);
          Dec(i);
        until (i = 0);
        Dec(TabCount);
        if TabCount = 0 then
        begin
          repeat
            Inc(pSrc);
            pDest^ := pSrc^;
            Inc(pDest);
          until (pSrc^ = #0);
          exit;
        end;
      end
      else
      begin
        pDest^ := pSrc^;
        Inc(pDest);
        Inc(DestLen);
      end;
      Inc(pSrc);
    until (pSrc^ = #0);
  end
  else
    HasTabs := False;
end;

function ConvertTabs2n(const Line: string; TabWidth: Integer): string;
var
  HasTabs: Boolean;
begin
  Result := ConvertTabs2nEx(Line, TabWidth, HasTabs);
end;

function ConvertTabsEx(const Line: string; TabWidth: Integer;
  var HasTabs: Boolean): string;
var
  i, DestLen, TabCount: Integer;
  pSrc, pDest: PWideChar;
begin
  Result := Line;  // increment reference count only
  if GetHasTabs(pointer(Line), DestLen) then
  begin
    HasTabs := True;
    pSrc := @Line[1 + DestLen];
    // We have at least one tab in the string, and the tab width is greater
    // than 1. pSrc points to the first tab char in Line. We get the number
    // of tabs and the length of the expanded string now.
    TabCount := 0;
    repeat
      if pSrc^ = #9 then
      begin
        DestLen := DestLen + TabWidth - DestLen mod TabWidth;
        Inc(TabCount);
      end
      else
        Inc(DestLen);
      Inc(pSrc);
    until (pSrc^ = #0);
    // Set the length of the expanded string.
    SetLength(Result, DestLen);
    DestLen := 0;
    pSrc := PWideChar(Line);
    pDest := PWideChar(Result);
    repeat
      if pSrc^ = #9 then
      begin
        i := TabWidth - (DestLen mod TabWidth);
        Inc(DestLen, i);
        repeat
          pDest^ := #9;
          Inc(pDest);
          Dec(i);
        until (i = 0);
        Dec(TabCount);
        if TabCount = 0 then
        begin
          repeat
            Inc(pSrc);
            pDest^ := pSrc^;
            Inc(pDest);
          until (pSrc^ = #0);
          exit;
        end;
      end
      else
      begin
        pDest^ := pSrc^;
        Inc(pDest);
        Inc(DestLen);
      end;
      Inc(pSrc);
    until (pSrc^ = #0);
  end
  else
    HasTabs := False;
end;

function ConvertTabs(const Line: string; TabWidth: Integer): string;
var
  HasTabs: Boolean;
begin
  Result := ConvertTabsEx(Line, TabWidth, HasTabs);
end;

function IsPowerOfTwo(TabWidth: Integer): Boolean;
var
  nW: Integer;
begin
  nW := 2;
  repeat
    if (nW >= TabWidth) then break;
    Inc(nW, nW);
  until (nW >= $10000);  // we don't want 64 kByte spaces...
  Result := (nW = TabWidth);
end;

function GetBestConvertTabsProc(TabWidth: Integer): TConvertTabsProc;
begin
  if (TabWidth < 2) then Result := TConvertTabsProc(@ConvertTabs1)
    else if IsPowerOfTwo(TabWidth) then
      Result := TConvertTabsProc(@ConvertTabs2n)
    else
      Result := TConvertTabsProc(@ConvertTabs);
end;

function GetBestConvertTabsProcEx(TabWidth: Integer): TConvertTabsProcEx;
begin
  if (TabWidth < 2) then Result := ConvertTabs1Ex
    else if IsPowerOfTwo(TabWidth) then
      Result := ConvertTabs2nEx
    else
      Result := ConvertTabsEx;
end;

function GetExpandedLength(const aStr: string; aTabWidth: Integer): Integer;
var
  iRun: PWideChar;
begin
  Result := 0;
  iRun := PWideChar(aStr);
  while iRun^ <> #0 do
  begin
    if iRun^ = #9 then
      Inc(Result, aTabWidth - (Result mod aTabWidth))
    else
      Inc(Result);
    Inc(iRun);
  end;
end;

function CharIndex2CaretPos(Index, TabWidth: Integer;
  const Line: string): Integer;
var
  iChar: Integer;
  pNext: PWideChar;
begin
// possible sanity check here: Index := Max(Index, Length(Line));
  if Index > 1 then
  begin
    if (TabWidth <= 1) or not GetHasTabs(pointer(Line), iChar) then
      Result := Index
    else
    begin
      if iChar + 1 >= Index then
        Result := Index
      else
      begin
        // iChar is number of chars before first #9
        Result := iChar;
        // Index is *not* zero-based
        Inc(iChar);
        Dec(Index, iChar);
        pNext := @Line[iChar];
        while Index > 0 do
        begin
          case pNext^ of
            #0:
              begin
                Inc(Result, Index);
                break;
              end;
            #9:
              begin
                // Result is still zero-based
                Inc(Result, TabWidth);
                Dec(Result, Result mod TabWidth);
              end;
            else
              Inc(Result);
          end;
          Dec(Index);
          Inc(pNext);
        end;
        // done with zero-based computation
        Inc(Result);
      end;
    end;
  end
  else
    Result := 1;
end;

function CaretPos2CharIndex(Position, TabWidth: Integer; const Line: string;
  var InsideTabChar: Boolean): Integer;
var
  iPos: Integer;
  pNext: PWideChar;
begin
  InsideTabChar := False;
  if Position > 1 then
  begin
    if (TabWidth <= 1) or not GetHasTabs(pointer(Line), iPos) then
      Result := Position
    else
    begin
      if iPos + 1 >= Position then
        Result := Position
      else
      begin
        // iPos is number of chars before first #9
        Result := iPos + 1;
        pNext := @Line[Result];
        // for easier computation go zero-based (mod-operation)
        Dec(Position);
        while iPos < Position do
        begin
          case pNext^ of
            #0: break;
            #9: begin
                  Inc(iPos, TabWidth);
                  Dec(iPos, iPos mod TabWidth);
                  if iPos > Position then
                  begin
                    InsideTabChar := True;
                    break;
                  end;
                end;
            else
              Inc(iPos);
          end;
          Inc(Result);
          Inc(pNext);
        end;
      end;
    end;
  end
  else
    Result := Position;
end;

function StrScanForCharInCategory(const Line: string; Start: Integer;
  IsOfCategory: TCategoryMethod): Integer;
var
  p: PWideChar;
begin
  if (Start > 0) and (Start <= Length(Line)) then
  begin
    p := PWideChar(@Line[Start]);
    repeat
      if IsOfCategory(p^) then
      begin
        Result := Start;
        exit;
      end;
      Inc(p);
      Inc(Start);
    until p^ = #0;
  end;
  Result := 0;
end;

function StrRScanForCharInCategory(const Line: string; Start: Integer;
  IsOfCategory: TCategoryMethod): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Start > 0) and (Start <= Length(Line)) then
  begin
    for I := Start downto 1 do
      if IsOfCategory(Line[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;
end;

function GetEOL(Line: PWideChar): PWideChar;
begin
  Result := Line;
  if Assigned(Result) then
    while (Result^ <> #0) and (Result^ <> #10) and (Result^ <> #13) do
      Inc(Result);
end;

{$IFOPT R+}{$DEFINE RestoreRangeChecking}{$ELSE}{$UNDEF RestoreRangeChecking}{$ENDIF}
{$R-}
function EncodeString(s: string): string;
var
  i, j: Integer;
begin
  SetLength(Result, 2 * Length(s)); // worst case
  j := 0;
  for i := 1 to Length(s) do
  begin
    Inc(j);
    if s[i] = '\' then
    begin
      Result[j] := '\';
      Result[j + 1] := '\';
      Inc(j);
    end
    else if s[i] = '/' then
    begin
      Result[j] := '\';
      Result[j + 1] := '.';
      Inc(j);
    end
    else
      Result[j] := s[i];
  end; //for
  SetLength(Result, j);
end; { EncodeString }

function DecodeString(s: string): string;
var
  i, j: Integer;
begin
  SetLength(Result, Length(s)); // worst case
  j := 0;
  i := 1;
  while i <= Length(s) do
  begin
    Inc(j);
    if s[i] = '\' then
    begin
      Inc(i);
      if s[i] = '\' then
        Result[j] := '\'
      else
        Result[j] := '/';
    end
    else
      Result[j] := s[i];
    Inc(i);
  end; //for
  SetLength(Result,j);
end; { DecodeString }
{$IFDEF RestoreRangeChecking}{$R+}{$ENDIF}

function DeleteTypePrefixAndSynSuffix(S: string): string;
begin
  Result := S;
  if CharInSet(Result[1], ['T', 't']) then //ClassName is never empty so no AV possible
    if Pos('tsyn', LowerCase(Result)) = 1 then
      Delete(Result, 1, 4)
    else
      Delete(Result, 1, 1);

  if Copy(LowerCase(Result), Length(Result) - 2, 3) = 'syn' then
    SetLength(Result, Length(Result) - 3);
end;

function GetHighlighterIndex(Highlighter: TSynCustomHighlighter;
  HighlighterList: TList): Integer;
var
  i: Integer;
begin
  Result := 1;
  for i := 0 to HighlighterList.Count - 1 do
    if HighlighterList[i] = Highlighter then
      Exit
    else if Assigned(HighlighterList[i]) and (TObject(HighlighterList[i]).ClassType = Highlighter.ClassType) then
      inc(Result);
end;

function InternalEnumHighlighterAttris(Highlighter: TSynCustomHighlighter;
  SkipDuplicates: Boolean; HighlighterAttriProc: THighlighterAttriProc;
  Params: array of Pointer; HighlighterList: TList): Boolean;
var
  i: Integer;
  UniqueAttriName: string;
begin
  Result := True;

  if (HighlighterList.IndexOf(Highlighter) >= 0) then
  begin
    if SkipDuplicates then Exit;
  end
  else
    HighlighterList.Add(Highlighter);

  if Highlighter is TSynMultiSyn then
    with TSynMultiSyn(Highlighter) do
    begin
      Result := InternalEnumHighlighterAttris(DefaultHighlighter, SkipDuplicates,
        HighlighterAttriProc, Params, HighlighterList);
      if not Result then Exit;

      for i := 0 to Schemes.Count - 1 do
      begin
        UniqueAttriName := Highlighter.ExportName +
          IntToStr(GetHighlighterIndex(Highlighter, HighlighterList)) + '.' +
          Schemes[i].MarkerAttri.Name + IntToStr(i + 1);

        Result := HighlighterAttriProc(Highlighter, Schemes[i].MarkerAttri,
          UniqueAttriName, Params);
        if not Result then Exit;

        Result := InternalEnumHighlighterAttris(Schemes[i].Highlighter,
          SkipDuplicates, HighlighterAttriProc, Params, HighlighterList);
        if not Result then Exit
      end
    end
  else if Assigned(Highlighter) then
    for i := 0 to Highlighter.AttrCount - 1 do
    begin
      UniqueAttriName := Highlighter.ExportName +
        IntToStr(GetHighlighterIndex(Highlighter, HighlighterList)) + '.' +
        Highlighter.Attribute[i].Name;

      Result := HighlighterAttriProc(Highlighter, Highlighter.Attribute[i],
        UniqueAttriName, Params);
      if not Result then Exit
    end
end;

function EnumHighlighterAttris(Highlighter: TSynCustomHighlighter;
  SkipDuplicates: Boolean; HighlighterAttriProc: THighlighterAttriProc;
  Params: array of Pointer): Boolean;
var
  HighlighterList: TList;
begin
  if not Assigned(Highlighter) or not Assigned(HighlighterAttriProc) then
  begin
    Result := False;
    Exit;
  end;

  HighlighterList := TList.Create;
  try
    Result := InternalEnumHighlighterAttris(Highlighter, SkipDuplicates,
      HighlighterAttriProc, Params, HighlighterList)
  finally
    HighlighterList.Free
  end
end;

{$IFDEF SYN_HEREDOC}
// Fast Frame Check Sequence (FCS) Implementation
// Translated from sample code given with RFC 1171 by Marko Njezic

const
  fcstab : array[Byte] of Word = (
    $0000, $1189, $2312, $329b, $4624, $57ad, $6536, $74bf,
    $8c48, $9dc1, $af5a, $bed3, $ca6c, $dbe5, $e97e, $f8f7,
    $1081, $0108, $3393, $221a, $56a5, $472c, $75b7, $643e,
    $9cc9, $8d40, $bfdb, $ae52, $daed, $cb64, $f9ff, $e876,
    $2102, $308b, $0210, $1399, $6726, $76af, $4434, $55bd,
    $ad4a, $bcc3, $8e58, $9fd1, $eb6e, $fae7, $c87c, $d9f5,
    $3183, $200a, $1291, $0318, $77a7, $662e, $54b5, $453c,
    $bdcb, $ac42, $9ed9, $8f50, $fbef, $ea66, $d8fd, $c974,
    $4204, $538d, $6116, $709f, $0420, $15a9, $2732, $36bb,
    $ce4c, $dfc5, $ed5e, $fcd7, $8868, $99e1, $ab7a, $baf3,
    $5285, $430c, $7197, $601e, $14a1, $0528, $37b3, $263a,
    $decd, $cf44, $fddf, $ec56, $98e9, $8960, $bbfb, $aa72,
    $6306, $728f, $4014, $519d, $2522, $34ab, $0630, $17b9,
    $ef4e, $fec7, $cc5c, $ddd5, $a96a, $b8e3, $8a78, $9bf1,
    $7387, $620e, $5095, $411c, $35a3, $242a, $16b1, $0738,
    $ffcf, $ee46, $dcdd, $cd54, $b9eb, $a862, $9af9, $8b70,
    $8408, $9581, $a71a, $b693, $c22c, $d3a5, $e13e, $f0b7,
    $0840, $19c9, $2b52, $3adb, $4e64, $5fed, $6d76, $7cff,
    $9489, $8500, $b79b, $a612, $d2ad, $c324, $f1bf, $e036,
    $18c1, $0948, $3bd3, $2a5a, $5ee5, $4f6c, $7df7, $6c7e,
    $a50a, $b483, $8618, $9791, $e32e, $f2a7, $c03c, $d1b5,
    $2942, $38cb, $0a50, $1bd9, $6f66, $7eef, $4c74, $5dfd,
    $b58b, $a402, $9699, $8710, $f3af, $e226, $d0bd, $c134,
    $39c3, $284a, $1ad1, $0b58, $7fe7, $6e6e, $5cf5, $4d7c,
    $c60c, $d785, $e51e, $f497, $8028, $91a1, $a33a, $b2b3,
    $4a44, $5bcd, $6956, $78df, $0c60, $1de9, $2f72, $3efb,
    $d68d, $c704, $f59f, $e416, $90a9, $8120, $b3bb, $a232,
    $5ac5, $4b4c, $79d7, $685e, $1ce1, $0d68, $3ff3, $2e7a,
    $e70e, $f687, $c41c, $d595, $a12a, $b0a3, $8238, $93b1,
    $6b46, $7acf, $4854, $59dd, $2d62, $3ceb, $0e70, $1ff9,
    $f78f, $e606, $d49d, $c514, $b1ab, $a022, $92b9, $8330,
    $7bc7, $6a4e, $58d5, $495c, $3de3, $2c6a, $1ef1, $0f78
  );

function CalcFCS(const ABuf; ABufSize: Cardinal): Word;
var
  CurFCS: Word;
  P: ^Byte;
begin
  CurFCS := $ffff;
  P := @ABuf;
  while ABufSize <> 0 do
  begin
    CurFCS := (CurFCS shr 8) xor fcstab[(CurFCS xor P^) and $ff];
    Dec(ABufSize);
    Inc(P);
  end;
  Result := CurFCS;
end;
{$ENDIF}

procedure SynDrawGradient(const ACanvas: TCanvas; const AStartColor, AEndColor: TColor;
  ASteps: Integer; const ARect: TRect; const AHorizontal: Boolean);
var
  StartColorR, StartColorG, StartColorB: Byte;
  DiffColorR, DiffColorG, DiffColorB: Integer;
  i, Size: Integer;
  PaintRect: TRect;
begin
  StartColorR := GetRValue(ColorToRGB(AStartColor));
  StartColorG := GetGValue(ColorToRGB(AStartColor));
  StartColorB := GetBValue(ColorToRGB(AStartColor));

  DiffColorR := GetRValue(ColorToRGB(AEndColor)) - StartColorR;
  DiffColorG := GetGValue(ColorToRGB(AEndColor)) - StartColorG;
  DiffColorB := GetBValue(ColorToRGB(AEndColor)) - StartColorB;

  ASteps := MinMax(ASteps, 2, 256);

  if AHorizontal then
  begin
    Size := ARect.Right - ARect.Left;
    PaintRect.Top := ARect.Top;
    PaintRect.Bottom := ARect.Bottom;

    for i := 0 to ASteps - 1 do
    begin
      PaintRect.Left := ARect.Left + MulDiv(i, Size, ASteps);
      PaintRect.Right := ARect.Left + MulDiv(i + 1, Size, ASteps);

      ACanvas.Brush.Color := RGB(StartColorR + MulDiv(i, DiffColorR, ASteps - 1),
                                 StartColorG + MulDiv(i, DiffColorG, ASteps - 1),
                                 StartColorB + MulDiv(i, DiffColorB, ASteps - 1));

      ACanvas.FillRect(PaintRect);
    end;
  end
  else
  begin
    Size := ARect.Bottom - ARect.Top;
    PaintRect.Left := ARect.Left;
    PaintRect.Right := ARect.Right;

    for i := 0 to ASteps - 1 do
    begin
      PaintRect.Top := ARect.Top + MulDiv(i, Size, ASteps);
      PaintRect.Bottom := ARect.Top + MulDiv(i + 1, Size, ASteps);

      ACanvas.Brush.Color := RGB(StartColorR + MulDiv(i, DiffColorR, ASteps - 1),
                                 StartColorG + MulDiv(i, DiffColorG, ASteps - 1),
                                 StartColorB + MulDiv(i, DiffColorB, ASteps - 1));

      ACanvas.FillRect(PaintRect);
    end;
  end;
end;


function DefaultFontName: string;
begin
    if CheckWin32Version(6) then
      Result := 'Consolas'
    else
      Result := 'Courier New';
end;

end.

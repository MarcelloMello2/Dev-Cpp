﻿(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower Abbrevia
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{*********************************************************}
{* ABBREVIA: AbBase.pas                                  *}
{*********************************************************}
{* ABBREVIA: Base component class                        *}
{*********************************************************}

unit AbBase;

{$I AbDefine.inc}

interface

uses
  Classes;

type
  TAbBaseComponent = class(TComponent)
  protected {methods}
    function  GetVersion : string;
    procedure SetVersion(const Value : string);

  protected {properties}
    property Version : string
      read  GetVersion
      write SetVersion
      stored False;
  end;

implementation

uses
  AbConst;

{ -------------------------------------------------------------------------- }
function TAbBaseComponent.GetVersion : string;
begin
  Result := AbVersionS;
end;
{ -------------------------------------------------------------------------- }
procedure TAbBaseComponent.SetVersion(const Value : string);
begin
  {NOP}
end;

end.

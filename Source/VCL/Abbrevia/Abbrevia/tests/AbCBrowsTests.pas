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
 * Robert Love
 *
 * Portions created by the Initial Developer are Copyright (C) 1997-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

unit AbCBrowsTests;

{$I AbDefine.inc}

interface

uses
  AbTestFrameWork, AbCBrows;

type
  TAbCabBrowserTests = class(TAbCompTestCase)
  private
    Component : TAbCabBrowser;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDefaultStreaming;
    procedure TestComponentLinks;
  end;

implementation

uses
  TestFrameWork;

{ TAbCabBrowserTests }

procedure TAbCabBrowserTests.SetUp;
begin
  inherited;
  Component := TAbCabBrowser.Create(nil);
end;

procedure TAbCabBrowserTests.TearDown;
begin
  Component.Free;
  inherited;
end;

procedure TAbCabBrowserTests.TestComponentLinks;
begin
  TestComponentLink(Component, 'ArchiveProgressMeter', TAbTestMeter);
  TestComponentLink(Component, 'ItemProgressMeter', TAbTestMeter);
end;

procedure TAbCabBrowserTests.TestDefaultStreaming;
begin
  inherited TestDefaultStreaming(Component);
end;

initialization

  TestFramework.RegisterTest('Abbrevia.Component Level Test Suite',
    TAbCabBrowserTests.Suite);

end.


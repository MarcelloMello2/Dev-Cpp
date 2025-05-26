object AbColHeadingsEditor: TAbColHeadingsEditor
  Left = 277
  Top = 533
  BorderStyle = bsDialog
  Caption = 'Headings Editor'
  ClientHeight = 92
  ClientWidth = 371
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 273
    Height = 92
    Align = alLeft
    Alignment = taLeftJustify
    BevelInner = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 22
      Width = 42
      Height = 13
      Caption = '&Attribute:'
      FocusControl = Attribute1
    end
    object Label2: TLabel
      Left = 16
      Top = 56
      Width = 43
      Height = 13
      Caption = '&Heading:'
      FocusControl = Heading1
    end
    object Attribute1: TComboBox
      Left = 80
      Top = 18
      Width = 177
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnClick = Attribute1Click
    end
    object Heading1: TEdit
      Left = 80
      Top = 52
      Width = 177
      Height = 21
      TabOrder = 1
      OnExit = Heading1Exit
    end
  end
  object Done1: TBitBtn
    Left = 288
    Top = 34
    Width = 75
    Height = 25
    Caption = '&Done'
    ModalResult = 1
    NumGlyphs = 2
    TabOrder = 1
  end
  object Apply1: TBitBtn
    Left = 288
    Top = 4
    Width = 75
    Height = 25
    Caption = 'Apply'
    Default = True
    NumGlyphs = 2
    TabOrder = 2
    OnClick = Apply1Click
  end
  object Button1: TButton
    Left = 288
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end

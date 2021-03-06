OPTION EXPLICIT
DEFINT A-Z


DECLARE SUB Conf.ConfAssoc ()
DECLARE SUB Conf.ConfMisc ()
DECLARE SUB Conf.ConfTheme ()
DECLARE SUB Conf.LoadDefaultThm ()
DECLARE SUB Conf.LoadTheme (BYVAL ThmFile AS STRING)
DECLARE SUB Conf.Main ()
DECLARE SUB Desk.DrawDesktop ()

'$INCLUDE: 'C:\COSTA\SOURCE\COSTALIB.BI'

DIM SHARED ThemeFile$, ThemeName$, ThemeAuthor$
DIM SHARED ThemeList() AS STRING
DIM SHARED DeskNeedsDraw

Sys.Load

Conf.Main

' =========================================================================
'          NAME: Conf.ConfAssoc()
'    PARAMETERS: None
'       RETURNS: Nothing
'       ASSUMES: Nothing
'   CALLED FROM: CONFIG.BAS
' -------------------------------------------------------------------------
'   DESCRIPTION: UI and logic for file association editor
' =========================================================================
SUB Conf.ConfAssoc ()

    IF NOT File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "AssignFileTypes", "1") = "1" THEN
        IF Sys.MsgBox("File associations disabled", "File associations are currently disabled." + CHR$(13) + "Do you want to enable this feature?", msgQuest) = True THEN
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "AssignFileTypes", "1"
        ELSE
            EXIT SUB
        END IF
    END IF


    DIM winAssoc AS WindowType
    DIM imgIcon AS ImageType
    DIM txtFileType AS TextboxType, txtFileTypeText AS STRING
    DIM txtOpenWith AS TextboxType, txtOpenWithText AS STRING
    DIM btnSave AS ButtonType, btnClose AS ButtonType, btnDisable AS ButtonType
    DIM OldFileType AS STRING, SaveVar
    DIM Key$

    Obj.SetSize winAssoc.Pos, 92, 100, 455, 280
    Obj.SetSize imgIcon.Pos, 105, 138, -1, -1
    Obj.SetSize txtFileType.Pos, 105, 310, 50, -1
    Obj.SetSize txtOpenWith.Pos, 182, 310, 353, -1
    Obj.SetSize btnClose.Pos, 451, 346, 84, 23
    Obj.SetSize btnSave.Pos, 351, 346, 84, 23
    Obj.SetSize btnDisable.Pos, 105, 346, 84, 23

    winAssoc.Caption = "File association editor"
    btnClose.Caption = "Close": btnClose.HotKey = 1
    btnSave.Caption = "Save": btnSave.HotKey = 1
    btnDisable.Caption = "Disable": btnDisable.HotKey = 1

    imgIcon.ImageFile = "UNKNOWN"
    txtFileType.MaxLen = 3

    Obj.DrawWin winAssoc
    Obj.DrawImg imgIcon
    Obj.DrawTxt txtFileType, txtFileTypeText, False
    Obj.DrawTxt txtOpenWith, txtOpenWithText, False
    Obj.DrawBtn btnClose, False
    Obj.DrawBtn btnSave, False
    Obj.DrawBtn btnDisable, False
    
    Font.Print "Edit file associations", 148, winAssoc.Pos.Top + 33, ClrWindowText, 1
    Font.Print "Using this editor you can associate files with programs, meaning", 148, 150, ClrWindowText, 2
    Font.Print "that if you for example run README.TXT, and TXT is associated", 148, 166, ClrWindowText, 2
    Font.Print "with EDIT.COM, EDIT.COM will run and open README.TXT for you.", 105, 182, ClrWindowText, 2
    Font.Print "To associate a filetype with a program, type the filetype below. If a", 105, 214, ClrWindowText, 2
    Font.Print "program is already assigned with this filetype, it will automatically", 105, 230, ClrWindowText, 2
    Font.Print "show up in the ""Open with"" field. To remove an association, leave the", 105, 246, ClrWindowText, 2
    Font.Print """Open with"" field blank.", 105, 262, ClrWindowText, 2

    Font.Print "Filetype", 105, 294, ClrWindowText, 1
    Font.Print "Open with", 182, 294, ClrWindowText, 1
    Mouse.Hide
    LINE (104, 305)-(110, 305), ClrWindowText
    LINE (181, 305)-(188, 305), ClrWindowText
    Mouse.Show

    DO

        Key$ = LCASE$(INKEY$)

        IF Obj.TxtClick(txtFileType) OR Key$ = "f" THEN
            OldFileType = txtFileTypeText
            Obj.EditTxt txtFileType, txtFileTypeText
            IF LEFT$(txtFileTypeText, 1) = "." THEN txtFileTypeText = RIGHT$(txtFileTypeText, LEN(txtFileTypeText) - 1)
            txtFileTypeText = UCASE$(txtFileTypeText)
            Obj.DrawTxt txtFileType, txtFileTypeText, False
            IF txtFileTypeText = "" THEN
                txtOpenWithText = ""
                Obj.DrawTxt txtOpenWith, txtOpenWithText, False
            ELSE
                IF NOT txtFileTypeText = OldFileType THEN
                    txtOpenWithText = UCASE$(File.CfgRead("DATA\CONFIG\FILETYPE.CFG", UCASE$(txtFileTypeText), ""))
                    Obj.DrawTxt txtOpenWith, txtOpenWithText, False
                END IF
            END IF
        END IF

        IF Obj.TxtClick(txtOpenWith) OR Key$ = "o" THEN
            Obj.EditTxt txtOpenWith, txtOpenWithText
            txtOpenWithText = UCASE$(txtOpenWithText)
            Obj.DrawTxt txtOpenWith, txtOpenWithText, False
        END IF

        IF Obj.BtnClick(btnClose) OR Key$ = "c" OR Key$ = CHR$(27) THEN
            EXIT DO
        END IF

        IF Obj.BtnClick(btnSave) OR Key$ = "s" THEN
            IF txtFileTypeText = "" THEN
                SaveVar = Sys.MsgBox("No filetype specified", "You must specify a filetype before pressing" + CHR$(13) + "save.", msgError)
            ELSE
                File.CfgWrite "DATA\CONFIG\FILETYPE.CFG", UCASE$(txtFileTypeText), UCASE$(txtOpenWithText)
                IF txtOpenWithText = "" THEN
                    SaveVar = Sys.MsgBox("Association was removed", "Your file association has been removed and" + CHR$(13) + "will take effect immediately.", msgInfo)
                ELSE
                    SaveVar = Sys.MsgBox("Association was saved", "Your file association has been saved and" + CHR$(13) + "will take effect immediately.", msgInfo)
                END IF
            END IF
        END IF

        IF Obj.BtnClick(btnDisable) OR Key$ = "d" THEN
            IF Sys.MsgBox("Disable file associations", "This will disable file associations in Costa" + CHR$(13) + "and all of its acessories. Are you sure?", msgQuest) = True THEN
                File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "AssignFileTypes", "0"
                EXIT SUB
            END IF
        END IF


    LOOP

END SUB

' =========================================================================
'          NAME: Conf.ConfMisc()
'    PARAMETERS: None
'       RETURNS: Nothing
'       ASSUMES: Nothing
'   CALLED FROM: CONFIG.BAS
' -------------------------------------------------------------------------
'   DESCRIPTION: UI and logic for misc. options editor
' =========================================================================
SUB Conf.ConfMisc ()

    DIM winMisc AS WindowType
    DIM frmDesktop AS FrameType, frmVarious AS FrameType
    DIM btnSave AS ButtonType, btnCancel AS ButtonType
    DIM chkShowLinkDesc AS CheckBoxType, chkShowLinkTarget AS CheckBoxType
    DIM chkLinkMenuOnLeft AS CheckBoxType, chkConfLinkDel AS CheckBoxType
    DIM chkConfExit AS CheckBoxType, chkGreyOutMsgbox AS CheckBoxType
    DIM chkAnimUI AS CheckBoxType, chkDailyTip AS CheckBoxType
    DIM chkUseLastProfile AS CheckBoxType

    DIM ShowLinkDesc, ShowLinkTarget, LinkMenuOnLeft, ConfLinkDel
    DIM AnimUI, ConfExit, GreyOutMsgbox, ShowTargetChk, DailyTip, UseLastProfile
    DIM Key$

    ShowLinkDesc = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ShowLinkDescriptions", "1"))
    ShowLinkTarget = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ShowLinkTargetFiles", "1"))
    LinkMenuOnLeft = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "LinkMenuOnLeftClick", "0"))
    ConfLinkDel = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ConfirmLinkDelete", "1"))
    AnimUI = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "Animations", "1"))
    ConfExit = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "ConfirmExit", "1"))
    GreyOutMsgbox = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "GreyOutOnMsgbox", "0"))
    DailyTip = VAL(File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "TipOfTheDay", "1"))
    UseLastProfile = VAL(File.CfgRead("DATA\CONFIG\COSTA.CFG", "UseLastProfile", "0"))

    IF ShowLinkDesc = 1 THEN ShowLinkDesc = True: ShowTargetChk = True
    IF ShowLinkTarget = 1 THEN ShowLinkTarget = True
    IF LinkMenuOnLeft = 1 THEN LinkMenuOnLeft = True
    IF ConfLinkDel = 1 THEN ConfLinkDel = True
    IF AnimUI = 1 THEN AnimUI = True
    IF ConfExit = 1 THEN ConfExit = True
    IF GreyOutMsgbox = 1 THEN GreyOutMsgbox = True
    IF DailyTip = 1 THEN DailyTip = True
    IF UseLastProfile = 1 THEN UseLastProfile = True


    winMisc.Pos.Width = 390
    winMisc.Pos.Height = 340
    winMisc.Pos.Left = (640 - winMisc.Pos.Width) / 2
    winMisc.Pos.Top = (480 - winMisc.Pos.Height) / 2
    Obj.SetSize frmDesktop.Pos, winMisc.Pos.Left + 12, winMisc.Pos.Top + 34, winMisc.Pos.Width - 24, 118
    Obj.SetSize frmVarious.Pos, winMisc.Pos.Left + 12, frmDesktop.Pos.Top + frmDesktop.Pos.Height + 12, frmDesktop.Pos.Width, 129
    Obj.SetSize chkShowLinkDesc.Pos, frmDesktop.Pos.Left + 12, frmDesktop.Pos.Top + 16, -1, -1
    Obj.SetSize chkShowLinkTarget.Pos, frmDesktop.Pos.Left + 34, frmDesktop.Pos.Top + 38, -1, -1
    Obj.SetSize chkLinkMenuOnLeft.Pos, frmDesktop.Pos.Left + 12, frmDesktop.Pos.Top + 70, -1, -1
    Obj.SetSize chkConfLinkDel.Pos, frmDesktop.Pos.Left + 12, frmDesktop.Pos.Top + 92, -1, -1
    Obj.SetSize chkAnimUI.Pos, frmVarious.Pos.Left + 12, frmVarious.Pos.Top + 16, -1, -1
    Obj.SetSize chkConfExit.Pos, frmVarious.Pos.Left + 12, frmVarious.Pos.Top + 38, -1, -1
    Obj.SetSize chkGreyOutMsgbox.Pos, frmVarious.Pos.Left + 12, frmVarious.Pos.Top + 60, -1, -1
    Obj.SetSize chkDailyTip.Pos, frmVarious.Pos.Left + 12, frmVarious.Pos.Top + 82, -1, -1
    Obj.SetSize chkUseLastProfile.Pos, frmVarious.Pos.Left + 12, frmVarious.Pos.Top + 104, -1, -1


    Obj.SetSize btnCancel.Pos, winMisc.Pos.Left + winMisc.Pos.Width - 104, winMisc.Pos.Top + winMisc.Pos.Height - 34, -1, -1
    Obj.SetSize btnSave.Pos, winMisc.Pos.Left + winMisc.Pos.Width - 208, winMisc.Pos.Top + winMisc.Pos.Height - 34, -1, -1


    winMisc.Caption = "Other settings"
    btnCancel.Caption = "Cancel": btnCancel.HotKey = 1
    btnSave.Caption = "Save": btnSave.HotKey = 1
    chkShowLinkDesc.Checked = ShowLinkDesc
    chkShowLinkTarget.Checked = ShowLinkTarget
    chkLinkMenuOnLeft.Checked = LinkMenuOnLeft
    chkConfLinkDel.Checked = ConfLinkDel
    chkAnimUI.Checked = AnimUI
    chkConfExit.Checked = ConfExit
    chkGreyOutMsgbox.Checked = GreyOutMsgbox
    chkDailyTip.Checked = DailyTip
    chkUseLastProfile.Checked = UseLastProfile


    Obj.DrawWin winMisc
    Obj.DrawFrm frmDesktop, 15, Clr3DShadow
    Obj.DrawFrm frmVarious, 15, Clr3DShadow
    Mouse.Hide
    LINE (frmDesktop.Pos.Left + 7, frmDesktop.Pos.Top)-(frmDesktop.Pos.Left + 64, frmDesktop.Pos.Top + 1), ClrWindow, B
    LINE (frmVarious.Pos.Left + 7, frmVarious.Pos.Top)-(frmVarious.Pos.Left + 116, frmVarious.Pos.Top + 1), ClrWindow, B
    Mouse.Show
    Font.Print "Desktop", frmDesktop.Pos.Left + 10, frmDesktop.Pos.Top - 3, ClrWindowText, 1
    Font.Print "Various settings", frmVarious.Pos.Left + 10, frmVarious.Pos.Top - 3, ClrWindowText, 1
    Obj.DrawChk chkShowLinkDesc
    Obj.DrawChk chkShowLinkTarget
    Obj.DrawChk chkLinkMenuOnLeft
    Obj.DrawChk chkConfLinkDel
    Obj.DrawChk chkAnimUI
    Obj.DrawChk chkConfExit
    Obj.DrawChk chkGreyOutMsgbox
    Obj.DrawChk chkDailyTip
    Obj.DrawChk chkUseLastProfile
    Obj.DrawBtn btnSave, False
    Obj.DrawBtn btnCancel, False


    Font.Print "Show link descriptions", chkShowLinkDesc.Pos.Left + 20, chkShowLinkDesc.Pos.Top + 3, ClrWindowText, 2
    IF ShowTargetChk = True THEN
        Font.Print "Show link targets", chkShowLinkTarget.Pos.Left + 20, chkShowLinkTarget.Pos.Top + 3, ClrWindowText, 2
        Mouse.Hide
        LINE (chkShowLinkTarget.Pos.Left + 81, chkShowLinkTarget.Pos.Top + 14)-(chkShowLinkTarget.Pos.Left + 87, chkShowLinkTarget.Pos.Top + 14), ClrWindowText
        Mouse.Show
    ELSE
        Mouse.Hide
        LINE (chkShowLinkTarget.Pos.Left + 2, chkShowLinkTarget.Pos.Top + 2)-(chkShowLinkTarget.Pos.Left + 12, chkShowLinkTarget.Pos.Top + 12), ClrWindow, BF
        Mouse.Show
        Font.Print "Show link targets", chkShowLinkTarget.Pos.Left + 20, chkShowLinkTarget.Pos.Top + 3, Clr3DShadow, 2
    END IF
    Font.Print "Show link menu on both left and right click", chkLinkMenuOnLeft.Pos.Left + 20, chkLinkMenuOnLeft.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Confirm link removal", chkConfLinkDel.Pos.Left + 20, chkConfLinkDel.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Animate user interface (sliding menus)", chkAnimUI.Pos.Left + 20, chkAnimUI.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Confirm when trying to exit Costa", chkConfExit.Pos.Left + 20, chkConfExit.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Grey out screen while showing a messagebox", chkGreyOutMsgbox.Pos.Left + 20, chkGreyOutMsgbox.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Show start-up ""Tip of the Day"" messages", chkDailyTip.Pos.Left + 20, chkDailyTip.Pos.Top + 3, ClrWindowText, 2
    Font.Print "Use last profile on start-up without asking", chkUseLastProfile.Pos.Left + 20, chkUseLastProfile.Pos.Top + 3, ClrWindowText, 2
    
    Mouse.Hide
    LINE (chkShowLinkDesc.Pos.Left + 81, chkShowLinkDesc.Pos.Top + 14)-(chkShowLinkDesc.Pos.Left + 88, chkShowLinkDesc.Pos.Top + 14), ClrWindowText
    LINE (chkLinkMenuOnLeft.Pos.Left + 81, chkLinkMenuOnLeft.Pos.Top + 14)-(chkLinkMenuOnLeft.Pos.Left + 91, chkLinkMenuOnLeft.Pos.Top + 14), ClrWindowText
    LINE (chkConfLinkDel.Pos.Left + 97, chkConfLinkDel.Pos.Top + 14)-(chkConfLinkDel.Pos.Left + 102, chkConfLinkDel.Pos.Top + 14), ClrWindowText
    LINE (chkConfExit.Pos.Left + 169, chkConfExit.Pos.Top + 14)-(chkConfExit.Pos.Left + 175, chkConfExit.Pos.Top + 14), ClrWindowText
    LINE (chkAnimUI.Pos.Left + 19, chkAnimUI.Pos.Top + 14)-(chkAnimUI.Pos.Left + 27, chkAnimUI.Pos.Top + 14), ClrWindowText
    LINE (chkGreyOutMsgbox.Pos.Left + 19, chkGreyOutMsgbox.Pos.Top + 14)-(chkGreyOutMsgbox.Pos.Left + 26, chkGreyOutMsgbox.Pos.Top + 14), ClrWindowText
    LINE (chkDailyTip.Pos.Left + 41, chkDailyTip.Pos.Top + 14)-(chkDailyTip.Pos.Left + 51, chkDailyTip.Pos.Top + 14), ClrWindowText
    LINE (chkUseLastProfile.Pos.Left + 19, chkUseLastProfile.Pos.Top + 14)-(chkUseLastProfile.Pos.Left + 26, chkUseLastProfile.Pos.Top + 14), ClrWindowText
    Mouse.Show

    DO
        Key$ = LCASE$(INKEY$)
        
        Obj.ChkClick chkShowLinkDesc
        IF NOT ShowTargetChk = chkShowLinkDesc.Checked THEN
            ShowTargetChk = chkShowLinkDesc.Checked
            chkShowLinkDesc.Checked = NOT chkShowLinkDesc.Checked
            Key$ = "d"
        END IF

        IF ShowTargetChk = True THEN Obj.ChkClick chkShowLinkTarget
        Obj.ChkClick chkLinkMenuOnLeft
        Obj.ChkClick chkConfLinkDel
        Obj.ChkClick chkConfExit
        Obj.ChkClick chkGreyOutMsgbox
        Obj.ChkClick chkAnimUI
        Obj.ChkClick chkDailyTip
        Obj.ChkClick chkUseLastProfile

        IF Obj.BtnClick(btnCancel) OR Key$ = "c" OR Key$ = CHR$(27) THEN EXIT SUB

        IF Obj.BtnClick(btnSave) OR Key$ = "s" THEN
            IF chkShowLinkDesc.Checked = True THEN ShowLinkDesc = 1:  ELSE ShowLinkDesc = False
            IF chkShowLinkTarget.Checked = True THEN ShowLinkTarget = 1:  ELSE ShowLinkTarget = False
            IF chkLinkMenuOnLeft.Checked = True THEN LinkMenuOnLeft = 1:  ELSE LinkMenuOnLeft = False
            IF chkConfLinkDel.Checked = True THEN ConfLinkDel = 1:  ELSE ConfLinkDel = False
            IF chkAnimUI.Checked = True THEN AnimUI = 1:  ELSE AnimUI = False
            IF chkConfExit.Checked = True THEN ConfExit = 1:  ELSE ConfExit = False
            IF chkGreyOutMsgbox.Checked = True THEN GreyOutMsgbox = 1:  ELSE GreyOutMsgbox = False
            IF chkDailyTip.Checked = True THEN DailyTip = 1:  ELSE DailyTip = False
            IF chkUseLastProfile.Checked = True THEN UseLastProfile = 1:  ELSE UseLastProfile = False
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ShowLinkDescriptions", LTRIM$(STR$(ShowLinkDesc))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ShowLinkTargetFiles", LTRIM$(STR$(ShowLinkTarget))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "LinkMenuOnLeftClick", LTRIM$(STR$(LinkMenuOnLeft))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\DESKTOP.CFG", "ConfirmLinkDelete", LTRIM$(STR$(ConfLinkDel))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "Animations", LTRIM$(STR$(AnimUI))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "ConfirmExit", LTRIM$(STR$(ConfExit))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "GreyOutOnMsgbox", LTRIM$(STR$(GreyOutMsgbox))
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "TipOfTheDay", LTRIM$(STR$(DailyTip))
            File.CfgWrite "DATA\CONFIG\COSTA.CFG", "UseLastProfile", LTRIM$(STR$(UseLastProfile))
            
            EXIT SUB
        END IF

        IF Key$ = "d" THEN
            chkShowLinkDesc.Checked = NOT chkShowLinkDesc.Checked: Obj.DrawChk chkShowLinkDesc
            DeskNeedsDraw = True
            IF chkShowLinkDesc.Checked = True THEN
                Obj.DrawChk chkShowLinkTarget
                Font.Print "Show link targets", chkShowLinkTarget.Pos.Left + 20, chkShowLinkTarget.Pos.Top + 3, ClrWindowText, 2
                Mouse.Hide
                LINE (chkShowLinkTarget.Pos.Left + 81, chkShowLinkTarget.Pos.Top + 14)-(chkShowLinkTarget.Pos.Left + 87, chkShowLinkTarget.Pos.Top + 14), ClrWindowText
                Mouse.Show
            ELSE
                Font.Print "Show link targets", chkShowLinkTarget.Pos.Left + 20, chkShowLinkTarget.Pos.Top + 3, Clr3DShadow, 2
                Mouse.Hide
                LINE (chkShowLinkTarget.Pos.Left + 2, chkShowLinkTarget.Pos.Top + 2)-(chkShowLinkTarget.Pos.Left + 13, chkShowLinkTarget.Pos.Top + 13), ClrWindow, BF
                LINE (chkShowLinkTarget.Pos.Left + 81, chkShowLinkTarget.Pos.Top + 14)-(chkShowLinkTarget.Pos.Left + 87, chkShowLinkTarget.Pos.Top + 14), ClrWindow
                Mouse.Show
            END IF
        END IF

        IF Key$ = "t" AND chkShowLinkDesc.Checked = True THEN chkShowLinkTarget.Checked = NOT chkShowLinkTarget.Checked: Obj.DrawChk chkShowLinkTarget: DeskNeedsDraw = True
        IF Key$ = "m" THEN chkLinkMenuOnLeft.Checked = NOT chkLinkMenuOnLeft.Checked: Obj.DrawChk chkLinkMenuOnLeft
        IF Key$ = "r" THEN chkConfLinkDel.Checked = NOT chkConfLinkDel.Checked: Obj.DrawChk chkConfLinkDel
        IF Key$ = "a" THEN chkAnimUI.Checked = NOT chkAnimUI.Checked: Obj.DrawChk chkAnimUI
        IF Key$ = "x" THEN chkConfExit.Checked = NOT chkConfExit.Checked: Obj.DrawChk chkConfExit
        IF Key$ = "g" THEN chkGreyOutMsgbox.Checked = NOT chkGreyOutMsgbox.Checked: Obj.DrawChk chkGreyOutMsgbox
        IF Key$ = "w" THEN chkDailyTip.Checked = NOT chkDailyTip.Checked: Obj.DrawChk chkDailyTip
        IF Key$ = "u" THEN chkUseLastProfile.Checked = NOT chkUseLastProfile.Checked: Obj.DrawChk chkUseLastProfile
        


    LOOP

END SUB

' =========================================================================
'          NAME: Conf.ConfTheme()
'    PARAMETERS: None
'       RETURNS: Nothing
'       ASSUMES: Nothing
'   CALLED FROM: CONFIG.BAS
' -------------------------------------------------------------------------
'   DESCRIPTION: UI and logic for theme selector
' =========================================================================
SUB Conf.ConfTheme ()

    DIM winTheme AS WindowType
    DIM frmPreview AS FrameType
    DIM btnBack AS ButtonType, btnNext AS ButtonType
    DIM btnSave AS ButtonType, btnCancel AS ButtonType
    
    winTheme.Pos.Width = 324
    winTheme.Pos.Height = 347
    winTheme.Pos.Left = (640 - winTheme.Pos.Width) / 2
    winTheme.Pos.Top = (480 - winTheme.Pos.Height) / 2
    winTheme.Caption = "Theme selector"
      
    frmPreview.Pos.Left = winTheme.Pos.Left + 12
    frmPreview.Pos.Top = winTheme.Pos.Top + 64
    frmPreview.Pos.Width = 300
    frmPreview.Pos.Height = 240

    Obj.SetSize btnBack.Pos, winTheme.Pos.Left + 12, frmPreview.Pos.Top + frmPreview.Pos.Height + 10, 45, 22
    btnBack.Caption = "<-"

    Obj.SetSize btnSave.Pos, winTheme.Pos.Left + 89, frmPreview.Pos.Top + frmPreview.Pos.Height + 10, 69, 22
    btnSave.Caption = "Select": btnSave.HotKey = 1

    Obj.SetSize btnCancel.Pos, winTheme.Pos.Left + 166, frmPreview.Pos.Top + frmPreview.Pos.Height + 10, 69, 22
    btnCancel.Caption = "Cancel": btnCancel.HotKey = 1

    Obj.SetSize btnNext.Pos, winTheme.Pos.Left + 267, frmPreview.Pos.Top + frmPreview.Pos.Height + 10, 45, 22
    btnNext.Caption = "->"

    Obj.DrawWin winTheme
    Obj.DrawBtn btnBack, False
    Obj.DrawBtn btnSave, False
    Obj.DrawBtn btnCancel, False
    Obj.DrawBtn btnNext, False
    Obj.DrawFrm frmPreview, 15, Clr3DShadow
    Mouse.Hide
    Font.Print "Theme name:", winTheme.Pos.Left + 12, winTheme.Pos.Top + 32, ClrWindowText, 1
    Font.Print "Theme author:", winTheme.Pos.Left + 12, winTheme.Pos.Top + 47, ClrWindowText, 1
    Mouse.Show

    'The rest of the controls are used in the preview
    DIM winPreview AS WindowType
    DIM txtPreview AS TextboxType, txtPreviewText AS STRING
    DIM btnPreview1 AS ButtonType, btnPreview2 AS ButtonType
    DIM imgPreview AS ImageType

    winPreview.Pos.Left = frmPreview.Pos.Left + 20
    winPreview.Pos.Top = frmPreview.Pos.Top + 20
    winPreview.Pos.Width = 260
    winPreview.Pos.Height = 145
    winPreview.Caption = appName

    txtPreview.Pos.Left = winPreview.Pos.Left + 12
    txtPreview.Pos.Top = winPreview.Pos.Top + 74
    txtPreview.Pos.Width = 236
    txtPreview.Pos.Height = 19
    txtPreviewText = "Textbox contents"
    
    Obj.SetSize btnPreview1.Pos, winPreview.Pos.Left + 14, winPreview.Pos.Top + 111, 111, 22
    btnPreview1.Caption = "Button up"

    Obj.SetSize btnPreview2.Pos, winPreview.Pos.Left + 133, winPreview.Pos.Top + 111, 111, 22
    btnPreview2.Caption = "Button down"

    imgPreview.Pos.Left = frmPreview.Pos.Left + 100
    imgPreview.Pos.Top = frmPreview.Pos.Top + 190
    imgPreview.ImageFile = "LOGO"


    'Load theme filenames into array
    DIM TmpName$, TmpCount, ActiveTheme
    REDIM ThemeList(0 TO 0) AS STRING
    TmpName$ = DIR$(Sys.Path + "DATA\THEMES\*.THM")
    TmpCount = 0
    DO WHILE NOT TmpName$ = ""
        TmpName$ = LEFT$(TmpName$, LEN(TmpName$) - 4)
        REDIM PRESERVE ThemeList(0 TO TmpCount) AS STRING
        ThemeList(UBOUND(ThemeList)) = TmpName$
        IF UCASE$(TmpName$) = UCASE$(File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "ThemeFile", "DEFAULT")) THEN ActiveTheme = TmpCount
        TmpName$ = DIR$
        TmpCount = TmpCount + 1
    LOOP

    IF TmpCount = 0 THEN
        TmpCount = Sys.MsgBox("No theme files found.", "Costa could not find any theme files. Make sure that the" + CHR$(13) + "themes are in DATA\THEMES, and try again.", msgError)
        EXIT SUB
    END IF
    
    Conf.LoadTheme ThemeList(ActiveTheme)
                       
    DIM Key$
UpdatePreview:
    Mouse.Hide
    LINE (frmPreview.Pos.Left + 2, frmPreview.Pos.Top + 2)-(frmPreview.Pos.Left + frmPreview.Pos.Width - 2, frmPreview.Pos.Top + frmPreview.Pos.Height - 2), ClrDesktop, BF
    Mouse.Show
    Obj.DrawWin winPreview
    Obj.DrawTxt txtPreview, txtPreviewText, True
    Obj.DrawBtn btnPreview1, False
    Obj.DrawBtn btnPreview2, True
    Obj.DrawImg imgPreview
                                  
    Font.Print "This is a preview of the theme.", winPreview.Pos.Left + 12, winPreview.Pos.Top + 32, ClrWindowText, 1
    Font.Print "This is a preview of the theme.", winPreview.Pos.Left + 12, winPreview.Pos.Top + 48, ClrWindowText, 2
    Font.Print "Preview link", imgPreview.Pos.Left + 38, imgPreview.Pos.Top + 4, ClrDesktopText, 1
    Font.Print "preview.exe", imgPreview.Pos.Left + 38, imgPreview.Pos.Top + 18, ClrDesktopText, 2

    Mouse.Hide
    LINE (winTheme.Pos.Left + 110, winTheme.Pos.Top + 29)-(winTheme.Pos.Left + 312, winTheme.Pos.Top + 59), POINT(164, 150), BF
    Mouse.Show
    Font.Print ThemeName$, winTheme.Pos.Left + 115, winTheme.Pos.Top + 32, POINT(178, 100), 2
    Font.Print ThemeAuthor$, winTheme.Pos.Left + 115, winTheme.Pos.Top + 47, POINT(178, 100), 2
    Conf.LoadTheme ClrThemeFile


    DO
        Key$ = LCASE$(INKEY$)

        IF Obj.BtnClick(btnSave) OR Key$ = "s" OR Key$ = CHR$(13) THEN
            DeskNeedsDraw = True
            File.CfgWrite "DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "ThemeFile", ThemeList(ActiveTheme)
            ClrThemeFile = ThemeList(ActiveTheme)
            EXIT SUB
        END IF

        IF Obj.BtnClick(btnCancel) OR Key$ = "c" OR Key$ = CHR$(27) THEN
            EXIT SUB
        END IF


        IF Obj.BtnClick(btnNext) OR Key$ = CHR$(0) + "m" THEN
            ActiveTheme = ActiveTheme + 1
            IF ActiveTheme > UBOUND(ThemeList) THEN ActiveTheme = 0
            Conf.LoadTheme ThemeList(ActiveTheme)
            GOTO UpdatePreview
        END IF

        IF Obj.BtnClick(btnBack) OR Key$ = CHR$(0) + "k" THEN
            ActiveTheme = ActiveTheme - 1
            IF ActiveTheme < 0 THEN ActiveTheme = UBOUND(ThemeList)
            Conf.LoadTheme ThemeList(ActiveTheme)
            GOTO UpdatePreview
        END IF

    LOOP

END SUB

' =========================================================================
'          NAME: Conf.LoadTheme()
'    PARAMETERS: ThmFile - the filename of the theme to load
'       RETURNS: Nothing
'       ASSUMES: That the specified theme file exists
'   CALLED FROM: CONFIG.BAS
' -------------------------------------------------------------------------
'   DESCRIPTION: Loads a theme into the UI color variables
' =========================================================================
SUB Conf.LoadTheme (BYVAL ThmFile AS STRING)

    IF NOT UCASE$(RIGHT$(ThmFile, 4)) = ".THM" THEN ThmFile = ThmFile + ".THM"
    ThmFile = "DATA\THEMES\" + ThmFile

    ThemeName$ = File.CfgRead(ThmFile, "ThemeName", "Untitled theme")
    ThemeAuthor$ = File.CfgRead(ThmFile, "ThemeAuthor", "Unknown author")

    ClrDesktop = VAL(File.CfgRead(ThmFile, "ClrDesktop", "3"))
    ClrDesktopText = VAL(File.CfgRead(ThmFile, "ClrDesktopText", "0"))
    ClrWindow = VAL(File.CfgRead(ThmFile, "ClrWindow", "7"))
    ClrButton = VAL(File.CfgRead(ThmFile, "ClrButton", "7"))
    ClrTextbox = VAL(File.CfgRead(ThmFile, "ClrTextbox", "15"))
    ClrTextboxText = VAL(File.CfgRead(ThmFile, "ClrTextboxText", "0"))
    ClrWindowText = VAL(File.CfgRead(ThmFile, "ClrWindowText", "0"))
    ClrTitleBar = VAL(File.CfgRead(ThmFile, "ClrTitlebar", "1"))
    ClrTitleBarText = VAL(File.CfgRead(ThmFile, "ClrTitlebarText", "15"))
    Clr3DLight = VAL(File.CfgRead(ThmFile, "Clr3DLight", "7"))
    Clr3DShadow = VAL(File.CfgRead(ThmFile, "Clr3DShadow", "8"))
    ClrSelect = VAL(File.CfgRead(ThmFile, "ClrSelect", "1"))
    ClrSelectText = VAL(File.CfgRead(ThmFile, "ClrSelectText", "1"))

    
END SUB

' =========================================================================
'          NAME: Conf.Main()
'    PARAMETERS: None
'       RETURNS: Nothing
'       ASSUMES: Nothing
'   CALLED FROM: DESKTOP.BAS
' -------------------------------------------------------------------------
'   DESCRIPTION: UI and logic for the main window of the configuration
'                editor.
' =========================================================================
SUB Conf.Main ()

    DIM winConfig AS WindowType
    DIM btnThemes AS ButtonType, btnFileAssoc AS ButtonType, btnMisc AS ButtonType
    DIM imgThemes AS ImageType, imgFileAssoc AS ImageType, imgMisc AS ImageType
    DIM btnClose AS ButtonType

    winConfig.Pos.Width = 410
    winConfig.Pos.Height = 245
    winConfig.Pos.Left = (640 - winConfig.Pos.Width) / 2
    winConfig.Pos.Top = (480 - winConfig.Pos.Height) / 2
    winConfig.Caption = "Configuration"

    Obj.SetSize btnThemes.Pos, winConfig.Pos.Left + 14, winConfig.Pos.Top + 36, 46, 46
    btnThemes.Transparent = True
    imgThemes.Pos.Left = btnThemes.Pos.Left + 7
    imgThemes.Pos.Top = btnThemes.Pos.Top + 7
    imgThemes.ImageFile = "THEMES"

    Obj.SetSize btnFileAssoc.Pos, winConfig.Pos.Left + 14, winConfig.Pos.Top + 96, 46, 46
    btnFileAssoc.Transparent = True
    imgFileAssoc.Pos.Left = btnFileAssoc.Pos.Left + 7
    imgFileAssoc.Pos.Top = btnFileAssoc.Pos.Top + 7
    imgFileAssoc.ImageFile = "UNKNOWN"

    Obj.SetSize btnMisc.Pos, winConfig.Pos.Left + 14, winConfig.Pos.Top + 156, 46, 46
    btnMisc.Transparent = True
    imgMisc.Pos.Left = btnMisc.Pos.Left + 7
    imgMisc.Pos.Top = btnMisc.Pos.Top + 7
    imgMisc.ImageFile = "MISCOPT"

    Obj.SetSize btnClose.Pos, winConfig.Pos.Left + winConfig.Pos.Width - 105, winConfig.Pos.Top + winConfig.Pos.Height - 35, 92, 22
    btnClose.Caption = "Close": btnClose.HotKey = 1

    Obj.DrawWin winConfig
    Obj.DrawBtn btnThemes, False
    Obj.DrawBtn btnFileAssoc, False
    Obj.DrawBtn btnMisc, False
    Obj.DrawImg imgThemes
    Obj.DrawImg imgFileAssoc
    Obj.DrawImg imgMisc
    Obj.DrawBtn btnClose, False

    Font.Print "Theme selector", btnThemes.Pos.Left + 60, btnThemes.Pos.Top, ClrWindowText, 1
    Font.Print "Change the colors of the user interface. Costa comes", btnThemes.Pos.Left + 60, btnThemes.Pos.Top + 15, ClrWindowText, 2
    Font.Print "with a collection of themes for you to choose from.", btnThemes.Pos.Left + 60, btnThemes.Pos.Top + 29, ClrWindowText, 2
    
    Font.Print "File associations", btnFileAssoc.Pos.Left + 60, btnFileAssoc.Pos.Top, ClrWindowText, 1
    Font.Print "Enable or disable file associations, and define which", btnFileAssoc.Pos.Left + 60, btnFileAssoc.Pos.Top + 15, ClrWindowText, 2
    Font.Print "programs should open different file types.", btnFileAssoc.Pos.Left + 60, btnFileAssoc.Pos.Top + 29, ClrWindowText, 2

    Font.Print "Other settings", btnMisc.Pos.Left + 60, btnMisc.Pos.Top, ClrWindowText, 1
    Font.Print "Tweak various aspects of Costa, like how the desktop", btnMisc.Pos.Left + 60, btnMisc.Pos.Top + 15, ClrWindowText, 2
    Font.Print "acts and if certain things require confirmation.", btnMisc.Pos.Left + 60, btnMisc.Pos.Top + 29, ClrWindowText, 2

    Mouse.Hide
    LINE (btnMisc.Pos.Left + 59, btnMisc.Pos.Top + 11)-(btnMisc.Pos.Left + 66, btnMisc.Pos.Top + 11), ClrWindowText
    LINE (btnThemes.Pos.Left + 59, btnThemes.Pos.Top + 11)-(btnThemes.Pos.Left + 66, btnThemes.Pos.Top + 11), ClrWindowText
    LINE (btnFileAssoc.Pos.Left + 59, btnFileAssoc.Pos.Top + 11)-(btnFileAssoc.Pos.Left + 64, btnFileAssoc.Pos.Top + 11), ClrWindowText
    Mouse.Show

    DIM Key$
    DO
        Key$ = LCASE$(INKEY$)

        IF Obj.BtnClick(btnThemes) THEN Key$ = "t"
        IF Obj.BtnClick(btnFileAssoc) THEN Key$ = "f"
        IF Obj.BtnClick(btnMisc) THEN Key$ = "o"
        IF Obj.BtnClick(btnClose) THEN Key$ = "c"

        IF Key$ = CHR$(27) OR Key$ = "c" THEN
            REDIM ThemeList(0) AS STRING
            IF DeskNeedsDraw = False THEN
                Sys.VGALoad "DESKTOP"
            ELSE
                Conf.LoadTheme File.CfgRead("DATA\CONFIG\" + ProfileID + "\PROFILE.CFG", "ThemeFile", "Default")
                Mouse.Hide
                LINE (0, 0)-(639, 479), ClrDesktop, BF
                Mouse.Show
                Desk.DrawDesktop
            END IF
            EXIT SUB
        END IF

        IF Key$ = "t" THEN
            Sys.VGASave "CONF"
            Conf.ConfTheme
            Sys.VGALoad "CONF"
        END IF

        IF Key$ = "f" THEN Sys.VGASave "CONF": Conf.ConfAssoc: Sys.VGALoad "CONF"

        IF Key$ = "o" THEN Sys.VGASave "CONF": Conf.ConfMisc: Sys.VGALoad "CONF"

    LOOP

END SUB


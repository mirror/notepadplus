; this file is part of installer for Notepad++
; Copyright (C)2006 Don HO <don.h@free.fr>
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either
; version 2 of the License, or (at your option) any later version.
;
; Note that the GPL places important restrictions on "derived works", yet
; it does not provide a detailed definition of that term.  To avoid      
; misunderstandings, we consider an application to constitute a          
; "derivative work" for the purpose of this license if it does any of the
; following:                                                             
; 1. Integrates source code from Notepad++.
; 2. Integrates/includes/aggregates Notepad++ into a proprietary executable
;    installer, such as those produced by InstallShield.
; 3. Links to a library or executes a program that does any of the above.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


; NSIS includes
!include "x64.nsh"       ; a few simple macros to handle installations on x64 machines
!include "MUI.nsh"       ; Modern UI
!include "nsDialogs.nsh" ; allows creation of custom pages in the installer
!include "Memento.nsh"   ; remember user selections in the installer across runs


; Define the application name
!define APPNAME "Notepad++"

!define APPVERSION "6.7.5"
!define APPNAMEANDVERSION "${APPNAME} v${APPVERSION}"
!define VERSION_MAJOR 6
!define VERSION_MINOR 75

!define APPWEBSITE "http://notepad-plus-plus.org/"

!define UNINSTALL_REG_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
!define MEMENTO_REGISTRY_ROOT HKLM
!define MEMENTO_REGISTRY_KEY ${UNINSTALL_REG_KEY}

; Main Install settings
Name "${APPNAMEANDVERSION}"
InstallDir "$PROGRAMFILES\${APPNAME}"
InstallDirRegKey HKLM "Software\${APPNAME}" ""
OutFile ".\build\npp.${APPVERSION}.Installer.exe"

; GetWindowsVersion 3.0 (2013-02-07)
;
; Based on Yazno's function, http://yazno.tripod.com/powerpimpit/
; Update by Joost Verburg
; Update (Macro, Define, Windows 7 detection) - John T. Haller of PortableApps.com - 2008-01-07
; Update (Windows 8 detection) - Marek Mizanin (Zanir) - 2013-02-07
;
; Usage: ${GetWindowsVersion} $R0
;
; $R0 contains: 95, 98, ME, NT x.x, 2000, XP, 2003, Vista, 7, 8 or '' (for unknown)
 
Function GetWindowsVersion
 
  Push $R0
  Push $R1
 
  ClearErrors
 
  ReadRegStr $R0 HKLM \
  "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
 
  IfErrors 0 lbl_winnt
 
  ; we are not NT
  ReadRegStr $R0 HKLM \
  "SOFTWARE\Microsoft\Windows\CurrentVersion" VersionNumber
 
  StrCpy $R1 $R0 1
  StrCmp $R1 '4' 0 lbl_error
 
  StrCpy $R1 $R0 3
 
  StrCmp $R1 '4.0' lbl_win32_95
  StrCmp $R1 '4.9' lbl_win32_ME lbl_win32_98
 
  lbl_win32_95:
    StrCpy $R0 '95'
  Goto lbl_done
 
  lbl_win32_98:
    StrCpy $R0 '98'
  Goto lbl_done
 
  lbl_win32_ME:
    StrCpy $R0 'ME'
  Goto lbl_done
 
  lbl_winnt:
 
  StrCpy $R1 $R0 1
 
  StrCmp $R1 '3' lbl_winnt_x
  StrCmp $R1 '4' lbl_winnt_x
 
  StrCpy $R1 $R0 3
 
  StrCmp $R1 '5.0' lbl_winnt_2000
  StrCmp $R1 '5.1' lbl_winnt_XP
  StrCmp $R1 '5.2' lbl_winnt_2003
  StrCmp $R1 '6.0' lbl_winnt_vista
  StrCmp $R1 '6.1' lbl_winnt_7
  StrCmp $R1 '6.2' lbl_winnt_8 lbl_error
 
  lbl_winnt_x:
    StrCpy $R0 "NT $R0" 6
  Goto lbl_done
 
  lbl_winnt_2000:
    Strcpy $R0 '2000'
  Goto lbl_done
 
  lbl_winnt_XP:
    Strcpy $R0 'XP'
  Goto lbl_done
 
  lbl_winnt_2003:
    Strcpy $R0 '2003'
  Goto lbl_done
 
  lbl_winnt_vista:
    Strcpy $R0 'Vista'
  Goto lbl_done
 
  lbl_winnt_7:
    Strcpy $R0 '7'
  Goto lbl_done
 
  lbl_winnt_8:
    Strcpy $R0 '8'
  Goto lbl_done
 
  lbl_error:
    Strcpy $R0 ''
  lbl_done:
 
  Pop $R1
  Exch $R0
 
FunctionEnd
 
!macro GetWindowsVersion OUTPUT_VALUE
	Call GetWindowsVersion
	Pop `${OUTPUT_VALUE}`
!macroend
 
!define GetWindowsVersion '!insertmacro "GetWindowsVersion"'


Function LaunchNpp
  Exec '"$INSTDIR\notepad++.exe" "$INSTDIR\change.log" '
FunctionEnd

; Modern interface settings
!define MUI_ICON ".\images\npp_inst.ico"

!define MUI_WELCOMEFINISHPAGE_BITMAP ".\images\wizard.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH

!define MUI_HEADERIMAGE
;!define MUI_HEADERIMAGE_RIGHT
;!define MUI_HEADERIMAGE_BITMAP ".\images\headerRight.bmp" ; optional
!define MUI_HEADERIMAGE_BITMAP ".\images\headerLeft.bmp" ; optional
!define MUI_ABORTWARNING


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\license.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
page Custom ExtraOptions
!insertmacro MUI_PAGE_INSTFILES


!define MUI_FINISHPAGE_RUN
;!define MUI_FINISHPAGE_RUN_TEXT "Run Npp"
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchNpp"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; TODO for optional arg
;!insertmacro GetParameters

; Set languages (first is default language)
;!insertmacro MUI_LANGUAGE "English"
!define MUI_LANGDLL_ALLLANGUAGES
;Languages

  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Catalan"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "NorwegianNynorsk"
  !insertmacro MUI_LANGUAGE "Belarusian"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Malay"
  !insertmacro MUI_LANGUAGE "Galician"
  !insertmacro MUI_LANGUAGE "Basque"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Afrikaans"
  !insertmacro MUI_LANGUAGE "Uzbek"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Bosnian"
  !insertmacro MUI_LANGUAGE "Mongolian"
  
  ;!insertmacro MUI_LANGUAGE "Estonian"
  ;!insertmacro MUI_LANGUAGE "Breton"
  ;!insertmacro MUI_LANGUAGE "Icelandic"
  ;!insertmacro MUI_LANGUAGE "Kurdish"
  ;!insertmacro MUI_LANGUAGE "Irish"

!insertmacro MUI_RESERVEFILE_LANGDLL

;Installer Functions
Var Dialog
Var NoUserDataCheckboxHandle
Var OldIconCheckboxHandle
Var ShortcutCheckboxHandle
Var PluginLoadFromUserDataCheckboxHandle
Var WinVer

Function ExtraOptions
	nsDialogs::Create 1018
	Pop $Dialog

	${If} $Dialog == error
		Abort
	${EndIf}

	${NSD_CreateCheckbox} 0 0 100% 30u "Don't use %APPDATA%$\nEnable this option to make Notepad++ load/write the configuration files from/to its install directory. Check it if you use Notepad++ in an USB device."
	Pop $NoUserDataCheckboxHandle
	${NSD_OnClick} $NoUserDataCheckboxHandle OnChange_NoUserDataCheckBox
	
	${NSD_CreateCheckbox} 0 50 100% 30u "Allow plugins to be loaded from %APPDATA%\\notepad++\\plugins$\nIt could cause a security issue. Turn it on if you know what you are doing."
	Pop $PluginLoadFromUserDataCheckboxHandle
	${NSD_OnClick} $PluginLoadFromUserDataCheckboxHandle OnChange_PluginLoadFromUserDataCheckBox
	
	${NSD_CreateCheckbox} 0 110 100% 30u "Create Shortcut on Desktop"
	Pop $ShortcutCheckboxHandle
	StrCmp $WinVer "8" 0 +2
	${NSD_Check} $ShortcutCheckboxHandle
	${NSD_OnClick} $ShortcutCheckboxHandle ShortcutOnChange_OldIconCheckBox

	${NSD_CreateCheckbox} 0 170 100% 30u "Use the old, obsolete and monstrous icon$\nI won't blame you if you want to get the old icon back :)"
	Pop $OldIconCheckboxHandle
	${NSD_OnClick} $OldIconCheckboxHandle OnChange_OldIconCheckBox
	
	nsDialogs::Show
FunctionEnd

Var noUserDataChecked
Var allowPluginLoadFromUserDataChecked
Var isOldIconChecked
Var createShortcutChecked

; TODO for optional arg
;Var params

; The definition of "OnChange" event for checkbox
Function OnChange_NoUserDataCheckBox
	${NSD_GetState} $NoUserDataCheckboxHandle $noUserDataChecked
FunctionEnd

Function OnChange_PluginLoadFromUserDataCheckBox
	${NSD_GetState} $PluginLoadFromUserDataCheckboxHandle $allowPluginLoadFromUserDataChecked
FunctionEnd

Function OnChange_OldIconCheckBox
	${NSD_GetState} $OldIconCheckboxHandle $isOldIconChecked
FunctionEnd

Function ShortcutOnChange_OldIconCheckBox
	${NSD_GetState} $ShortcutCheckboxHandle $createShortcutChecked
FunctionEnd


Function .onInit

	;Test if window9x
	${GetWindowsVersion} $WinVer
	
	StrCmp $WinVer "95" 0 +3
		MessageBox MB_OK "This version of Notepad++ does not support your OS.$\nPlease download zipped package of version 5.9 and use ANSI version. You can find v5.9 here:$\nhttp://notepad-plus-plus.org/release/5.9"
		Abort
		
	StrCmp $WinVer "98" 0 +3
		MessageBox MB_OK "This version of Notepad++ does not support your OS.$\nPlease download zipped package of version 5.9 and use ANSI version. You can find v5.9 here:$\nhttp://notepad-plus-plus.org/release/5.9"
		Abort
		
	StrCmp $WinVer "ME" 0 +3
		MessageBox MB_OK "This version of Notepad++ does not support your OS.$\nPlease download zipped package of version 5.9 and use ANSI version. You can find v5.9 here:$\nhttp://notepad-plus-plus.org/release/5.9"
		Abort

  !insertmacro MUI_LANGDLL_DISPLAY
	# the plugins dir is automatically deleted when the installer exits
	;InitPluginsDir
	;File /oname=$PLUGINSDIR\splash.bmp ".\images\splash.bmp"
	#optional
	#File /oname=$PLUGINSDIR\splash.wav "C:\myprog\sound.wav"

	;splash::show 1000 $PLUGINSDIR\splash

	;Pop $0 ; $0 has '1' if the user closed the splash screen early,
			; '0' if everything closed normally, and '-1' if some error occurred.

	${MementoSectionRestore}

FunctionEnd

Function .onInstSuccess
	${MementoSectionSave}
FunctionEnd


LangString langFileName ${LANG_ENGLISH} "english.xml"
LangString langFileName ${LANG_FRENCH} "french.xml"
LangString langFileName ${LANG_TRADCHINESE} "chinese.xml"
LangString langFileName ${LANG_SIMPCHINESE} "chineseSimplified.xml"
LangString langFileName ${LANG_KOREAN} "korean.xml"
LangString langFileName ${LANG_JAPANESE} "japanese.xml"
LangString langFileName ${LANG_GERMAN} "german.xml"
LangString langFileName ${LANG_SPANISH} "spanish.xml"
LangString langFileName ${LANG_ITALIAN} "italian.xml"
LangString langFileName ${LANG_PORTUGUESE} "portuguese.xml"
LangString langFileName ${LANG_PORTUGUESEBR} "brazilian_portuguese.xml"
LangString langFileName ${LANG_DUTCH} "dutch.xml"
LangString langFileName ${LANG_RUSSIAN} "russian.xml"
LangString langFileName ${LANG_POLISH} "polish.xml"
LangString langFileName ${LANG_CATALAN} "catalan.xml"
LangString langFileName ${LANG_CZECH} "czech.xml"
LangString langFileName ${LANG_HUNGARIAN} "hungarian.xml"
LangString langFileName ${LANG_ROMANIAN} "romanian.xml"
LangString langFileName ${LANG_TURKISH} "turkish.xml"
LangString langFileName ${LANG_FARSI} "farsi.xml"
LangString langFileName ${LANG_UKRAINIAN} "ukrainian.xml"
LangString langFileName ${LANG_HEBREW} "hebrew.xml"
LangString langFileName ${LANG_NORWEGIANNYNORSK} "nynorsk.xml"
LangString langFileName ${LANG_NORWEGIAN} "norwegian.xml"
LangString langFileName ${LANG_THAI} "thai.xml"
LangString langFileName ${LANG_ARABIC} "arabic.xml"
LangString langFileName ${LANG_FINNISH} "finnish.xml"
LangString langFileName ${LANG_LITHUANIAN} "lithuanian.xml"
LangString langFileName ${LANG_GREEK} "greek.xml"
LangString langFileName ${LANG_SWEDISH} "swedish.xml"
LangString langFileName ${LANG_GALICIAN} "galician.xml"
LangString langFileName ${LANG_SLOVENIAN} "slovenian.xml"
LangString langFileName ${LANG_SLOVAK} "slovak.xml"
LangString langFileName ${LANG_DANISH} "danish.xml"
LangString langFileName ${LANG_BULGARIAN} "bulgarian.xml"
LangString langFileName ${LANG_INDONESIAN} "indonesian.xml"
LangString langFileName ${LANG_ALBANIAN} "albanian.xml"
LangString langFileName ${LANG_CROATIAN} "croatian.xml"
LangString langFileName ${LANG_BASQUE} "basque.xml"
LangString langFileName ${LANG_BELARUSIAN} "belarusian.xml"
LangString langFileName ${LANG_SERBIAN} "serbian.xml"
LangString langFileName ${LANG_MALAY} "malay.xml"
LangString langFileName ${LANG_LUXEMBOURGISH} "luxembourgish.xml"
LangString langFileName ${LANG_AFRIKAANS} "afrikaans.xml"
LangString langFileName ${LANG_UZBEK} "uzbek.xml"
LangString langFileName ${LANG_MACEDONIAN} "macedonian.xml"
LangString langFileName ${LANG_LATVIAN} "Latvian.xml"
LangString langFileName ${LANG_BOSNIAN} "bosnian.xml"
LangString langFileName ${LANG_MONGOLIAN} "mongolian.xml"


Var UPDATE_PATH

Section -"Notepad++" mainSection

	; Set Section properties
	SetOverwrite on

	StrCpy $UPDATE_PATH $INSTDIR
	
	File /oname=$TEMP\xmlUpdater.exe ".\bin\xmlUpdater.exe"
		
	SetOutPath "$INSTDIR\"

	${If} $noUserDataChecked == ${BST_CHECKED}
		File "..\bin\doLocalConf.xml"
	${ELSE}
		IfFileExists $INSTDIR\doLocalConf.xml 0 +2
		Delete $INSTDIR\doLocalConf.xml
		StrCpy $UPDATE_PATH "$APPDATA\Notepad++"
		CreateDirectory $UPDATE_PATH\plugins\config
	${EndIf}
	
	${If} $allowPluginLoadFromUserDataChecked == ${BST_CHECKED}
		File "..\bin\allowAppDataPlugins.xml"
	${ELSE}
		IfFileExists $INSTDIR\allowAppDataPlugins.xml 0 +2
		Delete $INSTDIR\allowAppDataPlugins.xml
	${EndIf}
	
	
	; TODO for optional arg
	;${GetParameters} $params
	;${GetOptions} $params "/noEasterEggs"  $R0
 
	;IfErrors 0 +2
	;MessageBox MB_OK "Not found /noEasterEggs" IDOK +2
	;MessageBox MB_OK "Found /noEasterEggs"
	
	
	
	SetOutPath "$TEMP\"
	File "langsModel.xml"
	File "configModel.xml"
	File "stylesGlobalModel.xml"
	File "stylesLexerModel.xml"
	File "stylers_remove.xml"

	File "..\bin\langs.model.xml"
	File "..\bin\config.model.xml"
	File "..\bin\stylers.model.xml"

	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\langsModel.xml" "$TEMP\langs.model.xml" "$UPDATE_PATH\langs.xml"'
	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\configModel.xml" "$TEMP\config.model.xml" "$UPDATE_PATH\config.xml"'
	
	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\stylesGlobalModel.xml" "$TEMP\stylers.model.xml" "$UPDATE_PATH\stylers.xml"'
	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\stylesLexerModel.xml" "$TEMP\stylers_remove.xml" "$UPDATE_PATH\stylers.xml"'
	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\stylesLexerModel.xml" "$TEMP\stylers.model.xml" "$UPDATE_PATH\stylers.xml"'
	
	; This line is added due to the bug of xmlUpdater, to be removed in the future
	nsExec::ExecToStack '"$TEMP\xmlUpdater.exe" "$TEMP\stylesLexerModel.xml" "$TEMP\stylers.model.xml" "$UPDATE_PATH\stylers.xml"'
	
	SetOverwrite off
	SetOutPath "$UPDATE_PATH\"
	File "..\bin\contextMenu.xml"
	File "..\bin\functionList.xml"
	
	SetOverwrite on
	SetOutPath "$INSTDIR\"
	File "..\bin\langs.model.xml"
	File "..\bin\config.model.xml"
	File "..\bin\stylers.model.xml"
	File "..\bin\contextMenu.xml"
	File "..\bin\functionList.xml"

	SetOverwrite off
	File "..\bin\shortcuts.xml"
	
	; Set Section Files and Shortcuts
	SetOverwrite on
	File "..\license.txt"
	File "..\bin\SciLexer.dll"
	File "..\bin\change.log"
	File "..\bin\notepad++.exe"
	File "..\bin\readme.txt"

	; Localization
	; Default language English 
	SetOutPath "$INSTDIR\localization\"
	File ".\nativeLang\english.xml"

	; Copy all the language files to the temp directory
	; than make them installed via option
	SetOutPath "$TEMP\nppLocalization\"
	File ".\nativeLang\"

	IfFileExists "$UPDATE_PATH\nativeLang.xml" 0 +2
		Delete "$UPDATE_PATH\nativeLang.xml"
		
	IfFileExists "$INSTDIR\nativeLang.xml" 0 +2
		Delete "$INSTDIR\nativeLang.xml"

	StrCmp $LANGUAGE ${LANG_ENGLISH} +3 0
	CopyFiles "$TEMP\nppLocalization\$(langFileName)" "$UPDATE_PATH\nativeLang.xml"
	CopyFiles "$TEMP\nppLocalization\$(langFileName)" "$INSTDIR\localization\$(langFileName)"

	; remove all the npp shortcuts from current user
	Delete "$DESKTOP\Notepad++.lnk"
	Delete "$SMPROGRAMS\Notepad++\Notepad++.lnk"
	Delete "$SMPROGRAMS\Notepad++\readme.lnk"
	Delete "$SMPROGRAMS\Notepad++\Uninstall.lnk"
	CreateDirectory "$SMPROGRAMS\Notepad++"

	; remove unstable plugins
	CreateDirectory "$INSTDIR\plugins\disabled"
	
	IfFileExists "$INSTDIR\plugins\HexEditorPlugin.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nHexEditorPlugin.dll is about to be deleted." /SD IDOK
		Rename "$INSTDIR\plugins\HexEditorPlugin.dll" "$INSTDIR\plugins\disabled\HexEditorPlugin.dll"
		Delete "$INSTDIR\plugins\HexEditorPlugin.dll"

	IfFileExists "$INSTDIR\plugins\HexEditor.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nHexEditor.dll will be moved to the directory $\"disabled$\"" /SD IDOK 
		Rename "$INSTDIR\plugins\HexEditor.dll" "$INSTDIR\plugins\disabled\HexEditor.dll" 
		Delete "$INSTDIR\plugins\HexEditor.dll"

	IfFileExists "$INSTDIR\plugins\MultiClipboard.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nMultiClipboard.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\MultiClipboard.dll" "$INSTDIR\plugins\disabled\MultiClipboard.dll"
		Delete "$INSTDIR\plugins\MultiClipboard.dll"
		
	Delete "$INSTDIR\plugins\NppDocShare.dll"

	IfFileExists "$INSTDIR\plugins\FunctionList.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nFunctionList.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\FunctionList.dll" "$INSTDIR\plugins\disabled\FunctionList.dll"
		Delete "$INSTDIR\plugins\FunctionList.dll"
	
	IfFileExists "$INSTDIR\plugins\docMonitor.unicode.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\ndocMonitor.unicode.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\docMonitor.unicode.dll" "$INSTDIR\plugins\disabled\docMonitor.unicode.dll"
		Delete "$INSTDIR\plugins\docMonitor.unicode.dll"
		
	IfFileExists "$INSTDIR\plugins\NPPTextFX.ini" 0 +1
		Delete "$INSTDIR\plugins\NPPTextFX.ini"
		 
	IfFileExists "$INSTDIR\plugins\NppAutoIndent.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nNppAutoIndent.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\NppAutoIndent.dll" "$INSTDIR\plugins\disabled\NppAutoIndent.dll"
		Delete "$INSTDIR\plugins\NppAutoIndent.dll"

	IfFileExists "$INSTDIR\plugins\FTP_synchronize.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nFTP_synchronize.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\FTP_synchronize.dll" "$INSTDIR\plugins\disabled\FTP_synchronize.dll"
		Delete "$INSTDIR\plugins\FTP_synchronize.dll"

	IfFileExists "$INSTDIR\plugins\NppPlugin_ChangeMarker.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nNppPlugin_ChangeMarker.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\NppPlugin_ChangeMarker.dll" "$INSTDIR\plugins\disabled\NppPlugin_ChangeMarker.dll"
		Delete "$INSTDIR\plugins\NppPlugin_ChangeMarker.dll"
		
	IfFileExists "$INSTDIR\plugins\QuickText.UNI.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nQuickText.UNI.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\QuickText.UNI.dll" "$INSTDIR\plugins\disabled\QuickText.UNI.dll"
		Delete "$INSTDIR\plugins\QuickText.UNI.dll"

	IfFileExists "$INSTDIR\plugins\AHKExternalLexer.dll" 0 +4
		MessageBox MB_OK "Due to the compability issue,$\nAHKExternalLexer.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\AHKExternalLexer.dll" "$INSTDIR\plugins\disabled\AHKExternalLexer.dll"
		Delete "$INSTDIR\plugins\AHKExternalLexer.dll"

	IfFileExists "$INSTDIR\plugins\NppExternalLexers.dll" 0 +4
		MessageBox MB_OK "Due to the compability issue,$\n\NppExternalLexers.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\NppExternalLexers.dll" "$INSTDIR\plugins\disabled\NppExternalLexers.dll"
		Delete "$INSTDIR\plugins\NppExternalLexers.dll"

	IfFileExists "$INSTDIR\plugins\ExternalLexerKVS.dll" 0 +4
		MessageBox MB_OK "Due to the compability issue,$\n\ExternalLexerKVS.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\ExternalLexerKVS.dll" "$INSTDIR\plugins\disabled\ExternalLexerKVS.dll"
		Delete "$INSTDIR\plugins\ExternalLexerKVS.dll"

	IfFileExists "$INSTDIR\plugins\Oberon2LexerU.dll" 0 +4
		MessageBox MB_OK "Due to the compability issue,$\n\Oberon2LexerU.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\Oberon2LexerU.dll" "$INSTDIR\plugins\disabled\Oberon2LexerU.dll"
		Delete "$INSTDIR\plugins\Oberon2LexerU.dll"


	IfFileExists "$INSTDIR\plugins\NotepadSharp.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\n\NotepadSharp.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\NotepadSharp.dll" "$INSTDIR\plugins\disabled\NotepadSharp.dll"
		Delete "$INSTDIR\plugins\NotepadSharp.dll"
		
	IfFileExists "$INSTDIR\plugins\PreviewHTML.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nPreviewHTML.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\PreviewHTML.dll" "$INSTDIR\plugins\disabled\PreviewHTML.dll"
		Delete "$INSTDIR\plugins\PreviewHTML.dll"
		
	IfFileExists "$INSTDIR\plugins\nppRegEx.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nnppRegEx.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\nppRegEx.dll" "$INSTDIR\plugins\disabled\nppRegEx.dll"
		Delete "$INSTDIR\plugins\nppRegEx.dll"
		
	IfFileExists "$INSTDIR\plugins\AutoSaveU.dll" 0 +4
		MessageBox MB_OK "Due to the stability issue,$\nAutoSaveU.dll will be moved to the directory $\"disabled$\"" /SD IDOK
		Rename "$INSTDIR\plugins\AutoSaveU.dll" "$INSTDIR\plugins\disabled\AutoSaveU.dll"
		Delete "$INSTDIR\plugins\AutoSaveU.dll"
		
    ; Context Menu Management : removing old version of Context Menu module
	IfFileExists "$INSTDIR\nppcm.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\nppcm.dll"'
		Delete "$INSTDIR\nppcm.dll"
        
    IfFileExists "$INSTDIR\NppShell.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell.dll"'
		Delete "$INSTDIR\NppShell.dll"
		
    IfFileExists "$INSTDIR\NppShell_01.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell_01.dll"'
		Delete "$INSTDIR\NppShell_01.dll"
        
    IfFileExists "$INSTDIR\NppShell_02.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell_02.dll"'
		Delete "$INSTDIR\NppShell_02.dll"
		
    IfFileExists "$INSTDIR\NppShell_03.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell_03.dll"'
		Delete "$INSTDIR\NppShell_03.dll"
		
	IfFileExists "$INSTDIR\NppShell_04.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell_04.dll"'
		Delete "$INSTDIR\NppShell_04.dll"
		
	IfFileExists "$INSTDIR\NppShell_05.dll" 0 +3
		Exec 'regsvr32 /u /s "$INSTDIR\NppShell_05.dll"'
		Delete "$INSTDIR\NppShell_05.dll"
		
	; detect the right of 
	UserInfo::GetAccountType
	Pop $1
	StrCmp $1 "Admin" 0 +2
	
	SetShellVarContext all
	; add all the npp shortcuts for all user or current user
	CreateDirectory "$SMPROGRAMS\Notepad++"
	CreateShortCut "$SMPROGRAMS\Notepad++\Notepad++.lnk" "$INSTDIR\notepad++.exe"
	SetShellVarContext current
	
	${If} $createShortcutChecked == ${BST_CHECKED}
		CreateShortCut "$DESKTOP\Notepad++.lnk" "$INSTDIR\notepad++.exe"
	${EndIf}
	
	${If} $isOldIconChecked == ${BST_CHECKED}
		SetOutPath "$TEMP\"
		File "..\misc\vistaIconTool\changeIcon.exe"
		File "..\src\icons\npp.ico"
		nsExec::ExecToStack '"$TEMP\changeIcon.exe" "$TEMP\npp.ico" "$INSTDIR\notepad++.exe" 100 1033'
	${EndIf}
	
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe" "" "$INSTDIR\notepad++.exe"
SectionEnd

${MementoSection} "Context Menu Entry" explorerContextMenu
	SetOverwrite try
	SetOutPath "$INSTDIR\"
	${If} ${RunningX64}
		File /oname=$INSTDIR\NppShell_06.dll "..\bin\NppShell64_06.dll"
	${Else}
		File "..\bin\NppShell_06.dll"
	${EndIf}
	
	Exec 'regsvr32 /s "$INSTDIR\NppShell_06.dll"'
${MementoSectionEnd}

SectionGroup "Auto-completion Files" autoCompletionComponent
	SetOverwrite off
	
	${MementoSection} "C" C
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\c.xml"
	${MementoSectionEnd}
	
	${MementoSection} "C++" C++
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\cpp.xml"
	${MementoSectionEnd}

	${MementoSection} "Java" Java
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\java.xml"
	${MementoSectionEnd}
	
	${MementoSection} "C#" C#
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\cs.xml"
	${MementoSectionEnd}
	
	${MementoSection} "HTML" HTML
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\html.xml"
	${MementoSectionEnd}
	
	${MementoSection} "RC" RC
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\rc.xml"
	${MementoSectionEnd}
	
	${MementoSection} "SQL" SQL
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\sql.xml"
	${MementoSectionEnd}
	
	${MementoSection} "PHP" PHP
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\php.xml"
	${MementoSectionEnd}

	${MementoSection} "CSS" CSS
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\css.xml"
	${MementoSectionEnd}

	${MementoSection} "VB" VB
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\vb.xml"
	${MementoSectionEnd}

	${MementoSection} "Perl" Perl
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\perl.xml"
	${MementoSectionEnd}
	
	${MementoSection} "JavaScript" JavaScript
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\javascript.xml"
	${MementoSectionEnd}

	${MementoSection} "Python" Python
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\python.xml"
	${MementoSectionEnd}
	
	${MementoSection} "ActionScript" ActionScript
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\actionscript.xml"
	${MementoSectionEnd}
	
	${MementoSection} "LISP" LISP
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\lisp.xml"
	${MementoSectionEnd}
	
	${MementoSection} "VHDL" VHDL
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\vhdl.xml"
	${MementoSectionEnd}
	
	${MementoSection} "TeX" TeX
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\tex.xml"
	${MementoSectionEnd}
	
	${MementoSection} "DocBook" DocBook
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\xml.xml"
	${MementoSectionEnd}
	
	${MementoSection} "NSIS" NSIS
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\nsis.xml"
	${MementoSectionEnd}
	
	${MementoSection} "CMAKE" CMAKE
		SetOutPath "$INSTDIR\plugins\APIs"
		File ".\APIs\cmake.xml"
	${MementoSectionEnd}
SectionGroupEnd

SectionGroup "Plugins" Plugins
	SetOverwrite on

	${MementoSection} "Spell-Checker" DSpellCheck
		Delete "$INSTDIR\plugins\DSpellCheck.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\DSpellCheck.dll"
		SetOutPath "$UPDATE_PATH\plugins\Config"
		SetOutPath "$INSTDIR\plugins\Config\Hunspell"
		File "..\bin\plugins\Config\Hunspell\dictionary.lst"
		File "..\bin\plugins\Config\Hunspell\en_GB.aff"
		File "..\bin\plugins\Config\Hunspell\en_GB.dic"
		File "..\bin\plugins\Config\Hunspell\README_en_GB.txt"
		File "..\bin\plugins\Config\Hunspell\en_US.aff"
		File "..\bin\plugins\Config\Hunspell\en_US.dic"
		File "..\bin\plugins\Config\Hunspell\README_en_US.txt"
	${MementoSectionEnd}

	${MementoSection} "Npp FTP" NppFTP
		Delete "$INSTDIR\plugins\NppFTP.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\NppFTP.dll"
		SetOutPath "$INSTDIR\plugins\doc\NppFTP"
		File "..\bin\plugins\doc\NppFTP\license_NppFTP.txt"
		File "..\bin\plugins\doc\NppFTP\license_libssh.txt"
		File "..\bin\plugins\doc\NppFTP\license_OpenSSL.txt"
		File "..\bin\plugins\doc\NppFTP\license_TiXML.txt"
		File "..\bin\plugins\doc\NppFTP\license_ZLIB.txt"
		File "..\bin\plugins\doc\NppFTP\license_UTCP.htm"
		File "..\bin\plugins\doc\NppFTP\Readme.txt"
	${MementoSectionEnd}

	${MementoSection} "NppExport" NppExport
		Delete "$INSTDIR\plugins\NppExport.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\NppExport.dll"
	${MementoSectionEnd}

	${MementoSection} "Plugin Manager" PluginManager
		Delete "$INSTDIR\plugins\PluginManager.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\PluginManager.dll"
		SetOutPath "$INSTDIR\updater"
		File "..\bin\updater\gpup.exe"
	${MementoSectionEnd}
	
	${MementoSection} "Mime Tools" MimeTools
		Delete "$INSTDIR\plugins\mimeTools.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\mimeTools.dll"
	${MementoSectionEnd}
	
	${MementoSection} "Converter" Converter
		Delete "$INSTDIR\plugins\NppConverter.dll"
		SetOutPath "$INSTDIR\plugins"
		File "..\bin\plugins\NppConverter.dll"
	${MementoSectionEnd}
SectionGroupEnd

SectionGroup "Localization" localization
	SetOverwrite on
	${MementoUnselectedSection} "Afrikaans" afrikaans
		CopyFiles "$TEMP\nppLocalization\afrikaans.xml" "$INSTDIR\localization\afrikaans.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Albanian" albanian
		CopyFiles "$TEMP\nppLocalization\albanian.xml" "$INSTDIR\localization\albanian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Arabic" arabic
		CopyFiles "$TEMP\nppLocalization\arabic.xml" "$INSTDIR\localization\arabic.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Aragonese" aragonese
		CopyFiles "$TEMP\nppLocalization\aragonese.xml" "$INSTDIR\localization\aragonese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Aranese" aranese
		CopyFiles "$TEMP\nppLocalization\aranese.xml" "$INSTDIR\localization\aranese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Azerbaijani" azerbaijani
		CopyFiles "$TEMP\nppLocalization\azerbaijani.xml" "$INSTDIR\localization\azerbaijani.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Basque" basque
		CopyFiles "$TEMP\nppLocalization\basque.xml" "$INSTDIR\localization\basque.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Belarusian" belarusian
		CopyFiles "$TEMP\nppLocalization\belarusian.xml" "$INSTDIR\localization\belarusian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Bengali" bengali
		CopyFiles "$TEMP\nppLocalization\bengali.xml" "$INSTDIR\localization\bengali.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Bosnian" bosnian
		CopyFiles "$TEMP\nppLocalization\bosnian.xml" "$INSTDIR\localization\bosnian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Brazilian Portuguese" brazilian_portuguese
		CopyFiles "$TEMP\nppLocalization\brazilian_portuguese.xml" "$INSTDIR\localization\brazilian_portuguese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Bulgarian" bulgarian
		CopyFiles "$TEMP\nppLocalization\bulgarian.xml" "$INSTDIR\localization\bulgarian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Catalan" catalan
		CopyFiles "$TEMP\nppLocalization\catalan.xml" "$INSTDIR\localization\catalan.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Chinese (Traditional)" chineseTraditional
		CopyFiles "$TEMP\nppLocalization\chinese.xml" "$INSTDIR\localization\chinese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Chinese (Simplified)" chineseSimplified
		CopyFiles "$TEMP\nppLocalization\chineseSimplified.xml" "$INSTDIR\localization\chineseSimplified.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Croatian" croatian
		CopyFiles "$TEMP\nppLocalization\croatian.xml" "$INSTDIR\localization\croatian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Czech" czech
		CopyFiles "$TEMP\nppLocalization\czech.xml" "$INSTDIR\localization\czech.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Danish" danish
		CopyFiles "$TEMP\nppLocalization\danish.xml" "$INSTDIR\localization\danish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Dutch" dutch
		CopyFiles "$TEMP\nppLocalization\dutch.xml" "$INSTDIR\localization\dutch.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "English (Customizable)" english_customizable
		CopyFiles "$TEMP\nppLocalization\english_customizable.xml" "$INSTDIR\localization\english_customizable.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Esperanto" esperanto
		CopyFiles "$TEMP\nppLocalization\esperanto.xml" "$INSTDIR\localization\esperanto.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Extremaduran" extremaduran
		CopyFiles "$TEMP\nppLocalization\extremaduran.xml" "$INSTDIR\localization\extremaduran.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Farsi" farsi
		CopyFiles "$TEMP\nppLocalization\farsi.xml" "$INSTDIR\localization\farsi.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Finnish" finnish
		CopyFiles "$TEMP\nppLocalization\finnish.xml" "$INSTDIR\localization\finnish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Friulian" friulian
		CopyFiles "$TEMP\nppLocalization\friulian.xml" "$INSTDIR\localization\friulian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "French" french 
		CopyFiles "$TEMP\nppLocalization\french.xml" "$INSTDIR\localization\french.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Galician" galician
		CopyFiles "$TEMP\nppLocalization\galician.xml" "$INSTDIR\localization\galician.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Georgian" georgian
		CopyFiles "$TEMP\nppLocalization\georgian.xml" "$INSTDIR\localization\georgian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "German" german
		CopyFiles "$TEMP\nppLocalization\german.xml" "$INSTDIR\localization\german.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Greek" greek
		CopyFiles "$TEMP\nppLocalization\greek.xml" "$INSTDIR\localization\greek.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Gujarati" gujarati
		CopyFiles "$TEMP\nppLocalization\gujarati.xml" "$INSTDIR\localization\gujarati.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Hebrew" hebrew
		CopyFiles "$TEMP\nppLocalization\hebrew.xml" "$INSTDIR\localization\hebrew.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Hindi" hindi
		CopyFiles "$TEMP\nppLocalization\hindi.xml" "$INSTDIR\localization\hindi.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Hungarian" hungarian
		CopyFiles "$TEMP\nppLocalization\hungarian.xml" "$INSTDIR\localization\hungarian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Hungarian (ANSI)" hungarianA
		CopyFiles "$TEMP\nppLocalization\hungarianA.xml" "$INSTDIR\localization\hungarianA.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Indonesian" indonesian
		CopyFiles "$TEMP\nppLocalization\indonesian.xml" "$INSTDIR\localization\indonesian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Italian" italian
		CopyFiles "$TEMP\nppLocalization\italian.xml" "$INSTDIR\localization\italian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Japanese" japanese
		CopyFiles "$TEMP\nppLocalization\japanese.xml" "$INSTDIR\localization\japanese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Kazakh" kazakh
		CopyFiles "$TEMP\nppLocalization\kazakh.xml" "$INSTDIR\localization\kazakh.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Korean" korean
		CopyFiles "$TEMP\nppLocalization\korean.xml" "$INSTDIR\localization\korean.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Kyrgyz" kyrgyz
		CopyFiles "$TEMP\nppLocalization\kyrgyz.xml" "$INSTDIR\localization\kyrgyz.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Latvian" latvian
		CopyFiles "$TEMP\nppLocalization\latvian.xml" "$INSTDIR\localization\latvian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Ligurian" ligurian
		CopyFiles "$TEMP\nppLocalization\ligurian.xml" "$INSTDIR\localization\ligurian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Lithuanian" lithuanian
		CopyFiles "$TEMP\nppLocalization\lithuanian.xml" "$INSTDIR\localization\lithuanian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Luxembourgish" luxembourgish
		CopyFiles "$TEMP\nppLocalization\luxembourgish.xml" "$INSTDIR\localization\luxembourgish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Macedonian" macedonian
		CopyFiles "$TEMP\nppLocalization\macedonian.xml" "$INSTDIR\localization\macedonian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Malay" malay
		CopyFiles "$TEMP\nppLocalization\malay.xml" "$INSTDIR\localization\malay.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Marathi" marathi
		CopyFiles "$TEMP\nppLocalization\marathi.xml" "$INSTDIR\localization\marathi.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Mongolian" mongolian
		CopyFiles "$TEMP\nppLocalization\mongolian.xml" "$INSTDIR\localization\mongolian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Norwegian" norwegian
		CopyFiles "$TEMP\nppLocalization\norwegian.xml" "$INSTDIR\localization\norwegian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Nynorsk" nynorsk
		CopyFiles "$TEMP\nppLocalization\nynorsk.xml" "$INSTDIR\localization\nynorsk.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Occitan" occitan
		CopyFiles "$TEMP\nppLocalization\occitan.xml" "$INSTDIR\localization\occitan.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Polish" polish
		CopyFiles "$TEMP\nppLocalization\polish.xml" "$INSTDIR\localization\polish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Portuguese" portuguese
		CopyFiles "$TEMP\nppLocalization\portuguese.xml" "$INSTDIR\localization\portuguese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Kannada" kannada
		CopyFiles "$TEMP\nppLocalization\kannada.xml" "$INSTDIR\localization\kannada.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Romanian" romanian
		CopyFiles "$TEMP\nppLocalization\romanian.xml" "$INSTDIR\localization\romanian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Russian" russian
		CopyFiles "$TEMP\nppLocalization\russian.xml" "$INSTDIR\localization\russian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Samogitian" samogitian
		CopyFiles "$TEMP\nppLocalization\samogitian.xml" "$INSTDIR\localization\samogitian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Sardinian" sardinian
		CopyFiles "$TEMP\nppLocalization\sardinian.xml" "$INSTDIR\localization\sardinian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Serbian" serbian
		CopyFiles "$TEMP\nppLocalization\serbian.xml" "$INSTDIR\localization\serbian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Serbian (Cyrillic)" serbianCyrillic
		CopyFiles "$TEMP\nppLocalization\serbianCyrillic.xml" "$INSTDIR\localization\serbianCyrillic.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Sinhala" sinhala
		CopyFiles "$TEMP\nppLocalization\sinhala.xml" "$INSTDIR\localization\sinhala.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Slovak" slovak
		CopyFiles "$TEMP\nppLocalization\slovak.xml" "$INSTDIR\localization\slovak.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Slovak (ANSI)" slovakA
		CopyFiles "$TEMP\nppLocalization\slovakA.xml" "$INSTDIR\localization\slovakA.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Slovenian" slovenian
		CopyFiles "$TEMP\nppLocalization\slovenian.xml" "$INSTDIR\localization\slovenian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Spanish" spanish
		CopyFiles "$TEMP\nppLocalization\spanish.xml" "$INSTDIR\localization\spanish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Spanish_ar" spanish_ar
		CopyFiles "$TEMP\nppLocalization\spanish_ar.xml" "$INSTDIR\localization\spanish_ar.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Swedish" swedish
		CopyFiles "$TEMP\nppLocalization\swedish.xml" "$INSTDIR\localization\swedish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Tagalog" tagalog
		CopyFiles "$TEMP\nppLocalization\tagalog.xml" "$INSTDIR\localization\tagalog.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Tamil" tamil
		CopyFiles "$TEMP\nppLocalization\tamil.xml" "$INSTDIR\localization\tamil.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Telugu" telugu
		CopyFiles "$TEMP\nppLocalization\telugu.xml" "$INSTDIR\localization\telugu.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Thai" thai
		CopyFiles "$TEMP\nppLocalization\thai.xml" "$INSTDIR\localization\thai.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Turkish" turkish
		CopyFiles "$TEMP\nppLocalization\turkish.xml" "$INSTDIR\localization\turkish.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Ukrainian" ukrainian
		CopyFiles "$TEMP\nppLocalization\ukrainian.xml" "$INSTDIR\localization\ukrainian.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Urdu" urdu
		CopyFiles "$TEMP\nppLocalization\urdu.xml" "$INSTDIR\localization\urdu.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Uyghur" uyghur
		CopyFiles "$TEMP\nppLocalization\uyghur.xml" "$INSTDIR\localization\uyghur.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Uzbek" uzbek
		CopyFiles "$TEMP\nppLocalization\uzbek.xml" "$INSTDIR\localization\uzbek.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Uzbek (Cyrillic)" uzbekCyrillic
		CopyFiles "$TEMP\nppLocalization\uzbekCyrillic.xml" "$INSTDIR\localization\uzbekCyrillic.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Vietnamese" vietnamese
		CopyFiles "$TEMP\nppLocalization\vietnamese.xml" "$INSTDIR\localization\vietnamese.xml"
	${MementoSectionEnd}
	${MementoUnselectedSection} "Welsh" welsh
		CopyFiles "$TEMP\nppLocalization\welsh.xml" "$INSTDIR\localization\welsh.xml"
	${MementoSectionEnd}
SectionGroupEnd

SectionGroup "Themes" Themes
	SetOverwrite off
	${MementoSection} "Black Board" BlackBoard
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Black board.xml"
	${MementoSectionEnd}

	${MementoSection} "Choco" Choco
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Choco.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Hello Kitty" HelloKitty
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Hello Kitty.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Mono Industrial" MonoIndustrial
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Mono Industrial.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Monokai" Monokai
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Monokai.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Obsidian" Obsidian
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\obsidian.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Plastic Code Wrap" PlasticCodeWrap
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Plastic Code Wrap.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Ruby Blue" RubyBlue
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Ruby Blue.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Twilight" Twilight
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Twilight.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Vibrant Ink" VibrantInk
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Vibrant Ink.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Deep Black" DeepBlack
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Deep Black.xml"
	${MementoSectionEnd}
	
	${MementoSection} "vim Dark Blue" vimDarkBlue
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\vim Dark Blue.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Bespin" Bespin
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Bespin.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Zenburn" Zenburn
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Zenburn.xml"
	${MementoSectionEnd}

	${MementoSection} "Solarized" Solarized
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Solarized.xml"
	${MementoSectionEnd}

	${MementoSection} "Solarized Light" Solarized-light
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Solarized-light.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Hot Fudge Sundae" HotFudgeSundae
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\HotFudgeSundae.xml"
	${MementoSectionEnd}
	
	${MementoSection} "khaki" khaki
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\khaki.xml"
	${MementoSectionEnd}

	${MementoSection} "Mossy Lawn" MossyLawn
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\MossyLawn.xml"
	${MementoSectionEnd}
	
	${MementoSection} "Navajo" Navajo
		SetOutPath "$UPDATE_PATH\themes"
		File ".\themes\Navajo.xml"
	${MementoSectionEnd}
SectionGroupEnd

${MementoUnselectedSection} "As default html viewer" htmlViewer
	SetOverwrite on
	SetOutPath "$INSTDIR\"
	File "..\bin\nppIExplorerShell.exe"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Internet Explorer\View Source Editor\Editor Name" "" "$INSTDIR\nppIExplorerShell.exe"
${MementoSectionEnd}

InstType "Minimalist"

${MementoSection} "Auto-Updater" AutoUpdater
	SetOverwrite on
	SetOutPath "$INSTDIR\updater"
	File "..\bin\updater\GUP.exe"
	File "..\bin\updater\libcurl.dll"
	File "..\bin\updater\gup.xml"
	File "..\bin\updater\License.txt"
	File "..\bin\updater\gpl.txt"
	File "..\bin\updater\readme.txt"
${MementoSectionEnd}

${MementoSection} "User Manual" UserManual
	SetOverwrite on
	IfFileExists  "$INSTDIR\NppHelp.chm" 0 +2
		Delete "$INSTDIR\NppHelp.chm"
	SetOutPath "$INSTDIR\user.manual"
	File /r "..\bin\user.manual\"
${MementoSectionEnd}

/*
Section /o "Create Shortcut on Desktop" 

	
SectionEnd


Section /o "Use the old application icon" getOldIcon

SectionEnd
*/

${MementoSectionDone}

;--------------------------------
;Descriptions

  ;Language strings
  
  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    ;!insertmacro MUI_DESCRIPTION_TEXT ${makeLocal} 'Enable this option to make Notepad++ load/write the configuration files from/to its install directory. Check it if you use Notepad++ in an USB device.'
    !insertmacro MUI_DESCRIPTION_TEXT ${explorerContextMenu} 'Explorer context menu entry for Notepad++ : Open whatever you want in Notepad++ from Windows Explorer.'
    !insertmacro MUI_DESCRIPTION_TEXT ${autoCompletionComponent} 'Install the API files you need for the auto-completion feature (Ctrl+Space).'
    !insertmacro MUI_DESCRIPTION_TEXT ${Plugins} 'You may need those plugins to extend the capacity of Notepad++.'
    !insertmacro MUI_DESCRIPTION_TEXT ${Themes} 'The eye-candy to change visual effects. Use Theme selector to switch among them.'
    !insertmacro MUI_DESCRIPTION_TEXT ${htmlViewer} 'Open the html file in Notepad++ while you choose <view source> from IE.'
    !insertmacro MUI_DESCRIPTION_TEXT ${AutoUpdater} 'Keep your Notepad++ update: Check this option to install an update module which searches Notepad++ update on Internet and install it for you.'
    !insertmacro MUI_DESCRIPTION_TEXT ${UserManual} 'Here you can get all the secrets of Notepad++.'
    ;!insertmacro MUI_DESCRIPTION_TEXT ${shortcutOnDesktop} 'Check this option to add Notepad++ shortcut on your desktop.'
    ;!insertmacro MUI_DESCRIPTION_TEXT ${getOldIcon} "I won't blame you if you want to get the old icon back."
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------

Section -FinishSection

	WriteRegStr HKLM "Software\${APPNAME}" "" "$INSTDIR"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "Publisher" "Notepad++ Team"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "VersionMajor" "${VERSION_MAJOR}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "VersionMinor" "${VERSION_MINOR}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "MajorVersion" "${VERSION_MAJOR}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "MinorVersion" "${VERSION_MINOR}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayIcon" "$INSTDIR\notepad++.exe"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "DisplayVersion" "${APPVERSION}"
	WriteRegStr HKLM "${UNINSTALL_REG_KEY}" "URLInfoAbout" "${APPWEBSITE}"
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd


;Uninstall section

SectionGroup un.autoCompletionComponent
	Section un.PHP
		Delete "$INSTDIR\plugins\APIs\php.xml"
	SectionEnd

	Section un.CSS
		Delete "$INSTDIR\plugins\APIs\css.xml"
	SectionEnd	
	
	Section un.HTML
		Delete "$INSTDIR\plugins\APIs\html.xml"
	SectionEnd
	
	Section un.SQL
		Delete "$INSTDIR\plugins\APIs\sql.xml"
	SectionEnd
	
	Section un.RC
		Delete "$INSTDIR\plugins\APIs\rc.xml"
	SectionEnd

	Section un.VB
		Delete "$INSTDIR\plugins\APIs\vb.xml"
	SectionEnd

	Section un.Perl
		Delete "$INSTDIR\plugins\APIs\perl.xml"
	SectionEnd

	Section un.C
		Delete "$INSTDIR\plugins\APIs\c.xml"
	SectionEnd
	
	Section un.C++
		Delete "$INSTDIR\plugins\APIs\cpp.xml"
	SectionEnd
	
	Section un.Java
		Delete "$INSTDIR\plugins\APIs\java.xml"
	SectionEnd
	
	Section un.C#
		Delete "$INSTDIR\plugins\APIs\cs.xml"
	SectionEnd
	
	Section un.JavaScript
		Delete "$INSTDIR\plugins\APIs\javascript.xml"
	SectionEnd

	Section un.Python
		Delete "$INSTDIR\plugins\APIs\python.xml"
	SectionEnd

	Section un.ActionScript
		Delete "$INSTDIR\plugins\APIs\actionscript.xml"
	SectionEnd
	
	Section un.LISP
		Delete "$INSTDIR\plugins\APIs\lisp.xml"
	SectionEnd
	
	Section un.VHDL
		Delete "$INSTDIR\plugins\APIs\vhdl.xml"
	SectionEnd	
	
	Section un.TeX
		Delete "$INSTDIR\plugins\APIs\tex.xml"
	SectionEnd
	
	Section un.DocBook
		Delete "$INSTDIR\plugins\APIs\xml.xml"
	SectionEnd
	
	Section un.NSIS
		Delete "$INSTDIR\plugins\APIs\nsis.xml"
	SectionEnd
	
	Section un.AWK
		Delete "$INSTDIR\plugins\APIs\awk.xml"
	SectionEnd
	
	Section un.CMAKE
		Delete "$INSTDIR\plugins\APIs\cmake.xml"
	SectionEnd	
SectionGroupEnd

SectionGroup un.Plugins
	Section un.NPPTextFX
		Delete "$INSTDIR\plugins\NPPTextFX.dll"
		Delete "$INSTDIR\plugins\NPPTextFX.ini"
		Delete "$APPDATA\Notepad++\NPPTextFX.ini"
		Delete "$INSTDIR\plugins\doc\NPPTextFXdemo.TXT"
		Delete "$INSTDIR\plugins\Config\tidy\AsciiToEBCDIC.bin"
		Delete "$INSTDIR\plugins\Config\tidy\libTidy.dll"
		Delete "$INSTDIR\plugins\Config\tidy\TIDYCFG.INI"
		Delete "$INSTDIR\plugins\Config\tidy\W3C-CSSValidator.htm"
		Delete "$INSTDIR\plugins\Config\tidy\W3C-HTMLValidator.htm"
		RMDir "$INSTDIR\plugins\tidy\"
  SectionEnd

	Section un.NppNetNote
		Delete "$INSTDIR\plugins\NppNetNote.dll"
		Delete "$INSTDIR\plugins\Config\NppNetNote.ini"
	SectionEnd

	Section un.NppAutoIndent
		Delete "$INSTDIR\plugins\NppAutoIndent.dll"
		Delete "$INSTDIR\plugins\Config\NppAutoIndent.ini"
	SectionEnd

	Section un.MIMETools
		Delete "$INSTDIR\plugins\NppTools.dll"
		Delete "$INSTDIR\plugins\mimeTools.dll"
	SectionEnd

	Section un.FTP_synchronize
		Delete "$INSTDIR\plugins\FTP_synchronize.dll"
		Delete "$INSTDIR\plugins\Config\FTP_synchronize.ini"
		Delete "$INSTDIR\plugins\doc\FTP_synchonize.ReadMe.txt"
	SectionEnd

	Section un.NppFTP
		Delete "$INSTDIR\plugins\NppFTP.dll"
		
		Delete "$INSTDIR\plugins\doc\NppFTP\license_NppFTP.txt"
		Delete "$INSTDIR\plugins\doc\NppFTP\license_libssh.txt"
		Delete "$INSTDIR\plugins\doc\NppFTP\license_OpenSSL.txt"
		Delete "$INSTDIR\plugins\doc\NppFTP\license_TiXML.txt"
		Delete "$INSTDIR\plugins\doc\NppFTP\license_ZLIB.txt"
		Delete "$INSTDIR\plugins\doc\NppFTP\license_UTCP.htm"
		Delete "$INSTDIR\plugins\doc\NppFTP\Readme.txt"
		
	SectionEnd
	
	Section un.NppExport
		Delete "$INSTDIR\plugins\NppExport.dll"
	SectionEnd
	
	Section un.SelectNLaunch
		Delete "$INSTDIR\plugins\SelectNLaunch.dll"
	SectionEnd
	
	Section un.DocMonitor
		Delete "$INSTDIR\plugins\docMonitor.dll"
		Delete "$INSTDIR\plugins\Config\docMonitor.ini"
	SectionEnd	
	
	
	Section un.LightExplorer
		Delete "$INSTDIR\plugins\LightExplorer.dll"
		Delete "$INSTDIR\lightExplorer.ini"
	SectionEnd
	Section un.HexEditor
		Delete "$INSTDIR\plugins\HexEditor.dll"
	SectionEnd
	Section un.ConvertExt
		Delete "$INSTDIR\plugins\ConvertExt.dll"
		Delete "$APPDATA\Notepad++\ConvertExt.ini"
		Delete "$APPDATA\Notepad++\ConvertExt.enc"
		Delete "$APPDATA\Notepad++\ConvertExt.lng"
		Delete "$INSTDIR\ConvertExt.ini"
		Delete "$INSTDIR\ConvertExt.enc"
		Delete "$INSTDIR\ConvertExt.lng"
	SectionEnd
	Section un.SpellChecker
		Delete "$INSTDIR\plugins\SpellChecker.dll"
	SectionEnd
	Section un.DSpellCheck
		Delete "$INSTDIR\plugins\DSpellCheck.dll"
		Delete "$UPDATE_PATH\plugins\Config\DSpellCheck.ini"
		Delete "$INSTDIR\plugins\Config\Hunspell\dictionary.lst"
		Delete "$INSTDIR\plugins\Config\Hunspell\en_GB.aff"
		Delete "$INSTDIR\plugins\Config\Hunspell\en_GB.dic"
		Delete "$INSTDIR\plugins\Config\Hunspell\README_en_GB.txt"
		Delete "$INSTDIR\plugins\Config\Hunspell\en_US.aff"
		Delete "$INSTDIR\plugins\Config\Hunspell\en_US.dic"
		Delete "$INSTDIR\plugins\Config\Hunspell\README_en_US.txt"
	SectionEnd	
	Section un.NppExec
		Delete "$INSTDIR\plugins\NppExec.dll"
		Delete "$INSTDIR\plugins\doc\NppExec.txt"
		Delete "$INSTDIR\plugins\doc\NppExec_TechInfo.txt"
		Delete "$INSTDIR\plugins\Config\NppExec.ini"
		Delete "$INSTDIR\plugins\Config\NppExec_Manual.chm"
		Delete "$INSTDIR\plugins\Config\NppExec.ini"
		RMDir "$INSTDIR\plugins\doc\"
	SectionEnd
	Section un.QuickText
		Delete "$INSTDIR\plugins\QuickText.dll"
		Delete "$INSTDIR\QuickText.ini"
		Delete "$INSTDIR\plugins\doc\quickText_README.txt"
	SectionEnd
	Section un.ComparePlugin
		Delete "$INSTDIR\plugins\ComparePlugin.dll"
	SectionEnd
	Section un.Converter
		Delete "$INSTDIR\plugins\NppConverter.dll"
	SectionEnd
	Section un.MimeTools
		Delete "$INSTDIR\plugins\mimeTools.dll"
	SectionEnd
	Section un.PluginManager
		Delete "$INSTDIR\plugins\PluginManager.dll"
		Delete "$INSTDIR\updater\gpup.exe"
		RMDir "$INSTDIR\updater\"
	SectionEnd	
	Section un.ChangeMarkers
		Delete "$INSTDIR\plugins\NppPlugin_ChangeMarker.dll"
	SectionEnd	
SectionGroupEnd

SectionGroup un.Themes
	Section un.BlackBoard
		Delete "$UPDATE_PATH\themes\Black board.xml"
	SectionEnd

	Section un.Choco
		Delete "$UPDATE_PATH\themes\Choco.xml"
	SectionEnd
	
	Section un.HelloKitty
		Delete "$UPDATE_PATH\themes\Hello Kitty.xml"
	SectionEnd
	
	Section un.MonoIndustrial
		Delete "$UPDATE_PATH\themes\Mono Industrial.xml"
	SectionEnd
	
	Section un.Monokai
		Delete "$UPDATE_PATH\themes\Monokai.xml"
	SectionEnd
	
	Section un.Obsidian
		Delete "$UPDATE_PATH\themes/obsidian.xml"
	SectionEnd
	
	Section un.PlasticCodeWrap
		Delete "$UPDATE_PATH\themes\Plastic Code Wrap.xml"
	SectionEnd
	
	Section un.RubyBlue
		Delete "$UPDATE_PATH\themes\Ruby Blue.xml"
	SectionEnd
	
	Section un.Twilight
		Delete "$UPDATE_PATH\themes\Twilight.xml"
	SectionEnd
	
	Section un.VibrantInk
		Delete "$UPDATE_PATH\themes\Vibrant Ink.xml"
	SectionEnd

	Section un.DeepBlack
		Delete "$UPDATE_PATH\themes\Deep Black.xml"
	SectionEnd
	
	Section un.vimDarkBlue
		Delete "$UPDATE_PATH\themes\vim Dark Blue.xml"
	SectionEnd
	
	Section un.Bespin
		Delete "$UPDATE_PATH\themes\Bespin.xml"
	SectionEnd
	
	Section un.Zenburn
		Delete "$UPDATE_PATH\themes\Zenburn.xml"
	SectionEnd

	Section un.Solarized
		Delete "$UPDATE_PATH\themes\Solarized.xml"
	SectionEnd

	Section un.Solarized-light
		Delete "$UPDATE_PATH\themes\Solarized-light.xml"
	SectionEnd
	
	Section un.HotFudgeSundae
		Delete "$UPDATE_PATH\themes\HotFudgeSundae.xml"
	SectionEnd

	Section un.khaki
		Delete "$UPDATE_PATH\themes\khaki.xml"
	SectionEnd
	
	Section un.MossyLawn
		Delete "$UPDATE_PATH\themes\MossyLawn.xml"
	SectionEnd

	Section un.Navajo
		Delete "$UPDATE_PATH\themes\Navajo.xml"
	SectionEnd
	
SectionGroupEnd

SectionGroup un.localization
	SetOverwrite on
	Section un.afrikaans
		Delete "$INSTDIR\localization\afrikaans.xml"
	SectionEnd
	Section un.albanian
		Delete "$INSTDIR\localization\albanian.xml"
	SectionEnd
	Section un.arabic
		Delete "$INSTDIR\localization\arabic.xml"
	SectionEnd
	Section un.aragonese
		Delete "$INSTDIR\localization\aragonese.xml"
	SectionEnd
	Section un.aranese
		Delete "$INSTDIR\localization\aranese.xml"
	SectionEnd
	Section un.azerbaijani
		Delete "$INSTDIR\localization\azerbaijani.xml"
	SectionEnd
	Section un.basque
		Delete "$INSTDIR\localization\basque.xml"
	SectionEnd
	Section un.belarusian
		Delete "$INSTDIR\localization\belarusian.xml"
	SectionEnd
	Section un.bengali
		Delete "$INSTDIR\localization\bengali.xml"
	SectionEnd
	Section un.bosnian
		Delete "$INSTDIR\localization\bosnian.xml"
	SectionEnd
	Section un.brazilian_portuguese
		Delete "$INSTDIR\localization\brazilian_portuguese.xml"
	SectionEnd
	Section un.bulgarian
		Delete "$INSTDIR\localization\bulgarian.xml"
	SectionEnd
	Section un.catalan
		Delete "$INSTDIR\localization\catalan.xml"
	SectionEnd
	Section un.chineseTraditional
		Delete "$INSTDIR\localization\chinese.xml"
	SectionEnd
	Section un.chineseSimplified
		Delete "$INSTDIR\localization\chineseSimplified.xml"
	SectionEnd
	Section un.croatian
		Delete "$INSTDIR\localization\croatian.xml"
	SectionEnd
	Section un.czech
		Delete "$INSTDIR\localization\czech.xml"
	SectionEnd
	Section un.danish
		Delete "$INSTDIR\localization\danish.xml"
	SectionEnd
	Section un.dutch
		Delete "$INSTDIR\localization\dutch.xml"
	SectionEnd
	Section un.english_customizable
		Delete "$INSTDIR\localization\english_customizable.xml"
	SectionEnd
	Section un.esperanto
		Delete "$INSTDIR\localization\esperanto.xml"
	SectionEnd
	Section un.extremaduran
		Delete "$INSTDIR\localization\extremaduran.xml"
	SectionEnd
	Section un.farsi
		Delete "$INSTDIR\localization\farsi.xml"
	SectionEnd
	Section un.finnish
		Delete "$INSTDIR\localization\finnish.xml"
	SectionEnd
	Section un.friulian
		Delete "$INSTDIR\localization\friulian.xml"
	SectionEnd
	Section un.french 
		Delete "$INSTDIR\localization\french.xml"
	SectionEnd
	Section un.galician
		Delete "$INSTDIR\localization\galician.xml"
	SectionEnd
	Section un.georgian
		Delete "$INSTDIR\localization\georgian.xml"
	SectionEnd
	Section un.german
		Delete "$INSTDIR\localization\german.xml"
	SectionEnd
	Section un.greek
		Delete "$INSTDIR\localization\greek.xml"
	SectionEnd
	Section un.gujarati
		Delete "$INSTDIR\localization\gujarati.xml"
	SectionEnd
	Section un.hebrew
		Delete "$INSTDIR\localization\hebrew.xml"
	SectionEnd
		Section un.hindi
		Delete "$INSTDIR\localization\hindi.xml"
	SectionEnd
	Section un.hungarian
		Delete "$INSTDIR\localization\hungarian.xml"
	SectionEnd
	Section un.hungarianA
		Delete "$INSTDIR\localization\hungarianA.xml"
	SectionEnd
	Section un.indonesian
		Delete "$INSTDIR\localization\indonesian.xml"
	SectionEnd
	Section un.italian
		Delete "$INSTDIR\localization\italian.xml"
	SectionEnd
	Section un.japanese
		Delete "$INSTDIR\localization\japanese.xml"
	SectionEnd
	Section un.kazakh
		Delete "$INSTDIR\localization\kazakh.xml"
	SectionEnd
	Section un.korean
		Delete "$INSTDIR\localization\korean.xml"
	SectionEnd
	Section un.kyrgyz
		Delete "$INSTDIR\localization\kyrgyz.xml"
	SectionEnd
	Section un.latvian
		Delete "$INSTDIR\localization\latvian.xml"
	SectionEnd
	Section un.ligurian
		Delete "$INSTDIR\localization\ligurian.xml"
	SectionEnd
	Section un.lithuanian
		Delete "$INSTDIR\localization\lithuanian.xml"
	SectionEnd
	Section un.luxembourgish
		Delete "$INSTDIR\localization\luxembourgish.xml"
	SectionEnd
	Section un.macedonian
		Delete "$INSTDIR\localization\macedonian.xml"
	SectionEnd
	Section un.malay
		Delete "$INSTDIR\localization\malay.xml"
	SectionEnd
	Section un.marathi
		Delete "$INSTDIR\localization\marathi.xml"
	SectionEnd
	Section un.mongolian
		Delete "$INSTDIR\localization\mongolian.xml"
	SectionEnd
	Section un.norwegian
		Delete "$INSTDIR\localization\norwegian.xml"
	SectionEnd
	Section un.nynorsk
		Delete "$INSTDIR\localization\nynorsk.xml"
	SectionEnd
	Section un.occitan
		Delete "$INSTDIR\localization\occitan.xml"
	SectionEnd
	Section un.polish
		Delete "$INSTDIR\localization\polish.xml"
	SectionEnd
	Section un.kannada
		Delete "$INSTDIR\localization\kannada.xml"
	SectionEnd
	Section un.portuguese
		Delete "$INSTDIR\localization\portuguese.xml"
	SectionEnd
	Section un.romanian
		Delete "$INSTDIR\localization\romanian.xml"
	SectionEnd
	Section un.russian
		Delete "$INSTDIR\localization\russian.xml"
	SectionEnd
	Section un.samogitian
		Delete "$INSTDIR\localization\samogitian.xml"
	SectionEnd
	Section un.sardinian
		Delete "$INSTDIR\localization\sardinian.xml"
	SectionEnd
	Section un.serbian
		Delete "$INSTDIR\localization\serbian.xml"
	SectionEnd
	Section un.serbianCyrillic
		Delete "$INSTDIR\localization\serbianCyrillic.xml"
	SectionEnd
	Section un.sinhala
		Delete "$INSTDIR\localization\sinhala.xml"
	SectionEnd
	Section un.slovak
		Delete "$INSTDIR\localization\slovak.xml"
	SectionEnd
	Section un.slovakA
		Delete "$INSTDIR\localization\slovakA.xml"
	SectionEnd
	Section un.slovenian
		Delete "$INSTDIR\localization\slovenian.xml"
	SectionEnd
	Section un.spanish
		Delete "$INSTDIR\localization\spanish.xml"
	SectionEnd
	Section un.spanish_ar
		Delete "$INSTDIR\localization\spanish_ar.xml"
	SectionEnd
	Section un.swedish
		Delete "$INSTDIR\localization\swedish.xml"
	SectionEnd
	Section un.tagalog
		Delete "$INSTDIR\localization\tagalog.xml"
	SectionEnd
	Section un.tamil
		Delete "$INSTDIR\localization\tamil.xml"
	SectionEnd
	Section un.telugu
		Delete "$INSTDIR\localization\telugu.xml"
	SectionEnd
	Section un.thai
		Delete "$INSTDIR\localization\thai.xml"
	SectionEnd
	Section un.turkish
		Delete "$INSTDIR\localization\turkish.xml"
	SectionEnd
	Section un.ukrainian
		Delete "$INSTDIR\localization\ukrainian.xml"
	SectionEnd
	Section un.urdu
		Delete "$INSTDIR\localization\urdu.xml"
	SectionEnd
	Section un.uyghur
		Delete "$INSTDIR\localization\uyghur.xml"
	SectionEnd
	Section un.uzbek
		Delete "$INSTDIR\localization\uzbek.xml"
	SectionEnd
	Section un.uzbekCyrillic
		Delete "$INSTDIR\localization\uzbekCyrillic.xml"
	SectionEnd
	Section un.vietnamese
		Delete "$INSTDIR\localization\vietnamese.xml"
	SectionEnd
	Section un.welsh
		Delete "$INSTDIR\localization\welsh.xml"
	SectionEnd
SectionGroupEnd


Section un.htmlViewer
	DeleteRegKey HKLM "SOFTWARE\Microsoft\Internet Explorer\View Source Editor"
	Delete "$INSTDIR\nppIExplorerShell.exe"
SectionEnd

Section un.AutoUpdater
	Delete "$INSTDIR\updater\GUP.exe"
	Delete "$INSTDIR\updater\libcurl.dll"
	Delete "$INSTDIR\updater\gup.xml"
	Delete "$INSTDIR\updater\License.txt"
	Delete "$INSTDIR\updater\gpl.txt"
	Delete "$INSTDIR\updater\readme.txt"
	Delete "$INSTDIR\updater\getDownLoadUrl.php"
	RMDir "$INSTDIR\updater\"
SectionEnd  

Section un.explorerContextMenu
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_01.dll"'
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_02.dll"'
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_03.dll"'
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_04.dll"'
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_05.dll"'
	Exec 'regsvr32 /u /s "$INSTDIR\NppShell_06.dll"'
	Delete "$INSTDIR\NppShell_01.dll"
	Delete "$INSTDIR\NppShell_02.dll"
	Delete "$INSTDIR\NppShell_03.dll"
	Delete "$INSTDIR\NppShell_04.dll"
	Delete "$INSTDIR\NppShell_05.dll"
	Delete "$INSTDIR\NppShell_06.dll"
SectionEnd

Section un.UnregisterFileExt
	; Remove references to "Notepad++_file"
	IntOp $1 0 + 0	; subkey index
	StrCpy $2 ""	; subkey name
Enum_HKCR_Loop:
	EnumRegKey $2 HKCR "" $1
	StrCmp $2 "" Enum_HKCR_Done
	ReadRegStr $0 HKCR $2 ""	; Read the default value
	${If} $0 == "Notepad++_file"
		ReadRegStr $3 HKCR $2 "Notepad++_backup"
		; Recover (some of) the lost original file types
		${If} $3 == "Notepad++_file"
			${If} $2 == ".ini"
				StrCpy $3 "inifile"
			${ElseIf} $2 == ".inf"
				StrCpy $3 "inffile"
			${ElseIf} $2 == ".nfo"
				StrCpy $3 "MSInfoFile"
			${ElseIf} $2 == ".txt"
				StrCpy $3 "txtfile"
			${ElseIf} $2 == ".log"
				StrCpy $3 "txtfile"
			${ElseIf} $2 == ".xml"
				StrCpy $3 "xmlfile"
			${EndIf}
		${EndIf}
		${If} $3 == "Notepad++_file"
			; File type recovering has failed. Just discard the current file extension
			DeleteRegKey HKCR $2
		${Else}
			; Restore the original file type
			WriteRegStr HKCR $2 "" $3
			DeleteRegValue HKCR $2 "Notepad++_backup"
			IntOp $1 $1 + 1
		${EndIf}
	${Else}
		IntOp $1 $1 + 1
	${EndIf}
	Goto Enum_HKCR_Loop
Enum_HKCR_Done:

	; Remove references to "Notepad++_file" from "Open with..."
	IntOp $1 0 + 0	; subkey index
	StrCpy $2 ""	; subkey name
Enum_FileExts_Loop:
	EnumRegKey $2 HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts" $1
	StrCmp $2 "" Enum_FileExts_Done
	DeleteRegValue HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$2\OpenWithProgids" "Notepad++_file"
	IntOp $1 $1 + 1
	Goto Enum_FileExts_Loop
Enum_FileExts_Done:

	; Remove "Notepad++_file" file type
	DeleteRegKey HKCR "Notepad++_file"
SectionEnd

Section un.UserManual
	RMDir /r "$INSTDIR\user.manual"
SectionEnd

Section Uninstall
	;Remove from registry...
	DeleteRegKey HKLM "${UNINSTALL_REG_KEY}"
	DeleteRegKey HKLM "SOFTWARE\${APPNAME}"
	DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe"

	; Delete self
	Delete "$INSTDIR\uninstall.exe"

	; Delete Shortcuts
	Delete "$SMPROGRAMS\Notepad++\Uninstall.lnk"
	RMDir "$SMPROGRAMS\Notepad++"
	
	UserInfo::GetAccountType
	Pop $1
	StrCmp $1 "Admin" 0 +2
		SetShellVarContext all
	
	Delete "$DESKTOP\Notepad++.lnk"
	Delete "$SMPROGRAMS\Notepad++\Notepad++.lnk"
	Delete "$SMPROGRAMS\Notepad++\readme.lnk"
	

	; Clean up Notepad++
	Delete "$INSTDIR\LINEDRAW.TTF"
	Delete "$INSTDIR\SciLexer.dll"
	Delete "$INSTDIR\change.log"
	Delete "$INSTDIR\license.txt"

	Delete "$INSTDIR\notepad++.exe"
	Delete "$INSTDIR\readme.txt"
	
	
	Delete "$INSTDIR\config.xml"
	Delete "$INSTDIR\config.model.xml"
	Delete "$INSTDIR\langs.xml"
	Delete "$INSTDIR\langs.model.xml"
	Delete "$INSTDIR\stylers.xml"
	Delete "$INSTDIR\stylers.model.xml"
	Delete "$INSTDIR\stylers_remove.xml"
	Delete "$INSTDIR\contextMenu.xml"
	Delete "$INSTDIR\shortcuts.xml"
	Delete "$INSTDIR\functionList.xml"
	Delete "$INSTDIR\nativeLang.xml"
	Delete "$INSTDIR\session.xml"
	Delete "$INSTDIR\localization\english.xml"
	
	SetShellVarContext current
	Delete "$APPDATA\Notepad++\langs.xml"
	Delete "$APPDATA\Notepad++\config.xml"
	Delete "$APPDATA\Notepad++\stylers.xml"
	Delete "$APPDATA\Notepad++\contextMenu.xml"
	Delete "$APPDATA\Notepad++\shortcuts.xml"
	Delete "$APPDATA\Notepad++\functionList.xml"
	Delete "$APPDATA\Notepad++\nativeLang.xml"
	Delete "$APPDATA\Notepad++\session.xml"
	Delete "$APPDATA\Notepad++\insertExt.ini"
	IfFileExists  "$INSTDIR\NppHelp.chm" 0 +2
		Delete "$INSTDIR\NppHelp.chm"

	RMDir "$APPDATA\Notepad++"
	
	StrCmp $1 "Admin" 0 +2
		SetShellVarContext all
		
	; Remove remaining directories
	RMDir /r "$INSTDIR\plugins\disabled\"
	RMDir "$INSTDIR\plugins\APIs\"
	RMDir "$INSTDIR\plugins\"
	RMDir "$INSTDIR\themes\"
	RMDir "$INSTDIR\localization\"
	RMDir "$INSTDIR\"
	RMDir "$SMPROGRAMS\Notepad++"
	RMDir "$APPDATA\Notepad++"

SectionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

BrandingText "Don HO"

; eof

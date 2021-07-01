// Скрипт-обертка для запуска одноименного скрипта .ps1
Shell = WScript.CreateObject( "WScript.Shell" );
FSO = WScript.CreateObject( "Scripting.FileSystemObject" );
ThisScriptFile = FSO.GetFile( WScript.ScriptFullName );
ThisScriptFolder = FSO.GetParentFolderName( ThisScriptFile );
thisScriptFileName = FSO.GetBaseName( WScript.ScriptFullName );
targetPs1Path = FSO.BuildPath( ThisScriptFolder, thisScriptFileName + "1.ps1" );
Shell.Run( '"C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe" "' + targetPs1Path + '"', 0, false );

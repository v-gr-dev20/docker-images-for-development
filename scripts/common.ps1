# !Powershell

# Считывает параметры программы из файла config.json
function getConfig()
{
	$projectName, $projectPath = getProjectNP
	Get-Content "$projectPath/config.json" |ConvertFrom-Json -AsHashtable
}

# Возвращает имя и путь проекта - имя родительской папки скрипта на 2 уровня выше
function getProjectNP()
{
	$thisScriptDirPath = $ThisScriptPath |Split-Path -parent
	$projectPath = $thisScriptDirPath |Split-Path -parent
	$projectName = $projectPath |Split-Path -Leaf
	<#assert#> if( [string]::IsNullOrEmpty( $projectName ) ) { throw }
	<#assert#> if( [string]::IsNullOrEmpty( $projectPath ) ) { throw }

	$projectName, $projectPath
}

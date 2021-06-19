# !Powershell
# Общие фукции
# Для включения функций в код скрипта (include) использовать следующую строку
# . $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent )" -ChildPath "common.ps1" )

# Считывает параметры программы из файла config.json
function getConfig( [Parameter( Position = 0 )][string] $projectName )
{
	$projectPath = getProject( $projectName )
	$configPath = Join-Path $projectPath 'config.json'
	<#assert#> if( -not ( Test-Path $configPath -PathType leaf ) ) { throw }
	$result = Get-Content $configPath |ConvertFrom-Json -AsHashtable
	# вызов без параметров - получаем имя проекта из папки конфига
	if( [string]::IsNullOrEmpty( $projectName ) ) {
		$projectName = $configPath |Split-Path -parent |Split-Path -leaf
	}
	$result.projectName = $projectName
	$result.configPath = $configPath
	$result
}

# Возвращает путь проекта
function getProject( [Parameter( Position = 0 )][string] $projectName )
{
	$thisScriptDirPath = $ThisScriptPath |Split-Path -parent
	# вызов без параметров - считаем папкой проекта папку скрипта или родительскую
	if( $null -eq $projectName ) {
		$projectName = ''
	}
	$projectPath = $(
		if( Test-Path ( Join-Path $thisScriptDirPath $projectName 'config.json' ) -PathType leaf ) {
			$thisScriptDirPath
		} elseif( Test-Path ( Join-Path ( $thisScriptDirPath |Split-Path -parent ) $projectName 'config.json' ) -PathType leaf ) {
			$thisScriptDirPath |Split-Path -parent
		} else {
			$thisScriptDirPath
		}
	)
	<#assert#> if( [string]::IsNullOrEmpty( $projectPath ) ) { throw }
	$projectPath
}

# Копирует hashtable в части указанного набора ключей
function Select-Hashtable-by-Keys( [Parameter( Position = 0 )][hashtable] $map, [Parameter( Position = 1 )][string[]] $keys )
{
	$result = @{}
	# получаем срез конфига по следующим требуемым полям
	$keys |ForEach-Object {
		if( $PSItem -in $map.Keys ) {
			$result[$PSItem] = $config[$PSItem]
		}
	}
	$result
}

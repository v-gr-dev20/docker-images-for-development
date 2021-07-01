#!Powershell
# Скрипт выполняет очистку после запуска приложения

# TODO: реализовать хранение параметров в конфиге
# Параметры приложения в глобальных переменных
$interface = 'vEthernet (WSL)'

function main()
{
	$projectPath = getProject
	$projectName = ( $projectPath |Split-Path -Leaf ).ToLower()

	# Удаляем разрешающее правило файервола (от имени администратора)
	if( $null -ne ( Get-NetFirewallRule -DisplayName $projectName 2> $null ) ) {
		if( -NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator" ) ) {
			Start-Process powershell -Verb runAs "Remove-NetFirewallRule -DisplayName `'${projectName}`'"
		}
	}

}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
# TODO: возможна реализация конфига программы как дополнение к этой библиотеки
#. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 1 -le $Args.Count -and $Args[0].ToLower() -in @( "-h", "--help" ) `
	) -or( 0 -ne $Args.Count ) )
{
	outputHelp
	exit
}
$toSkipArgsCount = 0
New-Variable -Name config -Option ReadOnly  -Value $(
	# интерпретируем контекст аргументов скрипта, см. Usage:
	if( 0 -eq $Args.Count ) {
		getConfig
	} else {
		$toSkipArgsCount += 1
		getConfig $Args[0] 
	}
)
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )
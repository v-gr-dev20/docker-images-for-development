#!Powershell
# Запуск firefox из Docker-контейнера с графическим выводом X11 на windows-хосте
# Демонстрирует возможность "пробросить" X11 из docker-контейнера (X11-клиент)
#	через слой wsl2-debian в windows-хост (X11-сервер).

# TODO: реализовать хранение параметров в конфиге
# Параметры приложения в глобальных переменных
$dockerIPAdress = ( bash -c "hostname -I |cut -f1 -d' '" )
$appExportedPort = '2150'
$x11ServerFullPath = 'c:\Program Files\VcXsrv\vcxsrv.exe'
$display = '0.0'
$application = 'firefox'
$interface = 'Беспроводная сеть'
$localhostIPAddress = ( Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $interface ).IPAddress

function main()
{
	$projectPath = getProject
	$projectName = ( $projectPath |Split-Path -Leaf ).ToLower()

	# Проверяем наличие ключей
	$wasKeyExists = Test-Path "${projectPath}/id_rsa"
	if( -not $wasKeyExists ) {
		# генерация ключей
		ssh-keygen '-C' $( $projectPath |Split-Path -Leaf ) '-f' "$projectPath/id_rsa" '-P' """" `
		&& ssh-keygen '-y' '-f' "$projectPath/id_rsa" > "$projectPath/id_rsa.pub"
		<#assert#> if( 0 -ne $LastExitCode ) { throw }
	}

	# Проверяем наличие образа проекта в Docker
	$isImageExists = ( 1 -le `
		( [string[]]( bash -c `
			( -join( 'docker images "',$projectName,'" --format "{{.Repository}}"' ) ) ) `
		).Count )
	if( -not $isImageExists -or -not $wasKeyExists ) {
		# предварительная очистка
		&"${projectPath}/cleanup1.ps1" "$projectName"
		# сборка docker-образа
		&"${projectPath}/../scripts/build.ps1" "$projectName"
		<#assert#> if( 0 -ne $LastExitCode ) { throw }
	}

	# Запуск X сервера в windows
	if ( -not ( Get-Process | Where { $_.ProcessName -eq 'vcxsrv' } ) ) {
		&"${x11ServerFullPath}" ':0' '-ac' '-multiwindow' '-clipboard' '-primary' '-wgl' '-winkill'
		<#assert#> if( 0 -ne $LastExitCode ) { throw }
	}

	# Запуск docker-контейнера приложения
	$isContainerExists = ( 1 -le `
		( [string[]]( bash -c `
			( -join( 'docker ps -a --filter status=running --filter "ancestor=',$projectName,'" --format "{{.ID}}"' ) ) ) `
		).Count )
	if( -not $isContainerExists ) {
		bash -c "docker run -d -it --rm -p ${appExportedPort}:22 ${projectName}"
		<#assert#> if( 0 -ne $LastExitCode ) { throw }
	}

	# Добавляем разрешающее правило файервола (от имени администратора)
	if( $null -eq ( Get-NetFirewallRule -DisplayName $projectName 2> $null ) ) {
		if( -NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator" ) ) {
			Start-Process powershell -Verb runAs "New-NetFirewallRule -DisplayName `'${projectName}`' -Direction Inbound -Action Allow -Protocol TCP -InterfaceAlias `'${interface}`' -LocalAddress `'${localhostIPAddress}`' -Program `'${x11ServerFullPath}`'"
		}
	}

	# Запуск приложения
	Invoke-Command-by-SSH -MustSaveLog:$false -WithTimestamp:$false `
		-SshOptions:( '-f', '-X', '-oStrictHostKeyChecking=no', "-oUserKnownHostsFile=$null", "-iid_rsa", "-p${appExportedPort}", "root@${dockerIPAdress}" ) `
		 $config "DISPLAY=${localhostIPAddress}:${display} ${application}"
}

# include
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/common.ps1" )
. $( Join-Path -Path "$( $MyInvocation.MyCommand.Path |Split-Path -parent |Split-Path -parent )" -ChildPath "scripts/ssh-functions.ps1" )

# Выводит подсказку
function outputHelp()
{
	$commandName = $ThisScriptPath |Split-Path -Leaf
	if( ".ps1" -eq [System.IO.Path]::GetExtension( $commandName ).ToLower() ) {
		$commandName = [System.IO.Path]::GetFileNameWithoutExtension( $commandName )
	}
"	Usage:
		$commandName
		$commandName	<profile>
		$commandName	<profile> -c | --command <command> [<arg1> <arg2> ...]
		$commandName	-c | --command <command> [<arg1> <arg2> ...]
		$commandName	-h | --help
"
}

# Точка входа
[string] $ThisScriptPath = $MyInvocation.MyCommand.Path
if( ( 1 -le $Args.Count -and $Args[0].ToLower() -in @( "-h", "--help" ) `
	) -or( 2 -le $Args.Count `
		-and -not( $Args[1].ToLower() -in @( "-c", "--command" ) ) `
		-and -not( $Args[2].ToLower() -in @( "-c", "--command" ) ) `
	) -or( $Args.Count -in @( 1..2 ) -and $Args[-1].ToLower() -in @( "-c", "--command" ) ) )
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
		if( $Args[1].ToLower() -in @( "-c", "--command" ) ) {
			getConfig
		} else {
			getConfig $Args[0] 
		}
		if( 2 -le $Args.Count -and ( $Args[1].ToLower() -in @( "-c", "--command" ) ) ) {
			$toSkipArgsCount += 1 
		}
	}
)
Invoke-Command { main @Args } -ArgumentList ( $Args |Select-Object -Skip $toSkipArgsCount )
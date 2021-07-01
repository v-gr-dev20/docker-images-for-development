# !/usr/bin/bash
# Скрипт останавливает запущенные docker-контейнеры приложения

appExportedPort=2150

function main()
{
	# Находим файлы docker
	local -a projectData
	readarray -t projectData < <( GetProject "$1" )
	local projectName="${projectData[0]}" projectPath="${projectData[1]}" DockerfileName="${projectData[2]}" DockerfilePath="${projectData[3]}"
	[ -z "$DockerfilePath" ] && { 
		echo "Dockerfile not found." >&2
		exit 1
	}

	echo "cleanup ${projectName}: ${DockerfilePath}"

	# Останавливаем контейнеры приложения по номеру экспортированного порта
	docker ps -a --filter status=running --format "{{.ID}}\t{{.Ports}}" \
		|awk '$2~":'$appExportedPort'-" {print $1}' |xargs -r -n1 docker stop
}

# Выводит подсказку
function outputHelp()
{
	commandName=$( basename "$ThisScriptPath" )
	if [ ".sh" == ".${commandName##*.}" ] ;then
		commandName="${commandName%.*}"
	fi
	echo \
"	Usage:
		$commandName
		$commandName dockerImageName | dockerImagePath
		$commandName -h | --help
"
}

# Точка входа
typeset ThisScriptPath="$( readlink -m "$0" )"
if( echo "$1" |grep -E '\-h|\-help' > /dev/null );then
	outputHelp
	exit
fi
# include
. "$( dirname "$ThisScriptPath" )/common.sh" 2> /dev/null || \
. "$( dirname "$( dirname "$ThisScriptPath" )" )/scripts/common.sh" 2> /dev/null

main "$@"
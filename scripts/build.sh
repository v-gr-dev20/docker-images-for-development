# !/usr/bin/bash
# Скрипт запускает сборку docker-образа из Dockerfile.
# Скрипт предполагает наличие Dockerfile в папке, которая передается параметром в командной строке.
# Если параметров нет, то скрипт находит Dockerfile в текущей или родительской папке уровнем выше.

function main()
{
	typeset -a searchPlan
	typeset projectPath=
	typeset suffix=-docker-img
	typeset projectName=

	# Формируем план поиска Dockerfile
	if [ -z "$1" ] ;then
		searchPlan=( "${searchPlan[@]}" "$( pwd )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "${searchPlan[-1]}" )" )
	elif [[ "$1" == "$( basename "$1" )" && ! $1 =~ ^(\.|\.\.|\/)$ ]] ;then
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "$1" )" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( pwd )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )/$1" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( readlink -m "$0" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "${searchPlan[-1]}" )/$1" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		searchPlan=( "${searchPlan[@]}" "$( dirname "$( dirname "$( readlink -m "$0" )" )" )" )
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "../$1" )" )
		searchPlan=( "${searchPlan[@]}" "${searchPlan[-1]}${suffix}" )
		projectName=$1
	else
		searchPlan=( "${searchPlan[@]}" "$( readlink -m "$1" )" )
	fi

	# Находим Dockerfile проекта
	for projectPath in "${searchPlan[@]}" ;do
		[ -f "$projectPath" ] && break
		[[ -d "$projectPath" && -f "$projectPath/Dockerfile" ]] && break
	done

	# Получаем имя docker-образа
	projectName=${projectName:-$( echo "${projectPath}" |sed 's/^\///' )}
	while [ "$( basename "$projectName" )" == "Dockerfile" ] ;do
		projectName=$( dirname "$projectName" )
	done
	projectName=$( basename "$projectName" |sed 's/\('${suffix}'\)\{1,\}$//g' |sed 's/^[\.\/]$//g' )

	# Запускаем сборку docker-образа
	if [ -f "$projectPath" ] ;then
		docker build ${projectName:+-t "$projectName"} -f "$( basename "$projectPath" )" "$( dirname "$projectPath" )"
	elif [[ -d "$projectPath" && -f "$projectPath/Dockerfile" ]] ;then
		docker build ${projectName:+-t "$projectName"} "${projectPath}"
	else
	# либо выбрасываем ошибку
		echo "Error: Dockerfile project not found!"
		exit 1
	fi
}

main "$@"
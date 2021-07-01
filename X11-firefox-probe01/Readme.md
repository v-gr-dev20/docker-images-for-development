Краткое описание проекта X11-firefox-probe01  
============================================
https://github.com/v-gr-dev20/docker-images-for-development/blob/X11-firefox-probe01/X11-firefox-probe01/Readme.md  
https://github.com/v-gr-dev20/docker-images-for-development/tree/X11-firefox-probe01/X11-firefox-probe01

Это демонстрационный пример работы графического приложения X11 в Docker-конейнере под Windows.  
Docker исполняется на уровне WSL2-Debian вызывающего хоста Windows. В качестве приложения использован Firefox (для Debian Linux). Окно приложения может выводиться на монитор хоста Windows.

### Cхема компонентов:
| Компонент     | на уровне Docker      | на уровне ssh              | на уровне X11               |
|:--------------|:----------------------|:---------------------------|:----------------------------|
| Windows-хост  |                       | клиент                     | сервер X11 VcXsrv           |
| WSL2-Debian   | хост Docker           | экспорт 22 порта           |                             |
| Docker        | контейнер             | сервер                     |                             |
| Firefox       | приложение            | поток данных               | клиент X11                  |

### Пререквизиты
1. Windows c установленными VcXsrv, WSL2, git, open-ssh. Использован Powershell v7.2
1. Debian Linux - как гостевая OC для WSL2 в Windows
1. Docker - установлен в гостевом Debian Linux

### Установка
```
win$> mkdir demo
win$> git clone --branch X11-firefox-probe01 -- <this repo> demo
win$> ssh-keygen -C X11-firefox-probe01 -f demo/X11-firefox-probe01/id_rsa -P """"
win$> ssh-keygen -y -f demo/X11-firefox-probe01/id_rsa > demo/X11-firefox-probe01/id_rsa.pub
win$> demo/scripts/build.ps1 X11-firefox-probe01
```
### Запуск
```
win$> demo/X11-firefox-probe01/start.ps1
win$> demo/X11-firefox-probe01/start.ps1
win$> demo/X11-firefox-probe01/start.ps1
```

������� �������� ������� X11-firefox-probe01  
============================================
https://github.com/v-gr-dev20/docker-images-for-development/blob/X11-firefox-probe01/X11-firefox-probe01/Readme.md  
https://github.com/v-gr-dev20/docker-images-for-development/tree/X11-firefox-probe01/X11-firefox-probe01

��� ���������������� ������ ������ ������������ ���������� X11 � Docker-��������� ��� Windows.  
Docker ����������� �� ������ WSL2-Debian ����������� ����� Windows. � �������� ���������� ����������� Firefox (��� Debian Linux). ���� ���������� ����� ���������� �� ������� ����� Windows.

### C���� �����������:
| ���������     | �� ������ Docker      | �� ������ ssh              | �� ������ X11               |
|:--------------|:----------------------|:---------------------------|:----------------------------|
| Windows-����  |                       | ������                     | ������ X11 VcXsrv           |
| WSL2-Debian   | ���� Docker           | ������� 22 �����           |                             |
| Docker        | ���������             | ������                     |                             |
| Firefox       | ����������            | ����� ������               | ������ X11                  |

### ������������
1. Windows c �������������� VcXsrv, WSL2, git, open-ssh. ����������� Powershell v7.2
1. Debian Linux - ��� �������� OC ��� WSL2 � Windows
1. Docker - ���������� � �������� Debian Linux

### ���������
```
win$> mkdir demo
win$> git clone --branch X11-firefox-probe01 -- <this repo> demo
win$> ssh-keygen -C X11-firefox-probe01 -f demo/X11-firefox-probe01/id_rsa -P """"
win$> ssh-keygen -y -f demo/X11-firefox-probe01/id_rsa > demo/X11-firefox-probe01/id_rsa.pub
win$> demo/scripts/build.ps1 X11-firefox-probe01
```
### ������
```
win$> demo/X11-firefox-probe01/start.ps1
win$> demo/X11-firefox-probe01/start.ps1
win$> demo/X11-firefox-probe01/start.ps1
```

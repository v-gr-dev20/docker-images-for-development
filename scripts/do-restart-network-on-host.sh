#!/bin/sh
# ������� ����
# reboot � ������ ������� - ��� ���������� ������������ ���������� � ����

# ����������� ����� ������� ������� ����������� � ����
pingHost=8.8.8.8
# ����� � �������� �� �������������� ������������ ����� � ������ ���������� ����������� � ����
patienceTimeout=60
# ����� � �������� ����� ������������ ������� �� �����������
testTimeout=5

try() {
	ping -c1 -w$( expr $patienceTimeout * 10 / 100 ) $pingHost
}

# ������� ���� �� ��������� ����� � ������������ ����� �������
(((/etc/init.d/network restart &) ;sleep $patienceTimeout ;try > /dev/null 2>&1 || reboot )&)& 

ps -w |grep -E "network|sleep" |grep -v grep

# �������� �����������
tryRest=$( expr $patienceTimeout / $testTimeout + 1 )
while [[ 0 -lt $tryRest ]]
do
	sleep $testTimeout
	if try ;then break ;fi
	tryRest=$( expr $tryRest - 1 )
done |while read line ;do
	# ����������� ����� � ������ ���������� ����������� � ���������
	echo "$( date '+%F %H:%M:%S' )	$line"
done

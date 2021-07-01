FROM debian
RUN apt update \
	&& apt install -y \
		# специальное название пакета с firefox для debian
		firefox-esr \
		openssh-server \
		xauth
RUN mkdir /var/run/sshd \
	&& mkdir /root/.ssh \
	&& chmod 700 /root/.ssh \
	&& ssh-keygen -A \
	&& sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
	&& sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
	&& sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
	&& grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

COPY id_rsa.pub /root/.ssh/id_rsa.pub.tmp
RUN cat /root/.ssh/id_rsa.pub.tmp >> /root/.ssh/authorized_keys \
 && rm /root/.ssh/id_rsa.pub.tmp

ENV LIBGL_ALWAYS_INDIRECT=1

ENTRYPOINT ["sh", "-c", "/usr/sbin/sshd && tail -f /dev/null"]
FROM centos:latest
MAINTAINER Pisces
ENV VERSION 1.1.3
ENV ARCH amd64
ENV HAPROXY 1.6.5

# update and install sshd
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7 \
	&& rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN yum -y update && yum install -y epel-release
RUN yum install -y passwd openssh-server openssh-clients wget nginx net-tools

RUN yum install -y git gcc haproxy vim

#change root password
RUN echo "root:password" | chpasswd
RUN ssh-keygen -A

# install haproxy
WORKDIR /tmp

#RUN wget  -qO haproxy.tar.gz http://www.haproxy.org/download/1.6/src/haproxy-${HAPROXY}.tar.gz
#RUN tar -xvzf haproxy.tar.gz
#WORKDIR /tmp/haproxy-${HAPROXY}




# install the chisel http tunnel
ENV PATH_NAME chisel_${VERSION}_linux_${ARCH}
RUN wget  -qO chisel.tgz https://github.com/jpillora/chisel/releases/download/${VERSION}/${PATH_NAME}.tar.gz
RUN tar -xzvf chisel.tgz ${PATH_NAME}/chisel
RUN mv ${PATH_NAME}/chisel /usr/local/bin

RUN mkdir -p /var/log/nginx
RUN touch /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

COPY forward /usr/local/bin/
COPY haproxy.cfg /etc/haproxy/

CMD ["/bin/sh", "-c", "/usr/local/bin/forward"]
EXPOSE 8080

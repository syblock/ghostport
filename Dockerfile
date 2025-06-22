FROM alpine:latest

WORKDIR /app

# Add manageit alpine mirror to alpine
RUN echo https://mirror.manageit.ir/alpine/v$(echo $(cat /etc/alpine-release) | awk -F . '{print $1"."$2}')/main > /etc/apk/repositories
RUN echo https://mirror.manageit.ir/alpine/v$(echo $(cat /etc/alpine-release) | awk -F . '{print $1"."$2}')/community >> /etc/apk/repositories

RUN apk update
RUN apk add openssh
RUN apk add openssh-server
RUN apk add openssh-client
RUN apk add autossh
RUN apk add sshpass
RUN apk add curl
RUN apk add nano

RUN ssh-keygen -A
RUN mkdir -p /var/run/sshd

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
RUN sed -i 's/X11Forwarding.*/X11Forwarding yes/' /etc/ssh/sshd_config

RUN echo "root:root" | chpasswd

COPY . .

EXPOSE 2080

ENTRYPOINT ["/bin/sh"]
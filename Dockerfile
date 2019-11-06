FROM alpine:3.10
LABEL maintener="clazar <claudiolazarosantos@gmail.com>"
LABEL version="0.1"
LABEL description="Openconnect for gp in docker - Corporate"

ARG V_SITE

ENV VPNSITE=$V_SITE

RUN addgroup --gid 1000 admin && \
    adduser \
    --disabled-password \
    --gecos "" \
    --shell /bin/bash \
    --home /home/admin \
    --ingroup admin \
    --uid 1000 \
    admin

RUN set -ex \
# 1. Adicioar repositorios necessario, fix nsswitch erro
    && echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "@edgecommunity http://nl.alpinelinux.org/alpine/edge/community" >>/etc/apk/repositories \
    && echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories \
    && echo 'hosts: files dns' >> /etc/nsswitch.conf \
    && apk --update  upgrade \
#   && apk add --no-cache --no-progress --virtual stoken\
# 2. Essa build do openconnect e uma versao adaptada (fork from: https://github.com/gzm55/docker-vpn-client)
## 2.1 Instalacao de bibliotecas e dependencias
    && apk add --no-cache \
               gnutls gnutls-utils iptables libev libintl \
               libnl3 libseccomp linux-pam lz4-libs openssl \
               libxml2 openssh-client libproxy libtool krb5 \
    && apk add --no-cache \
               unzip curl file g++ gnutls-dev gpgme gzip libev-dev build-base \
               libnl3-dev libseccomp-dev libxml2-dev linux-headers \
               linux-pam-dev lz4-dev make readline-dev tar \
               sed readline procps gettext autoconf automake libproxy-dev krb5-dev \
               git sudo musl-dev gcc libxslt-dev pidgin pidgin-sipe ghostscript-fonts py2-lxml py2-requests py2-pip sshpass\
               chromium \
## 2.2 download vpnc-script
    && mkdir -p /usr/local/sbin/ \
    && curl -o /usr/local/sbin/vpnc-script http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/HEAD:/vpnc-script \
    && chmod +x /usr/local/sbin/vpnc-script  \
## 2.3 Install pip install pyotp
    && pip install pyotp \
## 2.4 create build dir, download, verify and decompress OC package to build dir
    && git clone https://github.com/dlenski/openconnect.git /tmp/openconnect-globalprotect \
## 2.5 build and install
    && cd /tmp/openconnect-globalprotect \
    && ./autogen.sh \
    && ./configure --with-vpnc-script=/usr/local/sbin/vpnc-script \
    && make \
    && make install \
# 3. cleanup
    && rm -rf /var/cache/apk/* /tmp/* \
# 4. Configuracao do usuario para pdgin
RUN export uid=1000 gid=1000 && \
    echo "admin:x:${uid}:${gid}:Admin,,,:/home/admin:/bin/bash" >> /etc/passwd && \
    echo "admin:x:${uid}:" >> /etc/group && \
    sed -e "s/^wheel:\(.*\)/wheel:\1,admin/g" -i /etc/group && \
    sed -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/g' -i /etc/sudoers

USER admin

EXPOSE 9090
EXPOSE 80

COPY content /

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "-c" ]

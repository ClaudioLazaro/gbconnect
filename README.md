# docker-openconnect-gp 

Openconnect globalprotect in docker. Support openconect.

[Fork and rewrite](https://github.com/gzm55/docker-vpn-client)


docker run -it \
   -e DISPLAY \
   -e VPNSITE=vpnusersebt.yourdomain.com.br \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   -v ${HOME}/.pidgin:/home/admin/config \
   -v ${HOME}/Shared:/Shared \
   --privileged \
   --hostname wtimedbs001.yourdomain.com.br \
   --name gbconnect \
   --user admin \
   --shm-size=2g \
   clazarsky/gbconnect:latest

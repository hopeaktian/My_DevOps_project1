[root@pro1 ~]# salt-cp 'pro5' /root/nginx-install.sh /root/nginx-install.sh 
[root@pro1 ~]# salt-cp 'pro5' /root/nginx-1.14.2.tar.gz /usr/local/src/nginx-1.14.2.tar.gz
[root@pro1 ~]# salt 'pro5' cmd.run "sh /root/nginx-install.sh"

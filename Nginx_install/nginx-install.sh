#!/bin/bash
RELEASE=nginx-1.14.2									# Nginx软件版本设置
SRC_TAR_PATH=/usr/local/src/nginx-1.14.2.tar.gz			# 安装源码包位置设置，需要预先将源码包放到到此处
SRC_PATH=/usr/local/src/nginx-1.14.2					# 源码解压路径	
INSTALL_PATH=/usr/local/nginx-1.14.2					# 安装位置自定义设置

function install(){
	cd $SRC_PATH
	./configure --prefix=$INSTALL_PATH --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module
	make & make install
	# 设置软连接目录，便于nginx升级
	if [ -d $(dirname $INSTALL_PATH)/nginx ];then
	rm -fr $(dirname $INSTALL_PATH)/nginx
	fi
	ln -s $INSTALL_PATH $(dirname $INSTALL_PATH)/nginx
}

function check_file(){
	if [ ! -f $SRC_TAR_PATH ];then
		echo NOT found  $SRC_TAR_PATH
		exit 1
	else
		if [ ! -d $SRC_PATH ];then
		mkdir -p $SRC_PATH
		fi
		if [ ! -d $INSTALL_PATH ];then
		mkdir -p $INSTALL_PATH
		fi
		tar zxf $SRC_TAR_PATH -C $SRC_PATH --strip-components 1
	fi
}
function main(){
	echo "Beginning to install $RELEASE"
	check_file
	if [ $? -eq 0 ];then
		yum install -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel pcre-devel zlib-devel openssl-devel 
	else
		check_file failed
		exit 1
	fi
	if [ $? -eq 0 ];then
		install
	else
		echo "yum install failed"
	fi
	if [ $? -eq 0 ];then
		ln -s $(dirname $INSTALL_PATH)/nginx/sbin/nginx /bin/nginx 
	else
		echo "nginx install failed"
	fi
	if [ ! -x /usr/lib/systemd/system/nginx.service ];then
	echo "[Unit]
Description=nginx - high performance web server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s stop

[Install]
WantedBy=multi-user.target" > /usr/lib/systemd/system/nginx.service
	fi
	if [ $? -eq 0 ];then
		systemctl enable nginx.service
		systemctl start nginx.service
	fi
	if [ $? -eq 0 ];then
		echo "Install Finished"	
	else
		echo "Failed"
	fi
}
main

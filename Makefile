# ip2region luc c module Make file
# @author   chenxin<chenxin619315@gmail.com> yorkane<whyork@qq.com>
# @date     2021/4/16

# @Note
# Please modify the LIBS and the LIB_DIR to fit you system
# 
CC = gcc
LIBS = -I ./ -I /usr/local/openresty/luajit/include/luajit-2.1/
FFLAGS = -O2 -Wall -fPIC
SO_FILE = Ip2region.so
LIB_DIR = /usr/local/openresty/site/

all: ip2region.c ip2region.h lua_ip2region.c
	$(CC) $(FFLAGS) $(LIBS) ip2region.c lua_ip2region.c -fPIC -shared -o $(SO_FILE)

install:
	mkdir -p $(LIB_DIR)lualib/resty/
	cp $(SO_FILE) $(LIB_DIR)lualib/ -f
	cp resty/*.lua $(LIB_DIR)lualib/resty/ -f
	cp *.csv $(LIB_DIR) -f
	mv data/ip2region.db $(LIB_DIR)
	echo "install Ip2region to $(LIB_DIR) successfully."

clean:
	find . -name \*.so | xargs rm -f
	find . -name \*.o  | xargs rm -f

.PHONY: clean

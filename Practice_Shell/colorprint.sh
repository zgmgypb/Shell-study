#!/bin/bash  
# 先定义一些颜色:
red='\e[0;41m' # 红色  
RED='\e[1;31m' 
green='\e[0;32m' # 绿色  
GREEN='\e[1;32m' 
yellow='\e[5;43m' # 黄色  
YELLOW='\e[1;33m' 
blue='\e[0;34m' # 蓝色  
BLUE='\e[1;34m' 
purple='\e[0;35m' # 紫色  
PURPLE='\e[1;35m' 
cyan='\e[4;36m' # 蓝绿色  
CYAN='\e[1;36m' 
WHITE='\e[1;37m' # 白色
  
NC='\e[0m' # 没有颜色

#$1: string
#$2: color
color_echo()
{
	[ -n "$2" ] && eval echo -ne "\${$2}"
	echo -e "$1${NC}"
}
 
#example
color_echo 显示红色0 red
color_echo 显示红色1 RED
color_echo 显示绿色0 green
color_echo 显示绿色1 GREEN
color_echo 显示黄色0 yellow
color_echo 显示黄色1 YELLOW
color_echo 显示蓝绿色0 cyan
color_echo 显示蓝绿色1 CYAN

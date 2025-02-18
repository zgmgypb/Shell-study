#!/bin/sh

#set -e # 当命令出现任何返回非 0 脚本停止运行并退出

# for debug
DEBUG_LOG_FILE='&2'
DEBUG_LOG_LEVEL=0

# ANSI COLORS
COLOR_CRE="[K"
COLOR_NORMAL="[0;39m"
COLOR_RED="[1;31m"
COLOR_GREEN="[1;32m"
COLOR_YELLOW="[1;33m"
COLOR_BLUE="[1;34m"
COLOR_MAGENTA="[1;35m"
COLOR_CYAN="[1;36m"
COLOR_WHITE="[1;37m"

# Shell command
TAR=tar
CP=/bin/cp
RM=/bin/rm
GREP=grep
SED=sed # stream edit 字符流编辑器
MKDIR=mkdir
CHMOD=chmod
MV=mv
CD=cd
LN=ln
MAKE=make
MKNOD=mknod
PUSHD=pushd 
POPD=popd 
RMDIR=rmdir # 删除空目录 
DEPMOD=/sbin/depmod # 创建 modules 的 symbols 依赖关系表 modules.dep
RMDIR=rmdir
MKIMG=mkimage # 使用 uboot 生成的工具制作 uimage 文件
PATCH=patch # 与 diff 一起使用，使用差异文件用于目标文件的补丁，直接打补丁到目标文件
DIFF=diff # diff 比较目标文件之间的差异，并可以生成补丁文件
TOUCH=touch # 改变目标文件的时间戳，可以创建一个空文件
CAT=cat

# 正则表达式，用于判断一些格式化数据
e_blank='[        ][      ]*'
e_year='20[0-9][0-9]'
e_month='([1-9]|0[1-9]|1[0-2])'
e_day='([1-9]|0[1-9]|[12][0-9]|3[0-1])'
e_time='([01][0-9]|2[0-3]):[0-5][0-9]'
e_employid='[a-zA-Z][a-zA-Z]*[0-9]{4,}'

#$1: string
#$2: color
ECHO()
{
	[ -n "$2" ] && eval echo -n \"\${${2}}\"; # -n 判断 $2 字符串是否为空,若不为空执行 echo 显示颜色，echo -n 表示不加入换行符
	echo "${1}${COLOR_NORMAL}"
}

ERR()
{
	echo "${COLOR_RED} ERR: ${1}${COLOR_NORMAL}" >&2 # 使用 stderr 输出
}

WARN()
{
	echo "${COLOR_YELLOW}WARN: ${1}${COLOR_NORMAL}" >&2
}

# $1:
LOG()
{
	echo "$1"
}


#$1: string
#$2: level
DEBUG()
{
	local level=$2
	[ -z "$level" ] && { level=0; } # 空参数检测
	[ $level -lt $DEBUG_LOG_LEVEL ] && return 0; # level 越高表示调试级别越高

	echo "$COLOR_WHITE$1$COLOR_NORMAL" > $DEBUG_LOG_FILE
}

# $1: command
# $2: LR/CR steps
run_command_progress() # 这个函数不完善,运行效果不好
{
	local n=0
	local steps=$2
	local progress_bar=""
	local counter=0
	local files=0

	ECHO "run_command_progress: '$1'" 
	[ -z "$steps" ] && { steps=1; }

	[ -n "$3" ] && [ -d "$3" ] && { steps=`find $3 | wc -l`; steps=`expr $steps / 50`; }

	eval $1 | while read line
	do
		#((n++))
		#((files++))
		((++n))
		((++files))

		if [ $n -ge $steps ] ;
		then
			#((counter++))
			((++counter))
			if [ $counter -le 50 ] ;
			then
				progress_bar="$progress_bar#";
				printf "     --------------------------------------------------|\r[%03d]$progress_bar\r" $steps
			else
				printf "[%03d#$progress_bar|\r" `expr $files / 50`
			fi

			n=0
		fi
	done

	echo ""
}

# 该函数使用进度条显示命令的执行进度，通过命令产生的输出行来判断命令执行的进度
# $1: command
# $2: total # 手动输入总输出行数
# $3: command to calc totals # 使用命令计算 command 的输出总行数
run_command_progress_float()
{
	local readonly RCP_RANGE=50 # 定义只读变量
	local rcp_lines=0
	local rcp_nextpos=1
	local rcp_total=0
	local progress_bar=
	local rcp_prog=0
	local rcp_tmp=0
	local prog_bar_base=
	local rcp_percent=0

	ECHO "run_command_progress_float: '$1'" 

	if [ -n "$3" ] ;
	then
		echo -n "Initializing progress bar ..."
		rcp_total=`eval $3`;
		echo -n "\r"
		[ -z "$rcp_total" ] && rcp_total=1
	else
		[ -n "$2" ] && rcp_total=$2
	fi

	[ -z "$rcp_total" ] && rcp_total=1
	[ $rcp_total -le 0 ] && rcp_total=1

	prog_bar_base="[    ]" # 进度显示百分比形如 100%，故留 4 个占位空格
	while [ $rcp_tmp -lt $RCP_RANGE ] # 进度条初始化，显示 50 个 - 符号，表示开始
	do
		prog_bar_base="$prog_bar_base-"
		#((rcp_tmp++)) 
		((++rcp_tmp)) 
	done
	prog_bar_base="${prog_bar_base}|"
	printf "\r$prog_bar_base\r"

	set +e # 即使命令有错，继续执行
	eval $1 | while read line
	do
		#((rcp_lines++))
		((++rcp_lines))

		if [ $rcp_lines -ge $rcp_nextpos ]
		then
			rcp_percent=`expr \( $rcp_lines \* 101 - 1 \) / $rcp_total ` # 乘 101 的作用是最后完成时保证进度是 100%
			rcp_prog=`expr \( $rcp_lines \* \( $RCP_RANGE + 1 \) - 1 \) / $rcp_total ` # 设置实际显示的进度条长度
			[ $rcp_prog -gt $RCP_RANGE ] && rcp_prog=$RCP_RANGE
			rcp_nextpos=`expr \( \( $rcp_percent + 1 \) \* $rcp_total \) / 100`
			[ $rcp_nextpos -gt $rcp_total ] && rcp_nextpos=$rcp_total

			rcp_tmp=0
			progress_bar=""
			while [ $rcp_tmp -lt $rcp_prog ]
			do
				progress_bar="$progress_bar#"
				((rcp_tmp++))
			done
			printf "\r$prog_bar_base\r[%3d%%]$progress_bar\r" $rcp_percent # 刷新显示
		fi
	done
	set -e # 恢复

	echo ""
}

# 显示绝对路径
#$1: path
abs_path()
{
	pushd "$1" >/dev/null # 跳转到传入的路径
	[ $? -ne 0 ] && return 1; # 错误
	pwd # 显示绝对路径
	popd >/dev/null # 恢复到之前的路径
}

#$1: $cfg_moddir is multi # 创建一个文件,unpacking/cleanup 的脚本
prepare_unpacking_cleanup()
{
	$CAT >> $HCM_SH_SDKINSTALL << EOF

ECHO "unpacking $cfg_moddir"
mkdir -pv $module_basedir
run_command_progress_float "tar -xvzf `sub_dir $dir_postbuild_srctarball $HCM_DESTDIR`/$module_dirname.tgz -C $module_basedir/" 0 \
	"tar -tzf `sub_dir $dir_postbuild_srctarball $HCM_DESTDIR`/$module_dirname.tgz | wc -l"
EOF

if [ -z "$1" ] ;
then
	$CAT >> $HCM_SH_SDKCLEANUP << EOF

ECHO "cleanup $cfg_moddir"
run_command_progress_float "rm $cfg_moddir -frv" 0 "find $cfg_moddir | wc -l"
EOF
else
	$CAT >> $HCM_SH_SDKCLEANUP << EOF

ECHO "cleanup $cfg_moddir"
pushd $module_basedir
run_command_progress_float "rm $cfg_moddir -frv" 0 "find $cfg_moddir | wc -l"
popd
EOF
fi

}

# $1: prefix
# $2..$n: dirs list
# 创建多个目录
make_dirs()
{
	local make_dirs_count=2
	local make_dirs_dir=

	[ -z "$1" ] && { ERR "make_dirs mast have a prefix dir!"; return 1; }
	$MKDIR $1 -p

	while true
	do
		eval make_dirs_dir=\${$make_dirs_count}
		[ -z "$make_dirs_dir" ] && break;
		$MKDIR $1/$make_dirs_dir -p
		#((make_dirs_count++))
		((++make_dirs_count))
	done
}

check_dir_empty()
{
	[ -z "$1" ] && return 0; # 无参数
	! [ -d $1 ] && return 0; # 非目录
	[ -z "`find $1/ -maxdepth 1 -mindepth 1`" ] && return 0; # 目录中无内容

	return 1
}

# 第一个路径减去第二个路径，如: $1 为 /home/zgm/test, $2 为 /home/zgm 返回值为 test
# $1 - $2
# $3: frefix for '/', like "\\\\/"
sub_dir()
{
	local subdir=
	local dirA=`dirname $1/stub` # 获取路径名
	local dirB=`dirname $2/stub`

	while [ "$dirA" != "$dirB" ] && [ "$dirA" != "." ] && [ "$dirA" != "/" ] 
	do
		if [ -z "$subdir" ] ; then
			subdir=`basename $dirA`
		else
			subdir=`basename $dirA`$3/$subdir
		fi
		dirA=`dirname $dirA`
	done

	[ -z "$subdir" ] && subdir=.

	dirname $subdir/stub
}

# 相对路径计算
# $1: base dir
# $2: dest dir
# $3: frefix for '/', like "\\\\/"
base_offset_dir()
{
	local ofstdir=`sub_dir $2 $1`
	local bodofst=

	while [ "$ofstdir" != "." ] && [ "$ofstdir" != "/" ] 
	do
		if [ -z "$bodofst" ] ; then
			bodofst=..
		else
			bodofst=..$3/$bodofst
		fi
		ofstdir=`dirname $ofstdir`
	done

	dirname $bodofst/stub
}

#$1: dir
set_drv_kbuild()
{
	local cc_file=Makefile
	local mbdir= 

	for mbdir in $1 $1/*
	do
		if [ -f $mbdir/$cc_file ] ;
		then
			local kbuild_dir_adj="`base_offset_dir $HCM_DESTDIR $mbdir "\\\\"`\\/`echo "$HCM_SDKDIR_KBUILD" | \
				sed -n "s/\//\\\\\\\\\//gp"`"

			$SED -i "s/^KERNEL_MAKE[ \t]*:=.*/KERNEL_MAKE := -C $kbuild_dir_adj/" $mbdir/$cc_file
		fi
	done	
}

# 写 rlevel.config 文件
#$1: name
#$2: level
write_rootfs_level()
{
	local rlevel_config=$HCM_DESTDIR/$HCM_SDKDIR_RESOURCE/rlevel.config
	$TOUCH $rlevel_config
	[ -n "`grep "^\[[0-9A-Za-z][0-9A-Za-z\-]*\]	$1$" < $rlevel_config`" ] && { \
       		WARN "$rlevel_config already have item '$1'"
		return 0;
	}
	echo "[$2]	$1" >> $rlevel_config
}

# 移除版本管理软件 cvs 产生的文件目录
#$1: 
remove_all_cvsdir()
{
	! [ -d "$1" ] && { WARN "'$1' not found when remove 'CVS' directories."; return ; }

	ECHO "Remove: 'CVS' directories in $1"
	find $1 -type d -name "CVS" | xargs rm -fr
}

# strip 没有 strip 的文件
#$1: strip command
#$2: file list
strip_elf()
{
	for file in $2
	do
		[ -z "`file $file | grep "ELF .* executable, .*, not stripped"`" ] && continue

		ECHO "$1 $file"
		$1 $file
	done
}

# strip 没有 strip 的库文件
#$1: strip command
#$2: file list
strip_lib()
{
	for file in $2
	do
		[ -z "`file $file | grep "ELF .* shared object, .*, not stripped"`" ] && continue

		ECHO "strip not really done: $file"
	done
}

# 安装外部的内核模块
# $1: rootfs base
# $2: modules list
install_extern_kmod()
{
	local iek_installed_modules=
	local iek_dest_module=
	local iek_depend_info=
	local iek_install_base=

	pushd $1 >/dev/null
	iek_install_base=$PWD
	popd >/dev/null

	for iek_extmod in `find $2`
	do
		iek_dest_module=/$HCM_INROOTFS_EXTKMOD/`basename $iek_extmod`

		[ -f $HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE/$iek_dest_module ] && \
			{ WARN "Extern module $iek_extmod conflict: $iek_dest_module"; sleep 1; }

		iek_installed_modules="$iek_installed_modules $iek_dest_module"
		$CP -uf $iek_extmod $HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE/$iek_dest_module # cp -u 表示只拷贝比目标文件更新的文件
	done

	pushd $HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE >/dev/null

	ECHO "Generating modules dependency ..."
	$DEPMOD -ae -b ./ -r -F $HCM_DESTDIR/$HCM_SDKDIR_KBUILD/System.map $HCM_KERNEL_RELEASE

	for iek_extmod in $iek_installed_modules
	do
		iek_depend_info=`grep "^$iek_extmod:" < $HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE/$HCM_INROOTFS_DEPKMOD/modules.dep | sed "s/\://"`
		for iek_extmod in $iek_depend_info
		do
			$CP -uf --parents .$iek_extmod $iek_install_base/
			[ x$cfg_install_strip == xyes ] && $HCM_CROSS_COMPILE-strip $iek_install_base$ikm_kmod -g -S -d

		done
	done

	popd >/dev/null
}

# 安装内核模块
# $1: dest rootfs based
# $2: module list
install_kernel_module()
{
	local ikm_kmod_resdir=$HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE
	local ikm_install_basedir=
	local ikm_kmod=

	pushd $1 >/dev/null
	ikm_install_basedir=$PWD
	popd  >/dev/null

	pushd $ikm_kmod_resdir >/dev/null
	$DEPMOD -ae -b ./ -r -F $HCM_DESTDIR/$HCM_SDKDIR_KBUILD/System.map $HCM_KERNEL_RELEASE

	while read ikm_kmod
	do
		ikm_depend_info=`grep "^$ikm_kmod:" < $HCM_DESTDIR/$HCM_KERNEL_INSTALL_RESOURCE/$HCM_INROOTFS_DEPKMOD/modules.dep | sed "s/\://"`
		for ikm_kmod in $ikm_depend_info
		do
			$CP -uf --parents .$ikm_kmod $ikm_install_basedir
			[ x$cfg_install_strip == xyes ] && $HCM_CROSS_COMPILE-strip $ikm_install_basedir$ikm_kmod -g -S -d
		done
	done << EOF
	`pushd $HCM_INROOTFS_KERNMOD >/dev/null; \
		eval find "$2" -type f -printf \"/$HCM_INROOTFS_KERNMOD/%p\\\n\"; \
		popd >/dev/null`
EOF

	popd >/dev/null
}

# 将字符串中的非法字符替换为 _ 符合变量名的规则
string_to_varname()
{
	echo "$1" | sed 's/[^a-zA-Z0-9_]/_/g'
}

patchset_get_param()
{
	echo "$1" | cut -d')' -f1 | sed 's/[\(\|]/ /g' # cut -d 指定分隔符分隔字符串
}

patchset_get_name()
{
	echo "$file" | cut -d')' -f2
}


#!/bin/bash

export autobaksql=1

# 设置语言环境
LANG="zh_CN.UTF-8"
export LANG

# 获取系统信息
W=$(getconf LONG_BIT)
export W

# 读取CentOS版本信息
centos=$(grep -Eos '\b[0-9]+\S*\b' /etc/redhat-release)
export centos

# 提取CentOS主版本号
XT=$(grep -Eos '\b[0-9]+\S*\b' /etc/redhat-release | cut -d'.' -f1)
export XT

# 获取CPU型号信息
CPU=$(grep 'model name' /proc/cpuinfo | uniq | awk -F : '{print $2}' | sed 's/^[ \t]*//g' | sed 's/ \+/ /g')
export CPU

# 获取物理CPU数量
H=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
export H

# 获取CPU核心数
HX=$(grep -c "core id" /proc/cpuinfo)
export HX

# 获取根分区使用情况
DD=$(df -h /)
export DD

# 计算内存总量（GB）
G=$(awk '/MemTotal/{printf("%1.f\n",$2/1024/1024)}' /proc/meminfo)
export G

# 获取MySQL版本
mysql_version=$(mysql -V 2>/dev/null | grep -oP 'Distrib \K[0-9.]+' || true)
export mysql_version

# 配置文件路径
export conf=/etc/httpd/conf/httpd.conf
# MySQL数据目录
export mysqld=/var/lib/mysql/
# 交换分区路径
export swap_part="/var/dofswap"
# 定义颜色代码（s表示粗体）
export red="\e[31m"
export reds="\e[31;1m"
export green="\e[32m"
export greens="\e[32;1m"
export yellow="\e[33m"
export yellows="\e[33;1m"
export blue="\e[36m"
export blues="\e[36;1m"
export purple="\e[35m"
export purples="\e[35;1m"
# 黑色文字,青色背景,闪烁效果
export black_cyan_blink="\e[30;46;5m"
# 青色文字,绿色背景,加粗效果
export cyan_green_bold="\e[36;42;1m"
export font="\e[0m"
# 定义状态提示
export new="${reds} New${font}"
export load="${yellow} loading...${font} "
export info="${yellows}[信息]${font} "
export characters="${greens}[通知]${font} "
export error="${reds}[错误]${font}"
export tip="${blues}[提示]${font} "
export warn="${reds}[警告]${font} "
export determine="${blues}[输入]${font} "
export success="${green} success ${font}"
	
# 设置脚本标题
export shelltitle="${reds}		     CentOS云端一键架设脚本${font}"

# 定义服务器地址
primary_server="XX.XX.XX.XX"
backup_server="XX.XX.XX.XX"

# 批量获取远程配置
declare -A configs=(
    ["Url"]="Url.php"
    ["mysqlsetup"]="mysqlsetup.php"
    ["udp_php"]="udp.php" 
    ["OssUrl"]="OssUrl.php"
    ["notice"]="notice.php"
)

# 处理配置项
for name in "${!configs[@]}"; do
    value=$(curl -s --max-time 1 "${primary_server}/${configs[$name]}" || 
            curl -s "${backup_server}/${configs[$name]}")
    export "$name=$value"
done

Memory_bytes=${Memory_bytes:-89520}
export Memory_bytes
# 如果需要从远程获取则再次尝试
[ "$Memory_bytes" = "89520" ] && Memory_bytes=$(curl -s "${backup_server}/Memory_bytes.php")

# 简化获取IP的逻辑
ip_sources=("ip.sb" "ifconfig.co" "ipecho.net/plain")
for source in "${ip_sources[@]}"; do
	IP=$(curl -s "http://${source}")
    export IP
    [[ "${IP}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && break
    echo -e "获取IP失败,尝试下一源:${source}"
done

# 定义分隔线和提示
export Separator="${greens}======================================================================${font}"
export input="${yellow}================================[开始]================================${font} "
export inputs="${yellow}================================[结束]================================${font} "
	
# 设置PATH环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/usr/local/mysql/bin:/usr/bin/mysql
# 随机字符集,用于生成密码等
export CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890123456789.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+.-@%^*=+"

# 配置curl安全参数
if [ ! -f "/etc/.curlrc" ] || ! grep -q "insecure" "/etc/.curlrc"; then
    echo "insecure" >> /etc/.curlrc
fi

# 更新模块已移除, 请自行添加
#---------------------------	
# 版本号
# Version="1.0"
# export Version
	
# 在这里放入你的更新地址
# newVersionUrl="xxx.com/"
# export newVersionUrl

# 在这里放入你的版本检测链接	
# newVersion=$(curl -s xxx.com/version)
# export newVersion
#---------------------------

# 显示脚本警告提示信息
function setupLogo() {
    echo -e "
  DDDDDDDDDDDDD          OOOOOOOOO          FFFFFFFFFFFFFFFFFFFFFF
  D::::::::::::DDD     OO:::::::::OO        F::::::::::::::::::::F
  D:::::::::::::::DD OO:::::::::::::OO      F::::::::::::::::::::F
  DDD:::::DDDDD:::::DO:::::::OOO:::::::O    FF::::::FFFFFFFFF::::F
    D:::::D    D:::::DO::::::O   O::::::O     F:::::F       FFFFFF
    D:::::D     D:::::DO:::::O     O:::::O     F:::::F
    D:::::D     D:::::DO:::::O     O:::::O     F::::::FFFFFFFFFF
    D:::::D     D:::::DO:::::O     O:::::O     F:::::::::::::::F
    D:::::D     D:::::DO:::::O     O:::::O     F:::::::::::::::F
    D:::::D     D:::::DO:::::O     O:::::O     F::::::FFFFFFFFFF
    D:::::D     D:::::DO:::::O     O:::::O     F:::::F
    D:::::D    D:::::DO::::::O   O::::::O      F:::::F
  DDD:::::DDDDD:::::DO:::::::OOO:::::::O    FF:::::::FF
  D:::::::::::::::DD OO:::::::::::::OO      F::::::::FF
  D::::::::::::DDD     OO:::::::::OO        F::::::::FF
  DDDDDDDDDDDDD          OOOOOOOOO          FFFFFFFFFFF"
	echo -e "${warn}${reds}该脚本仅提供测试便利,请勿用于违法违规用途,出现任何问题与作者无关!后果自负!${font}"
}

# 主函数
function main() {
	# 调用线路检测函数
	lineInspection
}

# 线路检测与环境检查函数
function lineInspection() {
	clear
	
	# 显示通知信息
	if [[ -n "${notice}" ]]; then
		echo -e "${input}"
		echo -e "${characters}${yellows}${notice}${font}"
		echo -e "${inputs}"
		echo -n -e "${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"
		read -r digit </dev/tty
		if [[ -z ${digit} ]]; then
			echo
		fi
	fi
	
	# 创建MySQL备份目录
	echo -e "${input}"
	if [ ! -d "/root/mysqlbak/" ]; then
		mkdir -p "/root/mysqlbak/"
	fi
	
	# 检查是否为root用户
	if [[ "$(id -u)" -ne 0 ]]; then
		echo -e "${reds}抱歉,当前非root账户,没有权限运行此脚本!${font}"
		echo -e "${Separator}"
		exit 1
	fi
	
	# 配置MySQL客户端配置
	config_file="/etc/my.cnf"
	if [ -e "$config_file" ]; then
		if grep -qF "[client]" "$config_file"; then
			if ! grep -q 'user=game' "$config_file"; then
				sed -i '/\[client\]/a\user=game' "$config_file"
			fi
			if ! grep -q 'password=uu5!^%jg' "$config_file"; then
				sed -i '/\[client\]/a\password=uu5!^%jg' "$config_file"
			fi
			if ! grep -q 'host=127.0.0.1' "$config_file"; then
				sed -i '/\[client\]/a\host=127.0.0.1' "$config_file"
			fi
		else
			echo -e "[client]\nuser=game\npassword=uu5!^%jg\nhost=127.0.0.1" >> "$config_file"
		fi
	fi
	
	# 检查软件仓库
	if [[ -e /etc/yum.repos.d/CentOS-Base.repo ]]; then
		rm -rf /run/yum.pid >/dev/null 2>&1
		echo -e "${greens}[通过] ${blues}软件仓库齐全${font}"
	else
		echo -e "${reds}[未通过] ${blues}软件仓库为空,开始安装${font}"
		echo -e "${Separator}"
		curl -# -L -o /etc/yum.repos.d/CentOS-Base.repo "${Url}yum/Centos-${XT}.repo"
		echo -e "${greens}[通过] ${blues}软件仓库齐全${font}"
	fi
	
	# 检查wget工具
	if command -v wget &>/dev/null; then
		echo -e "${greens}[通过] ${blues}wget下载工具已安装${font}"
	else
		echo -e "${reds}[未通过] ${blues}wget下载工具未安装,开始安装。${font}"
		echo -e "${Separator}"
		yum install -y wget
		sleep 1
		if command -v wget &>/dev/null; then
			echo -e "${greens}[通过] ${blues}wget下载工具已安装${font}"
		else
			clear
			echo -e "${reds}[未通过] 开始尝试修复软件源配置!${font}"
			echo -e "${Separator}"
			sudo rm -rf /etc/yum.repos.d/*
			curl -# -L -o /etc/yum.repos.d/CentOS-Base.repo "${Url}yum/Centos-${XT}.repo"
			yum install -y wget
			if command -v wget &>/dev/null; then
				echo -e "${greens}[通过] ${blues}wget下载工具已安装${font}"
			else
				clear
				echo -e "${reds}[未通过] 多次尝试安装 wget 工具失败!${font}"
				echo -e "${yellows}请反馈以下内容:安装wget工具失败!${font}"
				echo -e "${Separator}"
				exit
			fi
		fi
	fi
	
	# 创建游戏路径快捷方式
	if [ -d "/home/neople/game/" ] >/dev/null 2>&1; then
		sudo ln -s /home/neople/game /root >/dev/null 2>&1
		sudo ln -s /root /home/neople/game >/dev/null 2>&1
		echo -e "${info}${blues}创建root -> game快捷方式!${font}"
	else
		sleep 1
	fi
	
	# 检测主线路状态
	Line=$(wget -qO- --no-check-certificate "${Url}Line")
	if [ "$Line" = "yes" ]; then
		echo -e "${info}${blues}主线路正常${font}"
	else
		echo -e "${error}${reds}主线路检测异常,开始切换检测方式!${font}"
		wget --no-check-certificate -q -O /tmp/Lines "${Url}Lines" >/dev/null 2>&1
		Lines=$(stat -c %s "/tmp/Lines")
		sleep 1
		if [ "$Lines" -gt 150000 ]; then
			echo -e "${info}${blues}主线路正常${font}"
			sleep 1
			displayLogo
			return
		fi
		echo -e "${error}${red}确认主线路异常, 启用备用线路!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"
		read -r digit </dev/tty
		if [[ -z ${digit} ]]; then
			echo
		fi
		Url="${OssUrl:-$backup_server}"
		export Url
	fi
	
	# 检查系统用户安全, 按需开启
	# LAST_USER=$(cut -d ':' -f 1 /etc/passwd | tail -n 1)
	# if [ -d "/home/neople/game/cfg/" ]; then
		# if [[ $LAST_USER != "mysql" && $LAST_USER != "apache" && $LAST_USER != "ntp" && $LAST_USER != "mailnull" && $LAST_USER != "smmsp" && $LAST_USER != "tss" ]]; then
		#	echo -e "${warn}${red}当前服务器可能被提权了,请检查!${font}"
		#	echo -e "${Separator}"
		#	sleep 3
		# fi
	# fi
	
	# 检查MySQL用户安全
	# if command -v mysql >/dev/null 2>&1; then
	#	QUERY_RESULT=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "SELECT user, host FROM mysql.user;") >/dev/null 2>&1
	# fi
	
	# USER_COUNT=$(echo "${QUERY_RESULT}" | wc -l) >/dev/null 2>&1
	
	# 分析MySQL用户
	# for ((i=2; i<=USER_COUNT; i++)); do  # 从第二行开始,第一行是表头
	#	USER_INFO=$(echo "${QUERY_RESULT}" | awk -v line="$i" 'NR==line{print}')
	#	MYSQL_USER_RESULT[i]=$(echo "${USER_INFO}" | awk '{print $1}')
	#	MYSQL_HOST_RESULT[i]=$(echo "${USER_INFO}" | awk '{print $2}')
	# done
	
	# 正确声明数组变量
	# declare -a MYSQL_USER_RESULT
	# declare -a MYSQL_HOST_RESULT
	
	# 检查未授权的MySQL用户
	# for ((i=2; i<=USER_COUNT; i++)); do
	#	if [[ "${MYSQL_USER_RESULT[i]}" != "game" ]]; then
	#		echo -e "${warn}${red}发现未授权的MySQL用户 '${MYSQL_USER_RESULT[i]}',请检查是否被提权!${font}"
	#		echo -e "${Separator}"
	#		sleep 1
	#	fi
	# done
	
	# 检查IP配置是否一致
	if ls /home/neople/game/cfg/*.cfg 1> /dev/null 2>&1; then
		ipn=$(grep "udp_ip_of_hades = " /home/neople/game/cfg/siroco12.cfg 2>/dev/null | grep -P "[0-9.]+" -o)
		
		if [[ ${ipn} == *"192.168"* ]]; then
			:  # 本地IP,无需处理
		elif [[ ${IP} != "${ipn}" ]]; then
			echo -e "${warn}${red}当前服务端IP为[${ipn}]与实际不符,加盾请无视!${font}"
		fi
	fi
	
	# 检查内存大小
	if [[ ${G} -lt "3" ]]; then
		echo -e "${warn}${red}当前服务器内存过小,可能导致127和不出频道问题
		如有上述情况,请多次尝试五国!${font}"
		sleep 3
	fi
	
	# 内存优化程序管理
	file_path="/root/dof/Memory"
	if [ -e "$file_path" ]; then
		insert_str="/root/run"
		search_str="cd /root/dof >/dev/null 2>&1 && ./Memory &"
		
		temp_file=$(mktemp)
		
		if ! grep -qF "$search_str" "$insert_str"; then
			awk -v insert="$search_str" '
			/cd \/home\/neople\/game/ {print insert}
			{print}
			' "$insert_str" > "$temp_file"
			
			mv "$temp_file" "$insert_str"
			chmod 777 /root/run
		fi
		
		file_size=$(stat -c %s "$file_path")
		if [ "$file_size" -eq "$Memory_bytes" ]; then
			:  # 文件大小正确,无需更新
		else
			echo -e "${warn}${red}内存优化程序不是最新版, 正在更新!${font}"
			sleep 1
			wget --no-check-certificate -q -O "$file_path" "${Url}Memory" >/dev/null 2>&1
			echo -e "${tip}${yellows}更新完成,内存优化程序已经是最新版!${font}"
			sleep 1
		fi
	fi
	
	# 检查备份配置
	if grep -q './sql' /etc/cron.hourly/back >/dev/null 2>&1; then
		Backup_display="\e[33;1m已开启\e[0m"
	else
		Backup_display="\e[31;1m未开启\e[0m"
	fi
	export Backup_display
	
	if grep -q './cloudscp' /etc/cron.hourly/back >/dev/null 2>&1; then
		Backup_display="\e[33;1m已开启云端\e[0m"
		export Backup_display
	fi
	
	# 检查服务器时间同步
	timestamp1=$(date +"%s")
	# 尝试从外部服务器获取时间戳，设置5秒连接超时
	timestamp2=$(curl --silent --connect-timeout 5 XX.XX.XX.XX/timestamp.php)
	
	# 验证 timestamp2 是否为有效的整数
	if [[ "$timestamp2" =~ ^[0-9]+$ ]]; then
		# 计算时间差
		difference=$((timestamp1 - timestamp2))
		# 检查时间差是否大于300秒（5分钟）
		if [[ "$difference" -gt 300 || "$difference" -lt -300 ]]; then
			echo -e "${tip}${yellows}当前服务器时间为: $(date "+%Y-%m-%d %H:%M:%S") ${font}"
			echo -e "${warn}${reds}当前服务器时间与网络时间偏差超过5分钟, 开始校对!${font}"
			timeCheck
		fi
	else
		# 如果获取的时间戳无效，则打印警告信息
		echo -e "${warn}${reds}无法从时间服务器获取有效的时间戳。收到的内容: '$timestamp2'${font}"
	fi

	# 确保dof目录存在
	if [ ! -d "/root/dof" ]; then
		mkdir -p /root/dof
	fi

	# 调用logo函数
	displayLogo
 }

 # 显示脚本Logo和创建快捷方式脚本
 function displayLogo() {
 	shortcut=${shortcut:-no}
 
 	# 设置日志目录权限
 	chmod -w /home/neople/secsvr/zergsvr/log/ >/dev/null 2>&1

 	# 显示脚本结束标记
 	echo -e "${inputs}"
 	echo
 
 	# 显示免责声明
 	if [[ ${shortcut} != yes ]]; then
 		# 检查是否在交互式终端中运行并且可以读取 /dev/tty
 		echo -e "${reds}该脚本仅提供测试便利,请勿用于违法违规用途,出现任何问题与作者无关!后果自负!${font}"
 		echo
 		echo -n -e "${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"
 		read -r digit </dev/tty
 		if [[ -z ${digit} ]]; then
 			echo
 		fi

 		# 创建快捷方式脚本（减号）- 用于快速访问常用命令
 		chattr -i /usr/sbin/- >/dev/null 2>&1
 		rm -rf /usr/sbin/- >/dev/null 2>&1
 		cat <<EOF | sudo tee /usr/sbin/- >/dev/null
#!/bin/bash

function main() {
	export shortcut=yes
	cd /root/ || exit
	./y
	cd || exit
}
main
EOF
 		
 		# 创建快捷五国脚本（加号）- 用于快速执行服务器重启
 		chattr -i /usr/sbin/+ >/dev/null 2>&1
 		rm -rf /usr/sbin/+ >/dev/null 2>&1
 		cat <<EOF | sudo tee /usr/sbin/+ >/dev/null
#!/bin/bash
#启动
function startServer() {
	export red="\e[31m"
	export reds="\e[31;1m"
	export green="\e[32m"
	export greens="\e[32;1m"
	export yellow="\e[33m"
	export yellows="\e[33;1m"
	export blue="\e[36m"
	export blues="\e[36;1m"
	export purple="\e[35m"
	export purples="\e[35m;1m"	
	export font="\e[0m"
	export load="\${yellow} loading...\${font} "
	export info="\${green}[信息]\${font} "
	export error="\${red}[错误]\${font}"
	export tip="\${blue}[提示]\${font} "
	export success="\${green} success \${font}"
	export input="\${yellow}[输入开始]\${font} "
	export inputs="\${yellow}[输入结束]\${font} "
	export DNF_DIR="/home/neople/"
	export DNF_PATH="\${DNF_DIR}game"
	export daemon="./df_game_r siroco12"
	export init_files=\$(find /home/neople/game/log/ -type f \( -name "*.init" -o -name "*.cri" \))
	export XTG=\$(awk '/MemTotal/{printf("%1.f\n",\$2/1024/1024)}' /proc/meminfo)

	export file_size=\$(stat --format="%s" /home/neople/game/Script.pvf)
	export file_size_mb=\$((file_size / 1024 / 1024))
	if [ "\$file_size_mb" -lt 180 ]; then
		export file_size_mb=60
	fi

	if [ \${XTG} -ge 31 ]; then
		export time=\$((file_size_mb / 100))
	elif [ \${XTG} -ge 15 ]; then
		export time=\$((file_size_mb / 90))
	elif [ \${XTG} -ge 7 ]; then
		export time=\$((file_size_mb / 80))
	elif [ \${XTG} -ge 3 ]; then
		export time=\$((file_size_mb / 70))
	elif [ \${XTG} -ge 1 ]; then
		export time=\$((file_size_mb / 60))
	fi
	if [ "\$time" == 0 ]; then
		export time=1
	fi

clear
	echo -e "\${input}=================================================="
	echo -e "\e[36m数据不会回滚且会在游戏内发布通知"
	read -r -p "请输入多少分钟以后跑五国(回车则默认立即):" run
	echo -e "\${inputs}=================================================="
	echo
	chmod -R 0777 /root/run >/dev/null 2>&1
	run=\${run}
	if [[ -z \${run} ]]; then
		rundata=1
	else
		rundata=\$((\${run}*60))
	fi

for file in \$init_files; do
    if grep -q "Monitor Server Connected" "\$file"; then
		dnf_endtime=\$(date -d "+\${run} minute" "+%Y-%m-%d %H:%M:%S")
		export mess="游戏将于[\${dnf_endtime}]开始维护,敬请期待!"
		echo -e "\$mess"
		cd "\$DNF_PATH"
		if grep -q "weihu" "/dp2/df_game_r.js"; then >/dev/null 2>&1
			sed -i "s|var weihu_mess =.*|var weihu_mess = '\${mess}'|g" /dp2/df_game_r.js
			sed -i 's|var tongzhi = 0;|var tongzhi = 1;|g' /dp2/df_game_r.js
			sed -i 's|var tongzhi = 2;|var tongzhi = 1;|g' /dp2/df_game_r.js
			sed -i 's|var weihu = 1;|var weihu = 0;|g' /dp2/df_game_r.js
			sed -i 's|var weihu = 2;|var weihu = 0;|g' /dp2/df_game_r.js
			sed -i 's|//api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|g' /dp2/df_game_r.js
			sed -i 's|//api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|g' /dp2/df_game_r.js
		fi
		break
    fi
done
	run
}

#启动
function run() {
	sleep 1s
	clear

	if grep -q "weihu" "/dp2/df_game_r.js"; then >/dev/null 2>&1
		if [[ \${rundata} = 1 ]]; then
		sed -i 's|var weihu_mess =.*|var weihu_mess = '\''游戏即将开始维护,敬请期待!'\''|g' /dp2/df_game_r.js
		sed -i 's|var tongzhi = 1;|var tongzhi = 0;|g' /dp2/df_game_r.js
		sed -i 's|var tongzhi = 2;|var tongzhi = 0;|g' /dp2/df_game_r.js
		sed -i 's|var weihu = 0;|var weihu = 1;|g' /dp2/df_game_r.js
		echo -e "[dp2专享]正在踢出玩家!"
		sleep 5s
		fi
	fi

	((rundata--))

	if [[ \${rundata} -eq 0 ]]; then
	sed -i 's|var weihu = 1;|var weihu = 0;|g' /dp2/df_game_r.js
	sed -i 's|var weihu = 2;|var weihu = 0;|g' /dp2/df_game_r.js
	sed -i 's|api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|//api_scheduleOnMainThread_delay(game_weihu1, null, 1000);|g' /dp2/df_game_r.js
	dnf_endtime=\$(date "+%Y-%m-%d %H:%M:%S")

	processes=(
	"df_stun_r"
	"df_monitor_r"
	"df_manager_r"
	"df_relay_r"
	"df_bridge_r"
	"df_channel_r"
	"df_dbmw_r"
	"df_auction_r"
	"df_point_r"
	"df_guild_r"
	"df_statics_r"
	"df_coserver_r"
	"df_community_r"
	"gunnersvr"
	"zergsvr"
	"df_game_r"
	"secagent"
	"df_monitor_P_r"
	"df_guild_P_r"
	"df_statics_P_r"
	)

	mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "FLUSH TABLES;"

	for process in "\${processes[@]}"
	do
		killall -9 "\$process"
	done
	find \${DNF_DIR} \( -name '*.log' -o -name '*.pid' -o -name 'core.*' -o -name '*.cri' -o -name '*.debug' -o -name '*.error' -o -name '*.init' -o -name '*.snap' \) -type f -print -exec rm -rf {} \;

	cd;./run
	exit
	fi
	echo -e "重跑五国剩余时间: \${rundata}秒"
	run
}
startServer
EOF
		
		# 创建数据库备份脚本
		chattr -i /root/dof/sql >/dev/null 2>&1
		rm -rf /root/dof/sql >/dev/null 2>&1
		cat <<EOF | tee /root/dof/sql >/dev/null
#!/bin/bash

function main() {
	export BACKUP=/root/mysqlbak/
	export MAX_FILES=10
	export MAX_AGE=10
	export num_files=\$(ls -l "\${BACKUP}" | grep "^-" | wc -l)
	export time=\$(date +%m%d%H)
	export dataname=dnf.sql
	export reds="\e[31;1m"
	export greens="\e[32;1m"
	export yellows="\e[33;1m"
	export blues="\e[36;1m"
	export info="\${yellows}[信息]\${font} "
	export error="\${reds}[错误]\${font}"
	export tip="\${blues}[提示]\${font} "
	export font="\e[0m"
	export IP=\$(wget -qO - ifconfig.co)
	mysqlbk
}

function mysqlbk() {
	IP=\${IP:-127.0.0.1}
	[ ! -d "\${BACKUP}" ] && mkdir -p "\${BACKUP}"
	cd /\${BACKUP}
	echo -e "\${tip}\${greens}备份数据库\${dataname} 进行中!请耐心等待~\${font}"
	mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "show databases"| grep -Ev "Database|information_schema|mysql|test|performance_schema"| xargs mysqldump --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -R -B --default-character-set=utf8 --databases > \${dataname} && echo -e "\${info}\${greens}\${dataname} 数据库备份成功,正在压缩文件,请稍候~\${font}" || echo -e "\${error}\${reds}\${dataname} 数据库备份失败~\${font}"
	dnfsqlsize=\$(du -b /root/mysqlbak/dnf.sql | awk '{print \$1}')
	if [ \$dnfsqlsize -gt 100000 ]; then
		sleep 1
	else
		echo -e "\${error}\${reds}脚本运行结束!请检查数据库是否能正常连接。\${font}"
		exit
	fi
	tar -zcPf \sql_\${IP}_\${time}.tar.gz \${BACKUP}\${dataname}
	rm -rf \${BACKUP}\${dataname}
	echo -e "\${info}\${greens}压缩完成,位置[/root/mysqlbak/sql_\${IP}_\${time}.tar.gz]\${font}"
	find \${BACKUP} -mtime +\${MAX_AGE} -name "*.tar.gz" -exec rm {} \;
	if [ \$num_files -gt \$((\${MAX_FILES} * 2)) ]; then
	oldest_files=\$(ls -1t "\${BACKUP}" | tail -n2)
	if [ -n "\${oldest_files}" ]; then
		rm \${BACKUP}/\${oldest_files}
	fi
	echo -e "\${tip}\${greens}检查到目录内文件数超过储存上限2倍,已删除最早的两个。\${font}"
	elif [ \$num_files -gt \$MAX_FILES ]; then
	oldest_file=\$(ls -1t "\${BACKUP}" | tail -n1)
	if [ -n "\${oldest_file}" ]; then
		rm "\${BACKUP}/\${oldest_file}"
	fi
	echo -e "\${tip}\${greens}检查到目录内文件数超过储存上限,已删除最早的一个。\${font}"
	fi
}
main
EOF
		
		# 更新MOTD信息（登录信息）
		chattr -i /etc/motd >/dev/null 2>&1
		echo -e " -- 输入减号回车进入[常用指令] --\n -- 输入加号回车进入[快捷五国] --" | sudo tee /etc/motd >/dev/null
		chattr +i /etc/motd >/dev/null 2>&1
	fi
	
	# 设置脚本权限
	chmod 777 /usr/sbin/- >/dev/null 2>&1
	chmod 777 /usr/sbin/+ >/dev/null 2>&1
	chmod 777 /root/dof/sql >/dev/null 2>&1
	
	# 清屏并显示主菜单
	clear
	startMenu
}

# 主菜单函数,显示脚本操作选项
function startMenu() {
	# 声明变量
	local num
	local yes_and_no
	local password_modification
	local password_1
	local password_2
	local random_string
	local ggsjkzh
	local zdip
	local xsjkmm
	local user_exists
	local result
	
	# 检查MySQL状态
	mysqlChecks
	
	clear
	echo -e "${shelltitle}
${Separator}
${reds}(1)${font} ${greens}[安装服务端运行环境(独立端内存优化版)]${font}
${reds}(2)${font} ${greens}[数据备份与还原(支持云端)]${font}
${reds}(3)${font} ${greens}[${red}更改${blues}<服务器>${greens}密码(自定义/随机)]${font}
${reds}(4)${font} ${greens}[${red}更改${yellow}<数据库>${greens}密码(自定义/随机)]${font}
${reds}(5)${font} ${blues}[防卡|商城|点券|代币|阈值设定|${reds}防卡Npc商店]${font}
${reds}(6)${font} ${yellows}[开启拍卖/寄售/修复乱码]不需要五国${blues}<有选项>${font}
${reds}(7)${font} ${greens}[服务器/数据库垃圾清理<优化运行|减少卡顿>]${blues}<有选项>${font}
${reds}(8)${font} ${yellows}[UDP项目(组队转发、防炸内存)]${font}
${reds}(9)${font} ${greens}[安装DP/Frida插件(深渊播报多黄奖励等等)]${blues}<有选项>${font}
${Separator}
${blues}自动备份[${font}${Backup_display}${blues}]${font}
${greens}[右侧字母翻页]${font}${reds}(a | b | c | d)${font}	 
${reds}(0)${font} ${black_cyan_blink}退出安装${font}	     ${reds}(m)${font}${purple}防提权等级补丁${font}     ${reds}(当前页:${font}${cyan_green_bold}[1]${font}${green} [2] [3] [4]${font}${reds})${font}
${greens}${blue}本机IP:${font}${greens}${IP}   ${blue}配置:${font}${greens}${HX}核 ${G}G   ${blue}镜像:${font}${greens}Centos${XT}   ${font}${greens}${blue}数据库版本:${font}${greens}${mysql_version}${font}${blue}"

	# 等待用户输入选择
	echo -n -e "${determine}${yellow}数字 [0-9]:${font}"
	read -r num </dev/tty
	
	# 根据用户选择执行相应功能
	case "${num}" in
	1)
		clear
		# 检查系统版本是否支持
		if [[ $XT != 6 && $XT != 7 ]]; then
			echo -e "${shelltitle}"
			echo
			echo -e "${red}抱歉,暂时不支持Centos${XT}系统搭建!"
			sleep 2
			startMenu
			return
		fi

		# 检查是否已安装环境
		if [ -d "/home/neople/game/cfg/" ]; then
			echo -e "${tip}${greens}当前服务器可能已经安装好了相关环境${font}"
			echo -e "${warn}${reds}继续安装会清除所有数据!${font}"
			echo -n -e "${determine}${yellow}确定要继续吗？[输入确定后继续]${font}"
			read -r yes_and_no </dev/tty
			if [[ "$yes_and_no" != "确定" ]]; then
				echo -e "${green}已取消!${font}"
				sleep 2
				startMenu
				return
			fi
		fi
		
		# 这里应该调用安装环境的函数
		checkSys
		;;
	2)
		# 调用数据库备份功能
		mysqlBackups
		;;
	3)
		# 生成随机密码
		random_string=$(echo "$CHARS" | fold -w1 | shuf | tr -d '\n' | head -c8)
		
		clear
		echo -e "${input}"
		echo -e "${warn}${red}账号,账号啊,这他妈是账号,求求你别填IP了,实在不懂就直接回车!${font}"
		echo -e "${tip}直接回车则默认${red}root${font}"
		echo -n -e "${determine}${yellow}要更改的服务器账号:${font}"
		read -r password_modification </dev/tty
		
		# 设置默认账号为root
		if [[ -z ${password_modification} ]]; then
			password_modification=root
		fi
		
		echo -e "${Separator}"
		echo -e "${tip}直接回车则默认${red}随机${font}"
		echo -n -e "${determine}${yellow}请首次输入要更改的服务器密码:${font}"
		read -r password_1 </dev/tty
		
		# 处理随机密码情况
		if [[ -z ${password_1} ]]; then
			password_1=${random_string}
			cd || exit
			echo -e "${password_modification}:${password_1}" | chpasswd
			result=$?
			if [[ ${result} -eq 0 ]]; then
				echo -e "${greens}[服务器地址]${IP}${font}"
				echo -e "${greens}[服务器账号]${password_modification}${font}"
				echo -e "${greens}[服务器密码]${password_1}${font}"
				echo -e "${info}${greens}密码信息修改成功,请重新登录后再关闭此界面!${font}"
			else
				echo -e "${error}${reds}密码信息修改失败!${font}"
			fi
			echo -e "${inputs}"
			return
		fi
		
		# 二次确认密码
		echo -e "${Separator}"
		echo -n -e "${determine}${yellow}请再次输入要更改的服务器密码:${font}"
		read -r password_2 </dev/tty
		
		# 设置默认值
		if [[ -z ${password_2} ]]; then
			password_2=456789
		fi
		
		# 检查两次密码是否一致
		if [[ ${password_1} != "${password_2}" ]]; then
			echo -e "${error}${reds}两次输入不一致!请重试。${font}"
			echo -e "${inputs}"
			return
		fi
		
		# 更改密码
		cd || exit
		echo -e "${password_modification}:${password_2}" | chpasswd
		result=$?
		
		# 显示结果
		if [[ ${result} -eq 0 ]]; then
			echo -e "${Separator}"
			echo -e "${greens}[服务器地址]${IP}${font}"
			echo -e "${greens}[服务器账号]${password_modification}${font}"
			echo -e "${greens}[服务器密码]${password_1}${font}"
			echo -e "${info}${greens}密码信息修改成功,请重新登录后再关闭此界面!${font}"
		else
			echo -e "${error}${reds}密码信息修改失败!${font}"
			echo -e "${inputs}"
		fi
		;;
	4)
		# MySQL状态检查
		mysqlCheck
		
		# 生成随机密码
		random_string=$(echo "$CHARS" | fold -w1 | shuf | tr -d '\n' | head -c8)
		
		clear
		echo -e "${input}"
		echo -e "${warn}${red}账号,账号啊,这他妈是账号,求求你别填IP了,实在不懂就直接回车!${font}"
		echo -e "${tip}直接回车则默认${red}game${font}"
		echo -n -e "${determine}${yellow}需要更改密码的数据库账号 :${font}"
		read -r ggsjkzh </dev/tty
		
		# 设置默认账号为game
		if [[ -z ${ggsjkzh} ]]; then
			ggsjkzh=game
		fi
		
		echo -e "${Separator}"
		echo -e "${warn}${red}不懂就直接回车就完了,新手别动!${font}"
		echo -e "${tip}直接回车则默认${red}不指定${font}"
		echo -e "${tip}如果使用了d页4的指定IP权限功能则需要填写IP,否则无视${font}"
		echo -n -e "${determine}${yellow}主机:${font}"
		read -r zdip </dev/tty
		
		# 设置默认主机为通配符
		if [[ -z ${zdip} ]]; then
			zdip=%
		fi
		
		# 检查用户是否存在
		result=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "
			SELECT COUNT(*) FROM mysql.user WHERE User = '${ggsjkzh}' AND Host = '${zdip}';
		")

		user_exists=$(echo "$result" | tail -n +2)

		if [[ $user_exists -eq 0 ]]; then
			echo -e "${error}${reds}用户或主机不存在,脚本结束。"
			exit 1
		else
			echo -e "${Separator}"
		fi
		
		# 获取新密码
		echo -e "${tip}直接回车则默认${red}随机${font}"
		echo -n -e "${determine}${yellow}新的数据库密码 :${font}"
		read -r xsjkmm </dev/tty
		
		# 设置默认为随机密码
		if [[ -z ${xsjkmm} ]]; then
			xsjkmm=${random_string}
		fi
		
		echo -e "${Separator}"
		
		# 更新MySQL密码
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "
			UPDATE mysql.user SET PASSWORD=PASSWORD('${xsjkmm}') WHERE User='${ggsjkzh}' and Host='${zdip}';
			flush privileges;
		" >/dev/null 2>&1
		
		# 检查执行结果并显示信息
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "SELECT 1;" >/dev/null 2>&1; then
			# 显示友好的主机名
			if [[ ${zdip} = % ]]; then
				zdip="不限制IP"
			fi
			
			echo -e "--------更改完成--------"
			echo -e "${greens}[可连接主机]${font}${zdip}"
			echo -e "${greens}[数据库地址]${font}${IP}"
			echo -e "${greens}[数据库账号]${font}${ggsjkzh}"
			echo -e "${greens}[数据库密码]${font}${xsjkmm}"
			echo -e "${inputs}"
		fi
		;;
	5)
		# 调用防卡功能
		countermeasure
		;;
	6)
		# 调用拍卖/寄售功能
		auctionConsignment
		;;
	7)
		# 调用优化功能
		reduceLag
		;;
	8)
		# 调用UDP项目
		udpProject
		;;
	9)
		# 调用DP/Frida插件安装
		manageDpPlugin
		;;
	m)
		# 调用防提权补丁
		ftqBd
		;;
	b)
		# 跳转到第二页菜单
		displaySystemMenu
		;;
	c)
		# 跳转到第三页菜单
		displayGameMenu
		;;
	d)
		# 跳转到第四页菜单
		displayAdvancedMenu
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		startMenu
		;;
	esac
}

# 系统管理菜单:显示服务器状态、账号管理和系统配置等功能
function displaySystemMenu() {
	# 声明本地变量
	local num
	local digit
	local ipn
	local xzip
	local iptables_output
	
	# 检查MySQL状态
	mysqlChecks
	
	clear
	echo -e "${shelltitle}
${Separator}
${reds}(1)${font} ${greens}[查看服务器内存占用]${font}
${reds}(2)${font} ${greens}[查看所有服务器账号]${new}${font}
${reds}(3)${font} ${yellows}[查看服务器被连接端口]${new}${font}
${reds}(4)${font} ${greens}[查看服务器近期登陆过的IP]${new}${font}
${reds}(5)${font} ${yellows}[安装专用优化版PHP<5.4>]${font}
${reds}(6)${font} ${greens}[更改Cfg频道文件连接IP(加盾时候用)]${font}
${reds}(7)${font} ${yellows}[黑名单(指定IP禁止连接服务器/数据库)]${blues}<有选项>${font}
${reds}(8)${font} ${greens}[校对服务器时间(北京时间)]${font}
${reds}(9)${font} ${reds}[卸载此功能菜单(对服务器和数据库无影响)]${font}
${Separator}
${blues}自动备份[${font}${Backup_display}${blues}]${font}	       	
${greens}${blues}[右侧字母翻页]${font} ${font}${reds}(a | b | c | d)${font}	 
${reds}(0)${font} ${black_cyan_blink}退出安装${font}	     ${reds}(m)${font}${purple}防提权等级补丁${font}     ${reds}(当前页:${font}${green}[1] ${cyan_green_bold}[2]${font}${green} [3] [4]${font}${reds})${font}
${greens}${blue}本机IP:${font}${greens}${IP}   ${blue}配置:${font}${greens}${HX}核 ${G}G   ${blue}镜像:${font}${greens}Centos${XT}   ${font}${greens}${blue}数据库版本:${font}${greens}${mysql_version}${font}${blue}"
	
	# 等待用户输入选择
	echo -n -e "${determine}${yellow}数字 [0-9]:${font}"
	read -r num </dev/tty
	
	# 根据用户选择执行相应操作
	case "${num}" in
	1)
		# 查看服务器内存占用情况
		clear
		echo -e "${input}"
		process_info=$(ps aux --sort -rss | awk '{print $6/1024/1024, $4, $11}' | awk 'NR>1' | head -n 15)
		total_memory=$(echo "$process_info" | awk '{sum += $1} END{print sum}')
		echo -e "${yellows}进程内存占用情况（前 15 个）:"
		echo
		printf "%-15s %-15s %-15s\n" "占用(GB)" "占用(%)" "      程序"
		echo "$process_info" | awk '{printf "%-15.2f %-15.1f %s\n", $1, $2, $3}' | sed 's|./||'
		echo -e "${Separator}"
		echo -e "${yellows}总内存占用: ${total_memory} GB${font}"
		echo -e "${inputs}"
		;;
	2)
		# 查看所有服务器账号并检测可能的提权
		clear
		if [[ -z ${digit} ]]; then
			echo
		fi
		echo -e "${input}"
		cut -d: -f1 /etc/passwd	
		echo -e "${inputs}"
		
		# 检测是否可能被提权
		LAST_USER=$(cut -d ':' -f 1 /etc/passwd | tail -n 1)
		if [ -d "/home/neople/game/cfg/" ]; then
			if [[ $LAST_USER != "mysql" && $LAST_USER != "apache" && $LAST_USER != "ntp" && $LAST_USER != "mailnull" && $LAST_USER != "smmsp" && $LAST_USER != "tss" ]]; then
				echo -e "${warn}${reds}结尾账号并不是mysql,当前服务器可能被提权了。${font}"
				echo -e "${info}${greens}可以通过更改服务器密码项目对结尾这个账号进行改密。${font}"
			else
				echo
			fi
		fi
		;;
	3)
		# 查看服务器被连接端口及IP
		clear
        echo -e "${input}"
		echo -e "${yellows}本机开启的端口和所有连接的IP地址:${font}"
		open_ports=$(netstat -tnl | awk '$4 ~ /:[0-9]+$/ && $4 !~ /:127.0.0.1:/ && $4 !~ /::1:/ {print substr($4, index($4, ":")+1)}' | sort -n | uniq)

		# 逐个端口检查连接的IP
		for port in $open_ports; do
			echo -e "${blues}端口 $port:${font}"
			# 使用mapfile存储IP列表,避免SC2207警告
			mapfile -t ip_list < <(netstat -tn | awk -v port="$port" '$4 ~ ":"port"$" && $5 !~ /^127\.0\.0\.1:/ {print $5}' | awk -F ":" '{print $1}' | sort | uniq)
			
			if [[ ${#ip_list[@]} -gt 0 ]]; then
				for ip in "${ip_list[@]}"; do
					echo -e "  $ip"
				done
			else
				echo -e "${greens}	当前端口暂无IP连接${font}"
			fi
			echo
		done
		Port_sends_data	
		;;
	4)
		# 查看服务器近期登录记录
		clear
        echo -e "${input}"
		# 分析成功登录记录
		awk '/Accepted/ {
			cmd="date -d \"" $1 " " $2 " " $3 "\" \"+%Y年%m月%d日 %H:%M:%S\"";
			cmd | getline date_formatted;
			close(cmd);
			print date_formatted, $(NF-3), $(NF-2), $(NF-1);
		}' /var/log/secure
		
		echo -e "${greens}${Separator}${font}"
		echo -e "${yellow}开始解析登录失败记录并进行整理,请稍候!${font}"
		
		# 分析失败登录尝试
		lastb_output=$(lastb)
		top_failed_logins=$(echo "$lastb_output" | awk '{
			ip_address = $3
			username = $1
			login_count[ip_address, username]++
		}

		END {
			for (key in login_count) {
				split(key, components, SUBSEP)
				ip = components[1]
				user = components[2]
				count = login_count[key]
				print user, count, ip
			}
		}' | sort -nr -k2 | head -5)
		
		echo -e "${greens}${Separator}${font}"
		echo -e "${reds}以下是尝试登录被拒绝,次数最多的前5个IP地址!"
		echo -e "${greens}${Separator}${font}"
		echo -e "用户  次数  IP地址"
		echo -e "$top_failed_logins${font}" | column -t
        echo -e "${inputs}"
		;;
	5)
		# 安装专用优化版PHP
		install_php
		;;
	6)
		# 更改Cfg频道文件连接IP
		# 使用grep从配置文件获取当前IP
		ipn=$(grep "udp_ip_of_hades = " /home/neople/game/cfg/siroco12.cfg | grep -P "[0-9.]+" -o)
		clear
		echo -e "${input}"
		echo -n -e "${determine}${yellow}需要把频道IP修改为:${font}"
		read -r xzip </dev/tty
		echo -e "${inputs}"
		echo
		
		# 检查是否输入了IP
		if [[ -z ${xzip} ]]; then
			echo -e "${error}${red}未输入IP,修正失败!"
		else
			echo -e "cfg现在IP地址为: ${ipn}"
			echo -e "cfg需要替换为IP: ${xzip}"
			echo
			echo -e "${yellow}如发现ip不正确,请不要替换!"
			echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"
			read -r digit </dev/tty
			if [[ -z ${digit} ]]; then
				echo
			fi
			
			# 执行替换操作
			cd /home/neople/ || exit
			sed -i "s/${ipn}/${xzip}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
			echo -e "替换完成,请手动检查 cfg文件中的ip是否正常${font}"
		fi
		;;
	7)
		# 黑名单功能（IP封禁）
		
		# 检查iptables是否可用
		if ! command -v iptables &>/dev/null; then
			echo -e "${error}${reds}检测1:未通过,开始安装!${font}"
			apt-get install -y iptables
		else
			echo -e "${tip}${greens}检测1:通过${font}"
		fi

		# 获取iptables版本信息
		iptables_output=$(iptables --version)
		if [ -z "$iptables_output" ]; then
			echo -e "${error}${reds}检测2:未通过,安装失败,该服务器暂不支持使用此功能!${font}"
		else
			echo -e "${tip}${greens}检测2:通过${font}"
		fi

		blacklist
		;;
	8)
		timeCheck
		;;
	9)
		# 卸载功能菜单
		chattr -i /etc/motd
		echo "" | sudo tee /etc/motd >/dev/null
		chattr -i /usr/sbin/-
		rm -rf /usr/sbin/-
		chattr -i /usr/sbin/-
		rm -rf /usr/sbin/+
		chattr -i /root/dof/sql
		chattr -i /root/dof/cloudscp
		rm -rf /root/dof
		rm -rf /root/y
		clear
		;;
	a)
		# 跳转到主菜单
		startMenu
		;;
	c)
		# 跳转到游戏菜单
		displayGameMenu
		;;
	d)
		# 跳转到高级菜单
		displayAdvancedMenu
		;;
	m)
		# 调用防提权补丁
		ftqBd
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		displaySystemMenu
		;;
	esac
}

# 游戏管理菜单:提供游戏相关的数据库操作和配置功能
function displayGameMenu() {
	# 声明本地变量
	local num
	local digit
	
	# 检查MySQL状态
	mysqlChecks
	
	clear
	echo -e "${shelltitle}
${Separator}
${reds}(1)${font} ${yellows}[查询点券流水]${font}
${reds}(2)${font} ${blues}[修复登录网络中断或者商城限制购买]${font}
${reds}(3)${font} ${yellows}[解除全部玩家创建限制]${font}
${reds}(4)${font} ${greens}[锁定角色栏(指定剩余数量)]${blues}<有选项>${font}
${reds}(5)${font} ${greens}[设置自动加公会触发器]${new}${blues}<有选项>${font}
${reds}(6)${font} ${yellow}[开启关闭以及默认开启地狱级]${new}${blues}<有选项>${font}
${reds}(7)${font} ${greens}[跳过新建角色自动进教程副本]${blues}<有选项>${font}
${reds}(8)${font} ${yellows}[删除并重装数据库]${reds}(慎重操作,需确认)${font}
${reds}(9)${font} ${yellows}[卸载当前DOF环境]${reds}(慎重操作,需确认)${font}
${Separator}
${blues}自动备份[${font}${Backup_display}${blues}]${font}
${greens}${blues}[右侧字母翻页]${font} ${font}${reds}(a | b | c | d)${font}	 
${reds}(0)${font} ${black_cyan_blink}退出安装${font}	     ${reds}(m)${font}${purple}防提权等级补丁${font}     ${reds}(当前页:${font}${green}[1] [2] ${cyan_green_bold}[3] ${font}${green}[4]${font}${reds})${font}
${greens}${blue}本机IP:${font}${greens}${IP}   ${blue}配置:${font}${greens}${HX}核 ${G}G   ${blue}镜像:${font}${greens}Centos${XT}   ${font}${greens}${blue}数据库版本:${font}${greens}${mysql_version}${font}${blue}"
	
	# 等待用户输入选择
	echo -n -e "${determine}${yellow}数字 [0-9]:${font}"
	read -r num </dev/tty
	
	# 根据用户选择执行相应操作
	case "${num}" in
	1)
		# 查询点券流水
		mysqlCheck
		# 检查是否存在需要的数据表
		TABLE_EXISTS=$(mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'taiwan_billing' AND table_name = 'cera_changes_log';" -s --skip-column-names)
		if [ "$TABLE_EXISTS" -eq 1 ]; then
			Flow_query
		else
			echo -e "${error}${reds}7.13日后搭建或者c页8重装后的数据库才支持!${font}"
		fi
		;;
	2)
		# 修复登录网络中断或者商城限制购买
		mysqlCheck
		unfreeze
		;;
	3)
		# 解除全部玩家创建限制
		mysqlCheck
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<EOF
USE d_taiwan;

UPDATE limit_create_character SET count = 0;

DROP TRIGGER IF EXISTS \`update_limit_create_character\`;

DELIMITER //
CREATE TRIGGER \`update_limit_create_character\` 
BEFORE UPDATE ON \`limit_create_character\` 
FOR EACH ROW
BEGIN
    IF NEW.count = 2 THEN
        SET NEW.count = 0;
    END IF;
END //
DELIMITER ;
EOF
		echo -e "${tip}解除完成。${load}"
		;;
	4)
		# 锁定角色栏
		mysqlCheck
		Character_lock
		;;
	5)
		# 设置自动加公会触发器
		mysqlCheck
		Automatic_enrollment
		;;
	6)
		# 开启关闭以及默认开启地狱级
		mysqlCheck
		Hell_level
		;;
	7)
		# 跳过新建角色自动进教程副本
		mysqlCheck
		Skip_animation
		;;
	8)
		# 删除并重装数据库
		cyzlcleardnf
		;;
	9)
		# 卸载当前DOF环境
		clear
        echo -e "${input}"
		echo -e "${warn}${reds}一经删除不可恢复,请仔细斟酌!${font}"
		echo -n -e "${determine}${yellow}输入[我同意]后回车继续:${font}"
		read -r digit </dev/tty
		if [[ "$digit" != "我同意" ]]; then
			echo -e "已取消!"
			exit
		fi
		
		# 执行卸载操作
		echo -e "${info}开始卸载DOF环境,请耐心等待${load}"
		/root/stop >/dev/null 2>&1
		/root/stop >/dev/null 2>&1
		rm -rf /root/stop
		rm -rf /root/run
		service mysqld stop >/dev/null 2>&1
		swapoff -v "$swap_part" >/dev/null 2>&1
		sleep 2
		rm -rf "$swap_part"
		yes y | head -1 | yum remove -y mysql "mysql-*" mariadb >/dev/null 2>&1
		rm -rf /var/lib/mysql
		rm -rf /usr/lib64/mysql
		rm -rf /etc/my.cnf
		rm -rf /var/log/mysql
		rm -rf /var/local/mysql
		/opt/lampp/lampp stop >/dev/null 2>&1
		rm -rf /opt/lampp >/dev/null 2>&1
		sleep 1s
		rm -rf /etc/my.cnf
		userdel -r mysql >/dev/null 2>&1
		rm -rf /home/neople
		sed -i '/dnfswap/d' /etc/fstab >/dev/null 2>&1
		sed -i '/user/d' /etc/security/limits.conf
		chattr -i /etc/motd
		echo "" | sudo tee /etc/motd >/dev/null
		find /root -mindepth 1 -not -path "/root/.*" -delete
		echo -e "${tip}${greens}已移除当前系统内所有有关NDF的环境!${font}"
        echo -e "${inputs}"
		;;
	a)
		# 跳转到主菜单
		startMenu
		;;
	b)
		# 跳转到系统菜单
		displaySystemMenu
		;;
	d)
		# 跳转到高级菜单
		displayAdvancedMenu
		;;
	m)
		# 调用防提权补丁
		ftqBd
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		displayGameMenu
		;;
	esac
}

# 高级管理菜单:提供高级系统和数据库管理功能
function displayAdvancedMenu() {
	# 声明本地变量
	local num
	local digit
	local sjkwjzh
	
	# 检查MySQL状态
	mysqlChecks
	
	clear
	echo -e "${shelltitle}
${Separator}
${reds}(1)${font} ${yellows}[修复数据库正常但五国报错127${blues}(建议提前备份)]${font}
${reds}(2)${font} ${blues}[修改玩家密码(指定账号)]${font}
${reds}(3)${font} ${greens}[把商城限购一次改为每日限购一次]${blues}<有选项>${font}
${reds}(4)${font} ${yellows}[数据库限制指定IP才可访问]${font}
${reds}(5)${font} ${yellows}[初始化邮件系统(建议提前备份,会清空所有邮件)]${font}
${reds}(6)${font} ${greens}[数据库开启或关闭]${font}

${reds}(8)${font} ${reds}[重启服务器]${font}
${reds}(9)${font} ${reds}[关闭服务器]${font}
${Separator}
${blues}自动备份[${font}${Backup_display}${blues}]${font}		  
${greens}${blues}[右侧字母翻页]${font} ${font}${reds}(a | b | c | d)${font}	 
${reds}(0)${font} ${black_cyan_blink}退出安装${font}	     ${reds}(m)${font}${purple}防提权等级补丁${font}     ${reds}(当前页:${font}${green}[1] [2] [3] ${cyan_green_bold}[4]${font}${reds})${font}
${greens}${blue}本机IP:${font}${greens}${IP}   ${blue}配置:${font}${greens}${HX}核 ${G}G   ${blue}镜像:${font}${greens}Centos${XT}   ${font}${greens}${blue}数据库版本:${font}${greens}${mysql_version}${font}${blue}"
	
	# 等待用户输入选择
	echo -n -e "${determine}${yellow}数字 [0-9]:${font}"
	read -r num </dev/tty
	
	# 根据用户选择执行相应操作
	case "${num}" in
	1)
		# 修复数据库正常但五国报错127
		echo -e "${input}"
		echo -e "${warn}${reds}将修复数据库连接,建议提前备份数据!${load}"
		echo -n -e "${determine}${yellow}输入[确定]后回车继续:${font}"
		read -r digit </dev/tty
		if [[ "$digit" != "确定" ]]; then
			echo -e "${warn}${reds}未确定,结束!${load}"
			exit
		fi
		
		# 下载并执行修复SQL
		wget --no-check-certificate -q -O /root/db_connect.sql vip.123pan.cn/1784780/yb/sql/db_connect.sql >/dev/null 2>&1
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 --database=d_taiwan < "/root/db_connect.sql"
		rm -rf /root/db_connect.sql
		echo -e "${tip}请重试跑五国!${font}"
		echo -e "${inputs}"
		;;
	2)
		# 修改玩家密码
		mysqlCheck
		clear
		echo -e "${input}"
		echo -n -e "${determine}${yellow}玩家账号:${font}"
		read -r sjkwjzh </dev/tty
		echo -e "${inputs}"
		echo
		
		# 检查是否输入账号
		if [[ -z ${sjkwjzh} ]]; then
			echo -e "--------失败--------"
			return
		fi
		
		# 更新密码为123456(MD5加密后)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
use d_taiwan
update accounts set password="e10adc3949ba59abbe56e057f20f883e" where accountname="${sjkwjzh}";
EOF
		echo -e "账号为:${sjkwjzh}"
		echo -e "密码为:123456"
		;;
	3)
		# 把商城限购一次改为每日限购一次
		# 检查数据库版本是否支持
		if [[ ${mysql_version} = "5.0.95" ]]; then
			echo -e "${error}${red}当前数据库版本为[${mysql_version}],不支持该功能!"
			exit
		fi
		
		mysqlCheck
		daily_shopping
		;;
	4)
		# 数据库限制指定IP才可访问
		mysqlLimitation
		;;
	5)
		# 初始化邮件系统
		echo -e "${input}"
		echo -e "${warn}${reds}将初始化邮件系统,建议提前备份数据!${load}"
		echo -n -e "${determine}${yellow}输入[确定]后回车继续:${font}"
		read -r digit </dev/tty
		if [[ "$digit" != "确定" ]]; then
			echo -e "${warn}${reds}未确定,结束!${load}"
			exit
		fi
		
		# 下载并执行邮件系统初始化SQL
		wget --no-check-certificate -q -O /root/Email.sql vip.123pan.cn/1784780/yb/sql/Email.sql >/dev/null 2>&1
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 --database=d_taiwan < "/root/Email.sql"
		rm -rf /root/Email.sql
		echo -e "${tip}操作已经完成!${font}"
		echo -e "${inputs}"
		;;
	6)
		# 数据库开启或关闭
		mysqlOnOff
		;;
	8)
		# 重启服务器
		clear
		echo -e "${tip}服务器正在重启,请稍后重新连接。${load}"
		reboot
		;;
	9)
		# 关闭服务器
		clear
		echo -e "${tip}服务器正在关闭,请稍后重新启动。${load}"
		shutdown now
		;;
	a)
		# 跳转到主菜单
		startMenu
		;;
	b)
		# 跳转到系统菜单
		displaySystemMenu
		;;
	c)
		# 跳转到游戏菜单
		displayGameMenu
		;;
	m)
		# 调用防提权补丁
		ftqBd
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		displayAdvancedMenu
		;;
	esac
}

# 检查MySQL连接是否成功
function mysqlCheck() {
	clear
	echo -e "${Separator}"
	# 尝试连接数据库并刷新权限
	if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
USE d_taiwan;
flush privileges;
EOF
	then 
		echo -e "${tip}${greens}数据库连接成功!${font}"
	else
		echo -e "${error}${reds}数据库连接失败,已退出!${font}"
		echo -e "${Separator}"
		exit 1 # 连接失败则退出脚本
	fi
	echo -e "${Separator}"
}

# 检查MySQL连接状态并设置全局变量
function mysqlChecks() {
	clear
	# 尝试连接数据库并刷新权限,不显示输出
	if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
USE d_taiwan;
flush privileges;
EOF
	then 
		# 连接成功,将MySQL版本号存入Smooth_detection变量
		export Smooth_detection=${mysql_version}
	else
		# 连接失败,设置Smooth_detection为错误提示信息
		export Smooth_detection="${error}${reds}链接失败${font}"
	fi
}

# 查询并显示指定端口的数据包收发计数
function portSendsData() {
	echo -e "${input}"
	# 从运行脚本中提取频道标识符 (sirocoXX)
	local pro_identifier
	pro_identifier=$(grep -oP 'df_game_r\s+\K\w+' /root/run | head -n 1)

	# 定义频道标识符到端口号的映射
	declare -A siroco_map
	siroco_map=(
		["siroco11"]=10011 ["siroco12"]=10012 ["siroco13"]=10013 ["siroco14"]=10014 ["siroco15"]=10015
		["siroco16"]=10016 ["siroco17"]=10017 ["siroco18"]=10018 ["siroco19"]=10019 ["siroco20"]=10020
	)

	local default_port="${pro_identifier}" # 默认使用标识符本身作为端口（如果不在map中）
	# 如果标识符在映射中,则使用对应的端口号
	if [[ -n ${siroco_map[${pro_identifier}]} ]]; then
		default_port=${siroco_map[${pro_identifier}]}
	fi

	# 提示用户输入要查询的端口,默认为自动检测到的端口
	local query_port
	echo -n -e "${determine}${yellow}查询端口被发包计数(默认端口):${red}${default_port}${font}"; read -r query_port </dev/tty 
	echo
	# 如果用户未输入,则使用默认端口
	if [[ -z ${query_port} ]]; then
		query_port=${default_port}
	fi

	# 显示相关提示信息
	echo -e "${greens}如果服务器出现:hook_encrypt::0x848DA70类似情况一直刷新。${font}"
	echo -e "${greens}是dp在拦截拦截Encryption::Encrypt的调用,计数最大的拉黑,或者让机房封异常ip!${font}"

	# 使用netstat统计连接到指定端口的IP地址及其计数,并计算总IP数
	local total_ips
	
	sudo netstat -tn | grep ":${query_port}" | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | awk '{printf "计数: %-5s IP地址: %s\n", $1, $2}' | column -t
	total_ips=$(sudo netstat -tn | grep ":${query_port}" | awk '{print $5}' | cut -d: -f1 | sort | uniq | wc -l)
	echo "${query_port}频道总共有 ${total_ips} 个不同的 IP 地址在连接。"
	echo -e "${inputs}"

	# 询问用户是否继续查询
	local continue_query
	echo -n -e "${determine}${yellow}是否继续查询发包计数[是/否]${font}"; read -r continue_query </dev/tty 
	if [[ "${continue_query}" = "是" ]]; then
		portSendsData # 递归调用自身以继续查询
	else
		echo -e "${greens}结束查询!${font}"
	fi
}

# 开启或关闭MySQL服务
function mysqlOnOff() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${yellows}1、[数据库开启运行]${font}"
	echo -e "${reds}2、[数据库停止运行]${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty 
	case "${num}" in
	1)
		clear
		# 启动MySQL服务
		if service mysqld start; then
			echo -e "${tip}数据库运行已开启,可以正常访问数据库!${font}" # 修正了之前的提示语逻辑错误
		else
			echo -e "${error}${reds}启动MySQL服务失败!${font}"
		fi
		;;
	2)
		clear
		# 停止MySQL服务
		if service mysqld stop; then
			echo -e "${tip}数据库运行已停止,已无法访问数据库!${font}" # 修正了之前的提示语逻辑错误
		else
			echo -e "${error}${reds}停止MySQL服务失败!${font}"
		fi
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		mysqlOnOff # 输入无效,重新调用
		;;
	esac
}

# 检查并安装指定的软件包
# 参数1: package_name (要安装的包名)
# 参数2: command_name (用于检查是否已安装的命令名)
function checkAndInstall() {
	local package=$1
	local command_to_check=$2

	# 检查命令是否存在
	if ! command -v "${command_to_check}" &> /dev/null; then
		echo -e "${tip}${yellow}${command_to_check}工具 未安装,正在安装 ${package}...${font}"
		# 使用yum安装软件包,抑制输出
		sudo yum install -y "${package}" >/dev/null 2>&1
		# 再次检查是否安装成功
		if command -v "${command_to_check}" &> /dev/null; then
			echo -e "${tip}${greens}${command_to_check}工具 安装成功!${font}"
		else
			echo -e "${error}${reds}${command_to_check}工具 安装失败!${font}"
		fi
	else
		echo -e "${tip}${yellow}${command_to_check}工具 已安装,跳过安装。${font}"
	fi
}

# 解除玩家登录或商城购买限制
function unfreezeAccount() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${yellows}1、[指定Uid解除限制]${font}"
	echo -e "${yellows}2、[全部Uid解除限制]${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty 
	case "${num}" in
	1)
		clear
		echo -e "${input}"
		local user_id
		echo -e "直接回车则默认${red}18000000${font}"
		echo -n -e "${determine}${yellow}需要修复的UID:${font}"; read -r user_id </dev/tty 
		echo -e "${inputs}"
		echo
		# 如果用户未输入,则使用默认UID
		if [[ -z ${user_id} ]]; then
			user_id=18000000
		fi
		echo -e "开始还原登录设置..."
		# 删除 taiwan_login.login_account_3 表中的记录
		if ! mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_login' -e "DELETE FROM login_account_3 WHERE m_id = ${user_id};"; then 
			echo -e "${error}错误,请检查数据库连接和权限设置。"
			return 1
		fi
		sleep 2
		# 清空 taiwan_login.log_query_ref 表
		if ! mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_login' -e "TRUNCATE TABLE log_query_ref;"; then 
			echo -e "${error}错误,请检查数据库连接和权限设置。"
			return 1
		fi

		# 删除 d_taiwan.member_punish_info 表中的惩罚记录
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
use d_taiwan
delete from member_punish_info where m_id='${user_id}';
EOF
		# 将 taiwan_billing.cash_cera 表中对应用户的 cera_dof 字段置0
		mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_billing' -s -e "UPDATE cash_cera SET cera_dof = 0 where account='${user_id}';" >/dev/null 2>&1
		echo -e "${info}还原登录设置完成,请尝试登录游戏。"
		;;
	2)
		clear
		# 删除 d_taiwan.member_punish_info 表中的所有惩罚记录
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
use d_taiwan
delete from member_punish_info;
EOF
		# 将 taiwan_billing.cash_cera 表中所有用户的 cera_dof 字段置0
		mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_billing' -s -e "UPDATE cash_cera SET cera_dof = 0;" >/dev/null 2>&1
		echo -e "${info}还原登录设置完成,请尝试登录游戏。"
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		unfreezeAccount # 输入无效,重新调用
		;;
	esac
}

# 防卡、商城、点券/代币阈值设定及防卡商店功能菜单
function countermeasureMenu() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${yellows}1、[防卡|商城|点券|代币|阈值设定]${font}"
	echo -e "${yellows}2、[防卡商店]${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty 
	case "${num}" in
	1)
		# 执行防卡、商城、点券/代币阈值设定
		mysqlCheck # 检查MySQL连接
		clear
		echo -e "${warn}${reds}已解决点券代币归零bug!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo
		fi
		echo -e "${input}"
		echo -e "开始进行防卡商城处理!"
		echo -e "${inputs}"
		sleep 1
		echo -e "${input}"
		echo -e "开始下载函数sql数据包!"
		# 下载SQL文件
		wget --no-check-certificate -q -O /root/hs.sql "${Url}sql/hs.sql" >/dev/null 2>&1
		echo -e "函数sql数据包下载完成!"
		echo -e "${inputs}"
		sleep 1
		echo -e "${input}"
		echo -e "开始还原函数sql数据包!"
		# 执行SQL文件
		if "/usr/local/mysql/bin/mysql" --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 < "/root/hs.sql"; then 
			echo -e "还原函数sql数据包完成!"
		else
			echo -e "${error}${reds}还原函数sql数据包失败!${font}"
		fi
		rm -f /root/hs.sql # 删除下载的SQL文件
		echo -e "${inputs}"
		sleep 1
		echo -e "${input}"
		echo -e "开始添加判定字段!"
		# 在cash_cera表中添加cera_dof字段
		mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_billing' -s -e "ALTER TABLE cash_cera ADD COLUMN cera_dof int UNSIGNED NOT NULL DEFAULT 0 AFTER cera;" > /dev/null 2>&1
		echo -e "添加判定字段完成!"
		echo -e "${inputs}"
		sleep 1
		echo -e "防卡商城处理完毕,开始进行防卡点券阈值设定!"
		echo -e "${input}"
		local cera_threshold cera_obtain_threshold
		echo -e "${red}回车则默认10亿,超过阈值则清零。${font}"
		echo -n -e "${determine}${yellow}防卡点券阈值: ${font}"; read -r cera_threshold </dev/tty 
		echo -e "${inputs}"
		# 设置默认阈值
		if [[ -z ${cera_threshold} ]]; then
			cera_threshold=1000000000
		fi
		echo -e "防卡点券阈值设定处理完毕,开始进行单次点券获得上限设定!"
		echo -e "${input}"
		echo -e "${red}回车则默认1亿,超过阈值则限制购买。${font}"
		echo -n -e "${determine}${yellow}单次获得点券阈值: ${font}"; read -r cera_obtain_threshold </dev/tty 
		echo -e "${inputs}"
		# 设置默认单次获得上限
		if [[ -z ${cera_obtain_threshold} ]]; then
			cera_obtain_threshold=100000000
		fi
		# 删除可能存在的旧触发器
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_billing' << EOF
DROP TRIGGER IF EXISTS cera_threshold;
DROP TRIGGER IF EXISTS cera_point_threshold;
DROP TRIGGER IF EXISTS clear_cear;
DROP TRIGGER IF EXISTS clear_cear_point;
DROP TRIGGER IF EXISTS qingkong;
DROP TRIGGER IF EXISTS qingkong2;
DROP TRIGGER IF EXISTS cash_cera;
DROP TRIGGER IF EXISTS cash_cear_point;
DROP TRIGGER IF EXISTS clear_cera;
DROP TRIGGER IF EXISTS clear_point;
DROP TRIGGER IF EXISTS cash_cera_point;
EOF

		# 创建代币阈值触发器
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_billing' << EOF
DELIMITER $
DROP TRIGGER IF EXISTS cera_point_threshold;
CREATE TRIGGER cera_point_threshold BEFORE UPDATE ON cash_cera_point FOR EACH ROW
BEGIN
    IF NEW.cera_point >= ${cera_threshold} THEN
        SET NEW.cera_point = 0;
    END IF;
END$
DELIMITER ;
EOF

		# 创建点券阈值和单次获取上限触发器
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_billing' << EOF
DELIMITER $
DROP TRIGGER IF EXISTS cera_threshold;
CREATE TRIGGER cera_threshold BEFORE UPDATE ON cash_cera FOR EACH ROW
BEGIN
    IF NEW.cera >= ${cera_threshold} THEN
        SET NEW.cera = 0;
        SET NEW.cera_dof = ${cera_threshold};
    END IF;
    IF NEW.cera > OLD.cera AND NEW.cera > OLD.cera + ${cera_obtain_threshold} THEN
        SET NEW.cera_dof = ${cera_threshold};
    END IF;
END$
DELIMITER ;
EOF
		then 
			echo -e "${info}设定成功,点券|代币阈值为[${cera_threshold}]。"
			echo -e "${info}设定成功,单次获得点券上限值为[${cera_obtain_threshold}]。"
			echo -e "${tip}超过阈值则清零且限制其购买权限。"
			echo -e "${tip}被处罚的玩家购买会提示[错误:付费服务器错误],c页2可解除。"
		else
			echo -e "${error}${reds}创建触发器失败!${font}"
		fi
		;;
	2)
		# 执行防卡商店功能
		clear
		# 检查并安装必要的工具
		checkAndInstall "vim-common" "xxd"
		checkAndInstall "sed" "sed"
		checkAndInstall "tar" "tar"
		checkAndInstall "coreutils" "rm"
		echo -e "${info}${greens}即将停止服务端对等级补丁进行处理!${font}"
		echo -e "${info}${greens}一键端安装的等补自带防卡Npc商店!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo
		fi
		# 切换到游戏目录并停止服务
		cd ~/game || exit 1
		if [ -f "/root/stop" ]; then
			/root/stop
		else
			echo -e "${warn}停止脚本 /root/stop 不存在,尝试直接停止进程..."
			# 添加直接停止进程的逻辑 (如果需要)
		fi
		# 备份并修改游戏主程序文件
		if [ -f "df_game_r" ]; then
			cp df_game_r df_game_r_back
			xxd -p df_game_r > df_game_r.hex # 使用 .hex 后缀更清晰
			# 使用 sed 修改十六进制内容 (注意: 这种硬编码修改非常脆弱,容易因版本更新失效)
			sed -i 's/8b809800000083f8ff7413/8b809c00000083f8007c44/g' df_game_r.hex
			xxd -r -p df_game_r.hex df_game_r
			rm -f df_game_r.hex # 删除临时文件
			echo -e "${info}${yellows}处理完成,请重新跑五国!${font}"
		else
			echo -e "${error}${reds}游戏主程序 df_game_r 不存在!${font}"
			# 可以选择删除备份文件 df_game_r_back
			rm -f df_game_r_back
		fi
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		countermeasureMenu # 输入无效,重新调用
		;;
	esac
}

# 数据库访问IP限制管理
function mysqlLimitation() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${yellows}1、添加指定IP访问数据库权限(建议提前备份数据)${font}"
	echo -e "${yellows}2、删除指定IP访问数据库权限${font}"
	echo -e "${yellows}3、查询可通过game访问数据库的IP明细${font}"
	echo -e "${reds}4、初始化mysql密码项目<不影响数据>${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-4]:${font}"; read -r num </dev/tty 
	case "${num}" in
	1)
		# 添加指定IP访问权限
		clear
		local address
		echo -n -e "${determine}${yellow}指定可通过game访问数据库的IP:${font}"; read -r address </dev/tty 
		echo -e "${inputs}"
		echo
		if [[ -z ${address} ]]; then
			echo -e "${red}输入为空,已结束!${font}"
			exit
		fi
		# 创建用户并授权
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' << EOF
CREATE USER 'game'@'${address}' IDENTIFIED BY 'uu5!^%jg';
GRANT ALL PRIVILEGES ON *.* TO 'game'@'${address}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
		then 
			echo -e "${info}${yellow}数据库密码恢复为默认,请修改密码后重新进入!${font}"
			echo -e "${info}${yellow}确保连接正常且查询数据正常后再继续!${font}"
			echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
			if [[ -z ${digit} ]]; then
				echo
			fi
		else
			# 如果创建用户失败,尝试删除可能已部分创建的用户
			mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
DROP USER 'game'@'${address}';
EOF
			echo -e "${info}${reds}执行失败,权限不足!${font}"
			echo -e "${input}"
			echo -e "GRANT CREATE USER ON *.* TO 'game'@'127.0.0.1';
FLUSH PRIVILEGES;"
			echo -e "${input}"
			echo -e "${info}${greens}请在数据库中按F6运行以上命令添加权限后重试!${font}"
			echo -e "${info}${greens}如果实在不懂这个,可以初始化密码项目后再来添加!${font}"
			exit 1
		fi

		# 删除通配符主机 '%' 的权限
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
DROP USER 'game'@'%';
EOF
		echo -e "${info}${yellow}${address}已添加访问数据库权限!${font}"
		echo -e "${info}${greens}8月16日之前的数据库可能会出现点券归零情况!${font}"
		echo -e "${info}${greens}请重新使用防卡点券功能后即可恢复!${font}"
		;;
	2)
		# 删除指定IP访问权限
		clear
		echo -e "${input}"
		local address_to_delete
		echo -n -e "${determine}${yellow}删除可通过game访问数据库的IP:${font}"; read -r address_to_delete </dev/tty 
		echo -e "${inputs}"
		echo
		if [[ -z ${address_to_delete} ]]; then
			echo -e "${red}输入为空,结束!${font}"
			exit
		fi
		# 删除指定IP的用户
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
DROP USER 'game'@'${address_to_delete}';
EOF
		# 同时删除可能存在的通配符主机 '%',确保安全
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
DROP USER 'game'@'%';
EOF
		echo -e "${info}${yellow}${address_to_delete}已禁止访问数据库权限!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			mysqlLimitation # 返回菜单
		fi
		;;
	3)
		# 查询允许访问的IP明细
		clear
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
SELECT User, Host FROM mysql.user WHERE User='game';
EOF
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			mysqlLimitation # 返回菜单
		fi
		;;
	4)
		# 初始化MySQL密码项目（恢复默认权限）
		echo -e "${tip}${yellow}该项目会重置密码连接项目,不影响游戏数据,但是需要重跑五国!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo
		fi
		# 下载并解压权限文件
		wget --no-check-certificate -q -O /user.tar.gz "${Url}sql/user" >/dev/null 2>&1 # 使用.tar.gz后缀
		if tar -zxvf /user.tar.gz -C / >/dev/null 2>&1; then
			rm -f /user.tar.gz >/dev/null 2>&1
			service mysqld restart # 重启MySQL服务使权限生效
			echo -e "${yellow}操作完成,数据库账号密码已恢复默认状态!${font}"
		else
			echo -e "${error}${reds}解压权限文件失败!${font}"
			rm -f /user.tar.gz >/dev/null 2>&1
		fi
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		mysqlLimitation # 输入无效,重新调用
		;;
	esac
}

# 查询点券流水功能
function flowQuery() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${greens}1、查询指定Uid流水${font}"
	echo -e "${greens}2、查询所有流水${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty 
	local output_file="/root/output.csv" # 定义输出文件名
	case "${num}" in
	1)
		# 查询指定UID流水
		clear
		echo -e "${input}"
		local user_id_query
		echo -n -e "${determine}${yellow}玩家Uid:${font}"; read -r user_id_query </dev/tty 
		echo -e "${inputs}"
		echo
		if [[ -z ${user_id_query} ]]; then
			echo -e "--------失败--------"
			return 1
		fi
		# 执行MySQL查询并将结果输出到CSV文件
		mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -e "USE taiwan_billing; SELECT CONCAT('\"', account, '\",\"', old_value, '\",\"', new_value, '\",\"', (new_value - old_value), '\"') AS result FROM cera_changes_log WHERE account = ${user_id_query};" > "${output_file}"
		# 处理CSV文件,添加表头并替换NULL值
		sed -i '1s/^result/"UID","旧数值","新数值","单次差值"/' "${output_file}" # 使用1s只替换第一行
		sed -i 's/^NULL/""/' "${output_file}"
		echo -e "${info}${yellow}流水表格已输出到${output_file},请下载到电脑桌面打开!${font}"
		;;
	2)
		# 查询所有流水
		clear
		# 执行MySQL查询并将结果输出到CSV文件
		mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -e "USE taiwan_billing; SELECT CONCAT('\"', account, '\",\"', old_value, '\",\"', new_value, '\",\"', (new_value - old_value), '\"') AS result FROM cera_changes_log WHERE account > 0;" > "${output_file}"
		# 处理CSV文件,添加表头并替换NULL值
		sed -i '1s/^result/"UID","旧数值","新数值","单次差值"/' "${output_file}" # 使用1s只替换第一行
		sed -i 's/^NULL/""/' "${output_file}"
		echo -e "${info}${yellow}流水表格已输出到${output_file},请下载到电脑桌面打开!${font}"
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		flowQuery # 输入无效,重新调用
		;;
	esac
}

# IP黑名单管理功能
function blacklistManager() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blues}1、添加黑名单${font}"
	echo -e "${blues}2、删除黑名单${font}"
	echo -e "${greens}3、查询黑名单${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num
	echo -n -e "${determine}${yellow}数字 [0-3]:${font}"; read -r num </dev/tty 
	case "${num}" in
	1)
		# 添加黑名单条目
		# 尝试创建INPUT链,如果已存在则忽略错误
		sudo iptables -N INPUT 2>/dev/null
		while true; do
			clear
			echo -e "${input}"
			echo -e "${greens}添加了黑名单的IP会被拒绝连接所有端口,若已连接则直接断开!${font}"
			echo -e "${greens}如果拉黑以59开头的所有IP地址,可以输入:59.0.0.0/8${font}"
			echo -e "${greens}如果拉黑以59.47开头的所有IP地址,可以输入:59.47.0.0/16${font}"
			echo -e "${greens}如果拉黑以59.47.231开头的所有IP地址,可以输入:59.47.231.0/24${font}"
			local blacklist_ip
			echo -n -e "${determine}${yellow}添加黑名单的IP(0则退出):${font}"; read -r blacklist_ip </dev/tty 
			echo -e "${inputs}"
			echo
			if [[ "${blacklist_ip}" = 0 ]]; then
				echo -e "${red}输入为0,已退出!${font}"
				break # 退出循环
			fi
			sudo iptables -A INPUT -s "${blacklist_ip}" -p tcp --dport 0:65535 -j DROP
			echo -e "${yellow}[${blacklist_ip}]已添加黑名单!${font}"
			sleep 1
		done
		;;
	2)
		# 删除黑名单条目
		clear
		echo -e "${input}"
		local ip_to_delete
		echo -n -e "${determine}${yellow}删除黑名单的IP:${font}"; read -r ip_to_delete </dev/tty 
		echo -e "${inputs}"
		echo
		if [[ -z ${ip_to_delete} ]]; then
			echo -e "${red}输入为空,结束!${font}"
			return 1
		fi
		sudo iptables -D INPUT -s "${ip_to_delete}" -p tcp --dport 0:65535 -j DROP
		echo -e "${yellow}[${ip_to_delete}]已解除黑名单!${font}"
		;;
	3)
		# 查询黑名单列表
		clear
		echo -e "${inputs}" 
		echo -e "${blues}以下为目前在黑名单中的IP${yellows}" 
		# 显示INPUT链中非默认规则的源IP地址
		sudo iptables -L INPUT --line-numbers -n | awk '$4 == "DROP" && $5 != "0.0.0.0/0" {print $5}' # 更精确地过滤DROP规则
		echo -e "${font}${inputs}" 
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		blacklistManager # 输入无效,重新调用
		;;
	esac
}

# 安装PHP环境
function installPhp() {
	clear
	local php_version
	# 检查PHP是否已安装
	if command -v php &> /dev/null; then
		php_version=$(php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')
		echo -e "${tip}${red}检测到 PHP 已安装,当前版本[$php_version]是否继续安装？${font}"

		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo
		fi

		echo -e "${info}正在清理系统原始 PHP 环境${load}" 
		# 停止并清理 Xampp (如果存在)
		if [ -d "/opt/lampp" ]; then
			/opt/lampp/lampp stop >/dev/null 2>&1
			rm -rf /opt/lampp >/dev/null 2>&1
		fi
		# 清理系统自带的 PHP 和 Apache
		yes y | head -1 | yum remove -y php php-* httpd httpd-* >/dev/null 2>&1
		yum remove -y php* >/dev/null 2>&1 # 再次尝试移除,确保彻底
		yum remove -y httpd* >/dev/null 2>&1 # 再次尝试移除,确保彻底
		rm -rf /etc/httpd >/dev/null 2>&1
	else
		echo -e "${info}${yellow}检测到 PHP 未安装" 
	fi

	echo -e "${info}正在安装 PHP 环境,可能需要几分钟,请耐心等待!${load}" 
	# 禁用SELinux
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
	sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	setenforce 0 >/dev/null 2>&1

	# 根据CentOS版本安装PHP 5.4
	if [[ "${XT}" == "5" || "${XT}" == "6" ]]; then
		yum install -y "https://rpms.remirepo.net/enterprise/remi-release-${XT}.rpm" >/dev/null 2>&1
		yum install -y yum-utils >/dev/null 2>&1
		yum-config-manager --enable remi-php54 >/dev/null 2>&1
		yum install -y php php-mysqlnd openssl httpd >/dev/null 2>&1
		fuser -k -n tcp 735 >/dev/null 2>&1 # 关闭可能占用端口的进程
		chkconfig httpd on >/dev/null 2>&1 # 设置Apache开机自启
	elif [ "${XT}" = "7" ]; then
		yum install -y "https://rpms.remirepo.net/enterprise/remi-release-${XT}.rpm" >/dev/null 2>&1
		yum install -y yum-utils >/dev/null 2>&1
		yum-config-manager --enable remi-php54 >/dev/null 2>&1
		yum install -y php php-mysqlnd openssl httpd >/dev/null 2>&1
		fuser -k -n tcp 735 >/dev/null 2>&1 # 关闭可能占用端口的进程
		systemctl enable httpd.service >/dev/null 2>&1 # 设置Apache开机自启 (CentOS 7)
	else
		echo -e "${error}${reds}不支持的CentOS版本: ${XT}${font}"
		exit 1
	fi

	sleep 1
	# 配置Apache监听端口和ServerName
	sed -i "/Listen 80/a\Listen 735" "${conf}" >/dev/null 2>&1
	sed -i "/#ServerName www.example.com:80/a\ServerName localhost:80" "${conf}" >/dev/null 2>&1
	# 配置PHP连接MySQL的socket路径
	sed -i 's#mysql.default_socket[^,]*#mysql.default_socket = /var/lib/mysql/mysql.sock#' /etc/php.ini >/dev/null 2>&1
	sed -i 's#mysqli.default_socket[^,]*#mysqli.default_socket = /var/lib/mysql/mysql.sock#' /etc/php.ini >/dev/null 2>&1

	echo -e "${tip}PHP 环境安装成功!${success}" 
	# 启动Apache服务
	if [[ "${XT}" == "5" || "${XT}" == "6" ]]; then
		service httpd start
	elif [ "${XT}" = "7" ]; then
		systemctl start httpd.service
	fi

	# 创建一个简单的PHP脚本用于测试
	cat <<EOF | sudo tee /var/www/html/time.php >/dev/null
<?php
  date_default_timezone_set('Asia/Shanghai');
  \$currentTime = date('Y-m-d H:i:s');
  echo \$currentTime;
?>
EOF

	php_version=$(php -v | grep -oP '(?<=PHP )\d+\.\d+\.\d+')
	echo -e "${tip}${red}PHP 启动完成,当前版本[${php_version}]${font}!${success}" 
	echo -e "${tip}可以尝试在网页访问[${IP}/time.php]来获取时间判断是否成功!" 
	echo -e "${tip}Web 服务器默认文档根目录的位置为[/var/www/html]!" 
	echo -e "${tip}Web 服务器默认端口为[80/735]!" 
	exit # 安装完成后退出脚本
}

# 跳过新手教程动画功能
function skipAnimation() {
	clear
	echo -e "${green}------------------------------------------------------------${font}" 
	echo -e "${blues}1、${yellows}跳过新手教程触发器${greens}[功能添加]${font}" 
	echo -e "${blues}2、${yellows}跳过新手教程触发器${red}[功能解除]${font}" 
	echo -e "${green}------------------------------------------------------------${font}" 
	local num
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty
	case "${num}" in
	1)
		# 添加跳过教程的触发器
		echo -e "${input}"
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
USE taiwan_cain;
DROP TRIGGER IF EXISTS tutorial_skip; -- 先删除可能存在的旧触发器
DELIMITER //
CREATE TRIGGER tutorial_skip BEFORE INSERT ON charac_stat 
FOR EACH ROW BEGIN
    SET NEW.tutorial_flag = -1; -- 将新角色的教程标记设为-1
END //
DELIMITER ;
EOF
		then 
			echo -e "${tip}${blues}跳过新手教程触发器创建成功!${font}" 
		else
			echo -e "${error}${reds}跳过新手教程触发器创建失败!${font}" 
		fi
		echo -e "${inputs}"
		;;
	2)
		# 解除跳过教程的触发器
		local trigger_name='tutorial_skip'
		local mysql_cmd="mysql --defaults-extra-file=/etc/my.cnf -h127.0.0.1 -Dtaiwan_cain"
		local trigger_exists

		# 查询触发器是否存在
		
		if ! trigger_exists=$($mysql_cmd -se "SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'taiwan_cain' AND TRIGGER_NAME = '${trigger_name}';"); then 
			echo -e "${tip}${reds}MySQL 查询失败。${font}" 
			exit 1
		fi

		# 去除查询结果中的换行符
		trigger_exists=$(echo "${trigger_exists}" | tr -d '\n')

		# 如果触发器存在,则删除
		if [ "${trigger_exists}" -gt 0 ]; then
			if $mysql_cmd -e "DROP TRIGGER $trigger_name;"; then 
				echo -e "${tip}${greens}触发器 $trigger_name 已删除。${font}" 
			else
				echo -e "${tip}${reds}删除触发器 $trigger_name 失败。${font}" 
			fi
		else
			# 触发器不存在
			echo -e "${tip}${reds}触发器 $trigger_name 不存在。${font}" 
		fi
		;;
	0)
		exit
		;;
	*)
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		skipAnimation # 输入无效,重新调用
		;;
	esac
}

# 管理地狱级难度设置
function hellLevel() {
	# 清屏
	clear
	# 显示菜单选项
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blues}1、${yellow}目前所有角色${blues}开地狱级难度${red}[功能添加]${font}" 
	echo
	echo -e "${blues}2、${yellow}新建角色${blues}默认开地狱级难度${red}[功能添加]${font}" 
	echo -e "${blues}3、新建角色默认开地狱级难度${red}[功能解除]${font}" 
	echo -e "${green}------------------------------------------------------------${font}"

	# 定义地狱级难度配置字符串
	local result="1|3,2|3,3|3,4|3,5|3,6|3,7|3,8|3,9|3,11|3,12|3,13|3,14|3,15|3,17|3,21|3,22|3,23|3,24|3,25|3,26|3,27|3,31|3,32|3,33|3,34|3,35|3,36|3,37|3,40|3,41|3,42|3,43|3,44|3,45|3,50|3,51|3,52|3,53|3,60|3,61|3,62|3,63|3,64|3,65|3,66|3,67|3,70|3,71|3,72|3,73|3,74|3,75|3,76|3,77|3,80|3,81|3,82|3,83|3,84|3,85|3,86|3,87|3,88|3,89|3,90|3,91|3,92|3,93|3,100|3,101|3,102|3,103|3,104|3,110|3,111|3,112|3,120|3,121|3,140|3,141|3,200|3,201|3,202|3,203|3,204|3,205|3,206|3,1500|3,1501|3,1502|3,1504|3,1506|3,1507|3,"
	local num # 用户选择

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-3]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 为所有角色开启地狱级难度
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
UPDATE member_dungeon
SET dungeon = "${result}";
EOF
		echo -e "${tip}${blues}操作已完成,当前所有角色已开启地狱级难度,如果不生效请保持玩家离线状态重试!${font}"
		;;
	2)
		# 设置新建角色默认开启地狱级难度 (创建触发器)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DELIMITER \$
DROP TRIGGER IF EXISTS member_dungeon;
CREATE TRIGGER member_dungeon BEFORE INSERT ON member_dungeon FOR EACH ROW
IF new.m_id > 0 THEN
SET new.dungeon = "${result}";
END IF
\$
DELIMITER ;
EOF
		echo -e "${tip}${blues}开启完成,新建角色默认开地狱级难度!${font}"
		;;
	3)
		# 解除新建角色默认开启地狱级难度 (删除触发器)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DROP TRIGGER IF EXISTS member_dungeon;
EOF
		echo -e "${tip}${blues}解除完成,新建角色不会再默认开地狱级难度!${font}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"  if needed, assuming 'error' is exported
		sleep 1
		hellLevel # 重新调用函数
		;;
	esac
}

# 自动加入公会管理
function automaticEnrollment() {
	# 清屏
	clear
	# 显示菜单选项
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blues}1、自动入工会${red}[功能添加]${font}" 
	echo -e "${blues}2、自动入工会${red}[功能解除]${font}" 
	echo -e "${blues}3、解除全员脱离公会的冷却时间${font}"
	echo -e "${reds}4、解散所有公会${blues}[并修复表项]${font}"
	echo -e "${green}------------------------------------------------------------${font}"

	local num # 用户选择
	local result # 数据库查询结果
	local number # 公会编号
	local digit # 用户确认输入

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-4]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 添加自动加入公会功能
		# 查询现有公会列表
		result=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "SELECT guild_id, guild_name FROM d_guild.guild_info")
		if [ -z "$result" ]; then
			echo -e "未查询到有创建过公会,结束"
			exit
		fi

		# 显示公会列表
		echo -e "${input}"
		echo -e "编号\t名称${font}" # 使用 \t 制表符对齐
		tail -n +2 <<< "$result" # 显示除表头外的结果
		echo -e "${inputs}"
		echo -e "${input}"
		echo -e "${red}直接回车则默认不加入${font}" 

		# 获取要自动加入的公会编号
		echo -n -e "${determine}${yellow}要加入的公会编号:${font}"; read -r number </dev/tty 
		echo -e "${inputs}"

		# 检查输入是否为空
		if [[ -z ${number} ]]; then
			echo -e "${red}输入为空,结束!${font}" 
			return
		fi

		# 创建触发器,使新角色自动加入指定公会
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DELIMITER \$
DROP TRIGGER IF EXISTS charac_info;
CREATE TRIGGER charac_info BEFORE INSERT ON charac_info FOR EACH ROW
IF new.guild_id = 0 THEN
SET new.guild_id = "${number}";
END IF
\$
DELIMITER ;
EOF
		echo -e "${tip}完成,新建角色会自动加入相应编号公会!${font}"
		;;
	2)
		# 解除自动加入公会功能 (删除触发器)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DROP TRIGGER IF EXISTS charac_info;
EOF
		echo -e "${tip}解除完成,新建角色不再自动加入工会!${font}"
		;;
	3)
		# 解除所有玩家脱离公会的冷却时间
		echo -e "${input}"
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
UPDATE charac_info
SET guild_secede = "0"
WHERE guild_id >= "0";
EOF
		echo -e "${tip}所有脱离公会玩家的冷却时间已解除!${font}"
		echo -e "${inputs}"
		;;
	4)
		# 解散所有公会并修复表项
		echo -e "${input}"
		echo -e "${warn}${reds}清空公会信息无法恢复,建议提前备份,确定要执行吗？${load}"
		# 获取用户确认
		echo -n -e "${determine}${yellow}输入[确定]后回车继续:${font}"; read -r digit </dev/tty 
		if [[ "$digit" != "确定" ]]; then
			echo -e "${warn}${reds}未确定,结束!${load}"
			exit
		fi

		# 下载并执行公会数据库重置SQL
		wget --no-check-certificate -q -O /root/d_guild.sql "${Url}sql/d_guild.sql" >/dev/null 2>&1
		if "/usr/local/mysql/bin/mysql" --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 < "/root/d_guild.sql"; then
			rm -f /root/d_guild.sql # 删除下载的SQL文件
			# 解除自动入会触发器
			mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DROP TRIGGER IF EXISTS charac_info;
EOF
			# 重置所有角色的公会信息
			mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
UPDATE charac_info
SET guild_id = "0", guild_right = "0", guild_secede = "0"
WHERE guild_id >= "0";
EOF
			echo -e "${tip}清空完成且解除了脱离公会惩罚,同时解除了自动入会触发器!${font}"
		else
			echo -e "${error}${reds}执行SQL文件失败!${font}"
			rm -f /root/d_guild.sql # 即使失败也删除下载的SQL文件
		fi
		echo -e "${inputs}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		automaticEnrollment # 重新调用函数
		;;
	esac
}

# 每日商城限购设置
function dailyShopping() {
	# 清屏
	clear
	# 显示功能说明和菜单选项
	echo -e "${purple}------------------------------------------------------------${font}"
	echo -e "${reds}PVF中目录位置:etc/newcashshop_restrict.etc
其中[account restrict]词条为账号限制
其中[character restrict]词条为角色限制
填写商城的编号即可实现限制购买
至于编号是什么,就是限制只能使用点券要填的那个编号。
此功能由:863615806无偿提供!${font}"
	echo -e "${purple}------------------------------------------------------------${font}"
	echo -e "${blues}1、更改角色限购一次为角色每日限购一次"
	echo -e "${blues}2、更改账号限购一次为账号每日限购一次"
	echo -e "${green}3、删除对角色限购的更改(还原为限购一次)"
	echo -e "${green}4、删除对账号限购的更改(还原为限购一次)"
	echo -e "${purple}------------------------------------------------------------${font}"

	local num # 用户选择

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-4]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 更改角色限购为每日限购 (创建/修改MySQL事件)
		# 开启事件调度器
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' <<-EOF
SET GLOBAL event_scheduler = ON;
EOF
		# 创建每日清理角色限购记录的事件
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' <<-EOF
DROP EVENT IF EXISTS daily_shopping_char; -- 先删除可能存在的旧事件
CREATE EVENT daily_shopping_char
  ON SCHEDULE EVERY 1 DAY
  STARTS STR_TO_DATE(DATE_FORMAT(NOW(), '%Y-%m-%d 06:00:00'), '%Y-%m-%d %H:%i:%s') -- 从下一个早上6点开始
DO
  DELETE FROM charac_cerashop_restrict
  WHERE count = 1; -- 删除限购次数为1的记录
EOF
		echo -e "${blues}更改完成! 角色限购已修改为每日限购。${font}"
		;;
	2)
		# 更改账号限购为每日限购 (创建/修改MySQL事件)
		# 开启事件调度器 (可能重复,但确保开启)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'd_taiwan' <<-EOF
SET GLOBAL event_scheduler = ON;
EOF
		# 创建每日清理账号限购记录的事件
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'd_taiwan' <<-EOF
DROP EVENT IF EXISTS daily_shopping_acc; -- 先删除可能存在的旧事件
CREATE EVENT daily_shopping_acc
  ON SCHEDULE EVERY 1 DAY
  STARTS STR_TO_DATE(DATE_FORMAT(NOW(), '%Y-%m-%d 06:00:00'), '%Y-%m-%d %H:%i:%s') -- 从下一个早上6点开始
DO
  DELETE FROM account_cerashop_restrict
  WHERE count = 1; -- 删除限购次数为1的记录
EOF
		echo -e "${blues}更改完成! 账号限购已修改为每日限购。${font}"
		;;
	3)
		# 还原角色限购为一次 (删除MySQL事件)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' <<-EOF
DROP EVENT IF EXISTS daily_shopping_char;
EOF
		echo -e "${blues}更改完成! 角色限购已还原为仅限购一次。${font}"
		;;
	4)
		# 还原账号限购为一次 (删除MySQL事件)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'd_taiwan' <<-EOF
DROP EVENT IF EXISTS daily_shopping_acc;
EOF
		echo -e "${blues}更改完成! 账号限购已还原为仅限购一次。${font}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		dailyShopping # 重新调用函数
		;;
	esac
}

# 角色栏锁定管理
function characterLock() {
	# 清屏
	clear
	# 显示菜单选项
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blues}1、自动锁定角色栏${red}[功能添加]${font}" 
	echo -e "${blues}2、自动锁定角色栏${red}[功能解除]${font}" 
	echo -e "${green}------------------------------------------------------------${font}"

	local num # 用户选择
	local number # 锁定的栏位数

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-2]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 添加自动锁定角色栏功能
		clear
		echo -e "${input}"
		echo -e "${red}回车则默认不锁定${font}" 

		# 获取锁定后剩余的角色栏数量
		echo -n -e "${determine}${yellow}锁定后剩余角色栏的数量:${font}"; read -r number </dev/tty 
		echo -e "${inputs}"

		# 检查输入是否为空
		if [[ -z ${number} ]]; then
			echo -e "${red}输入为空,结束!${font}" 
			return
		fi

		# 更新现有玩家的角色栏上限
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
UPDATE charac_view
SET charac_slot_limit = "${number}", slot_effect_count = "${number}"
WHERE charac_slot_limit <> "${number}" OR slot_effect_count <> "${number}"; -- Use OR to update if either value is different
EOF

		# 创建触发器,为新玩家设置角色栏上限
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DELIMITER \$
DROP TRIGGER IF EXISTS charac_view;
CREATE TRIGGER charac_view BEFORE INSERT ON charac_view FOR EACH ROW
-- Check if the default values (e.g., 18) are being inserted, then modify
IF new.charac_slot_limit = 18 AND new.slot_effect_count = 18 THEN
    SET new.charac_slot_limit = "${number}";
    SET new.slot_effect_count = "${number}";
END IF
\$
DELIMITER ;
EOF
		echo -e "${tip}所有玩家的可创建栏位已更改为${number}个!${font}"
		echo -e "${tip}角色栏位解锁道具代码:2660239!${font}"
		;;
	2)
		# 解除自动锁定角色栏功能 (删除触发器)
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain' << EOF
DROP TRIGGER IF EXISTS charac_view;
EOF
		echo -e "${tip}解除成功,新建角色的栏位不再锁定!${font}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		characterLock # 重新调用函数
		;;
	esac
}

# 清理服务器与数据库垃圾
function reduceLag() {
	# 清屏
	clear
	# 显示菜单选项
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blues}1、一键清理服务端与系统垃圾"
	echo -e "${blues}2、一键清理游戏数据库无用日志"
	echo -e "${blues}3、清理指定天数未登录的角色数据${reds}(慎用!)${font}"
	echo -e "${green}------------------------------------------------------------${font}"

	local num # 用户选择
	local DNF_DIR="/home/neople/" # DNF根目录
	local day # 清理天数
	local name # 角色名
	local cid # 角色ID
	local yes_and_no # 用户确认
	local Table_Name # 数据库名
	local tables # 表列表
	local table # 单个表名
	local number # 角色ID (循环变量)

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-3]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 清理服务端与系统垃圾文件
		echo -e "${tip}开始清理服务端日志和临时文件...${font}"
		# 使用 find 命令查找并删除指定类型的文件,-print 用于显示被删除的文件名
		find "${DNF_DIR}" -type f \( -name '*.log' -o -name 'core.*' -o -name '*.core' -o -name '*.error' -o -name '*.debug' -o -name '*.cri' \) -print -exec rm -f {} \;
		echo -e "${yellow}清理完成!${font}" 
		;;
	2)
		# 清理游戏数据库日志表
		mysqlCheck # 检查MySQL连接
		echo -e "开始清空日志库..."
		# 获取 taiwan_cain_log 数据库中的所有表名
		tables=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' "taiwan_cain_log" -N -e "SHOW TABLES;")
		# 遍历并清空每个表
		for table in ${tables}; do
			# 执行 TRUNCATE TABLE 命令并捕获输出和错误
			result=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' "taiwan_cain_log" -e "TRUNCATE TABLE ${table};" 2>&1)
			# 检查命令执行是否成功
			if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "SELECT 1;" >/dev/null 2>&1; then 
				echo -e "${table}表已清空"
			else
				echo -e "清空表 ${table} 失败:${result}"
			fi
		done
		echo -e "${yellow}清理完成!${font}" 
		;;
	3)
		# 清理指定天数未登录的角色数据 (高风险操作)
		echo -e "${warn}:使用此功能前请提前备份!"
		echo -e "${warn}:由于技术受限,删除后的角色仍旧存在选择栏!"
		echo -e "${warn}:实际该角色数据已全部删除,选择后会网络中断!"

		# 获取要清理的天数
		echo -n -e "${determine}${yellow}输入要删除离线时间大于的天数:${font}"; read -r day </dev/tty 

		# 检查输入是否为空
		if [[ -z ${day} ]]; then
			echo -e "${red}输入为空,结束!${font}" 
			return
		fi

		# 查询符合条件的角色名和ID
		name=$(mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_cain' -N -e "SELECT charac_name FROM charac_info WHERE DATEDIFF(NOW(), last_play_time) > ${day};")
		cid=$(mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D 'taiwan_cain' -N -e "SELECT charac_no FROM charac_info WHERE DATEDIFF(NOW(), last_play_time) > ${day};")

		# 显示将被删除的角色名
		echo -e "将被删除的角色名:\n${name}"
		# 获取用户确认
		echo -n -e "${determine}${yellow}即将删除以上角色数据,输入[确定]后继续操作:${font}"; read -r yes_and_no </dev/tty 
		if [[ "$yes_and_no" != "确定" ]]; then
			echo -e "${green}已取消!${font}"
			exit
		fi

		# 遍历 taiwan_cain_2nd 数据库中的所有表
		Table_Name="taiwan_cain_2nd"
		tables=$(mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D "${Table_Name}" -N -e "SHOW TABLES;")
		for table in ${tables}; do
			echo "处理表: ${table}"
			# 遍历需要删除的角色ID列表
			while IFS= read -r number; do
				# 删除表中对应角色ID的记录,忽略错误输出
				mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D "${Table_Name}" -e "DELETE FROM ${table} WHERE charac_no = '${number}';" 2>/dev/null
			done <<< "$cid"
		done
		# 可以在这里添加删除 taiwan_cain.charac_info 中记录的逻辑,但这会导致角色选择栏问题

		echo -e "已删除以下角色的数据:\n${name}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		reduceLag # 重新调用函数
		;;
	esac
}

# 拍卖行与寄售行管理
function auctionConsignment() {
	mysqlCheck # 检查MySQL连接
	# 清屏
	clear
	# 显示菜单选项
	echo -e "  --${blues}根据月份开启后面6个月,不会覆盖数据包,不需要五国${font}--
${Separator}

 ${greens}1. 开启金币拍卖行${font}

 ${green}2. 关闭金币拍卖行${font}

 ${greens}3. 开启点券寄售行${font}

 ${green}4. 关闭点券寄售行${font}

 ${blues}5、拍卖行上架时间修改为:${red}[24小时]${font} 

 ${blues}6、拍卖行上架时间修改为:${red}[240小时]${font} 

 ${blues}7、修复拍卖行接收邮件乱码${font}

 ${yellows}8、退回所有拍卖中的邮件[并且修复表项]${font} 

${Separator}" && echo

	local num # 用户选择
	local config_file="/etc/my.cnf" # MySQL配置文件路径
	local data_query # SQL查询语句
	local data # 查询结果
	local owner_id owner_name item_id add_info seal_flag upgrade amplify_option endurance amplify_value # 邮件数据字段
	local sql_file # SQL文件名

	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-8]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 开启金币拍卖行
		echo -e "${tip}正在为未来6个月创建金币拍卖行历史记录表...${font}"
		# 为未来6个月创建表,使用 $(...) 代替反引号
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<EOF >/dev/null 2>&1
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+0 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+0 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+1 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+1 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+2 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+2 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+3 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+3 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+4 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+4 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+5 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+5 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_$(date -d "+6 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_gold.auction_history_buyer_$(date -d "+6 month" +%Y%m) LIKE taiwan_cain_auction_gold.auction_history_buyer;
FLUSH TABLES taiwan_cain_auction_gold.auction_history, taiwan_cain_auction_gold.auction_history_buyer; -- Flush specific tables
EOF
		# 重启金币拍卖行进程
		killall -9 df_auction_r >/dev/null 2>&1
		cd /home/neople/auction || exit 1 
		chmod 755 ./* 
		rm -f ./pid/*.pid >/dev/null 2>&1 
		rm -rf ./log/*.* >/dev/null 2>&1 
		nohup ./df_auction_r ./cfg/auction_siroco.cfg start ./df_auction_r >/dev/null 2>&1 &
		cd || exit 1 
		echo -e "--${blues}开启完成,可能会有一分钟延迟。${font}--"
		;;
	2)
		# 关闭金币拍卖行
		killall -9 df_auction_r >/dev/null 2>&1
		cd /home/neople/auction || exit 1 
		# 清理pid和log文件
		rm -f ./pid/*.pid >/dev/null 2>&1 
		rm -rf ./log/*.* >/dev/null 2>&1 
		cd || exit 1 
		echo -e "--${blues}关闭成功!${font}--"
		;;
	3)
		# 开启点券寄售行
		echo -e "${tip}正在为未来6个月创建点券寄售行历史记录表...${font}"
		# 为未来6个月创建表
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<EOF >/dev/null 2>&1
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+0 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+0 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+1 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+1 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+2 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+2 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+3 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+3 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+4 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+4 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+5 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+5 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_$(date -d "+6 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history;
CREATE TABLE IF NOT EXISTS taiwan_cain_auction_cera.auction_history_buyer_$(date -d "+6 month" +%Y%m) LIKE taiwan_cain_auction_cera.auction_history_buyer;
FLUSH TABLES taiwan_cain_auction_cera.auction_history, taiwan_cain_auction_cera.auction_history_buyer; -- Flush specific tables
EOF
		# 重启点券寄售行进程
		killall -9 df_point_r >/dev/null 2>&1
		cd /home/neople/point || exit 1 
		chmod 755 ./* 
		rm -f ./pid/*.pid >/dev/null 2>&1 
		rm -rf ./log/*.* >/dev/null 2>&1 
		nohup ./df_point_r ./cfg/point_siroco.cfg start df_point_r >/dev/null 2>&1 &
		cd || exit 1 
		echo -e "--${blues}开启完成,可能会有一分钟延迟。${font}--"
		;;
	4)
		# 关闭点券寄售行
		killall -9 df_point_r >/dev/null 2>&1
		cd /home/neople/point || exit 1 
		# 清理pid和log文件
		rm -f ./pid/*.pid >/dev/null 2>&1 
		rm -rf ./log/*.* >/dev/null 2>&1 
		cd || exit 1 
		echo -e "--${blues}关闭成功!${font}--"
		;;
	5)
		# 修改拍卖行上架时间为24小时
		echo -e "${tip}正在下载并应用24小时拍卖行配置文件...${font}"
		# 下载并解压配置文件
		wget --no-check-certificate -q -O /tmp/auction24.tar.gz "${Url}paimai/auction24.tar.gz" >/dev/null 2>&1
		if tar -zxvf /tmp/auction24.tar.gz -C / >/dev/null 2>&1; then
			rm -f /tmp/auction24.tar.gz >/dev/null 2>&1
			# 重启拍卖行和寄售行进程
			killall -9 df_auction_r >/dev/null 2>&1
			cd /home/neople/auction || exit 1
			chmod 755 ./* 
			rm -f ./pid/*.pid >/dev/null 2>&1 
			rm -rf ./log/*.* >/dev/null 2>&1 
			nohup ./df_auction_r ./cfg/auction_siroco.cfg start ./df_auction_r >/dev/null 2>&1 &
			cd || exit 1

			killall -9 df_point_r >/dev/null 2>&1
			cd /home/neople/point || exit 1
			chmod 755 ./* 
			rm -f ./pid/*.pid >/dev/null 2>&1 
			rm -rf ./log/*.* >/dev/null 2>&1 
			nohup ./df_point_r ./cfg/point_siroco.cfg start df_point_r >/dev/null 2>&1 &
			cd || exit 1
			echo -e "${tip}上架时间已修改为24小时,预计1分钟后生效,不需要五国!${font}"
		else
			echo -e "${error}${reds}下载或解压配置文件失败!${font}"
			rm -f /tmp/auction24.tar.gz >/dev/null 2>&1
		fi
		;;
	6)
		# 修改拍卖行上架时间为240小时
		echo -e "${tip}正在下载并应用240小时拍卖行配置文件...${font}"
		# 下载并解压配置文件
		wget --no-check-certificate -q -O /tmp/auction240.tar.gz "${Url}paimai/auction240.tar.gz" >/dev/null 2>&1
		if tar -zxvf /tmp/auction240.tar.gz -C / >/dev/null 2>&1; then
			rm -f /tmp/auction240.tar.gz >/dev/null 2>&1
			# 重启拍卖行和寄售行进程
			killall -9 df_auction_r >/dev/null 2>&1
			cd /home/neople/auction || exit 1
			chmod 755 ./* 
			rm -f ./pid/*.pid >/dev/null 2>&1 
			rm -rf ./log/*.* >/dev/null 2>&1 
			nohup ./df_auction_r ./cfg/auction_siroco.cfg start ./df_auction_r >/dev/null 2>&1 &
			cd || exit 1

			killall -9 df_point_r >/dev/null 2>&1
			cd /home/neople/point || exit 1
			chmod 755 ./* 
			rm -f ./pid/*.pid >/dev/null 2>&1 
			rm -rf ./log/*.* >/dev/null 2>&1 
			nohup ./df_point_r ./cfg/point_siroco.cfg start df_point_r >/dev/null 2>&1 &
			cd || exit 1
			echo -e "${tip}上架时间已修改为240小时,预计1分钟后生效,不需要五国!${font}"
		else
			echo -e "${error}${reds}下载或解压配置文件失败!${font}"
			rm -f /tmp/auction240.tar.gz >/dev/null 2>&1
		fi
		;;
	7)
		# 修复拍卖行接收邮件乱码
		# 检查配置文件是否存在
		if [ -f "$config_file" ]; then
			# 检查 [client] 部分是否存在,不存在则添加
			if ! grep -qF "[client]" "$config_file"; then
				echo -e "\n[client]" >> "$config_file"
			fi
			# 检查 default-character-set 是否已设置为 latin1,不存在则添加
			if ! grep -q 'default-character-set=latin1' "$config_file"; then
				# 在 [client] 下添加或修改为 latin1
				sed -i '/\[client\]/a default-character-set=latin1' "$config_file"
				# 删除可能存在的其他 default-character-set 设置
				sed -i '/\[client\]/,/\[/{/default-character-set=latin1/!{/default-character-set=/d}}' "$config_file"
			fi
			echo -e "${yellow}修复成功! 字符集已设置为 latin1。${font}" 
		else
			echo -e "${error}${reds}MySQL 配置文件 ${config_file} 不存在!${font}"
		fi
		;;
	8)
		# 退回所有拍卖中的邮件并修复表项
		echo -e "${tip}正在备份 taiwan_cain_auction_gold.auction_main 表...${font}"
		# 备份 auction_main 表
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain_auction_gold' <<-EOF >/dev/null 2>&1
CREATE TABLE IF NOT EXISTS auction_main_backups LIKE auction_main;
TRUNCATE TABLE auction_main_backups; -- 清空旧备份
INSERT INTO auction_main_backups SELECT * FROM auction_main;
EOF
		then 
			echo -e "${yellow}退回邮件已完成,拍卖行暂时关闭,请重新开启!${font}"
			echo -e "${tip}${greens}原表已备份在 auction_main_backups!${font}"
			killall -9 df_auction_r >/dev/null 2>&1 # 关闭拍卖行进程
		else
			echo -e "${error}${reds}备份失败,可能文件已经存在或当前数据库不支持!${font}" 
			exit 1
		fi

		# 查询所有拍卖中的物品信息
		data_query="SELECT owner_id, owner_name, item_id, add_info, seal_flag, upgrade, amplify_option, endurance, amplify_value FROM auction_main ORDER BY owner_id ASC;"
		data=$(connectToDatabase "$data_query") # 调用重命名后的函数

		# 遍历查询结果并通过邮件发送给卖家
		while read -r owner_id owner_name item_id add_info seal_flag upgrade amplify_option endurance amplify_value
		do
			getRowData "$owner_id" "$owner_name" "$item_id" "$add_info" "$seal_flag" "$upgrade" "$amplify_option" "$endurance" "$amplify_value" # 调用重命名后的函数
		done <<< "$data"

		# 删除原拍卖表并重新创建
		echo -e "${tip}正在清空并重建拍卖行主表...${font}"
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain_auction_gold' <<-EOF >/dev/null 2>&1
DROP TABLE IF EXISTS auction_main;
EOF
		then 
			# 下载并执行拍卖行数据库结构SQL
			sql_file="/root/taiwan_cain_auction_gold.sql"
			wget --no-check-certificate -q -O "${sql_file}" "${Url}sql/taiwan_cain_auction_gold.sql" >/dev/null 2>&1
			if "/usr/local/mysql/bin/mysql" --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 < "${sql_file}"; then
				rm -f "${sql_file}"
				echo -e "${info}${greens}清退已完成,原表已备份在 auction_main_backups${font}"
			else
				echo -e "${error}${reds}执行SQL文件 ${sql_file} 失败!${font}"
				rm -f "${sql_file}"
			fi
		else
			echo -e "${error}${reds}清退失败, auction_main 表不存在或删除失败!${font}" 
		fi
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		auctionConsignment # 重新调用函数
		;;
	esac
}

# 连接数据库并执行查询 (重构自 connect_to_database)
# 参数1: SQL 查询语句
function connectToDatabase() {
  local query="$1" # SQL 查询语句
  # 执行查询, -s 静默模式, -N 不输出列名
  mysql --defaults-extra-file=/etc/my.cnf -h '127.0.0.1' -D taiwan_cain_auction_gold -s -N -e "$query"
}

# 获取行数据并通过邮件发送 (重构自 get_row_data)
# 参数: owner_id, owner_name, item_id, add_info, seal_flag, upgrade, amplify_option, endurance, amplify_value
function getRowData() {
	# 将参数赋值给局部变量,提高可读性
	local owner_id="$1"
	local owner_name="$2"
	local item_id="$3"
	local add_info="$4"
	local seal_flag="$5"
	local upgrade="$6"
	local amplify_option="$7"
	local endurance="$8"
	local amplify_value="$9"

	# 获取下一个可用的 postal_id
	local letter_id
	# 使用 $(...) 进行命令替换
	letter_id=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D taiwan_cain_2nd -s -N -e "SELECT IFNULL(MAX(postal_id), 0) + 1 FROM postal;")

	# 获取当前时间
	local current_time
	current_time=$(date +"%Y-%m-%d %H:%M:%S")

	# 插入邮件物品信息到 postal 表 (后台执行以提高效率)
	if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<EOF >/dev/null 2>&1 &
INSERT INTO taiwan_cain_2nd.postal (letter_id, occ_time, send_charac_name, receive_charac_no, item_id, add_info, seal_flag, upgrade, amplify_option, endurance, amplify_value)
VALUES ('${letter_id}', '${current_time}', 'GM', '${owner_id}', '${item_id}', '${add_info}', '${seal_flag}', '${upgrade}', '${amplify_option}', '${endurance}', '${amplify_value}');
EOF
	then 
		# 插入邮件信息到 letter 表 (后台执行以提高效率)
		if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<EOF >/dev/null 2>&1 &
INSERT INTO taiwan_cain_2nd.letter (reg_date, charac_no, send_charac_name, letter_text, stat)
VALUES ('${current_time}', '${owner_id}', 'GM', '拍卖行清退', '1');
EOF
		then 
			echo -e "${tip}${yellows}拍卖行清退:给${owner_name}发送[${item_id}]----[${add_info}]个${font}" 
		else
			echo -e "${error}${reds}插入 letter 表失败: 用户 ${owner_name} (ID: ${owner_id}), 物品 ${item_id}${font}"
		fi
	else
		echo -e "${error}${reds}插入 postal 表失败: 用户 ${owner_name} (ID: ${owner_id}), 物品 ${item_id}${font}"
	fi
}

# 清理并重新安装数据库 (重构自 cyzlcleardnf)
function clearAndReinstallDatabase() {
	# 清屏
	clear
	# 检查数据库版本是否支持
	if [[ ${mysql_version} == "5.0.95" ]]; then
		echo -e "${error}${red}当前数据库版本为[${mysql_version}],不支持该功能,请重新搭建!${font}" 
		exit 1
	fi

	# 获取用户确认 (高风险操作)
	echo -e "${warn}${reds}数据库清档不可恢复,确定要执行吗？${load}"
	local digit
	echo -n -e "${determine}${yellow}输入[我同意]后回车继续:${font}"; read -r digit </dev/tty 
	if [[ "$digit" != "我同意" ]]; then
		echo -e "已取消!"
		exit
	fi

	# 确保MySQL日志目录存在且权限正确
	if [ ! -d "/var/log/mysql" ]; then
		sudo mkdir -p /var/log/mysql
		sudo chown mysql:mysql /var/log/mysql
	fi

	# 停止所有相关服务进程
	echo -e "${tip}正在停止相关服务进程...${load}"
	local processes=(
		"df_stun_r" "df_monitor_r" "df_manager_r" "df_relay_r" "df_bridge_r"
		"df_channel_r" "df_dbmw_r" "df_auction_r" "df_point_r" "df_guild_r"
		"df_statics_r" "df_coserver_r" "df_community_r" "gunnersvr" "zergsvr"
		"df_game_r" "secagent"
	)
	for process in "${processes[@]}"; do
		killall -9 "${process}" >/dev/null 2>&1
	done

	# 初始化数据库
	echo -e "${tip}正在对数据库进行初始化${load}"
	service mysqld stop >/dev/null 2>&1
	# 停止 Xampp (如果存在)
	if [ -d "/opt/lampp" ]; then
		/opt/lampp/lampp stop >/dev/null 2>&1
		rm -rf /opt/lampp
	fi
	# 清理MySQL数据目录
	rm -rf "${mysqld}"* : Use rm -rf cautiously.
	cd / || exit 1 # 切换到根目录

	# 下载并解压MySQL基础数据文件
	echo -e "${tip}正在下载并解压MySQL基础数据文件...${load}"
	local mysql_tar_file="/tmp/tar_mysql.tar.gz"
	wget --no-check-certificate -q -O "${mysql_tar_file}" "${Url}tar_mysql.tar.gz" >/dev/null 2>&1
	if tar -zxvf "${mysql_tar_file}" -C / >/dev/null 2>&1; then
		# 设置数据目录权限
		chmod -R 0777 "${mysqld}"
		chown -R mysql.mysql "${mysqld}"
		# 升级数据库 (如果需要)
		mysql_upgrade --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' >/dev/null 2>&1
		# 启动MySQL服务
		service mysqld start
		# 检查MySQL服务状态
		if systemctl is-active --quiet mysqld || service mysqld status >/dev/null 2>&1; then 
			echo -e "${tip}数据库初始化成功!${success}" 
		else
			echo -e "${error}数据库启动失败,请检查MySQL错误日志!${font}" 
		fi
	else
		echo -e "${error}${reds}解压MySQL基础数据文件失败!${font}"
	fi

	# 清理临时文件
	rm -rf /tmp/*
	echo -e "${tip}数据库重装完成。${font}"
	# 不再自动退出,让用户看到结果
	# exit
}

# 数据库备份与还原管理 (重构自 Mysqlbackups)
function mysqlBackups() {
	# 清屏
	clear
	# 定义局部变量
	# local DB_USER='game' # 默认数据库用户名
	# local DB_PASSWORD='uu5!^%jg' # 默认数据库密码
	local DB_HOST='127.0.0.1' # 数据库主机
	local BACKUP_DIR_SPLIT='/root/mysqlbak/cc' # 拆分备份目录
	local BACKUP_DIR='/root/mysqlbak' # 主备份目录
	local num # 用户选择
	local digit # 用户确认
	local mysql_path # mysql命令路径
	local mysqldump_location # mysqldump命令路径
	local mysql_bin_dir # mysql bin目录
	local TAR_FILE # 压缩文件名
	local dnf_start dnf_end let_time # 计时变量
	local databases # 数据库列表
	local database backup_file ku # 循环变量
	local file_path file_size yujitime # 文件大小和预估时间

	# 确保主备份目录存在
	mkdir -p "${BACKUP_DIR}"

	# 显示菜单选项
	echo && echo -e "  --${blues}推荐使用sql的备份${font},当前数据库版本号${reds}[${mysql_version}]${font}--
  --${red}如果头铁非要用tar的格式来备份,还原无限127的话解决50一次${font}--

 1. ${reds}[备份]${font}${yellow}开始(gz)格式${reds}备份${font}${yellow}数据库${font}${red}[不推荐]${font}

 2. ${reds}[还原]${font}${yellow}开始(gz)格式${reds}还原${font}${yellow}数据库${font}${red}[不推荐]${font}

 3. ${reds}[备份]${font}${blues}开始<sql>格式拆分单个库${reds}备份${font}${blues}数据库${greens}[强烈推荐]${new}${font}

 4. ${reds}[还原]${font}${blues}开始<sql>格式拆分单个库${reds}还原${font}${blues}数据库${greens}[强烈推荐]${new}${font}

 5. ${reds}[备份]${font}${green}开始${reds}<sql>${green}格式${reds}备份${font}${green}数据库${font}${blues}[推荐]${font}

 6. ${reds}[还原]${font}${green}开始${reds}<sql>${green}格式${reds}还原${font}${green}数据库${font}${blues}[自动备份还原用它]${font}

 ${green}7. 设置${reds}<sql>${green}格式自动备份${font}

 ${greens}8. ${blues}设置自动备份并发送到另一台服务器${reds}[云端]${font}${new}${font}

 ${green}9. 取消所有自动备份[包括云端]${font}

 0. 退出"
	echo
	# 获取用户输入
	echo -n -e "${determine}${yellow}数字 [0-9]:${font}"; read -r num </dev/tty 

	# 根据用户选择执行操作
	case "${num}" in
	1)
		# 备份MySQL数据目录 (tar.gz格式, 不推荐)
		clear
		echo -e "${tip}${red}确定要以直接压缩来备份数据？${font}"
		echo -e "${tip}${red}这个备份很容易出错,不建议使用。${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty
		if [[ -z ${digit} ]]; then
			echo
			echo -e "${tip}正在备份数据目录 ${mysqld} ...${load}"
			if tar -zcvf "${BACKUP_DIR}/tar_mysql.tar.gz" "${mysqld}"; then
				echo -e "${tip}数据库备份完成! 文件 tar_mysql.tar.gz 备份在 ${BACKUP_DIR} 目录!"
			else
				echo -e "${error}${reds}备份失败!${font}"
			fi
		else
			echo -e "${info}已取消备份。${font}"
		fi
		;;
	2)
		# 还原MySQL数据目录 (tar.gz格式, 不推荐)
		clear
		echo -e "${tip}还原数据库前会自动停止当前已运行的服务器。"
		echo -e "${tip}请把要还原的备份文件命名为 mysql.tar.gz 并上传到 /root 目录!"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			if [ -f "/root/mysql.tar.gz" ]; then
				echo -e "${tip}正在停止相关服务并还原数据...${load}"
				/root/stop >/dev/null 2>&1 || true # 忽略停止脚本的错误
				service mysqld stop >/dev/null 2>&1
				rm -rf "${mysqld}"* 
				cd / || exit 1
				if tar -zxvf /root/mysql.tar.gz -C /; then
					service mysqld restart
					echo -e "${tip}数据库还原完成! 正在尝试停止游戏服务...${load}"
					cd || exit 1 # 返回用户主目录
					/root/stop >/dev/null 2>&1 || true # 再次尝试停止
					/root/stop >/dev/null 2>&1 || true
					echo -e "${tip}数据库还原完成! 5秒后重启系统${load}"
					sleep 5
					reboot
				else
					echo -e "${error}${reds}解压备份文件失败!${font}"
					# 尝试恢复MySQL服务
					service mysqld start >/dev/null 2>&1
				fi
			else
				echo -e "${error}${reds}/root/mysql.tar.gz 文件不存在!${font}"
			fi
		else
			echo -e "${info}已取消还原。${font}"
		fi
		;;
	3)
		# 备份数据库 (拆分SQL格式, 推荐)
		mysqlCheck # 检查MySQL连接

		# 检查并尝试修复 mysqldump
		mysql_path=$(which mysql)
		mysqldump_location="/usr/local/mysql/bin/mysqldump"
		mysql_bin_dir="/usr/local/mysql/bin/"
		if ! [ -x "$mysqldump_location" ]; then # 检查是否存在且可执行
			echo -e "${error}${reds}mysqldump检验失败, 开始尝试修复 ... ...${font}"
			if [ ! -d "$mysql_bin_dir" ]; then
				mkdir -p "$mysql_bin_dir"
			fi
			# 下载 mysqldump
			wget --no-check-certificate -q -O "${mysqldump_location}" "${Url}yum/mysqldump" >/dev/null 2>&1
			chmod 777 "${mysqldump_location}" >/dev/null 2>&1
			if ! [ -x "$mysqldump_location" ]; then
				echo -e "${error}${reds}修复 mysqldump 失败! 无法进行备份。${font}"
				exit 1
			fi
		fi

		clear
		echo -e "${tip}文件 sqlcc.tar.gz 将备份在 ${BACKUP_DIR}/ 目录!${load}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo
			dnf_start=$(date +%s) # 记录开始时间
			sudo mkdir -p "$BACKUP_DIR_SPLIT" # 创建拆分备份目录
			TAR_FILE="${BACKUP_DIR}/sqlcc.tar.gz"

			echo -e "${tip}${greens}正在备份,请耐心等候,数据越多用时越久!${font}"
			echo -e "${tip}${greens}备份完成时会提示完成,期间请勿关闭终端!${font}"

			# 定义备份单个数据库的函数
			function backup_database() {
				local database=$1
				local backup_file="$BACKUP_DIR_SPLIT/${database}.sql"
				# 执行 mysqldump 命令
				if "${mysqldump_location}" --defaults-extra-file=/etc/my.cnf -h "$DB_HOST" --skip-comments --routines --hex-blob --default-character-set=utf8 -B "$database" > "$backup_file"; then
					printf "\e[32;1m%-50s %s\e[0m\n" "${database}库" "[备份成功]"
				else
					printf "\e[31;1m%-50s %s\e[0m\n" "${database}库" "[备份失败]"
				fi
			}

			# 获取需要备份的数据库列表 (排除系统库)
			databases=$("${mysql_path}" --defaults-extra-file=/etc/my.cnf -h "$DB_HOST" -N -e 'show databases;' | grep -Ev "Database|information_schema|performance_schema|mysql|test")

			# 遍历并备份每个数据库
			for ku in ${databases}; do
				backup_database "$ku"
			done

			echo -e "${tip}${greens}数据备份完成,开始对其进行整合压缩!${font}"
			# 将备份文件压缩
			if tar -zcpf "$TAR_FILE" -C "$BACKUP_DIR_SPLIT" .; then
				rm -rf "$BACKUP_DIR_SPLIT" && sleep 1 # 删除临时备份目录
				dnf_end=$(date +%s) # 记录结束时间
				let_time=$((dnf_end-dnf_start)) # 计算耗时
				echo -e "${tip}${greens}数据库备份操作全部完成! 备份文件储存在 $TAR_FILE!${font}"
				echo -e "${tip}${greens}总用时间为:${let_time}秒${font}"
			else
				echo -e "${error}${reds}压缩失败,请检查权限!${font}" 
				# 保留 $BACKUP_DIR_SPLIT 供检查
			fi
		else
			echo -e "${info}已取消备份。${font}"
		fi
		;;
	4)
		# 还原数据库 (拆分SQL格式, 推荐)
		mysqlCheck # 检查MySQL连接
		clear
		echo -e "${tip}${greens}请把sql拆分备份的压缩包改名为:\"sqlcc.tar.gz\"放入 /root 目录!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			dnf_start=$(date +%s) # 记录开始时间
			TAR_FILE='/root/sqlcc.tar.gz'
			sudo mkdir -p "$BACKUP_DIR_SPLIT" # 创建解压目录

			if [ -f "$TAR_FILE" ]; then
				echo -e "${tip}${greens}备份文件存在,开始解压并还原数据库...${font}"
				# 解压备份文件
				if tar -zxf "$TAR_FILE" -C "$BACKUP_DIR_SPLIT"; then
					sleep 1
					cd "$BACKUP_DIR_SPLIT" || exit 1 # 进入解压目录

					# 遍历并还原每个SQL文件
					for database in *.sql; do # 假设文件名是 database.sql
						# 执行 mysql 命令还原数据库
						if "/usr/local/mysql/bin/mysql" --defaults-extra-file=/etc/my.cnf -h"$DB_HOST" --default-character-set=utf8 < "$database" 2>/dev/null; then
							printf "\e[32;1m%-50s %s\e[0m\n" "${database%.sql}库" "[还原成功]"
						else
							printf "\e[31;1m%-50s %s\e[0m\n" "${database%.sql}库" "[还原失败]"
							# 如果一个库还原失败,可以选择停止或继续
						fi
					done
					# 清理
					cd /root || exit 1
					rm -rf "$BACKUP_DIR_SPLIT"
					sleep 1
					# 重启MySQL服务
					systemctl restart mysqld >/dev/null 2>&1 || service mysqld restart >/dev/null 2>&1
					# 检查服务状态
					if systemctl is-active --quiet mysqld || service mysqld status >/dev/null 2>&1; then 
						dnf_end=$(date +%s) # 记录结束时间
						let_time=$((dnf_end-dnf_start)) # 计算耗时
						echo -e "${tip}${greens}数据还原成功,MySQL服务已成功启动!${font}"
						echo -e "${tip}${greens}总用时间为:${let_time}秒${font}"
					else
						echo -e "${error}${reds}MySQL服务未能成功启动,请检查错误日志。${font}" 
					fi
				else
					echo -e "${error}${reds}解压备份文件失败!${font}" 
					rm -rf "$BACKUP_DIR_SPLIT"
				fi
			else
				echo -e "${error}${reds}备份文件 $TAR_FILE 不存在。${font}" 
				rm -rf "$BACKUP_DIR_SPLIT" # 确保清理
			fi
		else
			echo -e "${info}已取消还原。${font}"
		fi
		;;
	5)
		# 备份数据库 (合并SQL格式)
		mysqlCheck # 检查MySQL连接
		clear
		echo -e "${tip}${reds}文件 sql.tar.gz 将备份在 ${BACKUP_DIR}/ 目录!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			echo -e "${tip}${reds}正在备份,请耐心等候,数据越多用时越久!${font}"
			echo -e "${tip}${reds}备份完成时会提示完成,期间请勿关闭终端!${font}"
			# 调用位于 /root/dof/sql 的备份脚本
			if [ -x "/root/dof/sql" ]; then
				cd /root/dof && ./sql && cd || echo -e "${error}${reds}备份脚本执行失败!${font}" 
			else
				echo -e "${error}${reds}备份脚本 /root/dof/sql 不存在或不可执行!${font}" 
			fi
		else
			echo -e "${info}已取消备份。${font}"
		fi
		;;
	6)
		# 还原数据库 (合并SQL格式)
		mysqlCheck # 检查MySQL连接
		clear
		echo -e "${tip}${greens}请把合并备份的压缩包改名为:\"sql.tar.gz\"放入 /root 目录!${font}"
		echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty 
		if [[ -z ${digit} ]]; then
			file_path="/root/sql.tar.gz"
			# 检查备份文件是否存在
			if [ ! -f "$file_path" ]; then
				echo -e "${error}${reds}备份文件 ${file_path} 不存在!${font}"
				exit 1
			fi

			# 定义计算文件大小和预估时间的函数
			function getFileSizeAndTime() {
				local f_path=$1
				local f_size f_size_mb est_time
				f_size=$(stat -c%s "$f_path")
				f_size_mb=$((f_size / (1024 * 1024)))
				# 预估时间,例如每MB大约2秒
				est_time=$((f_size_mb * 2))
				echo "$est_time" # 返回预估时间
			}

			yujitime=$(getFileSizeAndTime "$file_path")

			echo -e "${tip}正在停止游戏服务...${load}"
			/root/stop >/dev/null 2>&1 || true # 忽略错误
			/root/stop >/dev/null 2>&1 || true

			echo -e "${tip}正在解压备份文件...${load}"
			if tar -zxvf "$file_path" -C /; then
				echo -e "开始还原,预估时间为[${yujitime}]秒,请耐心等待~"
				# 进入备份目录并执行还原
				cd "${BACKUP_DIR}" || exit 1 # 假设解压到了 BACKUP_DIR
				if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 < dnf.sql; then
					echo -e "${tip}${greens}恭喜你,还原数据成功${font}"
					# 还原后重置game用户密码为默认
					if mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF
UPDATE mysql.user SET PASSWORD=PASSWORD('uu5!^%jg') WHERE User='game' AND (Host='%' OR Host='localhost' OR Host='127.0.0.1');
FLUSH PRIVILEGES;
EOF
					then 
						echo -e "数据库地址为:${IP}"
						echo -e "数据库账号为:game"
						echo -e "数据库密码为:uu5!^%jg"
					else
						echo -e "${warn}${yellows}重置数据库密码失败,请手动检查。${font}"
					fi
				else
					echo -e "${error}${reds}还原失败,请检查数据库连接或SQL文件。${font}"
				fi
				# 清理临时的SQL文件
				rm -f dnf.sql
				cd /root || exit 1 # 返回/root目录
			else
				echo -e "${error}${reds}解压备份文件失败!${font}"
			fi
		else
			echo -e "${info}已取消还原。${font}"
		fi
		;;
	7)
		# 设置SQL格式自动备份
		mysqlCheck # 检查MySQL连接
		autoBackupSql # 调用自动备份设置函数
		;;
	8)
		# 设置自动备份并发送到云端
		scpAutoBackupMysql # 调用云端备份设置函数
		;;
	9)
		# 取消所有自动备份
		echo -e "${tip}正在取消所有自动备份任务...${load}"
		# 删除cron配置文件和脚本
		rm -f /etc/crontab # 谨慎操作,这会删除系统crontab
		rm -f /etc/cron.hourly/back
		rm -f /etc/cron.d/0hourly
		# 停止cron服务
		service crond stop >/dev/null 2>&1 || systemctl stop crond >/dev/null 2>&1
		echo -e "${tip}已取消所有自动备份设置${load}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!" 
		sleep 1
		mysqlBackups # 重新调用函数
		;;
	esac
}

# 设置自动备份到远程服务器
function scpAutoBackupMysql() {
	clear
	echo && echo -e "${blues}[云端定时备份]安装云端自动备份mysql程序${font}"
	echo
	echo -e "检测自动备份相关组件..."
	echo -e "${tip}yum源检查开始|预计需要1-100秒,请耐心等待。"
	# 安装 expect 和 crontabs
	yum -y install expect >/dev/null 2>&1
	yum install -y crontabs >/dev/null 2>&1 && chkconfig crond on

	echo -e "${tip}yum源检查完毕${font}" && sleep 1s

	# 创建 expect 脚本用于 SCP 传输
	local expect_script_path="/root/dof/cloudscp"
	local backup_script_path="/root/dof/sql"
	local cron_script_path="/etc/cron.hourly/back"
	local cron_conf_path="/etc/cron.d/0hourly"
	local scpip # 远程服务器IP
	local scpmm # 远程服务器密码
	local hour # 备份间隔小时数

	# 确保 /root/dof 目录存在
	mkdir -p /root/dof

	# 取消旧脚本的不可修改属性
	chattr -i "${expect_script_path}" >/dev/null 2>&1
	# 删除旧脚本
	rm -f "${expect_script_path}" >/dev/null 2>&1

	# 创建新的 expect 脚本
	cat <<EOF >"${expect_script_path}"
#!/usr/bin/expect
# 设置超时时间
set timeout 120
# 获取周几和当前时间戳
set week [exec date +%A]
set time [exec date +%m%d%H]
# 获取本地IP
set IP [exec wget -qO - ifconfig.co || echo "127.0.0.1"]

# 检查参数数量
if {\$argc != 2} {
    send_user "用法: expect cloudscp <远程IP> <远程密码>\n"
    exit 1
}
# 获取远程IP和密码参数
set remote_ip [lindex \$argv 0]
set pwd [lindex \$argv 1]

# 本地备份文件路径
set local_backup_file "/root/mysqlbak/sql_\${IP}_\${time}.tar.gz"
# 远程备份文件路径 (按周覆盖)
set remote_backup_file "/mnt/sql_\${IP}_\${week}.tar.gz"

# 检查本地备份文件是否存在
if {![file exists \$local_backup_file]} {
    send_user "错误: 本地备份文件 \$local_backup_file 不存在。\n"
    exit 1
}

# 执行 SCP 命令
spawn /usr/bin/scp "\$local_backup_file" "root@\$remote_ip:\$remote_backup_file"

# 处理 SSH 首次连接确认 和 密码输入
expect {
    "*yes/no*" { send "yes\r"; exp_continue }
    "*assword:" { send "\$pwd\r" }
    timeout { send_user "错误: SCP 连接超时。\n"; exit 1 }
    eof { } ;# 正常结束
    error { send_user "错误: SCP 命令执行失败。\n"; exit 1 }
}
# 等待 SCP 命令执行完毕
expect eof
EOF
	# 设置脚本权限
	chmod 777 "${expect_script_path}" >/dev/null 2>&1
	# 重新设置不可修改属性 (可选)
	# chattr +i "${expect_script_path}" >/dev/null 2>&1

	clear
	echo -e "${input}"
	echo -e "${red}备份将发送到指定的CentOS服务器, 最多保留7天的备份 (按周几覆盖)。${font}"  
	# 获取远程服务器IP
	echo -n -e "${determine}${yellow}欲发送的服务器IP (留空则使用默认服务器):${font}"; read -r scpip </dev/tty 

	if [[ -z ${scpip} ]]; then
		scpip="XX.XX.XX.XX" # 服务器IP
		scpmm="XXXXXXXX" # 服务器密码
		echo -e "${info}使用默认服务器: ${scpip}${font}"
		# 创建cron任务脚本
		cat <<EOF >"${cron_script_path}"
#!/bin/bash
# 先执行本地备份脚本
if [ -x "${backup_script_path}" ]; then
    cd /root/dof && "${backup_script_path}"
else
    echo "错误: 本地备份脚本 ${backup_script_path} 不存在或不可执行。" >&2
    exit 1
fi
# 执行 expect 脚本进行 SCP 传输
if [ -x "${expect_script_path}" ]; then
    expect "${expect_script_path}" "${scpip}" "${scpmm}"
else
    echo "错误: Expect 脚本 ${expect_script_path} 不存在或不可执行。" >&2
    exit 1
fi
cd 
EOF
		setupCronJob "${cron_script_path}" "${cron_conf_path}" # 调用设置cron任务的函数
		return # 直接返回
	fi

	echo -e "${inputs}"
	echo -e "${input}"
	# 获取远程服务器密码
	echo -n -e "${determine}${yellow}欲发送的服务器密码:${font}"; read -s -r scpmm </dev/tty , -s 隐藏输入
	echo # 换行
	echo -e "${inputs}"

	# 检查密码是否为空
	if [[ -z ${scpmm} ]]; then
		echo -e "${error}${reds}密码不能为空!${font}" 
		return 1
	fi

	# 创建cron任务脚本
	cat <<EOF >"${cron_script_path}"
#!/bin/bash
# 先执行本地备份脚本
if [ -x "${backup_script_path}" ]; then
    cd /root/dof && "${backup_script_path}"
else
    echo "错误: 本地备份脚本 ${backup_script_path} 不存在或不可执行。" >&2
    exit 1
fi
# 执行 expect 脚本进行 SCP 传输
if [ -x "${expect_script_path}" ]; then
    expect "${expect_script_path}" "${scpip}" "${scpmm}"
else
    echo "错误: Expect 脚本 ${expect_script_path} 不存在或不可执行。" >&2
    exit 1
fi
cd 
EOF

	setupCronJob "${cron_script_path}" "${cron_conf_path}" # 调用设置cron任务的函数
}

# 设置Cron定时任务 (重构自 scp2)
# 参数1: cron 任务脚本路径
# 参数2: cron 配置文件路径
function setupCronJob() {
	local cron_script_path="$1"
	local cron_conf_path="$2"
	local hour # 备份间隔小时数

	clear
	echo -e "${red}建议备份间隔为12小时一次,避免占用过多带宽。${font}" 
	# 获取备份间隔
	echo -n -e "${determine}${yellow}每日自动备份时间间隔 [1-23]小时 (默认:12小时):${font}"; read -r hour </dev/tty 

	# 设置默认间隔为12小时
	
	if [[ -z ${hour} ]]; then
		hour=12
	fi
	# 检查输入是否为有效数字且在范围内
	if ! [[ "${hour}" =~ ^[0-9]+$ ]] || [[ "${hour}" -lt 1 ]] || [[ "${hour}" -gt 23 ]]; then
		echo -e "${warn}无效的输入, 使用默认间隔 12 小时。${font}"
		hour=12
	fi

	# 创建cron配置文件
	cat <<EOF >"${cron_conf_path}"
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root:/usr/local/sbin:/usr/local/bin # 添加更多路径
MAILTO=root
HOME=/
# 每 ${hour} 小时执行一次 /etc/cron.hourly 目录下的所有脚本
0 */${hour} * * * root run-parts /etc/cron.hourly
EOF

	# 设置cron任务脚本权限
	chmod -R a+x /etc/cron.hourly
	# 重启cron服务
	service crond restart >/dev/null 2>&1 || systemctl restart crond >/dev/null 2>&1
	sleep 1s
	echo
	echo -e "${info}自动备份安装完成!${success}" && echo 
	echo -e "${info}开始试运行,结束时候会提示[试运行完成]!${font}" && echo 
	echo -e "${info}请耐心等待,数据越大时间越久!${font}" && echo 

	# 试运行备份脚本
	if [ -x "${cron_script_path}" ]; then
		# 进入脚本所在目录执行（如果脚本需要相对路径）
		# cd "$(dirname "${cron_script_path}")" && ./"$(basename "${cron_script_path}")"
		# 或者直接执行绝对路径
		"${cron_script_path}"
		cd || exit
		echo -e "${info}${black_cyan_blink}试运行完成!${success}" && echo 
		echo -e "${info}${black_cyan_blink}本地自动备份文件保存在 /root/mysqlbak/ 目录下。${font}" 
		echo -e "${info}${black_cyan_blink}接收服务器的自动备份文件保存在 /mnt 目录下 (按周覆盖)。${font}" 
	else
		echo -e "${error}${reds}Cron 任务脚本 ${cron_script_path} 不存在或不可执行! 试运行失败。${font}" 
	fi
	# 不再自动退出
	# exit
}

# 设置本地自动SQL备份
function autoBackupSql() {
	clear
	echo && echo -e "${blues}[定时备份]安装自动备份mysql程序${font}"
	echo && echo -e "${blues}[定时备份]定时失效问题已修复${font}"
	echo
	echo -e "检测自动备份相关组件..."
	# 安装 crontabs 并设置开机自启
	yum install -y crontabs >/dev/null 2>&1 && chkconfig crond on

	local backup_script_path="/root/dof/sql" # 本地备份脚本路径
	local cron_script_path="/etc/cron.hourly/back"
	local cron_conf_path="/etc/cron.d/0hourly"
	local hour # 备份间隔

	# 创建 cron 任务脚本
	cat <<EOF >"${cron_script_path}"
#!/bin/bash
# 执行本地备份脚本
if [ -x "${backup_script_path}" ]; then
    cd /root/dof && "${backup_script_path}"
else
    echo "错误: 本地备份脚本 ${backup_script_path} 不存在或不可执行。" >&2
    exit 1
fi
cd || exit 
EOF
	echo && echo
	# 获取备份间隔
	echo -n -e "${determine}${yellow}每日自动备份时间间隔 [1-23]小时 (默认:12小时):${font}"; read -r hour </dev/tty 

	# 设置默认间隔为12小时
	
	if [[ -z ${hour} ]]; then
		hour=12
	fi
	# 检查输入是否为有效数字且在范围内
	if ! [[ "${hour}" =~ ^[0-9]+$ ]] || [[ "${hour}" -lt 1 ]] || [[ "${hour}" -gt 23 ]]; then
		echo -e "${warn}无效的输入, 使用默认间隔 12 小时。${font}"
		hour=12
	fi

	# 创建cron配置文件
	cat <<EOF >"${cron_conf_path}"
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root:/usr/local/sbin:/usr/local/bin # 添加更多路径
MAILTO=root
HOME=/
# 每 ${hour} 小时执行一次 /etc/cron.hourly 目录下的所有脚本
1 */${hour} * * * root run-parts /etc/cron.hourly # 使用 1 分钟偏移,避免同时执行
EOF

	# 设置cron任务脚本权限
	chmod -R a+x /etc/cron.hourly
	# 重启cron服务
	service crond restart >/dev/null 2>&1 || systemctl restart crond >/dev/null 2>&1
	sleep 1s
	echo
	echo -e "${info}${black_cyan_blink}自动备份安装完成!${success}" && echo 
	echo -e "${info}${black_cyan_blink}自动备份文件保存在 /root/mysqlbak/ 目录下。${font}" 
}

# 显示旋转加载指示器 (重构自 spin)
# 参数1: 要监控的进程PID
function showSpinner() {
    local -r pid=$1 # 进程PID
    local delay=0.1 # 旋转延迟
    # shellcheck disable=SC1003
    local spinstr='|/-\\' # 旋转字符

    # 当进程存在时循环显示旋转字符
    while kill -0 "$pid" 2>/dev/null; do
        local temp=${spinstr#?} # 获取除第一个字符外的剩余部分
        printf " [%c]  " "$spinstr" # 打印当前旋转字符
        spinstr=$temp${spinstr%"$temp"} # 将第一个字符移到末尾
        sleep $delay # 等待
        printf "\\b\\b\\b\\b\\b\\b" # 使用退格符覆盖之前的输出
    done
    printf "       \\b\\b\\b\\b\\b\\b" # 清理最后的旋转字符
}

# 执行命令并检查是否成功,显示状态和错误信息 (重构自 check_success)
# 参数1: 操作描述
# 参数2...: 要执行的命令及其参数
function checkSuccess() {
    local -r desc=$1 # 操作描述
    shift # 移除第一个参数 (描述)
    local -r cmd=("$@") # 剩余参数作为命令
    local -r temp_file=$(mktemp) # 创建临时文件存储错误输出

    # 在后台执行命令,并将标准错误重定向到临时文件
    echo -n "$desc..." # 显示操作描述
    "${cmd[@]}" > /dev/null 2> "$temp_file" &

    local -r cmd_pid=$! # 获取后台命令的PID
    showSpinner "$cmd_pid" # 显示旋转指示器

    # 等待命令执行结束
    wait "$cmd_pid"
    local -r status=$? # 获取命令退出状态

    # 根据退出状态判断成功或失败
    if [ $status -ne 0 ]; then
        # 命令失败
        local err_msg # 错误信息
        err_msg=$(<"$temp_file") # 从临时文件读取错误信息
        # 使用 ANSI 转义码显示红色失败标记
        
        echo -e "\\r\e[0;31m[失败]\e[0m $desc"
        # 显示错误信息
        echo "错误信息:$err_msg"
    else
        # 命令成功
        # 使用 ANSI 转义码显示绿色成功标记
        echo -e "\\r\e[0;32m[成功]\e[0m $desc"
    fi
    # 删除临时文件
    rm -f "$temp_file"
}

# UDP项目管理菜单
# 提供UDP转发设置、UDP封堵和解除封堵的功能
function udpProject() {
	clear
	echo -e "${green}------------------------------------------------------------${font}"
	echo -e "${blue}1、UDP转发[解决组队问题]${font}"
	echo -e "${green}2、UDP封堵[解决发包炸频道问题和UDP攻击]${font}"
	echo -e "${green}3、UDP解除封堵${font}"
	echo -e "${green}------------------------------------------------------------${font}"
	local num # 用户选择
	echo -n -e "${determine}${yellow}数字 [0-3]:${font}"; read -r num </dev/tty
	case "${num}" in
	1)
		# 设置UDP转发
		setupUdpForwarding
		;;
	2)
		# 封堵UDP流量
		clear
		# 使用 checkSuccess 函数简化命令执行和状态检查
		checkSuccess "下载 iptables 管理工具" sudo yum install iptables-services -y
		checkSuccess "开启 iptables 防火墙" sudo systemctl start iptables
		checkSuccess "设置 iptables 自动启动" sudo systemctl enable iptables
		checkSuccess "生成 iptables 规则文件" sudo service iptables save
		# 使用 here document 写入 iptables 规则
		checkSuccess "写入 iptables 初始规则（放通所有TCP 禁止UDP）" sudo bash -c 'cat > /etc/sysconfig/iptables <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0] # 建议设置为0:0

# 允许已建立的连接和相关连接
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# 允许 ICMP 流量（例如 ping）
-A INPUT -p icmp -j ACCEPT

# 允许本地回环接口流量
-A INPUT -i lo -j ACCEPT

# 允许所有入站的 TCP 流量
-A INPUT -p tcp -j ACCEPT

# 丢弃所有入站的 UDP 流量
-A INPUT -p udp -j DROP

COMMIT
EOF'
		checkSuccess "重启 iptables 部署完成,所有操作已完成!" sudo systemctl restart iptables
		;;
	3)
		# 解除UDP封堵
		clear
		# 清空iptables规则并设置默认策略为ACCEPT
		sudo iptables -F INPUT
		sudo iptables -F FORWARD
		sudo iptables -F OUTPUT
		sudo iptables -P INPUT ACCEPT
		sudo iptables -P FORWARD ACCEPT
		sudo iptables -P OUTPUT ACCEPT
		# 删除iptables配置文件
		sudo rm -f /etc/sysconfig/iptables # 添加 -f 强制删除

		echo -e "${yellow}已解除UDP流量封堵!${font}"
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		udpProject # 重新调用自身
		;;
	esac
}

# 设置UDP转发IP (原 zdudp_dnf)
# 修改配置文件中的 stun_ip 指向指定的转发IP
function setupUdpForwarding() {
	# 切换到配置文件目录
	cd /home/neople/game/cfg || { echo "${error}无法切换到目录 /home/neople/game/cfg"; return 1; } # 添加错误处理
	clear
	echo -e "${input}"
	echo -e "${tip}${blue}输入一个搭建好DOF且端口全开的IP${font}"
	echo -e "${tip}${blue}如果自己实在没有,转发到122333${font}"
	local udpIp # UDP转发IP
	echo -n -e "${determine}${yellow}请在此处输入你的UDP转发IP(默认:${IP}): ${font}"; read -r udpIp </dev/tty
	echo
	# 如果用户未输入,则使用本机IP
	if [[ -z ${udpIp} ]]; then
		udpIp=${IP}
	fi
	# 如果用户输入122333,则使用从PHP获取的UDP地址
	if [[ ${udpIp} = 122333 ]]; then
		udpIp="${udp_php:-$backup_server}"
	fi
	# 使用 find 和 sed 批量修改配置文件中的 stun_ip
	# 使用更健壮的sed命令,处理空格和等号周围的空格
	find . -type f -name "*.cfg" -print0 | xargs -0 sed -i "s/^[[:space:]]*stun_ip[[:space:]]*=.*$/stun_ip = ${udpIp}/g" >/dev/null 2>&1
	echo -e "${tip}${greens}UDPIP已转发为: ${udpIp}${font}" && sleep 1s
	echo -e "${tip}${greens}跑五国后才会生效!!!!!!${font}" && sleep 1s
	echo -e "${inputs}"
	cd - || exit
}

# 管理DP插件 : 提供DP插件的安装、卸载、配置以及相关修复功能
function manageDpPlugin() {
	local activated # 插件激活状态显示
	local choice # 用户菜单选择
	local confirm # 用户确认
	# 查询轨迹的用户名已移除（未使用变量）

	# 检查交易记录功能是否激活 (假设通过检查特定字符串判断)
	if grep -q "shopkeeper" "/dp2/df_game_r.js" 2>/dev/null; then
		activated="${greens}<已激活>${font}"
	else
		activated="${reds}<未激活>${font}"
	fi

	clear
	# 显示插件管理菜单
	echo -e "${shelltitle}"
	echo -e "                      插件安装与卸载"
	echo -e "${Separator}"
	echo -e "  (1) ${yellows}安装新版本DP插件(动态播报红包等等)${font}"
	echo -e "  (old) ${green}安装旧版本DP插件(无动态彩色播报)${font}"
	echo -e "  (2) ${red}卸载DP插件${font}"
	echo -e "  (3) ${yellows}DP插件${blue}开启${yellows}功能选项${font}"
	echo -e "  (4) ${yellows}DP插件${red}关闭${yellows}功能选项${font}"
	echo -e "  (5) ${yellow}领取升级邮件报错问题[修复]${font}"
	echo -e "  (6) ${yellow}领取升级邮件报错问题[还原]${font}"
	echo -e "  (7) ${yellow}dp内输入[//签到判定改为][角色]${font}"
	echo -e "  (8) ${yellow}dp内输入[//签到判定改为][账号]${font}"
	echo -e "  (9) ${reds}可安装玩家之间交易记录[收费]${font}"
	echo -e "${Separator}"
	echo -e "  (x) ${yellows}查询插件中的角色轨迹[玩家之间交易记录${activated}]${font}"
	echo -e "${Separator}"
	echo -e "  (0) ${black_cyan_blink}退出安装${font}" && echo

	
	echo -n -e "${determine}${yellow}数字 [0-9, od, x]:${font}"; read -r choice </dev/tty

	case "${choice}" in
	1)
		# 安装新版本DP插件
		installDpFrida # 调用安装函数 (原 dp_frida)
		;;
	2)
		# 卸载DP插件
	

		echo -n -e "${determine}${yellow}即将停止服务端[输入确定后继续]${font}"; read -r confirm </dev/tty
		if [[ "${confirm}" != "确定" ]]; then
			echo -e "${green}已取消!${font}"
			exit
		fi
		# 停止服务
		./stop >/dev/null 2>&1; ./stop >/dev/null 2>&1 # 尝试停止两次

		echo -e "${yellow}开始删除DP插件文件！${font}"
		cd / || { echo "${error}无法切换到根目录"; return 1; } # 切换到根目录
		rm -rf /dp2 # 删除插件目录
		# 从启动脚本中移除DP插件的加载项
		sed -i "s|/dp2/libdp2pre.so ||g" /root/run
		sed -i "s|LD_PRELOAD=../df_game_r|LD_PRELOAD=./df_game_r|g" /root/run # 恢复可能的旧设置
		sed -i 's|LD_PRELOAD="" ./df_game_r|./df_game_r|g' /root/run # 移除空的LD_PRELOAD

		echo -e "${yellow}删除完成！${font}"
		;;
	3)
		# 开启DP插件功能选项
		enableDpFeatures # 调用开启功能函数 (原 switch_1)
		;;
	4)
		# 关闭DP插件功能选项
		disableDpFeatures # 调用关闭功能函数 (原 switch_2)
		;;
	5)
		# 修复领取升级邮件报错问题
		fixUpgradeMailError
		;;
	6)
		# 还原领取升级邮件报错问题的修复
		revertUpgradeMailErrorFix
		;;
	7)
		# 修改DP签到判定为角色
		setDpCheckinMode "character"
		;;
	8)
		# 修改DP签到判定为账号
		setDpCheckinMode "account"
		;;
	9)
		# 显示收费交易记录功能信息
		displayPaidTradeLogInfo
		;;
	x)
		# 查询插件中的角色轨迹
		queryPlayerTrace
		;;
	od)
		# 安装旧版本DP插件
		installOldDpPlugin
		;;
	0)
		# 退出脚本
		exit
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		manageDpPlugin # 重新调用自身
		;;
	esac
}

# 修复领取升级邮件报错问题
function fixUpgradeMailError() {
	# 添加触发器以处理非标准字符的发送者名称
	mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain_2nd' << EOF
DELIMITER \$
DROP TRIGGER IF EXISTS postal_fix_sender; -- 使用更明确的触发器名称
CREATE TRIGGER postal_fix_sender BEFORE INSERT ON postal FOR EACH ROW
BEGIN
    -- 检查发送者名称是否只包含字母、数字、空格和标点符号
    IF NOT (NEW.send_charac_name REGEXP '^[a-zA-Z0-9[:space:][:punct:]]*$') THEN
        SET NEW.send_charac_name = 'Unrecognized'; -- 将无法识别的名称替换为 'Unrecognized'
    END IF;
END \$
DELIMITER ;

DELIMITER \$
DROP TRIGGER IF EXISTS letter_fix_sender; -- 使用更明确的触发器名称
CREATE TRIGGER letter_fix_sender BEFORE INSERT ON letter FOR EACH ROW
BEGIN
    -- 检查发送者名称是否只包含字母、数字、空格和标点符号
    IF NOT (NEW.send_charac_name REGEXP '^[a-zA-Z0-9[:space:][:punct:]]*$') THEN
        SET NEW.send_charac_name = 'Unrecognized'; -- 将无法识别的名称替换为 'Unrecognized'
        SET NEW.letter_text = 'Emailrewards'; -- 同时设置邮件内容
    END IF;
END \$
DELIMITER ;
EOF
	echo -e "${tip}${blue}修复完成,后续角色获得升级邮件将不会再报错!${font}"
}

# 还原领取升级邮件报错问题的修复
function revertUpgradeMailErrorFix() {
	# 删除修复触发器
	mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -D'taiwan_cain_2nd' << EOF
DROP TRIGGER IF EXISTS postal_fix_sender;
DROP TRIGGER IF EXISTS letter_fix_sender;
EOF
	echo -e "${tip}${blue}还原完成!${font}"
}

# 设置DP签到判定模式
# 参数1: mode ("character" 或 "account")
function setDpCheckinMode() {
	local mode="$1"
	local target_file="/dp2/dof/Work_Reload.lua"
	local replacement

	if [[ "${mode}" == "character" ]]; then
		replacement="local characName = user:GetCharacName()"
	elif [[ "${mode}" == "account" ]]; then
		replacement="local characName = user:GetAccId()"
	else
		echo -e "${error}无效的签到模式: ${mode}"
		return 1
	fi

	# 使用 sed 修改 Lua 文件中的判定逻辑
	# 使用更精确的匹配模式,避免误改其他行
	if sed -i "s|^[[:space:]]*local[[:space:]]\+characName[[:space:]]*=.*$|${replacement}|g" "${target_file}"; then
		echo -e "${tip}${blue}签到判定模式已设置为 [${mode}]!${font}"
	else
		echo -e "${error}修改文件 ${target_file} 失败!"
	fi
}

# 显示收费交易记录功能信息
function displayPaidTradeLogInfo() {
	clear
	echo -e "${info}${blue}1, 玩家之间站街交易记录${font}"
	echo -e "${info}${blue}2, 玩家之间邮件发送记录${font}"
	echo -e "${info}${blue}3, 玩家之间摆摊购买记录${font}"
	echo
	echo
	echo -e "${tip}${blue}联系Q:1296792130手动安装, [100/不限IP数量, 一次购买永久使用]!${font}"
}

# 查询插件中的角色轨迹
function queryPlayerTrace() {
	local log_dir="/dp2/frida_log"
	local keyword
	local output_log

	# 检查日志目录是否存在且包含日志文件
	if ls "${log_dir}"/*.log > /dev/null 2>&1; then
	

		echo -n -e "${determine}${yellow}关键词:${font}"; read -r keyword </dev/tty
		# 如果未输入关键词,则使用默认值
		if [[ -z "${keyword}" ]]; then
			keyword="1"
		fi
		echo -e "${green}${Separator}${font}"
		output_log="${log_dir}/${keyword}.log"
		# 使用 grep -h 合并搜索结果并输出到指定文件
		if grep -h "${keyword}" "${log_dir}"/*.log > "${output_log}"; then
			echo -e "${tip}${blue}:关于[${blue}${keyword}${font}${blue}]的所有日志已储存到 ${output_log} 文件内!${font}"
		else
			echo -e "${warn}未找到包含关键词 '${keyword}' 的日志记录。"
			rm -f "${output_log}" # 删除空的输出文件
		fi
	else
		echo -e "${error}${reds}无效路径 ${log_dir}/ 或者 不存在 .log 文件${font}"
	fi
}

# 安装旧版本DP插件
function installOldDpPlugin() {
	clear
	echo -e "
${Separator}
跨界石,异界重置券,装备继承券,20级直升券,宠物删除券,一键分解券
女鬼转职券,点券增加券,签到拿低保,区域奖励,深渊播报,多黄奖励
交易记录,通关播报,防卡商店,镶嵌修复
${Separator}" && echo
	local digit # 用户确认
	local sybb luck dungeon_clearance # 插件选项
	local sfyg=2 fridaor=2 # 其他插件兼容性选项,默认为否
	local run_script_content # /root/run 脚本内容


	
	echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty
	if [[ -n ${digit} ]]; then # 如果用户输入了任何内容（非空）,则取消
		echo -e "${info}已取消安装。${font}"
		return
	fi
	echo

	echo -e "${green}开始下载旧版本dp2插件所需文件(解压在[/dp2/])${font}"
	# 下载并解压旧版本插件
	if ! wget --no-check-certificate -q -O /tmp/dp2_old.tar.gz "${Url}dp2/odp2.tar.gz"; then
		echo -e "${error}下载旧版本DP插件失败!"
		return 1
	fi
	if ! tar -zxvf /tmp/dp2_old.tar.gz -C / >/dev/null 2>&1; then
		echo -e "${error}解压旧版本DP插件失败!"
		rm -f /tmp/dp2_old.tar.gz
		return 1
	fi
	rm -f /tmp/dp2_old.tar.gz # 删除临时压缩包

	# 设置 GeoIP 库链接
	setenforce 0 >/dev/null 2>&1 # 临时禁用SELinux,可能需要更持久的解决方案
	cd /usr/lib || { echo "${error}无法切换到 /usr/lib"; return 1; }
	rm -f libGeoIP.so.1
	ln -s /dp2/libGeoIP.so.1 .
	cd - || exit

	# 清理 /root/run 脚本中的旧DP加载项
	grep -vE "\./df_game_r" /root/run | sudo tee /root/run >/dev/null 2>&1
	grep -v "sleep" /root/run | sudo tee /root/run >/dev/null 2>&1
	grep -v "Memory" /root/run | sudo tee /root/run >/dev/null 2>&1 # 移除内存优化加载项

	# 获取用户配置选项
	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启深渊多黄播报？[1=是/2=否](默认1) :${font}"; read -r sybb </dev/tty
	echo -e "${inputs}"
	echo
	sybb=${sybb:-1} # 设置默认值
	if [[ ${sybb} != 1 ]]; then
		sed -i 's/countQuality4EquipsInCurrentInstance(user, charac_no);/\/\/countQuality4EquipsInCurrentInstance(user, charac_no);/' /dp2/df_game_r.js
		sed -i 's/api_gameWorld_SendNotiPacketMessage(identifications/\/\/api_gameWorld_SendNotiPacketMessage(identifications/' /dp2/df_game_r.js
	fi

	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启幸运点影响爆率？[1=是/2=否](默认1) :${font}"; read -r luck </dev/tty
	echo -e "${inputs}"
	echo
	luck=${luck:-1} # 设置默认值
	if [[ ${luck} != 1 ]]; then
		sed -i 's/enable_drop_use_luck_piont();/\/\/enable_drop_use_luck_piont();/' /dp2/df_game_r.js
		sed -i 's/Query_lucky_points(user);/\/\/Query_lucky_points(user);/' /dp2/df_game_r.js
	fi

	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启副本通关播报？[1=是/2=否](默认1) :${font}"; read -r dungeon_clearance </dev/tty
	echo -e "${inputs}"
	echo
	dungeon_clearance=${dungeon_clearance:-1} # 设置默认值
	if [[ ${dungeon_clearance} != 1 ]]; then
		sed -i "s/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'/\/\/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'/" /dp2/df_game_r.js
		sed -i "s/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'/\/\/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'/" /dp2/df_game_r.js
	fi

	# 检查其他插件兼容性
	if [[ -e /root/bss/run.sh ]]; then
		echo -e "${input}"
	

		echo -n -e "${determine}${yellow}是否装有燃木插件？[1=是/2=否](默认2) :${font}"; read -r sfyg </dev/tty
		echo -e "${inputs}"
		sfyg=${sfyg:-2} # 设置默认值
	fi
	echo

	if [[ -e /home/neople/game/frida-gadget-12.11.13-linux-x86.config ]]; then
		echo -e "${input}"
	

		echo -n -e "${determine}${yellow}是否安装了Frida插件？[1=是/2=否](默认2) :${font}"; read -r fridaor </dev/tty
		echo -e "${inputs}"
		fridaor=${fridaor:-2} # 设置默认值
	fi
	echo

	# 根据插件组合构建 LD_PRELOAD 字符串并写入 /root/run
	run_script_content="sleep 1\n" # 初始化脚本内容
	preload_libs=("/dp2/libdp2pre.so") # 基础DP库
	if [[ ${sfyg} = 1 ]]; then
		preload_libs+=("/ranmu/ranmu.so") # 添加燃木库
	fi
	if [[ ${fridaor} = 1 ]]; then
		preload_libs+=("/home/neople/game/frida-gadget-12.11.13-linux-x86.so") # 添加Frida库
	fi
	# 使用 IFS（内部字段分隔符）将数组元素连接成空格分隔的字符串
	IFS=" "
	run_script_content+="LD_PRELOAD=\"${preload_libs[*]}\" ./df_game_r siroco12 start &\n"
	run_script_content+="sleep 2\n"
	run_script_content+="./df_game_r siroco52 start &\n"
	run_script_content+="sleep 2\n"
	run_script_content+="./df_game_r siroco56 start &"
	# 将构建好的内容追加到 /root/run
	echo -e "${run_script_content}" >> /root/run

	clear
	echo -e "
${Separator}
			旧版本DP插件安装完成
			/dp2/导入PVF文件.zip
			/dp2/介绍.txt
		介绍必看,代码可以根据pvf自行更换
${Separator}" && echo
	# 检查云端tool插件提示
	if [[ -e /root/tool/YDRestart ]]; then
		echo -e "检测到当前服务器可能安装了云端tool插件,请稍后自行重启云端tool网关。"
	fi
	return 0 # 表示成功
}

# 安装新版本DP插件 (原 dp_frida)
# 包含动态播报、红包等功能,并处理与其他插件的兼容性
function installDpFrida() {
	clear
	# 显示插件功能列表
	echo -e "
${Separator}
跨界石,异界重置券,装备继承券,20级直升券,宠物删除券,一键分解券
女鬼转职券,点券增加券,签到拿低保,区域奖励,深渊播报,多黄奖励
交易记录,通关播报,防卡商店,镶嵌修复,排行榜动态登录播报,口令红包
心悦动态登录播报,史诗药剂,特殊抗魔足够才能进副本等等
${Separator}" && echo

	local confirm # 用户确认
	local enableAbyssBroadcast luckDrop dungeonClearanceBroadcast # DP功能选项
	local hasRanmuPlugin=2 hasFridaPlugin=2 # 其他插件兼容性选项,默认为否(2)
	local runScriptContent # /root/run 脚本内容
	local preloadLibs=() # 需要预加载的库列表

	# 获取用户确认

	
	echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r confirm </dev/tty
	if [[ -n ${confirm} ]]; then # 如果用户输入了任何内容（非空）,则取消
		echo -e "${info}已取消安装。${font}"
		return
	fi
	echo

	echo -e "${green}开始下载新版本dp2插件所需文件(解压在[/dp2/])${font}"
	# 下载并解压新版本插件
	if ! wget --no-check-certificate -q -O /tmp/dp2_new.tar.gz "${Url}dp2/xdp2.tar.gz"; then
		echo -e "${error}下载新版本DP插件失败!"
		return 1
	fi
	if ! tar -zxvf "/tmp/dp2_new.tar.gz" -C / >/dev/null 2>&1; then
		echo -e "${error}解压新版本DP插件失败!"
		rm -f /tmp/dp2_new.tar.gz
		return 1
	fi
	rm -f /tmp/dp2_new.tar.gz # 删除临时压缩包

	# 设置 GeoIP 库链接
	setenforce 0 >/dev/null 2>&1 # 临时禁用SELinux
	cd /usr/lib || { echo "${error}无法切换到 /usr/lib"; return 1; }
	rm -f libGeoIP.so.1
	ln -s /dp2/libGeoIP.so.1 .
	cd - || exit

	# 清理 /root/run 脚本中的旧DP加载项和相关行
	grep -vE "\./df_game_r" /root/run | sudo tee /root/run >/dev/null 2>&1
	grep -v "sleep" /root/run | sudo tee /root/run >/dev/null 2>&1
	grep -v "Memory" /root/run | sudo tee /root/run >/dev/null 2>&1 # 移除内存优化加载项

	# 获取用户配置选项
	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启深渊多黄播报？[1=是/2=否](默认1) :${font}"; read -r enableAbyssBroadcast </dev/tty
	echo -e "${inputs}"
	echo
	enableAbyssBroadcast=${enableAbyssBroadcast:-1} # 设置默认值
	if [[ ${enableAbyssBroadcast} != 1 ]]; then
		# 注释掉相关代码行
		sed -i 's/countQuality4EquipsInCurrentInstance(user, charac_no);/\/\/countQuality4EquipsInCurrentInstance(user, charac_no);/' /dp2/df_game_r.js
		sed -i 's/api_gameWorld_SendNotiPacketMessage(identifications/\/\/api_gameWorld_SendNotiPacketMessage(identifications/' /dp2/df_game_r.js
	fi

	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启幸运点影响爆率？[1=是/2=否](默认1) :${font}"; read -r luckDrop </dev/tty
	echo -e "${inputs}"
	echo
	luckDrop=${luckDrop:-1} # 设置默认值
	if [[ ${luckDrop} != 1 ]]; then
		# 注释掉相关代码行
		sed -i 's/enable_drop_use_luck_piont();/\/\/enable_drop_use_luck_piont();/' /dp2/df_game_r.js
		sed -i 's/Query_lucky_points(user);/\/\/Query_lucky_points(user);/' /dp2/df_game_r.js
	fi

	echo -e "${input}"

	
	echo -n -e "${determine}${yellow}是否开启副本通关播报？[1=是/2=否](默认1) :${font}"; read -r dungeonClearanceBroadcast </dev/tty
	echo -e "${inputs}"
	echo
	dungeonClearanceBroadcast=${dungeonClearanceBroadcast:-1} # 设置默认值
	if [[ ${dungeonClearanceBroadcast} != 1 ]]; then
		# 注释掉相关代码行
		sed -i "s/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'/\/\/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'/" /dp2/df_game_r.js
		sed -i "s/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'/\/\/api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'/" /dp2/df_game_r.js
	fi

	# 配置战力榜播报
	configureCombatPowerRankingBroadcast # 调用配置函数 (原 dp_frida_zl)

	# 检查其他插件兼容性
	if [[ -e /root/bss/run.sh ]]; then
		echo -e "${input}"
	

		echo -n -e "${determine}${yellow}是否装有燃木插件？[1=是/2=否](默认2) :${font}"; read -r hasRanmuPlugin </dev/tty
		echo -e "${inputs}"
		hasRanmuPlugin=${hasRanmuPlugin:-2} # 设置默认值
	fi
	echo

	if [[ -e /home/neople/game/frida-gadget-12.11.13-linux-x86.config ]]; then
		echo -e "${input}"
	

		echo -n -e "${determine}${yellow}是否安装了Frida插件？[1=是/2=否](默认2) :${font}"; read -r hasFridaPlugin </dev/tty
		echo -e "${inputs}"
		hasFridaPlugin=${hasFridaPlugin:-2} # 设置默认值
	fi
	echo

	# 根据插件组合构建 LD_PRELOAD 字符串并写入 /root/run
	runScriptContent="sleep 1\n" # 初始化脚本内容
	preloadLibs+=("/dp2/libdp2pre.so") # 基础DP库
	if [[ ${hasRanmuPlugin} = 1 ]]; then
		preloadLibs+=("/ranmu/ranmu.so") # 添加燃木库
	fi
	if [[ ${hasFridaPlugin} = 1 ]]; then
		preloadLibs+=("/home/neople/game/frida-gadget-12.11.13-linux-x86.so") # 添加Frida库
	fi
	# 使用 IFS（内部字段分隔符）将数组元素连接成空格分隔的字符串
	IFS=" "
	runScriptContent+="LD_PRELOAD=\"${preloadLibs[*]}\" ./df_game_r siroco12 start &\n"
	runScriptContent+="sleep 2\n"
	runScriptContent+="./df_game_r siroco52 start &\n"
	runScriptContent+="sleep 2\n"
	runScriptContent+="./df_game_r siroco56 start &"
	# 将构建好的内容追加到 /root/run
	echo -e "${runScriptContent}" >> /root/run

	clear
	# 显示安装完成信息
	echo -e "
${Separator}
			新版本DP插件安装完成
			/dp2/导入PVF文件.zip
			/dp2/介绍.txt
		介绍必看,代码可以根据pvf自行更换
${Separator}" && echo
	# 检查云端tool插件提示
	if [[ -e /root/tool/YDRestart ]]; then
		echo -e "检测到当前服务器可能安装了云端tool插件,请稍后自行重启云端tool网关。"
	fi
	return 0 # 表示成功
}

# 开启DP插件功能菜单 (原 switch_1)
function enableDpFeatures() {
	clear
	local dp_script="/dp2/df_game_r.js" # DP脚本路径
	local choice # 用户选择

	# 检查DP脚本是否存在
	if [[ ! -f "${dp_script}" ]]; then
		echo -e "${error}DP脚本 ${dp_script} 不存在!"
		return 1
	fi

	echo -e "${Separator}"
	echo -e "  (1) ${blue}开启幸运值爆率和播报${font}"
	echo -e "  (2) ${blue}开启深渊多黄奖励和播报${font}"
	echo -e "  (3) ${blue}开启深渊多黄奖励和播报[副本展示结算版]${font}"
	echo -e "  (4) ${blue}开启通关|未通关播报${font}"
	echo -e "  (5) ${blue}开启副本拾取史诗播报${font}"
	echo -e "  (6) ${yellows}开启装备镶嵌并关闭时装镶嵌[需登录器支持]${font}"
	echo -e "  (7) ${yellow}开启时装镶嵌并关闭装备镶嵌[需登录器支持]${font}"
	echo
	echo -e "  (0) ${black_cyan_blink}返回上一级${font}" && echo

	
	echo -n -e "${determine}${yellow}数字 [0-7]:${font}"; read -r choice </dev/tty

	case "${choice}" in
	1)
		# 开启幸运值爆率和播报
		clear
		# 使用更精确的 sed 模式,确保只取消注释目标行
		sed -i 's|^//enable_drop_use_luck_piont();|enable_drop_use_luck_piont();|' "${dp_script}"
		sed -i 's|^//Query_lucky_points(user);|Query_lucky_points(user);|' "${dp_script}"

		echo -e "${yellow}幸运值爆率和播报已开启,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		enableDpFeatures # 返回菜单
		;;
	2)
		# 开启深渊多黄奖励和播报
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^//countQuality4EquipsInCurrentInstance(user, charac_no);|countQuality4EquipsInCurrentInstance(user, charac_no);|g' "${dp_script}"
		sleep 1

		echo -e "${yellow}深渊多黄奖励和播报已开启,奖励修改位置在 ${dp_script} 脚本中的2828行左右！${font}"
		# 不再返回菜单,直接退出当前函数
		;;
	3)
		# 开启深渊多黄奖励和播报[副本展示结算版]
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^//Prompt_end_of_dungeon(user);|Prompt_end_of_dungeon(user);|g' "${dp_script}"
		sleep 1

		echo -e "${yellow}深渊多黄奖励和播报[副本结算版]已开启,奖励修改位置在 ${dp_script} 脚本中的3384行左右！${font}"
		# 不再返回菜单
		;;
	4)
		# 开启通关|未通关播报
		clear
		# 使用更精确的 sed 模式,注意转义特殊字符
		sed -i "s|^//api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'|api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'|" "${dp_script}"
		sed -i "s|^//api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'|api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'|" "${dp_script}"

		echo -e "${yellow}通关|未通关播报已开启,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		enableDpFeatures # 返回菜单
		;;
	5)
		# 开启副本拾取史诗播报
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^//api_CUser_Rarity_equ(user,identifications|api_CUser_Rarity_equ(user,identifications|g' "${dp_script}"

		echo -e "${yellow}副本拾取史诗播报已开启,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		enableDpFeatures # 返回菜单
		;;
	6)
		# 开启装备镶嵌并关闭时装镶嵌
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^//Equipment_inlay|Equipment_inlay|g' "${dp_script}" # 取消注释装备镶嵌
		sed -i 's|^Fashion_inlay|//Fashion_inlay|g' "${dp_script}" # 注释时装镶嵌

		echo -e "${yellow}装备镶嵌已开启,时装镶嵌已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		enableDpFeatures # 返回菜单
		;;
	7)
		# 开启时装镶嵌并关闭装备镶嵌
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^//Fashion_inlay|Fashion_inlay|g' "${dp_script}" # 取消注释时装镶嵌
		sed -i 's|^Equipment_inlay|//Equipment_inlay|g' "${dp_script}" # 注释装备镶嵌

		echo -e "${yellow}时装镶嵌已开启,装备镶嵌已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		enableDpFeatures # 返回菜单
		;;
	0)
		manageDpPlugin
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		enableDpFeatures # 重新显示菜单
		;;
	esac
}

# 关闭DP插件功能菜单 (原 switch_2)
function disableDpFeatures() {
	clear
	local dp_script="/dp2/df_game_r.js" # DP脚本路径
	local choice # 用户选择

	# 检查DP脚本是否存在
	if [[ ! -f "${dp_script}" ]]; then
		echo -e "${error}DP脚本 ${dp_script} 不存在!"
		return 1
	fi

	echo -e "${Separator}"
	echo -e "  (1) ${blue}关闭幸运值爆率和播报${font}"
	echo -e "  (2) ${blue}关闭深渊多黄奖励和播报${font}"
	echo -e "  (3) ${blue}关闭深渊多黄奖励和播报[副本结算展示版]${font}"
	echo -e "  (4) ${blue}关闭通关|未通关播报${font}"
	echo -e "  (5) ${blue}关闭副本拾取史诗播报${font}"
	echo -e "  (6) ${yellows}开启装备镶嵌并关闭时装镶嵌[需登录器支持]${font}"
	echo -e "  (7) ${yellow}开启时装镶嵌并关闭装备镶嵌[需登录器支持]${font}"
	echo
	echo -e "  (0) ${black_cyan_blink}返回上一级${font}" && echo

	
	echo -n -e "${determine}${yellow}数字 [0-7]:${font}"; read -r choice </dev/tty

	case "${choice}" in
	1)
		# 关闭幸运值爆率和播报
		clear
		# 使用更精确的 sed 模式,确保只注释目标行
		sed -i 's|^enable_drop_use_luck_piont();|//enable_drop_use_luck_piont();|' "${dp_script}"
		sed -i 's|^Query_lucky_points(user);|//Query_lucky_points(user);|' "${dp_script}"

		echo -e "${yellow}幸运值爆率和播报已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	2)
		# 关闭深渊多黄奖励和播报
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^countQuality4EquipsInCurrentInstance(user, charac_no);|//countQuality4EquipsInCurrentInstance(user, charac_no);|g' "${dp_script}"

		echo -e "${yellow}深渊多黄奖励和播报已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	3)
		# 关闭深渊多黄奖励和播报[副本结算展示版]
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^Prompt_end_of_dungeon(user);|//Prompt_end_of_dungeon(user);|g' "${dp_script}"

		echo -e "${yellow}深渊多黄奖励和播报[副本结算版]已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	4)
		# 关闭通关|未通关播报
		clear
		# 使用更精确的 sed 模式,注意转义特殊字符
		sed -i "s|^api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'|//api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '通关'|" "${dp_script}"
		sed -i "s|^api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'|//api_gameWorld_SendNotiPacketMessage(identification + api_CUserCharacInfo_getCurCharacName(user) + ']' + '未通关'|" "${dp_script}"

		echo -e "${yellow}通关|未通关播报已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	5)
		# 关闭副本拾取史诗播报
		clear
		# 使用更精确的 sed 模式
		sed -i 's|^api_CUser_Rarity_equ(user,identifications|//api_CUser_Rarity_equ(user,identifications|g' "${dp_script}"

		echo -e "${yellow}副本拾取史诗播报已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	6)
		# 开启装备镶嵌并关闭时装镶嵌 (与 enableDpFeatures 中的选项6相同)
		clear
		sed -i 's|^//Equipment_inlay|Equipment_inlay|g' "${dp_script}"
		sed -i 's|^Fashion_inlay|//Fashion_inlay|g' "${dp_script}"

		echo -e "${yellow}装备镶嵌已开启,时装镶嵌已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	7)
		# 开启时装镶嵌并关闭装备镶嵌 (与 enableDpFeatures 中的选项7相同)
		clear
		sed -i 's|^//Fashion_inlay|Fashion_inlay|g' "${dp_script}"
		sed -i 's|^Equipment_inlay|//Equipment_inlay|g' "${dp_script}"
		echo -e "${yellow}时装镶嵌已开启,装备镶嵌已关闭,如果dp2已经启动则不需要重跑五国！${font}"
		sleep 1
		disableDpFeatures # 返回菜单
		;;
	0)
		manageDpPlugin
		;;
	*)
		# 处理无效输入
		echo -e "${error}:您输入的选项不存在,请重新选择!"
		sleep 1
		disableDpFeatures # 重新显示菜单
		;;
	esac
}

# 配置DP插件的战力榜播报功能 (原 dp_frida_zl)
function configureCombatPowerRankingBroadcast() {
	local dp_script="/dp2/df_game_r.js" # DP脚本路径
	local enableRankingBroadcast # 是否开启播报
	local rankingCriteria # 排名标准选择

	# 检查DP脚本是否存在
	if [[ ! -f "${dp_script}" ]]; then
		echo -e "${error}DP脚本 ${dp_script} 不存在!"
		return 1
	fi

	echo -e "${input}"
	echo -n -e "${determine}${yellow}是否开启战力榜播报？[1=是/2=否](默认1) :${font}"; read -r enableRankingBroadcast </dev/tty
	echo -e "${inputs}"
	echo
	enableRankingBroadcast=${enableRankingBroadcast:-1} # 设置默认值为1 (是)

	if [[ ${enableRankingBroadcast} = 1 ]]; then
		# 开启战力榜播报,取消注释相关代码
		sed -i 's|^//var myzhanli=|var myzhanli=|' "${dp_script}"

		# 显示排名标准选项
		clear
		echo -e "${Separator}"
		echo -e "  (1) ${yellow}最大血量值的玩家${font}"
		echo -e "  (2) ${yellow}花枝3.41战力榜${font}"
		echo -e "  (3) ${yellow}晴空战力榜${font}"
		echo -e "  (4) ${yellow}黑爵战力榜${font}"
		echo -e "  (5) ${yellow}暴雨战力榜${font}"
		echo -e "  (6) ${yellow}入梦战力榜${font}"
		echo -e "  (7) ${yellow}长虹战力榜${font}"
		echo -e "${Separator}" && echo
		echo -n -e "${determine}${yellow}请选择判定条件(默认1) :${font}"; read -r rankingCriteria </dev/tty

		# 根据选择取消注释对应的判定逻辑
		local sed_pattern # 用于sed命令的模式
		case "${rankingCriteria}" in
			1) sed_pattern='s|//zl血量||' ;;
			2) sed_pattern='s|//zl花枝341||' ;; #花枝3.41
			3) sed_pattern='s|//zl晴空||' ;; #晴空
			4) sed_pattern='s|//zl黑爵||' ;; #黑爵
			5) sed_pattern='s|//zl暴雨||' ;; #暴雨
			6) sed_pattern='s|//zl入梦||' ;; #入梦
			7) sed_pattern='s|//zl长虹||' ;; #长虹
			*)
				echo -e "${inputs}选择出错,默认判定最大血量值的玩家。"
				sed_pattern='s|//zl血量||' # 默认使用血量
				;;
		esac
		# 执行sed命令取消注释
		sed -i "${sed_pattern}" "${dp_script}"
		echo -e "${info}战力榜播报已开启,判定条件已设置。"

	else
		# 关闭战力榜播报,注释相关代码
		sed -i 's|^var myzhanli=|//var myzhanli=|' "${dp_script}"
		echo -e "${info}战力榜播报已关闭。"
	fi
}


# 安装防提权等级补丁 (原 ftqbd)
# 提供不同等级的补丁安装,并包含可选的服务器安全加固措施
function installAntiPrivilegeEscalationPatch() {
	clear
	echo -e "${input}"
	# 显示补丁包含的功能
	echo -e "${green}[修复黑武技能栏|${reds}修复卡NPC商店${green}|解除赫顿玛尔摆摊限制]${font}" : reds -> reds
	echo -e "${green}[防炸频道|防提权|修复不消耗门票|修复异界次数|修复领主塔光速回城]${font}"
	echo -e "${green}[修复外传进pk(需搭配客户端)|修复瞬间移动药水并拓展|修复多彩蜜蜡]${font}"
	echo -e "${green}[修复街头争霸(需搭配客户端)|修复缔造创建(需搭配0725)|添加勇士归来]${font}"
	# 显示支持的等级列表
	echo -e "${blue}目前所支持的等级有:${font}" # 使用 blue 颜色
	echo -e "${blue}50、60、65、70、75、80、85、86、90、95、100、110、120${font}" # 使用 blue 颜色
	echo -e "${input}"

	local patchLevel # 用户选择的补丁等级
	local skipEpicConfirm # 是否跳过史诗确认框 (1=是/2=否)
	local patchRoute # 补丁下载路径的一部分 (ftq 或 ftqmss)
	local enableExtraHardening # 是否开启额外安全加固

	# 获取用户输入的补丁等级
	echo -e "直接回车则默认${red}不安装${font}"

	echo -n -e "${determine}${yellow}安装防提权等级补丁[请输入以上等级]:${font}"; read -r patchLevel </dev/tty

	# 如果未输入等级,则退出
	if [[ -z "${patchLevel}" ]]; then
		echo -e "${info}未输入等级,已取消安装。${font}"
		return
	fi

	# 验证输入的等级是否有效
	local validLevels=("50" "60" "65" "70" "75" "80" "85" "86" "90" "95" "100" "110" "120")
	local isValidLevel=false
	for level in "${validLevels[@]}"; do
		if [[ "${patchLevel}" == "${level}" ]]; then
			isValidLevel=true
			break
		fi
	done

	if [[ "${isValidLevel}" == false ]]; then
		echo -e "${error}${red}抱歉,不支持该等级: ${patchLevel}。${font}"
		return 1
	fi

	# 获取是否免史诗确认框的选项
	echo -e "${Separator}"
	
	echo -e "直接回车则默认${red}免确认${font}[1为是/2为否]"

	echo -n -e "${determine}${yellow}是否免史诗确认框？[请输入1/2]:${font}"; read -r skipEpicConfirm </dev/tty
	echo -e "${inputs}"
	skipEpicConfirm=${skipEpicConfirm:-1} # 默认免确认

	# 根据选项设置下载路径
	if [[ ${skipEpicConfirm} = 2 ]]; then
		patchRoute="ftq" # 需要确认
	else
		patchRoute="ftqmss" # 免确认
	fi

	# 下载并安装补丁
	echo -e "${tip}开始下载并安装[${reds}${patchLevel}${font}]级防提权等级补丁。${load}"
	local patchUrl="${Url}${patchRoute}/${patchLevel}.tar.gz"
	local patchTempFile="/tmp/dj_${patchLevel}.tar.gz" # 使用更明确的临时文件名

	if ! wget --no-check-certificate -q -O "${patchTempFile}" "${patchUrl}" >/dev/null 2>&1; then
		
		echo -e "${Separator}"
		echo -e "${error}${red}下载补丁失败! URL: ${patchUrl}${font}"
		echo -e "${error}${red}请检查链接是否可下载或等级是否输入错误。${font}"
		rm -f "${patchTempFile}" # 删除可能存在的空文件
		return 1
	fi

	# 检查下载的文件大小 (可选,但建议保留)
	local patchFileSize
	patchFileSize=$(du -b "${patchTempFile}" | awk '{print $1}')
	if [[ ${patchFileSize} -lt 1000000 ]]; then # 假设补丁文件至少大于1MB
		
		echo -e "${Separator}"
		echo -e "${error}${red}下载的补丁文件过小 (${patchFileSize} bytes),可能下载不完整。URL: ${patchUrl}${font}"
		rm -f "${patchTempFile}"
		return 1
	fi

	# 解压补丁文件
	if ! tar -zxvf "${patchTempFile}" -C / >/dev/null 2>&1; then
		echo -e "${error}解压补丁文件失败!"
		rm -f "${patchTempFile}"
		return 1
	fi
	rm -f "${patchTempFile}" # 删除临时压缩包

	# 询问是否开启额外安全加固
	echo -e "${Separator}"
	
	echo -e "${tip}${red}是否继续开启更高强度的防破服务器？${font}[1为是/2为否]"
	echo -e "${tip}${red}可能会导致团本类插件无法安装,不可恢复,dp和frida类插件无影响!"

	echo -n -e "${determine}${yellow}直接回车默认为不开启[请输入1/2]:${font}"; read -r enableExtraHardening </dev/tty
	enableExtraHardening=${enableExtraHardening:-2} # 默认不开启

	if [[ ${enableExtraHardening} = 1 ]]; then
		# 应用额外的服务器安全加固措施
		applyServerHardening
	fi

	# 显示最终结果
	local confirmText
	if [[ ${skipEpicConfirm} = 2 ]]; then
		confirmText="有"
	else
		confirmText="免"
	fi
	
	
	echo -e "${tip}${yellows}防提权等级补丁安装完成! ${green}${confirmText}${red}史诗捡取框的[${patchLevel}]等级补丁已安装。${font}"
	if [[ ${enableExtraHardening} = 1 ]]; then
		echo -e "${tip}${yellows}已开启额外服务器安全加固。${font}"
	fi
	echo -e "${inputs}"
}

# 应用额外的服务器安全加固措施
function applyServerHardening() {
	echo -e "${info}正在应用额外的服务器安全加固措施...${load}"

	# 1. 修改 SSH 配置
	
	echo -e "${tip}${red}配置 SSH 服务...${font}"
	chattr -i /etc/ssh/sshd_config # 取消文件不可修改属性
	# 确保 PermitRootLogin yes (如果需要允许 root 登录)
	
	if grep -q '#PermitRootLogin yes' /etc/ssh/sshd_config; then
		sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
	elif ! grep -q 'PermitRootLogin yes' /etc/ssh/sshd_config; then
		echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
	fi
	# 添加 AllowUsers 指令,限制允许登录的用户
	if ! grep -q '# 允许通行' /etc/ssh/sshd_config; then
		sudo bash -c 'cat << EOF >> /etc/ssh/sshd_config
# 允许通行
AllowUsers root bin daemon adm lp sync shutdown halt mail operator games ftp nobody systemd-network dbus polkitd rpc rpcuser nfsnobody sshd postfix chrony apache mysql
EOF'
	fi
	# 重启 SSH 服务
	systemctl restart sshd >/dev/null 2>&1 || service sshd restart >/dev/null 2>&1 || /etc/init.d/sshd restart >/dev/null 2>&1

	# 2. 修改 login.defs 配置
	
	echo -e "${tip}${red}修改 /etc/login.defs 文件...${font}"
	sudo sed -i 's/CREATE_HOME\tyes/CREATE_HOME\tno/g' /etc/login.defs >/dev/null 2>&1

	# 3. 修改关键命令权限
	
	echo -e "${tip}${red}修改关键命令权限...${font}"
	sudo chmod 4700 /usr/sbin/useradd >/dev/null 2>&1
	sudo chown root:root /usr/sbin/useradd >/dev/null 2>&1
	sudo chmod 4700 /usr/sbin/passwd >/dev/null 2>&1
	sudo chown root:root /usr/sbin/passwd >/dev/null 2>&1
	sudo chmod 4700 /etc/passwd >/dev/null 2>&1
	sudo chown root:root /etc/passwd >/dev/null 2>&1

	# 4. 限制 MySQL 用户创建权限
	echo -e "${tip}${red}检查并限制 MySQL 用户权限...${font}"
	local mysqlResult
	mysqlResult=$(mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' -e "SELECT User, Host FROM mysql.user WHERE Host LIKE '%';" -B -N 2>/dev/null)
	
	if echo "${mysqlResult}" | grep -q "%"; then
		echo -e "${tip}${red}解除 mysql中game@127.0.0.1账号的创建账号权限。${font}"
		mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
REVOKE CREATE USER ON *.* FROM 'game'@'127.0.0.1';
EOF
	else
		echo -e "${tip}${yellow}检测到已使用限制IP功能或无通配符主机,不再限制创建账号权限。${font}"
	fi

	# 5. 确保 polkit 目录存在 (某些系统需要)
	if [ ! -d "/var/run/polkit-1" ]; then
		sudo mkdir /var/run/polkit-1 >/dev/null 2>&1
	fi

	echo -e "${info}额外服务器安全加固措施已应用。${font}"
}

# 检查系统环境
function checkSys() {
    # 检查线路连通性
    local line
    line=$(wget -qO- --no-check-certificate "${OssUrl}Line")
    if [ "$line" = "yes" ]; then
        echo
    else
        echo -e "${error}${reds}检测异常,开始切换检测方式！${font}"
        wget --no-check-certificate -q -O /tmp/Lines "${OssUrl}Lines" >/dev/null 2>&1
        local lines
        lines=$(stat -c %s "/tmp/Lines")
        sleep 1
        if [ "$lines" -gt 150000 ]; then
            sleep 1
            logo
            return
        fi
        
        echo -e "${error}${red}确认异常,启用主线路！${font}"
        if [[ -z ${digit} ]]; then
            echo
        fi
        Url=$(curl -s XX.XX.XX.XX/Url.php)
        export Url
    fi

    # 检查操作系统类型
    echo -e "${red}开始检查系统${info}${font}"
    local release=""
    
    if [[ -f /etc/redhat-release ]]; then
        release="CentOS"
    elif grep -q -E -i "debian" /etc/issue; then
        release="Debian"
    elif grep -q -E -i "ubuntu" /etc/issue; then
        release="Ubuntu"
    elif grep -q -E -i "centos|red hat|redhat" /etc/issue; then
        release="CentOS"
    elif grep -q -E -i "debian" /proc/version; then
        release="Debian"
    elif grep -q -E -i "ubuntu" /proc/version; then
        release="Ubuntu"
    elif grep -q -E -i "centos|red hat|redhat" /proc/version; then
        release="CentOS"
    fi
    
    if [ "$release" = "CentOS" ]; then
        echo -e "当前系统版本为:${red}${release}${XT} ${W} 位${font},系统检查通过。"
    elif [[ "${release}" == "Debian" || "${release}" == "Ubuntu" || "${W}" == "32" ]]; then
        echo -e "暂不支持该系统安装"
        echo -e "请更换 CentOS 64位 系统进行安装"
        exit
    fi
    
    # 继续安装流程
    firstJob
}

 # 初始化安装环境函数
 # 该函数用于配置和优化服务器基础环境
 # 1. 优化SSH配置以提高连接速度
 # 2. 配置系统语言环境
 # 3. 配置网络设置
 # 4. 关闭SELinux安全策略
 # 5. 调用presetsInformation函数继续安装流程
function firstJob() {
    echo -e "${red}开始检查安装环境${info}${font}"
    
    # 优化SSH配置
    sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    service sshd restart
    echo -e "${red}ssh服务正常${info}${font}"
    
    # 配置系统语言环境
    chattr -i /etc/sysconfig/network
    cat <<EOF >/etc/sysconfig/i18n
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16"
EOF

    # 配置网络设置
    cat <<EOF >/etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=yes
EOF
    chattr +i /etc/sysconfig/network
    
    # 关闭SELinux
    setenforce 0
    
    echo -e "${red}防火墙已关闭,环境检查通过。${info}${font}"
    
    # 继续安装流程
    presetsInformation
}

 # 预设信息收集函数
 #
 # 该函数用于收集用户安装偏好和配置MySQL参数
 # 1. 询问用户是否安装等级补丁
 # 2. 询问用户是否开启数据库自动备份
 # 3. 询问用户是否需要UDP转发
 # 4. 根据服务器内存大小自动配置MySQL参数
 # 5. 调用mysqlConfigSetup函数继续安装流程
function presetsInformation() {
    # 询问安装等级补丁
    clear
    setupLogo
    echo -e "${input}"
    echo -e "\e[36m[防提权/修复下线卡素喃/修复无视门票/添加史诗捡取框/添加公平pvp]\e[0m"
    echo -e "\e[36m防提权效果不如界面的(m)项目\e[0m"
    echo -e "\e[36m目前所支持的等级有\e[0m"
    echo -e "\e[36m50、60、65、70、75、80、85、86、90、95、100、110、120\e[0m"
    echo -e "直接回车则默认${red}不安装${font}"
    echo -n -e "${determine}${yellow}安装等级补丁[请输入以上等级]:${font}"
    read -r dfGameR </dev/tty
    echo -e "${inputs}"
    
    # 询问数据库自动备份
    clear
    setupLogo
    echo -e "${input}"
    echo -e "${purple}使用的是sql格式的自动备份,2个小时一次!${font}"
    echo -e "${purple}最长保存10天内数据!最多保留20个数据包!${font}"
    echo -e "直接回车则默认${red}是${font}"
    echo -n -e "${determine}${yellow}是否开启数据库自动备份[1是/2否]:${font}"
    read -r autoBakSql </dev/tty
    echo -e "${inputs}"
    
    # 询问UDP转发
    clear
    setupLogo
    echo -e "${input}"
    echo -e "${purple}(如果机器是封禁UDP的则需要转发才能组队)${font}"
    echo -e "直接回车则默认${red}不转发${font}"
    echo -n -e "${determine}${yellow}是否转发UDP[1是/2否]:${font}"
    read -r udpIp </dev/tty
    echo -e "${inputs}"
    
    # 根据内存大小配置MySQL参数
    local mysqlConfig
    
    # 导出变量供其他函数使用
    export dfGameR
    export autoBakSql
    export udpIp
    
    # 根据内存大小设置MySQL配置参数
    if [ "${G}" -ge 31 ]; then
        # 31GB及以上内存配置
        mysqlConfig="高性能配置"
		

		# binlog 缓存
        export mysqlTmpTableSize="512M"
		# 新线程的堆栈大小
        export mysqlKeyBufferSize="128M"
		# 指定内存临时表的大小
        export mysqlMaxHeapTableSize="512M"
		# binlog 缓存
        export mysqlBinlogCacheSize="256K"
		# 当前表二级缓存的大小
        export mysqlTableOpenCache="8192"
		# 新线程的堆栈大小
        export mysqlThreadStack="512K"
		# join 操作缓存的大小
        export mysqlJoinBufferSize="2M"
		# 排序操作时的缓冲大小
        export mysqlSortBufferSize="2M"
		# 读取缓冲区的大小
        export mysqlReadBufferSize="1M"
		# 读取随机缓冲区的大小
        export mysqlReadRndBufferSize="2M"
		# 线程缓存的大小
        export mysqlThreadCacheSize="512"
		# 查询缓存的大小
        export mysqlQueryCacheSize="128M"
		# MySQL 服务器最大并发连接数
        export mysqlMaxConnections="1200"
		# InnoDB 存储引擎的缓冲池大小
        export mysqlInnodbBufferPoolSize="2G"
    elif [ "${G}" -ge 15 ]; then
        # 15-30GB内存配置
        mysqlConfig="中高性能配置"

		# binlog 缓存
        export mysqlTmpTableSize="256M"
		# 新线程的堆栈大小
        export mysqlKeyBufferSize="64M"
		# 指定内存临时表的大小
        export mysqlMaxHeapTableSize="256M"
		# binlog 缓存
        export mysqlBinlogCacheSize="256K"
		# 当前表二级缓存的大小
        export mysqlTableOpenCache="4096"
		# 新线程的堆栈大小
        export mysqlThreadStack="512K"
		# join 操作缓存的大小
        export mysqlJoinBufferSize="1M"
		# 排序操作时的缓冲大小
        export mysqlSortBufferSize="1M"
		# 读取缓冲区的大小
        export mysqlReadBufferSize="512K"
		# 读取随机缓冲区的大小
        export mysqlReadRndBufferSize="1M"
		# 线程缓存的大小
        export mysqlThreadCacheSize="256"
		# 查询缓存的大小
        export mysqlQueryCacheSize="64M"
		# MySQL 服务器最大并发连接数
        export mysqlMaxConnections="800"
		# InnoDB 存储引擎的缓冲池大小
        export mysqlInnodbBufferPoolSize="1G"
    elif [ "${G}" -ge 7 ]; then
        # 7-14GB内存配置
        mysqlConfig="中性能配置"

		# binlog 缓存
        export mysqlTmpTableSize="128M"
		# 新线程的堆栈大小
        export mysqlKeyBufferSize="32M"
		# 指定内存临时表的大小
        export mysqlMaxHeapTableSize="128M"
		# binlog 缓存
        export mysqlBinlogCacheSize="128K"
        export mysqlTableOpenCache="2048"
		# 新线程的堆栈大小
        export mysqlThreadStack="256K"
		# join 操作缓存的大小
        export mysqlJoinBufferSize="512K"
		# 排序操作时的缓冲大小
        export mysqlSortBufferSize="512K"
		# 读取缓冲区的大小
        export mysqlReadBufferSize="256K"
		# 读取随机缓冲区的大小
        export mysqlReadRndBufferSize="512K"
		# 线程缓存的大小
        export mysqlThreadCacheSize="128"
		# 查询缓存的大小
        export mysqlQueryCacheSize="32M"
		# MySQL 服务器最大并发连接数
        export mysqlMaxConnections="500"
		# InnoDB 存储引擎的缓冲池大小
        export mysqlInnodbBufferPoolSize="512M"
    elif [ "${G}" -ge 3 ]; then
        # 3-6GB内存配置
        mysqlConfig="低性能配置"

		# binlog 缓存
        export mysqlTmpTableSize="64M"
		# 新线程的堆栈大小
        export mysqlKeyBufferSize="16M"
		# 指定内存临时表的大小
        export mysqlMaxHeapTableSize="64M"
		# binlog 缓存
        export mysqlBinlogCacheSize="32K"
		# 当前表二级缓存的大小
        export mysqlTableOpenCache="1024"
		# 新线程的堆栈大小
        export mysqlThreadStack="192K"
		# join 操作缓存的大小
        export mysqlJoinBufferSize="256K"
		# 排序操作时的缓冲大小
        export mysqlSortBufferSize="256K"
		# 读取缓冲区的大小
        export mysqlReadBufferSize="128K"
        export mysqlReadRndBufferSize="256K"
        export mysqlThreadCacheSize="64"
        export mysqlQueryCacheSize="16M"
        export mysqlMaxConnections="300"
        export mysqlInnodbBufferPoolSize="384M"
    elif [ "${G}" -ge 1 ]; then
        # 1-2GB内存配置
        mysqlConfig="最低配置"

		# binlog 缓存
        export mysqlTmpTableSize="16M"
		# 新线程的堆栈大小
        export mysqlKeyBufferSize="16M"
		# 指定内存临时表的大小
        export mysqlMaxHeapTableSize="16M"
		# binlog 缓存
        export mysqlBinlogCacheSize="32K"
        export mysqlTableOpenCache="128"
		# 新线程的堆栈大小
        export mysqlThreadStack="256K"
		# join 操作缓存的大小
        export mysqlJoinBufferSize="256K"
		# 排序操作时的缓冲大小
        export mysqlSortBufferSize="256K"
		# 读取缓冲区的大小
        export mysqlReadBufferSize="256K"
		# 读取随机缓冲区的大小
        export mysqlReadRndBufferSize="256K"
		# 线程缓存的大小
        export mysqlThreadCacheSize="64"
		# 查询缓存的大小
        export mysqlQueryCacheSize="16M"
		# MySQL 服务器最大并发连接数
        export mysqlMaxConnections="100"
		# InnoDB 存储引擎的缓冲池大小
        export mysqlInnodbBufferPoolSize="128M"
    fi
    
    echo -e "${info}已根据内存大小(${G}GB)选择${mysqlConfig}${font}"
    
    # 继续安装流程
    mysqlConfigSetup
}


 # MySQL配置设置函数
 #
 # 该函数用于设置MySQL数据库密码
 # 1. 提示用户输入MySQL密码
 # 2. 验证密码长度是否符合安全要求
 # 3. 要求用户二次确认密码
 # 4. 验证两次输入是否一致
 # 5. 设置密码并继续安装流程
function mysqlConfigSetup() {
    clear
    setupLogo
    echo -e "${green}------------------------------输入开始------------------------------${font}"
    echo -n -e "${determine}${yellow}请首次输入数据库密码（默认:uu5!^%jg）: ${font}"
    read -r mysqlPass1 </dev/tty
    echo -e "${green}------------------------------输入结束------------------------------${font}"
    
    # 使用默认密码或检查密码长度
    if [[ -z ${mysqlPass1} ]]; then
        mysqlPass1="uu5!^%jg"
        installYum
        return
    fi
    
    # 验证密码长度
    if [[ ${#mysqlPass1} -lt 6 ]]; then
        echo -e "${red}密码长度太短！请使用至少6个字符的密码。${font}"
        mysqlConfigSetup
        return
    fi
    
    # 二次确认密码
    clear
    setupLogo
    echo -e "${green}------------------------------输入开始------------------------------${font}"
    echo -n -e "${determine}${yellow}请再次输入数据库密码（默认:uu5!^%jg）: ${font}"
    read -r mysqlPass2 </dev/tty
    echo -e "${green}------------------------------输入结束------------------------------${font}"
    mysqlPass2=${mysqlPass2:-uu5!^%jg}
    
    # 验证两次输入是否一致
    if [[ "${mysqlPass1}" != "${mysqlPass2}" ]]; then
        echo -e "${red}两次输入不一致！请重试。${font}"
        mysqlConfigSetup
        return
    fi
    
    # 设置密码并继续安装
    export mysqlPass="${mysqlPass2}"
    installYum
}

function installYum() {
	clear
	echo -e "${reds}当前系统时间为: $(date "+%Y-%m-%d %H:%M:%S")${font}"
	sleep 2
	dnf_start=$(date +%s)
	dnf_starttime=$(date "+%Y-%m-%d %H:%M:%S")
	echo -e "${yellows}开始检测汉水准!${font}"
	if ! grep -q "LANG=\"zh_CN.UTF-8\"" /etc/locale.conf; then
		echo -e "${greens}开始使用汉化规则(1)!${font}"
		echo -e "LANG=\"zh_CN.UTF-8\"" > /etc/locale.conf
	fi
	if ! grep -q "export LANG=zh_CN.UTF-8" /etc/profile; then
		echo -e "${greens}开始使用汉化规则(2)!${font}"
		echo -e "export LANG=zh_CN.UTF-8" >> /etc/profile
	fi
	if ! grep -q "export LC_TIME=zh_CN.UTF-8" /etc/profile; then
		echo -e "${greens}开始使用汉化规则(3)!${font}"
		echo -e "export LC_TIME=zh_CN.UTF-8" >> /etc/profile
	fi
	sleep 2
	echo -e "${info}开始安装DOF服务端!"
	setenforce 0 	
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux >/dev/null 2>&1
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
	rm -rf /etc/yum.repos.d/*
	rm -rf /run/yum.pid >/dev/null 2>&1
#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	curl -# -L -o /etc/yum.repos.d/CentOS-Base.repo "${Url}yum/Centos-${XT}.repo"
#-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
	echo -e "${info}正在搜索系统可用yum源${load}"
	yum clean all
    yum makecache

	wget --no-check-certificate -q -O /tmp/lsof-4.87-6.el7.x86_64.rpm "${Url}tmp/lsof-4.87-6.el7.x86_64.rpm" >/dev/null 2>&1
	wget --no-check-certificate -q -O /tmp/yum-3.4.3-168.el7.centos.noarch.rpm "${Url}tmp/yum-3.4.3-168.el7.centos.noarch.rpm" >/dev/null 2>&1
	wget --no-check-certificate -q -O /tmp/gcc-4.8.5-44.el7.x86_64.rpm "${Url}tmp/gcc-4.8.5-44.el7.x86_64.rpm" >/dev/null 2>&1
	wget --no-check-certificate -q -O /tmp/gcc-c++-4.8.5-44.el7.x86_64.rpm "${Url}tmp/gcc-c++-4.8.5-44.el7.x86_64.rpm" >/dev/null 2>&1
	wget --no-check-certificate -q -O /tmp/make-3.82-24.el7.x86_64.rpm "${Url}tmp/make-3.82-24.el7.x86_64.rpm" >/dev/null 2>&1
	rpm -ivh /tmp/lsof-4.87-6.el7.x86_64.rpm
	rpm -ivh /tmp/yum-3.4.3-168.el7.centos.noarch.rpm
	rpm -ivh /tmp/gcc-4.8.5-44.el7.x86_64.rpm
	rpm -ivh /tmp/gcc-c++-4.8.5-44.el7.x86_64.rpm
	rpm -ivh /tmp/make-3.82-24.el7.x86_64.rpm
	
	check_package_installed() {
		local package=$1
		rpm -q "$package" &> /dev/null
	}

	if ! check_package_installed "lsof"; then
		echo -e "${tip}lsof 尚未安装。正在运行 yum makecache 并安装 lsof..."
		yum install -y lsof  # 安装 lsof
	else
		echo -e "${info}lsof 已经安装,跳过安装。"
	fi

    echo -e "${tip}可用yum源更新成功!${success}"
    echo -e "${info}开始配置防火墙与dns及TCP相关协议${load}"
    if [ "${XT}" = "5" ]; then
        service iptables stop >/dev/null 2>&1
        chkconfig iptables off >/dev/null 2>&1
    elif [ "${XT}" = "6" ]; then
        service iptables stop >/dev/null 2>&1
        chkconfig iptables off >/dev/null 2>&1
    elif [ "${XT}" = "7" ]; then
        systemctl disable firewalld >/dev/null 2>&1
        systemctl stop firewalld >/dev/null 2>&1
        systemctl disable firewalld.service >/dev/null 2>&1
        systemctl stop firewalld.service >/dev/null 2>&1
    fi
    sleep 1
    echo -e "" >/etc/ld.so.preload
    sed -i "s/HISTSIZE=1000/HISTSIZE=0/g" /etc/profile
    # shellcheck disable=SC1091
    echo -e "export HISTFILESIZE=0" >>/etc/profile && source /etc/profile

    cat <<EOF >/etc/sysctl.conf
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
fs.file-max = 1000000
vm.swappiness=10
EOF

    echo -e "ulimit -n 65535" >>/etc/profile
    echo -e "ulimit -HSn 102400" >>/etc/profile
    cat <<EOF >/etc/security/limits.conf
root soft nofile 655350
root hard nofile 655350
* soft nofile 655350
* hard nofile 655350
* soft nproc  655350
* hard nproc  650000
EOF

    sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
    chattr -i /etc/sysconfig/network

    cat <<EOF >/etc/sysconfig/i18n
LANG="en_US.UTF-8"
SYSFONT="latarcyrheb-sun16"
EOF

    cat <<EOF >/etc/sysconfig/network
NETWORKING=yes
NETWORKING_IPV6=yes
EOF

    if [[ "${XT}" == "5" || "${XT}" == "6" ]]; then
        sed -i '/kernel /s/$/& highres=off/' /boot/grub/grub.conf >/dev/null 2>&1
    elif [ "${XT}" = "7" ]; then
        sed -i '/linux16 /s/$/& highres=off/' /boot/grub2/grub.cfg >/dev/null 2>&1
    fi

	sleep 1
	echo -e "${tip}系统优化相关配置完成!${success}"
	uninstSql
}

function uninstSql() {
    # 清理系统原始MySQL与PHP环境
    echo -e "${info}正在清理系统原始Mysql与php环境${load}"
    
    # 卸载MySQL和相关组件
    yes y | head -1 | yum remove -y mysql mysql-* mariadb
    rm -rf /var/lib/mysql
    rm -rf /usr/lib64/mysql
    rm -rf /etc/my.cnf
    rm -rf /var/log/mysql
    rm -rf /var/local/mysql
    
    # 停止LAMPP服务
    /opt/lampp/lampp stop >/dev/null 2>&1
    rm -rf /opt/lampp
    
    # 卸载PHP和HTTP服务器
    yes y | head -1 | yum remove -y php php-* httpd httpd-*
    yum remove -y php*
    yum remove -y httpd*
    rm -rf /etc/httpd
    rm -rf /var/www/html
    
    sleep 1s
    # 执行下一步骤
    installLibrary
}

function installLibrary() {
    # 安装Centos系统运行库
    echo -e "${info}安装Centos ${XT} 系运行库,请耐心等待${load}"
    
    # 移除旧的yum进程锁
    rm -f /var/run/yum.pid
    
    # 移除旧版本库组件
    yum remove -y libstdc*i686
    
    # 安装必要的系统库
    yum install -y glibc*i686
    yum install -y libstdc*i686
    yum install -y xulrunner.i686
    yum install -y libXtst
    yum install -y gcc gcc-c++ make zlib-devel
    yum install -y net-tools
    yum install -y psmisc
    yum install -y openssl
    
    clear
    echo -e "${tip}Centos ${XT} 运行库安装成功!${success}"
    
    # 执行下一步骤
    installMysqlDnf
}

function installMysqlDnf() {
    # 再次禁用SELINUX
    setenforce 0 >/dev/null 2>&1
    
    # 开始下载DOF服务端文件
    echo -e "${purple}开始下载DOF服务端文件!${font}"
    
    # 检测并下载Siroco文件
    Sirocosize=$(du -b /tmp/Dnf_Siroco.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
    if [ "$Sirocosize" -gt 1000000 ] 2>/dev/null; then
        echo -e "${yellows}[/tmp/Dnf_Siroco.tar.gz]文件已存在,跳过下载!${font}"
    else
        wget --no-check-certificate -O /tmp/Dnf_Siroco.tar.gz "${Url}Dnf_Siroco.tar.gz"
    fi
    
    # 验证下载是否成功
    Sirocosize=$(du -b /tmp/Dnf_Siroco.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
    if [ "$Sirocosize" -gt 1000000 ] 2>/dev/null; then
        sleep 1
    else
        echo -e "${Separator}"
        echo -e "${Url}Dnf_Siroco.tar.gz"
        echo -e "${red}下载失败,请检查链接或网络连接后重试。"
        echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty
        if [[ -z ${digit} ]]; then
            echo
        fi
        installMysqlDnf
        return
    fi
    
    # 检测并下载MySQL安装文件
    mysqlsize=$(du -b /tmp/mysqlsetup.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
    
    if [ "$mysqlsize" -gt 1000000 ] 2>/dev/null; then
        echo -e "${yellows}[/tmp/mysqlsetup.tar.gz]文件已存在,跳过下载!${font}"
    else
        wget --no-check-certificate -O /tmp/mysqlsetup.tar.gz "${mysqlsetup:-${backup_server}}"
    fi
    
    # 验证MySQL安装文件下载是否成功
    mysqlsize=$(du -b /tmp/mysqlsetup.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
    if [ "$mysqlsize" -gt 1000000 ] 2>/dev/null; then
        sleep 1
    else
        echo -e "${Separator}"
        echo -e "${mysqlsetup}"
        echo -e "${red}下载失败,以上链接可能失效,即将更换地址重新下载。"
        sleep 3
        wget --no-check-certificate -O /tmp/mysqlsetup.tar.gz "${Url}mysqlsetup.tar.gz"
        mysqlsize=$(du -b /tmp/mysqlsetup.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
        if [ "$mysqlsize" -gt 1000000 ] 2>/dev/null; then
            sleep 1
        else
            echo -e "${Separator}"
            echo -e "${Url}mysqlsetup.tar.gz"
            echo -e "${red}下载失败,请检查链接或网络连接后重试。"
            echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty
            if [[ -z ${digit} ]]; then
                echo
            fi
            installMysqlDnf
            return
        fi
    fi
    
    # 下载数据库SQL文件
    wget --no-check-certificate -q -O /tmp/dnfsql.tar.gz "${Url}dnfsql.tar.gz"
    dnfsqlsize=$(du -b /tmp/dnfsql.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
    if [ "$dnfsqlsize" -gt 1000000 ] 2>/dev/null; then
        sleep 1
    else
        echo -e "${Separator}"
        echo -e "${Url}dnfsql.tar.gz"
        echo -e "${red}下载失败,请检查链接或网络连接后重试。"
        echo -n -e "${determine}${yellow}按回车键继续,按Ctrl+c取消 ... ...${font}"; read -r digit </dev/tty
        if [[ -z ${digit} ]]; then
            echo
        fi
        installMysqlDnf
        return
    fi
    
    clear
    echo -e "${Separator}"
    echo -e "${tip}DOF相关组件下载完成!${success}" && sleep 1
    echo -e "${tip}开始解压home文件!${success}"
    
    # 解压Siroco文件
    tar zxf /tmp/Dnf_Siroco.tar.gz -C >/dev/null 2>&1
    echo -e "${tip}文件解压程序完成!${success}"
    sleep 1
    
    # 安装MySQL依赖
    yum -y install numactl perl libaio autoconf >/dev/null 2>&1
    rm -rf /etc/my.cnf
    
    echo -e "${Separator}"
    echo -e "${tip}开始根据当前系统配置分配mysql优化参数!${success}"
    sleep 1
    echo
   
    # 显示MySQL配置参数
    echo -e "${info}binlog 缓存设定为[${mysqlBinlogCacheSize}]!${success}"
    echo -e "${info}新线程的堆栈大小设定为[${mysqlThreadStack}]!${success}"
    echo -e "${info}join 操作缓存的大小设定为[${mysqlJoinBufferSize}]!${success}"
    echo -e "${info}内存表最大内存限制设定为[${mysqlMaxHeapTableSize}]!${success}"
    echo -e "${info}MyISAM 索引缓存的大小设定为[${mysqlKeyBufferSize}]!${success}"
    echo -e "${info}当前表二级缓存的大小设定为[${mysqlTableOpenCache}]!${success}"
    echo -e "${info}排序操作时的缓冲大小设定为[${mysqlSortBufferSize}]!${success}"
    echo -e "${info}指定段检索时的缓冲大小设定为[${mysqlReadBufferSize}]!${success}"
    echo -e "${info}读取临时表时的缓冲区大小设定为[${mysqlReadRndBufferSize}]!${success}"
    echo -e "${info}存储线程的缓存大小设定为[${mysqlThreadCacheSize}]!${success}"
    echo -e "${info}查询缓存的大小设定为[${mysqlQueryCacheSize}]!${success}"
    echo -e "${info}指定内存临时表的大小设定为[${mysqlTmpTableSize}]!${success}"
    echo -e "${info}MySQL 服务器最大并发连接数设定为[${mysqlMaxConnections}]!${success}"
    echo -e "${info}InnoDB 存储引擎的缓冲池大小设定为[${mysqlInnodbBufferPoolSize}]!${success}"
    echo -e "${Separator}"
    
    # 生成MySQL配置文件
    writerMyCnf
    
    sleep 1
    chmod 644 /etc/my.cnf
    
    # 创建MySQL用户和组
    groupadd mysql
    useradd -g mysql mysql
    
    # 解压MySQL安装包
    cd / || { echo -e "${error}切换到根目录失败"; return 1; }
    echo -e "${tip}开始解压mysql数据库文件!${success}"
    tar -zxf /tmp/mysqlsetup.tar.gz -C / >/dev/null 2>&1
    echo -e "${tip}文件解压程序完成!${success}"
    
    # 配置MySQL
    mv /mysql-5.6.51-linux-glibc2.12-x86_64 /mysql
    sleep 2
    sqlmodea=sql_mode=" "
    sed -i "s/sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES/${sqlmodea}/g" /mysql/support-files/my-default.cnf >/dev/null 2>&1
    sleep 1
    
    # 移动MySQL到系统目录
    rm -rf /usr/local/mysql
    mv mysql /usr/local/
    mkdir -p /var/lib/mysql/mysql
    chown -R mysql:mysql /var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql/mysql
    
    # 初始化MySQL
    cd /usr/local/mysql || { echo -e "${error}切换到MySQL目录失败"; return 1; }
    chown -R mysql:mysql ./
    ./scripts/mysql_install_db --user=mysql >/dev/null 2>&1
    chown -R mysql:mysql data
    cp -f ./support-files/mysql.server /etc/rc.d/init.d/mysqld
    chmod +x /etc/rc.d/init.d/mysqld
    chkconfig --add mysqld
    # shellcheck disable=SC1091
    echo "export PATH=\$PATH:/usr/local/mysql/bin" >>/etc/profile
    # shellcheck disable=SC1091
    source /etc/profile
    
    # 解压SQL文件并启动MySQL
    tar -zxf /tmp/dnfsql.tar.gz -C /tmp/ >/dev/null 2>&1
    service mysqld start >/dev/null 2>&1
    
    # 检查MySQL是否启动成功
    if service mysqld status >/dev/null 2>&1; then
        echo -e "${tip}数据库启动成功!${success}"
    else
        echo -e "${tip}数据库启动失败,请检查数据库版本号或者Url链接!${error}"
    fi
    
    # 导入初始数据库
    mysql -u'root' -h'127.0.0.1' --default-character-set=utf8 </tmp/dnf1.sql
    service mysqld restart >/dev/null 2>&1
    mysql_upgrade --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' >/dev/null 2>&1
    rm -rf /home/mysql >/dev/null 2>&1
    service mysqld restart >/dev/null 2>&1
    echo -e "${Separator}"
    
    # 配置MySQL客户端设置
    config_file="/etc/my.cnf"
    if grep -qF "[client]" "$config_file"; then
        if ! grep -q 'user=game' "$config_file"; then
            sed -i '/\[client\]/a\user=game' "$config_file"
        fi
        if ! grep -q 'password=uu5!^%jg' "$config_file"; then
            sed -i '/\[client\]/a\password=uu5!^%jg' "$config_file"
        fi
        if ! grep -q 'host=127.0.0.1' "$config_file"; then
            sed -i '/\[client\]/a\host=127.0.0.1' "$config_file"
        fi
    else
        echo -e "[client]\nuser=game\npassword=uu5!^%jg\nhost=127.0.0.1" >> "$config_file"
    fi
    
    # 导入第二部分数据库
    mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' --default-character-set=utf8 </tmp/dnf2.sql
    service mysqld restart >/dev/null 2>&1
    echo -e "${tip}DOF数据库环境配置成功 ${success}"
    
    # 创建MySQL日志目录
    if [ ! -d "/var/log/mysql" ]; then
        sudo mkdir -p /var/log/mysql
        sudo chown mysql:mysql /var/log/mysql
    fi
    
    # 执行下一步骤
    installDnf
}

function installDnf() {
    # 安装服务端
    echo -e "${info}正在安装服务端${load}"
    
    # 进入服务端目录
    cd /home/neople || { echo -e "${error}切换到neople目录失败"; return 1; }
    
    # 复制加密库到系统目录
    cp -f /home/neople/game/libnxencryption.so /usr/lib/
    
    # 设置数据库连接信息
    MYSQL=127.0.0.1
    MYSQLNAME=game
    PASSWD=uu5!^%jg
    PWDKey=20e35501e56fcedbe8b10c1f8bc3595be8b10c1f8bc3595b
    
    # 更新配置文件中的信息
    sed -i "s/Public IP/${IP}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    sed -i "s/MySQL IP/${MYSQL}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    sed -i "s/MySQL Name/${MYSQLNAME}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    sed -i "s/MySQL PWD/${PASSWD}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    sed -i "s/MySQL Key/${PWDKey}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    sed -i "s/stun_ip= UDP IP/stun_ip= ${UDPIP}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    
    echo -e "${tip}服务端安装完成!${success}" && sleep 1s
    
    # 检查系统内存并设置SWAP
    mem=$(free -m | awk '/^Mem:/{print $2}')

    if [ "$mem" -gt 13000 ]; then
        sleep 3
        echo -e "${info}${greens}当前内存足够处理读/写性能,无须创建Swap空间。${font}"
        backupSettings
        return
    elif [ "$mem" -gt 7000 ]; then
        echo -e "${tip}${yellows}当前内存需求可能会溢出,开始分配4G Swap空间。${font}"
        block_size=4M
    elif [ "$mem" -gt 3000 ]; then
        echo -e "${tip}${yellows}当前内存需求可能会溢出,开始分配6G Swap空间。${font}"
        block_size=6M
    elif [ "$mem" -gt 1500 ]; then
        echo -e "${tip}${yellows}当前内存需求可能会溢出,开始分配8G Swap空间。${font}"
        block_size=8M
    else
        echo -e "${error}${reds}当前服务器不满足创建Swap空间的需求。"
        backupSettings
        return
    fi

    # 检查SWAP是否已存在
    if grep -q "$swap_part" /proc/swaps; then
        echo -e "${tip}${yellows}Swap 空间已存在。${font}"
        backupSettings
        return
    else
        echo -e "${info}${blues}正在设置 Swap 空间,可能用时较久,请稍作等候...${font}"
        dd if=/dev/zero of="$swap_part" bs="$block_size" count=1000 >/dev/null 2>&1
        chmod 600 "$swap_part"
        mkswap "$swap_part"
        swapon "$swap_part"
        echo -e "$swap_part        none    swap    sw      0       0" >> /etc/fstab
        sed -i 's/swapoff -a/#swapoff -a/g' /etc/rc.d/rc.local
    fi

    # 清除内存缓存
    echo 1 >/proc/sys/vm/drop_caches
    backupSettings
}

function backupSettings() {
    # 检查数据库映射文件
    echo -e "${tip}检查数据库映射文件${load}"
    
    # 创建MySQL符号链接
    cd /usr/local/bin || { echo -e "${error}切换到/usr/local/bin目录失败"; return 1; }
    ln -fs /MYSQLPATH/bin/mysql mysql >/dev/null 2>&1
    ln -s /usr/local/mysql/bin/mysql /usr/bin >/dev/null 2>&1
    
    cd "$HOME" || { echo -e "${error}切换到HOME目录失败"; return 1; }
    sleep 1
    
    # 查找MySQL位置
    whereis mysql >/dev/null 2>&1
    
    # 创建mysqldump符号链接
    ln -fs /usr/local/mysql/bin/mysqldump /usr/bin >/dev/null 2>&1
    echo -e "${tip}数据库映射文件检查成功${load}"
    
    # 执行预设配置
    executePreset
}

function executePreset() {
    # 根据用户选择的等级安装补丁
    if [[ $df_game_r -eq 50 || $df_game_r -eq 60 || $df_game_r -eq 65 || $df_game_r -eq 70 || 
          $df_game_r -eq 75 || $df_game_r -eq 80 || $df_game_r -eq 85 || $df_game_r -eq 86 || 
          $df_game_r -eq 90 || $df_game_r -eq 95 || $df_game_r -eq 100 || $df_game_r -eq 110 || 
          $df_game_r -eq 120 ]]; then
        
        echo -e "${tip}开始下载并安装[${reds}${df_game_r}${font}]级等级补丁[基础防提,效果略差,建议用m选项]。${load}"
        wget --no-check-certificate -q -O /tmp/dj.tar.gz "${Url}ftq/${df_game_r}.tar.gz" && sleep 1 >/dev/null 2>&1
        
        df_game_rsize=$(du -b /tmp/dj.tar.gz 2>/dev/null | awk '{print $1}' || echo 0)
        if [ "$df_game_rsize" -gt 1000000 ] 2>/dev/null; then
            sleep 1
        else
            echo -e "${Separator}"
            echo -e "${Url}ftq/${df_game_r}.tar.gz"
            echo -e "${red}下载失败,请检查以上链接是否可下载或者等级是否输入错误。${font}"
            df_game_r=""
        fi
        
        # 解压补丁文件
        tar -zxf /tmp/dj.tar.gz -C / >/dev/null 2>&1
        rm -rf /tmp/dj.tar.gz >/dev/null 2>&1
        
        # 设置安全权限
        sudo chmod 4700 /usr/sbin/useradd >/dev/null 2>&1
        sudo chown root:root /usr/sbin/useradd >/dev/null 2>&1
        sudo chmod 4700 /usr/sbin/passwd >/dev/null 2>&1
        sudo chown root:root /usr/sbin/passwd >/dev/null 2>&1
        sudo chmod 4700 /etc/passwd >/dev/null 2>&1
        sudo chown root:root /etc/passwd >/dev/null 2>&1
    else
        if [[ -z ${df_game_r} ]]; then
            df_game_r="未指定等级"
        else
            echo -e "${red}抱歉,不支持该等级。${font}"
        fi
    fi
    
    # 配置自动备份
    if [[ ${autobaksql} != 2 ]]; then
        yum install -y crontabs >/dev/null 2>&1 && chkconfig crond on
        cat <<EOF >/etc/cron.hourly/back
cd /root/dof;./sql;cd
EOF
        cat <<EOF >/etc/cron.d/0hourly
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/
1 */2 * * * root run-parts /etc/cron.hourly
EOF

        chmod -R a+x /etc/cron.hourly
        service crond restart >/dev/null 2>&1
    fi
    
    # 配置UDP端口IP
    if [[ ${UDPIP} != 2 ]]; then
        UDPIP=${udp_php}
    else
        UDPIP=${IP}
    fi
    
    cd /home/neople/game/cfg || { echo -e "${error}切换到cfg目录失败"; return 1; }
    echo -e "${tip}${yellows}开始转发UDP端口IP,解决组队问题!${font}"
    sed -i "s/stun_ip= *.*.*.*/stun_ip= ${UDPIP}/g" "$(find . -type f -name "*.cfg")" >/dev/null 2>&1
    
    # 设置MySQL密码
    if [[ -z ${mysqlmm} ]]; then
        mysqlmm=uu5!^%jg
    fi
    
    cd "$HOME" || { echo -e "${error}切换到HOME目录失败"; return 1; }
    
    # 更新MySQL用户密码
    mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
    UPDATE mysql.user SET PASSWORD=PASSWORD('${mysqlmm}') WHERE User='game' and Host='%';
    flush privileges;
EOF
    
    # 提高系统安全性
    sudo sed -i 's/CREATE_HOME yes/CREATE_HOME no/' /etc/login.defs
    sudo chmod 750 /usr/sbin/useradd
    sudo chown root:root /usr/sbin/useradd
    
    # 限制MySQL权限
    mysql --defaults-extra-file=/etc/my.cnf -h'127.0.0.1' <<-EOF >/dev/null 2>&1
    REVOKE CREATE USER ON *.* FROM 'game'@'127.0.0.1';
EOF
    
    # 完成安装
    dnfOk
}

function writerMyCnf() {
    # 生成MySQL配置文件
    cat <<EOF >/etc/my.cnf
#dofserver my.cnf config files;

[client]
port = 3306
socket = /var/lib/mysql/mysql.sock
default-character-set=latin1

[mysql]
no-auto-rehash

[mysqld]
general_log = 1
general_log_file = /var/log/mysql/mysql.log
event_scheduler = ON
user = mysql
port = 3306
socket = /var/lib/mysql/mysql.sock
datadir = /var/lib/mysql
open_files_limit = 65535
federated
back_log = 600
max_prepared_stmt_count=124000
max_connect_errors = 6000
query_cache_limit = 2M
ft_min_word_len = 4
query_cache_min_res_unit = 2k
default-storage-engine = InnoDB
character-set-server = latin1
transaction_isolation = READ-COMMITTED
expire_logs_days = 7
bulk_insert_buffer_size = 8M
myisam_max_sort_file_size = 10G
interactive_timeout = 28800
wait_timeout = 28800
myisam_recover-options
skip-name-resolve
lower_case_table_names = 1
server-id = 1
table_open_cache= 4096
table_definition_cache=8192
innodb_flush_log_at_trx_commit = 2
innodb_lock_wait_timeout = 120
innodb_file_per_table = 1
innodb_open_files = 2000
query_cache_type = 1
default-storage-engine=InnoDB
character-set-server=latin1
skip-external-locking
net_buffer_length = 4K
max_allowed_packet = 4M
myisam_sort_buffer_size = 16M
binlog_cache_size = ${mysqlBinlogCacheSize}
thread_stack = ${mysqlThreadStack}
join_buffer_size = ${mysqlJoinBufferSize}
max_heap_table_size = ${mysqlMaxHeapTableSize}
key_buffer_size = ${mysqlKeyBufferSize}
table_open_cache = ${mysqlTableOpenCache}
sort_buffer_size = ${mysqlSortBufferSize}
read_buffer_size = ${mysqlReadBufferSize}
read_rnd_buffer_size = ${mysqlReadRndBufferSize}
thread_cache_size = ${mysqlThreadCacheSize}
query_cache_size = ${mysqlQueryCacheSize}
tmp_table_size = ${mysqlTmpTableSize}
max_connections = ${mysqlMaxConnections}
innodb_buffer_pool_size = ${mysqlInnodbBufferPoolSize}
[mysqldump]
quick
max_allowed_packet = 16M

[mysqld_safe]
log-error = /var/log/mysql/mysql_error.log
pid-file = /var/run/mysqld/mysqld.pid
EOF
}

function dnfOk() {
    # 获取MySQL版本号
	mysql_version=$(mysql -V 2>/dev/null | grep -oP 'Distrib \K[0-9.]+') || true
    export mysql_version
    
    # shellcheck disable=SC1091
    # 更新环境变量
	source /etc/profile
    
    # 计算安装用时
    dnf_end=$(date +%s)
    dnf_endtime=$(date "+%Y-%m-%d %H:%M:%S")
    let_time=$((dnf_end-dnf_start))
    
    # 清理屏幕
    clear
    
    # 设置脚本权限
    chmod -R 0777 /root/run >/dev/null 2>&1
    chmod -R 0777 /root/stop >/dev/null 2>&1
    
    # 清理临时文件
    rm -rf /tmp/errorlog
    rm -rf /tmp/*
    
    # 回到主目录
    cd "$HOME" || { echo -e "${error}切换到HOME目录失败"; exit 1; }
    
    # 设置系统时区
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    
    # 创建Web目录
    mkdir -p /opt/lampp/htdocs
    mkdir -p /var/www/html
    
    # 同步系统时间
    date -s "$(curl --silent XX.XX.XX.XX/time.php)"
    
    # 清理屏幕
    clear
    
    # 显示logo
    setupLogo
    
    # 清理屏幕并显示安装摘要
    clear
    echo -e "${yellows}==============================================================================${font}
${reds}DOF一键端安装成功!本一键端预置了以下功能!${font}
${purple}[防卡商城][防卡点券][防提权][拍卖行邮件乱码修复][等级补丁和dp包含更多功能]${font}

--${reds}当前数据库版本号[${mysql_version}]${font}--
${blue}数据库帐号:game
数据库密码:${mysqlmm}${font}

${green}开始系统时间为:${dnf_starttime}
结束系统时间为:${dnf_endtime}${font}
${reds}搭建总用时间为:${let_time}秒${font}

请在/home/neople/game/目录下上传[Script.pvf]
当前等级为:${red}[${df_game_r}]${font}

[常用指令]${red}输入减号后回车进入指令界面！${font}
${yellows}==============================================================================${font}" && echo
    
    # 重启系统
    echo -e "${red}服务器已重启,请稍后重新连接... ....${font}"
    reboot
}

function timeCheck() {
    # 校对服务器时间
    clear
    echo -e "${input}"
    echo -e "${info}更新服务器时间${load}"
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    date -s "$(curl --silent XX.XX.XX.XX/time.php)" >/dev/null 2>&1
    yum install ntpdate -y >/dev/null 2>&1
    ntpdate cn.pool.ntp.org >/dev/null 2>&1
    hwclock --systohc >/dev/null 2>&1
    echo -e "${tip}当前系统时间为: $(date "+%Y-%m-%d %H:%M:%S") "
    echo -e "${info}服务器时间更新完成${success}"
}

main "$@" # 调用主函数并传递所有脚本参数
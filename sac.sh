#!/bin/bash

version="Ver3.0.0"

# 更新脚本本体 / Update the script itself
update_script() {
    echo -e "正在更新脚本喵~ / Updating the script~"
    curl -O https://raw.githubusercontent.com/XhyEax/UTMAlpine/main/sac.sh
    echo -e "重启终端或者输入bash sac.sh重新进入脚本喵~ / Restart the terminal or run bash sac.sh to re-enter the script~"
}

# 命令行参数：sac.sh update 直接更新脚本本体后退出 / CLI argument: run `sac.sh update` to update the script itself and exit
if [ "$1" = "update" ]; then
    update_script
    exit 0
fi

st_version=$(grep '"version"' "SillyTavern/package.json" | awk -F '"' '{print $4}')
echo "hoping：卡在这里了？...说明有小猫没开魔法喵~ / Stuck here? It means your magic (proxy) isn't on~"
latest_version=$(curl -s https://raw.githubusercontent.com/XhyEax/UTMAlpine/main/VERSION)
st_latest=$(curl -s https://raw.githubusercontent.com/SillyTavern/SillyTavern/release/package.json | grep '"version"' | awk -F '"' '{print $4}')
# hopingmiao=hotmiao
#

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

kill_unix() {
  local PROCESS_NAME="$1"

  # Check ps command format and determine PID column
  PS_TEST=$(ps -ef 2>/dev/null | head -n 1)
  if [ $? -eq 0 ]; then
    # Modern ps -ef format available
    # Check if PID is in first or second column by looking at header
    if echo "$PS_TEST" | grep -q "^UID"; then
      # Standard format: UID PID PPID...
      PIDS=$(ps -ef | grep "$PROCESS_NAME" | grep -v grep | awk '{print $2}')
    else
      # Some systems might have PID as first column
      PIDS=$(ps -ef | grep "$PROCESS_NAME" | grep -v grep | awk '{print $1}')
    fi
  elif ps aux >/dev/null 2>&1; then
    # Try BSD-style ps aux format
    PIDS=$(ps aux | grep "$PROCESS_NAME" | grep -v grep | awk '{print $2}')
  elif ps >/dev/null 2>&1; then
    # Minimal ps command
    PIDS=$(ps | grep "$PROCESS_NAME" | grep -v grep | awk '{print $1}')
  else
    # Last resort: try pgrep
    PIDS=$(pgrep -f "$PROCESS_NAME" 2>/dev/null)
  fi

  if [ -z "$PIDS" ]; then
    # echo "No $PROCESS_NAME processes found."
    :
  else
    # echo "Found $PROCESS_NAME processes with PIDs: $PIDS"
    for PID in $PIDS; do
      echo "正在结束进程 $PID... / Killing process $PID..."
      kill -9 $PID 2>/dev/null
    done
    echo "所有 $PROCESS_NAME 进程已结束。 / All $PROCESS_NAME processes terminated."
  fi
}

update_node() {
  # 定义Node.js版本和架构变量 / Define Node.js version and arch variables
  NODE_VERSION="22.14.0"
  NODE_ARCH="linux-arm64"

  # 构建文件名和目录名 / Build file name and directory name
  NODE_FILE="node-v${NODE_VERSION}-${NODE_ARCH}.tar.xz"
  NODE_DIR="node-v${NODE_VERSION}-${NODE_ARCH}"

  # 检查node是否已安装 / Check whether node is already installed
  if command -v node &> /dev/null; then
    # 获取当前版本号 / Get current version number
    CURRENT_VERSION=$(node --version | sed 's/^v//')

    # 比较版本号 / Compare version numbers
    if [ "$CURRENT_VERSION" = "$NODE_VERSION" ]; then
      echo "当前Node.js版本已是v${NODE_VERSION}，无需更新 / Current Node.js is already v${NODE_VERSION}, no update needed"
      return 0
    else
      echo "当前Node.js版本为v${CURRENT_VERSION}，将更新至v${NODE_VERSION} / Current Node.js is v${CURRENT_VERSION}, will update to v${NODE_VERSION}"
    fi
  else
    echo "未检测到Node.js，将安装v${NODE_VERSION} / Node.js not detected, will install v${NODE_VERSION}"
  fi

  # 下载Node.js / Download Node.js
  echo "正在下载Node.js v${NODE_VERSION}... / Downloading Node.js v${NODE_VERSION}..."
  curl -O "https://nodejs.org/dist/v${NODE_VERSION}/${NODE_FILE}"

  # 解压文件 / Extract the archive
  echo "正在解压文件... / Extracting files..."
  tar xf "${NODE_FILE}"

  # 添加到PATH / Add to PATH
  echo "正在配置环境变量... / Configuring environment variables..."
  echo "export PATH=/root/${NODE_DIR}/bin:\$PATH" >>/etc/profile
  source /etc/profile

  # 检查安装是否成功 / Check whether installation succeeded
  if command -v node &> /dev/null; then
    NEW_VERSION=$(node --version)
    echo "Node.js ${NEW_VERSION} 安装成功 / installed successfully"
  else
    echo "Node.js安装失败，╮(︶﹏︶)╭，请尝试手动下载 / installation failed, please try downloading manually: curl -O https://nodejs.org/dist/v${NODE_VERSION}/${NODE_FILE}"
    exit 1
  fi
}

# 检查是否存在git指令 / Check whether the git command exists
if command -v git &> /dev/null; then
    echo "git指令存在 / git command found"
    git --version
else
    echo "git指令不存在，建议回termux下载git喵~ / git not found, please go back to termux and install git~"
fi

# 检查是否存在node指令 / Check whether the node command exists
if command -v node &> /dev/null; then
    echo "node指令存在 / node command found"
    node --version
else
    echo "node指令不存在，正在尝试重新下载喵~ / node not found, trying to download it again~"
    update_node
fi

#添加termux上的Ubuntu/root软链接 / Add the Ubuntu/root symlink on termux
# if [ ! -d "/data/data/com.termux/files/home/root" ]; then
#     ln -s /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root /data/data/com.termux/files/home
# fi

# echo "root软链接已添加，可直接在mt管理器打开root文件夹修改文件 / root symlink added, you can open the root folder in MT Manager to edit files"

if [ ! -d "SillyTavern" ]; then
    echo "SillyTavern不存在，正在通过git下载... / SillyTavern not found, downloading via git..."
    git clone --depth=1 https://github.com/SillyTavern/SillyTavern SillyTavern
    echo -e "\033[0;33m本操作仅为破限下载提供方便，所有破限皆为收录，喵喵不具有破限所有权 / This only provides a convenient download; all presets are merely collected and we claim no ownership of them\033[0m"
    read -p "回车进行导入破限喵~ / Press Enter to import presets~"
    rm -rf /root/st_promot
    git clone --depth=1 https://github.com/hopingmiao/promot.git /root/st_promot
    if  [ ! -d "/root/st_promot" ]; then
        echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因网络波动预设文件下载失败了，更换网络后再试喵~ / Preset download failed due to network issues, please switch network and try again~\n\033[0m"
    else
    cp -r /root/st_promot/. /root/SillyTavern/public/'OpenAI Settings'/
    echo -e "\033[0;33m破限已成功导入，安装完毕后启动酒馆即可看到喵~ / Presets imported successfully, start SillyTavern after install to see them~\033[0m"
    fi
fi

if [ ! -d "SillyTavern" ]; then
	echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因网络波动文件下载失败了，更换网络后再试喵~ / Download failed due to network issues, please switch network and try again~\n\033[0m"
	exit 2
fi

function sillyTavernSettings {
    # 4. SillyTavern设置 / SillyTavern settings
	echo -e "\033[0;36mhoping：选一个执行喵~ / Pick one to run~\033[0m
\033[0;33m当前版本/Current:\033[0m$st_version \033[0;33m最新版本/Latest:\033[0m\033[5;36m$st_latest\033[0m
\033[0;33m--------------------------------------\033[0m
\033[0;33m选项1 安装 TavernAI-extras（酒馆拓展） / Install TavernAI-extras\033[0m
\033[0;37m选项2 启动 TavernAI-extras（酒馆拓展） / Start TavernAI-extras\033[0m
\033[0;33m选项3 修改 酒馆端口 / Change SillyTavern port\033[0m
\033[0;37m选项4 导入 最新整合预设 / Import latest presets\033[0m
\033[0;33m选项5 自定义 模型名称 / Custom model name\033[0m
\033[0;37m选项6 自定义 unlock上下文长度 / Custom unlock context length\033[0m
\033[0;33m选项7 删除 旧版本酒馆(不包括上一版本) / Delete old versions (except previous)\033[0m
\033[0;37m选项8 回退 上一版本酒馆 / Roll back to previous version\033[0m
\033[0;33m选项9 导出 当前版本酒馆 / Export current version\033[0m
\033[0;33m--------------------------------------\033[0m
\033[0;31m选项0 更新酒馆 / Update SillyTavern\033[0m
\033[0;33m--------------------------------------\033[0m
"
    read -n 1 option
    echo
    case $option in
        0)
			echo -e "hoping：选择更新模式(重要数据会进行转移，但喵喵最好自己有备份)喵~ / Choose update mode (important data is migrated, but you'd better keep your own backup)~\n\033[0;33m--------------------------------------\n\033[0m\033[0;33m选项1 使用git pull进行简单更新 / Simple update with git pull\n\033[0m\033[0;37m选项2 几乎重新下载进行全面更新 / Full update by re-downloading almost everything\n\033[0m"
            read -n 1 -p "" stup_choice
			echo
			cd /root
			case $stup_choice in
				1)
					cd /root/SillyTavern
					git pull
					;;
				2)
					if [ -d "SillyTavern_old" ]; then
						NEW_FOLDER_NAME="SillyTavern_$(date +%Y%m%d)"
						mv SillyTavern_old $NEW_FOLDER_NAME
					fi
					echo -e "
hoping：选择更新正式版或者测试版喵？/ Update to release or staging version?
\033[0;33m选项1 正式版 / Release\033[0m
\033[0;37m选项2 测试版 / Staging\033[0m"
					while :
					do
					    read -n 1 stupdate
					    [ "$stupdate" = 1 ] && { git clone --depth=1 https://github.com/SillyTavern/SillyTavern.git SillyTavern_new; break; }
					    [ "$stupdate" = 2 ] && { git clone --depth=1 -b staging https://github.com/SillyTavern/SillyTavern.git SillyTavern_new; break; }
					    echo -e "\n\033[5;33m选择错误，快快重新选择喵~ / Wrong choice, please choose again~\033[0m"
					done

					if [ ! -d "SillyTavern_new" ]; then
						echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因为网络波动下载失败了，更换网络再试喵~ / Download failed due to network issues, please switch network and try again~\n\033[0m"
						exit 5
					fi

					if [ -d "SillyTavern/data/default-user" ]; then
					    cp -r SillyTavern/data/default-user/characters/. SillyTavern_new/public/characters/
    					cp -r SillyTavern/data/default-user/chats/. SillyTavern_new/public/chats/
    					cp -r SillyTavern/data/default-user/worlds/. SillyTavern_new/public/worlds/
    					cp -r SillyTavern/data/default-user/groups/. SillyTavern_new/public/groups/
    					cp -r SillyTavern/data/default-user/group\ chats/. SillyTavern_new/public/group\ chats/
    					cp -r SillyTavern/data/default-user/OpenAI\ Settings/. SillyTavern_new/public/OpenAI\ Settings/
    					cp -r SillyTavern/data/default-user/User\ Avatars/. SillyTavern_new/public/User\ Avatars/
    					cp -r SillyTavern/data/default-user/backgrounds/. SillyTavern_new/public/backgrounds/
    					cp -r SillyTavern/data/default-user/settings.json SillyTavern_new/public/settings.json
					else
    					cp -r SillyTavern/public/characters/. SillyTavern_new/public/characters/
    					cp -r SillyTavern/public/chats/. SillyTavern_new/public/chats/
    					cp -r SillyTavern/public/worlds/. SillyTavern_new/public/worlds/
    					cp -r SillyTavern/public/groups/. SillyTavern_new/public/groups/
    					cp -r SillyTavern/public/group\ chats/. SillyTavern_new/public/group\ chats/
    					cp -r SillyTavern/public/OpenAI\ Settings/. SillyTavern_new/public/OpenAI\ Settings/
    					cp -r SillyTavern/public/User\ Avatars/. SillyTavern_new/public/User\ Avatars/
    					cp -r SillyTavern/public/backgrounds/. SillyTavern_new/public/backgrounds/
    					cp -r SillyTavern/public/settings.json SillyTavern_new/public/settings.json
					fi

					mv SillyTavern SillyTavern_old
					mv SillyTavern_new SillyTavern
					echo -e "\033[0;33mhoping：酒馆已更新完毕，启动后若丢失聊天请回退上一版本喵~ / SillyTavern updated; if chats are missing after launch, roll back to the previous version~\033[0m"
					;;
			esac
			st_version=$(grep '"version"' "SillyTavern/package.json" | awk -F '"' '{print $4}')
            ;;
        1)
            #安装TavernAI-extras（酒馆拓展）及其环境 / Install TavernAI-extras and its environment
			TavernAI-extrasinstall
            ;;
        2)
            #启动TavernAI-extras（酒馆拓展） / Start TavernAI-extras
			TavernAI-extrasstart
            ;;
		3)
			if [ ! -f "SillyTavern/config.yaml" ]; then
				echo -e "当前酒馆版本过低，请更新酒馆版本后重试 / SillyTavern version is too low, please update it and try again"
				exit
			fi
            read -p "是否要修改开放端口?(y/n) / Change the open port? (y/n)" choice

            if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
                # 读取用户输入的端口号 / Read the port number entered by the user
                read -p "请输入开放的端口号: / Enter the port to open:" custom_port
                # 更新配置文件的端口号 / Update the port in the config file
                sed -i 's/port: [0-9]*/port: '$custom_port'/g' SillyTavern/config.yaml
                echo "端口已修改为$custom_port / Port changed to $custom_port"
            else
                echo "未修改端口号 / Port not changed"
            fi
            ;;
        4)
            #导入破限 / Import presets
            echo -e "$(curl -s https://raw.githubusercontent.com/hopingmiao/promot/main/STpromotINFO)"
            echo "是否导入当前预设喵？[y/n] / Import the current presets? [y/n]"
            read choice
            if [[ "$choice" == [yY] ]]; then
                echo -e "\033[0;33m本操作仅为破限下载提供方便，所有破限皆为收录，喵喵不具有破限所有权 / This only provides a convenient download; all presets are merely collected and we claim no ownership of them\033[0m"
                sleep 2
                rm -rf /root/st_promot
                git clone --depth=1 https://github.com/hopingmiao/promot.git /root/st_promot
                if  [ ! -d "/root/st_promot" ]; then
                    echo -e "(*꒦ິ⌓꒦ີ)\n\033[0;33m hoping：因网络波动文件下载失败了，更换网络后再试喵~ / Download failed due to network issues, please switch network and try again~\n\033[0m"
                exit 6
                fi
                cp -r /root/st_promot/. /root/SillyTavern/public/'OpenAI Settings'/
                echo -e "\033[0;33m破限已成功导入，启动酒馆看看喵~ / Presets imported successfully, start SillyTavern to check~\033[0m"
            else
                echo "当前预设未导入喵~ / Presets not imported~"
            fi
            ;;
        5)
            echo -e "\033[5;33m当前存在自定义模型有： / Existing custom models:\033[0m"
            echo -e "$(sed -n '/<optgroup label="自定义">/,/<optgroup label="GPT-3.5 Turbo">/{s/.*<option value="\([^"]*\)".*/\1/p}' SillyTavern/public/index.html)"
            echo "是否添加自定义模型喵[y/n]？ / Add a custom model? [y/n]"
            read cuschoice
            if [[ "$cuschoice" == [yY] ]]; then
                echo "输入自定义的模型名称喵~ / Enter the custom model name~"
                read CUSTOM_INPUT_VALUE
                grep -q '<optgroup label="自定义">' "SillyTavern/public/index.html" && sed -i "/<optgroup label=\"自定义\">/a\ \ \ \ <option value=\"$CUSTOM_INPUT_VALUE\">$CUSTOM_INPUT_VALUE</option>" "SillyTavern/public/index.html" || { sed -i "/<optgroup label=\"GPT-3.5 Turbo\">/i\<optgroup label=\"自定义\">\n\ \ \ \ <option value=\"$CUSTOM_INPUT_VALUE\">$CUSTOM_INPUT_VALUE</option>\n</optgroup>" "SillyTavern/public/index.html"; sed -i "/<optgroup label=\"Versions\">/i\<optgroup label=\"自定义\">\n\ \ \ \ <option value=\"$CUSTOM_INPUT_VALUE\">$CUSTOM_INPUT_VALUE</option>\n</optgroup>" "SillyTavern/public/index.html"; }
                echo -e "\033[0;33m已添加$CUSTOM_INPUT_VALUE模型喵~ / Model $CUSTOM_INPUT_VALUE added~\033[0m"
            else
                echo "并未添加喵~ / Nothing added~"
            fi
            sleep 2
            ;;
        6)
            unlocked_max=$(sed -n 's/^const unlocked_max = \(.*\);$/\1/p' SillyTavern/public/scripts/openai.js)
            echo "当前unlocked_max(最大上下文)为$unlocked_max喵~ / Current unlocked_max (max context) is $unlocked_max~"
            echo "是否修改最大上下文喵？[y/n] / Change the max context? [y/n]"
            read unlockedchoice
            if [[ "$unlockedchoice" == [yY] ]]; then
                echo "输入unlocked_max值，例如200000 / Enter the unlocked_max value, e.g. 200000"
                read unlocked_max
                sed -i "s/^const unlocked_max = .*;/const unlocked_max = ${unlocked_max};/" "SillyTavern/public/scripts/openai.js"
            else
                echo "并未修改喵~ / Nothing changed~"
            fi
            ;;
        7)
            echo -e "当前存在 / Currently present"
            ls | grep "^SillyTavern_\([^o].*\|..+\.?.*\)$"
            echo -e "是否删除所有旧版本酒馆喵？ / Delete all old SillyTavern versions?"
            read delSTChoice
            [[ "$delSTChoice" == [yY] ]] && { echo -e "开始删除喵~ / Deleting~"; ls | grep "^SillyTavern_\([^o].*\|..+\.?.*\)$" | xargs -d"\n" rm -r; echo -e "旧版本酒馆删除完成了喵~ / Old versions deleted~"; } || echo "什么都没有执行喵~ / Nothing was done~" >&2
            ;;
        8)
            while :
            do
                [ ! -d SillyTavern_old ] && { echo -e "hoping：当前未检查到上一版本喵~ / No previous version detected~"; break; }
                echo -e "版本正在回退中，请稍等喵~ / Rolling back the version, please wait~"
                mv SillyTavern SillyTavern_temp
                mv SillyTavern_old SillyTavern
                mv SillyTavern_temp SillyTavern_old
                echo -e "hoping：版本回退成功了喵~ / Version rolled back successfully~"
                st_version=$(grep '"version"' "SillyTavern/package.json" | awk -F '"' '{print $4}')
                break
            done
            ;;
        9)
            [ ! command -v zip &> /dev/null ] && { DEBIAN_FRONTEND=noninteractive apt install zip -y; }
            echo -e "\033[0;33m压缩文件中，请稍等喵~ / Compressing files, please wait~\033[0m"
            rm -rf SillyTavern.zip
            zip -rq SillyTavern.zip SillyTavern/
            echo -e "文件压缩完成 / Compression complete"
            python -m http.server 8976 &
            echo -e "hoping：\033[0;33m十秒后将关闭网页并回到主页面喵~ / The page will close and return to the main menu in ten seconds~\033[0m"
            termux-open-url http://127.0.0.1:8976/SillyTavern.zip
            sleep 10
            rm -rf SillyTavern.zip
            pkill -f 'python -m http.server'
            ;;
        *)
            echo "什么都没有执行喵~ / Nothing was done~"
            ;;
    esac
}

function TavernAI-extrasinstall {

	echo -e "安装TavernAI-extras（酒馆拓展）分为三步骤\n分别大致所需\n三分钟\n\033[0;33m七分钟\n\033[0m\033[0;31m十五分钟\n\033[0m具体时间视情况而定\n\033[0;31m全部安装大致所需\033[0;33m 3 \033[0m\033[0;31mG存储(不包括额外模型) / Installing TavernAI-extras has three steps, roughly 3 / 7 / 15 minutes each (actual time varies); a full install needs about 3 GB of storage (excluding extra models)\033[0m"
	echo -e "当出现\n\033[0;32m恭喜TavernAI-extras（酒馆拓展）所需环境已完全安装，可进行启动喵~\033[0m\n则说明安装完毕喵~ / When you see the green 'environment fully installed' message, installation is complete~"
	read -p "是否现在进行安装TavernAI-extras（酒馆拓展）[y/n]？ / Install TavernAI-extras now? [y/n]" extrasinstallchoice
	[ "$extrasinstallchoice" = "y" ] || [ "$extrasinstallchoice" = "Y" ] && echo "已开始安装喵~ / Installation started~" || exit 7
	#检测环境 / Check the environment
	if [ ! -d "/root/TavernAI-extras" ]; then
		echo "hoping:未检测到TavernAI-extras（酒馆拓展），正在通过git下载 / TavernAI-extras not detected, downloading via git"
		git clone --depth=1 https://github.com/Cohee1207/TavernAI-extras /root/TavernAI-extras
		[ -d /root/TavernAI-extras ] || { echo "TavernAI-extras（酒馆拓展）安装失败，请更换网络后重试喵~ / TavernAI-extras install failed, please switch network and try again~"; exit 8; }
	fi

	if [ ! -d "/root/myenv" ] || [ ! -f "/root/myenv/bin/activate" ]; then
		rm -rf /root/myenv
		# 更新软件包列表并安装所需软件包，重定向输出。 / Update package lists and install required packages, redirecting output.
		echo "正在更新软件包列表... / Updating package lists..."
		apt update -y > /dev/null 2>&1

		echo -e "\033[0;33m正在安装python3虚拟环境，请稍候\n\033[0;33m(hoping：首次安装大概需要7到15分钟喵~) / Installing the python3 virtual environment, please wait (first install takes about 7-15 minutes)..."
		read -p "是否现在进行安装喵？[y/n] / Install now? [y/n]" python3venvchoicce
		[ "$python3venvchoicce" = "y" ] || [ "$python3venvchoicce" = "Y" ] && DEBIAN_FRONTEND=noninteractive apt install python3 python3-pip python3-venv -y || exit 9
		echo "python3虚拟环境安装完成。正在创建虚拟环境 / python3 virtual environment installed. Creating the virtual environment"
		python3 -m venv /root/myenv
		echo "虚拟环境完成，路径为/root/myenv / Virtual environment ready at /root/myenv"
	fi
	echo -e "\033[0;31m正在安装requirements.txt所需依赖\n\033[0m(hoping：首次安装大概需要15至30分钟，最后构建时会出现长时间页面无变化，请耐心等待喵~) / Installing dependencies from requirements.txt (first install takes about 15-30 minutes; the final build may show no progress for a while, please be patient)..."
	read -p "是否现在进行安装喵？[y/n] / Install now? [y/n]" requirementschoice
	[ "$requirementschoice" = "y" ] || [ "$requirementschoice" = "Y" ] && { source /root/myenv/bin/activate; cd /root/TavernAI-extras; pip3 install -r requirements.txt; } || exit 10
	echo -e "喵喵？\n\033[0;32m恭喜TavernAI-extras（酒馆拓展）所需环境已完全安装，可进行启动喵~ / Congrats, the TavernAI-extras environment is fully installed and ready to start~\033[0m"

}

function TavernAI-extrasstart {

	if [ ! -d "/root/TavernAI-extras" ] || [ ! -d "/root/myenv" ] || [ ! -f "/root/myenv/bin/activate" ]; then
	echo "检测到当前环境不完整，先进行TavernAI-extras（酒馆拓展）安装喵~ / Environment is incomplete, please install TavernAI-extras first~"
	exit 11
	fi
	echo -e "\033[0;33m喵喵小提示：\n\033[0m启动对应拓展时可能需要额外下载，具体情况可以查看官方文档喵~ / Tip: starting some modules may require extra downloads, see the official docs for details~"
	sleep 3

	#进入虚拟环境 / Enter the virtual environment
	source /root/myenv/bin/activate
	cd /root/TavernAI-extras
	#确认依赖已安装 / Make sure dependencies are installed
	echo -e "正在检测依赖安装情况喵~ / Checking dependency installation~"
	pip3 install -r requirements.txt
	clear

	# 选项数组 / Options array
	modules=("caption" "chromadb" "classify" "coqui-tts" "edge-tts" "embeddings" "rvc" "sd" "silero-tts" "summarize" "talkinghead" "websearch" "确认" "退出")

	# 数组中选项的状态，0 - 未选择，1 - 已选定 / Option states: 0 - unselected, 1 - selected
	declare -A selection_status

	# 初始化选项状态 / Initialize option states
	for i in "${!modules[@]}"; do
	  selection_status[$i]=0
	  selection_status[4]=1
	done

	# 函数：打印已选中的选项 / Function: print the selected options
	print_selected() {
	  selected_modules=()
	  for i in "${!selection_status[@]}"; do
		if [[ "${selection_status[$i]}" -eq 1 ]]; then
		  selected_modules+=("${modules[$i]}")
		fi
	  done
	  echo -e "\033[0;33m--------------------------------\033[0m"
	  echo -e "\033[0;33m使用上↑，下↓进行控制\n\033[0m回车选中，再次选中可取消选定\n\033[0;33m选择完毕后选择确认即可喵~ / Use ↑/↓ to move, Enter to toggle, then pick 确认/Confirm when done~\033[0m"
	  echo "喵喵当前选择了 / Currently selected: $(IFS=,; echo -e "\033[0;36m${selected_modules[*]}\033[0m")"
	}

	# 函数：显示菜单 / Function: show the menu
	show_menu() {
	  print_selected
	  echo -e "\033[0;33m--------------------------------\033[0m"
	  for i in "${!modules[@]}"; do
		if [[ "$i" -eq "$current_selection" ]]; then
		  # 当前选择中的选项使用绿色显示 / Highlight the current option in green
		  echo -e "${GREEN}${modules[$i]} (选择中 / selecting)${NC}"
		elif [[ "${selection_status[$i]}" -eq 1 ]]; then
		  # 被选定的选项使用红色显示 / Show selected options in red
		  echo -e "${RED}${modules[$i]} (已选定 / selected)${NC}"
		else
		  # 其他选项正常显示 / Show other options normally
		  echo -e "${modules[$i]} (未选择 / unselected)"
		fi
	  done
	  echo -e "\033[0;33m--------------------------------\033[0m"
	}

	current_selection=0
	while true; do
	  show_menu
	  # 读取用户输入 / Read user input
	  IFS= read -rsn1 key

	  case "$key" in
		$'\x1b')
		  # 读取转义序列 / Read the escape sequence
		  read -rsn2 -t 0.1 key
		  case "$key" in
			'[A') # 上箭头 / Up arrow
			  if [[ $current_selection -eq 0 ]]; then
				current_selection=$((${#modules[@]} - 1))
			  else
				((current_selection--))
			  fi
			  ;;
			'[B') # 下箭头 / Down arrow
			  if [[ $current_selection -eq $((${#modules[@]} - 1)) ]]; then
				current_selection=0
			  else
				((current_selection++))
			  fi
			  ;;
		  esac
		  ;;
		"") # Enter键 / Enter key
		  if [[ $current_selection -eq $((${#modules[@]} - 2)) ]]; then
			# 选择 "确认" 选项 / Chose the "Confirm" option
			break
		  elif [[ $current_selection -eq $((${#modules[@]} - 1)) ]]; then
			# 选择 "退出" 选项 / Chose the "Exit" option
			exit 12
		  else
			# 切换选择状态 / Toggle the selection state
			selection_status[$current_selection]=$((1 - selection_status[$current_selection]))
		  fi
		  ;;
		'q') # 按 'q' 退出 / Press 'q' to exit
		  break
		  ;;
	  esac
	  # 清除屏幕以准备下一轮显示 / Clear the screen for the next round
	  clear
	done

	# 构建命令行 / Build the command line
	command="python3 server.py"
	if [ ${#selected_modules[@]} -ne 0 ]; then
	  command+=" --enable-module=$(IFS=,; echo "${selected_modules[*]}")"
	fi

	# 打印最终的命令行 / Print the final command line
	clear
	echo "正在启动相关酒馆拓展喵~ / Starting the selected extras~:"
	echo "$command"
	eval $command



}
# 主菜单 / Main menu
echo -e "
喵喵一键脚本 / Meow All-in-One Script
版本 / Version：酒馆/ST:$st_version 脚本/Script:$version
最新 / Latest：\033[5;36m酒馆/ST:$st_latest\033[0m \033[0;33m脚本/Script:$latest_version\033[0m
类脑Discord(角色卡发布等 / character cards etc.): https://discord.gg/HWNkueX34q
此程序完全免费，不允许对脚本/教程进行盗用/商用。运行时需要稳定的魔法网络环境。
This program is completely free; reselling or commercial use of the script/tutorial is prohibited. A stable proxy network is required while running."
while :
do
    echo -e "\033[0;36mhoping喵~让你选一个执行（输入数字即可），懂了吗？/ Pick one to run (just enter a number), got it?\033[0;38m(｡ì _ í｡)\033[0m\033[0m
\033[0;33m--------------------------------------\033[0m
\033[0;31m选项0 退出脚本 / Exit script\033[0m
\033[0;33m选项1 启动酒馆 / Start SillyTavern\033[0m
\033[0;37m选项2 酒馆设置 / SillyTavern settings\033[0m
\033[0;33m--------------------------------------\033[0m
\033[0;31m选项3 更新脚本 / Update script\033[0m
\033[0;32m选项4 更新Node / Update Node\033[0m
\033[0;33m--------------------------------------\033[0m
\033[0;35m不准选其他选项，听到了吗？/ Don't pick anything else, okay?
\033[0m\n"
    read -n 1 option
    echo
    case $option in
        0)
            break ;;
        1)
            #启动SillyTavern / Start SillyTavern
			kill_unix "server.js"
            cd SillyTavern
	        bash start.sh
            echo "酒馆已关闭, 即将返回主菜单 / SillyTavern closed, returning to the main menu"
            cd ../
            ;;
        2)
            #SillyTavern设置 / SillyTavern settings
            sillyTavernSettings
            ;;
        3)
            # 更新脚本 / Update script
            update_script
            break ;;
	4)
            # 更新Node / Update Node
            update_node
	    echo -e "重启终端或者输入bash sac.sh重新进入脚本喵~ / Restart the terminal or run bash sac.sh to re-enter the script~"
            break ;;
        *)
            echo -e "m9( ｀д´ )!!!! \n\033[0;36m坏猫猫居然不听话，存心和我hoping喵~过不去是吧？ / Naughty kitty won't listen, trying to mess with hoping?\033[0m\n"
            ;;
    esac
done
echo "已退出喵喵一键脚本，输入 bash sac.sh 可重新进入脚本喵~ / Exited the Meow script; run bash sac.sh to re-enter~"
exit

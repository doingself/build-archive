#!/bin/sh

# xcodebuild
# xcodebuild -showsdks查看可用的SDK
# xcodebuild -list查看项目全部的targets，schemes和configurations
# chmod +x ./test.sh  #使脚本具有执行权限
# ./test.sh #执行脚本

SECONDS=0

_project_name="xxxx"

_scheme=${_project_name}
_workspace="${_project_name}.xcworkspace"
_Plist_file="xcodebuild_AdHoc.plist"
_configuration="Release" # Release / Debug

_path="/Users/${USER}/Desktop/ipas"
_log_file="${_path}/${_project_name}.txt"
_archive_file="${_path}/${_project_name}.xcarchive"
_ipa_path="${_path}/${_project_name}"
_ipa_file="${_ipa_path}/${_project_name}.ipa"

_pgy_api="bb288cefc195f3151870578d10062925"
_pgy_user="cfaa38d34b3a08fb01d0de24b4ef09a9"
_pgy_url="https://www.pgyer.com/manager/dashboard/app/"
_pgy_desc=`git log -10 --pretty="%h %s" --no-merges`


function clean(){
    # 清理
    _start_seconds="$(date "+%s")"

    echo "~~~~~~~~~~~~ clean 🍺 ~~~~~~~~~~~~"

    # xcodebuild clean -workspace ${_workspace} -scheme ${_scheme} -configuration ${_configuration} -destination 'generic/platform=iOS' -quiet || exit
    xcodebuild clean -workspace ${_workspace} -scheme ${_scheme} -configuration ${_configuration} -destination 'generic/platform=iOS' >> ${_log_file}

    _end_seconds=`date +"%s"`
    _sum_time=$[ $_end_seconds - $_start_seconds ]

    if (($? == 0))
    then
        echo "~~~~~~~~~~~~ clean success ✅ (${_sum_time}) ~~~~~~~~~~~~"
    else
        echo "~~~~~~~~~~~~ clean faild ❌ (${_sum_time}) ~~~~~~~~~~~~"
    fi
}

function build(){
    # 编译
    _start_seconds="$(date "+%s")"

    echo "~~~~~~~~~~~~ build 🍺 ~~~~~~~~~~~~"

    xcodebuild build -workspace ${_workspace} -scheme ${_scheme} -configuration ${_configuration} -destination 'generic/platform=iOS' >> ${_log_file}

    _end_seconds=`date +"%s"`
    _sum_time=$((_end_seconds-_start_seconds))
    # _sum_time=`expr $_end_seconds - $_start_seconds`
    # _sum_time=$[ $_end_seconds - $_start_seconds ]

    if (($? == 0))
    then
        echo "~~~~~~~~~~~~ build success ✅ (${_sum_time}) ~~~~~~~~~~~~"
    else
        echo "~~~~~~~~~~~~ build faild ❌ (${_sum_time}) ~~~~~~~~~~~~"
    fi
}

function archive(){
    # 打包
    _start_seconds="$(date "+%s")"

    #打包前, 删除旧文件
    rm -rf ${_archive_file}

    echo "~~~~~~~~~~~~ archive 🍺 ~~~~~~~~~~~~"

    xcodebuild archive -workspace ${_workspace} -scheme ${_scheme} -configuration ${_configuration} -archivePath ${_archive_file} -destination 'generic/platform=iOS' >> ${_log_file}

    _end_seconds=`date +"%s"`
    _sum_time=$[ $_end_seconds - $_start_seconds ]

    # 目录存在, 则表示成功
    if [ -d ${_archive_file} ]
    then
        echo "~~~~~~~~~~~~ archive success ✅ (${_sum_time}) ~~~~~~~~~~~~"
    else
        echo "~~~~~~~~~~~~ archive faild ❌ (${_sum_time}) ~~~~~~~~~~~~"
    fi
}

function exportArchive(){
    # 4 导出IPA xcodebuild
    _start_seconds="$(date "+%s")"
    
    # 导出前, 先删除旧文件
    rm -rf ${_ipa_path}

    echo "~~~~~~~~~~~~ exportArchive 🍺 ~~~~~~~~~~~~"

    if [ -d ${_archive_file} ]
    then
        xcodebuild -exportArchive -archivePath ${_archive_file} -exportPath ${_ipa_path} -exportOptionsPlist ${_Plist_file} >> ${_log_file}

        _end_seconds=`date +"%s"`
        _sum_time=$[ $_end_seconds - $_start_seconds ]

        # 文件存在, 则表示成功
        if [ -e ${_ipa_file} ]
        then
            echo "~~~~~~~~~~~~ exportArchive success ✅ (${_sum_time}) ~~~~~~~~~~~~"
        else
            echo "~~~~~~~~~~~~ exportArchive faild ❌ (${_sum_time}) ~~~~~~~~~~~~"
        fi
    else
        echo "~~~~~~~~~~~~ ${_archive_file} 不存在 💣 ~~~~~~~~~~~~"
    fi
}

function uploadPGY(){
    #上传蒲公英
    _start_seconds="$(date "+%s")"

    echo "~~~~~~~~~~~~ 上传ipa到蒲公英 🍺 ~~~~~~~~~~~~"

    if [ -e ${_ipa_file} ]
    then
        curl -F "file=@${_ipa_file}" \
        -F "uKey=${_pgy_user}" \
        -F "_api_key=${_pgy_api}" \
        -F "updateDescription=${_pgy_desc}" \
        "http://www.pgyer.com/apiv1/app/upload"

        _end_seconds=`date +"%s"`
        _sum_time=$[ $_end_seconds - $_start_seconds ]

        if (($? == 0))
        then
            echo "~~~~~~~~~~~~ 上传ipa到蒲公英 success ✅ (${_sum_time}) ~~~~~~~~~~~~"
            echo "蒲公英地址: ${_pgy_url}"
        else
            echo "~~~~~~~~~~~~ 上传ipa到蒲公英 faild ❌ (${_sum_time}) ~~~~~~~~~~~~"
        fi

    else
        echo "~~~~~~~~~~~~ ${_ipa_file} 不存在 💣 ~~~~~~~~~~~~"
    fi
}

# 清理 - 打包 - 导出 - 上传
function startClean(){
    clean
    if (($? == 0))
    then
        startArchive
    fi
}

# 打包 - 导出 - 上传
function startArchive(){
    archive

    # 目录存在, 则表示成功
    if [ -d ${_archive_file} ]
    then
        startExportArchive
    fi   
}

# 导出 - 上传
function startExportArchive(){
    exportArchive

    # 文件存在, 则表示成功
    if [ -e ${_ipa_file} ]
    then
        uploadPGY
    fi
}

function dsymHandle(){
    echo "~~~~~~~~~~~~ 压缩dSYM文件 🍺 ~~~~~~~~~~~~"
    cd "${_archive_file}/dSYMs"
    zip -r -o "${_project_name}.app.dSYM.zip" "${_project_name}.app.dSYM"
    echo "~~~~~~~~~~~~ 压缩dSYM文件 success ✅ ~~~~~~~~~~~~"
}

function main(){

    if [ ! -d ${_path} ];
    then
    mkdir -p ${_path};
    fi

    # 删除旧文件
    rm -rf ${_log_file}
    # rm -rf ${_archive_file}
    # rm -rf ${_ipa_path}

    if (($# == 0))
    then
        while :
        do
        echo '~~~~~~~~~~~~ 使用 xcodebuild 🚀 自动打包上传蒲公英 ⏳ ~~~~~~~~~~~~'
        echo  "📌 输入 1: 清理 🗑 + 打包 💼 + 导出 ipa 🧩 + 上传蒲公英 📎"
        echo  "📌 输入 2: 打包 💼 + 导出 ipa 🧩 + 上传蒲公英 📎"
        echo  "📌 输入 3: 导出 ipa 🧩 + 上传蒲公英 📎"
        echo  "📌 输入 4: 上传蒲公英 📎"
        echo  "📌 输入 5: 清理 🗑"
        echo  "📌 输入 6: 编译 🏗"
        echo  "📌 输入 7: 打包 💼"
        echo  "📌 输入 8: 导出 ipa 🔫"
        echo  "📌 输入 0: 退出 🏃‍♂️"
        echo  "🕹  请输入菜单序号: ✍️"

        read aNum
        case $aNum in
            0) break;;
            1) startClean
            break;;
            2) startArchive
            break;;
            3) startExportArchive
            break;;
            4) uploadPGY
            break;;
            5) clean
            break;;
            6) build
            break;;
            7) archive
            break;;
            8) exportArchive
            break;;
            *) echo '~~~~~~~~~~~~~~ 输入异常 🧨 ~~~~~~~~~~~~~~'
            continue;;
        esac
        done
    fi
}

main

# 输出总用时
echo "~~~~~~~~~~~~ 执行耗时: ${SECONDS}秒 ⏰ ~~~~~~~~~~~~"

exit 0




###################################
###################################
###################################


num=0
str=''
max=100
postfix=('|' '/' '-' '\')
while [ $num -le $max ]
do
    let index=num%4
    shellwidth=`stty size | awk '{print $2}'`
    shellwidthstr="%-"$shellwidth"s\n"
    fmt_str="now "$num" shell tty width "$shellwidth
    printf "$shellwidthstr" "$fmt_str"
    printf "loading: [%-50s %-2d%% %c]\r" "$str" "$num" "${postfix[$index]}"
    let num++
    sleep 0.1
    if (($num % 2 == 0)); then
        str+='#'
    fi
done
printf "\n"


function testShell(){
    echo "第一个参数为：$1 ";
    echo "第三个参数为：${3} ";
    echo "参数个数为：$# ";
    echo "作为一个字符串输出所有参数 $* "
    echo "显示最后命令的退出状态(0表示没有错误)：$? "
    
    # $0：当前Shell程序的文件名
    # dirname $0，取得当前执行的脚本文件的父目录
    # cd `dirname $0`，进入这个目录(切换当前工作目录)
    # pwd，显示当前工作目录(cd执行后的)
    _current_path=$(cd -P $(dirname $0);pwd)

    # 桌面路径
    _desktop_path="~/Desktop"

    #包名后缀(日期+时间)
    _date="$(date "+%Y-%m-%d_%H-%M-%S")"
    
    _file="${base_dir}/xcodebuild.sh"

    echo "current_path: ${_current_path}"
    echo "desktop_path: ${_desktop_path}"
    echo "date: ${_date}"
    echo "file: ${_file}"

    # chmod +x ./test.sh #使脚本具有执行权限
    # ./test.sh  #执行脚本
    if [ -x ${_file} ]
    then
       echo "文件可执行"
    else
       echo "文件不可执行"
    fi

    return ${_file}
}

testShell 10 2 3 4 5 5

exit 0

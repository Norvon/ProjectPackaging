# target_name 在项目根目录通过 xcodebuild -list 查看
target_name='App' # 需要修改

# 项目绝对路径 
project_path="/Users/nor/Desktop/MyCode/App/App.xcodeproj" # 需要修改

# Debug or Release
build_configuration='Release' # 需要修改

# 导出包配置文件 和脚本放在一个目录 
# teamID 修改给自己的
# method这个字段对应的值：app-store, ad-hoc, enterprise, development
export_options_plist_path=./ExportOptions.plist # 需要修改

# pgyer_UserKey 和 pgyer_ApiKey 需要在蒲公英的账号设置中查找 
# https://www.pgyer.com/doc/api#uploadApp  路径 uKey 和 _api_key
pgyer_UserKey="" # 需要修改
pgyer_ApiKey="" # 需要修改

# 生产的文件路径
base_save_path=./${target_name}/${target_name}_$(date +%Y-%m-%d_%H-%M-%S)
export_archive_path=${base_save_path}/xcarchive/${target_name}.xcarchive
export_ipa_path=${base_save_path}/${target_name}_$(date +%Y-%m-%d_%H-%M-%S)_ipa/

# clean
cleanProject() {
    echo "\033[46;30m ~~~~~~~~~~~~~~~~ clean 开始 ~~~~~~~~~~~~~~~~ \033[0m"

    if [[ $project_path =~ .xcodeproj$ ]]; then
        echo 123
        xcodebuild clean\
        -project ${project_path} \
        -scheme ${target_name} \
        -configuration ${build_configuration} 
    else 
        xcodebuild clean\
        -workspace ${project_path} \
        -scheme ${target_name} \
        -configuration ${build_configuration} 
    fi
}

# archive
archivePorject() {

    echo "\033[46;30m ~~~~~~~~~~~~~~~~ archive 开始 ~~~~~~~~~~~~~~~~ \033[0m"
    if [[ $project_path =~ .xcodeproj$ ]]; then
        xcodebuild archive\
        -project ${project_path} \
        -scheme ${target_name} \
        -configuration ${build_configuration} \
        -archivePath ${export_archive_path} 
    else 
        xcodebuild archive\
        -workspace ${project_path} \
        -scheme ${target_name} \
        -configuration ${build_configuration} \
        -archivePath ${export_archive_path} 
    fi  
}

# exprot
exprotProjectIpa() {
    echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 导出 ipa ~~~~~~~~~~~~~~~~~~~ \033[0m"
    xcodebuild -exportArchive \
    -archivePath ${export_archive_path} \
    -exportPath ${export_ipa_path} \
    -exportOptionsPlist ${export_options_plist_path} \
    -allowProvisioningUpdates
}

# upload
uploadIpaToPgyer() {
    echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 上传 ipa ~~~~~~~~~~~~~~~~~~~ \033[0m"
    curl -F "file=@${export_ipa_path}${target_name}.ipa" \
     -F "uKey=${pgyer_UserKey}" \
     -F "_api_key=${pgyer_ApiKey}" \
     -F "installType=2" \
     -F "password=csyapp" \
     -F "updateDescription=${pgyerDescription}" \
     https://upload.pgyer.com/apiv1/app/upload
}

# 打包
packaging() {
    cleanProject
    if (($? != 0)); then
        echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 💔💔 clean 失败  💔💔~~~~~~~~~~~~~~~~~~~ \033[0m \n"
        exit 
    fi
    echo "\033[46;30m  ~~~~~~~~~~~~~~~~ clean 成功 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"

    archivePorject
    if (($? != 0)); then
        echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 💔💔 archive 失败  💔💔~~~~~~~~~~~~~~~~~~~ \033[0m \n"
        exit 
    fi
    echo "\033[46;30m  ~~~~~~~~~~~~~~~~ archive 成功 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"

    exprotProjectIpa
    if (($? != 0)); then
        echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 💔💔  导出 ipa 失败 💔💔 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"
        exit 
    fi
    echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 导出ipa成功 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"
}

# 打包和上传
packagingAndUpload() {
    packaging   
    if (($? != 0)); then
        echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 💔💔 打包失败 💔💔 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"
        exit 
    fi

    uploadIpaToPgyer
    if (($? != 0)); then
        echo "\033[46;30m  ~~~~~~~~~~~~~~~~ 💔💔 上传蒲公英失败 💔💔 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"
        exit 
    fi
    echo "\n \033[46;30m ~~~~~~~~~~~~~~~~ 上传蒲公英成功 ~~~~~~~~~~~~~~~~~~~ \033[0m \n"
}


main() {
    read -p '是否上传蒲公英：YES 上传 ：' isUpload

    isUpload=$(echo $isUpload| tr '[A-Z]' '[a-z]') # 输入大写转小写
    if [ "yes" = $isUpload ] ; then # 上传和打包
        echo "\033[46;30m '上传' \033[0m\n"
        read -p "输入蒲公英上传描述：" pgyerDescription

        start_time=$(date +%s)
        packagingAndUpload # 打包和上传
        end_time=$(date +%s)

        echo "\033[46;30m 打包上传总用时：$((end_time-start_time))s \033[0m\n"
        open $export_ipa_path
    else # 打包
        echo "\033[46;30m '不上传' \033[0m\n"

        start_time=$(date +%s)
        packaging # 打包
        end_time=$(date +%s)
        echo "\033[46;30m 打包总用时：$((end_time-start_time))s  \033[0m\n"
        open $export_ipa_path
    fi
}

main
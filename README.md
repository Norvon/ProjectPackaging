# ProjectPackaging
iOS 项目自动打包上传到 蒲公英

## 使用
修改脚本里面的内容：工程名、项目绝对路径
修改 `ExportOptions.plist` 下：`teamID` 、`method`
只需要修改前20行数据

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
    

注意：
    `ExportOptions.plist`  里面修改 `teamID` 和  `method` 这两个字段为自己  `compileBitcode`  这个字段为 `YES` 会报错，暂时设置为 `NO` 
    

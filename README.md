# build-archive

iOS 使用脚本 (xcodebuild / fastlane) 自动打包, 并导出 ipa 上传蒲公英 (个人喜欢 fir)

目前只支持 Ad-Hoc 包

## xcodebuild

1. 拷贝文件 `xcodebuild_AdHoc.plist` 和 `xcodebuild.sh` 到项目中, 与 `xxx.xcworkspace` 同级目录
2. 修改 `xcodebuild.sh` 文件中的 `_project_name` 为实际项目名称 (targets 名称)
3. 修改 `xcodebuild_AdHoc.plist` 文件中的 `teamID` 为 `xxx.xcodeproj/project.pbxproj` 中的 `DEVELOPMENT_TEAM`
4. 修改 `xcodebuild.sh` 中的 蒲公英账号
5. 使用终端进入项目地址, 运行 `./xcodebuild.sh`

```
~~~~~~~~~~~~ 使用 xcodebuild 🚀 自动打包上传蒲公英 ~~~~~~~~~~~~
📌 输入 1: 清理 + 打包 + 导出 ipa + 上传蒲公英
📌 输入 2: 打包 + 导出 ipa + 上传蒲公英
📌 输入 3: 导出 ipa + 上传蒲公英
📌 输入 4: 上传蒲公英
📌 输入 5: 清理 🗑
📌 输入 6: 编译 🏗
📌 输入 7: 打包 💼
📌 输入 8: 导出 ipa 🔫
📌 输入 0: 退出 🏃‍♂️
```

## Fastlane

### 环境配置

1. 安装 `sudo gem install fastlane -NV`
2. 查看版本 `fastlane --version`
3. 进入项目目录, 初始化 `fastlane init` (我选择 4)
4. 安装蒲公英的 Fastlane 插件 `fastlane add_plugin pgyer`
5. 卸载 `sudo gem uninstall fastlane`

### 使用

编辑 `fastlane/Fastfile` 文件

1. 配置 项目名称
2. 配置 蒲公英账号
3. 运行 `fastlane ios dev`

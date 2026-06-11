# Changelog

## 鸿蒙化Log

### v3.1.1
- release v3.1.1

### v3.1.1-rc.2
- fix:移除扫码登录接口遗留代码 by @qiaojianqiang in [#77](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/77)

### v3.1.1-rc.1
- fix:移除扫码登录接口遗留代码 by @qiaojianqiang in [#73](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/73)

### v3.1.0
- release v3.1.0

### v3.0.6-rc.5
**What's Changed**
- 修改demo中测试的小程序信息 by @yangwwwping in [#49](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/49)
- feat: wechat_open_sdk升级至1.0.14 && isWXAppInstalled重构 by @yangwwwping in [#51](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/51)
- refactor: react_native_wechat_lib模块重构 by @yangwwwping in [#53](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/53)
- feat: support shareWebpage、shareVideo、shareFile by @yangwwwping in [#55](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/55)
- feat: support sharing online files by @yangwwwping in [#57](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/57)
- feat: add shareToLineTime interface by @yangwwwping in [#59](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/59)
- feat: support shareToTimeline by @yangwwwping in [#60](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/60)
- feat: add demo for shareToTimeline by @yangwwwping in [#61](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/61)
- feat: Support isSecretMessage in WXWebpageObject by @yangwwwping in [#62](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/62)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.6-rc.4 by @yangwwwping in [#64](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/64)

### v3.0.6-rc.3
**What's Changed**
- fix: 兼容早期API 12 by @yangwwwping in [#46](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/46)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.6-rc.3 by @yangwwwping in [#47](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/47)

### v3.0.6-rc.2
**What's Changed**
- fix: 分享小程序图片为空无错误提示 by @yangwwwping in [#41](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/41)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.6-rc.2 by @yangwwwping in [#43](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/43)

### v3.0.6-rc.1
**What's Changed**
- 支持分享小程序 by @yangwwwping in [#35](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/35)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.6-rc.1#37 by @yangwwwping in [#39](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/39)

### v3.0.5
**What's Changed**
- fix: 修复连续点击扫码登录会crash的问题 by @dream-approaching in [#29](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/29)
- feat: 与原库保持一致，移除扫码登录 by @dream-approaching in [#31](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/31)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.5 by @dream-approaching in [#32](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/32)

### v3.0.5-rc.3
**What's Changed**
- feat: "@tencent/wechat_open_sdk" 升级 "1.0.3" & 添加 launchMiniProgram 接口 by @dream-approaching in [#23](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/23)
- build: 取消buildOptionSet混淆配置 by @dream-approaching in [#25](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/25)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.5-rc.3 by @dream-approaching in [#27](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/27)

### v3.0.5-rc.2
**What's Changed**
- fix: 修复下载不到@tencent/wechat_open_sdk 的问题 by @dream-approaching in [#19](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/19)
- feat: 添加 android 手动 link 配置 by @dream-approaching in [#20](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/20)
- releases：@react-native-ohos/react-native-wechat-lib@3.0.5-rc.2 by @dream-approaching in [#21](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/21)

### v3.0.5-rc.1
**What's Changed**
- ci: Clear initial project by @dream-approaching in [#1](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/1)
- build: 初始化工程与项目结构 by @dream-approaching in [#2](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/2)
- feat: 鸿蒙化适配 by @dream-approaching in [#3](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/3)
- feat: 统一文件名后缀为ets，修改entryAbility中引用方式 by @dream-approaching in [#5](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/5)
- refactor: 修改 package.json by @abilit68 in [#7](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/7)
- feat:添加 sharelocalimage 原生侧实现代码 by @abilit68 in [#9](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/9)
- 接口联调：registerApp，openWXApp，shareText，sendAuthRequest，authByScan，ShareImage，ShareLocalImage by @dream-approaching in [#11](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/11)
- feat: App修改为用例模式 by @dream-approaching in [#13](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/13)
- feat: 添加源码以及har包 by @dream-approaching in [#15](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/15)
- feat: 添加 pay 用例 by @dream-approaching in [#17](https://github.com/react-native-oh-library/react-native-wechat-lib/pull/17)

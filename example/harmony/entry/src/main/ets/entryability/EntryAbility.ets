import {RNAbility} from '@rnoh/react-native-openharmony';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { WXApi, WXEventHandler } from '@react-native-ohos/react-native-wechat-lib/src/main/ets/model/WXApiWrap';

export default class EntryAbility extends RNAbility {

  onCreate(want: Want) {
    super.onCreate(want)
    this.handleWeChatCallIfNeed(want)
  }

  getPagePath() {
    return 'pages/Index';
  }

  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
    this.handleWeChatCallIfNeed(want)
  }

  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler)
  }
}

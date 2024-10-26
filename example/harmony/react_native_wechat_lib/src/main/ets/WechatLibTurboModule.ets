/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { EventEmitter, TurboModule } from '@rnoh/react-native-openharmony/ts';
import { TM } from './generated/ts';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wxopensdk, WXEventHandler } from '../../../ts';
import { http } from '@kit.NetworkKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { Want } from '@kit.AbilityKit';

enum LoadingStatus {
  INIT,
  LOADING,
  SCANNING,
  SCANNED,
  SUCCESS,
  FAILED,
  INVALID_APP_SECRET,
}

type CallbackBoolean = (error: string | null, result: null | boolean) => void

interface GeneratedTypeLiteralInterface_2 {
  authCode: string | null;
  errCode: wxopensdk.OAuthErrCode | null;
}

type CallbackAuthCode = (error: string | null, result: GeneratedTypeLiteralInterface_2 | null) => void

export class WechatLibTurboModule extends TurboModule implements TM.WechatLibTurboModule.Spec {
  private appId: string | null = null;
  private wxEventHandler = WXEventHandler
  private static wxApi: wxopensdk.WXApi | null = null;
  private context = getContext(this) as common.UIAbilityContext;
  lastOAuth: wxopensdk.IDiffDevOAuth | null = null
  loadStatus: LoadingStatus = LoadingStatus.INIT
  private NOT_REGISTERED = "registerApp required.";
  private API_NOT_SUPPORTED = "Api not supported.";
  private logger = this.ctx.logger.clone('WechatLibTurboModuleLogger');
  listener = new EventEmitter();
  unsubscribeAuthGotQrcode = () => {};

  subscribeAuthGotQrcode(onQRGet: (qrcode: string) => void) {
    this.unsubscribeAuthGotQrcode = this.listener.subscribe(
      'onAuthGotQrcode',
      (qrcode: string) => onQRGet && onQRGet(qrcode),
    );
  }

  unSubscribeAuthGotQrcode() {
    this.unsubscribeAuthGotQrcode();
  }

  registerCallback(name: string, handler: (result: null | Object) => void) {
    this.wxEventHandler.registerOnWXRespCallback(name, handler)
  }

  unregisterCallback(name: string) {
    this.wxEventHandler.unregisterOnWXRespCallback(name)
  }

  public static handleWant(want: Want) {
    WechatLibTurboModule.wxApi?.handleWant(want, WXEventHandler)
  }

  /**
   * 暂不支持的接口统一返回
   * @returns
   */
  notSupportPromise(callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
    } else {
      callback(this.API_NOT_SUPPORTED, null);
    }
  }

  /**
   * 注册应用，初始化WechatLibTurboModule.wxApi
   * @param appId
   * @param universalLink
   * @returns
   */
  registerApp(appId: string, universalLink: string, callback: CallbackBoolean) {
    try {
      this.appId = appId;
      WechatLibTurboModule.wxApi = wxopensdk.WXAPIFactory.createWXAPI(appId);
      callback(null, true)
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while registering app with appId ${appId}: ${message}`);
      callback(message, false)
    }
  }

  isWXAppInstalled(callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  isWXAppSupportApi(callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  getApiVersion(callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  /**
   * 打开微信
   * @returns
   */
  async openWXApp(callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      WechatLibTurboModule.wxApi.openWechat(this.context) as boolean;
      // 常规是需要await等待结果返回，这里内部没有resolve，等不到结果 所以直接返回true
      callback(null, true);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while openWXAppopenWXApp ${message}`);
    }
  }

  async sendAuthRequest(scope: string, state: string, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    let req = new wxopensdk.SendAuthReq
    req.isOption1 = false
    req.nonAutomatic = true
    req.scope = scope
    req.state = state
    req.transaction = ''

    try {
      // 调用 api.sendReq 方法并返回结果
      WechatLibTurboModule.wxApi.sendReq(this.context, req);
      callback(null, true);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while sendAuthRequest ${message}`);
    }
  }

  // 触发 QRCode 事件
  emitQRCode(base64String: string) {
    this.listener.emit('onAuthGotQrcode', base64String);
  }

  async authByScan(
    appid: string,
    nonceStr: string,
    timeStamp: string,
    scope: string,
    signature: string,
    schemeData: string,
    callback: CallbackAuthCode
  ) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    if (this.lastOAuth) {
      this.lastOAuth.stopOAuth()
    }
    let oauth = wxopensdk.DiffDevOAuthFactory.getDiffDevOAuth()!

    oauth.startOAuth(appid, scope, nonceStr, timeStamp, signature, {
      onGotQRCode: (base64JpegImageBuffer: string) => {
        this.loadStatus = LoadingStatus.SCANNING
        const base64String: string = `data:image/jpeg;base64,${base64JpegImageBuffer}`
        this.emitQRCode(base64String); // 触发 QRCode 事件
      },
      onQRCodeScanned: () => {
        this.loadStatus = LoadingStatus.SCANNED
      },
      onAuthFinish: (authCode: string) => {
        this.loadStatus = LoadingStatus.SUCCESS
        callback(null, { authCode, errCode: null });
      },
      onAuthError: (errCode: wxopensdk.OAuthErrCode, errMsg: string) => {
        this.loadStatus = LoadingStatus.FAILED
        this.logger.error(`Error while startOAuth, errMsg is: ${errMsg}`);
        callback(null, { authCode: null, errCode: errCode })
      }
    });
  }

  async shareText(message: TM.WechatLibTurboModule.ShareTextMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null)
      return
    }

    // 初始化 WXTextObject 对象
    let textObject = new wxopensdk.WXTextObject
    textObject.text = message.text
    // 用 WXTextObject 对象初始化 WXMediaMessage 对象
    let mediaMessage = new wxopensdk.WXMediaMessage()
    mediaMessage.mediaObject = textObject

    // 创建 SendMessageToWX.Req 对象
    let req = new wxopensdk.SendMessageToWXReq()
    req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession
    req.message = mediaMessage

    try {
      // 调用 api.sendReq 方法并返回结果
      WechatLibTurboModule.wxApi.sendReq(this.context, req);
      callback(null, true);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while openWXAppopenWXApp ${message}`);
    }
  }

  downloadImageWithUrl(url: string,
    completion: (imageData: ArrayBuffer) => void) {
    http.createHttp().request(url,
      (error: BusinessError, data: http.HttpResponse) => {
        if (error || data.responseCode != 200) {
          return
        }
        completion((data.result as ArrayBuffer))
      })
  }

  async shareImage(message: TM.WechatLibTurboModule.ShareImageMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    this.downloadImageWithUrl(message.imageUrl, async (imageData: ArrayBuffer) => {
      if (!imageData) {
        callback("Failed to retrieve imageData", null);
        return;
      }

      try {
        let file: fileIo.File | undefined;
        let filePath = getContext(this).filesDir + `/original-${Date.now()}.jpg`;
        file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        fileIo.writeSync(file.fd, imageData);
        fileIo.closeSync(file);

        // 初始化 WXImageObject
        let imageObject = new wxopensdk.WXImageObject();
        imageObject.uri = fileUri.getUriFromPath(filePath);

        // 初始化 WXMediaMessage 对象
        let mediaMessage = new wxopensdk.WXMediaMessage();
        mediaMessage.mediaObject = imageObject;

        let req = new wxopensdk.SendMessageToWXReq();
        req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
        req.message = mediaMessage;

        if (!WechatLibTurboModule.wxApi) {
          callback(this.NOT_REGISTERED, null);
          return;
        }

        WechatLibTurboModule.wxApi.sendReq(this.context, req);
        callback(null, true);
      } catch (err) {
        const message = err instanceof Error ? err.message : 'downloadImageWithUrl Unknown error';
        callback(message, null);
      }
    });

  }

  async shareLocalImage(message: TM.WechatLibTurboModule.ShareImageMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      let imageObject = new wxopensdk.WXImageObject();
      // 需要用fileUri.getUriFromPath处理成带有包名的路径才能分享出去
      imageObject.uri = fileUri.getUriFromPath(message.imageUrl.replace("file://", ""))

      let mediaMessage = new wxopensdk.WXMediaMessage()
      mediaMessage.mediaObject = imageObject
      let req = new wxopensdk.SendMessageToWXReq()
      req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage

      WechatLibTurboModule.wxApi.sendReq(this.context, req);
      callback(null, true);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareLocalImage Unknown error';
      callback(message, null);
    }
  }

  shareFile(message: TM.WechatLibTurboModule.ShareFileMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  shareMusic(message: TM.WechatLibTurboModule.ShareMusicMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  shareVideo(message: TM.WechatLibTurboModule.ShareVideoMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  shareWebpage(message: TM.WechatLibTurboModule.ShareWebpageMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  shareMiniProgram(message: TM.WechatLibTurboModule.ShareMiniProgramMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  launchMiniProgram(message: TM.WechatLibTurboModule.LaunchMiniProgramMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  chooseInvoice(data: TM.WechatLibTurboModule.ChooseInvoice, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback);
  }

  async pay(payload: TM.WechatLibTurboModule.PaymentLoad, callback: (result: Object | null) => void) {
    if (!WechatLibTurboModule.wxApi) {
      throw new Error(this.NOT_REGISTERED);
    }
    let payReq = new wxopensdk.PayReq
    if (payload.partnerId) {
      payReq.partnerId = payload.partnerId;
    }
    if (this.appId) {
      payReq.appId = this.appId;
    }
    if (payload.prepayId) {
      payReq.prepayId = payload.prepayId;
    }
    if (payload.nonceStr) {
      payReq.nonceStr = payload.nonceStr;
    }
    if (payload.timeStamp) {
      payReq.timeStamp = payload.timeStamp;
    }
    if (payload.sign) {
      payReq.sign = payload.sign;
    }
    if (payload.package) {
      payReq.packageValue = payload.package;
    }
    if (payload.extData) {
      payReq.extData = payload.extData;
    }

    try {
      WechatLibTurboModule.wxApi.sendReq(this.context, payReq);
      callback(null);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareLocalImage Unknown error';
      callback(message);
    }
  }

  subscribeMessage(message: TM.WechatLibTurboModule.SubscribeMessageMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }
}

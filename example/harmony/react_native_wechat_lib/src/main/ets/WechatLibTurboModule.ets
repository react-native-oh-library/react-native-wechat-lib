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


export class WechatLibTurboModule extends TurboModule implements TM.WechatLibTurboModule.Spec {
  private appId: string | null = null;
  private static wxApi: wxopensdk.WXApi | null = null;
  private context = getContext(this) as common.UIAbilityContext;
  lastOAuth: wxopensdk.IDiffDevOAuth | null = null
  loadStatus: LoadingStatus = LoadingStatus.INIT
  private NOT_REGISTERED = "registerApp required.";
  private INVOKE_FAILED = "WeChat API invoke returns false.";
  private API_NOT_SUPPORTED = "Api not supported.";
  private logger = this.ctx.logger.clone('WechatLibTurboModuleLogger');
  listener = new EventEmitter();

  getNativeEventEmitter() {
    return this.listener;
  }

  public static handleWant(want: Want) {
    WechatLibTurboModule.wxApi?.handleWant(want, WXEventHandler)
  }

  /**
   * 暂不支持的接口统一reject
   * @returns
   */
  notSupportPromise(): Promise<never> {
    return new Promise((_, reject) => {
      if (!WechatLibTurboModule.wxApi) {
        reject(new Error(this.NOT_REGISTERED));
      } else {
        reject(new Error(this.API_NOT_SUPPORTED));
      }
    });
  }

  /**
   * 注册应用，初始化WechatLibTurboModule.wxApi
   * @param appId
   * @param universalLink
   * @returns
   */
  async registerApp(appId: string, universalLink: string): Promise<boolean> {
    try {
      this.appId = appId;
      WechatLibTurboModule.wxApi = wxopensdk.WXAPIFactory.createWXAPI(appId);
      return true;
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while registering app with appId ${appId}: ${message}`);
      return false;
    }
  }

  isWXAppInstalled(): Promise<boolean> {
    return this.notSupportPromise()
  }

  isWXAppSupportApi(): Promise<boolean> {
    return this.notSupportPromise()
  }

  getApiVersion(): Promise<string> {
    return this.notSupportPromise()
  }

  /**
   * 打开微信
   * @returns
   */
  async openWXApp(): Promise<boolean> {
    if (!WechatLibTurboModule.wxApi) {
      return Promise.reject(new Error(this.NOT_REGISTERED));
    }

    const result = await WechatLibTurboModule.wxApi.openWechat(this.context);
    return Promise.resolve(result);
  }

  async sendAuthRequest(scope: string, state: string): Promise<boolean> {
    if (!WechatLibTurboModule.wxApi) {
      throw new Error(this.NOT_REGISTERED);
    }

    let req = new wxopensdk.SendAuthReq
    req.isOption1 = false
    req.nonAutomatic = true
    req.scope = scope
    req.state = state
    req.transaction = ''
    const isRequestSent = WechatLibTurboModule.wxApi.sendReq(this.context, req);
    return Promise.resolve(isRequestSent);
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
  ): Promise<TM.WechatLibTurboModule.IScanRes> {

    if (!WechatLibTurboModule.wxApi) {
      throw new Error(this.NOT_REGISTERED);
    }

    if (this.lastOAuth) {
      this.lastOAuth.stopOAuth()
    }
    let oauth = wxopensdk.DiffDevOAuthFactory.getDiffDevOAuth()!

    return new Promise((resolve, reject) => {
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
          resolve({ authCode, errCode: null });
        },
        onAuthError: (errCode: wxopensdk.OAuthErrCode, errMsg: string) => {
          this.loadStatus = LoadingStatus.FAILED
          this.logger.error(`Error while startOAuth, errMsg is: ${errMsg}`);
          reject({ authCode: null, errCode: errCode })
        }
      });
    });
  }

  async shareText(message: TM.WechatLibTurboModule.ShareTextMetadata): Promise<boolean> {
    if (!WechatLibTurboModule.wxApi) {
      throw new Error("NOT_REGISTERED");
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

    // 调用 api.sendReq 方法并返回结果
    const isRequestSent = await WechatLibTurboModule.wxApi.sendReq(this.context, req);
    return Promise.resolve(isRequestSent);
  }

  // shareImage(message: TM.WechatLibTurboModule.ShareImageMetadata): Promise<boolean> {
  //   // const res: boolean = { errCode: 0, errStr: undefined }
  //   return Promise.resolve(res);
  // }

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

  async shareImage(message: TM.WechatLibTurboModule.ShareImageMetadata): Promise<boolean> {
    if (!WechatLibTurboModule.wxApi) {
      throw new Error(this.NOT_REGISTERED);
    }

    return new Promise((resolve, reject) => {
      this.downloadImageWithUrl(message.imageUrl, async (imageData: ArrayBuffer) => {
        if (!imageData) {
          reject(new Error("Failed to retrieve imageData"));
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
            reject(new Error(this.NOT_REGISTERED));
            return;
          }

          const isRequestSent = await WechatLibTurboModule.wxApi.sendReq(this.context, req);
          resolve(isRequestSent);
        } catch (error) {
          reject(error);
        }
      });
    });
  }

  async shareLocalImage(message: TM.WechatLibTurboModule.ShareImageMetadata): Promise<boolean> {
    return Promise.resolve(false);
  }

  shareFile(message: TM.WechatLibTurboModule.ShareFileMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  shareMusic(message: TM.WechatLibTurboModule.ShareMusicMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  shareVideo(message: TM.WechatLibTurboModule.ShareVideoMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  shareWebpage(message: TM.WechatLibTurboModule.ShareWebpageMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  shareMiniProgram(message: TM.WechatLibTurboModule.ShareMiniProgramMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  launchMiniProgram(message: TM.WechatLibTurboModule.LaunchMiniProgramMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }

  chooseInvoice(data: TM.WechatLibTurboModule.ChooseInvoice): Promise<TM.WechatLibTurboModule.IChooseInvoiceRes> {
    return this.notSupportPromise()
  }

  async pay(payload: TM.WechatLibTurboModule.PaymentLoad, callback: (result: Object | null) => void): Promise<boolean> {
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

    const result = WechatLibTurboModule.wxApi?.sendReq(this.context, payReq);
    callback(result ? null : this.INVOKE_FAILED);
    return Promise.resolve(result)
  }

  subscribeMessage(message: TM.WechatLibTurboModule.SubscribeMessageMetadata): Promise<boolean> {
    return this.notSupportPromise()
  }
}

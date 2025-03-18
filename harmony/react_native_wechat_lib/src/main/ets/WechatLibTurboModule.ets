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
import { bundleManager } from '@kit.AbilityKit';
import OpenLinkOptions from '@ohos.app.ability.OpenLinkOptions';
import image from '@ohos.multimedia.image';

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
  private INVOKE_FAILED = "WeChat API invoke returns false.";
  private INVALID_ARGUMENT = "invalid argument.";
  private THUMB_SIZE = 64;
  private logger = this.ctx.logger.clone('WechatLibTurboModuleLogger');
  listener = new EventEmitter();
  unsubscribeAuthGotQrcode = () => {
  };

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
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }
    try {
      let link = 'weixin://test.example.com';
      let canOpen = bundleManager.canOpenLink(link);
      this.logger.info(JSON.stringify(canOpen));
      callback(null, canOpen);
    } catch (err) {
      let message = (err as BusinessError).message;
      callback(message, null);
    }
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
      const res = await WechatLibTurboModule.wxApi.openWechat(this.context) as boolean;
      this.logger.info('res:' + res)
      callback(null, res);
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
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      this.logger.info('sendAuthRequest res:' + res)
      callback(null, res);
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
    return callback(this.API_NOT_SUPPORTED, null);
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
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      callback(null, res);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      this.logger.error(`Error while openWXAppopenWXApp ${message}`);
    }
  }

  downloadImageWithUrl(url: string,
    completion: (imageData: ArrayBuffer) => void, callback?: CallbackBoolean) {
    http.createHttp().request(url,
      (error: BusinessError, data: http.HttpResponse) => {
        if (error || data.responseCode != 200) {
          if(callback){
            callback("Download image failed, error code: " + data.responseCode, null)
          }
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

        const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
        callback(null, res);
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

      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      callback(null, res);
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

  async shareMiniProgram(message: TM.WechatLibTurboModule.ShareMiniProgramMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      const miniProgramObject = new wxopensdk.WXMiniProgramObject();
      miniProgramObject.webpageUrl = message.webpageUrl ?? "";
      // 小程序类型，默认正式版
      miniProgramObject.miniprogramType = message.miniProgramType ?? wxopensdk.WXMiniProgramType.RELEASE;
      // 小程序原始id
      miniProgramObject.userName = message.userName ?? undefined;
      // 小程序页面路径
      miniProgramObject.path = message.path ?? undefined;
      // 是否使用带shareTicket的分享
      miniProgramObject.withShareTicket = message.withShareTicket ?? undefined;

      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = miniProgramObject;
      mediaMessage.title = message.title ?? " ";
      mediaMessage.description = message.description ?? " ";

      let thumbImageUrl =
        message.hdImageUrl ? message.hdImageUrl : (message.thumbImageUrl ? message.thumbImageUrl : null);

      if (thumbImageUrl != null && !(thumbImageUrl === "")) {
        this.downloadImageWithUrl(thumbImageUrl, async (imageData: ArrayBuffer) => {
          if (!imageData) {
            callback("ShareMiniProgram Failed to retrieve imageData", null);
            return;
          }
          let thumbPixel = image.createImageSource(imageData).createPixelMapSync();
          // 图片压缩
          let thumbBuffer = await this.bitmapResizeGetBytes(thumbPixel, this.THUMB_SIZE);
          mediaMessage.thumbData = new Uint8Array(thumbBuffer);

          await this.shareMiniProgramSendReq(mediaMessage, message, callback);
        }, callback);
      } else {
        await this.shareMiniProgramSendReq(mediaMessage, message, callback);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareMiniProgram Unknown error';
      callback(message, null);
    }
  }

  async shareMiniProgramSendReq(mediaMessage: wxopensdk.WXMediaMessage,
    message: TM.WechatLibTurboModule.ShareMiniProgramMetadata, callback: CallbackBoolean) {
    const req = new wxopensdk.SendMessageToWXReq();
    req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
    req.message = mediaMessage;

    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    // 调用 api.sendReq 方法并返回结果
    const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
    callback(null, res);
  }

  async bitmapResizeGetBytes(sourcePixMap: image.PixelMap, maxCompressedImageSize: number): Promise<ArrayBuffer> {
    let thumbBuffer = await image.createImagePacker().packToData(sourcePixMap, { format: "image/jpeg", quality: 100 });
    let options = 100;
    while (thumbBuffer.byteLength / 1024 > maxCompressedImageSize) {
      if (options > 10) {
        options -= 8;
      } else {
        // 计算压缩比
        let imageInfo = await sourcePixMap.getImageInfo();
        let scale: number = 280 / imageInfo.size.width;
        await sourcePixMap.scale(scale, scale);
        return this.bitmapResizeGetBytes(sourcePixMap, maxCompressedImageSize);
      }
      let packOpts: image.PackingOption = { format: "image/jpeg", quality: options };
      let imagePacker = image.createImagePacker();
      thumbBuffer = await imagePacker.packToData(sourcePixMap, packOpts);
    }
    return thumbBuffer
  }

  async launchMiniProgram(message: TM.WechatLibTurboModule.LaunchMiniProgramMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }
    let miniReq = new wxopensdk.LaunchMiniProgramReq
    // 小程序原始id
    miniReq.userName = message.userName
    //拉起小程序页面的可带参路径，不填默认拉起小程序首页
    miniReq.path = message.path
    // 可选打开 开发版，体验版和正式版
    miniReq.miniprogramType = message.miniProgramType

    try {
      this.logger.info('launchMiniProgram miniReq:' + JSON.stringify(miniReq))
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, miniReq) as boolean;
      this.logger.info('launchMiniProgram res:' + res)
      if (!res) {
        return callback(this.INVALID_ARGUMENT, null);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      callback(message, null);
      this.logger.error(`Error while sendAuthRequest ${message}`);
    }
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
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, payReq) as boolean;
      callback(res ? null : this.INVOKE_FAILED);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareLocalImage Unknown error';
      callback(message);
    }
  }

  subscribeMessage(message: TM.WechatLibTurboModule.SubscribeMessageMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }
}
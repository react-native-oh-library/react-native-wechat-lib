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
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { wxopensdk, WXEventHandler } from '../../../ts';
import { http } from '@kit.NetworkKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { Want } from '@kit.AbilityKit';
import OpenLinkOptions from '@ohos.app.ability.OpenLinkOptions';
import image from '@ohos.multimedia.image';
import { util } from '@kit.ArkTS'

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

type CallbackMediaObject = (result: wxopensdk.WXImageObject | null) => void

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
      let res = WechatLibTurboModule.wxApi.isWXAppInstalled();
      this.logger.info("isWXAppInstalled: " + JSON.stringify(res));
      callback(null, res);
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
    let fileData: Array<ArrayBuffer> = new Array();

    let httpRequest = http.createHttp();
    httpRequest.on("dataReceive", (data)=>{
      fileData.push(data);
    })
    httpRequest.requestInStream(url,
      (error: BusinessError, data: number) => {
        if (error || data != 200) {
          if(callback){
            callback("Download image failed, error code: " + data, null);
            httpRequest.off('dataReceive');
            httpRequest.destroy();
          }
          return
        }
        let result = this.combineArrayBuffers(fileData);
        completion((result as ArrayBuffer));
        httpRequest.off('dataReceive');
        httpRequest.destroy();
      })
  }

  combineArrayBuffers(arrayBuffers: ArrayBuffer[]): ArrayBuffer {
    // 计算多个ArrayBuffer的总字节大小
    let totalByteLength = 0;
    for (const arrayBuffer of arrayBuffers) {
      totalByteLength += arrayBuffer.byteLength;
    }
    // 创建一个新的ArrayBuffer
    const combinedArrayBuffer = new ArrayBuffer(totalByteLength);
    // 创建一个Uint8Array来操作新的ArrayBuffer
    const combinedUint8Array = new Uint8Array(combinedArrayBuffer);
    // 依次复制每个ArrayBuffer的内容到新的ArrayBuffer中
    let offset = 0;
    for (const arrayBuffer of arrayBuffers) {
      const sourceUint8Array = new Uint8Array(arrayBuffer);
      combinedUint8Array.set(sourceUint8Array, offset);
      offset += sourceUint8Array.length;
    }
    return combinedArrayBuffer;
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
    }, callback);

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

  /**
   * 通过url获取文件名称
   *  @param url
   */
   getFileNameFromUrl(url: string): string {
    try {
      // 获取路径部分并解码（处理可能的 URL 编码）
      let pathname = decodeURIComponent(url);

      // 提取最后一部分作为文件名
      const parts = pathname.split('/');
      const fileName = parts.pop() || '';

      let result = fileName.split('?')[0].split('#')[0] || '';
      return result
    } catch (error) {
      this.logger.error(`getFileNameFromUrl exception, error URL:'${ url }, error message: ${ JSON.stringify(error) }`);
      // 非 URL 字符串处理（例如相对路径）
      const parts = url.split('/');
      return parts.pop() || '';
    }
  }

  /**
   * 下载远程文件并写入本地wechatLibShare目录下
   * @param url
   * @param callback
   * @returns
   */
  async loadRawDataFromURL(url: string, callback: CallbackBoolean){
    let rawData: ArrayBuffer | null = null;
    await new Promise<void>((resolve) => {
      this.downloadImageWithUrl(url, async (data: ArrayBuffer) => {
        if (!data) {
          callback("loadRawDataFromURL Failed to retrieve data", null);
          return;
        }
        rawData = data;
        resolve();
      }, callback);
    });

    if(!rawData) {
      callback("loadRawDataFromURL retrieve data is empty", null);
      return null
    }

    try {
      let file: fileIo.File | undefined;
      let fileName = this.getFileNameFromUrl(url);
      let filePath = getContext(this).filesDir + `/wechatLibShare`;
      // 创建wechatLibShare目录
      if(!fileIo.accessSync(filePath)){
        fileIo.mkdirSync(filePath);
      }
      filePath += `/${ fileName }`;
      file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, rawData);
      fileIo.closeSync(file);
      return filePath
    } catch (e) {
      callback("loadRawDataFromURL Failed to write data, error message: " + JSON.stringify(e), null);
      return null
    }
  }

  /**
   * 分享文件
   * @param message
   * @param callback
   */
  async shareFile(message: TM.WechatLibTurboModule.ShareFileMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      //初始化一个 WXFileObject 对象，填写分享的文件 uri
      const fileObject = new wxopensdk.WXFileObject();

      let url = (message.url ? message.url : null);
      // 下载网络资源并写入本地
      if (url && url.startsWith("http")) {
        url = await this.loadRawDataFromURL(url, callback);
      }
      fileObject.fileUri = fileUri.getUriFromPath(url?.replace("file://", ""));

      // 用 WXFileObject 对象初始化一个 WXMediaMessage 对象
      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = fileObject;
      mediaMessage.title = message.title ?? " ";

      const req = new wxopensdk.SendMessageToWXReq();
      req.transaction = Date.now().toString();
      req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      // 调用 api.sendReq 方法并返回结果
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      callback(null, res);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareFile Unknown error';
      callback(message, null);
    }
  }

  shareMusic(message: TM.WechatLibTurboModule.ShareMusicMetadata, callback: CallbackBoolean): void {
    return this.notSupportPromise(callback)
  }

  /**
   * 分享视频
   * @param message
   * @param callback
   */
  async shareVideo(message: TM.WechatLibTurboModule.ShareVideoMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      // 初始化一个 WXVideoObject 对象，填写分享的视频链接
      const videoObject = new wxopensdk.WXVideoObject();
      videoObject.videoUrl = message.videoUrl ?? "";
      videoObject.videoLowBandUrl = message.videoLowBandUrl ?? "";

      // 用 WXVideoObject 对象初始化一个 WXMediaMessage 对象
      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = videoObject;
      mediaMessage.title = message.title ?? " ";
      mediaMessage.description = message.description ?? " ";

      let thumbImageUrl = (message.thumbImageUrl ? message.thumbImageUrl : null);
      if (thumbImageUrl != null && !(thumbImageUrl === "")) {
        await new Promise<void>((resolve) => {
          this.downloadImageWithUrl(thumbImageUrl!, async (imageData: ArrayBuffer) => {
            if (!imageData) {
              callback("shareVideo Failed to retrieve imageData", null);
              return;
            }
            let thumbPixel = image.createImageSource(imageData).createPixelMapSync();
            // 图片压缩
            let thumbBuffer = await this.bitmapResizeGetBytes(thumbPixel, this.THUMB_SIZE);
            mediaMessage.thumbData = new Uint8Array(thumbBuffer);
            resolve();
          }, callback);
        })
      }
      // 构造一个Req
      const req = new wxopensdk.SendMessageToWXReq();
      req.transaction = "video";
      req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      // 调用 api.sendReq 方法并返回结果
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      callback(null, res);

    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareVideo Unknown error';
      callback(message, null);
    }
  }

  /**
   * 分享网页
   * @param message
   * @param callback
   */
  async shareWebpage(message: TM.WechatLibTurboModule.ShareWebpageMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    try {
      // 初始化一个 WXWebpageObject 对象，填写分享的网页链接
      const webpageObject = new wxopensdk.WXWebpageObject();
      webpageObject.webpageUrl = message.webpageUrl ?? "";
      webpageObject.isSecretMessage = message.isSecretMessage ?? false;

      // 用 WXWebpageObject 对象初始化一个 WXMediaMessage 对象
      const mediaMessage = new wxopensdk.WXMediaMessage();
      mediaMessage.mediaObject = webpageObject;
      mediaMessage.title = message.title ?? " ";
      mediaMessage.description = message.description ?? " ";

      let thumbImageUrl = (message.thumbImageUrl ? message.thumbImageUrl : null);
      if (thumbImageUrl != null && !(thumbImageUrl === "")) {
        await new Promise<void>((resolve) => {
          this.downloadImageWithUrl(thumbImageUrl!, async (imageData: ArrayBuffer) => {
            if (!imageData) {
              callback("shareWebpage Failed to retrieve imageData", null);
              return;
            }
            let thumbPixel = image.createImageSource(imageData).createPixelMapSync();
            // 图片压缩
            let thumbBuffer = await this.bitmapResizeGetBytes(thumbPixel, this.THUMB_SIZE);
            mediaMessage.thumbData = new Uint8Array(thumbBuffer);
            resolve();
          }, callback);
        })
      }
      // 构造一个Req
      const req = new wxopensdk.SendMessageToWXReq();
      req.transaction = "webpage";
      req.scene = message.scene ?? wxopensdk.SendMessageToWXReq.WXSceneSession;
      req.message = mediaMessage;

      // 调用 api.sendReq 方法并返回结果
      const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
      callback(null, res);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareWebpage Unknown error';
      callback(message, null);
    }
  }

  /**
   * 分享小程序
   * @param message
   * @param callback
   */
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
    let thumbBuffer: ArrayBuffer;
    let imagePacker: ESObject = image.createImagePacker();
    if (deviceInfo.sdkApiVersion >= 13 || imagePacker.packToData) {
      thumbBuffer = await imagePacker.packToData(sourcePixMap, { format: "image/jpeg", quality: 100 });
    } else {
      thumbBuffer = await imagePacker.packing(sourcePixMap, { format: "image/jpeg", quality: 100 });
    }

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
      let imagePacker: ESObject = image.createImagePacker();
      if (deviceInfo.sdkApiVersion >= 13 || imagePacker.packToData) {
        thumbBuffer = await imagePacker.packToData(sourcePixMap, packOpts);
      }else{
        thumbBuffer = await imagePacker.packing(sourcePixMap, packOpts);
      }
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

  /**
   * share to timeline
   * @param message
   * @param callback
   */
  async shareToTimeline(message: TM.WechatLibTurboModule.ShareMetadata, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }
    await this._share(wxopensdk.SendMessageToWXReq.WXSceneTimeline, message, callback);
  }

  /**
   * 统一对thumbImage进行处理
   * @param scene
   * @param message
   * @param callback
   */
  async _share(scene: number, message: TM.WechatLibTurboModule.ShareMetadata, callback: CallbackBoolean) {
    try {
      let uri: string | null = message.thumbImage ? message.thumbImage : null;

      if (uri === null || uri === "") {
        // thumbImage为空
        this._share_handleType(scene, message, null, callback);
      } else if (uri.startsWith('http')) {
        // thumbImage为远程图片
        this.downloadImageWithUrl(uri, async (imageData: ArrayBuffer) => {
          // 图片压缩
          let thumbPixel = image.createImageSource(imageData).createPixelMapSync();
          let thumbBuffer = await this.bitmapResizeGetBytes(thumbPixel, this.THUMB_SIZE);
          this._share_handleType(scene, message, thumbBuffer, callback);
        }, callback)
      } else {
        // thumbImage为本地resource目录下的图片
        let imageData = getContext(this).resourceManager.getRawFileContentSync(uri);
        // 图片压缩
        let thumbPixel = image.createImageSource(imageData).createPixelMapSync();
        let thumbBuffer = await this.bitmapResizeGetBytes(thumbPixel, this.THUMB_SIZE);
        this._share_handleType(scene, message, thumbBuffer, callback);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'shareToTimeline Unknown error';
      callback(message, null);
    }
  }

  /**
   * 为不同分享类型创建多媒体消息中包含的数据对象， 支持： news、text、imageUrl、imageResource、imageFile、video、audio、file
   * @param scene
   * @param message
   * @param thumbImage
   * @param callback
   */
  async _share_handleType(scene: number, message: TM.WechatLibTurboModule.ShareMetadata,
    thumbImage: ArrayBuffer | ArrayBufferLike | null, callback: CallbackBoolean) {
    if (!message.type) {
      callback(this.INVALID_ARGUMENT, null);
      return
    }

    let type: string = message.type;
    let mediaObject: wxopensdk.IMediaObject | null = null;
    switch (type) {
      case 'news':
        // mediaObject = this._jsonToWebpageMedia(message as TM.WechatLibTurboModule.ShareMetadata);
        this.notSupportPromise(callback);
        return;
      case "text":
        mediaObject = this._jsonToTextMedia(message);
        break;
      case "imageUrl":
      case "imageResource":
        await this.__jsonToImageUrlMedia(message, (mediaObject: wxopensdk.IMediaObject | null) => {
          if (mediaObject == null) {
            callback(this.INVALID_ARGUMENT, null);
          } else {
            this._share_handleProperty(scene, message, thumbImage, mediaObject, callback);
          }
        });
        return;
      case "imageFile":
        await this.__jsonToImageFileMedia(message, (mediaObject: wxopensdk.IMediaObject | null) => {
          if (mediaObject == null) {
            callback(this.INVALID_ARGUMENT, null);
          } else {
            this._share_handleProperty(scene, message, thumbImage, mediaObject, callback);
          }
        });
        return;
      case "video":
        // mediaObject = this.__jsonToVideoMedia(message);
        this.notSupportPromise(callback);
        return;
      case "audio":
        // mediaObject = this.__jsonToMusicMedia(message);
        this.notSupportPromise(callback);
        return;
      case "file":
        // mediaObject = this.__jsonToFileMedia(message);
        this.notSupportPromise(callback);
        return;
    }


    if (mediaObject === null) {
      callback(this.INVALID_ARGUMENT, null);
    } else {
      this._share_handleProperty(scene, message, thumbImage, mediaObject, callback);
    }

  }

  /**
   * 处理多媒体消息携带信息，并发送调用 api.sendReq 分享至目标场景
   * @param scene
   * @param message
   * @param thumbImage
   * @param mediaObject
   * @param callback
   */
  async _share_handleProperty(scene: number, message: TM.WechatLibTurboModule.ShareMetadata,
    thumbImage: ArrayBuffer | ArrayBufferLike | null, mediaObject: wxopensdk.IMediaObject, callback: CallbackBoolean) {
    if (!WechatLibTurboModule.wxApi) {
      callback(this.NOT_REGISTERED, null);
      return;
    }

    const mediaMessage = new wxopensdk.WXMediaMessage();
    mediaMessage.mediaObject = mediaObject;

    if (thumbImage != null) {
      mediaMessage.thumbData = new Uint8Array(thumbImage);
    }
    if (message.title) {
      mediaMessage.title = message.title
    }
    if (message.description) {
      mediaMessage.description = message.description
    }
    if (message.mediaTagName) {
      mediaMessage.mediaTagName = message.mediaTagName
    }
    if (message.messageAction) {
      mediaMessage.messageAction = message.messageAction
    }
    if (message.messageExt) {
      mediaMessage.messageExt = message.messageExt
    }

    // 构造一个Req
    const req = new wxopensdk.SendMessageToWXReq();
    req.transaction = util.generateRandomUUID().toString();
    req.scene = scene;
    req.message = mediaMessage;

    // 调用 api.sendReq 方法并返回结果
    const res = await WechatLibTurboModule.wxApi.sendReq(this.context, req) as boolean;
    callback(null, res);
  }

  /**
   * 将rawfile目录下的相对路径转换成uri
   * @param context
   * @param url
   * @returns
   */
  transRawFileToUri(context: Context, url: string): string | null {
    try {
      let content = context.resourceManager.getRawFileContentSync(url);
      if (!content) {
        this.logger.info('get rawfile content failed, url is: ' + url);
        return null;
      }
      let fileName = this.getFileNameFromUrl(url);
      let filePath = getContext(this).filesDir + `/wechatLibShare`;
      // 创建wechatLibShare目录
      if (!fileIo.accessSync(filePath)) {
        fileIo.mkdirSync(filePath);
      }
      filePath += `/${fileName}`;
      this.writeFile(filePath, content.buffer);
      return filePath;
    } catch (err) {
      this.logger.error('trans rawfile to uri failed, error message: ' + JSON.stringify(err))
      return null
    }
  }

  /**
   * 将ArrayBuffer写入本地文件
   * @param filePath
   * @param rawData
   * @returns
   */
  writeFile(filePath: string, rawData: ArrayBuffer | ArrayBufferLike) {
    try {
      let file: fileIo.File | undefined =
        fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(file.fd, rawData);
      fileIo.closeSync(file);
      return true
    } catch (err) {
      this.logger.error('write file failed, error message: ' + JSON.stringify(err))
      return false
    }
  }

  // 构建 WXTextObject 对象
  _jsonToTextMedia(message: TM.WechatLibTurboModule.ShareMetadata) {
    if (!message.description) {
      return null;
    }

    let ret = new wxopensdk.WXTextObject();
    ret.text = message.description;
    return ret;
  }

  /**
   * 构建 WXWebpageObject 对象
   */
  _jsonToWebpageMedia(message: TM.WechatLibTurboModule.ShareMetadata) {
    if (!message.webpageUrl) {
      return null;
    }

    let ret = new wxopensdk.WXWebpageObject();
    ret.webpageUrl = message.webpageUrl;
    if (message.extInfo) {
      ret.extInfo = message.extInfo;
    }
    return ret;
  }

  /**
   * 构建 WXImageObject 对象
   * @param imageUrl
   * @param callback
   */
  async __jsonToImageMedia(imageUrl: string, callback: CallbackMediaObject) {
    let imageUri: string | null = imageUrl;
    try {
      // get resource uri.
      if (!(imageUri.startsWith("http") || imageUrl.startsWith("file"))) {
        imageUri = this.transRawFileToUri(getContext(this), imageUrl);
      }
    } catch (e) {
      imageUri = null;
    }

    if (imageUri === null) {
      callback(null);
      return;
    }

    if (!(imageUri.startsWith("http"))) {
      // 本地文件
      let imageObject = new wxopensdk.WXImageObject();
      imageObject.uri = fileUri.getUriFromPath(imageUri.replace("file://", ""));
      callback(imageObject);
    } else {
      // 远程文件
      let callBean = (error: string | null, result: null | boolean) => {
        callback(null);
        return
      }
      this.downloadImageWithUrl(imageUrl!, async (imageData: ArrayBuffer) => {
        if (!imageData) {
          callback(null);
          return
        }

        let filePath = getContext(this).filesDir + `/original-${Date.now()}.jpg`
        let result = this.writeFile(filePath, imageData);
        if (!result) {
          callback(null);
          return
        }
        let imageObject = new wxopensdk.WXImageObject();
        imageObject.uri = fileUri.getUriFromPath(filePath);

        callback(imageObject);
      }, callBean)
    }
  }

  /**
   * 处理本地图片路径
   * @param message
   * @param callback
   */
  async __jsonToImageUrlMedia(message: TM.WechatLibTurboModule.ShareMetadata, callback: CallbackMediaObject) {
    if (!message.imageUrl) {
      callback(null);
      return;
    }
    let imageUrl = message.imageUrl;
    await this.__jsonToImageMedia(imageUrl, callback);
  }

  /**
   * 处理网络图片路径
   * @param message
   * @param callback
   */
  __jsonToImageFileMedia(message: TM.WechatLibTurboModule.ShareMetadata, callback: CallbackMediaObject) {
    if (!message.imageUrl) {
      callback(null);
      return;
    }

    let imageUrl = message.imageUrl;
    if (!imageUrl.toLowerCase().startsWith("file://")) {
      imageUrl = "file://" + imageUrl;
    }
    this.__jsonToImageMedia(imageUrl, callback);
  }

  /**
   * 构建 WXMusicObject 对象
   * @param message
   */
  __jsonToMusicMedia(message: TM.WechatLibTurboModule.ShareMetadata) {
    // todo
  }

  /**
   * 构建 WXVideoObject 对象
   * @param message
   * @returns
   */
  __jsonToVideoMedia(message: TM.WechatLibTurboModule.ShareMetadata) {
    if (!message.videoUrl) {
      return null;
    }

    let ret = new wxopensdk.WXVideoObject();
    ret.videoUrl = message.videoUrl;
    return ret;
  }

  /**
   * 构建 WXFileObject 对象
   * @param message
   * @returns
   */
  __jsonToFileMedia(message: TM.WechatLibTurboModule.ShareMetadata) {
    if (!message.filePath) {
      return null;
    }
    let ret = new wxopensdk.WXFileObject();
    ret.fileUri = message.filePath
    return ret;
  }
}
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

import { TurboModule } from '@rnoh/react-native-openharmony/ts';
import { TM } from './generated/ts';
import { bundleManager, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

declare function getContext(context: any): common.UIAbilityContext;

let context = getContext(this) as common.UIAbilityContext;

export class WechatLibTurboModule extends TurboModule implements TM.WechatLibTurboModule.Spec {
  private lastSaveTime: number | null = null;
  private logger = this.ctx.logger.clone('WechatLibTurboModuleLogger');

  registerApp(appId: string, universalLink: string): Promise<boolean> {
    try {
      bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO).then((data) => {
        this.logger.info('data:' + JSON.stringify(data));
      }).catch((err: BusinessError) => {
        this.logger.error('message:' + err.message);
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      this.logger.error('error:' + message);
    }
    return Promise.resolve(true);
  }

  isWXAppInstalled(): Promise<boolean> {
    return Promise.resolve(true);
  }

  isWXAppSupportApi(): Promise<boolean> {
    return Promise.resolve(true);
  }

  getApiVersion(): Promise<string> {
    return Promise.resolve('0.0.1');
  }

  openWXApp(): Promise<boolean> {
    return Promise.resolve(true);
  }

  sendAuthRequest(scope: Object, state: string): Promise<TM.WechatLibTurboModule.AuthResponse> {
    const res = {
      errCode: 0,
      errStr: 'string',
      openId: 'string',
      code: 'string',
      url: 'string',
      lang: 'string',
      country: 'string'
    }
    return Promise.resolve(res);
  }

  authByScan(appId: string, appSecret: string,
    onQRGet: (qrcode: string) => void): Promise<TM.WechatLibTurboModule.ScanLoginResp> {
    const res = {
      nickname: 'string',
      headimgurl: 'string',
      openid: 'string',
      unionid: 'string',
      errCode: 0,
      errStr: 'string'
    }
    return Promise.resolve(res);
  }

  shareText(message: TM.WechatLibTurboModule.ShareTextMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareImage(message: TM.WechatLibTurboModule.ShareImageMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareLocalImage(message: TM.WechatLibTurboModule.ShareImageMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareFile(message: TM.WechatLibTurboModule.ShareFileMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareMusic(message: TM.WechatLibTurboModule.ShareMusicMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareVideo(message: TM.WechatLibTurboModule.ShareVideoMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareWebpage(message: TM.WechatLibTurboModule.ShareWebpageMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  shareMiniProgram(message: TM.WechatLibTurboModule.ShareMiniProgramMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  launchMiniProgram(message: TM.WechatLibTurboModule.LaunchMiniProgramMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  chooseInvoice(data: TM.WechatLibTurboModule.ChooseInvoice): Promise<{ errCode?: number | undefined; errStr?: string | undefined; cards: TM.WechatLibTurboModule.Invoice[] }> {
    const res = {
      errCode: 0,
      errStr: undefined,
      cards: [{ appId: 'string', cardId: 'string', encryptCode: 'string' }]
    }
    return Promise.resolve(res);
  }

  pay(payload: TM.WechatLibTurboModule.PaymentLoad): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }

  subscribeMessage(message: TM.WechatLibTurboModule.SubscribeMessageMetadata): Promise<{ errCode?: number | undefined; errStr?: string | undefined }> {
    const res = { errCode: 0, errStr: undefined }
    return Promise.resolve(res);
  }
}

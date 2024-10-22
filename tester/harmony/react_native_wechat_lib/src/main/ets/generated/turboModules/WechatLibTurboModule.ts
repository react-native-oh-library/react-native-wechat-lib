/**
 * This code was generated by "react-native codegen-lib-harmony"
 */

import { Tag } from "@rnoh/react-native-openharmony/ts"

export namespace WechatLibTurboModule {
  export const NAME = 'WechatLibTurboModule' as const

  export enum WXScene {
    WXSceneSession = 0,
    WXSceneTimeline = 1,
    WXSceneFavorite = 2,
    WXSceneSpecifiedSession = 3,
  }

  export type AuthResponse = {errCode?: number, errStr?: string, openId?: string, code?: string, url?: string, lang?: string, country?: string}
  
  export type ScanLoginResp = {nickname?: string, headimgurl?: string, openid?: string, unionid?: string, errCode?: number, errStr?: string}
  
  export type ShareTextMetadata = {text: string, scene?: WXScene}
  
  export type ShareImageMetadata = {imageUrl: string, scene?: WXScene}
  
  export type ShareFileMetadata = {url: string, title?: string, ext?: string, scene?: WXScene}
  
  export type ShareMusicMetadata = {musicUrl: string, musicLowBandUrl?: string, musicDataUrl?: string, musicLowBandDataUrl?: string, title?: string, description?: string, thumbImageUrl?: string, scene?: WXScene}
  
  export type ShareVideoMetadata = {videoUrl: string, videoLowBandUrl?: string, title?: string, description?: string, thumbImageUrl?: string, scene?: WXScene}
  
  export type ShareWebpageMetadata = {webpageUrl: string, title?: string, description?: string, thumbImageUrl?: string, scene?: WXScene}
  
  export type ShareMiniProgramMetadata = {webpageUrl: string, userName: string, path?: string, hdImageUrl?: string, withShareTicket?: string, miniProgramType?: number, title?: string, description?: string, thumbImageUrl?: string, scene?: WXScene}
  
  export type LaunchMiniProgramMetadata = {userName: string, miniProgramType?: number, path?: string}
  
  export type ChooseInvoice = {signType?: string, nonceStr?: string, timeStamp?: number, cardSign?: string}
  
  export type Invoice = {appId: string, cardId: string, encryptCode: string}
  
  export type PaymentLoad = {partnerId: string, prepayId: string, nonceStr: string, timeStamp: string, package: string, sign: string}
  
  export type SubscribeMessageMetadata = {scene?: WXScene, templateId: string, reserved?: string}
  
  export interface Spec {
    registerApp(appId: string, universalLink: string): Promise<boolean>;
  
    isWXAppInstalled(): Promise<boolean>;
  
    isWXAppSupportApi(): Promise<boolean>;
  
    getApiVersion(): Promise<string>;
  
    openWXApp(): Promise<boolean>;
  
    sendAuthRequest(scope: Object, state: string): Promise<AuthResponse>;
  
    authByScan(appId: string, appSecret: string, onQRGet: (qrcode: string) => void): Promise<ScanLoginResp>;
  
    shareText(message: ShareTextMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareImage(message: ShareImageMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareLocalImage(message: ShareImageMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareFile(message: ShareFileMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareMusic(message: ShareMusicMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareVideo(message: ShareVideoMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareWebpage(message: ShareWebpageMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    shareMiniProgram(message: ShareMiniProgramMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    launchMiniProgram(message: LaunchMiniProgramMetadata): Promise<{errCode?: number, errStr?: string}>;
  
    chooseInvoice(data: ChooseInvoice): Promise<{errCode?: number, errStr?: string, cards: Invoice[]}>;
  
    pay(payload: PaymentLoad): Promise<{errCode?: number, errStr?: string}>;
  
    subscribeMessage(message: SubscribeMessageMetadata): Promise<{errCode?: number, errStr?: string}>;

  }
}

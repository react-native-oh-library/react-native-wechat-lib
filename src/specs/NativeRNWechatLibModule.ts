import { TurboModuleRegistry, TurboModule } from "react-native";
import { Int32 } from "react-native/Libraries/Types/CodegenTypes";

enum WXScene {
  WXSceneSession = 0 /**< 聊天界面 */,
  WXSceneTimeline = 1 /**< 朋友圈 */,
  WXSceneFavorite = 2 /**< 收藏 */,
  WXSceneSpecifiedSession = 3 /**< 指定联系人 */,
}

export interface WeChatReq {
  type?: string;
  errStr?: string;
  extMsg?: string;
  country?: string;
  state?: string;
  returnKey?: string;
}
export interface WeChatResp {
  type?: string;
  errStr?: string;
  extMsg?: string;
  country?: string;
  state?: string;
  returnKey?: string;
}

export interface ShareMetadata {
  type: "news" | "text" | "imageUrl" | "imageFile" | "imageResource" | "video" | "audio" | "file";
  title?: string;
  thumbImage?: string;
  description?: string;
  webpageUrl?: string;
  imageUrl?: string;
  videoUrl?: string;
  musicUrl?: string;
  filePath?: string;
  fileExtension?: string;
  mediaTagName?: string;
  messageAction?: string;
  messageExt?: string;
  extInfo?: string;
}

export interface AuthResponse {
  errCode?: Int32;
  errStr?: string;
  openId?: string;
  code?: string;
  url?: string;
  lang?: string;
  country?: string;
}

export interface ScanLoginResp {
  nickname?: string;
  headimgurl?: string;
  openid?: string;
  unionid?: string;
  errCode?: Int32;
  errStr?: string;
}

export interface ShareTextMetadata {
  text: string;
  scene?: WXScene;
}

export interface ShareImageMetadata {
  imageUrl: string;
  scene?: WXScene;
}

export interface ShareFileMetadata {
  url: string;
  title?: string;
  ext?: string;
  scene?: WXScene;
}

export interface ShareMusicMetadata {
  musicUrl: string;
  musicLowBandUrl?: string;
  musicDataUrl?: string;
  musicLowBandDataUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface ShareVideoMetadata {
  videoUrl: string;
  videoLowBandUrl?: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface ShareWebpageMetadata {
  webpageUrl: string;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
  isSecretMessage?: boolean;
}

export interface ShareMiniProgramMetadata {
  webpageUrl?: string;
  userName: string;
  path?: string;
  hdImageUrl?: string;
  withShareTicket?: boolean;
  miniProgramType?: Int32;
  title?: string;
  description?: string;
  thumbImageUrl?: string;
  scene?: WXScene;
}

export interface LaunchMiniProgramMetadata {
  userName: string;
  miniProgramType?: Int32;
  path?: string;
}

export interface ChooseInvoice {
  signType?: string;
  nonceStr?: string;
  timeStamp?: Int32;
  cardSign?: string;
}

export interface Invoice {
  appId: string;
  cardId: string;
  encryptCode: string;
}

export interface PaymentLoad {
  partnerId: string;
  prepayId: string;
  nonceStr: string;
  timeStamp: string;
  package: string;
  sign: string;
  extData: string;
}

export interface SubscribeMessageMetadata {
  scene?: WXScene;
  templateId: string;
  reserved?: string;
}

export interface ICommonRes {
  errCode?: Int32;
  errStr?: string;
}

export interface IChooseInvoiceRes {
  errCode?: Int32;
  errStr?: string;
  cards: Invoice[];
}

// interface IScanRes {
//   authCode: string | null;
//   errCode: string | null;
// }

type Callback1 = (result: Object | null) => void;
type CallbackBoolean = (error: string | null, result: boolean | null) => void;

export interface Spec extends TurboModule {
  registerApp: (appId: string, universalLink: string, callback: CallbackBoolean) => void;
  isWXAppInstalled: (callback: CallbackBoolean) => void;
  isWXAppSupportApi: (callback: CallbackBoolean) => void;
  getApiVersion: (callback: CallbackBoolean) => void;
  openWXApp: (callback: CallbackBoolean) => void;
  sendAuthRequest: (scope: string, state: string, callback: CallbackBoolean) => void;
  shareText: (message: ShareTextMetadata, callback: CallbackBoolean) => void;
  shareImage: (message: ShareImageMetadata, callback: CallbackBoolean) => void;
  shareLocalImage: (message: ShareImageMetadata, callback: CallbackBoolean) => void;
  shareFile: (message: ShareFileMetadata, callback: CallbackBoolean) => void;
  shareMusic: (message: ShareMusicMetadata, callback: CallbackBoolean) => void;
  shareVideo: (message: ShareVideoMetadata, callback: CallbackBoolean) => void;
  shareWebpage: (message: ShareWebpageMetadata, callback: CallbackBoolean) => void;
  shareMiniProgram: (message: ShareMiniProgramMetadata, callback: CallbackBoolean) => void;
  shareToTimeline: (message: ShareMetadata, callback: CallbackBoolean) => void;
  launchMiniProgram: (message: LaunchMiniProgramMetadata, callback: CallbackBoolean) => void;
  chooseInvoice: (data: ChooseInvoice, callback: CallbackBoolean) => void;
  pay: (payload: PaymentLoad, callback: Callback1) => void;
  subscribeMessage: (message: SubscribeMessageMetadata, callback: CallbackBoolean) => void;
  subscribeAuthGotQrcode: (onQRGet: (qrcode: string) => void) => void;
  unSubscribeAuthGotQrcode: () => void;
  registerCallback: (name: string, callback: Callback1) => void;
  unregisterCallback: (name: string) => void;
}


export default TurboModuleRegistry.getEnforcing<Spec>("WechatLibTurboModule");

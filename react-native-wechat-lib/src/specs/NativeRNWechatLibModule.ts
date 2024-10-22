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
  thumbImage?: string;
  description?: string;
  webpageUrl?: string;
  imageUrl?: string;
  videoUrl?: string;
  musicUrl?: string;
  filePath?: string;
  fileExtension?: string;
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
}

export interface ShareMiniProgramMetadata {
  webpageUrl: string;
  userName: string;
  path?: string;
  hdImageUrl?: string;
  withShareTicket?: string;
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
}

export interface SubscribeMessageMetadata {
  scene?: WXScene;
  templateId: string;
  reserved?: string;
}




export interface Spec extends TurboModule {
  registerApp: (appId: string, universalLink?: string) => Promise<boolean>;
  isWXAppInstalled: () => Promise<boolean>;
  isWXAppSupportApi: () => Promise<boolean>;
  getApiVersion: () => Promise<string>;
  openWXApp: () => Promise<boolean>;
  sendAuthRequest: (scope: string | string[], state?: string) => Promise<AuthResponse>;
  authByScan: (appId: string, appSecret: string, onQRGet: (qrcode: string) => void) => Promise<ScanLoginResp>;
  shareText: (message: ShareTextMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareImage: (message: ShareImageMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareLocalImage: (message: ShareImageMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareFile: (message: ShareFileMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareMusic: (message: ShareMusicMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareVideo: (message: ShareVideoMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareWebpage: (message: ShareWebpageMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  shareMiniProgram: (message: ShareMiniProgramMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  launchMiniProgram: (message: LaunchMiniProgramMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
  chooseInvoice: (data: ChooseInvoice) => Promise<{ errCode?: Int32; errStr?: string; cards: Invoice[] }>;
  pay: (payload: PaymentLoad) => Promise<{ errCode?: Int32; errStr?: string }>;
  subscribeMessage: (message: SubscribeMessageMetadata) => Promise<{ errCode?: Int32; errStr?: string }>;
}


export default TurboModuleRegistry.getEnforcing<Spec>("WechatLibTurboModule");

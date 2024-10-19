import WechatLib from './specs/NativeRNWechatLibModule';


export const {
  registerApp,
  isWXAppInstalled,
  isWXAppSupportApi,
  getApiVersion,
  openWXApp,
  sendAuthRequest,
  authByScan,
  shareText,
  shareImage,
  shareLocalImage,
  shareFile,
  shareMusic,
  shareVideo,
  shareWebpage,
  shareMiniProgram,
  launchMiniProgram,
  chooseInvoice,
  pay,
  subscribeMessage,
  openCustomerServiceChat,
} = WechatLib;

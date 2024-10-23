import { EventEmitter } from "events";
import { DeviceEventEmitter } from "react-native";
import { sha1 } from "js-sha1";
import WechatLib, {
  LaunchMiniProgramMetadata,
  PaymentLoad,
  ShareFileMetadata,
  ShareImageMetadata,
  ShareMiniProgramMetadata,
  ShareMusicMetadata,
  ShareTextMetadata,
  ShareVideoMetadata,
  ShareWebpageMetadata,
  SubscribeMessageMetadata,
} from "./specs/NativeRNWechatLibModule";

let isAppRegistered = false;

// Event emitter to dispatch request and response from WechatLib.
const emitter = new EventEmitter();

DeviceEventEmitter.addListener("WeChat_Resp", (resp) => {
  emitter.emit(resp.type, resp);
});

DeviceEventEmitter.addListener("WeChat_Req", (resp) => {
  emitter.emit(resp.type, resp);
});

type Callback = (error: any, result: any) => void;
function wrapRegisterApp(nativeFunc: ((...args: any[]) => void) | undefined) {
  if (!nativeFunc) {
    return undefined;
  }

  return (...args: any[]): Promise<boolean> => {
    if (isAppRegistered) {
      return Promise.resolve(true);
    }

    isAppRegistered = true; // 注册状态修改

    return new Promise((resolve, reject) => {
      nativeFunc.apply(null, [
        ...args,
        (error: any, result: any) => {
          if (!error) {
            return resolve(result);
          }
          if (typeof error === "string") {
            return reject(new Error(error));
          }
          reject(error);
        },
      ] as [...any[], Callback]);
    });
  };
}

function wrapApi(nativeFunc: ((...args: any[]) => void) | undefined) {
  if (!nativeFunc) {
    return undefined;
  }

  return (...args: any[]): Promise<any> => {
    if (!isAppRegistered) {
      return Promise.reject(new Error("registerApp required."));
    }

    return new Promise((resolve, reject) => {
      nativeFunc.apply(null, [
        ...args,
        (error: any, result: any) => {
          if (!error) {
            return resolve(result);
          }
          if (typeof error === "string") {
            return reject(new Error(error));
          }
          reject(error);
        },
      ] as [...any[], Callback]);
    });
  };
}

/**
 * `addListener` inherits from `events` module
 * @method addListener
 * @param {String} eventName - the event name
 * @param {Function} trigger - the function when event is fired
 */
export const addListener = emitter.addListener.bind(emitter);

/**
 * `once` inherits from `events` module
 * @method once
 * @param {String} eventName - the event name
 * @param {Function} trigger - the function when event is fired
 */
export const once = emitter.once.bind(emitter);

/**
 * `removeAllListeners` inherits from `events` module
 * @method removeAllListeners
 * @param {String} eventName - the event name
 */
export const removeAllListeners = emitter.removeAllListeners.bind(emitter);

/**
 * @method registerApp
 * @param {String} appid - the app id
 * @return {Promise}
 */
export const registerApp = wrapRegisterApp(WechatLib.registerApp);

// /**
//  * @method registerAppWithDescription
//  * @param {String} appid - the app id
//  * @param {String} appdesc - the app description
//  * @return {Promise}
//  */
// export const registerAppWithDescription = wrapRegisterApp(
//   WechatLib.registerAppWithDescription,
// );

/**
 * Return if the wechat app is installed in the device.
 * @method isWXAppInstalled
 * @return {Promise}
 */
export const isWXAppInstalled = wrapApi(WechatLib.isWXAppInstalled);

/**
 * Return if the wechat application supports the api
 * @method isWXAppSupportApi
 * @return {Promise}
 */
export const isWXAppSupportApi = wrapApi(WechatLib.isWXAppSupportApi);

/**
 * Get the wechat app installed url
 * @method getWXAppInstallUrl
 * @return {String} the wechat app installed url
 */
// export const getWXAppInstallUrl = wrapApi(WechatLib.getWXAppInstallUrl);

/**
 * Get the wechat api version
 * @method getApiVersion
 * @return {String} the api version string
 */
export const getApiVersion = wrapApi(WechatLib.getApiVersion);

/**
 * Open wechat app
 * @method openWXApp
 * @return {Promise}
 */
export const openWXApp = wrapApi(WechatLib.openWXApp);

// wrap the APIs
const nativeLaunchMiniProgram = wrapApi(WechatLib.launchMiniProgram);
const nativeShareText = wrapApi(WechatLib.shareText);
const nativeShareImage = wrapApi(WechatLib.shareImage);
const nativeShareLocalImage = wrapApi(WechatLib.shareLocalImage);
const nativeShareMusic = wrapApi(WechatLib.shareMusic);
const nativeShareVideo = wrapApi(WechatLib.shareVideo);
const nativeShareWebpage = wrapApi(WechatLib.shareWebpage);
const nativeShareMiniProgram = wrapApi(WechatLib.shareMiniProgram);
const nativeSubscribeMessage = wrapApi(WechatLib.subscribeMessage);

const nativeChooseInvoice = wrapApi(WechatLib.chooseInvoice);
const nativeShareFile = wrapApi(WechatLib.shareFile);
const nativeScan = wrapApi(WechatLib.authByScan);

// https://developers.weixin.qq.com/doc/offiaccount/Basic_Information/Get_access_token.html
const getAccessToken = async (appId: string, appSecret: string) => {
  let url =
    "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" +
    appId +
    "&secret=" +
    appSecret;
  const response = await fetch(url);
  const res = await response.json();
  return res.access_token;
};

const getSDKTicket = async (accessToken: string) => {
  let url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?type=2&access_token=" + accessToken;
  const response = await fetch(url);
  const res = await response.json();
  return res.ticket;
};

const createSignature = (appId: string, nonceStr: string, sdkTicket: string, timestamp: string) => {
  const origin = "appid=" + appId + "&noncestr=" + nonceStr + "&sdk_ticket=" + sdkTicket + "&timestamp=" + timestamp;
  const ret = sha1(origin);
  return ret;
};

const getUserInfo = (appId: string, appSecret: string, code: string, callback: (res: any) => void) => {
  let accessTokenUrl =
    "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" +
    appId +
    "&secret=" +
    appSecret +
    "&code=" +
    code +
    "&grant_type=authorization_code";
  fetch(accessTokenUrl)
    .then((res) => {
      return res.json();
    })
    .then((res) => {
      // console.log('wechat get access code success: ', res.access_token);
      let userInfoUrl =
        "https://api.weixin.qq.com/sns/userinfo?access_token=" + res.access_token + "&openid=" + res.openid;
      fetch(userInfoUrl)
        .then((res2) => {
          return res2.json();
        })
        .then((json) => {
          // console.log('wechat get user info success: ', json);
          callback({
            nickname: json.nickname,
            headimgurl: json.headimgurl,
            openid: json.openid,
            unionid: json.unionid,
          });
        })
        .catch((e) => {
          console.warn("wechat get user info fail ", e);
          callback({ error: e });
        });
    })
    .catch((e) => {
      console.warn("wechat get access code fail ", e);
      callback({ error: e });
    });
};

const generateObjectId = () => {
  var timestamp = ((new Date().getTime() / 1000) | 0).toString(16); // eslint-disable-line no-bitwise
  return (
    timestamp +
    "xxxxxxxxxxxxxxxx".replace(/[x]/g, function () {
      return ((Math.random() * 16) | 0).toString(16).toLowerCase(); // eslint-disable-line no-bitwise
    })
  );
};

/**
 * @method authByScan
 * @param {String} appId - the app id
 * @param {String} appSecret - the app secret
 * @param {Function} onQRGet - (qrcode: string) => void
 * @return {Promise}
 */
export function authByScan(appId: string, appSecret: string, onQRGet: (qrcode: string) => void) {
  return new Promise(async (resolve, reject) => {
    const accessToken = await getAccessToken(appId, appSecret);
    const ticket = await getSDKTicket(accessToken);
    const nonceStr = generateObjectId();
    const timestamp = String(Math.round(Date.now() / 1000));
    const signature = createSignature(appId, nonceStr, ticket, timestamp);

    const qrcodeEmitter = WechatLib.getNativeEventEmitter();
    // @ts-ignore
    const unsubscribe = qrcodeEmitter.subscribe("onAuthGotQrcode", (res) => onQRGet && onQRGet(res.qrcode));
    console.log('%c  unsubscribe:', 'color: #0e93e0;background: #aaefe5;', unsubscribe);

    const ret = await nativeScan?.(appId, nonceStr, timestamp, "snsapi_userinfo", signature, "");
    console.log('%c  ret:', 'color: #0e93e0;background: #aaefe5;', ret);
    unsubscribe();
    if (!ret?.authCode) {
      reject(
        new WechatError({
          errStr: "Auth code 获取失败",
          errCode: -1,
        })
      );
      return;
    }
    getUserInfo(appId, appSecret, ret?.authCode, (result) => {
      console.log('扫码登录结果', result)
      if (!result.error) {
        resolve(result);
      } else {
        reject(
          new WechatError({
            errStr: "扫码登录失败" + JSON.stringify(result),
            errCode: -2,
          })
        );
      }
    });
  });
}

/**
 * @method sendAuthRequest
 * @param {Array} scopes - the scopes for authentication.
 * @return {Promise}
 */
export function sendAuthRequest(scopes: string, state: string) {
  return new Promise((resolve, reject) => {
    WechatLib.sendAuthRequest(scopes, state);
    emitter.once("SendAuth.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share text
 * @method shareText
 * @param {Object} data
 */
export function shareText(data: ShareTextMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareText?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Choose Invoice
 * @method chooseInvoice
 * @param {Object} data
 */
export function chooseInvoice(data = {}) {
  return new Promise((resolve, reject) => {
    nativeChooseInvoice?.(data);
    emitter.once("WXChooseInvoiceResp.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share File
 * @method shareFile
 * @param {Object} data
 */
export function shareFile(data: ShareFileMetadata) {
  return new Promise((resolve, reject) => {
    nativeShareFile?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share image
 * @method shareImage
 * @param {Object} data
 */
export function shareImage(data: ShareImageMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareImage?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share local image
 * @method shareLocalImage
 * @param {Object} data
 */
export function shareLocalImage(data: ShareImageMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareLocalImage?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share music
 * @method shareMusic
 * @param {Object} data
 */
export function shareMusic(data: ShareMusicMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareMusic?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share video
 * @method shareVideo
 * @param {Object} data
 */
export function shareVideo(data: ShareVideoMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareVideo?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * Share webpage
 * @method shareWebpage
 * @param {Object} data
 */
export function shareWebpage(data: ShareWebpageMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareWebpage?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}
/**
 * Share miniProgram
 * @method shareMiniProgram
 * @param {Object} data
 */
export function shareMiniProgram(data: ShareMiniProgramMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  if (data && data.miniProgramType == null) {
    data.miniProgramType = 0;
  }
  return new Promise((resolve, reject) => {
    nativeShareMiniProgram?.(data);
    emitter.once("SendMessageToWX.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * 打开小程序
 * @method launchMini
 * @param
 * @param {String} userName - 拉起的小程序的username
 * @param {Integer} miniProgramType - 拉起小程序的类型. 0-正式版 1-开发版 2-体验版
 * @param {String} path - 拉起小程序页面的可带参路径，不填默认拉起小程序首页
 */
export function launchMiniProgram({ userName, miniProgramType = 0, path = "" }: LaunchMiniProgramMetadata) {
  return new Promise((resolve, reject) => {
    if (miniProgramType !== 0 && miniProgramType !== 1 && miniProgramType !== 2) {
      reject(
        new WechatError({
          errStr: "拉起小程序的类型不对，0-正式版 1-开发版 2-体验版",
          errCode: -1,
        })
      );
      return;
    }
    nativeLaunchMiniProgram?.({ userName, miniProgramType, path });
    emitter.once("WXLaunchMiniProgramReq.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * 一次性订阅消息
 * @method shareVideo
 * @param {Object} data
 */
export function subscribeMessage(data: SubscribeMessageMetadata) {
  if (data && data.scene == null) {
    data.scene = 0;
  }
  return new Promise((resolve, reject) => {
    nativeSubscribeMessage?.(data);
    emitter.once("WXSubscribeMsgReq.Resp", (resp) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

interface PayResponse {
  errCode: number;
  errStr?: string;
  [key: string]: any;
}

/**
 * 支付
 * @param data PaymentLoad
 * @returns Promise<PayResponse>
 */
export function pay(data: PaymentLoad): Promise<PayResponse> {
  function correct(actual: keyof PaymentLoad, fixed: keyof PaymentLoad) {
    if (!data[fixed] && data[actual]) {
      data[fixed] = data[actual];
      delete data[actual];
    }
  }

  correct("prepayid" as keyof PaymentLoad, "prepayId");
  correct("noncestr" as keyof PaymentLoad, "nonceStr");
  correct("partnerid" as keyof PaymentLoad, "partnerId");
  correct("timestamp" as keyof PaymentLoad, "timeStamp");

  data.timeStamp = String(data.timeStamp);

  return new Promise((resolve, reject) => {
    WechatLib.pay(data, (result: any) => {
      if (result) reject(result);
    });

    emitter.once("PayReq.Resp", (resp: PayResponse) => {
      if (resp.errCode === 0) {
        resolve(resp);
      } else {
        reject(new WechatError(resp));
      }
    });
  });
}

/**
 * promises will reject with this error when API call finish with an errCode other than zero.
 */
interface WechatResponse {
  errCode: number;
  errStr?: string;
}

export class WechatError extends Error {
  code: number;

  constructor(resp: WechatResponse) {
    const message = resp.errStr || resp.errCode.toString();
    super(message);
    this.name = "WechatError";
    this.code = resp.errCode;

    // 处理 Babel 对 Error 类继承的限制
    if (typeof Object.setPrototypeOf === "function") {
      Object.setPrototypeOf(this, WechatError.prototype);
    } else {
      // @ts-ignore
      this.__proto__ = WechatError.prototype;
    }
  }
}

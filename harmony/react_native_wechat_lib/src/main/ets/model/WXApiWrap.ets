import { wxopensdk } from '../../../../ts';

export type OnWXReq = (req: wxopensdk.BaseReq) => void
export type OnWXResp = (resp: wxopensdk.BaseResp) => void

const kTag = "WXApiEventHandlerImpl"

class WXApiEventHandlerImpl implements wxopensdk.WXApiEventHandler {
  private onReqCallbacks: Map<string, OnWXReq> = new Map
  private onRespCallbacks: Map<string, OnWXResp> = new Map

  registerOnWXReqCallback(key: string, on: OnWXReq) {
    this.onReqCallbacks.set(key, on)
  }
  unregisterOnWXReqCallback(key: string) {
    this.onReqCallbacks.delete(key)
  }

  registerOnWXRespCallback(key: string, on: OnWXResp) {
    this.onRespCallbacks.set(key, on)
  }
  unregisterOnWXRespCallback(key: string) {
    this.onRespCallbacks.delete(key)
  }

  onReq(req: wxopensdk.BaseReq): void {
    wxopensdk.Log.i(kTag, "onReq:%s", JSON.stringify(req))
    this.onReqCallbacks.forEach((on) => {
      on(req)
    })
  }

  onResp(resp: wxopensdk.BaseResp): void {
    wxopensdk.Log.i(kTag, "onResp:%s", JSON.stringify(resp))
    this.onRespCallbacks.forEach((on) => {
      on(resp)
    })
  }
}

export const WXEventHandler = new WXApiEventHandlerImpl


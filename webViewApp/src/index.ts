import { ReqResMessaging } from './ReqResMessaging';
import { Paths } from './__generated_ios_api_schema__'

declare global {
  interface Window {
    // iOS web-view specific injected objects for WebView -> iOS communication
    webkit: { messageHandlers: { observer: { postMessage: (m: any) => void }}}
    // iOS message to send message from iOS->WebView
    __global__onNewIosMessage: (m: any) => void
  }
}

const rrMessaging = new ReqResMessaging()

// # swift web view implementation
// 1. send messages:     JS -> iOS
rrMessaging.registerEmitMessage(m => window.webkit.messageHandlers.observer.postMessage(m))

// 2. receive messages: iOS -> JS
window.__global__onNewIosMessage = (m: any) => {
  rrMessaging.handleMessage(m)
  // https://stackoverflow.com/a/61262502/8995887
  return undefined
}

/*
// # iframe implementation will look like:
// 1. send messages:     JS    -> Iframe
rrMessaging.registerEmitMessage(m => window.parent.postMessage(m, '*'))
// 2. receive messages: Iframe -> JS
window.addEventListener('message', e => rrMessaging.handleMessage(e.data))
*/

const fetchMessage = <URI extends keyof Paths>(
  uri: URI,
  body: Paths[URI]['request'],
) =>
  rrMessaging.fetchMessage<Paths[URI]['request'], Paths[URI]['response']>(uri, body)

const getFetchMessageByURI = <URI extends keyof Paths>(
  uri: URI,
) => (body: Paths[URI]['request']) =>
  fetchMessage(uri, body)


export const swiftNativeUISDK = {

  asyncUi: getFetchMessageByURI('ios/ASYNC_UI'),

  _iOSLog: getFetchMessageByURI('ios/JS_STD_OUTPUT'),

  __rrMessaging: rrMessaging
}

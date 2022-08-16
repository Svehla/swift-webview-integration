import { swiftNativeUISDK } from '../.';

declare global {
  interface Window {
    logIos: () => void
    asyncUI: () => void
  }
}

const ui = {
  loading: () => {
    document.getElementById("response-data")!.innerHTML = "loading"
    document.getElementById("response-error")!.innerHTML = ""
  },

  error: (err: any) => {
    console.error(err)
    document.getElementById("response-data")!.innerHTML = ""
    document.getElementById("response-error")!.innerHTML = err
    swiftNativeUISDK._iOSLog({
      message: `${err}`,
      type: 'error'
    })
  },

  data: (data) => {
    document.getElementById("response-data")!.innerHTML = JSON.stringify(data, null, 2)
    document.getElementById("response-error")!.innerHTML = ""
  },
}

// ----- server -----
swiftNativeUISDK.__rrMessaging.onMessage("js/REVERSE_TEXT", (body) => {
  if (body.inputText === "") {
    throw new Error("input is empty error")
  }
  return {
    reversedText: body.inputText.split('').reverse().join('')
  }
})


// ----- client service layer -----
window.logIos = async () => {
  try {
    ui.loading()
    const resData = await swiftNativeUISDK._iOSLog({ type: 'error', message: "xxx" })
    await swiftNativeUISDK._iOSLog({ type: 'log', message: "logging" })
    ui.data(resData)
  } catch(err) {
    ui.error(err)
  }
}

window.asyncUI = async () => {
  try {
    ui.loading()
    let resData = await swiftNativeUISDK.asyncUi({ h1: 'JS header' })
    ui.data(resData)
  } catch(err) {
    ui.error(err)
  }
}

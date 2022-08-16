
# Swift - web view proprietal messaging

  
This repo implements `TypeScript` + `Swift` library for transfering default event driven messaging between
native swift app and web view to the Request & Response.

API of the library is inspired by express.js & HTTP protocol.

Library support runtime + compile time validation by generated schema communication description.


## Example communication log

```
← JS  → iOS 2022-08-16 15:01:21 | REQUEST//ios/JS_STD_OUTPUT | id-l6w71eyi-um07oye3l3} | ["directionFlow":REQUEST,"body":{message="logmessagefromJStointheswiftconsole";type=error;},"id":id-l6w71eyi-um07oye3l3},"uri":ios/JS_STD_OUTPUT]
→ iOS →  JS 2022-08-16 15:01:21 | RESPONSE                   | id-l6w71eyi-um07oye3l3} | ["id":"id-l6w71eyi-um07oye3l3}","directionFlow":"RESPONSE","data":[:]]
← JS  → iOS 2022-08-16 15:01:21 | REQUEST//ios/JS_STD_OUTPUT | id-l6w71ezw-k85j02olgkc | ["uri":ios/JS_STD_OUTPUT,"directionFlow":REQUEST,"id":id-l6w71ezw-k85j02olgkc},"body":{message=logging;type=log;}]
→ iOS →  JS 2022-08-16 15:01:21 | RESPONSE                   | id-l6w71ezw-k85j02olgkc | ["data":[:],"id":"id-l6w71ezw-k85j02olgkc}","directionFlow":"RESPONSE"]
← JS  → iOS 2022-08-16 15:01:22 | REQUEST//ios/ASYNC_UI      | id-l6w71gc2-qliz3kj265i | ["id":id-l6w71gc2-qliz3kj265i},"uri":ios/ASYNC_UI,"directionFlow":REQUEST,"body":{h1="JSheader";}]
→ iOS →  JS 2022-08-16 15:01:37 | REQUEST//js/REVERSE_TEXT   | id-549738133-26915442   | ["id":"id-549738133-26915442","directionFlow":"REQUEST","uri":"js/REVERSE_TEXT","body":["inputText":Nam]]
← JS  → iOS 2022-08-16 15:01:37 | RESPONSE                   | id-549738133-26915442   | ["id":id-549738133-26915442,"data":{reversedText=maN;},"directionFlow":RESPONSE]
→ iOS →  JS 2022-08-16 15:01:37 | RESPONSE                   | id-l6w71gc2-qliz3kj265i | ["id":"id-l6w71gc2-qliz3kj265i}","data":["username":Kuba,"gender":maN,"age":{value=30;},"hasGender":1],"directionFlow":"RESPONSE"]

```

## Example communication without data

```

← JS  → iOS 2022-08-16 15:01:21 | REQUEST//ios/JS_STD_OUTPUT | id-l6w71eyi-um07oye3l3}
→ iOS →  JS 2022-08-16 15:01:21 | RESPONSE                   | id-l6w71eyi-um07oye3l3}
← JS  → iOS 2022-08-16 15:01:21 | REQUEST//ios/JS_STD_OUTPUT | id-l6w71ezw-k85j02olgkc
→ iOS →  JS 2022-08-16 15:01:21 | RESPONSE                   | id-l6w71ezw-k85j02olgkc
← JS  → iOS 2022-08-16 15:01:22 | REQUEST//ios/ASYNC_UI      | id-l6w71gc2-qliz3kj265i
→ iOS →  JS 2022-08-16 15:01:37 | REQUEST//js/REVERSE_TEXT   | id-549738133-26915442  
← JS  → iOS 2022-08-16 15:01:37 | RESPONSE                   | id-549738133-26915442  
→ iOS →  JS 2022-08-16 15:01:37 | RESPONSE                   | id-l6w71gc2-qliz3kj265i

```


## Javascript request to swift example

```typescript
let resData = await swiftNativeUISDK.asyncUi({ h1: 'JS header' })
```

## Javascript handling swift call

```typescript
swiftNativeUISDK.__rrMessaging.onMessage("js/REVERSE_TEXT", (body) => ({
  reversedText: body.inputText.split('').reverse().join('')
}))

```

## Swift request to webView example
```swift
let reversedGenderResponse = try await self.webViewMessaging.fetchMessage(
  ReqBodyOf: Test1ReqBody.self,
  ResOf: Test1ResData.self,
  "js/REVERSE_TEXT",
  Test1ReqBody(inputText: genderInput )
)
```



## Swift handling webView call

```swift
self.webViewMessaging.onMessage(ReqOf: JsLogReqBody.self, ResOf: JsLogResData.self, "ios/JS_STD_OUTPUT") { body in
  if (AppConfig.Logging.printJSConsoleLog) {
    print("📲",  "JS_STDOUT", getCurrentFormattedTime(), "|", body.type.getIcon(), body.message)
  }
  return JsLogResData()
}
```

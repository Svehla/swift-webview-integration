
# Swift <-> webView Request Response protocol
  
Implementation of the custom protocol for the `Request` & `Response` (`ReqResMessaging`) messaging between `iOS` and `web-view`.

API of the `ReqResMessaging` is heavily inspired by `express.js` & `HTTP` & `swagger`.

`ReqResMessaging` is build on top of the native one way directional message emiting.

`ReqResMessaging` supports:
- Awaitable `Request` & `Response` communication
- Abstraction over one-way directional postMessages
- Runtime message validations
- Compile-time message validations
- Generating API schema similar to the `open API spec`
- Integration for the `Web <-> Iframe` communication
- Protocol has currently implementations in the 2 languages:
  - Swift
  - TypeScript
- Generic error handling

## Communication logs examples

### Example communication log

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

## Examples



### Swift register message handler from the webView

```swift
self.webViewMessaging.onMessage(ReqOf: JsLogReqBody.self, ResOf: JsLogResData.self, "ios/JS_STD_OUTPUT") { body in
  if (AppConfig.Logging.printJSConsoleLog) {
    print("📲",  "JS_STDOUT", getCurrentFormattedTime(), "|", body.type.getIcon(), body.message)
  }
  return JsLogResData()
}
```

### Javascript request to the swift app

```typescript
let response = await swiftNativeUISDK.fetchMessage('ios/JS_STD_OUTPUT')
```

---------------------

### Javascript register message handler from the swift App

```typescript
swiftNativeUISDK.__rrMessaging.onMessage("js/REVERSE_TEXT", (body) => ({
  reversedText: body.inputText.split('').reverse().join('')
}))

```

### Swift request to the webView

```swift
let reversedGenderResponse = try await self.webViewMessaging.fetchMessage(
  ReqBodyOf: ReverseTextReqBody.self,
  ResOf: ReverseResData.self,
  "js/REVERSE_TEXT",
  Test1ReqBody(inputText: genderInput )
)
```


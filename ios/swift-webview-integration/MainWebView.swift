import SwiftUI
import WebKit
import Combine

struct MainWebView: View {
    
    let webViewMessaging = ReqResMessaging()
    
    @State private var isWebViewReady = true
    @State private var hideActiveWebView = false
 
    @EnvironmentObject var syncModal: SyncModal
    
    var body: some View {
        VStack {
            VStack {
                WebView(
                    // TODO: pass proper query params, not pure string
                    targetWebURL: EnvConfig.webViewURL,
                    messaging_handleMessage: { message in
                        
                        if AppConfig.Logging.iOSJSCommunication {
                            logMessage("← JS  → iOS", message)
                        }
                        do {
                            try webViewMessaging.handleMessage(message)
                        } catch {
                            print("Not able to process the message: \(message). error: \(error)")
                        }
                    },
                    messaging_registerEmitMessage: {sendMessageToJS in
                        // UI has to wait till the webView messaging is ready to 'receive' & 'send' messages
                        self.isWebViewReady = false
                        webViewMessaging.registerEmitMessage({ message in
                            if AppConfig.Logging.iOSJSCommunication {
                                logMessage("→ iOS →  JS", message)
                            }
                            sendMessageToJS(message)
                        })
                    }
                )
            }.opacity(self.hideActiveWebView ? 0 : 1)

        }.onAppear(perform: {
           
            enum LogMessageType: String, ReqResDTO {
                case error
                case info
                case log
                
                func getIcon () -> String {
                    switch self {
                    case .info:
                        return "🔵"
                    case .error:
                        return "🔴"
                    case .log:
                        return "🟢"
                    }
                }
            }
            
            struct JsLogReqBody: ReqResDTO {
                let type: LogMessageType
                let message: String
            }
            struct JsLogResData: ReqResDTO {}
            self.webViewMessaging.onMessage(ReqOf: JsLogReqBody.self, ResOf: JsLogResData.self, "ios/JS_STD_OUTPUT") { body in
                if (AppConfig.Logging.printJSConsoleLog) {
                    print("📲",  "JS_STDOUT", getCurrentFormattedTime(), "|", body.type.getIcon(), body.message)
                }
                return JsLogResData()
            }

            
            struct Test1ReqBody: ReqResDTO {
                let inputText: String
            }
            struct Test1ResData: ReqResDTO {
                let reversedText: String
            }
            
            struct AsyncUIReqBody: ReqResDTO {
                let h1: String
            }
            struct AsyncUIResData: ReqResDTO {
                let username: String
                let age: IntModalData
                let hasGender: Bool?
                let gender: String?
            }
            self.webViewMessaging.onMessage(ReqOf: AsyncUIReqBody.self, ResOf: AsyncUIResData.self, "ios/ASYNC_UI", { body in
                let username = try await syncModal.show(SyncTextModal(text: "username \(body.h1)"))

                let age = try await syncModal.show(SyncAgeModal())

                let hasGender = try await syncModal.show(SyncBooleanModal())
                
                var gender: String?
                if (hasGender) {
                   let genderInput = try await syncModal.show(SyncTextModal(text: "specify your gender"))
                    
                    let reversedGenderResponse = try await self.webViewMessaging.fetchMessage(
                       ReqBodyOf: Test1ReqBody.self,
                       ResOf: Test1ResData.self,
                       "js/REVERSE_TEXT",
                       Test1ReqBody(inputText: genderInput )
                   )

                    gender = reversedGenderResponse.reversedText
                }
                

                return AsyncUIResData(
                    username: username,
                    age: age,
                    hasGender: hasGender,
                    gender: gender ?? "404"
               )
            })

            // TODO: Generate + sync output to the webViewApp somehow
            // TODO: sort json alphabetically: https://codeshack.io/json-sorter/
            let jsonApiDoc = self.webViewMessaging.getJSONApiDoc()
            print(jsonApiDoc)
        })
    }
    
}



// ---------------------------------------------------------------
//     Messaging Network debugging for ReqResMessaging library
// ---------------------------------------------------------------

let getCurrentFormattedTime = { () -> String in
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}

let logMessage = { (prefix: String, data: Dictionary<String, Any>) in
    var directionFlow = (data["directionFlow"] as! String)
    let id = (data["id"] as! String).padding(toLength: 23, withPad: " ", startingAt: 0)
    let stringifiedData = "\(data)".components(separatedBy: .whitespacesAndNewlines).joined()
    if (directionFlow == DirectionFlow.REQUEST.rawValue) {
        directionFlow = "\(directionFlow)//\(data["uri"] as! String)"
    }
    
    print(prefix, getCurrentFormattedTime(), "| \(directionFlow.padding(toLength: 26, withPad: " ", startingAt: 0)) | \(id) | \(AppConfig.Logging.iOSJSMessageBody ? stringifiedData: "")")
}


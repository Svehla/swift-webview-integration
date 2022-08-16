import SwiftUI
import WebKit
import Combine


// --------------------------------
//     WebView Component
// --------------------------------

struct WebView: UIViewRepresentable {
    
    let targetWebURL: String
    let messaging_handleMessage: (_ message: JSONDictionary) -> Void
    let messaging_registerEmitMessage: (_ emitMessageFn: @escaping ((JSONDictionary) -> Void)) -> Void
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        let userContentController = WKUserContentController()

        userContentController.add(context.coordinator, name:"observer")

        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        
        DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: self.targetWebURL )!)
            webView.load(request)
        }
        return webView
    }
  
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
  
    typealias UIViewType = WKWebView
}


class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

    var controlParentWebView: WebView
    var wkWebView: WKWebView?

    init(_ controlParentWebView: WebView) {
        self.controlParentWebView = controlParentWebView
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dictMessage = message.body as! JSONDictionary
        self.controlParentWebView.messaging_handleMessage(dictMessage)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.wkWebView = webView
        self.controlParentWebView.messaging_registerEmitMessage(self.sendMessageToJS)
    }

    func sendMessageToJS(_ data: JSONDictionary) {
        let webView = self.wkWebView!

        DispatchQueue.main.async {
            let dictAsString = convertDictionaryToJSONString(data)
            let javascriptFunction = "__global__onNewIosMessage(\(dictAsString))"
            webView.evaluateJavaScript(javascriptFunction) { (response, error) in
                if let error = error {
                    print("!!! Error calling javascript:__global__onNewIosMessage()")
                    print(error)
                    print(error.localizedDescription)
                }
            }
        }
    }
}

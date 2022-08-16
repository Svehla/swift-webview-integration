import SwiftUI

@main
struct swift_webview_integrationApp: App {
    
    @StateObject var syncModal = SyncModal()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                MainWebView()
                HookGlobalModal()
            }.environmentObject(syncModal)

        }
    }
}

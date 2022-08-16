import SwiftUI

class SyncComponent <T> {
    var resolve: ((T) -> Void)?
    var reject: ((Error) -> Void)?
    
    // swift promises sucks because you cant hold pointer into the unresolved promise
    func awaitSuccess() async throws -> T {
        // TODO: check if someone already call it and throw error if yes
        // THIS HAVE TO BE IN THE CLASS!!! not STRUCT => then there is memory leak
        return try await withCheckedThrowingContinuation({ continuation -> Void in
            self.resolve = { val in
                continuation.resume(returning: val)
            }
            self.reject = { err in
                continuation.resume(throwing: err)
            }
        })
    }
}


protocol SyncViewComponentProtocol: View {
    associatedtype T
    var sync: SyncComponent<T> { get }
}


struct ModalComponent: View {
    var genericView: AnyView
    
    // inspiration
    // > https://stackoverflow.com/q/65390267/8995887
    @Environment(\.presentationMode) var presentationMode
    
    @State var isPresented = true
    var body: some View {
        VStack {
            VStack {
                Button("Return back to the modal") {
                    // presentationMode.wrappedValue.dismiss()
                    self.isPresented = true
                }
                .sheet(
                    isPresented: self.$isPresented,
                    // user is not able to close the modal by swipe down xd
                    onDismiss: { isPresented = true }
                ) {
                    genericView
                }

            }
        }
    }
}
    
/**
 * TODO: add locking for more paralles open modals
 */
class SyncModal: ObservableObject {
    
    // global shared state
    @Published var syncModalView: ModalComponent? = nil
    
    func setAsyncDynamicModalUI (_ v: AnyView?) {
        DispatchQueue.main.async {
            if let vv = v {
                self.syncModalView = ModalComponent(genericView: vv)
                return
            }
            self.syncModalView = nil
        }
    }
    
    func show <U: SyncViewComponentProtocol>(_ genericView: U) async throws -> U.T {
        do {
            // https://stackoverflow.com/a/58497643/8995887
            setAsyncDynamicModalUI(AnyView(genericView))
            let data = try await genericView.sync.awaitSuccess()
            setAsyncDynamicModalUI(nil)
            return data
        } catch {
            setAsyncDynamicModalUI(nil)
            throw error
        }
    }
}

struct HookGlobalModal: View {
    @EnvironmentObject var syncModal: SyncModal

    var body: some View {
        VStack {
            syncModal.syncModalView
        }
    }
}

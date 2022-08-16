import SwiftUI


enum SyncFormError: Error {
    case basic(_ message: String)
}

struct SyncTextModal : SyncViewComponentProtocol, View {
    let text: String
    var sync = SyncComponent<String>()
    @State var input1 = ""
    
    var body: some View {
        VStack {
            Text(self.text)
            TextField(text: $input1) { Text("Input1") }
            Button("Next") { self.sync.resolve?(self.input1) }
            Button("CANCEL") { self.sync.reject?(SyncFormError.basic("ERROR")) }
        }
    }
}


struct IntModalData: ReqResDTO {
    var value: Int
}

struct SyncAgeModal : SyncViewComponentProtocol {
    var sync = SyncComponent<IntModalData>()
    
    func sendRes (_ age: Int) {
        self.sync.resolve?(IntModalData(value: age))
    }
    var body: some View {
        VStack {
            Text("Age")
            Button("10") { self.sendRes(10) }
            Button("20") { self.sendRes(20) }
            Button("30") { self.sendRes(30) }
            Button("40") { self.sendRes(40) }
            Button("50") { self.sendRes(50) }
        }
    }
}

struct SyncBooleanModal : SyncViewComponentProtocol {
    var sync = SyncComponent<Bool>()
    var body: some View {
        VStack {
            Text("hasGender")
            Button("Yes") { self.sync.resolve?(true) }
            Button("no") { self.sync.resolve?(false) }
        }
    }
}


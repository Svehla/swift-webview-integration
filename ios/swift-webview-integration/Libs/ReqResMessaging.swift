import SwiftUI

// --------------------------------------------------------------------------------
//     LOW-LEVEL Messaging Protocol for sending Dictionaries between two entities
// --------------------------------------------------------------------------------

// All input+output struct has to implement this protocol
protocol ReqResDTO: ConvertableToDictionary {}

// TODO: add proper id generation from the protocol spec
let generateId = {() in "id-\(Int.random(in: 0 ... 1_000_000_000))-\(Int.random(in: 0 ... 1_000_000_000))" }

// TODO: should I use this typeAlias or keep dictionary as it is with Any type?
typealias JSONDictionary = [String: Any]

let decoder = JSONDecoder()

enum DirectionFlow: String {
    case REQUEST = "REQUEST"
    case RESPONSE = "RESPONSE"
    case ERROR_RESPONSE = "ERROR_RESPONSE"
}

enum MessagingError: Error {
    case response(_ message: String)
    case duplicatedMessageHandler(_ message: String)
    case shape(_ message: String)
    case badInitialization(_ message: String)
}

struct build {
    static let response = {(id: String, data: JSONDictionary) in [
        "id": id,
        "directionFlow": DirectionFlow.RESPONSE.rawValue,
        "data": data,
    ]}
    
    static let request = { (uri: String, body: JSONDictionary) in [
        "id": generateId(),
        "directionFlow": DirectionFlow.REQUEST.rawValue,
        "uri": uri,
        "body": body,
    ]}
 
    static let errorResponse = {(id: String, error: String) in [
        "id": id,
        "directionFlow": DirectionFlow.ERROR_RESPONSE.rawValue,
        "error": error,
    ]}
}


typealias MessageHandlerCb = (_ body: JSONDictionary) async throws -> JSONDictionary

struct PendingState {
    let uri: String
    let cleanUp: () -> Void
    let resolve: (_ data: JSONDictionary) -> Void
    let reject: (_ error: String) -> Void
}

class ReqResMessaging {
    
    var _generatedApiDoc = Dictionary<String, Dictionary<String, Any>>()
    
    func getJSONApiDoc() -> String {
        return convertDictionaryToJSONString(self._generatedApiDoc, options: [.prettyPrinted, .sortedKeys])
    }
    
    private var _pendingRequests = Dictionary<String, PendingState>()
    private var _emitMessage: ((JSONDictionary) -> Void)?
    
    private var _messageHandlers = Dictionary<String, MessageHandlerCb/*<Any, Any>*/>()
    
    // I cant set emit message from constructor because it's not available in that time
    func registerEmitMessage(_ emitMessageFn: @escaping ((JSONDictionary) -> Void)) -> Void {
        self._emitMessage = emitMessageFn
    }
    
    func removeOnMessage(_ uri: String) -> Void {
        self._messageHandlers.removeValue(forKey: uri)
    }

    func onMessage <ReqData: ReqResDTO, ResData: ReqResDTO>(
        ReqOf: ReqData.Type,
        ResOf: ResData.Type,
        _ uri: String,
        _ messageHandlerCb: @escaping ((_ body: ReqData) async throws -> ResData)
    ) -> Void {
        if self._messageHandlers[uri] != nil {
            // TODO: keep print here till we'll solve failed request clearing complexly
            print("Message handler for '\(uri)' is already defined") // fatalError("Message handler for '\(uri)' is already defined")
        }
        self._generatedApiDoc[uri] = [
            // TODO: add support for enums
            "request": try! getStructRuntimeShapeDescription(ReqOf),
            "response": try! getStructRuntimeShapeDescription(ResOf)
        ]

        self._messageHandlers[uri] = { body async throws -> JSONDictionary in
            let requestBody = try convertDictionaryToStruct(ReqOf, body)
            let responseStruct = try await messageHandlerCb(requestBody)
            let responseDict = try responseStruct.convertCodableToDict()!
            return responseDict
        }
    }
    

    func handleMessage(_ message: JSONDictionary) throws {
        guard let emitMessage = self._emitMessage else { throw MessagingError.badInitialization("Emit message is not defined") }
        guard let directionFlow = message["directionFlow"] as! String? else { throw MessagingError.shape("invalid 'directionFlow' in message: \(message)") }
        guard let id = message["id"] as! String? else { throw MessagingError.shape("invalid 'id' in message: \(message)") }
        
        switch directionFlow {
        case DirectionFlow.REQUEST.rawValue:
            guard let uri = message["uri"] as! String? else { throw MessagingError.shape("invalid 'uri' in message: \(message)") }
            // message has to be dictionary, not string!
            guard let body = message["body"] as! JSONDictionary? else { throw MessagingError.shape("invalid 'body' in message: \(message)") }
            guard let messageHandler = self._messageHandlers[uri] else {
                emitMessage(build.errorResponse(id, "message handler \(uri) does not exist"))
                throw MessagingError.shape("message handler \(uri) does not exist: \(message)")
            }
            Task {
                var messageToSend: JSONDictionary = Dictionary()
                do {
                    let data = try await messageHandler(body)
                    messageToSend = build.response(id, data as JSONDictionary)
                } catch {
                    messageToSend = build.errorResponse(id, "\(error)")
                }
                emitMessage(messageToSend)
            }
            break;
            
        case DirectionFlow.RESPONSE.rawValue:
            guard let request = self._pendingRequests[id] else { return }
            guard let data = message["data"] as! JSONDictionary? else { throw MessagingError.shape("invalid 'data' in message: \(message)") }
            request.cleanUp()
            request.resolve(data)
            break;

        case DirectionFlow.ERROR_RESPONSE.rawValue:
            guard let request = self._pendingRequests[id] else { return }
            guard let resError = message["error"] as! String? else { throw MessagingError.shape("invalid 'error' in message: \(message)") }
            request.cleanUp()
            request.reject(resError)
            break;
        default:
            throw MessagingError.shape("unsupported directionFlow: \(String(describing: message["directionFlow"])) handler for message: \(message)")
        }
    }

    func fetchMessage<ReqBody: ReqResDTO, ResData: ReqResDTO>(
        ReqBodyOf: ReqBody.Type,
        ResOf: ResData.Type,
        _ uri: String,
        _ bodyStruct: ReqBody
    ) async throws -> ResData {
        // TODO: we could wrap setEmitMessage into the Promise to not to throw new Error => or init it in the constructor?
        guard let emitMessage = self._emitMessage else { throw MessagingError.badInitialization("You can't call fetch before emit message is set") }
        
        let body = try bodyStruct.convertCodableToDict()!
        
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<ResData, Error>) -> Void in
            
            let request = build.request(uri, body)
            
            self._pendingRequests[request["id"] as! String] = PendingState(
                uri: uri,
                cleanUp: { () -> Void in self._pendingRequests.removeValue(forKey: request["id"] as! String)},
                resolve: { (dictData: JSONDictionary) in
                    do {
                        let data = try convertDictionaryToStruct(ResOf, dictData)
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: MessagingError.response("\(error)"))
                    }
                },
                reject: { (err: String) in
                    continuation.resume(throwing: MessagingError.response(err))
                }
            )
            
            emitMessage(request)
        })
    }
}

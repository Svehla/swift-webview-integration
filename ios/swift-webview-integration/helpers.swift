import Foundation

// --------------------------------
//     JSON/Dictionary/ helpers
// --------------------------------

// kinda shitty convert solution via JSON
func convertDictionaryToStruct<T: Decodable>(_ Struct: T.Type, _ data: Dictionary<String, Any>) throws -> T {
    let structData = try decoder.decode(Struct.self, from: Data(convertDictionaryToJSONString(data).utf8))
    return structData
}


func convertDictionaryToJSONString(_ jsonDictionary: JSONDictionary, options: JSONSerialization.WritingOptions = []) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: options /**/)
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    } catch {
        return ""
    }
}

// inspiration
// > https://stackoverflow.com/a/69413762/8995887
// TODO: convert this code into the function
protocol ConvertableToDictionary: Codable {}
extension ConvertableToDictionary {
    func convertCodableToDict() throws -> Dictionary<String, Any>? {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
    }
}



import SwiftUI
import Runtime


enum StructMetadataError: Error {
    case unsupportedDataType(_ message: String)
}

/**
  inspiration:
  > non-answered question: https://stackoverflow.com/questions/51986512/swift-get-struct-properties-from-type-reference
  > working code: https://gist.github.com/pofat/d3c77ca88c5b2a3019febcb073c3d879
  > working library:
    https://medium.com/@weswickwire/creating-a-swift-runtime-library-3cc92fc486cc
    https://github.com/wickwirew/Runtime
*/
func getStructRuntimeShapeDescription(_ MyStruct: Any.Type) throws -> [String: Any] {
    var info: TypeInfo
    var isRequired = true
    
    info = try typeInfo(of: MyStruct.self)
    
    // ----- unwrap optional type -----
    if info.kind == .optional {
        isRequired = false
        let nonNullableDataCase = info.cases.first(where: { i in
            switch i.payloadType {
            case .some:
                return true
            default:
                return false
            }
        })
        let unwrappedType = nonNullableDataCase!.payloadType.unsafelyUnwrapped
        info = try typeInfo(of: unwrappedType)
    }
    
    if info.kind == .enum {
        let enumValue = info.cases.map { i in i.name }
        
        return [
            "type": "string",
            "enum": enumValue,
            "required": isRequired,
        ]
    }
    
    if info.type is String.Type {
        return ["type": "string", "required": isRequired]
    } else if info.type is Int.Type {
        return ["type": "int", "required": isRequired]
    } else if info.type is Bool.Type {
        return ["type": "boolean", "required": isRequired]
    } else if info.type is Float.Type {
        return ["type": "float", "required": isRequired]
    }
    
    if (info.mangledName == "Array") {
        return [
            "type": "array",
            "required": isRequired,
            "items": try getStructRuntimeShapeDescription(
                // array has only one generic like this: Array<FirstGenericItemType>
                info.genericTypes[0]
            )
        ]
    }

    if info.kind != .struct {
        throw StructMetadataError.unsupportedDataType("unsupported type.kind : \(info.kind)")
    }
    
    var objAttributes = [:] as Dictionary<String, Any>
    
    try info.properties.forEach { i -> Void in
        objAttributes[i.name] = try getStructRuntimeShapeDescription(i.type)
    }
    
    return [
        "type": "object",
        "required": isRequired,
        "attributes": objAttributes
    ]
}


import Foundation

public enum FriendlyDecodableError: Error {
    public static func from(_ decodingError: DecodingError) -> FriendlyDecodableError {
        switch decodingError {
        case let .valueNotFound(dataType, context):
            return .missingValue(type: String(describing: dataType),
                                 path: humanReadablePath(from: context.codingPath))
            
        case let .keyNotFound(key, context):
            return .keyNotFound(key: key.stringValue,
                                path: humanReadablePath(from: context.codingPath))
            
        case .dataCorrupted:
            return .corruptedData
            
        case let .typeMismatch(dataType, context):
            return .typeMismatch(expected: String(describing: dataType),
                                 path: humanReadablePath(from: context.codingPath))
            
        @unknown default:
            assertionFailure("DecodingError gained a new case that we're not handling yet")
            return other
        }
    }
    
    /// The model has a required property, but the data has a `null` value
    /// - Note: Some types (e.g. `Bool`) return a `typeMismatch` instead.
    /// - Parameters:
    ///   - type: The expected type of the missing value
    ///   - path: The path to the property in the model
    case missingValue(type: String, path: String)
    
    /// A required property of the model is not present in the data
    /// - Parameters:
    ///   - key: The name of the property
    ///   - path: The path to the property in the model
    case keyNotFound(key: String, path: String)
    
    /// The data could not be parsed as JSON
    case corruptedData
    
    /// The JSON type does not match the model's requirements
    /// - Parameters:
    ///   - expected: The type of the property in the model
    ///   - path: The path to the property in the model
    case typeMismatch(expected: String, path: String)
    
    /// An unknown error occurred
    case other
}

extension FriendlyDecodableError {
    static func humanReadablePath(from path: [CodingKey]) -> String {
        guard !path.isEmpty else { return "." }

        return path.map { key -> String in
            if let index = key.intValue { return "[\(index)]" }
            return ".\(key.stringValue)"
        }
        .joined()
    }
}

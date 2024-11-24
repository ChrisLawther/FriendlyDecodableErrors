import Foundation

public extension DecodingError {
    func helpfulError() -> FriendlyDecodableError {
        FriendlyDecodableError.from(self)
    }
}

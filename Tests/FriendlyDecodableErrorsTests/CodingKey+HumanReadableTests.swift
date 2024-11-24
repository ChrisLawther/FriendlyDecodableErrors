import XCTest
@testable import FriendlyDecodableErrors

final class HumanReadableCodingKeyTests: XCTestCase {
    func testNestedPropertiesDecodeToPeriodSeparatedString() {
        enum Keys: CodingKey {
            case root, child, grandChild
        }
        
        let keys: [CodingKey] = [
            Keys.root,
            Keys.child,
            Keys.grandChild
        ]
        
        let readable = FriendlyDecodableError.humanReadablePath(from: keys)
        
        XCTAssertEqual(readable, ".root.child.grandChild")
    }
    
    func testArrays() {
        enum Keys: CodingKey {
            case root, child, grandChild
        }

        struct ArrayIndex: CodingKey {
            var stringValue: String
            
            init?(stringValue: String) {
                self.stringValue = stringValue
            }
            
            var intValue: Int?
            
            init?(intValue: Int) {
                self.intValue = intValue
                self.stringValue = ""
            }
        }
        
        let keys: [CodingKey] = [
            Keys.root,
            Keys.child,
            ArrayIndex(intValue: 3)!,
            Keys.grandChild
        ]
        
        let readable = FriendlyDecodableError.humanReadablePath(from: keys)

        XCTAssertEqual(readable, ".root.child[3].grandChild")
    }
}

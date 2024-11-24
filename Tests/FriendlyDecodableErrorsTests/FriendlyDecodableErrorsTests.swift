import XCTest
import FriendlyDecodableErrors

final class FriendlyDecodableErrorsTests: XCTestCase {
    
    func testDecodesTypeMismatch() {
        struct Model: Decodable {
            let thing: Int
        }
        
        let json = """
        {
            "thing": "value"
        }
        """.data(using: .utf8)!
        
        do {
            _ = try JSONDecoder().decode(Model.self, from: json)
            XCTFail("Should have thrown")
        } catch let error as DecodingError {
            let friendly = FriendlyDecodableError.from(error)
            guard case let .typeMismatch(expected, path) = friendly else {
                return XCTFail()
            }
            
            XCTAssertEqual(expected, "Int")
            XCTAssertEqual(path, ".thing")

        } catch {
            XCTFail("Threw, but for the wrong reason")
        }
    }
    
    func testDecodesMissingValue() {
        // NOTE: This seems strangely sensitive to the type. If `thing` is a `Bool` (no other changes)
        //       then the test will fail (reporting a typeMismatch rather than a missing value)
        struct Model: Decodable {
            let thing: Int
        }
        
        let json = """
        {
            "thing": null
        }
        """.data(using: .utf8)!
        
        do {
            _ = try JSONDecoder().decode(Model.self, from: json)
            XCTFail("Should have thrown")
        } catch let error as DecodingError {
            let friendly = FriendlyDecodableError.from(error)
            print(error.localizedDescription)
            guard case let .missingValue(expected, path) = friendly else {
                return XCTFail("Wasn't expecting \(friendly)")
            }
            
            XCTAssertEqual(expected, "Int")
            XCTAssertEqual(path, ".thing")

        } catch {
            XCTFail("Threw, but for the wrong reason")
        }
    }
    
    func testDecodesKeyNotFound() {
        struct Model: Decodable {
            let thing: Bool
        }
        
        let json = """
        {
            "other": "value"
        }
        """.data(using: .utf8)!
        
        do {
            _ = try JSONDecoder().decode(Model.self, from: json)
            XCTFail("Should have thrown")
        } catch let error as DecodingError {
            let friendly = FriendlyDecodableError.from(error)
            guard case let .keyNotFound(expected, path) = friendly else {
                return XCTFail("Wasn't expecting \(friendly)")
            }
            
            XCTAssertEqual(expected, "thing")
            XCTAssertEqual(path, ".")

        } catch {
            XCTFail("Threw, but for the wrong reason")
        }
    }
    
    func testDecodesCorruptedData() {
        struct Model: Decodable {
            let thing: Bool
        }
        
        let json = """
        {wtf$£@
        """.data(using: .utf8)!
        
        do {
            _ = try JSONDecoder().decode(Model.self, from: json)
            XCTFail("Should have thrown")
        } catch let error as DecodingError {
            let friendly = FriendlyDecodableError.from(error)
            guard case .corruptedData = friendly else {
                return XCTFail("Wasn't expecting \(friendly)")
            }
            // Nothing further to check - we don't get any visibility of where in the doc
            // the error was.

        } catch {
            XCTFail("Threw, but for the wrong reason")
        }
    }
    
    func testDecodesErrorInNestedProperty() {
        struct Model: Decodable {
            let children: [Child]
        }
        
        struct Child: Decodable {
            let id: Int
        }
        
        let json = """
        {
            "children": [
                {"id": 1},
                {"id": "two"},
                {"id": 3},
            ]
        }
        """.data(using: .utf8)!

        do {
            _ = try JSONDecoder().decode(Model.self, from: json)
            XCTFail("Should have thrown")
        } catch let error as DecodingError {
            let friendly = FriendlyDecodableError.from(error)
            guard case let .typeMismatch(expected, path) = friendly else {
                return XCTFail("Wasn't expecting \(friendly)")
            }
            
            XCTAssertEqual(expected, "Int")
            XCTAssertEqual(path, ".children[1].id")
        } catch {
            XCTFail("Threw, but for the wrong reason")
        }

    }
}

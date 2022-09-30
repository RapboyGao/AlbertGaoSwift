@testable import AlbertGaoSwift
import JavaScriptCore
import XCTest

final class AlbertGaoSwiftTests: XCTestCase {
    func testExample() throws {
//        print(AlbertGaoSwift().text)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
//        XCTAssertEqual(AlbertGaoSwift().text, "Hello, World")
//        print(AGao.keep0sDouble(5, 0, 0))
//
//        print(AGao.keep0sInt(2, 0, 0))

//        let test1 = try! AGao.sumOf60s(["00:100", "1:2:00"], separators: ["°", "′"])
//        print(test1)
//        let jsVM = JSVirtualMachine()
//        let jsContext = JSContext(virtualMachine: jsVM)
//        jsContext?.setObject(AGao.self, forKeyedSubscript: "AGao" as (NSCopying & NSObjectProtocol))
//        let result = jsContext?.evaluateScript("AGao.")
//        print(result as Any)
        let time0 = Time60(source: "1:00:10")
        let time1 = Time60(source: "12:20")
        print((time0 + time1).parsed.numbers)
    }
}

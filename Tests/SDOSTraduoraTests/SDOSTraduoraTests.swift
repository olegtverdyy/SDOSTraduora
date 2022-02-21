import XCTest
import class Foundation.Bundle
@testable import SDOSTraduora

final class SDOSTraduoraTests: XCTestCase {
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//
//        // Some of the APIs that we use below are available in macOS 10.13 and above.
//        guard #available(macOS 10.13, *) else {
//            return
//        }
//
//        let fooBinary = productsDirectory.appendingPathComponent("SDOSTraduora")
//
//        let process = Process()
//        process.executableURL = fooBinary
//
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        try process.run()
//        process.waitUntilExit()
//
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)
//        XCTAssertEqual(output, "Hello, world!\n")
//    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
    
    func testFormatLine() {
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {%1string}"), "Hola, %@")
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {%1string} y {%2string}"), "Hola, %@ y %@")
        XCTAssertEqual(LangClass.shared.formatLine("Mi número de teléfono es {%109int}"), "Mi número de teléfono es %09ld")
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {%1string} y {%2string}. Mi número de teléfono es {%109int}"), "Hola, %@ y %@. Mi número de teléfono es %09ld")
        XCTAssertEqual(LangClass.shared.formatLine("El % del IVA es 21"), "El %% del IVA es 21")
    }

    static var allTests = [
        ("testFormatLine", testFormatLine),
    ]
}

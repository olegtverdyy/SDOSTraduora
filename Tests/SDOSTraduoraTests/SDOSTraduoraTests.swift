import XCTest
import class Foundation.Bundle
@testable import SDOSTraduora

final class SDOSTraduoraTests: XCTestCase {
    func testFormatLine() {
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {{$1;string}}"), "Hola, %@")
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {{$1;string}}. Este no es un formato correcto {$2;string}, {{string}}"), "Hola, %@. Este no es un formato correcto {$2;string}, {{string}}")
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {{$1;string}} y {{$2;string}}"), "Hola, %@ y %@")
        XCTAssertEqual(LangClass.shared.formatLine("Mi número de teléfono es {{$1;number}}. Este no es un formato correcto {$2;number}, {{number}}"), "Mi número de teléfono es %ld. Este no es un formato correcto {$2;number}, {{number}}")
        XCTAssertEqual(LangClass.shared.formatLine("Hola, {{$1;string}} y {{$2;string}}. Mi número de teléfono es {{$3;number}}"), "Hola, %@ y %@. Mi número de teléfono es %ld")
        XCTAssertEqual(LangClass.shared.formatLine("El % del IVA es 21"), "El %% del IVA es 21")
        XCTAssertEqual(LangClass.shared.formatLine("Escape caracter comilla (\")"), "Escape caracter comilla (\\\")")
        XCTAssertEqual(LangClass.shared.formatLine("""
                                                   También tenemos
                                                   saltos de línea
                                                   """), "También tenemos\\nsaltos de línea")
        XCTAssertEqual(LangClass.shared.formatLine("Valor del número Pi: {{$1;decimal}} sin decimales; {{$2;decimal;2}} con 2 decimales; {{$3;decimal;40}} con 40 decimales"), "Valor del número Pi: %f sin decimales; %.2f con 2 decimales; %.40f con 40 decimales")
        XCTAssertEqual(LangClass.shared.formatLine("Valor del número Pi: {{$1;decimal}} sin decimales; {{$2;decimal;2}} con 2 decimales; {{$3;decimal;40}} con 40 decimales. Este no es un formato correcto {$4;decimal}, {$4;decimal:4}, {{decimal}}, {{decimal;52}}"), "Valor del número Pi: %f sin decimales; %.2f con 2 decimales; %.40f con 40 decimales. Este no es un formato correcto {$4;decimal}, {$4;decimal:4}, {{decimal}}, {{decimal;52}}")
    }
}

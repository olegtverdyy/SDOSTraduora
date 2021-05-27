//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation

struct LangDTO: Codable {
    let data: [LangData]

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

// MARK: LangDTO convenience initializers and mutators

extension LangDTO {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LangDTO.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        data: [LangData]? = nil
    ) -> LangDTO {
        return LangDTO(
            data: data ?? self.data
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Datum
struct LangData: Codable {
    let id: String
    let locale: Locale

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case locale = "locale"
    }
}

// MARK: Datum convenience initializers and mutators

extension LangData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(LangData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        id: String? = nil,
        locale: Locale? = nil
    ) -> LangData {
        return LangData(
            id: id ?? self.id,
            locale: locale ?? self.locale
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Locale
struct Locale: Codable {
    let code: String
    let language: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case language = "language"
        case region = "region"
    }
}

// MARK: Locale convenience initializers and mutators

extension Locale {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Locale.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        code: String? = nil,
        language: String? = nil,
        region: String? = nil
    ) -> Locale {
        return Locale(
            code: code ?? self.code,
            language: language ?? self.language,
            region: region ?? self.region
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

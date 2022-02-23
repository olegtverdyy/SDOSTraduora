//
//  File.swift
//  
//
//  Created by Oleg Tverdyy on 27/5/21.
//

import Foundation
// MARK: - AuthObject
struct AuthObject: Codable {
    var grantType: String = "client_credentials" //Need this value hardoced
    var username: String = "ios@alten.es" //Need this value hardoced
    var password: String = "-------------"
    let clientID: String
    let clientSecret: String

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case clientID = "client_id"
        case clientSecret = "client_secret"
    }
}

// MARK: AuthObject convenience initializers and mutators

extension AuthObject {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AuthObject.self, from: data)
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
        clientID: String? = nil,
        clientSecret: String? = nil
    ) -> AuthObject {
        return AuthObject(
            clientID: clientID ?? self.clientID,
            clientSecret: clientSecret ?? self.clientSecret
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

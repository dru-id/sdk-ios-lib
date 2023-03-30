//
//  Data+Extras.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

extension Data {
#if DEBUG
    func prettyPrint() {
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let dataJSON = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        else { return }
        print(NSString(data: dataJSON, encoding: String.Encoding.utf8.rawValue) ?? "")
    }
#endif
    
    func decoded<T: Decodable>(decoder: JSONDecoder = .apiDecoder) throws -> T {
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

extension JSONDecoder {
    static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}

extension JSONEncoder {
    static var apiEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

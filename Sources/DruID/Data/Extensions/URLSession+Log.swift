//
//  File.swift
//  
//
//  Created on 17/1/23.
//

import Foundation

extension URLSession {
    func send(request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
#if DEBUG
        request.log()
        (urlResponse as? HTTPURLResponse)?.log(data: data)
#endif
        return (data, urlResponse)
    }
}

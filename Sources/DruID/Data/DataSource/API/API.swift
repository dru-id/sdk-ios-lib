//
//  API.swift
//  
//
//  Created on 9/1/23.
//

import Foundation

class API {
    
    enum Method: String { case GET, POST, PUT, DELETE }
    
    private static func requestWithClientToken(
        url: String,
        method: Method,
        body: Encodable? = nil,
        headers: [String : String]? = nil,
        clientAuthManager: ClientAuthManager
    ) async throws -> URLRequest {
        let token = try await clientAuthManager.validToken()
        return try request(url: url, method: method, body: body, headers: headers, clientToken: token)
    }
    
    private static func requestWithAccessToken(
        url: String,
        method: Method,
        body: Encodable? = nil,
        headers: [String : String]? = nil,
        userAuthManager: UserAuthManager
    ) async throws -> URLRequest {
        let token = try await userAuthManager.validToken()
        return try request(url: url, method: method, body: body, headers: headers, userTokenData: token)
    }
    
    private static func request(
        url: String,
        method: Method,
        body: Encodable? = nil,
        headers: [String : String]? = nil,
        clientToken: ClientTokenData? = nil,
        userTokenData: SessionInfoData? = nil
    ) throws -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = ["Accept-Language" : Strings.common_language_code]
        if let headers = headers {
            request.allHTTPHeaderFields = request.allHTTPHeaderFields?.merging(headers, uniquingKeysWith: { (first, _) in first })
        }
        if let token = clientToken?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let token = userTokenData?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            if let urlEncodedBody = body as? UrlEncodedRequest {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpBody = urlEncodedBody.urlComponents.query?.data(using: .utf8)
            } else {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                do {
                    request.httpBody = try JSONEncoder.apiEncoder.encode(body)
                } catch {
                    throw APIError.encoding(error)
                }
            }
        }
        return request
    }
    
    @discardableResult
    static func loadData<T: Encodable>(url: String, method: Method, body: T? = nil) async throws -> Data {
        let request = try request(url: url, method: method, body: body)
        let (data, _) = try await URLSession.shared.send(request: request)
        return data
    }
    
    @discardableResult
    static func loadDataWithClientToken(
        url: String,
        method: Method,
        body: Encodable? = nil,
        headers: [String : String]? = nil,
        clientAuthManager: ClientAuthManager,
        allowRetryClientAuth: Bool = true
    ) async throws -> Data {
        let request = try await requestWithClientToken(url: url, method: method, body: body, headers: headers, clientAuthManager: clientAuthManager)
        let (data, urlResponse) = try await URLSession.shared.send(request: request)
        
        // check the http status code and refresh + retry if we received 401 Unauthorized
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetryClientAuth {
                _ = try await clientAuthManager.refreshToken()
                return try await loadDataWithClientToken(url: url, method: method, body: body, headers: headers, clientAuthManager: clientAuthManager, allowRetryClientAuth: false)
            }
            
            throw APIError.invalidClientToken
        }
        return data
    }
    
    @discardableResult
    static func loadDataWithAccessToken(
        url: String,
        method: Method,
        body: Encodable? = nil,
        headers: [String : String]? = nil,
        userAuthManager: UserAuthManager,
        allowRetryUserAuth: Bool = true
    ) async throws -> Data {
        let request = try await requestWithAccessToken(url: url, method: method, body: body, headers: headers, userAuthManager: userAuthManager)
        let (data, urlResponse) = try await URLSession.shared.send(request: request)
        
        // check the http status code and refresh + retry if we received 401 Unauthorized
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetryUserAuth {
                _ = try await userAuthManager.refreshToken()
                return try await loadDataWithAccessToken(url: url, method: method, body: body, headers: headers, userAuthManager: userAuthManager, allowRetryUserAuth: false)
            }
            
            throw APIError.invalidUserToken
        }
        return data
    }
}

protocol UrlEncodedRequest {
    var urlComponents: URLComponents { get }
}

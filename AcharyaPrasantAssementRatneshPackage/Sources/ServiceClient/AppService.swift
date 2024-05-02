//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import AppService
import ComposableArchitecture
import Foundation
import Moya

/// An API client subclass with a method to accept the custom `AppTarget` and `PathProvider`.
///
/// This uses my own API client (`AppService`) which internally uses `Moya` which is a wrapper around `Alamofire`.
/// `Moya` provides an excellent api to costruct endpoints, plugins etc.
class AppService: Service<AppTarget> {
    var baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
        super.init()
    }
    
    /// This fetches the api from the given Path and method.
    /// - Parameters:
    ///   - path: An path from the endpoint. an conformer of `PathProvider`
    ///   - method: A method for the HTTP Method from Moya wrapper.
    ///   - queries: Additional URL Queries to be included in final url.
    ///   - request: An json or dictionary parameter to be send in http header/body.
    ///   - auth: An authentication state for each endpoint.
    /// - Returns: An Object<T> from the API response.
    public func fetch<T: Codable>(
        path: PathProvider,
        method: Moya.Method,
        queries: [URLQueryItem] = [],
        request: Encodable? = nil,
        auth: AuthorizationType? = .none
    ) async throws -> T {
        var task: Moya.Task = .requestPlain
        if let request {
            if method == .get {
                task = .requestParameters(
                    parameters: request.dictionary,
                    encoding: URLEncoding.default
                )
            } else {
                task = .requestJSONEncodable(request)
            }
        }
        return try await self.fetch(
            AppTarget(
                url: self.baseURL,
                path: path.path,
                method: method,
                task: task,
                queries: queries,
                authType: auth
            ))
    }
}

extension Encodable {
    var dictionary: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        let item = try! JSONSerialization.jsonObject(
            with: data, options: [.mutableContainers, .fragmentsAllowed, .mutableLeaves])
        return item as! [String: Any]
    }
}

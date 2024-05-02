//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Alamofire
import AppService
import Foundation
import Models
import Moya

/// `ServiceTarget` provides all the endpoint used by the working application.
enum ServiceTarget: PathProvider {
    case mediaCoverage
    
    var path: String {
        switch self {
        case .mediaCoverage:
            return "/content/misc/media-coverages"
        }
    }
}

/// Extending the AppService to provide a clear call site from the Feature reducers.
extension AppService {
    func mediaCoverage(limit: Int) async throws -> [MediaCoverage] {
        try await self.fetch(
            path: ServiceTarget.mediaCoverage,
            method: .get,
            queries: [.init(name: "limit", value: "\(limit)")]
        )
    }
}

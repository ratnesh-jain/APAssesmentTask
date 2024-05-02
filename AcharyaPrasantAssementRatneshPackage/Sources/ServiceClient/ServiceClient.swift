//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import ComposableArchitecture
import Foundation
import Models

/// An Dependency client for the Network Services.
@DependencyClient
public struct ServiceClient {
    /// An Media Coverage endpoint that also accept an limit for the response item list.
    public var mediaCoverages: (_ limit: Int) async throws -> [MediaCoverage]
}

extension ServiceClient: DependencyKey {
    
    /// An live value object for application run time.
    public static var liveValue: ServiceClient = {
        let liveService  = AppService(baseURL: URL(
            string: "https://acharyaprashant.org/api/v2"
        )!)
        return .init { limit in
            try await liveService.mediaCoverage(limit: limit)
        }
    }()
}

extension DependencyValues {
    
    /// This can be used from the `@Dependency(\.serviceClient)` property wrapper.
    /// Using this property wrapper, we can easily override it for the Xcode preview and Xcode's Unit test modules.
    public var serviceClient: ServiceClient {
        get { self[ServiceClient.self] }
        set { self[ServiceClient.self] = newValue }
    }
}

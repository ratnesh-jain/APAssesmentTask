//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation

public struct Thumbnail: Codable, Equatable {
    public var id: String
    public var version: Int
    public var domain: String
    public var basePath: String
    public var key: String
    public var qualities: [Int]
    public var aspectRatio: Double
    
    public init(id: String, version: Int, domain: String, basePath: String, key: String, qualities: [Int], aspectRatio: Double) {
        self.id = id
        self.version = version
        self.domain = domain
        self.basePath = basePath
        self.key = key
        self.qualities = qualities
        self.aspectRatio = aspectRatio
    }
}

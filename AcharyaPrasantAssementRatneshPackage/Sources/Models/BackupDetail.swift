//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation

public struct BackupDetail: Codable, Equatable {
    public var pdfLink: String
    public var screenshotURL: String
    
    public init(pdfLink: String, screenshotURL: String) {
        self.pdfLink = pdfLink
        self.screenshotURL = screenshotURL
    }
}

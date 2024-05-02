//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation

public struct MediaCoverage: Codable, Equatable {
    public var id: String
    public var title: String
    public var language: String
    public var thumbnail: Thumbnail
    public var mediaType: Int
    public var coverageURL: String
    public var publishedAt: String
    public var publishedBy: String
    public var backupDetails: BackupDetail?
    
    public init(id: String, title: String, language: String, thumbnail: Thumbnail, mediaType: Int, coverageURL: String, publishedAt: String, publishedBy: String, backupDetails: BackupDetail? =  nil) {
        self.id = id
        self.title = title
        self.language = language
        self.thumbnail = thumbnail
        self.mediaType = mediaType
        self.coverageURL = coverageURL
        self.publishedAt = publishedAt
        self.publishedBy = publishedBy
        self.backupDetails = backupDetails
    }
    
    public var thumbnailURL: URL {
        let quality = self.thumbnail.qualities.min() ?? 10
        let path = self.thumbnail.domain + "/" + self.thumbnail.basePath + "/\(quality)/" + self.thumbnail.key
        guard let url = URL(string: path) else { fatalError() }
        return url
    }
    
    public var highqualityURL: URL {
        let quality = self.thumbnail.qualities.max() ?? 30
        let path = self.thumbnail.domain + "/" + self.thumbnail.basePath + "/\(quality)/" + self.thumbnail.key
        guard let url = URL(string: path) else { fatalError() }
        return url
    }
}

extension MediaCoverage {
    public static var preview: MediaCoverage {
        let data = """
        {"id":"coverage-ad9391","title":"गेस्ट इन द न्यूजरूम: आचार्य प्रशांत ने बताया IIT और IIM से पढ़ने के बाद अध्यात्म ही क्यों चुना?","language":"hindi","thumbnail":{"id":"img-e7fa1a75-40d5-4972-bdb0-3308d3f47410","version":1,"domain":"https://cimg.acharyaprashant.org","basePath":"images/img-e7fa1a75-40d5-4972-bdb0-3308d3f47410","key":"image.jpg","qualities":[10,20,30],"aspectRatio":1},"mediaType":0,"coverageURL":"https://www.thelallantop.com/lallankhas/post/spiritual-speaker-acharya-prashant-in-guest-in-the-newsroom","publishedAt":"2022-08-27","publishedBy":"The Lallantop","backupDetails":{"pdfLink":"https://drive.google.com/file/d/1ZFW40DiLN8y2DSVaJGMLZcfB1c9pf-U2/view?usp=sharing","screenshotURL":"https://cimg.acharyaprashant.org/images/img-1aab37a6-1735-4201-bdf7-d0a532c6266e/40/image.jpg"}}
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(MediaCoverage.self, from: data)
    }
}

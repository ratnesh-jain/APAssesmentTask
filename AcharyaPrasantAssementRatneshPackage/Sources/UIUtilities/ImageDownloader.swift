//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation
import UIKit

/// An Image Download actor.
///
/// This will download the image from the web server and manages the local and filesystem cache.
/// 
/// The main reason to use an `actor` for the `ImageDownloader` is that it can be called for
/// multiple images at the same time and can be called from multiple threads.
///
/// This will prevent the data-race for the local `caches` variable since it can be read-write from
/// multiple threads/queues incorporated by cooperative thread pool used by `Task`.
actor ImageDownloader {
    
    /// `TaskState` allow use to keep track of on-going (in-flight) image downloading task and
    ///  a completed task.
    enum TaskState {
        case inProgress(Task<UIImage, Error>)
        case ready(UIImage)
        
        /// `readyImage` property can be used to directly return the recently downloaded image
        ///  before checking the local file system cache.
        var readyImage: UIImage? {
            guard case let .ready(image) = self else {
                return nil
            }
            return image
        }
    }
    
    /// A common path for the local file system cache directory path.
    private let localBaseURL = URL.documentsDirectory.appending(path: "Images")
    
    /// A local dictionary to store the current download task state with corresponding to the remote url.
    private var caches: [URL: TaskState] = [:]
    
    /// Downloads the image from the remote url.
    /// - Parameter url: Remote server address for the target image.
    /// - Returns: An `UIImage` type if its exist from local cache or from file system cache or by
    /// downloading from the remote server address.
    func download(url: URL) async throws -> UIImage {
        
        // Check for the in-memory cache, this is cheapter then file system
        // reading, incresing the overall app performance.
        if let readyImage = self.caches[url]?.readyImage {
            return readyImage
        }
        
        // If the in-memory cache does not have a downloaded image, then checking
        // for the local file system for the stored image.
        // This is cheapter then the remote server image download.
        if let localImage = self.localImage(for: url) {
            return localImage
        }
        
        // if both in-memory downloaded and file-system cache does not have an entry for the
        // requested image, we check for the if there is an on-going download task available,
        // if yes, we wait for its result and cache them in both in-memory and file-system.
        // else if the image is downloaded but did not store in the file-system, we store it
        // in file-system.
        if let cacheEntry = caches[url] {
            switch cacheEntry {
            case .inProgress(let task):
                let image = try await task.value
                self.caches[url] = .ready(image)
                try self.store(image: image, for: url)
                return image
                
            case .ready(let image):
                try self.store(image: image, for: url)
                return image
            }
        }
        
        // if all cache (in-memory and file-system) and in-flight task does not exists,
        // we create a `Task` to download the image data from the remote server url.
        let task = Task<UIImage, Error> {
            return try await downloadImage(url: url)
        }
        
        // We store the in task in inProgress state to cache.
        self.caches[url] = .inProgress(task)
        
        // We wait for the task's result and store in in-memory and file-system if it is successfull
        // else we clear the in-memory cache entry to nil, this will allow the system to re-try when
        // the image is requested again in future.
        do {
            let image = try await task.value
            self.caches[url] = .ready(image)
            try self.store(image: image, for: url)
            return image
        } catch {
            self.caches[url] = nil
            throw error
        }
    }
    
    /// Cancels the in-flight image download task.
    /// - Parameter url: Remote server address for the image from which we track the current in-flight download task.
    func cancel(url: URL) {
        if let cacheEntry = self.caches[url] {
            if case .inProgress(let task) = cacheEntry {
                task.cancel()
                self.caches[url] = nil
            }
        }
    }
    
    /// Download Image from the Remote server address.
    /// - Parameter url: Remote server address for Image.
    /// - Returns: `UIImage` from the URLSession data task.
    private func downloadImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            struct ImageError: Error {}
            throw ImageError()
        }
    }
    
    /// URL for file-system directory for local cache.
    /// - Parameter url: Remote server address of Image.
    /// - Returns: Local file-system url
    private func localImageURL(for url: URL) -> URL {
        self.localBaseURL.appending(path: String(url.pathComponents.dropFirst(2).joined(separator: "-")))
    }
    
    /// Image from the local file-system.
    /// - Parameter url: Remote server address of Image
    /// - Returns: `UIImage` object from the local file-system path.
    private func localImage(for url: URL) -> UIImage? {
        UIImage(contentsOfFile: self.localImageURL(for: url).path())
    }
    
    /// Stores the downloaded image from the remote server address for image.
    /// - Parameters:
    ///   - image: Downloaded Image.
    ///   - url: Remote server address for Image. Used as a key to get the file-system url.
    private func store(image: UIImage, for url: URL) throws {
        let localURL = localImageURL(for: url)
        try? FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try image.pngData()?.write(to: localImageURL(for: url))
    }
}

/// A Internal single-ton access point for the `ImageDownloader` actor.
enum AppImageDownloader {
    static var downloader = ImageDownloader()
}

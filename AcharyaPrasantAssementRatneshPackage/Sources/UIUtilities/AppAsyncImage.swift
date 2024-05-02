//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation
import SwiftUI

/// An Async Image view using a Application specific caching mechanics.
///
/// This is also handling the in progress and error state using `FetchingView`.
/// In case of the reuse, `.onChange(of: url)` handles it properly.
/// When the view is disappearing it will also cancel the in-flight download task to prevent resources.
public struct AppAsyncImage: View {
    let url: URL
    @State private var fetchingState: FetchingState<UIImage> = .fetching
    
    /// An Async Image view using a Application specific caching mechanics.
    /// - Parameter url: A remote image address.
    public init(url: URL) {
        self.url = url
    }
    
    public var body: some View {
        FetchingView(state: fetchingState) { image in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
        }
        .onChange(of: url, { oldValue, newValue in
            Task {
                await AppImageDownloader.downloader.cancel(url: oldValue)
                await fetchImage(url: newValue)
            }
        })
        .onAppear {
            Task {
                await fetchImage(url: url)
            }
        }
        .onDisappear {
            Task {
                await AppImageDownloader.downloader.cancel(url: url)
            }
        }
    }
    
    /// Downloads the Image from the Remote image address using the `ImageDownloader` actor.
    /// This will also handle the image fetching state via `fetchingState`.
    /// - Parameter url: An Remote Image address.
    private func fetchImage(url: URL) async {
        do {
            self.fetchingState = .fetching
            let image = try await AppImageDownloader.downloader.download(url: url)
            self.fetchingState = .fetched(image)
        } catch {
            self.fetchingState = .error(error.localizedDescription)
        }
    }
}

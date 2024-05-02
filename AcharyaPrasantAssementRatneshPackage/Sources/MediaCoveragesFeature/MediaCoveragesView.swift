//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UIUtilities

/// A Media Converage items listing view.
///
/// This view is controlled by Store of `MediaConveragesFeature` which handles the actions sent by this view.
public struct MediaCoveragesView: View {
    let store: StoreOf<MediaCoveragesFeature>
    
    public init(store: StoreOf<MediaCoveragesFeature>) {
        self.store = store
    }
    
    /// Body displays the loading indicator view as per the `fetchingState` from the store's state.
    /// If the network call is successfull, `mediaCoverages` array is returned to view builder which displays a
    /// scrollView with grid of 3 columns.
    /// If user wants to open the details of single mediaCoverage, we are sending that button action `.didTap` back to store.
    public var body: some View {
        FetchingView(state: store.fetchingState, title: "Media Coverages") { mediaCoverages in
            ScrollView {
                LazyVGrid(columns: .init(repeating: GridItem(), count: 3), alignment: .center, spacing: 8) {
                    ForEach(mediaCoverages, id: \.id) { mediaCoverage in
                        Button {
                            store.send(.didTap(mediaCoverage))
                        } label: {
                            MediaCoverageItemView(item: mediaCoverage)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }
        }
        .onAppear { store.send(.onAppear) }
    }
    
    
    /// An Inline MediaCoverage item view.
    struct MediaCoverageItemView: View {
        let mediaCoverage: MediaCoverage
        
        init(item mediaCoverage: MediaCoverage) {
            self.mediaCoverage = mediaCoverage
        }
        
        var body: some View {
            Rectangle()
                .fill(Color.secondary)
                .aspectRatio(CGFloat(mediaCoverage.thumbnail.aspectRatio), contentMode: .fit)
                .overlay {
                    AppAsyncImage(url: mediaCoverage.thumbnailURL)
                }
                .clipShape(.rect(cornerRadius: 8, style: .continuous))
        }
    }
}

#Preview {
    MediaCoveragesView(store: .init(initialState: .init(), reducer: {
        MediaCoveragesFeature()
    }))
}

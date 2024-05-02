//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 02/05/24.
//

import ComposableArchitecture
import Foundation
import Models
import SwiftUI
import UIUtilities

/// A View to show the details for the `MediaCoverage` item.
///
/// This view is controlled by Store of `MediaCoverageDetailsFeature`.
/// Currently this video does not have any complex actions so just reading the information.
public struct MediaCoverageDetailsView: View {
    let store: StoreOf<MediaCoverageDetailsFeature>
    
    public init(store: StoreOf<MediaCoverageDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            AppAsyncImage(url: store.mediaCoverage.highqualityURL)
                .aspectRatio(store.mediaCoverage.thumbnail.aspectRatio, contentMode: .fit)
            Section {
                Text(store.mediaCoverage.title)
                LabeledContent("Language", value: store.mediaCoverage.language)
                LabeledContent("Published At", value: store.mediaCoverage.publishedAt)
                LabeledContent("Published by", value: store.mediaCoverage.publishedBy)
                
                if let pdfLink = store.mediaCoverage.backupDetails?.pdfLink {
                    LabeledContent {
                        Link(destination: URL(string: pdfLink)!, label: {
                            Text(pdfLink)
                                .foregroundStyle(Color.accentColor)
                                .truncationMode(.middle)
                                .lineLimit(1)
                        })
                    } label: {
                        Text("PDF")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(store.mediaCoverage.title)
    }
}

#Preview {
    NavigationStack {
        MediaCoverageDetailsView(store: .init(initialState: MediaCoverageDetailsFeature.State(mediaCoverage: .preview), reducer: {
            MediaCoverageDetailsFeature()
        }))
    }
}

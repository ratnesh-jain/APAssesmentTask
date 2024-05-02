//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import ComposableArchitecture
import Foundation
import MediaCoverageDetailsFeature
import MediaCoveragesFeature
import SwiftUI

/// App's Main View which is the root view controller of the default app window.
///
/// This view is driven by the Store of `AppFeature` reducer.
/// AppFeature reducer will handle all actions sent by this view to reduce it into appropriate states.
public struct AppView: View {
    let store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: \.path)) {
            MediaCoveragesView(store: store.scope(state: \.root, action: \.root))
                .navigationTitle("Media Coverage")
        } destination: { destinationStore in
            DestinationView(store: destinationStore)
        }
    }
    
    /// Inline Destination View for the NavigationStacks drill down detail views.
    ///
    /// This is inline struct because outside of `AppFeature` it does not have any purpose to read/mutate.
    ///
    /// It fullfil its sole purpose of providing the views for each `AppFeature.Path`'s destination case.
    struct DestinationView: View {
        let store: StoreOf<AppFeature.Path>
        
        var body: some View {
            switch store.case {
            case .mediaCoverageDetails(let mediaCoverageStore):
                MediaCoverageDetailsView(store: mediaCoverageStore)
            }
        }
    }
}

#Preview {
    AppView(store: .init(initialState: .init(), reducer: {
        AppFeature()
    }))
}

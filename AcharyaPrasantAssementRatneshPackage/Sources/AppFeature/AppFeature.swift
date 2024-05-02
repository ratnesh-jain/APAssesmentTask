//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import ComposableArchitecture
import Foundation
import MediaCoveragesFeature
import MediaCoverageDetailsFeature

/// An Root feature for the whole app.
///
/// This feature compose all the child features the application has.
/// Which is `MediaCoveragesFeature` and `MediaCoverageDetailsFeature`.
///
/// The `MediaCoverageDetailsFeature` is accessed via Navigation drill down from the
/// `MediaCoveragesFeature`.
@Reducer
public struct AppFeature {
    
    /// The navigation details reducer to be shown in the navigation drill downs
    ///
    /// Currently we are only showing the media coverage details via composing `MediaCoverageDetailsFeature`.
    @Reducer(state: .equatable, action: .equatable)
    public enum Path {
        case mediaCoverageDetails(MediaCoverageDetailsFeature)
    }
    
    /// State represents the runtime state of the `AppFeature` reducer
    ///
    /// This holds `MediaCoveragesFeature` child feature as the root of the NavigationStack.
    /// It also contains a `path` of type `StackState` which drill downs the navigation from `Path` enum reducer.
    @ObservableState
    public struct State: Equatable {
        var path: StackState<Path.State>
        var root: MediaCoveragesFeature.State
        
        public init(root: MediaCoveragesFeature.State = .init(), path: StackState<Path.State> = .init()) {
            self.root = root
            self.path = path
        }
    }
    
    /// Action that can be reduced to some states of the `AppFeature`.
    ///
    /// This composes the actions from the `StackAction` of `Path` reducer and
    /// `MediaCoveragesFeature` as a root feature.
    public enum Action: Equatable {
        case path(StackActionOf<Path>)
        case root(MediaCoveragesFeature.Action)
    }
    
    public init() {}
    
    /// This body converts the actions to appropriate changes in the state.
    /// 
    /// First we reduce the actions of the root feature which is `MediaCoveragesFeature`
    /// into the `\.root` variable of state with `\.root` action.
    ///
    /// Then we listen from the root's delegate for opening the media coverage details.
    ///
    /// Lastly we composes the actions for the each child state in the navigation stack's `\.path`.
    public var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) {
            MediaCoveragesFeature()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .path:
                return .none
                
            case .root(.delegate(.openDetails(for: let mediaCoverage))):
                state.path.append(.mediaCoverageDetails(.init(mediaCoverage: mediaCoverage)))
                return .none
                
            case .root:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

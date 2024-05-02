//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import ComposableArchitecture
import Foundation
import Models
import ServiceClient
import UIUtilities

/// `MediaCoveragesFeature` handles all the business logic of Media Converages listing.
@Reducer
public struct MediaCoveragesFeature {
    
    /// State handles the media coverages listing and its api calling state using `FetchingState`.
    /// It also accept an API limit.
    /// Limit also can be controlled from the outside since the initialiser also accept as a parameter.
    /// Limit has a default value of 200.
    @ObservableState
    public struct State: Equatable {
        var fetchingState: FetchingState<[MediaCoverage]>
        let limit: Int
        
        public init(fetchingState: FetchingState<[MediaCoverage]> = .fetching, limit: Int = 200) {
            self.fetchingState = fetchingState
            self.limit = limit
        }
    }
    
    /// Declares all the possible actions a system can call also a by user
    /// System events like `onAppear`, api callback like `didReceive` etc.
    /// User driven access like `didTap`.
    ///
    /// This also has a delegate actions to send information to other features i.e. parent feature.
    public enum Action: Equatable {
        case delegate(Delegate)
        case didReceive(FetchingState<[MediaCoverage]>)
        case didTap(MediaCoverage)
        case onAppear
        
        public enum Delegate: Equatable {
            case openDetails(for: MediaCoverage)
        }
    }
    
    public init() {}
    
    /// A Dependency object to perform API calls.
    @Dependency(\.serviceClient) private var service
    
    
    /// Body reduces the sent actions by system or user to appropriate state in this feature reducer.
    ///
    /// For example, `onAppear` will call the api and only if there is no data fetched previously.
    /// When there is a response from the api call this receives `didReceive` action for the result
    /// and it updates the fetchingState.
    ///
    /// When there is a user actions like `didTap`, we send a action via `.delegate` to other observing features.
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .delegate:
                return .none
                
            case .didTap(let mediaCoverage):
                return .send(.delegate(.openDetails(for: mediaCoverage)))
                
            case .didReceive(let fetchingState):
                state.fetchingState = fetchingState
                return .none
                
            case .onAppear:
                guard state.fetchingState.value?.isEmpty ?? true else { return .none }
                let limit = state.limit
                state.fetchingState = .fetching
                return .run { send in
                    let mediaCoverages = try await service.mediaCoverages(limit: limit)
                    await send(.didReceive(.fetched(mediaCoverages)))
                } catch: { error, send in
                    await send(.didReceive(.error(error.localizedDescription)))
                }
            }
        }
    }
}

//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 25/04/24.
//

import Foundation
import SwiftUI

/// An Common state for handling various network activities.
///  
/// This includes in-flight/on-going state as `.fetching`
/// An successful response as `.fetched(T)`
/// An error case as `.error(message)`.
public enum FetchingState<T: Equatable>: Equatable {
    case fetching
    case fetched(T)
    case error(String)
}

/// An set of computed properties for easy access to interval associated values of various possible state.
extension FetchingState {
    public var isFetching: Bool {
        guard case .fetching = self else {
            return false
        }
        return true
    }
    
    public var value: T? {
        guard case .fetched(let t) = self else {
            return nil
        }
        return t
    }
    
    public var error: String? {
        guard case .error(let message) = self else {
            return nil
        }
        return message
    }
}

/// An View to handle various remote activity state via `FetchingState`.
public struct FetchingView<T: Equatable, Content: View>: View {
    let state: FetchingState<T>
    let title: String?
    @ViewBuilder var content: (T) -> Content
    
    public init(state: FetchingState<T>, title: String? = nil, @ViewBuilder content: @escaping (T) -> Content) {
        self.state = state
        self.title = title
        self.content = content
    }
    
    public var body: some View {
        switch state {
        case .fetching:
            VStack {
                ProgressView()
                Text("Fetching \(title ?? "") ...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .fetched(let t):
            content(t)
            
        case .error(let message):
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.yellow)
                Text(message)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

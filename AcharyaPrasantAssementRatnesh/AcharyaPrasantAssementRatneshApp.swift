//
//  AcharyaPrasantAssementRatneshApp.swift
//  AcharyaPrasantAssementRatnesh
//
//  Created by Ratnesh Jain on 25/04/24.
//

import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct AcharyaPrasantAssementRatneshApp: App {
    let store: StoreOf<AppFeature> = .init(initialState: .init()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}

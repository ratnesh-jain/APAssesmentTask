//
//  File.swift
//  
//
//  Created by Ratnesh Jain on 02/05/24.
//

import ComposableArchitecture
import Foundation
import Models
import UIUtilities

/// A Media Coverage Details feature for showing the details about the single `MediaCoverage` item.
///
/// This reducer is does not have any complex actions so using the macro generated empty actions and body.
///
/// Since we need to iniailise the `MediaCoverageDetailsFeature` outside this feature module,
/// we are declaring an implicit public initializer.
@Reducer
public struct MediaCoverageDetailsFeature {
    @ObservableState
    public struct State: Equatable {
        var mediaCoverage: Models.MediaCoverage
        
        public init(mediaCoverage: Models.MediaCoverage) {
            self.mediaCoverage = mediaCoverage
        }
    }
    
    public init() {}
}

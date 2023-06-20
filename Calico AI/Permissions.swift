//
//  Permissions.swift
//  Calico AI
//
//  Created by Ben Pearman on 2023-06-20.
//

import Foundation
import SwiftUI

class UserEntitlements {
    let Trial = PermissionsStruct(
        title: "Calico Trial",
        maxTokens: 100,
        maxResolution: 720,
        maxGenerations: 1,
        accentColour: [.orange]
    )
   
    let Apprentice = PermissionsStruct(
        title: "Calico Apprentice",
        maxTokens: 1000,
        maxResolution: 720,
        maxGenerations: 1,
        accentColour: [.primary]
    )
    
    let Sorcerer = PermissionsStruct(
        title: "Calico Apprentice",
        maxTokens: 6500,
        maxResolution: 1024,
        maxGenerations: 2,
        accentColour: [.mint]
    )
    
    let Illusionist = PermissionsStruct(
        title: "Calico Illusionist",
        maxTokens: 0,
        maxResolution: 2048,
        maxGenerations: 4,
        accentColour: [.cyan, .blue]
    )
    
}


struct PermissionsStruct {
    let title: String
    let maxTokens: Int
    let maxResolution: Int
    let maxGenerations: Int
    let accentColour: [Color]
}

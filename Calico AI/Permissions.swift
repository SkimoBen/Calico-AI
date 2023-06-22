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
        title: "Free Trial",
        maxTokens: 100,
        maxResolution: 720,
        maxGenerations: 1,
        accentColour: [.orange],
        cashPicName: "cashWingOrange",
        maxSamples: 30
        
    )
   
    let Apprentice = PermissionsStruct(
        title: "Apprentice",
        maxTokens: 1000,
        maxResolution: 720,
        maxGenerations: 1,
        accentColour: [.purple, .pink],
        cashPicName: "cashWingPink",
        maxSamples: 50
    )
    
    let Sorcerer = PermissionsStruct(
        title: "Sorcerer",
        maxTokens: 6500,
        maxResolution: 1024,
        maxGenerations: 2,
        accentColour: [.mint, .cyan],
        cashPicName: "cashWingMint",
        maxSamples: 75
    )
    
    let Illusionist = PermissionsStruct(
        title: "Illusionist",
        maxTokens: 0,
        maxResolution: 2048,
        maxGenerations: 4,
        accentColour: [.cyan, .blue],
        cashPicName: "cashWingBlue",
        maxSamples: 100
    )
    
}


struct PermissionsStruct {
    let title: String
    let maxTokens: Int
    let maxResolution: Int
    let maxGenerations: Int
    let accentColour: [Color]
    let cashPicName: String
    let maxSamples: Int
}

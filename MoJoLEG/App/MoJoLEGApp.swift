//
//  MoJoLEGApp.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftData
import SwiftUI

@main
struct MoJoLEGApp: App {
    var body: some Scene {
        WindowGroup {
            DevView()
        }
        .modelContainer(
            for: [SceneBreakdown.self, CharacterItem.self, PropItem.self],
            inMemory: true
        )
    }
}

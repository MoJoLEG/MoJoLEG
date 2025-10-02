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
            //      ChooseScenarioView()
            DevView()
        }
        .modelContainer(
            for: [Scenario.self, Prop.self, ScenarioScene.self],
            inMemory: false
        )
    }
}

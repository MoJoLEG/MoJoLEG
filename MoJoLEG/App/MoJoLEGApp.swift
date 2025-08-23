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
        ChooseScenarioView()
    }
    .modelContainer(
      for: [Scenario.self, Prop.self],
      inMemory: true
    )
  }
}

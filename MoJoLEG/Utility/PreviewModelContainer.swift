//
//  PreviewModelContainer.swift
//  MoJoLEG
//
//  Created by 정희균 on 10/3/25.
//

import SwiftData
import SwiftUI

struct PreviewModelContainer: PreviewModifier {
  static func makeSharedContext() async throws -> ModelContainer {
    let configurations = ModelConfiguration(
      isStoredInMemoryOnly: true,
      cloudKitDatabase: .none
    )

    let container = try ModelContainer(
      for: Scenario.self,
      Prop.self,
      ScenarioScene.self,
      configurations: configurations
    )

    container.mainContext.insert(Scenario.sample)

    return container
  }

  func body(content: Content, context: ModelContainer) -> some View {
    content
      .modelContainer(context)
  }
}

//
//  SwiftDataView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftData
import SwiftUI

struct SwiftDataView: View {
  @Environment(\.modelContext) private var context

  @Query(sort: \Scenario.updatedAt, order: .forward)
  private var scenarios: [Scenario]

  var body: some View {
    List {
      Button("Add") {
        let scenario = Scenario(
          id: UUID(),
          title: "테스트",
          scenes: [],
          props: [],
          createdAt: Date(),
          updatedAt: Date()
        )

        context.insert(scenario)

        try? context.save()
      }
      ForEach(scenarios) { scenario in
        Text(String(describing: scenario))
          .swipeActions {
            Button("Delete", role: .destructive) {
              context.delete(scenario)

              try? context.save()
            }
          }
      }
    }
  }
}

#Preview {
  SwiftDataView()
    .modelContainer(
      for: [Scenario.self, Prop.self],
      inMemory: false
    )
}

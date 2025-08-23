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

    @Query(sort: \SceneBreakdown.sceneNumber, order: .forward)
    private var scenes: [SceneBreakdown]

    var body: some View {
        List {
            Button("Add") {
                let scene = SceneBreakdown(
                    sceneNumber: "\(Int.random(in: 1..<10))",
                    ioType: "실내",
                    timeOfDay: "D",
                    sceneSummary: "레몬이 커피를 마신다."
                )

                context.insert(scene)
                
                try? context.save()
            }
            ForEach(scenes) { scene in
                Text(String(describing: scene))
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            context.delete(scene)
                            
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
            for: [SceneBreakdown.self, CharacterItem.self, PropItem.self],
            inMemory: false
        )
}

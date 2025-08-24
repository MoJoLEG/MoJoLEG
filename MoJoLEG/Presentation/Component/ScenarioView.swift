//
//  ScenarioView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct ScenarioView: View {
  let scenes: [ScenarioScene]
  @Binding var selectedScene: ScenarioScene?

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 36) {
          ForEach(
            scenes.sorted(by: { $0.order < $1.order }),
            id: \.self
          ) { scene in
            Text(scene.content)
              .id(scene.id)
              .foregroundStyle(.gray900)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .defaultScrollAnchor(.top)
      .padding(32)
      .background {
        RoundedRectangle(cornerRadius: 24)
          .fill(.white)
          .shadow(color: .black.opacity(0.25), radius: 20, x: 4, y: 4)
      }
      .onChange(of: selectedScene) { oldValue, newValue in
        if let newValue {
          proxy.scrollTo(newValue.id)
        }
      }
    }
  }
}

#Preview {
  ScenarioView(scenes: [], selectedScene: .constant(nil))
}

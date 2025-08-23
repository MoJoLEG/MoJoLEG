//
//  ScenarioView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct ScenarioView: View {
  let scenes: [String]

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(scenes, id: \.self) { scene in
          Text(scene)
        }
      }
      .padding(32)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(.white, in: RoundedRectangle(cornerRadius: 24))
    .shadow(color: .black.opacity(0.25), radius: 20, x: 4, y: 4)
  }
}

#Preview {
  ScenarioView(scenes: ["#1 Start", "#2 End"])
}

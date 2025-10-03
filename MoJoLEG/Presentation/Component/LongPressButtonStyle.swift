//
//  LongPressButtonStyle.swift
//  MoJoLEG
//
//  Created by 정희균 on 10/3/25.
//

import SwiftUI

struct LongPressButtonStyle: PrimitiveButtonStyle {
  let longPressAction: () -> Void

  @State private var isPressed = false

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(isPressed ? 0.9 : 1.0)
      .onTapGesture {
        configuration.trigger()
      }
      .onLongPressGesture {
        self.longPressAction()
      } onPressingChanged: { pressing in
        withAnimation(.spring(duration: 0.3)) {
          self.isPressed = pressing
        }
      }
  }
}

#Preview {
  Button(action: { print("Pressed") }) {
    Label("Press Me", systemImage: "star")
  }
  .buttonStyle(
    LongPressButtonStyle {
      print("Long Pressed")
    }
  )
}

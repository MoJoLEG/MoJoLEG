//
//  ScenarioButton.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct ScenarioButton: View {
  let title: String
  let date: String
  @Binding var isFavorite: Bool
  let action: () -> Void
  let longPressAction: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      VStack(spacing: 36) {
        Image("Box")
          .resizable()
          .scaledToFit()
        VStack(spacing: 6) {
          HStack {
            Button {
              isFavorite.toggle()
            } label: {
              Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .red : .gray)
            }
            Text(title)
              .font(.system(size: 20, weight: .semibold))
              .foregroundStyle(.skyBlue)
              .lineLimit(1)
              .minimumScaleFactor(0.8)
          }
          Text(date)
            .font(.system(size: 14))
            .foregroundStyle(.gray500)
        }
      }
    }
    .buttonStyle(
      LongPressButtonStyle {
        longPressAction()
      }
    )
  }
}

#Preview {
  HStack {
    ScenarioButton(
      title: "채집자",
      date: "오늘 오전 8:23",
      isFavorite: .constant(false)
    ) {
    } longPressAction: {
    }
    ScenarioButton(
      title: "채집자",
      date: "오늘 오전 8:23",
      isFavorite: .constant(true)
    ) {
    } longPressAction: {
    }
  }
}

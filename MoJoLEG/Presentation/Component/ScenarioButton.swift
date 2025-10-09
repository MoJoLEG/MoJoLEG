//
//  ScenarioButton.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct ScenarioButton: View {
  @Binding var title: String
  let date: String
  @Binding var isFavorite: Bool
  @Binding var isEditMode: Bool
  let action: () -> Void

  var body: some View {
    Button {
      action()
    } label: {
      VStack(spacing: 36) {
        icon

        ZStack {
          detail
            .opacity(isEditMode ? 0.0 : 1.0)

          if isEditMode {
            titleEditor
          }
        }
        .animation(.default, value: isEditMode)
      }
    }
  }

  private var icon: some View {
    Image("Box")
      .resizable()
      .scaledToFit()
  }

  private var detail: some View {
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

  private var titleEditor: some View {
    HStack {
      TextField("제목을 입력해주세요", text: $title)
        .multilineTextAlignment(.leading)
        .onSubmit {
          isEditMode = false
        }
      if !title.isEmpty {
        Button("모두 지우기", systemImage: "xmark.circle.fill") {
          title = ""
        }
        .labelStyle(.iconOnly)
      }
    }
    .padding(10)
    .background(.gray300, in: Capsule())
  }
}

#Preview {
  HStack {
    ScenarioButton(
      title: .constant("채집자"),
      date: "오늘 오전 8:23",
      isFavorite: .constant(false),
      isEditMode: .constant(false),
    ) {}
    ScenarioButton(
      title: .constant("채집자"),
      date: "오늘 오전 8:23",
      isFavorite: .constant(true),
      isEditMode: .constant(true),
    ) {}
  }
}

//
//  ScenarioButton.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct ScenarioButton: View {
  let scenario: Scenario
  @FocusState.Binding var focused: UUID?
  let action: () -> Void

  @State private var title: String = ""

  var body: some View {
    Button {
      action()
    } label: {
      VStack(spacing: 36) {
        icon

        ZStack {
          detail
            .opacity(focused == scenario.id ? 0.0 : 1.0)
          titleEditor
            .opacity(focused == scenario.id ? 1.0 : 0.0)
        }
        .animation(.default, value: focused)
      }
    }
  }

  private var icon: some View {
    Image(.box)
      .resizable()
      .scaledToFit()
  }

  private var detail: some View {
    let title = scenario.title
    let date = scenario.updatedAt.formatted(
      date: .numeric,
      time: .omitted
    )

    return VStack(spacing: 6) {
      HStack {
        Button {
          scenario.isFavorite.toggle()
        } label: {
          Image(systemName: scenario.isFavorite ? "star.fill" : "star")
            .foregroundColor(scenario.isFavorite ? .red : .gray)
        }
        Text(title)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(.skyBlue)
          .lineLimit(1)
          .minimumScaleFactor(0.8)
          .onTapGesture {
            focused = scenario.id
          }
      }
      Text(date)
        .font(.system(size: 14))
        .foregroundStyle(.gray500)
    }
  }

  private var titleEditor: some View {
    HStack {
      TextField("제목을 입력해주세요", text: $title)
        .foregroundStyle(.black)
        .multilineTextAlignment(.leading)
        .focused($focused, equals: scenario.id)
        .onSubmit {
          focused = nil
        }
        .onChange(of: focused) { oldValue, newValue in
          if newValue == scenario.id {
            title = scenario.title
          } else {
            if title.isEmpty == false {
              scenario.title = title
            }
          }
        }
      if title.isEmpty == false {
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
  @Previewable @FocusState var focused: UUID?

  HStack {
    ScenarioButton(
      scenario: .sample,
      focused: $focused,
    ) {}
    ScenarioButton(
      scenario: .sample,
      focused: $focused,
    ) {}
  }
}

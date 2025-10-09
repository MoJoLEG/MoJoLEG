//
//  LoadingView.swift
//  MoJoLEG
//
//  Created by 나현흠 on 8/23/25.
//

import Lottie
import SwiftUI

struct LoadingView: View {
  private enum LoadingText {
    case first
    case second
    case third

    var toString: String {
      switch self {
      case .first:
        String(localized: "LoadingText1")
      case .second:
        String(localized: "LoadingText2")
      case .third:
        String(localized: "LoadingText3")
      }
    }

    var next: LoadingText {
      switch self {
      case .first:
        .second
      case .second:
        .third
      case .third:
        .first
      }
    }
  }

  @State private var loadingText: LoadingText = .first
  @State private var isShowingText: Bool = true

  var body: some View {
    ZStack {
      Color.gray100
        .ignoresSafeArea()

      VStack(spacing: 32) {
        LottieView(animation: .named("loading"))
          .playing()
          .looping()
          .frame(width: 400, height: 400)

        Text(loadingText.toString)
          .foregroundStyle(.gray900)
          .font(.system(size: 30, weight: .bold))
          .blur(radius: isShowingText ? 0.0 : 16.0)
          .opacity(isShowingText ? 1.0 : 0.0)
          .task {
            while true {
              try? await Task.sleep(for: .seconds(10))
              withAnimation(.easeOut) {
                isShowingText = false
              } completion: {
                loadingText = loadingText.next
                withAnimation(.easeIn) {
                  isShowingText = true
                }
              }
            }
          }
      }
    }
  }
}

#Preview {
  LoadingView()
}

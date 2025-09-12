//
//  LoadingView.swift
//  MoJoLEG
//
//  Created by 나현흠 on 8/23/25.
//

import Lottie
import SwiftUI

struct LoadingView: View {
  @State private var currentIndex: Int = 0
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

        Text(localizedTexts[currentIndex])
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
                if currentIndex == 2 {
                  currentIndex = 0
                } else {
                  currentIndex += 1
                }
                withAnimation(.easeIn) {
                  isShowingText = true
                }
              }
            }
          }
      }
    }
  }

  private let loadingTexts: [String: [String]] = [
    "ko": [
      "시나리오를 분석 중입니다.",
      "씬 단위로 필요한 소품을 정리하고 있습니다.",
      "최종 소품리스트를 생성하고 있으니 잠시만 기다려주세요.",
    ],
    "en": [
      "Analyzing the scenario.",
      "Organizing necessary props by scene.",
      "Finalizing the props list, please wait a moment.",
    ],
  ]

  private var localizedTexts: [String] {
    let langCode = Locale.current.language.languageCode?.identifier ?? "ko"
    return loadingTexts[langCode] ?? loadingTexts["ko"]!
  }
}

#Preview {
  LoadingView()
}

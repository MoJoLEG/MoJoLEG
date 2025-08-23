//
//  LoadingView.swift
//  MoJoLEG
//
//  Created by 나현흠 on 8/23/25.
//

import Combine
import Lottie
import SwiftUI

private let loadingText: [String] = [
  "시나리오를 분석 중입니다.",
  "씬 단위로 필요한 소품을 정리하고 있습니다.",
  "최종 소품리스트를 생성하고 있으니 잠시만 기다려주세요.",
]

struct LoadingView: View {

  @State private var currentText: String = loadingText[0]
  @State private var currentIndex: Int = 0

  let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

  var body: some View {
    ZStack {
      Color.gray100
        .ignoresSafeArea()

      VStack(spacing: 32) {
        LottieView(animation: .named("loading"))
          .playing()
          .looping()
          .frame(width: 400, height: 400)

        Text(loadingText[currentIndex])
          .foregroundStyle(.gray900)
          .font(.system(size: 30, weight: .bold))
      }
    }
    .onReceive(timer) { _ in
      if currentIndex == 2 {
        currentIndex = 0
      } else {
        currentIndex += 1
      }
    }
  }
}

#Preview {
  LoadingView()
}

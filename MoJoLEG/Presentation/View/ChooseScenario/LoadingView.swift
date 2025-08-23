//
//  LoadingView.swift
//  MoJoLEG
//
//  Created by 나현흠 on 8/23/25.
//

import SwiftUI
import Combine

private let loadingText : [String] = [
    "시나리오를 분석 중입니다.",
    "씬 단위로 필요한 소품을 정리하고 있습니다.",
    "최종 소품리스트를 생성하고 있으니 잠시만 기다려주세요."
]


struct LoadingView: View {
    
    @State private var currentText: String = loadingText[0]
    @State private var currentIndex: Int = 0
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            LottieView(animationName: "loading")
                .padding(.bottom, 30)
            Text(loadingText[currentIndex])
                .padding(.top, 800)
                .font(.system(size: 30, weight: .bold, design: .default))
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

//
//  NavigationManager.swift
//  MoJoLEG
//
//  Created by 나현흠 on 8/24/25.
//

import SwiftUI
import Combine

// View의 종류에 대한 Enum
enum ViewType: Hashable {
    case Loading
    case PropList
}

// MARK: 화면 전환을 관리하는 객체
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    // 화면 전환하기
    func navigate(to destination: ViewType) {
        path.append(destination)
    }
    
    // 루트로 이동하기
    func poptoRoot() {
        path.removeLast(path.count)
    }
    
    // 뒤로가기
    func pop() {
        path.removeLast()
    }
  
  @ViewBuilder
  func view(_ viewType: ViewType) -> some View {
    switch viewType {
    case .Loading:
      LoadingView()
        .toolbarVisibility(.hidden, for: .navigationBar)
    case .PropList:
      PropListView(scenario: .sample)
    }
  }
}

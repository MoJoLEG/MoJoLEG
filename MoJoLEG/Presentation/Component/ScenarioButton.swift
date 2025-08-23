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
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 36) {
                Image(isFavorite ? .favoriteBox : .box)
                    .resizable()
                    .scaledToFit()
                VStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.skyBlue)
                    Text(date)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray500)
                }
            }
        }
    }
}

#Preview {
    HStack {
        ScenarioButton(title: "채집자", date: "오늘 오전 8:23", isFavorite: false) {}
        ScenarioButton(title: "채집자", date: "오늘 오전 8:23", isFavorite: true) {}
    }
}

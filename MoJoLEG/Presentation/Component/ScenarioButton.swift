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
                        ZStack {
                            Button {
                                isFavorite.toggle()
                            } label: {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundColor(isFavorite ? .red : .gray)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        Text(title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.skyBlue)
                    }
                    Text(date)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray500)
                }
            }
        }
    }
}

#Preview {
    @State var fav1 = false
    @State var fav2 = true

    return HStack {
        ScenarioButton(title: "채집자", date: "오늘 오전 8:23", isFavorite: $fav1) {}
        ScenarioButton(title: "채집자", date: "오늘 오전 8:23", isFavorite: $fav2) {}
    }
}

//
//  CaseTabButton.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct CaseTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(
                    isSelected ? .gray200 : .gray900
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(.primaryYellow)
                    } else {
                        Capsule()
                            .strokeBorder(.primaryYellow)
                    }
                }
        }
    }
}

#Preview {
    VStack {
        CaseTabButton(title: "전체보기", isSelected: true) {}
        CaseTabButton(title: "즐겨찾기", isSelected: false) {}
    }
}

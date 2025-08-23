//
//  SideTabView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct SideTabView: View {
  let tabs: [String]
  @Binding var selectedTab: String
  var dismiss: (() -> Void)? = nil

  @Namespace private var namespace

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("로고")
          .font(.title)
          .bold()
        
        Spacer()
        
        Button {
          dismiss?()
        } label: {
          Image(systemName: "xmark")
        }
      }
      .padding(.vertical)
      
      ForEach(tabs, id: \.self) { tab in
        Text(tab)
          .padding(16)
          .background {
            if tab == selectedTab {
              Capsule()
                .fill(.regularMaterial)
                .matchedGeometryEffect(
                  id: "BackgroundCapsule",
                  in: namespace
                )
            }
          }
          .onTapGesture {
            withAnimation {
              selectedTab = tab
            }
          }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background {
      RoundedRectangle(cornerRadius: 24)
        .fill(.white)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
    }
  }
}

#Preview {
  @Previewable @State var selectedTab: String = "채집자"

  SideTabView(
    tabs: [
      "채집자",
      "S#1. 산의 아지트 안, 낮",
      "S#2. 황무지, 낮",
      "S#3. 해변가, 해질녘",
    ],
    selectedTab: $selectedTab
  )
}

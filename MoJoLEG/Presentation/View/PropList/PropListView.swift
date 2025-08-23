//
//  PropListView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct PropListView: View {
  var body: some View {
    ZStack {
      background
      
      VStack {
        ZStack {
          HStack {
            Button {
              
            } label: {
              Image(systemName: "sidebar.left")
                .foregroundStyle(.primaryYellow)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
              HStack {
                Toggle(isOn: .constant(false)) {}
                  .tint(.primaryYellow)
                  .frame(maxWidth: 72)
                Text("시나리오 보기")
                  .padding(.horizontal, 10)
              }
              ShareLink(item: .applicationSupportDirectory)
                .labelStyle(.iconOnly)
                .foregroundStyle(.primaryYellow)
            }
          }
          
          Text("채집자")
            .font(.system(size: 40, weight: .semibold))
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)
        
        HStack {
          HStack {
            Text("리스트뷰")
              .foregroundStyle(.white)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
              .background(.primaryYellow, in: Capsule())
            Text("갤러리뷰")
              .foregroundStyle(.gray900)
              .padding(.vertical, 8)
              .padding(.horizontal, 16)
          }
          .padding(4)
          .background(.gray200, in: Capsule())
          
          Spacer()
          
          Image(systemName: "magnifyingglass")
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)
        
        ScrollView([.horizontal, .vertical]) {
          LazyVStack(pinnedViews: .sectionHeaders) {
            Section {
              ForEach(0..<100) { index in
                PropListRowView(prop: .sample)
              }
            } header: {
              header
            }
          }
          .padding(.horizontal, 40)
        }
        .defaultScrollAnchor(.topLeading)
      }
    }
  }
  
  private var background: some View {
      Color.gray100
        .ignoresSafeArea()
  }
  
  private var header: some View {
    HStack(spacing: 24) {
      Image(systemName: "checkmark.circle.fill")
        .frame(minWidth: 16)
      Text("S#")
        .frame(minWidth: 24)
      Text("구분")
        .frame(minWidth: 54)
      Text("이름")
        .frame(minWidth: 80)
      Text("장소")
        .frame(minWidth: 72)
      Text("I/E")
        .frame(minWidth: 24)
      Text("등장인물")
        .frame(minWidth: 96)
      Text("비고")
        .frame(minWidth: 160)
      Text("개수")
        .frame(minWidth: 32)
      Text("구매가")
        .frame(minWidth: 96)
      Text("레퍼런스 이미지")
        .frame(minWidth: 160)
      Text("담당팀")
        .frame(minWidth: 128)
    }
    .font(.system(size: 17, weight: .semibold))
    .padding(.vertical, 10)
    .padding(.horizontal, 28)
    .frame(minWidth: 1280)
    .background(.white, in: RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  PropListView()
}

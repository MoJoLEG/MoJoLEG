//
//  PropListRowView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct PropListRowView: View {
  let prop: Prop
  
  var body: some View {
    HStack(spacing: 24) {
      Image(systemName: prop.isCompleted ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(prop.isCompleted ? .primaryYellow : .gray900)
        .frame(minWidth: 16)
      Text("\(prop.sceneNumber)")
        .frame(minWidth: 24)
      Text("\(prop.category.toString)")
        .frame(minWidth: 54)
      Text("\(prop.name)")
        .frame(minWidth: 80)
      Text("\(prop.location)")
        .frame(minWidth: 72)
      Text("\(prop.environment.toString)")
        .frame(minWidth: 24)
      Text("\(prop.character)")
        .frame(minWidth: 96)
      Text("\(prop.note)")
        .frame(minWidth: 160)
      if let count = prop.count {
        Text("\(count)")
          .frame(minWidth: 32)
      } else {
        Text("n/a")
          .frame(minWidth: 32)
      }
      if let price = prop.price {
        Text("\(price)")
          .frame(minWidth: 96)
      } else {
        Text("n/a")
          .frame(minWidth: 96)
      }
      if let data = prop.referenceImage, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(minWidth: 160)
      } else {
        Text("n/a")
          .frame(minWidth: 160)
      }
      if let responsibleTeam = prop.responsibleTeam {
        Text("\(responsibleTeam)")
          .frame(minWidth: 128)
      } else {
        Text("n/a")
          .frame(minWidth: 128)
      }
    }
    .foregroundStyle(prop.isCompleted ? .gray600 : .gray900)
    .padding(.vertical, 20)
    .padding(.horizontal, 28)
    .frame(minWidth: 1280)
    .background(prop.isCompleted ? .gray300 : .white, in: RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  let prop = Prop.sample
  prop.isCompleted = true
  
  return VStack {
    PropListRowView(prop: prop)
    PropListRowView(prop: .sample)
  }
}

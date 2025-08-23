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
      Button {
        prop.isCompleted.toggle()
      } label: {
        Image(systemName: prop.isCompleted ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(prop.isCompleted ? .primaryYellow : .gray900)
          .frame(width: 16)
      }
      Text("\(prop.sceneNumber)")
        .lineLimit(1)
        .frame(width: 24)
      Text("\(prop.category.toString)")
        .lineLimit(1)
        .frame(width: 54)
        .background(prop.category.toHighlight)
      Text("\(prop.name)")
        .lineLimit(1)
        .frame(width: 80)
      Text("\(prop.majorLocation)/\(prop.minorLocation ?? "n/a")")
        .lineLimit(1)
        .frame(width: 72)
      Text("\(prop.environment.toString)")
        .lineLimit(1)
        .frame(width: 24)
      Text("\(prop.character ?? "")")
        .lineLimit(1)
        .frame(width: 96)
      Text("\(prop.note)")
        .lineLimit(1)
        .frame(width: 160)
      if let count = prop.count {
        Text("\(count)")
          .lineLimit(1)
          .frame(width: 32)
      } else {
        Text("n/a")
          .lineLimit(1)
          .frame(width: 32)
      }
      if let price = prop.price {
        Text("\(price)")
          .lineLimit(1)
          .frame(width: 96)
      } else {
        Text("n/a")
          .lineLimit(1)
          .frame(width: 96)
      }
      if let data = prop.referenceImage, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
          .frame(width: 160)
      } else {
        Text("n/a")
          .lineLimit(1)
          .frame(width: 160)
      }
      if let responsibleTeam = prop.responsibleTeam {
        Text("\(responsibleTeam)")
          .lineLimit(1)
          .frame(width: 128)
      } else {
        Text("n/a")
          .lineLimit(1)
          .frame(width: 128)
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

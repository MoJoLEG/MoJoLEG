//
//  GalleryView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import SwiftUI

struct GalleryView: View {
  let props: [Prop]

  var body: some View {
    ScrollView {
      LazyVGrid(
        columns: Array(repeating: GridItem(spacing: 32), count: 4),
        spacing: 40
      ) {
        ForEach(props) { prop in
          VStack(spacing: 0) {
            ZStack {
              Color.gray300

              VStack {
                HStack {
                  Text("S#\(prop.sceneNumber)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.gray900)
                  Spacer()
                  Image(
                    systemName: prop.isCompleted
                      ? "checkmark.circle.fill" : "circle"
                  )
                  .foregroundStyle(prop.isCompleted ? .primaryYellow : .gray900)
                  .frame(width: 16)
                }
                Spacer()
              }
              .padding(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ZStack {
              Color.white

              VStack(spacing: 20) {
                HStack {
                  Text(prop.name)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.gray900)
                    .lineLimit(1)

                  Spacer()

                  Text("\(prop.category.toString)")
                    .foregroundStyle(.gray900)
                    .lineLimit(1)
                    .frame(width: 54)
                    .background(prop.category.toHighlight)
                }

                LazyVGrid(
                  columns: [
                    GridItem(.flexible(minimum: 96, maximum: 96)), GridItem(),
                  ],
                  spacing: 8
                ) {
                  Text("장소")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Text("\(prop.majorLocation)/\(prop.minorLocation ?? "n/a")")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Text("등장인물")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Text(prop.character ?? "n/a")
                    .font(.system(size: 15))
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                  Text("비고")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.gray900)
                    .frame(
                      maxWidth: .infinity,
                      maxHeight: .infinity,
                      alignment: .topLeading
                    )
                  Text(prop.note)
                    .font(.system(size: 15))
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity, alignment: .top)
              }
              .padding(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .frame(height: 360)
          .clipShape(RoundedRectangle(cornerRadius: 20))
        }
      }
      .padding(40)
    }
  }
}

#Preview {
  GalleryView(props: [.sample])
}

//
//  PropsGalleryView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import PhotosUI
import SwiftUI

struct PropsGalleryView: View {
  let scenario: Scenario
  let props: [Prop]

  @Binding var selectedSceneNumber: Int?
  @Binding var selectedCategory: PropCategory?
  @Binding var selectedMajorLocation: String?
  @Binding var selectedCharacter: String?

  private let backgroundColor: Color = Color.gray100

  var body: some View {
    ScrollView {
      LazyVStack(pinnedViews: .sectionHeaders) {
        Section {
          LazyVGrid(
            columns: Array(repeating: GridItem(spacing: 32), count: 4),
            spacing: 40
          ) {
            ForEach(props) { prop in
              PropCardView(prop: prop)
            }
          }
          .safeAreaPadding(.horizontal, 40)
        } header: {
          header
        }
      }
    }
    .background(
      backgroundColor
    )
  }

  private var header: some View {
    HStack {
      HStack(spacing: 32) {
        headerSceneNumber
        headerPropCategory
        headerMajorLocation
        headerCharacter
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 20)
      .background(
        Capsule()
          .fill(Color.white)
      )

      Spacer()
    }
    .font(.system(size: 17, weight: .semibold))
    .foregroundStyle(.gray900)
    .padding(.bottom, 16)
    .padding(.horizontal, 40)
    .background {
      VariableBlurView()

      LinearGradient(
        colors: [backgroundColor, Color.clear],
        startPoint: .top,
        endPoint: .bottom
      )
    }
  }

  private var headerSceneNumber: some View {
    Menu {
      Picker("씬 번호", selection: $selectedSceneNumber) {
        Text("S#")
          .tag(nil as Int?)
        ForEach(
          scenario.scenes.compactMap { $0.sceneNumber }.sorted(),
          id: \.self
        ) { sceneNumber in
          Text(sceneNumber.formatted())
            .tag(sceneNumber)
        }
      }
    } label: {
      HStack {
        Text(selectedSceneNumber?.formatted() ?? "S#")
          .lineLimit(1)
          .foregroundStyle(
            selectedSceneNumber != nil ? .primaryYellow : .gray900
          )
        Image(systemName: "chevron.up.chevron.down")
      }
    }
  }

  private var headerPropCategory: some View {
    Menu {
      Picker("구분", selection: $selectedCategory) {
        Text("구분")
          .tag(nil as PropCategory?)
        ForEach(PropCategory.allCases, id: \.self) { category in
          Text(category.toString)
            .tag(category)
        }
      }
    } label: {
      HStack {
        Text(selectedCategory?.toString ?? "구분")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedCategory != nil ? .primaryYellow : .gray900)
    }
  }

  private var headerMajorLocation: some View {
    Menu {
      Picker("장소", selection: $selectedMajorLocation) {
        Text("장소")
          .tag(nil as String?)
        ForEach(
          Set(scenario.props.compactMap({ $0.majorLocation })).sorted(),
          id: \.self
        ) { majorLocation in
          Text(majorLocation)
            .tag(majorLocation)
        }
      }
    } label: {
      HStack {
        Text(selectedMajorLocation ?? "장소")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedMajorLocation != nil ? .primaryYellow : .gray900)
    }
  }

  private var headerCharacter: some View {
    Menu {
      Picker("등장인물", selection: $selectedCharacter) {
        Text("등장인물")
          .tag(nil as String?)
        ForEach(
          Set(scenario.props.compactMap({ $0.character })).sorted(),
          id: \.self
        ) { character in
          Text(character)
            .tag(character)
        }
      }
    } label: {
      HStack {
        Text(selectedCharacter ?? "등장인물")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedCharacter != nil ? .primaryYellow : .gray900)
    }
  }
}

#Preview("PropsGalleryView") {
  @Previewable @State var selectedSceneNumber: Int? = nil
  @Previewable @State var selectedCategory: PropCategory? = nil
  @Previewable @State var selectedMajorLocation: String? = nil
  @Previewable @State var selectedCharacter: String? = nil
  @Previewable @State var selectedScene: ScenarioScene? = nil
  @Previewable @State var selectedProp: Prop? = nil

  let scenario: Scenario = .sample
  let props = scenario.props

  PropsGalleryView(
    scenario: scenario,
    props: props,
    selectedSceneNumber: $selectedSceneNumber,
    selectedCategory: $selectedCategory,
    selectedMajorLocation: $selectedMajorLocation,
    selectedCharacter: $selectedCharacter
  )
}

private struct PropCardView: View {
  let prop: Prop

  private let height: CGFloat = 360.0

  var body: some View {
    VStack(spacing: 0) {
      cardHeader
      cardFooter
    }
    .frame(maxWidth: .infinity, idealHeight: height)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }

  @State private var imageSelection: PhotosPickerItem? = nil

  private var cardHeader: some View {
    ZStack {
      Group {
        if let imageData = prop.referenceImage,
          let uiImage = UIImage(data: imageData)
        {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(minHeight: 0, maxHeight: .infinity)
        } else {
          Color.gray300
        }
      }
      .overlay(alignment: .bottomTrailing) {
        PhotosPicker(selection: $imageSelection, matching: .images) {
          Image(systemName: "photo")
            .padding()
        }
        .onChange(of: imageSelection) { oldValue, newValue in
          if let newValue {
            newValue.loadTransferable(type: Data.self) { result in
              switch result {
              case .success(let data):
                prop.referenceImage = data
              case .failure(let error):
                print("Failed to load image: \(error)")
              }
            }
          }
        }
      }

      VStack {
        HStack {
          Text("S#\(prop.sceneNumber)")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.gray900)

          Spacer()

          Button {
            prop.isCompleted.toggle()
          } label: {
            Image(
              systemName: prop.isCompleted ? "checkmark.circle.fill" : "circle"
            )
            .font(.system(size: 20))
            .foregroundStyle(
              prop.isCompleted ? Color.primaryYellow : Color.gray900
            )
          }
        }
        .padding(20)
        .background(
          VariableBlurView(maxBlurRadius: 8, direction: .blurredTopClearBottom)
        )

        Spacer()
      }
    }
    .frame(maxWidth: .infinity, idealHeight: height / 2)
  }

  private var cardFooter: some View {
    ZStack {
      if prop.isCompleted {
        Color.gray300
      } else {
        Color.white
      }

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
    .frame(maxWidth: .infinity, idealHeight: height / 2)
  }
}

#Preview("PropCardView") {
  let prop = Prop.sample

  PropCardView(prop: prop)
}

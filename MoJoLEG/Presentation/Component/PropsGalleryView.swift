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

  @Binding var selectedSceneNumber: String?
  @Binding var selectedCategory: PropCategory?
  @Binding var selectedMajorLocation: String?
  @Binding var selectedCharacter: String?
  @Binding var selectedScene: ScenarioScene?
  @Binding var selectedProp: Prop?

  @State private var scrollPosition: ScrollPosition = ScrollPosition()
  @State private var isPhotoMenuPresented: Bool = false
  @State private var selectedPropForImageChange: Prop? = nil
  @State private var isPhotoPickerPresented: Bool = false
  @State private var pickedPhoto: PhotosPickerItem? = nil
  @State private var isErrorPresented: Bool = false
  @State private var error: Error? = nil

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
              PropCardView(
                prop: prop,
                isPhotoMenuPresented: $isPhotoMenuPresented,
                selectedPropForImageChange: $selectedPropForImageChange,
              )
              .id(prop.id)
            }
          }
          .safeAreaPadding(.horizontal, 40)
        } header: {
          header
            .id("__header__")
        }
      }
    }
    .scrollPosition($scrollPosition)
    .animation(.default, value: scrollPosition)
    .background(
      backgroundColor
    )
    .onChange(of: props) { _, _ in
      scrollPosition.scrollTo(edge: .top)
    }
    .onChange(of: selectedScene) { _, scene in
      guard let scene else { return }
      scrollTo(scene: scene)
    }
    .onChange(of: selectedProp) { _, prop in
      guard let prop else { return }
      scrollTo(prop: prop)
    }
    .alert("사진 설정", isPresented: $isPhotoMenuPresented) {
      Button("앨범에서 사진 선택") {
        isPhotoPickerPresented = true
      }
      if selectedPropForImageChange?.referenceImage != nil {
        Button("삭제", role: .destructive) {
          selectedPropForImageChange?.referenceImage = nil
        }
      }
      Button("취소", role: .cancel) {
        isPhotoMenuPresented = false
      }
    }
    .photosPicker(
      isPresented: $isPhotoPickerPresented,
      selection: $pickedPhoto
    )
    .onChange(of: pickedPhoto) { _, photo in
      defer {
        pickedPhoto = nil
      }

      guard let photo else { return }
      photo.loadTransferable(type: Data.self) { result in
        switch result {
        case .success(let data):
          selectedPropForImageChange?.referenceImage = data
        case .failure(let error):
          isErrorPresented = true
          self.error = error

          print("Failed to load image: \(error)")
        }
      }
    }
    .alert("오류", isPresented: $isErrorPresented) {
      Button("확인") {
        isErrorPresented = false
        error = nil
      }
    }
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
          .tag(nil as String?)
        ForEach(
          scenario.scenes.sorted(by: { $0.order < $1.order }).compactMap(
            \.sceneNumber
          ),
          id: \.self
        ) { sceneNumber in
          Text(sceneNumber)
            .tag(sceneNumber)
        }
      }
    } label: {
      HStack(spacing: 4) {
        Text(selectedSceneNumber ?? "S#")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedSceneNumber != nil ? .primaryYellow : .gray900)
    }
  }

  private var headerPropCategory: some View {
    Menu {
      Picker("구분", selection: $selectedCategory) {
        Text("구분")
          .tag(nil as PropCategory?)
        ForEach(PropCategory.allCases, id: \.self) { category in
          Text(category.description)
            .tag(category)
        }
      }
    } label: {
      HStack(spacing: 4) {
        Text(selectedCategory?.description ?? String(localized: "구분"))
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
      HStack(spacing: 4) {
        Text(selectedMajorLocation ?? String(localized: "장소"))
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
      HStack(spacing: 4) {
        Text(selectedCharacter ?? String(localized: "등장인물"))
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedCharacter != nil ? .primaryYellow : .gray900)
    }
  }

  private func scrollTo(scene: ScenarioScene) {
    guard
      let firstSceneProp = props.first(where: {
        $0.sceneNumber == scene.sceneNumber
      })
    else {
      print(
        "Failed to find first prop for scene: \(String(describing: scene.sceneNumber))"
      )
      return
    }

    scrollTo(prop: firstSceneProp)
  }

  private func scrollTo(prop: Prop) {
    scrollPosition.scrollTo(id: prop.id)
  }
}

#Preview("PropsGalleryView") {
  @Previewable @State var selectedSceneNumber: String? = nil
  @Previewable @State var selectedCategory: PropCategory? = nil
  @Previewable @State var selectedMajorLocation: String? = nil
  @Previewable @State var selectedCharacter: String? = nil
  @Previewable @State var selectedScene: ScenarioScene? = nil
  @Previewable @State var selectedProp: Prop? = nil

  let scenario: Scenario = .sample
  scenario.props = [
    .sample
  ]
  let props = scenario.props

  return PropsGalleryView(
    scenario: scenario,
    props: props,
    selectedSceneNumber: $selectedSceneNumber,
    selectedCategory: $selectedCategory,
    selectedMajorLocation: $selectedMajorLocation,
    selectedCharacter: $selectedCharacter,
    selectedScene: $selectedScene,
    selectedProp: $selectedProp
  )
}

private struct PropCardView: View {
  let prop: Prop

  @Binding var isPhotoMenuPresented: Bool
  @Binding var selectedPropForImageChange: Prop?

  private let height: CGFloat = 360.0

  var body: some View {
    VStack(spacing: 0) {
      cardHeader
      cardFooter
    }
    .frame(maxWidth: .infinity, maxHeight: height)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }

  private var cardHeader: some View {
    ZStack {
      Group {
        if let imageData = prop.referenceImage,
          let uiImage = UIImage(data: imageData)
        {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
        } else {
          Color.gray200
            .overlay {
              Image(systemName: "camera")
                .font(.system(size: 40))
                .foregroundStyle(Color.gray900)
            }
        }
      }
      .frame(
        minWidth: 0,
        maxWidth: .infinity,
        minHeight: 0,
        maxHeight: .infinity
      )
      .onTapGesture {
        isPhotoMenuPresented = true
        selectedPropForImageChange = prop
      }

      VStack {
        HStack {
          Text("S#\(prop.sceneNumber)")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.gray900)
            .padding(4)
            .background(
              RoundedRectangle(cornerRadius: 4)
                .fill(Color.skyBlueLight)
            )

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
            .frame(width: 26, height: 26)
          }
        }
        .padding(20)
        .background(
          VariableBlurView(maxBlurRadius: 8, direction: .blurredTopClearBottom)
            .allowsHitTesting(false)
        )

        Spacer()
      }
    }
    .frame(maxWidth: .infinity, idealHeight: height / 2, maxHeight: height / 2)
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
            .minimumScaleFactor(0.5)

          Spacer()

          Text(prop.category.description)
            .foregroundStyle(.gray900)
            .lineLimit(1)
            .frame(width: 54)
            .background(prop.category.toHighlight)
        }

        VStack(spacing: 8) {
          cardFooterRow(
            title: String(localized: "장소"),
            content: prop.majorLocation
              + (prop.minorLocation.map { "/\($0)" } ?? "")
          )
          cardFooterRow(
            title: String(localized: "등장인물"),
            content: prop.character ?? ""
          )
          cardFooterRow(title: String(localized: "비고"), content: prop.note)
        }
        .frame(maxHeight: .infinity, alignment: .top)
      }
      .padding(20)
    }
    .frame(maxWidth: .infinity, idealHeight: height / 2, maxHeight: height / 2)
  }

  @ViewBuilder
  private func cardFooterRow(title: String, content: String) -> some View {
    HStack(alignment: .top) {
      Text(title)
        .font(.system(size: 17, weight: .semibold))
        .frame(width: 80, alignment: .leading)
      Text(content)
        .font(.system(size: 15))
        .minimumScaleFactor(0.5)
    }
    .foregroundStyle(.gray900)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview("PropCardView") {
  let prop = Prop.sample

  PropCardView(
    prop: prop,
    isPhotoMenuPresented: .constant(false),
    selectedPropForImageChange: .constant(nil)
  )
}

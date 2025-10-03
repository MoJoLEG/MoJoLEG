//
//  PropsListView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import PhotosUI
import SwiftUI

struct PropsListView: View {
  let scenario: Scenario
  let props: [Prop]

  @Binding var isScenarioPresented: Bool

  @Binding var selectedSceneNumber: String?
  @Binding var selectedCategory: PropCategory?
  @Binding var selectedMajorLocation: String?
  @Binding var selectedCharacter: String?
  @Binding var selectedScene: ScenarioScene?
  @Binding var selectedProp: Prop?

  @State private var scrollPosition: ScrollPosition = ScrollPosition()
  @State private var scrollViewSize: CGSize = .zero
  @State private var isPhotoMenuPresented: Bool = false
  @State private var selectedPropForImageChange: Prop? = nil
  @State private var isPhotoPickerPresented: Bool = false
  @State private var pickedPhoto: PhotosPickerItem? = nil
  @State private var isErrorPresented: Bool = false
  @State private var error: Error? = nil

  var body: some View {
    ScrollView([.horizontal, .vertical]) {
      LazyVStack(pinnedViews: .sectionHeaders) {
        Section {
          ForEach(props) { prop in
            HStack {
              PropsListRowView(
                prop: prop,
                isPhotoMenuPresented: $isPhotoMenuPresented,
                selectedPropForImageChange: $selectedPropForImageChange,
              )
              Spacer()
            }
            .id(prop.id)
          }
        } header: {
          HStack {
            header
            Spacer()
          }
          .id("__header__")
        }
      }
      .safeAreaPadding(.horizontal, isScenarioPresented ? 40 : nil)
      .frame(
        minWidth: isScenarioPresented ? scrollViewSize.width * 1.6 : nil,
        minHeight: scrollViewSize.height,
        alignment: .topLeading
      )
    }
    .onGeometryChange(for: CGSize.self) { proxy in
      proxy.size
    } action: { newValue in
      scrollViewSize = newValue
    }
    .scrollPosition($scrollPosition, anchor: .topLeading)
    .defaultScrollAnchor(.topLeading)
    .animation(.default, value: scrollPosition)
    .onAppear {
      UIScrollView.appearance().isDirectionalLockEnabled = true
    }
    .onDisappear {
      UIScrollView.appearance().isDirectionalLockEnabled = false
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
    HStack(spacing: 24) {
      headerCompleted
      headerSceneNumber
      headerPropCategory
      headerPropName
      headerMajorLocation
      headerPropEnvironment
      headerCharacter
      headerPropNote
      headerReferenceImage
    }
    .font(.system(size: 17, weight: .semibold))
    .minimumScaleFactor(0.5)
    .foregroundStyle(.gray900)
    .padding(.vertical, 10)
    .padding(.horizontal, 28)
    .background(.white, in: RoundedRectangle(cornerRadius: 12))
  }

  private var headerCompleted: some View {
    Image(systemName: "checkmark.circle.fill")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.completedWidth)
  }

  private var headerSceneNumber: some View {
    Menu {
      Picker("씬 번호", selection: $selectedSceneNumber) {
        Text("S#")
          .tag(nil as String?)
        ForEach(
          scenario.scenes.sorted(by: { $0.order < $1.order }).compactMap(\.sceneNumber),
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
      .frame(width: PropsListConstants.Columns.sceneNumberWidth)
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
      HStack(spacing: 4) {
        Text(selectedCategory?.toString ?? "구분")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedCategory != nil ? .primaryYellow : .gray900)
      .frame(width: PropsListConstants.Columns.propCategoryWidth)
    }
  }

  private var headerPropName: some View {
    Text("이름")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propNameWidth)
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
        Text(selectedMajorLocation ?? "장소")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedMajorLocation != nil ? .primaryYellow : .gray900)
      .frame(width: PropsListConstants.Columns.propLocationWidth)
    }
  }

  private var headerPropEnvironment: some View {
    Text("I/E")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propEnvironmentWidth)
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
        Text(selectedCharacter ?? "등장인물")
          .lineLimit(1)
        Image(systemName: "chevron.up.chevron.down")
      }
      .foregroundStyle(selectedCharacter != nil ? .primaryYellow : .gray900)
      .frame(width: PropsListConstants.Columns.propCharacterWidth)
    }
  }

  private var headerPropNote: some View {
    Text("비고")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propNoteWidth)
  }

  private var headerReferenceImage: some View {
    Text("레퍼런스 이미지")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propReferenceImageWidth)
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
    guard let index = props.firstIndex(of: prop) else {
      print("Failed to find index for prop: \(prop.name)")
      return
    }

    let previousIndex = index - 1

    if previousIndex < 0 {
      scrollPosition.scrollTo(point: .zero)
    } else if props.indices.contains(previousIndex) {
      let previousTarget = props[previousIndex]

      scrollPosition.scrollTo(id: previousTarget.id)
    }
  }
}

#Preview("PropsListView") {
  @Previewable @State var isScenarioPresented: Bool = false

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

  return PropsListView(
    scenario: scenario,
    props: props,
    isScenarioPresented: $isScenarioPresented,
    selectedSceneNumber: $selectedSceneNumber,
    selectedCategory: $selectedCategory,
    selectedMajorLocation: $selectedMajorLocation,
    selectedCharacter: $selectedCharacter,
    selectedScene: $selectedScene,
    selectedProp: $selectedProp
  )
}

private struct PropsListRowView: View {
  let prop: Prop

  @Binding var isPhotoMenuPresented: Bool
  @Binding var selectedPropForImageChange: Prop?

  var body: some View {
    HStack(spacing: 24) {
      propCompleted
      propSceneNumber
      propCategory
      propName
      propLocation
      propEnvironment
      propCharacter
      propNote
      propReferenceImage
    }
    .minimumScaleFactor(0.5)
    .foregroundStyle(prop.isCompleted ? .gray600 : .gray900)
    .padding(.vertical, 8)
    .padding(.horizontal, 28)
    .background(
      prop.isCompleted ? .gray300 : .white,
      in: RoundedRectangle(cornerRadius: 12)
    )
  }

  private var propCompleted: some View {
    Button {
      prop.isCompleted.toggle()
    } label: {
      Image(systemName: prop.isCompleted ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(prop.isCompleted ? .primaryYellow : .gray900)
        .frame(width: PropsListConstants.Columns.completedWidth)
    }
  }

  private var propSceneNumber: some View {
    Text(prop.sceneNumber)
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.sceneNumberWidth)
  }

  private var propCategory: some View {
    Text(prop.category.toString)
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propCategoryWidth)
      .background(prop.category.toHighlight)
  }

  private var propName: some View {
    Text(prop.name)
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propNameWidth)
  }

  private var propLocation: some View {
    Text(prop.majorLocation + (prop.minorLocation.map { "/\($0)" } ?? ""))
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propLocationWidth)
  }

  private var propEnvironment: some View {
    Text(prop.environment.toString)
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propEnvironmentWidth)
  }

  private var propCharacter: some View {
    Text(prop.character ?? "")
      .lineLimit(1)
      .frame(width: PropsListConstants.Columns.propCharacterWidth)
  }

  private var propNote: some View {
    Text(prop.note)
      .minimumScaleFactor(0.5)
      .lineLimit(4)
      .multilineTextAlignment(.center)
      .frame(width: PropsListConstants.Columns.propNoteWidth)
  }

  private var propReferenceImage: some View {
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
          }
      }
    }
    .frame(
      width: PropsListConstants.propReferenceImageMaxWidth,
      height: PropsListConstants.propReferenceImageMaxHeight
    )
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .frame(width: PropsListConstants.Columns.propReferenceImageWidth)
    .onTapGesture {
      isPhotoMenuPresented = true
      selectedPropForImageChange = prop
    }
  }
}

#Preview("PropsListRowView") {
  let prop = Prop.sample
  prop.isCompleted = true
  prop.note =
    "컵 안에 내용물은 무엇일까?글자컵 안에 내용물은 무엇일까?글자컵 안에 내용물은글자컵 안에 내용물은안에 내용물안에 내용물안에 내용물"

  return VStack {
    PropsListRowView(
      prop: prop,
      isPhotoMenuPresented: .constant(false),
      selectedPropForImageChange: .constant(nil),
    )
    PropsListRowView(
      prop: .sample,
      isPhotoMenuPresented: .constant(false),
      selectedPropForImageChange: .constant(nil),
    )
  }
}

private enum PropsListConstants {
  enum Columns {
    static let completedWidth: CGFloat = 16.0
    static let sceneNumberWidth: CGFloat = 48.0
    static let propCategoryWidth: CGFloat = 56.0
    static let propNameWidth: CGFloat = 144.0
    static let propLocationWidth: CGFloat = 144.0
    static let propEnvironmentWidth: CGFloat = 22.0
    static let propCharacterWidth: CGFloat = 144.0
    static let propNoteWidth: CGFloat = 200.0
    static let propReferenceImageWidth: CGFloat = 144.0
  }

  static let propReferenceImageMaxWidth: CGFloat = 80.0
  static let propReferenceImageMaxHeight: CGFloat = 60.0
}

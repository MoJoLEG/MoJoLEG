//
//  PropsListView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct PropsListView: View {
  let scenario: Scenario
  let props: [Prop]

  @Binding var selectedSceneNumber: Int?
  @Binding var selectedCategory: PropCategory?
  @Binding var selectedMajorLocation: String?
  @Binding var selectedCharacter: String?
  @Binding var selectedScene: ScenarioScene?
  @Binding var selectedProp: Prop?

  @State private var scrollPosition: ScrollPosition = ScrollPosition()

  var body: some View {
    ScrollView([.horizontal, .vertical]) {
      LazyVStack(pinnedViews: .sectionHeaders) {
        Section {
          ForEach(props) { prop in
            PropsListRowView(prop: prop)
              .padding(.horizontal, 40)
              .id(prop.id)
          }
        } header: {
          header
            .padding(.horizontal, 40)
            .id("__header__")
        }
      }
      .safeAreaPadding(.trailing, 580)
      .safeAreaPadding(.bottom, 800)
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
    .onChange(of: selectedScene) { oldValue, newValue in
      if let newValue {
        scrollTo(scene: newValue)
      }
    }
    .onChange(of: selectedProp) { oldValue, newValue in
      if let newValue {
        scrollTo(prop: newValue)
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
      headerPropCount
      headerPropPrice
      headerReferenceImage
      headerResponsibleTeam
    }
    .font(.system(size: 17, weight: .semibold))
    .minimumScaleFactor(0.5)
    .foregroundStyle(.gray900)
    .padding(.vertical, 10)
    .padding(.horizontal, 28)
    .frame(minWidth: 1280)
    .background(.white, in: RoundedRectangle(cornerRadius: 12))
  }

  private var headerCompleted: some View {
    Image(systemName: "checkmark.circle.fill")
      .lineLimit(1)
      .frame(minWidth: 16)
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
      Text(selectedSceneNumber?.formatted() ?? "S#")
        .lineLimit(1)
        .foregroundStyle(selectedSceneNumber != nil ? .primaryYellow : .gray900)
        .frame(width: 24)
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
      .frame(width: 54)
    }
  }

  private var headerPropName: some View {
    Text("이름")
      .lineLimit(1)
      .frame(width: 80)
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
      .frame(width: 72)
    }
  }

  private var headerPropEnvironment: some View {
    Text("I/E")
      .lineLimit(1)
      .frame(width: 24)
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
      .frame(width: 96)
    }
  }

  private var headerPropNote: some View {
    Text("비고")
      .lineLimit(1)
      .frame(width: 160)
  }

  private var headerPropCount: some View {
    Text("개수")
      .lineLimit(1)
      .frame(width: 32)
  }

  private var headerPropPrice: some View {
    Text("구매가")
      .lineLimit(1)
      .frame(width: 96)
  }

  private var headerReferenceImage: some View {
    Text("레퍼런스 이미지")
      .lineLimit(1)
      .frame(width: 160)
  }

  private var headerResponsibleTeam: some View {
    Text("담당팀")
      .lineLimit(1)
      .frame(width: 128)
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
  @Previewable @State var selectedSceneNumber: Int? = nil
  @Previewable @State var selectedCategory: PropCategory? = nil
  @Previewable @State var selectedMajorLocation: String? = nil
  @Previewable @State var selectedCharacter: String? = nil
  @Previewable @State var selectedScene: ScenarioScene? = nil
  @Previewable @State var selectedProp: Prop? = nil

  let scenario: Scenario = .sample
  let props = scenario.props

  PropsListView(
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

private struct PropsListRowView: View {
  let prop: Prop

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
      propCount
      propPrice
      propReferenceImage
      propResponsibleTeam
    }
    .foregroundStyle(prop.isCompleted ? .gray600 : .gray900)
    .padding(.vertical, 20)
    .padding(.horizontal, 28)
    .frame(minWidth: 1280)
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
        .frame(width: 16)
    }
  }

  private var propSceneNumber: some View {
    Text("\(prop.sceneNumber)")
      .lineLimit(1)
      .frame(width: 24)
  }

  private var propCategory: some View {
    Text("\(prop.category.toString)")
      .lineLimit(1)
      .frame(width: 54)
      .background(prop.category.toHighlight)
  }

  private var propName: some View {
    Text("\(prop.name)")
      .minimumScaleFactor(0.5)
      .lineLimit(1)
      .frame(width: 80)
  }

  private var propLocation: some View {
    Text(prop.majorLocation + (prop.minorLocation.map { "/\($0)" } ?? ""))
      .minimumScaleFactor(0.5)
      .lineLimit(1)
      .frame(width: 72)
  }

  private var propEnvironment: some View {
    Text("\(prop.environment.toString)")
      .lineLimit(1)
      .frame(width: 24)
  }

  private var propCharacter: some View {
    Text("\(prop.character ?? "")")
      .lineLimit(1)
      .frame(width: 96)
  }

  private var propNote: some View {
    Text("\(prop.note)")
      .minimumScaleFactor(0.5)
      .lineLimit(1)
      .frame(width: 160)
  }

  private var propCount: some View {
    Text(prop.count.map { $0.formatted() } ?? "-")
      .lineLimit(1)
      .frame(width: 32)
  }

  private var propPrice: some View {
    Text(prop.price.map { $0.formatted() } ?? "-")
      .lineLimit(1)
      .frame(width: 96)
  }

  private var propReferenceImage: some View {
    Group {
      if let imageData = prop.referenceImage,
        let uiImage = UIImage(data: imageData)
      {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFit()
      } else {
        Text("-")
      }
    }
    .frame(width: 160)
  }

  private var propResponsibleTeam: some View {
    Text(prop.responsibleTeam ?? "-")
      .lineLimit(1)
      .frame(width: 128)
  }
}

#Preview("PropsListRowView") {
  let prop = Prop.sample
  prop.isCompleted = true

  return VStack {
    PropsListRowView(prop: prop)
    PropsListRowView(prop: .sample)
  }
}

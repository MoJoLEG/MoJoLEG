//
//  ChooseScenarioView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

struct ChooseScenarioView: View {
  enum ScenarioFilterState {
    case all
    case favorite
  }

  @State private var isFileOpen: Bool = false
  @State private var scenarioFilterState: ScenarioFilterState = .all
  @State private var isSearchBarPresented: Bool = false
  @State private var isLoadingViewPresented: Bool = false

  @Environment(\.modelContext) private var context
  @Query(sort: \Scenario.updatedAt, order: .forward)
  private var scenarios: [Scenario]

  @State private var selectedScenario: Scenario? = nil

  @Environment(\.editMode) private var editMode

  @Namespace private var namespace

  var body: some View {
    NavigationStack {
      ZStack {
        background

        VStack {
          navigationTitle

          topToolbar

          scenarioList
        }
        .padding(40)

        if isLoadingViewPresented {
          LoadingView()
            .ignoresSafeArea()
        }
      }
      .navigationDestination(item: $selectedScenario) { scenario in
        PropListView(scenario: scenario)
      }
      .toolbar {
        bottomToolbar
      }
      .fileImporter(
        isPresented: $isFileOpen,
        allowedContentTypes: [.pdf]
      ) { result in
        switch result {
        case .success(let url):
          Task {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            await loadScenario(url)
          }
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    }
  }

  private func loadScenario(_ url: URL) async {
    isLoadingViewPresented = true

    defer {
      isLoadingViewPresented = false
    }

    /// 1. PDF에서 텍스트 추출
    let extracted = ExtractTextService.shared.extractText(
      from: url,
      fileType: .pdf
    )

    guard let extracted, !extracted.isEmpty else {
      print("Failed to extract text from PDF")
      return
    }

    /// 2. 추출된 텍스트에서 씬 분리
    let separated = SeperateSceneService.shared.separteScenes(
      scenario: extracted
    )

    guard let separated, !separated.isEmpty else {
      print("Failed to separate scenes")
      return
    }

    /// 3. Upstage에 씬 분석 요청
    let responses = await UpstageService.shared
      .processScenesInParallel(separated.map { $0.content })
    let contents = responses.compactMap {
      $0.choices.first?.message.content
    }

    guard !contents.isEmpty else {
      print("Failed to analyze scenes")
      return
    }

    var allProps: [Prop] = []
    for content in contents {
      do {
        let props = try PropDecodeService.shared.decode(content)

        allProps.append(contentsOf: props)
      } catch {
        print("Failed to decode prop:", error.localizedDescription)
      }
    }

    let lines = extracted.components(separatedBy: .newlines)
    var title: String = "Untitled"
    if let firstLine = lines.first, !firstLine.isEmpty {
      title = firstLine
    }

    let scenario = Scenario(
      id: UUID(),
      title: title,
      scenes: separated,
      props: allProps,
      isFavorite: false,
      createdAt: Date(),
      updatedAt: Date()
    )

    context.insert(scenario)

    do {
      try context.save()
    } catch {
      print("Failed to save data:", error.localizedDescription)
    }
  }

  private var background: some View {
    Color.gray100
      .ignoresSafeArea()
  }

  private var navigationTitle: some View {
    HStack {
      Text("소품리스트 모음")
        .font(.system(size: 40, weight: .semibold))
        .foregroundStyle(.gray900)
      Spacer()
    }
    .padding(.bottom, 24)
  }

  private var topToolbar: some View {
    HStack {
      scenarioFilter

      Spacer()

      HStack(spacing: 16) {
        selectButton

        if isSearchBarPresented {
          searchBar
        }

        searchButton
      }
    }
    .padding(.bottom, 48)
  }

  private var scenarioFilter: some View {
    HStack {
      Button {
        scenarioFilterState = .all
      } label: {
        Text("전체보기")
          .foregroundStyle(scenarioFilterState == .all ? .white : .gray900)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background {
            if scenarioFilterState == .all {
              Capsule()
                .fill(.primaryYellow)
                .matchedGeometryEffect(id: "LayoutBackground", in: namespace)
            }
          }
      }
      Button {
        scenarioFilterState = .favorite
      } label: {
        Text("즐겨찾기")
          .foregroundStyle(scenarioFilterState == .favorite ? .white : .gray900)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background {
            if scenarioFilterState == .favorite {
              Capsule()
                .fill(.primaryYellow)
                .matchedGeometryEffect(id: "LayoutBackground", in: namespace)
            }
          }
      }
    }
    .padding(4)
    .background(.gray200, in: Capsule())
  }

  private var selectButton: some View {
    Button("선택") {
      if editMode?.wrappedValue == .active {
        editMode?.wrappedValue = .inactive
      } else {
        editMode?.wrappedValue = .active
      }
    }
  }

  private var searchBar: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.gray400)
      TextField("검색", text: .constant(""))
      Image(systemName: "xmark.circle.fill")
        .foregroundStyle(.gray400)
    }
    .padding(7)
    .frame(maxWidth: 300)
    .background(.gray200, in: RoundedRectangle(cornerRadius: 8))
  }

  private var searchButton: some View {
    Button {
      withAnimation {
        isSearchBarPresented.toggle()
      }
    } label: {
      if isSearchBarPresented {
        Text("취소")
      } else {
        Image(systemName: "magnifyingglass")
      }
    }
  }

  private var scenarioList: some View {
    ScrollView {
      LazyVGrid(
        columns: Array(repeating: GridItem(), count: 4),
        spacing: 48
      ) {
        addScenarioButton
          .frame(maxWidth: 220, maxHeight: .infinity, alignment: .top)

        ForEach(scenarios) { scenario in
          ScenarioButton(
            title: scenario.title,
            date: scenario.updatedAt.formatted(date: .numeric, time: .omitted),
            isFavorite: scenario.isFavorite
          ) {
            selectedScenario = scenario
          }
          .frame(maxWidth: 220, maxHeight: .infinity, alignment: .top)
        }
      }
    }
  }

  private var addScenarioButton: some View {
    Button {
      isFileOpen.toggle()
    } label: {
      VStack(spacing: 36) {
        Image(.plusBox)
          .resizable()
          .scaledToFit()
        Text("신규 시나리오")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(.primaryYellow)
      }
    }
  }

  @ToolbarContentBuilder
  private var bottomToolbar: some ToolbarContent {
    if editMode?.wrappedValue == .active {
      ToolbarItem(placement: .bottomBar) {
        Text("공유")
      }
      ToolbarItem(placement: .bottomBar) {
        Text("복제")
      }
      ToolbarItem(placement: .bottomBar) {
        Text("삭제")
      }
    }
  }
}

#Preview {
  ChooseScenarioView()
    .modelContainer(
      for: [Scenario.self, Prop.self],
      inMemory: true
    )
}

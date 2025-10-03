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
  @State private var selectedScenarios: Set<UUID> = []
  @State private var searchText: String = ""

  @Environment(\.modelContext) private var context
  @Query(sort: \Scenario.updatedAt, order: .reverse)
  private var scenarios: [Scenario]

  @State private var selectedScenario: Scenario? = nil
  @State private var importFileTask: Task<Void, Never>? = nil
  @State private var error: String? = nil

  @State private var longPressedScenario: Scenario? = nil

  @Environment(\.editMode) private var editMode

  @Namespace private var namespace

  private var filteredScenarios: [Scenario] {
    scenarios.filter {
      matchesFavorite($0)
        && matchesSearch($0)
    }
  }

  private func matchesFavorite(_ scenario: Scenario) -> Bool {
    scenarioFilterState == .all || scenario.isFavorite
  }

  private func matchesSearch(_ scenario: Scenario) -> Bool {
    !isSearchBarPresented || searchText.isEmpty
      || scenario.title.localizedCaseInsensitiveContains(searchText)
  }

  var body: some View {
    NavigationStack {
      ZStack {
        background

        VStack {
          VStack(spacing: 24) {
            navigationTitle

            topToolbar
          }
          .padding([.top, .horizontal], 40)

          scenarioList
        }

        if isLoadingViewPresented {
          LoadingView()
            .ignoresSafeArea()
            .onTapGesture(count: 3) {
              importFileTask?.cancel()
              importFileTask = nil
            }
        }
      }
      .navigationDestination(item: $selectedScenario) { scenario in
        ScenarioPropsView(scenario: scenario)
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
          importFileTask = Task {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer {
              url.stopAccessingSecurityScopedResource()
              importFileTask = nil
            }

            await loadScenario(url)
          }
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
      .alert(
        "Error",
        isPresented: Binding(
          get: {
            error != nil
          },
          set: { _, _ in
            error = nil
          }
        )
      ) {
      } message: {
        if let error {
          Text(error)
        }
      }
    }
  }

  private func loadScenario(_ url: URL) async {
    editMode?.wrappedValue = .inactive
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
    let props = await withTaskGroup { group in
      for (index, scene) in separated.enumerated() {
        group.addTask { () -> [Prop]? in
          do {
            let request: UpstageRequestDto = await UpstageRequestDto(
              messages: [
                UpstageMessageRequestDto(
                  role: "system",
                  content: Prompt.default
                ),
                UpstageMessageRequestDto(role: "user", content: scene.content),
              ],
              responseFormat: ResponseFormat.default
            )

            let response: UpstageResponseDto = try await UpstageService.shared
              .request(request)

            guard let content = response.choices.first?.message.content else { return nil }
            
            let props = try await PropDecodeService.shared.decode(content)
            
            if separated.indices.contains(index) {
              separated[index].sceneNumber = props.first?.sceneNumber
            }
            print("[\(index)] Successfully finished processing scene \(props.first?.sceneNumber)")
            
            return props
          } catch {
            print(
              "[\(index)] Failed to process scene: \(String(describing: error))"
            )
          }
          return nil
        }
      }

      var result: [Prop] = []
      for await response in group {
        if let response {
          result.append(contentsOf: response)
        }
      }
      return result
    }

    let lines = extracted.components(separatedBy: .newlines)
    var title: String = "Untitled"
    if let firstLine = lines.first, !firstLine.isEmpty {
      title = firstLine
    }

    let pdfFile = try? Data(contentsOf: url)

    let scenario = Scenario(
      id: UUID(),
      title: title,
      scenes: separated,
      props: props,
      isFavorite: false,
      createdAt: Date(),
      updatedAt: Date(),
      pdfFile: pdfFile
    )

    context.insert(scenario)

    do {
      try context.save()
    } catch {
      print("Failed to save data: \( error.localizedDescription)")
    }

    selectedScenario = scenario
  }

  private func duplicateSelectedScenarios() {
    let targets = scenarios.filter { selectedScenarios.contains($0.id) }
    guard !targets.isEmpty else { return }
    for scenario in targets {
      let copiedScenario = scenario.copy()
      copiedScenario.title = "\(copiedScenario.title) - 복사"
      context.insert(copiedScenario)
    }
    do { try context.save() } catch {
      self.error = "Duplicate save error: \( error.localizedDescription)"
    }
    selectedScenarios.removeAll()
  }

  private func deleteSelectedScenarios() {
    let targets = scenarios.filter { selectedScenarios.contains($0.id) }
    guard !targets.isEmpty else { return }
    for t in targets { context.delete(t) }
    do { try context.save() } catch {
      self.error = "Delete save error: \( error.localizedDescription)"
    }
    selectedScenarios.removeAll()
  }

  private var background: some View {
    Color.gray100
      .ignoresSafeArea()
  }

  private var navigationTitle: some View {
    HStack {
      Text("영화 선재")
        .font(.system(size: 40, weight: .semibold))
        .foregroundStyle(.gray900)
      Spacer()
    }
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
  }

  private var scenarioFilter: some View {
    HStack {
      Button {
        withAnimation {
          scenarioFilterState = .all
        }
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
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
          }
      }
      Button {
        withAnimation {
          scenarioFilterState = .favorite
        }
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
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
          }
      }
    }
    .padding(4)
    .background(.gray200, in: Capsule())
  }

  private var selectButton: some View {
    HStack {
      if editMode?.wrappedValue == .active {
        Button("전체 선택") {
          selectedScenarios = Set(filteredScenarios.map { $0.id })
        }
        .padding(.trailing, 20)
      }
      Button(editMode?.wrappedValue == .active ? "완료" : "선택") {
        if editMode?.wrappedValue == .active {
          editMode?.wrappedValue = .inactive
          selectedScenarios.removeAll()
        } else {
          editMode?.wrappedValue = .active
        }
      }
      .padding(.trailing, 20)
    }
  }

  private var searchBar: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.gray400)
      TextField("검색", text: $searchText)
      if !searchText.isEmpty {
        Button {
          searchText = ""
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.gray400)
        }
      }
    }
    .padding(7)
    .frame(maxWidth: 300)
    .background(.gray200, in: RoundedRectangle(cornerRadius: 8))
  }

  @ViewBuilder
  private var searchButton: some View {
    if isSearchBarPresented {
      Button {
        withAnimation {
          searchText = ""
          isSearchBarPresented = false
        }
      } label: {
        Text("취소")
      }

    } else {
      Button {
        withAnimation {
          isSearchBarPresented = true
        }
      } label: {
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

        ForEach(filteredScenarios) { scenario in
          ZStack(alignment: .center) {
            ScenarioButton(
              title: scenario.title,
              date: scenario.updatedAt.formatted(
                date: .numeric,
                time: .omitted
              ),
              isFavorite: Binding(
                get: { scenario.isFavorite },
                set: { newValue in
                  scenario.isFavorite = newValue
                  try? context.save()
                }
              )
            ) {
              if editMode?.wrappedValue == .active {
                if selectedScenarios.contains(scenario.id) {
                  selectedScenarios.remove(scenario.id)
                } else {
                  selectedScenarios.insert(scenario.id)
                }
              } else {
                selectedScenario = scenario
              }
            } longPressAction: {
              longPressedScenario = scenario
            }
            .popover(
              item: Binding(
                get: {
                  longPressedScenario == scenario ? scenario : nil
                },
                set: {
                  longPressedScenario = $0
                }
              )
            ) { scenario in
              VStack {
                TextField(
                  "제목을 입력해주세요",
                  text: Binding(
                    get: {
                      scenario.title
                    },
                    set: {
                      scenario.title = $0
                    }
                  )
                )
                .padding(8)

                Divider()

                ShareLink(item: scenario, preview: SharePreview(scenario.title, image: Image(.logo))) {
                  Label("공유", systemImage: "square.and.arrow.up")
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button("복제", systemImage: "document.on.document") {
                  let copiedScenario = scenario.copy()
                  copiedScenario.title = "\(copiedScenario.title) - 복사"
                  context.insert(copiedScenario)

                  longPressedScenario = nil
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button("삭제", systemImage: "trash", role: .destructive) {
                  context.delete(scenario)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .padding()
              .frame(idealWidth: 240, maxWidth: 240)
            }

            if editMode?.wrappedValue == .active {
              Circle()
                .strokeBorder(Color.white, lineWidth: 2)
                .background(
                  selectedScenarios.contains(scenario.id)
                    ? Circle().fill(Color.accentColor)
                    : Circle().fill(Color.clear)
                )
                .frame(width: 25, height: 25)
                .overlay(
                  Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 12, weight: .bold))
                    .opacity(selectedScenarios.contains(scenario.id) ? 1 : 0)
                )
                .padding(8)
                .padding(.top, 20)
            }
          }
          .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
        }
      }
    }
    .safeAreaPadding(40)
    .overlay(alignment: .top) {
      VariableBlurView(maxBlurRadius: 8)
        .frame(height: 40)

      LinearGradient(
        colors: [Color.gray100, Color.clear],
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(height: 40)
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
      .frame(maxWidth: 200, maxHeight: .infinity, alignment: .top)
    }
  }

  @ToolbarContentBuilder
  private var bottomToolbar: some ToolbarContent {
    if editMode?.wrappedValue == .active {
      ToolbarItem(placement: .bottomBar) {
        HStack {
          // Left - 복제
          Button {
            duplicateSelectedScenarios()
          } label: {
            Text("복제")
              .foregroundStyle(
                selectedScenarios.count > 0 ? .primaryYellow : .gray600
              )
          }
          .disabled(selectedScenarios.isEmpty)

          Spacer()

          // Center - 공유
          ShareLink(
            items: scenarios.filter { selectedScenarios.contains($0.id) }
          ) {
            SharePreview($0.title, image: Image(.logo))
          } label: {
            Text("공유")
              .foregroundStyle(
                selectedScenarios.count > 0 ? .primaryYellow : .gray600
              )
          }
          .disabled(selectedScenarios.isEmpty)

          Spacer()

          // Right - 삭제
          Button(role: .destructive) {
            deleteSelectedScenarios()
          } label: {
            Text("삭제")
              .foregroundStyle(
                selectedScenarios.count > 0 ? .primaryYellow : .gray600
              )
          }
          .disabled(selectedScenarios.isEmpty)
        }
      }
    }
  }
}

#Preview(traits: .modifier(PreviewModelContainer())) {
  ChooseScenarioView()
}

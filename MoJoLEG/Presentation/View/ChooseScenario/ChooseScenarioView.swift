//
//  ChooseScenarioView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

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

  @Environment(\.editMode) private var editMode
    
    @StateObject private var navigationManager = NavigationManager()

  @Namespace private var namespace

  @State private var processedSceneTexts: [String] = []

  var body: some View {
      NavigationStack(path: $navigationManager.path){
          ZStack {
              background
              
              VStack {
                  navigationTitle
                  
                  topToolbar
                  
                  scenarioList
                  
              }
              .padding(40)
          }
          .navigationDestination(for: ViewType.self) { value in
              switch value {
              case .Loading:
                  LoadingView()
                      .environmentObject(navigationManager)
              case .PropList:
                  PropListView(scenario: .sample)
              }
          }
          .toolbar {
              bottomToolbar
          }
          .fileImporter(isPresented: $isFileOpen,
                        allowedContentTypes: [.pdf])
          { result in
              switch result {
              case .success(let url):
                  Task {
                      guard url.startAccessingSecurityScopedResource() else { return }
                      defer { url.stopAccessingSecurityScopedResource() }

                      // 1. Extract text from PDF
                      let extracted = ExtractTextService.shared.extractText(from: url, fileType: .pdf)

                      // 2. Separate scenes from extracted text
                      if let extracted, !extracted.isEmpty {
                          let separated = SeperateSceneService.shared.separteScenes(scenario: extracted)

                          // 3. Upstage에 씬들을 순차적으로 보냄
                          if let separated, !separated.isEmpty {
                              await MainActor.run {
                                  navigationManager.navigate(to: .Loading)
                              }
                let responses = await UpstageService.shared
                  .processScenesInParallel(separated)
                let contents = responses.map {
                  $0.choices.first?.message.content ?? ""
                }
                              await MainActor.run {
                                  self.processedSceneTexts = contents
                                  navigationManager.navigate(to: .PropList)
                              }
                          } else {
                              print("Scene separation failed or no scenes")
                          }
                      } else {
                          print("PDF extraction failed")
                      }
                  }
                  
              case .failure(let error):
                  print(error.localizedDescription)
              }
          }
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

        ScenarioButton(
          title: "채집자",
          date: "오늘 오전 8:23",
          isFavorite: false
        ) {}
        .frame(maxWidth: 220, maxHeight: .infinity, alignment: .top)
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
}

//
//  ScenarioPropsView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import PDFKit
import SwiftUI

struct ScenarioPropsView: View {
  enum PropsLayout {
    case list
    case gallery
  }

  let scenario: Scenario

  private var filteredProps: [Prop] {
    scenario.props
      .filter { prop in
        matchesSearch(prop)
          && matchesScene(prop)
          && matchesCategory(prop)
          && matchesLocation(prop)
          && matchesCharacter(prop)
      }
      .sorted(by: { $0.sceneNumber < $1.sceneNumber })
  }

  private func matchesSearch(_ prop: Prop) -> Bool {
    !isSearchBarPresented || searchText.isEmpty
      || prop.name.localizedCaseInsensitiveContains(
        searchText.trimmingCharacters(in: .whitespaces)
      )
  }

  private func matchesScene(_ prop: Prop) -> Bool {
    selectedSceneNumber == nil || prop.sceneNumber == selectedSceneNumber
  }

  private func matchesCategory(_ prop: Prop) -> Bool {
    selectedCategory == nil || prop.category == selectedCategory
  }

  private func matchesLocation(_ prop: Prop) -> Bool {
    selectedMajorLocation == nil || prop.majorLocation == selectedMajorLocation
  }

  private func matchesCharacter(_ prop: Prop) -> Bool {
    selectedCharacter == nil || prop.character == selectedCharacter
  }

  @State private var isSidebarPresented: Bool = false

  @State private var isScenarioPresented: Bool = false
  @State private var pdfDocument: PDFDocument? = nil

  @State private var isSearchBarPresented: Bool = false
  @State private var searchText: String = ""

  @State private var selectedLayout: PropsLayout = .list

  @State private var selectedSceneNumber: Int? = nil
  @State private var selectedCategory: PropCategory? = nil
  @State private var selectedMajorLocation: String? = nil
  @State private var selectedCharacter: String? = nil
  @State private var selectedScene: ScenarioScene? = nil
  @State private var selectedProp: Prop? = nil

  @Namespace private var namespace

  var body: some View {
    ZStack {
      background

      VStack {
        VStack {
          ZStack {
            topToolbar

            scenarioTitle
          }

          HStack {
            layoutPicker

            Spacer()

            HStack {
              searchBar

              searchButton
            }
          }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)

        ZStack {
          switch selectedLayout {
          case .list:
            propsList
              .transition(.move(edge: .leading))
          case .gallery:
            propsGallery
              .transition(.move(edge: .trailing))
          }

          scenarioViewer
        }
      }

      sidebar
    }
    .task {
      if self.pdfDocument == nil {
        guard let pdfFile = scenario.pdfFile else { return }

        self.pdfDocument = PDFDocument(data: pdfFile)
      }

      guard let pdfDocument else { return }

      PDFService.shared.highlightScenario(in: pdfDocument, scenario: scenario)
    }
  }

  private var background: some View {
    Color.gray100
      .ignoresSafeArea()
  }

  private var topToolbar: some View {
    HStack {
      Button {
        isSidebarPresented = true
      } label: {
        Image(systemName: "sidebar.left")
          .foregroundStyle(.primaryYellow)
      }

      Spacer()

      HStack(spacing: 12) {
        HStack {
          Toggle(isOn: $isScenarioPresented) {}
            .tint(.primaryYellow)
            .frame(maxWidth: 72)
          Text("시나리오 보기")
            .foregroundStyle(.gray900)
            .padding(.horizontal, 10)
        }
        ShareLink(item: ExcelService.shared.createExcelFile(scenario))
          .labelStyle(.iconOnly)
          .foregroundStyle(.primaryYellow)
      }
    }
  }

  private var scenarioTitle: some View {
    Text(scenario.title)
      .font(.system(size: 40, weight: .semibold))
      .foregroundStyle(.gray900)
  }

  private var layoutPicker: some View {
    HStack {
      Button {
        withAnimation {
          selectedLayout = .list
        }
      } label: {
        Text("리스트뷰")
          .foregroundStyle(selectedLayout == .list ? .white : .gray900)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background {
            if selectedLayout == .list {
              Capsule()
                .fill(.primaryYellow)
                .matchedGeometryEffect(id: "LayoutBackground", in: namespace)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            }
          }
      }
      Button {
        withAnimation {
          selectedLayout = .gallery
        }
      } label: {
        Text("갤러리뷰")
          .foregroundStyle(selectedLayout == .gallery ? .white : .gray900)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background {
            if selectedLayout == .gallery {
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

  private var searchBar: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(.gray400)
      TextField("검색", text: $searchText)
      Button {
        searchText = ""
      } label: {
        Image(systemName: "xmark.circle.fill")
          .foregroundStyle(.gray400)
      }
    }
    .padding(7)
    .frame(maxWidth: 300)
    .background(.gray200, in: RoundedRectangle(cornerRadius: 8))
    .opacity(isSearchBarPresented ? 1.0 : 0.0)
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

  private var propsList: some View {
    PropsListView(
      scenario: scenario,
      props: filteredProps,
      selectedSceneNumber: $selectedSceneNumber,
      selectedCategory: $selectedCategory,
      selectedMajorLocation: $selectedMajorLocation,
      selectedCharacter: $selectedCharacter,
      selectedScene: $selectedScene,
      selectedProp: $selectedProp
    )
  }

  private var propsGallery: some View {
    PropsGalleryView(
      scenario: scenario,
      props: filteredProps,
      selectedSceneNumber: $selectedSceneNumber,
      selectedCategory: $selectedCategory,
      selectedMajorLocation: $selectedMajorLocation,
      selectedCharacter: $selectedCharacter
    )
  }

  private var scenarioViewer: some View {
    HStack {
      Spacer()

      if isScenarioPresented {
        Group {
          if let pdfDocument {
            PDFKitView(pdfDocument: pdfDocument, selectedScene: selectedScene) {
              annotation in
              guard let page = annotation.page else {
                print("Failed to find annotation page")
                return
              }

              guard let selection = page.selection(for: annotation.bounds)
              else {
                print("Failed to select annotation")
                return
              }

              guard
                let target = filteredProps.first(where: {
                  $0.originalText == selection.string
                })
              else {
                print(
                  "Failed to find prop with name: \(String(describing: selection.string))"
                )
                return
              }

              self.selectedProp = target
            }
            .padding(32)
            .background {
              RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 4, y: 4)
            }
          } else {
            ScenarioView(scenes: scenario.scenes, selectedScene: $selectedScene)
          }
        }
        .frame(maxWidth: 540)
        .transition(.move(edge: .trailing).combined(with: .opacity))
      }
    }
    .padding(.trailing, 36)
    .animation(.default, value: isScenarioPresented)
  }

  private var sidebar: some View {
    HStack {
      if isSidebarPresented {
        VStack(alignment: .leading) {
          HStack {
            Image(.logo)
              .resizable()
              .scaledToFit()
              .frame(maxWidth: 72)

            Spacer()
          }
          .padding(.horizontal, 16)
          .padding(.top)

          Text(scenario.title)
            .font(.title3)
            .bold()
            .padding(.horizontal, 16)

          ScrollView {
            LazyVStack(alignment: .leading) {
              ForEach(
                scenario.scenes.sorted(by: {
                  $0.order < $1.order
                })
              ) { scene in
                Text(scene.title)
                  .foregroundStyle(
                    scene == selectedScene ? .primaryYellow : .gray900
                  )
                  .padding(16)
                  .onTapGesture {
                    withAnimation {
                      selectedScene = scene
                      isSidebarPresented = false
                    }
                  }
              }
            }
            .frame(maxWidth: .infinity)
          }
        }
        .padding(16)
        .background {
          RoundedRectangle(cornerRadius: 24)
            .fill(.white)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
        }
        .frame(maxWidth: 360)
        .transition(.move(edge: .leading).combined(with: .opacity))
      }

      Spacer()
    }
    .padding(.leading, 36)
    .background {
      if isSidebarPresented {
        Color.black
          .opacity(0.3)
          .ignoresSafeArea()
          .onTapGesture {
            isSidebarPresented = false
          }
          .transition(.opacity)
      }
    }
    .animation(.default, value: isSidebarPresented)
  }
}

#Preview {
  let scenario = Scenario.sample

  scenario.props = [
    .sample
  ]

  return ScenarioPropsView(scenario: scenario)
}

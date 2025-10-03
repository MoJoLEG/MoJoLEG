//
//  ScenarioPropsView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import PDFKit
import SwiftUI

struct ScenarioPropsView: View {
  enum PropsLayout: Hashable {
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

        TabView(selection: $selectedLayout) {
          propsList
            .tag(PropsLayout.list)

          propsGallery
            .tag(PropsLayout.gallery)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(alignment: .trailing) {
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
        withAnimation {
          isSidebarPresented = true
        }
      } label: {
        Image(systemName: "sidebar.left")
          .foregroundStyle(.primaryYellow)
      }

      Spacer()

      HStack(spacing: 12) {
        HStack {
          Toggle(isOn: $isScenarioPresented.animation(.default)) {}
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
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .frame(maxWidth: 480)
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

  private var propsList: some View {
    PropsListView(
      scenario: scenario,
      props: filteredProps,
      isScenarioPresented: $isScenarioPresented,
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
      selectedCharacter: $selectedCharacter,
      selectedScene: $selectedScene,
      selectedProp: $selectedProp
    )
  }

  private var scenarioViewer: some View {
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
    .frame(maxWidth: 672)
    .offset(x: isScenarioPresented ? -36 : 708)
  }

  private var sidebar: some View {
    ZStack(alignment: .leading) {
      Color.black
        .opacity(isSidebarPresented ? 0.3 : 0)
        .ignoresSafeArea()
        .allowsHitTesting(isSidebarPresented)
        .onTapGesture {
          withAnimation {
            isSidebarPresented = false
          }
        }

      VStack(alignment: .leading) {
        HStack {
          Image(.logo)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 72)

          Spacer()
        }

        ScrollView {
          LazyVStack(alignment: .leading) {
            ForEach(
              scenario.scenes.sorted(by: {
                $0.order < $1.order
              })
            ) { scene in
              let isSelected = scene == selectedScene
              Button {
                withAnimation {
                  selectedScene = scene
                  isSidebarPresented = false
                }
              } label: {
                Text(scene.title)
                  .bold(isSelected)
                  .multilineTextAlignment(.leading)
                  .foregroundStyle(
                    isSelected ? Color.white : Color.gray900
                  )
                  .padding(16)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(
                    RoundedRectangle(cornerRadius: 12)
                      .fill(Color.primaryYellow)
                      .opacity(isSelected ? 1 : 0)
                  )
              }
            }
          }
          .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
      }
      .padding(32)
      .background {
        RoundedRectangle(cornerRadius: 24)
          .fill(.white)
          .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
      }
      .frame(maxWidth: 360)
      .offset(x: isSidebarPresented ? 36 : -396)
    }
  }
}

#Preview {
  let scenario = Scenario.sample

  scenario.props = [
    .sample
  ]

  return ScenarioPropsView(scenario: scenario)
}

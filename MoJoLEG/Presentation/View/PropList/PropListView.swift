//
//  PropListView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct PropListView: View {
  enum PropLayout {
    case list
    case gallery
  }

  let scenario: Scenario
  
  private var filteredProps: [Prop] {
    scenario.props
      .filter { !isSearchBarPresented || searchText.isEmpty || $0.name.contains(searchText) }
      .sorted(by: { $0.sceneNumber < $1.sceneNumber })
  }

  @State private var isScenarioPresented: Bool = false
  @State private var isSidebarPresented: Bool = false
  @State private var isSearchBarPresented: Bool = false
  @State private var searchText: String = ""
  @State private var selectedLayout: PropLayout = .list

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

            if isSearchBarPresented {
              searchBar
            }

            searchButton
          }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 8)

        ZStack {
          propList

          scenarioViewer
        }
      }

      sidebar
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
        ShareLink(item: .applicationSupportDirectory)
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
        selectedLayout = .list
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
            }
          }
      }
      Button {
        selectedLayout = .gallery
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

  private var propList: some View {
    ScrollView([.horizontal, .vertical]) {
      LazyVStack(pinnedViews: .sectionHeaders) {
        Section {
          ForEach(filteredProps) { prop in
            PropListRowView(prop: prop)
          }
        } header: {
          header
        }
      }
      .padding(.horizontal, 40)
      .safeAreaPadding(.trailing, 580)
      .safeAreaPadding(.bottom, 800)
    }
    .defaultScrollAnchor(.topLeading)
  }

  private var header: some View {
    HStack(spacing: 24) {
      Image(systemName: "checkmark.circle.fill")
        .frame(minWidth: 16)
      Text("S#")
        .frame(minWidth: 24)
      Text("구분")
        .frame(minWidth: 54)
      Text("이름")
        .frame(minWidth: 80)
      Text("장소")
        .frame(minWidth: 72)
      Text("I/E")
        .frame(minWidth: 24)
      Text("등장인물")
        .frame(minWidth: 96)
      Text("비고")
        .frame(minWidth: 160)
      Text("개수")
        .frame(minWidth: 32)
      Text("구매가")
        .frame(minWidth: 96)
      Text("레퍼런스 이미지")
        .frame(minWidth: 160)
      Text("담당팀")
        .frame(minWidth: 128)
    }
    .font(.system(size: 17, weight: .semibold))
    .foregroundStyle(.gray900)
    .padding(.vertical, 10)
    .padding(.horizontal, 28)
    .frame(minWidth: 1280)
    .background(.white, in: RoundedRectangle(cornerRadius: 12))
  }

  private var scenarioViewer: some View {
    HStack {
      Spacer()

      if isScenarioPresented {
        ScenarioView(scenes: scenario.scenes)
          .frame(maxWidth: 540)
          .transition(.move(edge: .trailing).combined(with: .opacity))
      }
    }
    .padding(.trailing, 36)
    .animation(.default, value: isScenarioPresented)
  }

  private var sidebar: some View {
    ZStack {
      if isSidebarPresented {
        Color.black
          .opacity(0.3)
          .ignoresSafeArea()
          .onTapGesture {
            isSidebarPresented = false
          }
          .transition(.opacity)
      }

      HStack {
        if isSidebarPresented {
          SideTabView(tabs: [], selectedTab: .constant("hi")) {
            isSidebarPresented = false
          }
          .frame(maxWidth: 360)
          .transition(.move(edge: .leading).combined(with: .opacity))
        }

        Spacer()
      }
      .padding(.leading, 36)

    }
    .animation(.default, value: isSidebarPresented)
  }
}

#Preview {
  let scenario = Scenario.sample
  
  scenario.props = [
    .sample
  ]
  
  return PropListView(scenario: scenario)
}

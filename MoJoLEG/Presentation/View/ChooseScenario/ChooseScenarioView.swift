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

    var body: some View {
        ZStack {
            background

            VStack {
                navigationTitle

                topToolbar

                scenarioList

            }
            .padding(40)
        }
        .toolbar {
            bottomToolbar
        }
        .fileImporter(isPresented: $isFileOpen,
                      allowedContentTypes: [.pdf])
        { result in
            switch result {
            case .success(let file):
                guard let url = URL(string: file.absoluteString) else {
                    print("there's no file")
                    return
                }
                print(url)
                
            case .failure(let error):
                print(error.localizedDescription)
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
        HStack(spacing: 16) {
            CaseTabButton(
                title: "전체보기",
                isSelected: scenarioFilterState == .all
            ) {
                scenarioFilterState = .all
            }
            CaseTabButton(
                title: "즐겨찾기",
                isSelected: scenarioFilterState == .favorite
            ) {
                scenarioFilterState = .favorite
            }
        }
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

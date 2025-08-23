//
//  SeperateSceneView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct SeperateSceneView: View {
    @State private var scenario: String? = nil
    @State private var scenes: [String]? = nil
    @State private var isFileImporterPresented: Bool = false
    @State private var extractTask: Task<Void, Never>? = nil

    var body: some View {
        VStack {
            if extractTask != nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack {
                        if let scenes {
                            Text("Seperated")
                                .font(.headline)
                            ForEach(scenes, id: \.self) { scene in
                                Text(scene)
                                    .padding()
                                    .background(
                                        .ultraThinMaterial,
                                        in: RoundedRectangle(cornerRadius: 16)
                                    )
                            }
                            Divider()
                        }
                        if let scenario {
                            Text("Original")
                                .font(.headline)
                            Text(scenario)
                        }
                    }
                }
            }
            HStack {
                Button("Open file") {
                    isFileImporterPresented = true
                }
                .buttonStyle(.borderedProminent)
                .fileImporter(
                    isPresented: $isFileImporterPresented,
                    allowedContentTypes: [.pdf]
                ) { result in
                    switch result {
                    case .success(let url):
                        extractTask = Task {
                            guard url.startAccessingSecurityScopedResource()
                            else {
                                return
                            }

                            defer {
                                url.stopAccessingSecurityScopedResource()

                                Task { @MainActor in
                                    extractTask = nil
                                }
                            }
                            
                            await MainActor.run {
                                scenario = nil
                                scenes = nil
                            }

                            let extracted = ExtractTextService.shared
                                .extractText(
                                    from: url,
                                    fileType: .pdf
                                )

                            await MainActor.run {
                                scenario = extracted
                            }
                        }
                    case .failure(let error):
                        scenario = error.localizedDescription
                    }
                }
                Button("Seperate scenes") {
                    Task {
                        guard let scenario else { return }
                        
                        let seperatedScenes = SeperateSceneService.shared.separteScenes(
                            scenario: scenario
                        )
                        
                        await MainActor.run {
                            scenes = seperatedScenes
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(scenario == nil)
            }
        }
        .padding()
    }
}

#Preview {
    SeperateSceneView()
}

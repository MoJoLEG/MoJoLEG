//
//  ExtractTextView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ExtractTextView: View {
    @State private var text: String? = nil
    @State private var isFileImporterPresented: Bool = false
    @State private var extractTask: Task<Void, Never>? = nil

    var body: some View {
        VStack {
            if extractTask != nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    if let text {
                        Text(text)
                    }
                }
            }
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
                        guard url.startAccessingSecurityScopedResource() else {
                            return
                        }

                        defer {
                            url.stopAccessingSecurityScopedResource()

                            Task { @MainActor in
                                extractTask = nil
                            }
                        }

                        let extracted = ExtractTextService.shared.extractText(
                            from: url,
                            fileType: .pdf
                        )

                        await MainActor.run {
                            text = extracted
                        }
                    }
                case .failure(let error):
                    text = error.localizedDescription
                }
            }
        }
        .padding()
    }
}

#Preview {
    ExtractTextView()
}

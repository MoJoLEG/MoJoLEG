//
//  DocumentOCR.swift
//  MoJoLEG
//
//  Created by 나현흠 on 9/14/25.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct DocumentOCR: View {
    @State private var text: String? = nil
    @State private var isFileImporterPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            if let text {
                ScrollView {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                }
            } else {
                Text("No file selected")
                    .foregroundStyle(.secondary)
            }
            
            if isLoading { ProgressView().padding(.top, 4) }
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button("Open PDF") {
                isFileImporterPresented = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.pdf]
        ) { result in
            switch result {
            case .success(let url):
                Task {
                    await handleSelectedURL(url)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    @MainActor
    private func handleSelectedURL(_ url: URL) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "파일 접근 권한을 얻지 못했습니다."
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let parsed = try await UpstageDocumentParsingService.shared.parseDocument(
                at: url,
                ocr: .force,
                outputFormats: ["text"],
                base64Encoding: nil,
                model: "document-parse"
            )
            
            if let t = parsed.extractedText, !t.isEmpty {
                text = t
            } else {
                // 스키마가 다를 수 있으니 원본을 문자열로 표시
                text = String(describing: parsed.raw)
            }
            
            // 테이블 Base64가 필요한 경우 여기서 디코딩 가능:
            // let tables = parsed.base64Tables
            // if let first = tables.first, let data = Data(base64Encoded: first) { ... }
            
        } catch {
            errorMessage = "업로드/파싱 실패: \(error.localizedDescription)"
        }
    }
}

#Preview {
  DocumentOCR()
}
 

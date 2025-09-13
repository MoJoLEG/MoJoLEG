//
//  ImportPDFView.swift
//  MoJoLEG
//
//  Created by 정희균 on 9/6/25.
//

import PDFKit
import SwiftUI
internal import UniformTypeIdentifiers

struct ImportPDFView: View {
  @State private var pdfDocument: PDFDocument? = nil
  @State private var isPresented: Bool = false

  var body: some View {
    VStack {
      PDFKitView(pdfDocument: pdfDocument, selectedScene: nil)
    }
    .fileImporter(
      isPresented: $isPresented,
      allowedContentTypes: [.pdf],
      onCompletion: { result in
        switch result {
        case .success(let success):
          guard success.startAccessingSecurityScopedResource() else {
            print("Failed to access PDF")
            return
          }

          defer {
            success.stopAccessingSecurityScopedResource()
          }

          guard let data = try? Data(contentsOf: success) else {
            print("Failed to read PDF data")
            return
          }

          self.pdfDocument = PDFDocument(data: data)
        case .failure(let failure):
          print(failure.localizedDescription)
        }
      }
    )
    .toolbar {
      ToolbarItem {
        Button("Import") {
          #if DEBUG
            guard
              let url = Bundle.main.url(
                forResource: "SamplePdf",
                withExtension: "pdf"
              )
            else { return }
            self.pdfDocument = PDFDocument(url: url)
          #else
            isPresented.toggle()
          #endif
        }
      }
      
      ToolbarItem {
        Button("Search") {
          guard let pdfDocument else { return }
          
          PDFService.shared.highlightAllOccurrences(in: pdfDocument, query: "PDF")
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ImportPDFView()
  }
}

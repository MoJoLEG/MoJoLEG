//
//  PDFKitView.swift
//  MoJoLEG
//
//  Created by 정희균 on 9/6/25.
//

import PDFKit
import SwiftUI

struct PDFKitView: UIViewRepresentable {
  let pdfDocument: PDFDocument?
  let selectedScene: ScenarioScene?
  let onAnnotationTap: ((PDFAnnotation) -> Void)?

  init(
    pdfDocument: PDFDocument? = nil,
    selectedScene: ScenarioScene? = nil,
    onAnnotationTap: ((PDFAnnotation) -> Void)? = nil
  ) {
    self.pdfDocument = pdfDocument
    self.selectedScene = selectedScene
    self.onAnnotationTap = onAnnotationTap
  }

  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()

    pdfView.autoScales = true
    pdfView.displayMode = .singlePageContinuous
    pdfView.displayDirection = .vertical
    pdfView.backgroundColor = .white
    pdfView.document = pdfDocument

    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleTap(_:))
    )
    tapGesture.cancelsTouchesInView = false
    pdfView.addGestureRecognizer(tapGesture)

    context.coordinator.pdfView = pdfView

    return pdfView
  }

  func updateUIView(_ pdfView: PDFView, context: Context) {
    if pdfView.document != pdfDocument {
      pdfView.document = pdfDocument
    }
    context.coordinator.setScene(selectedScene)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject {
    var parent: PDFKitView
    weak var pdfView: PDFView?

    init(_ parent: PDFKitView) {
      self.parent = parent
    }

    private var previousScene: ScenarioScene?

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
      guard let pdfView else { return }
      let tapPoint = sender.location(in: pdfView)

      guard let page = pdfView.page(for: tapPoint, nearest: true) else {
        return
      }
      let pagePoint = pdfView.convert(tapPoint, to: page)

      if let annotation = page.annotation(at: pagePoint) {
        parent.onAnnotationTap?(annotation)
      }
    }

    func setScene(_ scene: ScenarioScene?) {
      guard previousScene != scene else { return }
      previousScene = scene

      if let scene {
        setPage(to: scene)
      }
    }

    private func setPage(to scene: ScenarioScene) {
      guard let pdfView else { return }
      guard let pdfDocument = parent.pdfDocument else { return }

      let selection = pdfDocument.findString(
        scene.title,
        withOptions: [.caseInsensitive]
      )

      if let page = selection.first?.pages.first {
        pdfView.go(to: page)
      }
    }
  }
}

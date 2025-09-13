//
//  PDFService.swift
//  MoJoLEG
//
//  Created by 정희균 on 9/10/25.
//

import PDFKit
import SwiftUI

final class PDFService {
  static let shared = PDFService()

  private init() {}

  func highlightScenario(in document: PDFDocument, scenario: Scenario) {
    var cursor: PDFSelection? = nil
    var sceneSelections: [Int: PDFSelection] = [:]

    for scene in scenario.scenes.sorted(by: { $0.order < $1.order }) {
      if let selection = document.findString(
        scene.title,
        fromSelection: cursor,
        withOptions: [.caseInsensitive, .diacriticInsensitive]
      ) {
        cursor = selection
        if let sceneNumber = scene.sceneNumber {
          sceneSelections[sceneNumber] = selection
        }
      }
    }

    for prop in scenario.props {
      if let sceneSelection = sceneSelections[prop.sceneNumber],
        let selection = document.findString(
          prop.originalText,
          fromSelection: sceneSelection
        )
      {
        for lineSelection in selection.selectionsByLine() {
          guard let page = lineSelection.pages.first else { continue }

          let bounds = lineSelection.bounds(for: page)
          let annotation = PDFAnnotation(
            bounds: bounds,
            forType: .highlight,
            withProperties: nil
          )
          annotation.color = UIColor(prop.category.toHighlight)

          page.addAnnotation(annotation)
        }
      }
    }
  }

  func highlightAllOccurrences(
    in doc: PDFDocument,
    query: String,
    color: UIColor = .systemYellow.withAlphaComponent(0.35)
  ) {
    var cursor: PDFSelection? = nil
    var hits: [PDFSelection] = []

    while let sel = doc.findString(
      query,
      fromSelection: cursor,
      withOptions: [.caseInsensitive, .diacriticInsensitive]
    ) {
      hits.append(sel)
      cursor = sel
    }

    for sel in hits {
      for lineSel in sel.selectionsByLine() {
        guard let page = lineSel.pages.first else { continue }
        let bounds = lineSel.bounds(for: page)
        let ann = PDFAnnotation(
          bounds: bounds,
          forType: .highlight,
          withProperties: nil
        )
        ann.color = color
        page.addAnnotation(ann)
      }
    }
  }
}

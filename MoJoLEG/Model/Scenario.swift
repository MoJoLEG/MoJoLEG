//
//  Scenario.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import CoreTransferable
import Foundation
import SwiftData
import SwiftUI
internal import UniformTypeIdentifiers

@Model
final class Scenario {
  var id: UUID
  var title: String
  var scenes: [ScenarioScene]
  var props: [Prop]
  var isFavorite: Bool
  var createdAt: Date
  var updatedAt: Date
  var pdfFile: Data?

  init(
    id: UUID,
    title: String,
    scenes: [ScenarioScene],
    props: [Prop],
    isFavorite: Bool,
    createdAt: Date,
    updatedAt: Date,
    pdfFile: Data? = nil
  ) {
    self.id = id
    self.title = title
    self.scenes = scenes
    self.props = props
    self.isFavorite = isFavorite
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.pdfFile = pdfFile
  }
}

extension Scenario {
  static var sample: Scenario {
    Scenario(
      id: UUID(),
      title: "채집자",
      scenes: [],
      props: [],
      isFavorite: false,
      createdAt: Date(),
      updatedAt: Date()
    )
  }
}

extension Scenario {
  func copy() -> Scenario {
    Scenario(
      id: UUID(),
      title: title,
      scenes: scenes.map { $0.copy() },
      props: props.map { $0.copy() },
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
}

extension Scenario: Sendable {}

extension Scenario: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: UTType(filenameExtension: "xlsx")!)
    { scenario in
      let url = await ExcelService.shared.createExcelFile(scenario)
      return try Data(contentsOf: url)
    }
    .suggestedFileName { "소품리스트_\($0.title).xlsx" }
  }
}

extension UTType {
  static var excel: UTType {
    UTType(filenameExtension: "xlsx")!
  }
}

//
//  ExcelService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import Foundation
import SwiftXLSX
import UIKit

final class ExcelService {
  static let shared = ExcelService()

  private init() {}

  func createExcelFile(_ scenario: Scenario) -> URL {
    let book = XWorkBook()

    let sheet = book.NewSheet("Props")

    var cell = sheet.AddCell(XCoords(row: 1, col: 1))
    cell.value = .text("완료")

    cell = sheet.AddCell(XCoords(row: 1, col: 2))
    cell.value = .text("S#")

    cell = sheet.AddCell(XCoords(row: 1, col: 3))
    cell.value = .text("구분")

    cell = sheet.AddCell(XCoords(row: 1, col: 4))
    cell.value = .text("이름")

    cell = sheet.AddCell(XCoords(row: 1, col: 5))
    cell.value = .text("장소")

    cell = sheet.AddCell(XCoords(row: 1, col: 6))
    cell.value = .text("I/E")

    cell = sheet.AddCell(XCoords(row: 1, col: 7))
    cell.value = .text("등장인물")

    cell = sheet.AddCell(XCoords(row: 1, col: 8))
    cell.value = .text("비고")

    cell = sheet.AddCell(XCoords(row: 1, col: 9))
    cell.value = .text("개수")

    cell = sheet.AddCell(XCoords(row: 1, col: 10))
    cell.value = .text("구매가")

    cell = sheet.AddCell(XCoords(row: 1, col: 11))
    cell.value = .text("레퍼런스 이미지")

    cell = sheet.AddCell(XCoords(row: 1, col: 12))
    cell.value = .text("담당팀")

    for (index, prop) in scenario.props.sorted(by: {
      $0.sceneNumber < $1.sceneNumber
    }).enumerated() {
      cell = sheet.AddCell(XCoords(row: 2 + index, col: 1))
      cell.value = .text(prop.isCompleted ? "true" : "false")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 2))
      cell.value = .text("\(prop.sceneNumber)")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 3))
      cell.value = .text(prop.category.toString)

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 4))
      cell.value = .text(prop.name)

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 5))
      cell.value = .text("\(prop.majorLocation)/\(prop.minorLocation ?? "n/a")")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 6))
      cell.value = .text(prop.environment.toString)

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 7))
      cell.value = .text(prop.character ?? "n/a")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 8))
      cell.value = .text(prop.note)

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 9))
      cell.value = .text("\(prop.count ?? 0)")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 10))
      cell.value = .text("\(prop.price ?? 0)")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 11))
      cell.value = .text("n/a")

      cell = sheet.AddCell(XCoords(row: 2 + index, col: 12))
      cell.value = .text(prop.responsibleTeam ?? "")
    }

    let path = book.save("소품리스트_\(scenario.title).xlsx")

    let url = URL(fileURLWithPath: path)

    return url
  }
}

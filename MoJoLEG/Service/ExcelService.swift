//
//  ExcelService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import Foundation
import SwiftXLSX
internal import UIKit

final class ExcelService {
  static let shared = ExcelService()

  private init() {}

  func createExcelFile(_ scenario: Scenario) -> URL {
    let book = XWorkBook()

    let sheet = book.NewSheet("Props")

    let header = [
      "완료", "S#", "구분", "이름", "장소", "I/E", "등장인물", "비고", "개수", "구매가",
      "레퍼런스 이미지", "담당팀",
    ]
    for (index, column) in header.enumerated() {
      sheet.ForColumnSetWidth(1 + index, 80)

      let cell = sheet.AddCell(XCoords(row: 1, col: 1 + index))
      cell.value = .text(column)
      cell.Cols(txt: .black, bg: .yellow)
    }

    let props = scenario.props.sorted(by: { $0.sceneNumber < $1.sceneNumber })
    for (index, prop) in props.enumerated() {
      let isCompleted = prop.isCompleted ? "true" : "false"
      let sceneNumber = prop.sceneNumber
      let category = prop.category.toString
      let name = prop.name
      let location =
        prop.majorLocation + (prop.minorLocation.map { "/\($0)" } ?? "")
      let environment = prop.environment.toString
      let character = prop.character ?? ""
      let note = prop.note
      let quantity = "0"
      let price = "0"
      let referenceImage = prop.referenceImage
      let team = ""

      let items: [Any?] = [
        isCompleted, sceneNumber, category, name, location, environment,
        character, note, quantity, price, referenceImage, team,
      ]

      for (col, item) in items.enumerated() {
        let cell = sheet.AddCell(XCoords(row: 2 + index, col: 1 + col))
        switch item {
        case let text as String:
          cell.value = .text(text)
        case let image as Data:
          guard let imageClass = ImageClass(data: image) else { continue }
          guard let xImage = XImage(with: imageClass) else { continue }
          let key = XImages.append(with: xImage)
          cell.value = .icon(
            XImageCell(key: key, size: CGSize(width: 20, height: 20))
          )
        default:
          break
        }
      }
    }

    let path = book.save("\(scenario.id.uuidString).xlsx")

    let url = URL(fileURLWithPath: path)

    return url
  }
}

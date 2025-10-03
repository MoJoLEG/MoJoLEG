//
//  ScenarioScene.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import Foundation
import SwiftData

@Model
class ScenarioScene {
  var id: UUID
  var order: Int
  var sceneNumber: String?
  var title: String
  var content: String

  init(id: UUID, order: Int, sceneNumber: String? = nil, title: String, content: String) {
    self.id = id
    self.order = order
    self.sceneNumber = sceneNumber
    self.title = title
    self.content = content
  }
}

extension ScenarioScene {
  func copy() -> ScenarioScene {
    ScenarioScene(
      id: UUID(),
      order: order,
      sceneNumber: sceneNumber,
      title: title,
      content: content
    )
  }
}

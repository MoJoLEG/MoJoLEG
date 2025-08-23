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
  var sceneNumber: Int?
  var title: String
  var content: String

  init(id: UUID, sceneNumber: Int? = nil, title: String, content: String) {
    self.id = id
    self.sceneNumber = sceneNumber
    self.title = title
    self.content = content
  }
}

extension ScenarioScene {
  func copy() -> ScenarioScene {
    ScenarioScene(
      id: UUID(),
      sceneNumber: sceneNumber,
      title: title,
      content: content
    )
  }
}

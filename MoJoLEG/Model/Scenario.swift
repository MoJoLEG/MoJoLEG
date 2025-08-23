//
//  Scenario.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Foundation
import SwiftData

@Model
class Scenario {
  var id: UUID
  var title: String
  var scenes: [ScenarioScene]
  var props: [Prop]
  var isFavorite: Bool
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID,
    title: String,
    scenes: [ScenarioScene],
    props: [Prop],
    isFavorite: Bool,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.title = title
    self.scenes = scenes
    self.props = props
    self.isFavorite = isFavorite
    self.createdAt = createdAt
    self.updatedAt = updatedAt
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

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
  var scenes: [String]
  var props: [Prop]
  var createdAt: Date
  var updatedAt: Date

  init(
    id: UUID,
    title: String,
    scenes: [String],
    props: [Prop],
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.title = title
    self.scenes = scenes
    self.props = props
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

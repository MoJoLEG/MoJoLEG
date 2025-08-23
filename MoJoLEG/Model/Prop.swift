//
//  Prop.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Foundation
import SwiftData

@Model
class Prop {
  var id: UUID
  var isCompleted: Bool
  var sceneNumber: Int
  var category: PropCategory
  var name: String
  var location: String
  var environment: PropEnvironment
  var character: String
  var note: String
  var count: Int?
  var price: Double?
  var referenceImage: Data?
  var responsibleTeam: String?

  init(
    id: UUID,
    isCompleted: Bool,
    sceneNumber: Int,
    category: PropCategory,
    name: String,
    location: String,
    environment: PropEnvironment,
    character: String,
    note: String,
    count: Int? = nil,
    price: Double? = nil,
    referenceImage: Data? = nil,
    responsibleTeam: String? = nil
  ) {
    self.id = id
    self.isCompleted = isCompleted
    self.sceneNumber = sceneNumber
    self.category = category
    self.name = name
    self.location = location
    self.environment = environment
    self.character = character
    self.note = note
    self.count = count
    self.price = price
    self.referenceImage = referenceImage
    self.responsibleTeam = responsibleTeam
  }
}

extension Prop {
  static var sample: Prop {
    Prop(
      id: UUID(),
      isCompleted: false,
      sceneNumber: 1,
      category: .major,
      name: "책상",
      location: "상훈의집/방",
      environment: .interior,
      character: "상훈",
      note: "낡은 창고"
    )
  }
}

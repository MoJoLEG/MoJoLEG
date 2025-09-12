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
  var majorLocation: String
  var minorLocation: String?
  var environment: PropEnvironment
  var character: String?
  var note: String
  var count: Int?
  var price: Double?
  var referenceImage: Data?
  var responsibleTeam: String?
  var originalText: String

  init(
    id: UUID,
    isCompleted: Bool,
    sceneNumber: Int,
    category: PropCategory,
    name: String,
    majorLocation: String,
    minorLocation: String? = nil,
    environment: PropEnvironment,
    character: String? = nil,
    note: String,
    count: Int? = nil,
    price: Double? = nil,
    referenceImage: Data? = nil,
    responsibleTeam: String? = nil,
    originalText: String
  ) {
    self.id = id
    self.isCompleted = isCompleted
    self.sceneNumber = sceneNumber
    self.category = category
    self.name = name
    self.majorLocation = majorLocation
    self.minorLocation = minorLocation
    self.environment = environment
    self.character = character
    self.note = note
    self.count = count
    self.price = price
    self.referenceImage = referenceImage
    self.responsibleTeam = responsibleTeam
    self.originalText = originalText
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
      majorLocation: "상훈의집",
      minorLocation: "방",
      environment: .interior,
      character: "상훈",
      note: "낡은 창고",
      originalText: "책상"
    )
  }
}

extension Prop {
  func copy() -> Prop {
    Prop(
      id: UUID(),
      isCompleted: isCompleted,
      sceneNumber: sceneNumber,
      category: category,
      name: name,
      majorLocation: majorLocation,
      minorLocation: minorLocation,
      environment: environment,
      character: character,
      note: note,
      count: count,
      price: price,
      referenceImage: referenceImage,
      responsibleTeam: responsibleTeam,
      originalText: originalText
    )
  }
}

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
  private var categoryRawValue: Int
  var category: PropCategory {
    get {
      PropCategory(rawValue: categoryRawValue) ?? .uncategorized
    }
    set {
      categoryRawValue = newValue.rawValue
    }
  }
  var name: String
  var majorLocation: String
  var minorLocation: String?
  private var environmentRawValue: Int
  var environment: PropEnvironment {
    get {
      PropEnvironment(rawValue: environmentRawValue) ?? .interior
    }
    set {
      environmentRawValue = newValue.rawValue
    }
  }
  var character: String?
  var note: String
  var referenceImage: Data?
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
    referenceImage: Data? = nil,
    originalText: String
  ) {
    self.id = id
    self.isCompleted = isCompleted
    self.sceneNumber = sceneNumber
    self.categoryRawValue = category.rawValue
    self.name = name
    self.majorLocation = majorLocation
    self.minorLocation = minorLocation
    self.environmentRawValue = environment.rawValue
    self.character = character
    self.note = note
    self.referenceImage = referenceImage
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
      referenceImage: referenceImage,
      originalText: originalText
    )
  }
}

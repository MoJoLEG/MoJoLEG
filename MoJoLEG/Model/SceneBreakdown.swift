//
//  SceneBreakdown.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Foundation
import SwiftData

@Model
class SceneBreakdown {
    @Attribute(.unique) var id: UUID
    var sceneNumber: String
    var majorLocations: [String]
    var minorLocations: [String]
    var ioType: String          // "실내" | "야외" | "실내/야외"
    var timeOfDay: String       // "M" | "D" | "E" | "N"
    var sceneSummary: String
    var notes: String?

    // ==== M:N: Scene ↔ CharacterItem ====
    // 역할(주/조연)별로 분리된 다대다 관계
    @Relationship(deleteRule: .nullify)
    var mainCharacters: [CharacterItem] = []

    @Relationship(deleteRule: .nullify)
    var subCharacters: [CharacterItem] = []

    // ==== M:N: Scene ↔ PropItem ====
    // 소품 카테고리별로 분리된 다대다 관계
    @Relationship(deleteRule: .nullify)
    var setPieces: [PropItem] = []

    @Relationship(deleteRule: .nullify)
    var handProps: [PropItem] = []

    @Relationship(deleteRule: .nullify)
    var unidentifiedProps: [PropItem] = []

    init(
        id: UUID = UUID(),
        sceneNumber: String,
        majorLocations: [String] = [],
        minorLocations: [String] = [],
        ioType: String,
        timeOfDay: String,
        sceneSummary: String,
        notes: String? = nil
    ) {
        self.id = id
        self.sceneNumber = sceneNumber
        self.majorLocations = majorLocations
        self.minorLocations = minorLocations
        self.ioType = ioType
        self.timeOfDay = timeOfDay
        self.sceneSummary = sceneSummary
        self.notes = notes
    }
}

@Model
class CharacterItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var notes: String?

    init(id: UUID = UUID(), name: String, notes: String? = nil) {
        self.id = id
        self.name = name
        self.notes = notes
    }
}

@Model
class PropItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String?

    init(id: UUID = UUID(), name: String, descriptionText: String? = nil) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
    }
}

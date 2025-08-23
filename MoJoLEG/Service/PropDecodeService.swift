//
//  PropDecodeService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import Foundation

enum PropDecodeServiceError: Error, LocalizedError {
  case failedToConvertStringToData
}

final class PropDecodeService {
  static let shared = PropDecodeService()
  
  private init() {}
  
  func decode(_ text: String) throws -> [Prop] {
    let jsonDecoder = JSONDecoder()
    
    guard let data = text.data(using: .utf8) else { throw PropDecodeServiceError.failedToConvertStringToData }
    
    let propDtos = try jsonDecoder.decode([PropDto].self, from: data)
    
    let props = propDtos.map { $0.toProp() }
    
    return props
  }
}


// MARK: - Prop DTO

struct PropDto: Decodable {
  let sceneNumber: Int
  let propsType: String?
  let propsName: String
  let majorLocation: String
  let minorLocation: String?
  let ieType: String
  let character: String?
  let note: String

  // JSON 키와 Swift 프로퍼티 매핑
  enum CodingKeys: String, CodingKey {
    case sceneNumber = "scene_number"
    case propsType = "props_type"
    case propsName = "props_name"
    case majorLocation = "major_location"
    case minorLocation = "minor_location"
    case ieType = "ie_type"
    case character
    case note
  }
}

extension PropDto {
  func toProp() -> Prop {
    var category = PropCategory.uncategorized
    switch propsType {
    case "big":
      category = .major
    case "small":
      category = .minor
    case "null":
      category = .uncategorized
    default:
      break
    }

    var environment = PropEnvironment.interior
    switch ieType {
    case "i":
      environment = .interior
    case "e":
      environment = .exterior
    default:
      break
    }

    return Prop(
      id: UUID(),
      isCompleted: false,
      sceneNumber: sceneNumber,
      category: category,
      name: propsName,
      majorLocation: majorLocation,
      minorLocation: minorLocation,
      environment: environment,
      character: character,
      note: note
    )
  }
}

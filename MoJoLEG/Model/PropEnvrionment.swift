//
//  PropEnvrionment.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

enum PropEnvironment: Codable {
  case interior
  case exterior
}

extension PropEnvironment {
  var toString: String {
    switch self {
    case .interior:
      "I"
    case .exterior:
      "E"
    }
  }
}

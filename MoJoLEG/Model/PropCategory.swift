//
//  PropCategory.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

enum PropCategory: Codable {
  case major
  case minor
  case uncategorized
}

extension PropCategory {
  var toString: String {
    switch self {
    case .major:
      "대도구"
    case .minor:
      "소도구"
    case .uncategorized:
      "미분류"
    }
  }
}

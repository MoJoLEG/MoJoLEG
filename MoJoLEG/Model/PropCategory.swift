//
//  PropCategory.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

enum PropCategory: Int, Codable, CaseIterable {
  case major
  case minor
  case uncategorized
}

extension PropCategory: CustomStringConvertible {
  var description: String {
    switch self {
    case .major:
      String(localized: "대도구")
    case .minor:
      String(localized: "소도구")
    case .uncategorized:
      String(localized: "미분류")
    }
  }
}

extension PropCategory {
  var toHighlight: Color {
    switch self {
    case .major:
      Color.highlightYellow
    case .minor:
      Color.highlightMint
    case .uncategorized:
      Color.highlightPink
    }
  }
}

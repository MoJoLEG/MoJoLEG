//
//  SeperateSceneService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Foundation

final class SeperateSceneService {
  static let shared = SeperateSceneService()

  private init() {}

  func separteScenes(scenario: String) -> [ScenarioScene]? {
    let pattern = #".*#\d+(-\d+)?[^\n]*"#

    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let matches = regex.matches(
        in: scenario,
        range: NSRange(scenario.startIndex..., in: scenario)
      )

      var scenes: [ScenarioScene] = []
      var lastIndex = scenario.startIndex

      for match in matches {
        let matchRange = Range(match.range, in: scenario)!

        if lastIndex < matchRange.lowerBound {
          // 이전 씬부터 현재 씬 시작 직전까지 잘라서 저장
          let content = String(
            scenario[lastIndex..<matchRange.lowerBound]
          ).trimmingCharacters(in: .whitespacesAndNewlines)
          if !content.isEmpty {
            let scene = ScenarioScene(
              id: UUID(),
              sceneNumber: nil,
              title: "",
              content: content
            )
            scenes.append(scene)
          }
        }

        lastIndex = matchRange.lowerBound
      }

      // 마지막 씬까지 저장
      let lastScene = String(scenario[lastIndex...]).trimmingCharacters(
        in: .whitespacesAndNewlines
      )
      if !lastScene.isEmpty {
        let scene = ScenarioScene(
          id: UUID(),
          sceneNumber: nil,
          title: "",
          content: lastScene
        )
        scenes.append(scene)
      }

      // 결과 출력
      return scenes
    } catch {
      print("Regex error: \(error.localizedDescription)")
    }
    return nil
  }
}

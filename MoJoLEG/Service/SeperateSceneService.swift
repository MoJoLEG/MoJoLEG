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

  func seperateScenes(scenario: String) -> [ScenarioScene]? {
      let pattern = #"^(?:S#?\d+(-\d+)?\.?|#\d+\.?|\d+\. |S#?(인트로|프롤로그|에필로그|쿠키|COOKIE|PROLOGUE)|인트로|프롤로그|에필로그|쿠키|COOKIE|PROLOGUE)"#

    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
      let matches = regex.matches(
        in: scenario,
        range: NSRange(scenario.startIndex..., in: scenario)
      )

      var scenes: [ScenarioScene] = []
      var lastIndex = scenario.startIndex
      var order: Int = 0
      
      for (index, match) in matches.enumerated() {
        let matchRange = Range(match.range, in: scenario)!

        if lastIndex < matchRange.lowerBound {
          // 이전 씬부터 현재 씬 시작 직전까지 잘라서 저장
          let content = String(
            scenario[lastIndex..<matchRange.lowerBound]
          ).trimmingCharacters(in: .whitespacesAndNewlines)
          if !content.isEmpty {
            // Use previous match header as title and extract number
            var titleLine = ""
            var number: String? = nil
            if index > 0 {
              let prevMatch = matches[index - 1]
              let prevRange = Range(prevMatch.range, in: scenario)!
              titleLine = String(scenario[prevRange]).trimmingCharacters(in: .whitespacesAndNewlines)
              number = titleLine.filter { $0.isNumber }
            } else {
              // No previous match, so no title or number
              titleLine = ""
              number = nil
            }
            let scene = ScenarioScene(
              id: UUID(),
              order: order,
              sceneNumber: number,
              title: titleLine,
              content: content
            )
            order += 1
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
        // Split first line as title
        let lines = lastScene.components(separatedBy: .newlines)
        let titleLine = lines.first ?? ""
        let number = titleLine.filter { $0.isNumber }
        let scene = ScenarioScene(
          id: UUID(),
          order: order,
          sceneNumber: number,
          title: titleLine,
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

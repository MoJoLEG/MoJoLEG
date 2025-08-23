//
//  UpstageService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//


import Alamofire
import Foundation
import SwiftUI

private func loadPromptText() -> String {
    guard let url = Bundle.main.url(forResource: "Prompter", withExtension: "txt"),
          let text = try? String(contentsOf: url, encoding: .utf8) else {
        fatalError("Prompt.txt not found or unreadable")
    }
    return text
}

final class UpstageService {
    static let shared = UpstageService()

    private init() {}

    func request(_ upstageRequestDto: UpstageRequestDto) async throws
        -> UpstageResponseDto
    {
        let router = UpstageRouter.request(upstageRequestDto)

        return try await AF.request(router)
            .validate()
            .serializingDecodable(UpstageResponseDto.self)
            .value
    }

    /// Sends a request where `Prompt.txt` is used as the system prompt and `userText` becomes the user message.
    func requestWithPrompt(userText: String) async throws -> UpstageResponseDto {
        let messages: [UpstageMessageRequestDto] = [
            UpstageMessageRequestDto(role: "system", content: loadPromptText()),
            UpstageMessageRequestDto(role: "user", content: userText)
        ]
        let dto = UpstageRequestDto(messages: messages)
        print("Check")
        return try await request(dto)
    }

    /// Processes an array of scenes in order, sending each one to Upstage sequentially.
    func processScenesInOrder(_ scenes: [String]) async -> [UpstageResponseDto] {
        var results: [UpstageResponseDto] = []
        for (index, scene) in scenes.enumerated() {
            do {
                let response = try await requestWithPrompt(userText: scene)
                results.append(response)
                print("✅ Scene \(index+1) 완료")
            } catch {
                print("❌ Scene \(index+1) 에러: \(error)")
            }
        }
        return results
    }

    /// Processes scenes concurrently in batches, preserving original order.
    /// - Parameters:
    ///   - scenes: Array of scene texts.
    ///   - concurrency: Max number of simultaneous requests (default 8).
    /// - Returns: Responses in the same order as input (failed ones are skipped).
    func processScenesConcurrently(_ scenes: [String], concurrency: Int = 15) async -> [UpstageResponseDto] {
        guard !scenes.isEmpty, concurrency > 0 else { return [] }

        let total = scenes.count
        var orderedResults: [UpstageResponseDto?] = Array(repeating: nil, count: total)

        // Process in batches of `concurrency` to limit simultaneous requests
        for start in stride(from: 0, to: total, by: concurrency) {
            let end = min(start + concurrency, total)
            await withTaskGroup(of: (Int, UpstageResponseDto?).self) { group in
                for i in start..<end {
                    let scene = scenes[i]
                    group.addTask { [scene] in
                        do {
                            let response = try await self.requestWithPrompt(userText: scene)
                            return (i, response)
                        } catch {
                            print("❌ Scene \(i + 1) 에러: \(error)")
                            return (i, nil)
                        }
                    }
                }

                for await (index, response) in group {
                    orderedResults[index] = response
                    if let content = response?.choices.first?.message.content {
                        print("📥 Scene \(index + 1) 응답: \(content)")
                    }
                    print("✅ Scene \(index + 1) 완료 (동시 처리)")
                }
            }
        }

        // Preserve order, drop failures
        return orderedResults.compactMap { $0 }
    }
}

enum UpstageRouter: URLRequestConvertible {
    case request(UpstageRequestDto)

    func asURLRequest() throws -> URLRequest {
        let url = "https://api.upstage.ai/v1/chat/completions"
        var request = try URLRequest(url: url, method: .post)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            request.setValue(
                "Bearer \(apiKey)",
                forHTTPHeaderField: "Authorization"
            )
        }

        switch self {
        case .request(let upstageRequestDto):
            // Prepend system prompt from Prompt.txt
            let systemPrompt = UpstageMessageRequestDto(role: "system", content: loadPromptText())
            var updatedMessages = [systemPrompt]
            updatedMessages.append(contentsOf: upstageRequestDto.messages)
            let mergedDto = UpstageRequestDto(messages: updatedMessages)
            let data = try JSONEncoder().encode(mergedDto)
            request.httpBody = data
        }

        return request
    }
}

// MARK: - Request DTO

nonisolated struct UpstageRequestDto: Encodable, Sendable {
    let model: String
    let messages: [UpstageMessageRequestDto]
    let reasoning_effort: String

    init(messages: [UpstageMessageRequestDto]) {
        self.messages = messages
        self.model = "solar-pro2"
        self.reasoning_effort = "high"
    }
}

struct UpstageMessageRequestDto: Encodable, Sendable {
    let role: String
    let content: String
}

// MARK: - Response DTO

nonisolated struct UpstageResponseDto: Decodable, Sendable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [UpstageChoiceResponseDto]
    let usage: UpstageUsageResponseData
    let system_fingerprint: String?
}

struct UpstageChoiceResponseDto: Decodable, Sendable {
    let index: Int
    let message: UpstageMessageResponseDto
    let logprobs: String?
    let finish_reason: String
}

struct UpstageMessageResponseDto: Decodable, Sendable {
    let role: String
    let content: String
}

struct UpstageUsageResponseData: Decodable, Sendable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

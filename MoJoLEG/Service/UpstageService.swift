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
    guard let url = Bundle.main.url(forResource: "Prompt", withExtension: "txt"),
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
    @MainActor
    func requestWithPrompt(userText: String) async throws -> UpstageResponseDto {
        let messages: [UpstageMessageRequestDto] = [
            UpstageMessageRequestDto(role: "system", content: loadPromptText()),
            UpstageMessageRequestDto(role: "user", content: userText)
        ]
        let dto = UpstageRequestDto(messages: messages)
        print("Check")
        return try await request(dto)
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

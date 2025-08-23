//
//  UpstageService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Alamofire
import Foundation
import SwiftUI

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
            let payload = try upstageRequestDto.asDictionary()
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
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

extension UpstageRequestDto {
    /// Builds a dictionary payload including `response_format` (json_schema) for Scene Analysis
    func asDictionary() throws -> [String: Any] {
        let messagesArray: [[String: Any]] = messages.map { [
            "role": $0.role,
            "content": $0.content
        ] }
        
        let responseFormat: [String: Any] = [
            "type": "json_schema",
            "json_schema": [
                "name": "scene_analysis",
                "strict": true,
                "schema": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "scene_number": ["type": ["string", "number"]],
                            "major_locations": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "minor_locations": [
                                "type": "array",
                                "items": ["type": "string"]
                            ],
                            "io_type": [
                                "type": "string",
                                "enum": ["실내", "야외", "실내/야외"]
                            ],
                            "time_of_day": [
                                "type": "string",
                                "enum": ["M", "D", "E", "N"]
                            ],
                            "scene_summary": ["type": "string"],
                            "characters": [
                                "type": "object",
                                "properties": [
                                    "Main_Characters": [
                                        "type": "array",
                                        "items": ["type": "string"]
                                    ],
                                    "Sub_Characters": [
                                        "type": "array",
                                        "items": ["type": "string"]
                                    ]
                                ],
                                "required": ["Main_Characters", "Sub_Characters"]
                            ],
                            "props": [
                                "type": "object",
                                "properties": [
                                    "set_pieces": [
                                        "type": "array",
                                        "items": ["type": "string"]
                                    ],
                                    "hand_props": [
                                        "type": "object",
                                        "properties": [
                                            "": ["type": "array", "items": ["type": "string"]],
                                            "미상": ["type": "array", "items": ["type": "string"]]
                                        ],
                                        "required": ["", "미상"]
                                    ],
                                    "unidentified_props": [
                                        "type": "array",
                                        "items": ["type": "string"]
                                    ]
                                ],
                                "required": ["set_pieces", "hand_props", "unidentified_props"]
                            ],
                            "notes": ["type": "string"]
                        ],
                        "required": [
                            "scene_number",
                            "major_locations",
                            "minor_locations",
                            "io_type",
                            "time_of_day",
                            "scene_summary",
                            "characters",
                            "props",
                            "notes"
                        ]
                    ]
                ]
            ]
        ]
        
        var dict: [String: Any] = [
            "model": model,
            "messages": messagesArray,
            "reasoning_effort": reasoning_effort,
            "response_format": responseFormat
        ]
        return dict
    }
}

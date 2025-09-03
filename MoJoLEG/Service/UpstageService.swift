//
//  UpstageService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import Alamofire
import Foundation

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
      let data = try JSONEncoder().encode(upstageRequestDto)
      request.httpBody = data
    }

    return request
  }
}

// MARK: - Request DTO

nonisolated struct UpstageRequestDto: Encodable, Sendable {
  let model: String
  let messages: [UpstageMessageRequestDto]
  let reasoningEffort: String
  let responseFormat: String?

  enum CodingKeys: String, CodingKey {
    case model
    case messages
    case reasoningEffort = "reasoning_effort"
    case responseFormat = "response_format"
  }

  init(
    model: String = "solar-pro2",
    messages: [UpstageMessageRequestDto],
    reasoningEffort: String = "high",
    responseFormat: String? = nil
  ) {
    self.model = model
    self.messages = messages
    self.reasoningEffort = reasoningEffort
    self.responseFormat = responseFormat
  }

  nonisolated func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(model, forKey: .model)
    try container.encode(messages, forKey: .messages)
    try container.encode(reasoningEffort, forKey: .reasoningEffort)

    if let responseFormat {
      if let data = responseFormat.data(using: .utf8),
        let jsonObject = try? JSONSerialization.jsonObject(with: data),
        JSONSerialization.isValidJSONObject(jsonObject)
      {
        try container.encode(
          AnyCodable(value: jsonObject),
          forKey: .responseFormat
        )
      } else {
        try container.encode(responseFormat, forKey: .responseFormat)
      }
    }
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

// MARK: - AnyCodable

nonisolated struct AnyCodable: Codable {
  let value: Any

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let string = try? container.decode(String.self) {
      value = string
    } else if let int = try? container.decode(Int.self) {
      value = int
    } else if let double = try? container.decode(Double.self) {
      value = double
    } else if let bool = try? container.decode(Bool.self) {
      value = bool
    } else if let array = try? container.decode([AnyCodable].self) {
      value = array.map { $0.value }  // AnyCodable 배열을 Any 배열로 변환
    } else if let dict = try? container.decode([String: AnyCodable].self) {
      value = dict.mapValues { $0.value }  // AnyCodable 딕셔너리를 Any 딕셔너리로 변환
    } else {
      value = NSNull()
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch value {
    case let string as String:
      try container.encode(string)
    case let int as Int:
      try container.encode(int)
    case let double as Double:
      try container.encode(double)
    case let bool as Bool:
      try container.encode(bool)
    case let array as [Any]:
      // [Any]를 [AnyCodable]로 변환
      let codableArray = array.map { AnyCodable(value: $0) }
      try container.encode(codableArray)
    case let dict as [String: Any]:
      // [String: Any]를 [String: AnyCodable]로 변환
      let codableDict = dict.mapValues { AnyCodable(value: $0) }
      try container.encode(codableDict)
    default:
      try container.encodeNil()
    }
  }

  // 편의 초기화
  init(value: Any) {
    self.value = value
  }
}

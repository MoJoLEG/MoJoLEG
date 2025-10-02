//
//  UpstageDocumentParsingService.swift
//  MoJoLEG
//
//  Created by 나현흠 on 10/2/25.
//

import Foundation
import Alamofire
internal import UIKit

enum UpstageDocumentParsingError: Error, LocalizedError {
  case emptyText
  var errorDescription: String? {
    switch self {
    case .emptyText:
      return "문서에서 텍스트를 추출하지 못했습니다."
    }
  }
}

// MARK: - OCR Mode

enum OCRMode: String {
  case auto = "auto"
  case force = "force"
  case none  = "none"
}

// MARK: - Router

enum UpstageDocumentRouter: URLRequestConvertible {
  case parse(fileURL: URL, ocr: OCRMode, base64Encoding: [String]?, model: String)

  func asURLRequest() throws -> URLRequest {
    let url = "https://api.upstage.ai/v1/document-digitization"
    var request = try URLRequest(url: url, method: .post)
    request.setValue("application/json", forHTTPHeaderField: "Accept")

    // API Key는 Info.plist의 "API_KEY" 사용 (다른 파일 건드리지 않음)
    if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
      request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }

    return request
  }
}

// MARK: - Local AnyCodable (DocAnyCodable)

struct DocAnyCodable: Codable, Sendable {
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
    } else if let array = try? container.decode([DocAnyCodable].self) {
      value = array.map { $0.value }
    } else if let dict = try? container.decode([String: DocAnyCodable].self) {
      value = dict.mapValues { $0.value }
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
      try container.encode(array.map { DocAnyCodable(value: $0) })
    case let dict as [String: Any]:
      try container.encode(dict.mapValues { DocAnyCodable(value: $0) })
    default:
      try container.encodeNil()
    }
  }

  init(value: Any) {
    self.value = value
  }
}

// MARK: - HTML → Plain Text helper (Approach 2-(b))
private extension String {
  /// Convert HTML (from Document Parsing) into readable plain text.
  /// 1) Pre-replace common block/line tags to preserve structure.
  /// 2) Try NSAttributedString(html) → .string
  /// 3) Fallback: strip tags and decode common entities.
  func htmlStripped() -> String {
    var pre = self
    // Preserve basic structure before rich parsing
    pre = pre.replacingOccurrences(of: "(?i)<br\\s*/?>", with: "\n", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)</p>", with: "\n\n", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)<li\\b[^>]*>", with: "\n• ", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)</h[1-6]>", with: "\n\n", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)</div>", with: "\n", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)</tr>", with: "\n", options: .regularExpression)
    pre = pre.replacingOccurrences(of: "(?i)</td>", with: "\t", options: .regularExpression)

    // Attempt rich HTML parsing
    if let data = pre.data(using: .utf8),
       let attributed = try? NSAttributedString(
          data: data,
          options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
          ],
          documentAttributes: nil
       ) {
      return attributed.string
    }

    // Fallback: strip tags + decode entities
    let noTags = pre.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
    return noTags
      .replacingOccurrences(of: "&nbsp;", with: " ")
      .replacingOccurrences(of: "&amp;",  with: "&")
      .replacingOccurrences(of: "&lt;",   with: "<")
      .replacingOccurrences(of: "&gt;",   with: ">")
      .replacingOccurrences(of: "&quot;", with: "\"")
      .replacingOccurrences(of: "&#39;",  with: "'")
  }
}

// MARK: - Response DTO

struct UpstageDocumentParsingResponseDto: Decodable, Sendable {
  let raw: [String: DocAnyCodable]

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.raw = try container.decode([String: DocAnyCodable].self)
  }

  subscript(key: String) -> Any? { raw[key]?.value }

  /// HTML/Markdown 중심의 Parsing 응답을 "순수 텍스트"로 정규화
  var extractedText: String? {
    // 1) Prefer plain text when requested via output_formats=['text']
    if let text = raw["text"]?.value as? String {
      let stripped = text.htmlStripped().trimmingCharacters(in: .whitespacesAndNewlines)
      if !stripped.isEmpty { return stripped }
    }
    // 2) Fallback to markdown
    if let md = raw["markdown"]?.value as? String {
      let stripped = md.htmlStripped().trimmingCharacters(in: .whitespacesAndNewlines)
      if !stripped.isEmpty { return stripped }
    }
    // 3) Fallback to html
    if let html = raw["html"]?.value as? String {
      let stripped = html.htmlStripped().trimmingCharacters(in: .whitespacesAndNewlines)
      if !stripped.isEmpty { return stripped }
    }
    // 4) Fallback to content / full_text
    let rawText =
      (raw["content"]?.value as? String) ??
      (raw["full_text"]?.value as? String)
    guard let rawText else { return nil }
    let stripped = rawText.htmlStripped().trimmingCharacters(in: .whitespacesAndNewlines)
    return stripped.isEmpty ? nil : stripped
  }

  /// Base64 테이블 섹션 (옵션)
  var base64Tables: [String] {
    raw["table"]?.value as? [String] ?? []
  }
}

// MARK: - Service

final class UpstageDocumentParsingService {
  static let shared = UpstageDocumentParsingService()
  private init() {}

  /// Upstage Document Digitization API 호출 (multipart/form-data)
  @discardableResult
  func parseDocument(
    at fileURL: URL,
    ocr: OCRMode = .force,
    outputFormats: [String] = ["text"],
    base64Encoding: [String]? = ["table"],
    model: String = "document-parse"
  ) async throws -> UpstageDocumentParsingResponseDto {
    let router = UpstageDocumentRouter.parse(
      fileURL: fileURL,
      ocr: ocr,
      base64Encoding: base64Encoding,
      model: model
    )

    return try await AF.upload(
      multipartFormData: { formData in
        // 파일 파트
        formData.append(fileURL, withName: "document")

        // 파이썬 샘플과 동일한 필드 유지
        formData.append(ocr.rawValue.data(using: .utf8)!, withName: "ocr")

        // Request plain text via output_formats (e.g., "['text']").
        let ofList = outputFormats.isEmpty ? ["text"] : outputFormats
        let ofFormatted = "[\(ofList.map { "'\($0)'" }.joined(separator: ", "))]"
        formData.append(ofFormatted.data(using: .utf8)!, withName: "output_formats")

        // Minimize non-text payload
        formData.append("false".data(using: .utf8)!, withName: "coordinates")
        formData.append("false".data(using: .utf8)!, withName: "chart_recognition")
        formData.append("false".data(using: .utf8)!, withName: "merge_multipage_tables")

        // "['table']" 포맷으로 전송 (호환성)
        if let base64Encoding, !base64Encoding.isEmpty {
          let formatted = "[\(base64Encoding.map { "'\($0)'" }.joined(separator: ", "))]"
          formData.append(formatted.data(using: .utf8)!, withName: "base64_encoding")
        }

        formData.append(model.data(using: .utf8)!, withName: "model")
      },
      with: router
    )
    .validate()
    .serializingDecodable(UpstageDocumentParsingResponseDto.self)
    .value
  }

  /// Convenience: 텍스트만 필요할 때 사용
  func parseDocumentText(
    at fileURL: URL,
    ocr: OCRMode = .force,
    model: String = "document-parse"
  ) async throws -> String {
    let dto = try await parseDocument(
      at: fileURL,
      ocr: ocr,
      outputFormats: ["text"],
      base64Encoding: nil,
      model: model
    )
    guard let text = dto.extractedText, !text.isEmpty else {
      throw UpstageDocumentParsingError.emptyText
    }
    return text
  }
}

//
//  ResponseFormat.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/26/25.
//

enum ResponseFormat {
  static let `default`: String = """
    {
      "type": "json_schema",
      "json_schema": {
        "name": "scene_prop",
        "strict": true,
        "schema": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "scene_number": {
                "type": "string",
                "description": "씬 번호. `S#`은 제외한 숫자."
              },
              "props_type": {
                "type": "string",
                "enum": ["big", "small", "null"],
                "description": "소품의 종류 (big=대도구, small=소도구, null=정체불명/묶음)."
              },
              "props_name": {
                "type": "string",
                "description": "소품 이름 (한국어)."
              },
              "major_location": {
                "type": "string",
                "description": "주요 장소 (집, 학교, 거리 등)."
              },
              "minor_location": {
                "type": ["string", "null"],
                "description": "세부 장소 (거실, 주방 등). 없으면 null."
              },
              "ie_type": {
                "type": "string",
                "enum": ["i", "e", "i/e"],
                "description": "실내(i), 실외(e), 혼합(i/e)."
              },
              "character": {
                "type": ["string", "null"],
                "description": "소품과 연관된 등장인물. 없으면 null."
              },
              "note": {
                "type": "string",
                "maxLength": 25,
                "description": "소품에 대한 간단한 한국어 메모 (25자 이내)."
              },
              "original_text": {
                "type": "string",
                "description": "시나리오에 묘사된 소품에 대한 원문."
              }
            },
            "required": [
              "scene_number",
              "props_type",
              "props_name",
              "major_location",
              "ie_type",
              "note",
              "original_text"
            ]
          }
        }
      }
    }
    """
}

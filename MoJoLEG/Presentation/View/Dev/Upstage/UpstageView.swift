//
//  UpstageView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct UpstageView: View {
  @State private var prompt: String = ""
  @State private var responses: [UpstageResponseDto] = []
  @State private var requestTask: Task<Void, Never>? = nil
  @State private var isUsingResponseFormat: Bool = false

  var body: some View {
    VStack {
      responseList

      HStack {
        TextField("Prompt", text: $prompt)
        responseFormatButton
        requestButton
      }
      .padding()
      .background(
        .regularMaterial,
        in: RoundedRectangle(cornerRadius: 16)
      )
    }
    .padding()
  }

  private var responseList: some View {
    ScrollView {
      ForEach(responses, id: \.id) { response in
        if let firstChoice = response.choices.first {
          let content = firstChoice.message.content

          VStack {
            Text(content)
            if let props = try? PropDecodeService.shared.decode(content) {
              ForEach(props) { prop in
                Text(prop.name)
              }
            }
          }
          .padding()
          .background(
            .ultraThickMaterial,
            in: RoundedRectangle(cornerRadius: 16)
          )
        }
      }
    }
  }

  private var responseFormatButton: some View {
    Button(
      isUsingResponseFormat ? "Not Use Response Format" : "Use Response Format"
    ) {
      isUsingResponseFormat.toggle()
    }
    .buttonStyle(.bordered)
  }

  private var requestButton: some View {
    Button("Request") {
      requestTask = Task {
        let currentPrompt = prompt
        prompt = ""
        defer {
          Task { @MainActor in
            requestTask = nil
          }
        }

        let requestDto = UpstageRequestDto(
          messages: [
            UpstageMessageRequestDto(
              role: "user",
              content: currentPrompt
            )
          ],
          responseFormat: isUsingResponseFormat ? ResponseFormat.default : nil
        )
        do {
          let response = try await UpstageService.shared.request(
            requestDto
          )
          responses.append(
            response
          )
        } catch {
          print(error.localizedDescription)
        }
      }
    }
    .buttonStyle(.borderedProminent)
    .disabled(requestTask != nil)
  }
}

#Preview {
  UpstageView()
}

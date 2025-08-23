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
    @State private var isProcessing: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                ForEach(responses, id: \.id) { response in
                    if let firstChoice = response.choices.first {
                        let content = firstChoice.message.content

                        Text(content)
                            .padding()
                            .background(
                                .ultraThickMaterial,
                                in: RoundedRectangle(cornerRadius: 16)
                            )

                    }
                }
            }
            HStack {
                TextField("Prompt", text: $prompt)
                Button("Request") {
                    Task {
                        prompt = ""

                        isProcessing = true
                        defer {
                            isProcessing = false
                        }

                        let requestDto = UpstageRequestDto(messages: [
                            UpstageMessageRequestDto(
                                role: "user",
                                content: prompt
                            )
                        ])
                        do {
                            responses.append(
                                try await UpstageService.shared.request(
                                    requestDto
                                )
                            )
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isProcessing)
            }
            .padding()
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .padding()
    }
}

#Preview {
    UpstageView()
}

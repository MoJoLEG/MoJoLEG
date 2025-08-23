//
//  ExtractTextService.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import PDFKit
internal import UniformTypeIdentifiers

final class ExtractTextService {
    static let shared = ExtractTextService()

    private init() {}

    func extractText(from url: URL, fileType: UTType) -> String? {
        switch fileType {
        case .pdf:
            return extractTextFromPDF(from: url)
        default:
            return nil
        }
    }

    private func extractTextFromPDF(from url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        var all = ""
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            all += (page.string ?? "") + "\n"
        }
        return all.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

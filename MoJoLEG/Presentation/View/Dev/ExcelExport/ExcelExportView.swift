//
//  ExcelExportView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/24/25.
//

import SwiftUI

struct ExcelExportView: View {
  @State private var isPresented: Bool = false
  @State private var selectedFile: URL? = nil

  var body: some View {
    VStack {
      Button("Export") {
        let url = ExcelService.shared.createExcelFile(.sample)

        selectedFile = url
      }

      if let selectedFile {
        ShareLink(item: selectedFile)
      }
    }
  }
}

#Preview {
  ExcelExportView()
}

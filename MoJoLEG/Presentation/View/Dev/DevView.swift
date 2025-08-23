//
//  DevView.swift
//  MoJoLEG
//
//  Created by 정희균 on 8/23/25.
//

import SwiftUI

struct DevView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Upstage") {
                    myView()
                }
                NavigationLink("Extract Text") {
                    ExtractTextView()
                }
                NavigationLink("Seperate Scene") {
                    SeperateSceneView()
                }
            }
            .navigationTitle("Dev")
        }
    }
}

#Preview {
    DevView()
}

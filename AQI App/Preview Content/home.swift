//
//  home.swift
//  AQI App
//
//  Created by Calvin Lynch on 12/02/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to My Air Quality Metrics")
            Text("View Live Updates in the Air Quality Tab")
        }
        .padding()
    }
}


struct home_preview: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


//
//  CombinedView.swift
//  AQI App
//
//  Created by Calvin Lynch on 26/02/2025.
//

import SwiftUI

struct CombinedAirQualityView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ViewAirQualityData()
                    .padding(.bottom, 20)

                RecommendationsView()
            }
            .padding()
        }
        .navigationTitle("Air Quality & Recommendations")
    }
}

#Preview {
    CombinedAirQualityView()
}

//
//  AQI_AppApp.swift
//  AQI App
//
//  Created by Calvin Lynch on 05/02/2025.
//

import SwiftUI

@main
struct AQI_AppApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                CombinedAirQualityView()
                    .tabItem {
                        Label("Air Quality", systemImage: "wind")
                    }
            
            }
        }
    }
}

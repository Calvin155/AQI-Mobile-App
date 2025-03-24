import SwiftUI

struct RecommendationsView: View {
    @State private var pm1_0: Double = 0
    @State private var pm2_5: Double = 0
    @State private var pm10: Double = 0
    @State private var outdoortemperature: Double = 0
    @State private var co2_ppm: Double = 0
    @State private var co2_perc: Double = 0
    @State private var timer: Timer?

    let webServerIp = "52.212.232.158"
    var pmAPI: String { "http://\(webServerIp):8000/aqi_pm_data" }
    var metEireannAPI: String {"https://api.open-meteo.com/v1/forecast?latitude=52.6680&longitude=-8.4756&current=temperature_2m"}
    var co2API: String { "http://\(webServerIp):8000/aqi_co2_temp_humidity_data"}

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                VStack(alignment: .leading, spacing: 10) {
                    recommendationText(for: "PM 1.0", value: pm1_0)
                    recommendationText(for: "PM 2.5", value: pm2_5)
                    recommendationText(for: "PM 10", value: pm10)
                    temperatureRecommendationText()
                    co2RecommendationText()
                }
                .padding()
                Spacer()
            }
            .padding()
            .navigationTitle("Recommendations")
            .onAppear {
                fetchPMData()
                fetchTemperatureData()
                fetchCO2Data() // Fetch CO2 data
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    func recommendationText(for type: String, value: Double) -> some View {
        let recommendation = getPMRecommendation(value: value)
        return VStack(alignment: .leading) {
            Text("\(type): \(String(format: "%.1f", value)) µg/m³")
                .font(.headline)
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    func temperatureRecommendationText() -> some View {
        let recommendation = getTemperatureRecommendation(value: outdoortemperature)
        return VStack(alignment: .leading) {
            Text("Outdoor Temperature: \(String(format: "%.1f", outdoortemperature))°C")
                .font(.headline)
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    func co2RecommendationText() -> some View {
        let recommendation = getCO2Recommendation(value: co2_ppm)
        return VStack(alignment: .leading) {
            Text("CO2 Level: \(String(format: "%.1f", co2_ppm)) ppm, \(String(format: "%.1f", co2_perc))%")
                .font(.headline)
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }


    func getPMRecommendation(value: Double) -> String {
        switch value {
        case 0..<12:
            return "Low Particles - Safe & No Risk of exposure."
        case 12..<35:
            return "Moderate air quality. Sensitive groups should reduce exposure."
        case 35..<55:
            return "Unhealthy for sensitive groups. Consider wearing a mask if indoors."
        case 55..<150:
            return "Unhealthy air quality."
        case 150..<250:
            return "Very unhealthy air. Consider Ventilation."
        default:
            return "Hazardous!"
        }
    }

    func getTemperatureRecommendation(value: Double) -> String {
        switch value {
        case ..<0:
            return "Very Cold! Stay warm and reduce exposure to cold."
        case 0..<10:
            return "Cold weather. Dress warm if going outside."
        case 10..<25:
            return "Comfortable temperature."
        case 25..<35:
            return "Warm weather. Stay hydrated."
        default:
            return "Extremely hot! Stay cool and limit exposure to heat."
        }
    }

    func getCO2Recommendation(value: Double) -> String {
        switch value {
        case ..<400:
            return "Normal CO2 levels - Safe air quality."
        case 400..<1_000:
            return "Slightly High CO2 levels. Improve ventilation if possible but not Dangerous."
        case 1_000..<2_000:
            return "High CO2 levels. Consider ventilating your space."
        case 2_000..<5_000:
            return "Very high CO2 levels. Ventilate The Areas if Possible."
        default:
            return "Hazardous CO2 levels. Extremely High Levels - Leave the Area Now."
        }
    }


    func fetchPMData() {
        guard let url = URL(string: pmAPI) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([AirQualityDataNow].self, from: data)
                        if decodedData.count >= 3 {
                            pm1_0 = decodedData[0].value
                            pm2_5 = decodedData[2].value
                            pm10 = decodedData[1].value
                        }
                    } catch {
                        print("Error decoding PM data: \(error)")
                    }
                } else {
                    print("Error fetching PM data: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }

    struct WeatherDataLocal: Codable {
        struct CurrentWeather: Codable {
            let temperature_2m: Double
        }
        
        let current: CurrentWeather
    }

    func fetchTemperatureData() {
        guard let url = URL(string: metEireannAPI) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching temperature data: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received from MET Éireann API")
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(WeatherDataLocal.self, from: data)
                    outdoortemperature = decodedData.current.temperature_2m
                } catch {
                    print("Error decoding temperature data: \(error)")
                }
            }
        }.resume()
    }

    func fetchCO2Data() {
        guard let url = URL(string: co2API) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching CO2/Temp/Humidity data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No CO2/Temp/Humidity data received")
                return
            }
            
            do {
                let co2Data = try JSONDecoder().decode([AirQualityDataNow].self, from: data)
                DispatchQueue.main.async {
                    if co2Data.count >= 2 {
                        self.co2_ppm = co2Data[0].value
                        self.co2_perc = co2Data[1].value
                    }
                }
            } catch {
                print("Error decoding CO2/Temp/Humidity data: \(error)")
            }
        }.resume()
    }

    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            fetchPMData()
            fetchTemperatureData()
            fetchCO2Data()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RecommendationsView()
}

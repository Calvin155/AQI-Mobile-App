//
//  view_live_data.swift
//  AQI App
//
//  Created by Calvin Lynch on 12/02/2025.
//


import SwiftUI

struct AirQualityDataNow: Decodable {
    let time: String
    let value: Double
}

struct WeatherDataLocal: Decodable {
    let current: CurrentWeatherData
}

struct CurrentWeatherData: Decodable {
    let temperature_2m: Double
    let precipitation: Double
}

struct ViewAirQualityData: View {
    @State private var pm1_0: Double = 0
    @State private var pm2_5: Double = 0
    @State private var pm10: Double = 0
    @State private var co2_ppm: Double = 0
    @State private var co2_perc: Double = 0
    @State private var outdoortemperature: Double = 0
    @State private var timer: Timer?
    @State private var pm1_0Data: [Double] = []
    @State private var pm2_5Data: [Double] = []
    @State private var pm10Data: [Double] = []

    let webServerIp = "52.212.232.158"
    
    var pmAPI: String { "http://\(webServerIp):8000/aqi_pm_data"}
    var co2API: String { "http://\(webServerIp):8000/aqi_co2_temp_humidity_data"}
    var metEireannAPI: String {"https://api.open-meteo.com/v1/forecast?latitude=52.6680&longitude=-8.4756&current=temperature_2m,precipitation"}

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Local Air Quality Data")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top)
                
                VStack(spacing: 10) {
                    HStack {
                        createDataView(title: "CO2%", value: co2_perc, isPercentage: true)
                        createDataView(title: "CO2ppm", value: co2_ppm, isPPM: true)
                        createDataView(title: "Outdoor Temp", value: outdoortemperature, isTemp: true)
                    }
                    HStack {
                        createDataView(title: "PM 1.0", value: pm1_0, isPPM: true)
                        createDataView(title: "PM 2.5", value: pm2_5, isPPM: true)
                        createDataView(title: "PM 10", value: pm10, isPPM: true)
                    }
                }
                
                Spacer()

            }
            .padding()
            .navigationTitle("Air Quality Data")
            .onAppear {
                fetchAirQualityData()
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    func createDataView(title: String, value: Double, isPercentage: Bool = false, isTemp: Bool = false, isPPM: Bool = false) -> some View {
        VStack {
            Text(title)
                .font(.body)
                .foregroundColor(.black)
            
            if isPercentage {
                Text(String(format: "%.1f%%", value))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(width: 80)}
            else if isPPM {
                Text(String(format: "%.1fPPM", value))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(width: 80)}
            else if isTemp {
                Text(String(format: "%.1f°C", value))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(width: 80)}
            else {
                Text(String(format: "%.1f", value))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(width: 80)
            }
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }

    func fetchAirQualityData() {
        fetchPMData()
        fetchCO2Data()
        fetchOutsideMetrics()
    }
    
    func fetchPMData() {
        guard let url = URL(string: pmAPI) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching PM data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No PM data received")
                return
            }
            
            do {
                let pmData = try JSONDecoder().decode([AirQualityDataNow].self, from: data)
                DispatchQueue.main.async {
                    if pmData.count >= 3 {
                        self.pm1_0 = pmData[0].value
                        self.pm2_5 = pmData[2].value
                        self.pm10 = pmData[1].value

                        self.pm1_0Data.append(pmData[0].value)
                        self.pm2_5Data.append(pmData[2].value)
                        self.pm10Data.append(pmData[1].value)
                    }
                }
            } catch {
                print("Error: PM data: \(error)")
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
                print("Error: CO2/Temp/Humidity data: \(error)")
            }
        }.resume()
    }

    
    func fetchOutsideMetrics() {
        guard let url = URL(string: metEireannAPI) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching Met-Eireann API Data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from MET Eireann")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherDataLocal.self, from: data)
                DispatchQueue.main.async {
                    self.outdoortemperature = weatherData.current.temperature_2m
                }
            } catch {
                print("Error: weather data: \(error.localizedDescription)")
            }
        }.resume()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            self.fetchAirQualityData()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ViewAirQualityData_Previews: PreviewProvider {
    static var previews: some View {
        ViewAirQualityData()
    }
}


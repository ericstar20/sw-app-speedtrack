import CoreLocation
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var location = LocationManager()
    @AppStorage("speedUnit") private var unit: SpeedUnit = .kmh
    @State private var maxSpeedMetersPerSecond: Double = 0.0

    private var currentSpeed: Double {
        unit.convert(from: location.speed)
    }

    private var maxSpeed: Double {
        unit.convert(from: maxSpeedMetersPerSecond)
    }

    // Thresholds in m/s so color is consistent regardless of displayed unit:
    // green < 60 km/h (16.67 m/s), yellow 60–100 km/h, red > 100 km/h (27.78 m/s)
    private var speedColor: Color {
        switch location.speed {
        case ..<16.67: return .green
        case 16.67..<27.78: return .yellow
        default: return .red
        }
    }

    private var statusMessage: String? {
        switch location.authStatus {
        case .denied, .restricted:
            return "Enable location access in Settings to track speed."
        case .notDetermined:
            return "Waiting for location permission..."
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("SPEEDTRACK")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.gray)
                    .tracking(4)

                Spacer()

                VStack(spacing: 4) {
                    Text("\(Int(currentSpeed.rounded()))")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(speedColor)
                        .monospacedDigit()
                        .contentTransition(.numericText(value: currentSpeed))
                        .animation(.easeInOut(duration: 0.2), value: currentSpeed)

                    Text(unit.rawValue)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Picker("Unit", selection: $unit) {
                    ForEach(SpeedUnit.allCases, id: \.self) { speedUnit in
                        Text(speedUnit.rawValue).tag(speedUnit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 60)
                .colorScheme(.dark)

                Spacer()

                VStack(spacing: 6) {
                    Text("MAX SPEED")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.gray)
                        .tracking(3)

                    Text("\(Int(maxSpeed.rounded())) \(unit.rawValue)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    Button("Reset") {
                        maxSpeedMetersPerSecond = 0
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                }

                VStack(spacing: 8) {
                    Text(location.locationName)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray.opacity(0.7))

                    if let statusMessage {
                        Text(statusMessage)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gray.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 8)
            }
            .padding()
        }
        .onReceive(location.$speed) { newSpeed in
            if newSpeed > maxSpeedMetersPerSecond {
                maxSpeedMetersPerSecond = newSpeed
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

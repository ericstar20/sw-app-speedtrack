# sw-app-speedtrack — Full Development Specification

## Overview

A personal-use iOS speedometer app built with SwiftUI and CoreLocation. Displays real-time GPS speed in a clean black theme with support for mph and km/h toggle. Designed to be sideloaded on a personal iPhone using a free Apple ID.

---

## Project Info

| Field | Value |
|---|---|
| App Name | SpeedTrack |
| Project Name | sw-app-speedtrack |
| Platform | iOS 16.0+ |
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| IDE | Xcode 15+ |
| Device Target | iPhone (personal use) |
| Distribution | Sideloaded via Xcode (free Apple ID) |
| Developer Account | Free Apple ID (no $99/year) |

---

## Features

| Feature | Description |
|---|---|
| Real-time Speed | GPS-based speed updated every second |
| Unit Toggle | Switch between mph and km/h |
| Black Theme | Full dark UI optimized for dashboard use |
| Always-on Screen | Prevents screen from sleeping while app is open |
| Speed Indicator | Color changes based on speed (green → yellow → red) |
| Current Location | Shows city/area name below speed |
| Max Speed Tracker | Tracks and displays max speed reached in session |
| Reset Button | Resets max speed tracker |

---

## Project Structure

```
sw-app-speedtrack/
├── SpeedTrackApp.swift             # App entry point
├── ContentView.swift               # Main speedometer UI
├── LocationManager.swift           # GPS & speed logic
├── SpeedUnit.swift                 # mph/kmh enum
├── Info.plist                      # Location permissions
└── sw-app-speedtrack.xcodeproj
```

---

## File Specifications

---

### 1. `SpeedUnit.swift`

Defines the speed unit enum used across the app.

```swift
import Foundation

enum SpeedUnit: String, CaseIterable {
    case kmh = "km/h"
    case mph = "mph"

    func convert(from metersPerSecond: Double) -> Double {
        switch self {
        case .kmh:
            return metersPerSecond * 3.6
        case .mph:
            return metersPerSecond * 2.23694
        }
    }
}
```

---

### 2. `LocationManager.swift`

Handles GPS location updates and exposes speed data.

```swift
import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var speed: Double = 0.0          // in meters/second
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String = "Locating..."

    private let geocoder = CLGeocoder()
    private var lastGeocode: Date = .distantPast

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .automotiveNavigation
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let raw = location.speed
        DispatchQueue.main.async {
            self.speed = max(raw, 0)
        }

        // Reverse geocode every 30 seconds to save battery
        if Date().timeIntervalSince(lastGeocode) > 30 {
            lastGeocode = Date()
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let place = placemarks?.first {
                    DispatchQueue.main.async {
                        self.locationName = place.locality
                            ?? place.administrativeArea
                            ?? "Unknown Location"
                    }
                }
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authStatus = manager.authorizationStatus
        }
    }
}
```

---

### 3. `ContentView.swift`

Main UI view with speedometer display, unit toggle, and max speed tracker.

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var location = LocationManager()
    @AppStorage("speedUnit") private var unit: SpeedUnit = .kmh
    @State private var maxSpeed: Double = 0.0

    private var currentSpeed: Double {
        unit.convert(from: location.speed)
    }

    private var speedColor: Color {
        switch currentSpeed {
        case ..<60:  return .green
        case 60..<100: return .yellow
        default:     return .red
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {

                // Header
                Text("SPEEDTRACK")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(4)

                Spacer()

                // Speed Display
                VStack(spacing: 4) {
                    Text("\(Int(currentSpeed))")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundColor(speedColor)
                        .animation(.easeInOut, value: speedColor)
                        .monospacedDigit()

                    Text(unit.rawValue)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.gray)
                }

                // Unit Toggle
                Picker("Unit", selection: $unit) {
                    ForEach(SpeedUnit.allCases, id: \.self) { u in
                        Text(u.rawValue).tag(u)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 60)
                .colorScheme(.dark)

                Spacer()

                // Max Speed
                VStack(spacing: 6) {
                    Text("MAX SPEED")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                        .tracking(3)

                    Text("\(Int(maxSpeed)) \(unit.rawValue)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()

                    Button("Reset") {
                        maxSpeed = 0
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                }

                // Location
                Text(location.locationName)
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .onReceive(location.$speed) { newSpeed in
            let converted = unit.convert(from: newSpeed)
            if converted > maxSpeed {
                maxSpeed = converted
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true  // Keep screen on
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
```

---

### 4. `SpeedTrackApp.swift`

App entry point.

```swift
import SwiftUI

@main
struct SpeedTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
```

---

### 5. `Info.plist` — Required Keys

Add these keys inside your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SpeedTrack needs your location to calculate your current speed.</string>
```

---

## Xcode Setup Steps

1. Open Xcode → **Create New Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `SpeedTrack`
   - Interface: `SwiftUI`
   - Language: `Swift`
4. Rename the project folder to `sw-app-speedtrack`
5. Create all files listed in the project structure above
6. Add location permission key to `Info.plist`
7. Connect your iPhone via USB
8. Go to **Signing & Capabilities** → select your free Apple ID team
9. Press **Run (⌘R)**

---

## Sideloading Notes (Free Apple ID)

| Item | Detail |
|---|---|
| Re-sign frequency | Every **7 days** |
| How to re-sign | Connect iPhone → Run from Xcode again |
| Max sideloaded apps | 3 apps at a time |
| TestFlight | Not available (paid only) |
| Trust profile | Settings → General → VPN & Device Management → Trust |

---

## Permissions Required

| Permission | Reason |
|---|---|
| Location (When In Use) | GPS speed tracking |

---

## Known Limitations

- GPS speed may read **0** when stationary (expected behavior)
- Speed accuracy depends on GPS signal quality
- App must be **open and on screen** for speed tracking (no background mode on free account)
- Re-signing every 7 days is required with a free Apple ID

---

## Future Improvements (Optional)

- Compass/heading indicator
- Trip distance tracker
- Speed limit warnings
- Custom accent color picker
- Apple Watch companion app

---

*Spec version 1.0 — sw-app-speedtrack — Personal use only*
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

import Combine
import GameController

class GameController: ObservableObject {
    let gcController: GCController
    let elements: [ControllerElement]
    
    var name: String {
        gcController.vendorName ?? "Unknown"
    }
    
    var productCategory: String {
        gcController.productCategory
    }
    
    init(_ gcController: GCController) {
        self.gcController = gcController
        self.elements = gcController.physicalInputProfile.elements
            .map { ControllerElement(key: $0, element: $1) }
            .sorted { $0.key < $1.key }
        
        gcController.publisher(for: \.playerIndex).assign(to: &$playerIndex)
        gcController.battery?.publisher(for: \.batteryLevel)
            .map({ BatteryLevel.value($0) }).assign(to: &$batteryLevel)
    }
    
    @Published private(set) var playerIndex: GCControllerPlayerIndex = .indexUnset
    @Published private(set) var batteryLevel: BatteryLevel = .unknown
    
    func setPlayerIndex(_ playerIndex: GCControllerPlayerIndex) {
        gcController.playerIndex = playerIndex
    }
}

enum BatteryLevel {
    case value(Float)
    case unknown
}

extension BatteryLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .value(let value):
            return String(format: "%.0f%%", value * 100)
        case .unknown:
            return "-"
        }
    }
}

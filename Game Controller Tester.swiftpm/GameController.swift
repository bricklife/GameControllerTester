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
    }
    
    @Published private(set) var playerIndex: GCControllerPlayerIndex = .indexUnset
    
    func setPlayerIndex(_ playerIndex: GCControllerPlayerIndex) {
        gcController.playerIndex = playerIndex
    }
}


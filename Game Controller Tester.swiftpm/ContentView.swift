
import SwiftUI
import GameController

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(viewModel.controllers) { gc in
                    let gameController = GameController(gc)
                    NavigationLink {
                        GameControllerDetailView(gameController: gameController)
                            .navigationTitle(gc.name)
                    } label: {
                        GameControllerView(gameController: gameController)
                            .foregroundColor(viewModel.current == gc ? .blue : nil)
                    }
                }
            }
            .navigationTitle("Controllers")
        }
    }
}

extension GCController: Identifiable {}

extension GCController {
    var name: String {
        vendorName ?? "Unknown"
    }
}

class ViewModel: ObservableObject {
    
    @Published var controllers: [GCController] = []
    @Published var current: GCController? = nil
    
    var virtualController: GCVirtualController?
    
    init() {
        NotificationCenter.default.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
            print(".GCControllerDidConnect", (notification.object as? GCController)?.vendorName ?? "Unknown")
            self?.update()
        }
        NotificationCenter.default.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] notification in
            print(".GCControllerDidDisconnect", (notification.object as? GCController)?.vendorName ?? "Unknown")
            self?.update()
        }
        NotificationCenter.default.addObserver(forName: .GCControllerDidBecomeCurrent, object: nil, queue: .main) { [weak self] notification in
            print(".GCControllerDidBecomeCurrent", (notification.object as? GCController)?.vendorName ?? "Unknown")
            self?.current = notification.object as? GCController
        }
        NotificationCenter.default.addObserver(forName: .GCControllerDidStopBeingCurrent, object: nil, queue: .main) { notification in
            print(".GCControllerDidStopBeingCurrent", (notification.object as? GCController)?.vendorName ?? "Unknown")
        }
        
        //createVC()
    }
    
    func scan() {
        GCController.startWirelessControllerDiscovery()
    }
    
    func update() {
        self.controllers = GCController.controllers()
    }
    
    func createVC() {
        let config = GCVirtualController.Configuration()
        config.elements = [
            GCInputButtonA, GCInputButtonB,
            GCInputButtonX, GCInputButtonY,
            GCInputDirectionPad,
        ]
        self.virtualController = GCVirtualController(configuration: config)
        
        virtualController?.connect { error in
            print(error ?? "Connected")
        }
    }
}

import SwiftUI
import GameController

struct GameControllerView: View {
    @StateObject var gameController: GameController
    
    var body: some View {
        HStack {
            Text(gameController.playerIndex.description)
            Text(gameController.name)
            Text(gameController.productCategory)
        }
    }
}

let indexAllCase: [GCControllerPlayerIndex] = [
    .indexUnset,
    .index1,
    .index2,
    .index3,
    .index4,
]

extension GCControllerPlayerIndex: Identifiable {
    public var id: Int { rawValue }
}

extension GCControllerPlayerIndex: CustomStringConvertible {
    public var description: String {
        return self == .indexUnset ? "Unset" : "\(rawValue + 1)"
    }
}

struct GameControllerDetailView: View {
    let gameController: GameController
    
    @State var playerIndex: GCControllerPlayerIndex = .indexUnset
    
    var body: some View {
        Form {
            Section {
                Text("\(gameController.gcController.physicalInputProfile)")
                Picker("Player Index", selection: $playerIndex) { 
                    ForEach(indexAllCase) { index in
                        Text(index.description).tag(index)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Elements: \(gameController.elements.count)", content: {
                ForEach(gameController.elements) { e in
                    ControllerElementView(viewModel: ControllerElementViewModel(element: e))
                }
            })
        }
        .onChange(of: playerIndex) { newValue in
            gameController.setPlayerIndex(newValue)
        }
        .onAppear { 
            playerIndex = gameController.playerIndex
        }
    }
}

extension ControllerElement: Identifiable {
    var id: String {
        key
    }
}

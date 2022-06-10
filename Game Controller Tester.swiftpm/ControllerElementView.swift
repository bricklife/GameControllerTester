import SwiftUI
import GameController

struct ControllerElementView: View {
    @StateObject var viewModel: ControllerElementViewModel
    
    var body: some View {
        let element = viewModel.element
        HStack {
            Label("\(element.key) (\(element.name))", systemImage: element.sfSymbolsName)
            Spacer()
            Text(element.element.isAnalog ? viewModel.value.analogValue : viewModel.value.digitalValue)
            viewModel.value.image
                .foregroundColor(element.element.isAnalog ? .red : .blue)
        }
    }
}

class ControllerElementViewModel: ObservableObject {
    let element: ControllerElement
    let className: String
    
    @Published var value: ElementValue = .unset
    
    init(element: ControllerElement) {
        self.element = element
        self.className = type(of: element.element).description()
        
        element.element.preferredSystemGestureState = .disabled
        if let e = element.element as? GCControllerAxisInput {
            self.value = .axis(value: 0)
            e.valueChangedHandler = { [weak self] (_, value) in 
                self?.value = .axis(value: value)
            }
        } else if let e = element.element as? GCControllerButtonInput {
            self.value = .button(value: 0, pressed: false)
            e.valueChangedHandler = { [weak self] (button, value, pressed) in 
                //if pressed { print("Pressed", button) }
                self?.value = .button(value: value, pressed: pressed)
            }
            e.pressedChangedHandler = { (button, _, pressed) in
                if pressed { print("Pressed", button) }
            }
        } else if let e = element.element as? GCControllerDirectionPad {
            self.value = .dpad(x: 0, y: 0)
            e.valueChangedHandler = { [weak self] (_, x, y) in
                self?.value = .dpad(x: x, y: y)
            }
        }
    }
}

enum ElementValue {
    case axis(value: Float)
    case button(value: Float, pressed: Bool)
    case dpad(x: Float, y: Float)
    case unset
    
    var image: Image {
        switch self {
        case .axis:
            return Image(systemName: "arrow.left.and.right")
        case .button:
            return Image(systemName: "button.programmable")
        case .dpad:
            return Image(systemName: "dpad.fill")
        case .unset:
            return Image(systemName: "questionmark.app.dashed")
        }
    }
}

extension ElementValue: CustomStringConvertible {
    var description: String {
        return analogValue
    }
}

extension ElementValue {
    var analogValue: String {
        switch self {
        case .axis(value: let value):
            return String(format: "%.3f", value)
        case .button(value: let value, pressed: let pressed):
            return "\(pressed ? "ON" : "OFF") (\(String(format: "%.3f", value)))"
        case .dpad(x: let x, y: let y):
            return "(\(String(format: "%.3f", x)), \(String(format: "%.3f", y)))"
        case .unset:
            return "-"
        }
    }
    
    var digitalValue: String {
        switch self {
        case .axis(value: let value):
            return String(format: "%.0f", value)
        case .button(value: _, pressed: let pressed):
            return pressed ? "ON" : "OFF"
        case .dpad(x: let x, y: let y):
            return "(\(String(format: "%.0f", x)), \(String(format: "%.0f", y)))"
        case .unset:
            return "-"
        }
    }
}

struct ControllerElement {
    let key: String
    let element: GCControllerElement
    
    var name: String {
        element.localizedName ?? "Unknown"
    }
    
    var sfSymbolsName: String {
        element.sfSymbolsName ?? "" //"questionmark.app.dashed"
    }
}

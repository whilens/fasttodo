import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var stored: Double?
    @State private var operation: String?
    @State private var shouldReset = false
    @State private var pressed: String?

    private let keys: [[String]] = [
        ["C", "÷", "×", "⌫"],
        ["7", "8", "9", "−"],
        ["4", "5", "6", "+"],
        ["1", "2", "3", "="],
        ["0", ".", "%"],
    ]

    var body: some View {
        VStack(spacing: 18) {
            Text("Калькулятор")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Text(display)
                .font(.system(size: 56, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .contentTransition(.numericText())

            VStack(spacing: 12) {
                ForEach(keys, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { key in
                            if key.isEmpty {
                                Color.clear.frame(height: 68)
                            } else {
                                calcButton(key)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)

            Spacer()
        }
    }

    private func calcButton(_ key: String) -> some View {
        let isOp = ["÷", "×", "−", "+", "="].contains(key)
        return Button {
            tap(key)
        } label: {
            Text(key)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 68)
                .foregroundStyle(isOp ? Color(red: 0.72, green: 0.78, blue: 1) : .white)
                .scaleEffect(pressed == key ? 0.9 : 1)
        }
        .buttonStyle(.plain)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func tap(_ key: String) {
        pressed = key
        Haptics.tap()
        Task {
            try? await Task.sleep(for: .milliseconds(80))
            pressed = nil
        }

        switch key {
        case "C":
            display = "0"
            stored = nil
            operation = nil
        case "⌫":
            if display.count <= 1 || display == "-0" {
                display = "0"
            } else {
                display.removeLast()
            }
        case "+", "−", "×", "÷":
            stored = Double(display)
            operation = key
            shouldReset = true
        case "=":
            calculate()
        case "%":
            if let value = Double(display) {
                display = format(value / 100)
            }
        case ".":
            if shouldReset {
                display = "0."
                shouldReset = false
            } else if !display.contains(".") {
                display += "."
            }
        default:
            if shouldReset || display == "0" {
                display = key
                shouldReset = false
            } else {
                display += key
            }
        }
    }

    private func calculate() {
        guard let op = operation, let left = stored, let right = Double(display) else { return }
        let result: Double
        switch op {
        case "+": result = left + right
        case "−": result = left - right
        case "×": result = left * right
        case "÷": result = right == 0 ? 0 : left / right
        default: return
        }
        display = format(result)
        stored = nil
        operation = nil
        shouldReset = true
        Haptics.add()
    }

    private func format(_ value: Double) -> String {
        value.rounded() == value ? String(Int(value)) : String(value)
    }
}

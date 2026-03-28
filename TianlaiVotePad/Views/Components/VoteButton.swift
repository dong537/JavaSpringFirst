import SwiftUI

struct VoteButton: View {
    let value: Int
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(value)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Text("票")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(isEnabled ? Color.primary : Color.secondary)
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isEnabled ? Color(.systemGray6) : Color(.systemGray5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isEnabled ? Color(red: 0.85, green: 0.24, blue: 0.21) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(VoteButtonPressStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct VoteButtonPressStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1)
            .opacity(configuration.isPressed && isEnabled ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

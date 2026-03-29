import SwiftUI

struct VoteButton: View {
    let value: Int
    let isEnabled: Bool
    let isSelected: Bool
    let action: () -> Void

    private let badgeAspectRatio: CGFloat = 349.0 / 288.0

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(voteAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .saturation(isEnabled ? 1 : 0.08)
                    .brightness(isEnabled ? 0 : -0.04)
                    .opacity(isEnabled ? 1 : 0.55)

                if !isEnabled {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .padding(14)
                }
            }
            .overlay {
                if isEnabled && isSelected {
                    VoteBadgeSelectionRing()
                        .padding(10)
                        .transition(.opacity)
                }
            }
            .overlay(alignment: .bottom) {
                Text(isEnabled ? "点击选择" : "不可投")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.white : Color.white.opacity(0.86))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(isEnabled ? 0.18 : 0.3))
                    .clipShape(Capsule())
                    .padding(.bottom, 6)
            }
            .shadow(
                color: isEnabled
                    ? (isSelected ? Color(red: 0.96, green: 0.83, blue: 0.45).opacity(0.42) : .black.opacity(0.16))
                    : .clear,
                radius: isSelected ? 16 : 10,
                y: isSelected ? 8 : 5
            )
        }
        .buttonStyle(VoteBadgeButtonStyle(isEnabled: isEnabled, isSelected: isSelected))
        .disabled(!isEnabled)
        .aspectRatio(badgeAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(value) 票")
        .accessibilityHint(isEnabled ? "点击选择该票数" : "当前不可选择该票数")
    }

    private var voteAssetName: String {
        "VoteCountBadge\(value)"
    }
}

private struct VoteBadgeButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : (isSelected ? 1.015 : 1))
            .brightness(configuration.isPressed && isEnabled ? 0.03 : 0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

private struct VoteBadgeSelectionRing: View {
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.96),
                        Color(red: 0.99, green: 0.9, blue: 0.62),
                        Color(red: 0.82, green: 0.58, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .shadow(color: Color(red: 0.98, green: 0.89, blue: 0.62).opacity(0.45), radius: 10)
    }
}

import SwiftUI

struct VoteButton: View {
    let value: Int
    let isEnabled: Bool
    let isSelected: Bool
    let action: () -> Void

    private let badgeAssetName = "ContestantBadgeBase"
    private let badgeAspectRatio: CGFloat = 823.0 / 791.0

    var body: some View {
        Button(action: action) {
            GeometryReader { proxy in
                let size = proxy.size

                ZStack {
                    Image(badgeAssetName)
                        .resizable()
                        .scaledToFit()
                        .saturation(isEnabled ? 1 : 0.2)
                        .brightness(isEnabled ? 0 : 0.05)
                        .opacity(isEnabled ? 1 : 0.7)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.43, green: 0.76, blue: 0.86).opacity(isEnabled ? 0.97 : 0.75),
                                    Color(red: 0.22, green: 0.59, blue: 0.74).opacity(isEnabled ? 0.95 : 0.72)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: size.width * 0.42, height: size.width * 0.42)
                        .offset(y: -size.height * 0.02)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(isEnabled ? 0.42 : 0.22), lineWidth: max(2, size.width * 0.006))
                        )

                    VStack(spacing: size.height * 0.02) {
                        Spacer(minLength: size.height * 0.18)

                        Text("\(value)")
                            .font(.system(size: size.width * 0.22, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: Color(red: 0.73, green: 0.58, blue: 0.26).opacity(0.9), radius: 1, x: 1, y: 2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Spacer(minLength: size.height * 0.12)

                        Text("票数")
                            .font(.system(size: size.width * 0.11, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: Color(red: 0.73, green: 0.58, blue: 0.26).opacity(0.85), radius: 1, x: 1, y: 2)
                            .lineLimit(1)

                        Text(isEnabled ? "点击选择" : "不可投")
                            .font(.system(size: size.width * 0.042, weight: .semibold, design: .rounded))
                            .foregroundStyle(isEnabled ? Color(red: 0.33, green: 0.41, blue: 0.52) : Color.gray)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, size.width * 0.08)
                    .padding(.vertical, size.height * 0.08)
                }
                .frame(width: size.width, height: size.height)
            }
            .aspectRatio(badgeAspectRatio, contentMode: .fit)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(VoteBadgeButtonStyle(isEnabled: isEnabled, isSelected: isSelected))
        .disabled(!isEnabled)
    }
}

private struct VoteBadgeButtonStyle: ButtonStyle {
    let isEnabled: Bool
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let showHighlight = isEnabled && (configuration.isPressed || isSelected)

        configuration.label
            .overlay {
                if showHighlight {
                    VoteBadgeHighlight()
                        .transition(.opacity)
                }
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .brightness(showHighlight ? 0.03 : 0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.18), value: isSelected)
    }
}

private struct VoteBadgeHighlight: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let circleSize = size.width * 0.72
            let lineWidth = max(4, size.width * 0.016)

            ZStack {
                Circle()
                    .trim(from: 0.03, to: 0.97)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.97, green: 0.84, blue: 0.44),
                                Color(red: 0.82, green: 0.58, blue: 0.18),
                                Color(red: 0.98, green: 0.9, blue: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .offset(y: -size.height * 0.015)
                    .shadow(color: Color(red: 0.95, green: 0.77, blue: 0.28).opacity(0.45), radius: 12)

                Circle()
                    .trim(from: 0.14, to: 0.36)
                    .stroke(
                        Color(red: 0.99, green: 0.9, blue: 0.62).opacity(0.9),
                        style: StrokeStyle(lineWidth: lineWidth * 0.55, lineCap: .round)
                    )
                    .frame(width: circleSize * 1.08, height: circleSize * 1.08)
                    .offset(x: size.width * 0.02, y: -size.height * 0.015)

                Circle()
                    .fill(Color(red: 0.99, green: 0.9, blue: 0.62))
                    .frame(width: lineWidth * 1.6, height: lineWidth * 1.6)
                    .offset(x: -circleSize * 0.44, y: -circleSize * 0.37)

                Circle()
                    .fill(Color(red: 0.99, green: 0.9, blue: 0.62))
                    .frame(width: lineWidth * 1.35, height: lineWidth * 1.35)
                    .offset(x: circleSize * 0.38, y: circleSize * 0.34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }
}

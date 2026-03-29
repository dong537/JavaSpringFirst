import SwiftUI

struct ContestantCard: View {
    let contestant: Contestant
    let entryState: ContestantEntryState

    private let badgeAssetName = "ContestantBadgeBase"
    private let badgeAspectRatio: CGFloat = 823.0 / 791.0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                badgeBackground

                Circle()
                    .fill(centerPlateGradient)
                    .frame(width: size.width * 0.46, height: size.width * 0.46)
                    .offset(y: -size.height * 0.02)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.42), lineWidth: max(2, size.width * 0.006))
                    )

                RoundedRectangle(cornerRadius: size.width * 0.07, style: .continuous)
                    .fill(nameRibbonGradient)
                    .frame(width: size.width * 0.82, height: size.height * 0.24)
                    .offset(y: size.height * 0.22)
                    .blur(radius: size.width * 0.012)

                VStack(spacing: size.height * 0.03) {
                    Spacer(minLength: size.height * 0.18)

                    badgeTitle(
                        String(format: "%02d", contestant.order),
                        fontSize: size.width * 0.22,
                        weight: .black
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                    Spacer(minLength: size.height * 0.14)

                    VStack(spacing: size.height * 0.008) {
                        badgeTitle(
                            contestant.name,
                            fontSize: contestant.name.count > 4 ? size.width * 0.105 : size.width * 0.13,
                            weight: .heavy
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                        Text(statusDescription)
                            .font(.system(size: size.width * 0.043, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.33, green: 0.41, blue: 0.52))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .padding(.horizontal, size.width * 0.08)
                .padding(.vertical, size.height * 0.08)

                VStack {
                    HStack {
                        Spacer()

                        Text(statusTitle)
                            .font(.system(size: size.width * 0.048, weight: .bold, design: .rounded))
                            .foregroundStyle(statusForeground)
                            .padding(.horizontal, size.width * 0.038)
                            .padding(.vertical, size.height * 0.018)
                            .background {
                                Capsule()
                                    .fill(statusBackground)
                            }
                    }

                    Spacer()
                }
                .padding(.top, size.height * 0.14)
                .padding(.trailing, size.width * 0.1)
            }
            .frame(width: size.width, height: size.height)
        }
        .aspectRatio(badgeAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(isInactive ? 0.14 : 0.22), radius: 22, y: 12)
        .opacity(isInactive ? 0.78 : 1)
        .scaleEffect(isCompleted ? 0.985 : 1)
    }

    private var badgeBackground: some View {
        Image(badgeAssetName)
            .resizable()
            .scaledToFit()
            .overlay(colorOverlay)
            .saturation(isInactive ? 0.76 : 1)
            .brightness(isCompleted ? -0.03 : 0)
    }

    @ViewBuilder
    private var colorOverlay: some View {
        switch entryState {
        case .pending:
            Color.clear
        case .voted:
            Color(red: 0.07, green: 0.34, blue: 0.24).opacity(0.18)
        case .locked:
            Color.black.opacity(0.22)
        case .invalidConfiguration:
            Color(red: 0.25, green: 0.12, blue: 0.14).opacity(0.22)
        }
    }

    private var isCompleted: Bool {
        if case .voted = entryState {
            return true
        }

        return false
    }

    private var isInactive: Bool {
        switch entryState {
        case .pending:
            return false
        case .voted, .locked, .invalidConfiguration:
            return true
        }
    }

    private var statusTitle: String {
        switch entryState {
        case .pending:
            return "待投"
        case .voted:
            return "已投"
        case .locked:
            return "锁定"
        case .invalidConfiguration:
            return "待配置"
        }
    }

    private var statusDescription: String {
        switch entryState {
        case let .voted(votes):
            return "已投 \(votes) 票"
        case .locked:
            return "票数已分配完毕"
        case .invalidConfiguration:
            return "名单信息待完善"
        case .pending:
            return "点击进入投票"
        }
    }

    private var statusForeground: Color {
        switch entryState {
        case .pending:
            return Color(red: 0.29, green: 0.22, blue: 0.05)
        case .voted, .locked, .invalidConfiguration:
            return .white
        }
    }

    private var statusBackground: AnyShapeStyle {
        switch entryState {
        case .pending:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.99, green: 0.9, blue: 0.47), Color(red: 0.92, green: 0.73, blue: 0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .voted:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color(red: 0.22, green: 0.69, blue: 0.48), Color(red: 0.13, green: 0.46, blue: 0.33)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .locked, .invalidConfiguration:
            return AnyShapeStyle(Color.black.opacity(0.26))
        }
    }

    private var centerPlateGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.43, green: 0.76, blue: 0.86).opacity(0.97),
                Color(red: 0.22, green: 0.59, blue: 0.74).opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var nameRibbonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.98, blue: 0.99).opacity(0.96),
                Color(red: 0.83, green: 0.91, blue: 0.95).opacity(0.88)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func badgeTitle(_ title: String, fontSize: CGFloat, weight: Font.Weight) -> some View {
        ZStack {
            Text(title)
                .font(.system(size: fontSize, weight: weight, design: .rounded))
                .foregroundStyle(Color(red: 0.73, green: 0.58, blue: 0.26))
                .offset(x: 1, y: 2)

            Text(title)
                .font(.system(size: fontSize, weight: weight, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

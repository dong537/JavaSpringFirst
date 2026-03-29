import SwiftUI

struct ContestantCard: View {
    let contestant: Contestant
    let entryState: ContestantEntryState

    private let badgeAspectRatio: CGFloat = 823.0 / 791.0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                Image(contestant.badgeImageAssetName)
                    .resizable()
                    .scaledToFit()
                    .saturation(isInactive ? 0.76 : 1)
                    .brightness(isCompleted ? -0.03 : 0)

                if isInactive {
                    RoundedRectangle(cornerRadius: size.width * 0.12, style: .continuous)
                        .fill(colorOverlay)
                }

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

                    Text(statusDescription)
                        .font(.system(size: size.width * 0.044, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, size.width * 0.065)
                        .padding(.vertical, size.height * 0.022)
                        .background(.black.opacity(0.22))
                        .clipShape(Capsule())
                }
                .padding(.top, size.height * 0.14)
                .padding(.trailing, size.width * 0.1)
                .padding(.bottom, size.height * 0.12)
            }
            .frame(width: size.width, height: size.height)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(contestant.badgeAccessibilityLabel)
            .accessibilityValue(statusDescription)
        }
        .aspectRatio(badgeAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(isInactive ? 0.14 : 0.22), radius: 22, y: 12)
        .opacity(isInactive ? 0.82 : 1)
        .scaleEffect(isCompleted ? 0.985 : 1)
    }

    private var colorOverlay: Color {
        switch entryState {
        case .pending:
            return .clear
        case .voted:
            return Color(red: 0.07, green: 0.34, blue: 0.24).opacity(0.18)
        case .locked:
            return Color.black.opacity(0.22)
        case .invalidConfiguration:
            return Color(red: 0.25, green: 0.12, blue: 0.14).opacity(0.22)
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
}

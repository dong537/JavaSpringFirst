import SwiftUI

struct ContestantCard: View {
    let contestant: Contestant
    let isEnabled: Bool
    let isLocked: Bool
    let isConfigurationValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text(String(format: "%02d", contestant.order))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(accentColor.opacity(0.14))
                    .clipShape(Capsule())

                Spacer()

                Text(statusTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(statusForeground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusBackground)
                    .clipShape(Capsule())
            }

            Spacer(minLength: 8)

            Text(contestant.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Text(statusDescription)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .opacity(isEnabled || contestant.voted ? 1 : 0.7)
    }

    private var statusTitle: String {
        if contestant.voted {
            return "已投"
        }

        if !isConfigurationValid {
            return "未就绪"
        }

        if isLocked {
            return "已锁定"
        }

        return "待投"
    }

    private var statusDescription: String {
        if let votes = contestant.allocatedVotes, contestant.voted {
            return "已投 \(votes) 票"
        }

        if !isConfigurationValid {
            return "名单未配置完成"
        }

        if isLocked {
            return "当前票数已用完"
        }

        return "点击进入投票"
    }

    private var accentColor: Color {
        contestant.voted ? Color(red: 0.28, green: 0.78, blue: 0.56) : Color(red: 1.0, green: 0.84, blue: 0.28)
    }

    private var statusForeground: Color {
        contestant.voted ? .white : (isLocked || !isConfigurationValid ? .white : .black)
    }

    private var statusBackground: Color {
        if contestant.voted {
            return Color(red: 0.16, green: 0.56, blue: 0.40)
        }

        if isLocked || !isConfigurationValid {
            return .white.opacity(0.14)
        }

        return Color(red: 1.0, green: 0.84, blue: 0.28)
    }

    private var cardBackground: LinearGradient {
        if contestant.voted {
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.44, blue: 0.30), Color(red: 0.18, green: 0.62, blue: 0.44)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        if isEnabled {
            return LinearGradient(
                colors: [Color(red: 0.76, green: 0.13, blue: 0.23), Color(red: 0.96, green: 0.41, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [Color(red: 0.29, green: 0.34, blue: 0.41), Color(red: 0.19, green: 0.22, blue: 0.29)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

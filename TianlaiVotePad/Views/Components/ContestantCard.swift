import SwiftUI

struct ContestantCard: View {
    let contestant: Contestant
    let entryState: ContestantEntryState

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
        .opacity(entryState.isInteractive || isCompleted ? 1 : 0.7)
    }

    private var isCompleted: Bool {
        if case .voted = entryState {
            return true
        }

        return false
    }

    private var statusTitle: String {
        switch entryState {
        case .pending:
            return "待投"
        case .voted:
            return "已投"
        case .locked:
            return "已锁定"
        case .invalidConfiguration:
            return "未就绪"
        }
    }

    private var statusDescription: String {
        switch entryState {
        case let .voted(votes):
            return "已投 \(votes) 票"
        case .invalidConfiguration:
            return "名单未配置完成"
        case .locked:
            return "当前票数已用完"
        case .pending:
            return "点击进入投票"
        }
    }

    private var accentColor: Color {
        isCompleted ? Color(red: 0.28, green: 0.78, blue: 0.56) : Color(red: 1.0, green: 0.84, blue: 0.28)
    }

    private var statusForeground: Color {
        switch entryState {
        case .pending:
            return .black
        case .voted, .locked, .invalidConfiguration:
            return .white
        }
    }

    private var statusBackground: Color {
        switch entryState {
        case .voted:
            return Color(red: 0.16, green: 0.56, blue: 0.40)
        case .pending:
            return Color(red: 1.0, green: 0.84, blue: 0.28)
        case .locked, .invalidConfiguration:
            return .white.opacity(0.14)
        }
    }

    private var cardBackground: LinearGradient {
        switch entryState {
        case .voted:
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.44, blue: 0.30), Color(red: 0.18, green: 0.62, blue: 0.44)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pending:
            return LinearGradient(
                colors: [Color(red: 0.76, green: 0.13, blue: 0.23), Color(red: 0.96, green: 0.41, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .locked, .invalidConfiguration:
            return LinearGradient(
                colors: [Color(red: 0.29, green: 0.34, blue: 0.41), Color(red: 0.19, green: 0.22, blue: 0.29)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

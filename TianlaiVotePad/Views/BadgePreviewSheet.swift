import SwiftUI

struct BadgePreviewSheet: View {
    let voteCount: Int
    let confirmationText: String
    let badgeAssetName: String
    let isConfirming: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("投票确认")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(confirmationText)
                .font(.system(size: 36, weight: .bold, design: .rounded))

            VStack(spacing: 10) {
                Text("\(voteCount)")
                    .font(.system(size: 168, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.95, green: 0.71, blue: 0.18), Color(red: 0.84, green: 0.33, blue: 0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)

                Text("本次投票 \(voteCount) 票")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            HStack(spacing: 14) {
                Button(action: onCancel) {
                    Text("取消返回")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                .disabled(isConfirming)

                Button(action: onConfirm) {
                    Group {
                        if isConfirming {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        } else {
                            Text("确认投票")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.79, green: 0.15, blue: 0.18))
                .disabled(isConfirming)
            }
        }
        .padding(28)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 28, y: 12)
    }
}

#Preview {
    BadgePreviewSheet(
        voteCount: 5,
        confirmationText: "是否确认为【少年01】投 5 票？",
        badgeAssetName: "BadgeLogo",
        isConfirming: false,
        onCancel: {},
        onConfirm: {}
    )
}

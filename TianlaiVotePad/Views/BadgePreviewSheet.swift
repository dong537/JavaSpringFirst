import SwiftUI

struct BadgePreviewSheet: View {
    let voteCount: Int
    let confirmationText: String
    let badgeAssetName: String
    let isConfirming: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 92, maximum: 120), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("投票确认")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text(confirmationText)
                .font(.system(size: 18, weight: .medium))

            if voteCount == 0 {
                VStack(spacing: 12) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text("本次投票为 0 票")
                        .font(.system(size: 20, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("徽章预览")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(0..<voteCount, id: \.self) { _ in
                                BadgeTokenView(badgeAssetName: badgeAssetName)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 280)
            }

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

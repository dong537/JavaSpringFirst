import SwiftUI

struct BadgePreviewSheet: View {
    let contestantName: String
    let voteCount: Int
    let badgeAssetName: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Text("投票确认")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("是否确认为【\(contestantName)】投 \(voteCount) 票？")
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
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(0..<voteCount, id: \.self) { _ in
                            BadgeTokenView(badgeAssetName: badgeAssetName)
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

                Button(action: onConfirm) {
                    Text("确认投票")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.79, green: 0.15, blue: 0.18))
            }
        }
        .padding(28)
    }
}

#Preview {
    BadgePreviewSheet(
        contestantName: "少年01",
        voteCount: 5,
        badgeAssetName: "BadgeLogo",
        onCancel: {},
        onConfirm: {}
    )
}

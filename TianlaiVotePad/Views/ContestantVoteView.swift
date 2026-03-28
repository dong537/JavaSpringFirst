import SwiftUI

struct ContestantVoteView: View {
    let contestantID: String

    @EnvironmentObject private var session: VotingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVoteCount = 0
    @State private var isPreviewPresented = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

    var body: some View {
        Group {
            if let contestant = session.contestant(for: contestantID) {
                content(for: contestant)
            } else {
                missingContestantView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(for contestant: Contestant) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(contestant.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("当前可分配票数：0 - \(session.remainingVotes)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)

                    if contestant.voted {
                        Text("该选手已完成投票，本轮不可再次修改。")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red)
                    } else if session.isLocked {
                        Text("当前余额为 0，投票功能已锁定。")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.red)
                    } else {
                        Text("点击任一数字后，会先展示对应数量的节目徽章，再进入确认步骤。")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0...16, id: \.self) { vote in
                        VoteButton(
                            value: vote,
                            isEnabled: session.isVoteEnabled(vote, for: contestant)
                        ) {
                            selectedVoteCount = vote
                            isPreviewPresented = true
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $isPreviewPresented) {
            BadgePreviewSheet(
                contestantName: contestant.name,
                voteCount: selectedVoteCount,
                badgeAssetName: session.badgeAssetName,
                onCancel: {
                    isPreviewPresented = false
                },
                onConfirm: {
                    session.confirmVotes(for: contestant.id, count: selectedVoteCount)
                    isPreviewPresented = false
                    dismiss()
                }
            )
            .presentationDetents([.fraction(0.62), .large])
            .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("剩余 \(session.remainingVotes) 票")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }

    private var missingContestantView: some View {
        VStack(spacing: 16) {
            Text("选手数据不存在")
                .font(.title2.bold())

            Text("请检查 contestants.json 配置。")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        ContestantVoteView(contestantID: "contestant-01")
            .environmentObject(VotingSessionViewModel())
    }
}

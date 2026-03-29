import SwiftUI

struct ContestantVoteView: View {
    let contestantID: String

    @EnvironmentObject private var session: VotingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVoteCount: Int?
    @State private var isSubmitting = false

    var body: some View {
        Group {
            if let contestant = session.contestant(for: contestantID) {
                content(for: contestant)
            } else {
                missingContestantView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(selectedVoteCount != nil)
    }

    private func content(for contestant: Contestant) -> some View {
        GeometryReader { proxy in
            let entryState = session.entryState(for: contestant)
            let hasSelection = selectedVoteCount != nil

            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(contestant.name)
                                .font(.system(size: 32, weight: .bold, design: .rounded))

                            Text("当前可分配票数：0 - \(session.remainingVotes)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.secondary)

                            Text(message(for: entryState))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(messageColor(for: entryState))
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                        LazyVGrid(columns: voteColumns(for: proxy.size), spacing: 16) {
                            ForEach(0...session.initialVotes, id: \.self) { vote in
                                VoteButton(
                                    value: vote,
                                    isEnabled: session.isVoteEnabled(vote, for: contestant),
                                    isSelected: selectedVoteCount == vote
                                ) {
                                    selectedVoteCount = vote
                                }
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, 24)
                }
                .background(Color(.systemBackground))
                .scrollIndicators(.hidden)
                .blur(radius: hasSelection ? 1.5 : 0)
                .allowsHitTesting(!hasSelection)

                if let selectedVoteCount {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    BadgePreviewSheet(
                        voteCount: selectedVoteCount,
                        confirmationText: session.confirmationMessage(for: contestant.name, voteCount: selectedVoteCount),
                        badgeAssetName: session.badgeAssetName,
                        isConfirming: isSubmitting,
                        onCancel: {
                            guard !isSubmitting else {
                                return
                            }

                            self.selectedVoteCount = nil
                        },
                        onConfirm: {
                            guard !isSubmitting else {
                                return
                            }

                            isSubmitting = true

                            if session.confirmVotes(for: contestant.id, count: selectedVoteCount) {
                                self.selectedVoteCount = nil
                                dismiss()
                            } else {
                                isSubmitting = false
                            }
                        }
                    )
                    .frame(maxWidth: 720)
                    .padding(24)
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedVoteCount != nil)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("返回") {
                    dismiss()
                }
                .disabled(selectedVoteCount != nil || isSubmitting)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Text("剩余 \(session.remainingVotes) 票")
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .onDisappear {
            selectedVoteCount = nil
            isSubmitting = false
        }
    }

    private func message(for entryState: ContestantEntryState) -> String {
        switch entryState {
        case let .voted(votes):
            return "该选手已完成投票，本轮已投 \(votes) 票，不可再次修改。"
        case .invalidConfiguration:
            return session.validationMessage ?? "名单未配置完成，请先补齐配置。"
        case .locked:
            return "当前余额为 0，投票功能已锁定。"
        case .pending:
            return "点击任一数字后，会先展示对应数量的节目徽章，再进入确认步骤。"
        }
    }

    private func messageColor(for entryState: ContestantEntryState) -> Color {
        switch entryState {
        case .pending:
            return .secondary
        case .voted, .locked, .invalidConfiguration:
            return .red
        }
    }

    private func voteColumns(for size: CGSize) -> [GridItem] {
        let minimumWidth = size.width > size.height ? 120.0 : 145.0
        return [GridItem(.adaptive(minimum: minimumWidth, maximum: 180), spacing: 16)]
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

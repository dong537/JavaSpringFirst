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
                Image("VoteSelectionBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                Color.black.opacity(0.26)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(spacing: 18) {
                            Image(contestant.badgeImageAssetName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: min(proxy.size.width * 0.42, 360))
                                .accessibilityLabel(contestant.badgeAccessibilityLabel)

                            Text("当前可分配票数：0 - \(session.remainingVotes)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white.opacity(0.88))

                            Text(message(for: entryState))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(messageColor(for: entryState))
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.16), lineWidth: 1)
                        )

                        LazyVGrid(columns: voteColumns(for: proxy.size), spacing: 18) {
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
                .scrollIndicators(.hidden)
                .blur(radius: hasSelection ? 1.5 : 0)
                .allowsHitTesting(!hasSelection)

                if let selectedVoteCount {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()

                    BadgePreviewSheet(
                        contestant: contestant,
                        voteCount: selectedVoteCount,
                        confirmationText: session.confirmationMessage(voteCount: selectedVoteCount),
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
                RemainingVotesBadge(
                    votes: session.remainingVotes,
                    width: 220,
                    numberFontSize: 30,
                    trailingPadding: 18
                )
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
            return "请选择一个票数徽章，系统会先展示确认弹层，再进入最终确认。"
        }
    }

    private func messageColor(for entryState: ContestantEntryState) -> Color {
        switch entryState {
        case .pending:
            return .white.opacity(0.78)
        case .voted, .locked, .invalidConfiguration:
            return Color(red: 1.0, green: 0.82, blue: 0.82)
        }
    }

    private func voteColumns(for size: CGSize) -> [GridItem] {
        let minimumWidth = size.width > size.height ? 138.0 : 150.0
        return [GridItem(.adaptive(minimum: minimumWidth, maximum: 188), spacing: 18)]
    }

    private var missingContestantView: some View {
        ZStack {
            Image("VoteSelectionBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.28)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("选手数据不存在")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("请检查 contestants.json 配置。")
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContestantVoteView(contestantID: "contestant-01")
            .environmentObject(VotingSessionViewModel())
    }
}

import SwiftUI

struct ContestantVoteView: View {
    let contestantID: String

    @EnvironmentObject private var session: VotingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVoteCount: Int?
    @State private var confirmedVoteCount: Int?
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func content(for contestant: Contestant) -> some View {
        GeometryReader { proxy in
            let hasOverlay = selectedVoteCount != nil || confirmedVoteCount != nil
            let safeTop = proxy.safeAreaInsets.top
            let layout = voteLayout(for: proxy.size)

            ZStack(alignment: .top) {
                voteBackground

                VStack(spacing: 0) {
                    topBar(topInset: safeTop, remainingVotes: session.remainingVotes)

                    Spacer(minLength: layout.topSpacing)

                    voteRows(layout: layout, contestant: contestant)

                    Spacer(minLength: layout.bottomSpacing)
                }
                .padding(.horizontal, layout.horizontalPadding)
                .blur(radius: hasOverlay ? 1.5 : 0)
                .allowsHitTesting(!hasOverlay)

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
                                confirmedVoteCount = selectedVoteCount
                                isSubmitting = false
                            } else {
                                isSubmitting = false
                            }
                        }
                    )
                    .frame(maxWidth: 720)
                    .padding(24)
                    .transition(.opacity.combined(with: .scale))
                }

                if let confirmedVoteCount {
                    FinalVoteResultOverlay(
                        voteCount: confirmedVoteCount,
                        onContinue: {
                            self.confirmedVoteCount = nil
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedVoteCount != nil)
        .animation(.easeInOut(duration: 0.25), value: confirmedVoteCount != nil)
    }

    private var voteBackground: some View {
        AppPageBackground()
    }

    private func topBar(topInset: CGFloat, remainingVotes: Int) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.28))
                        .frame(width: 42, height: 42)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(selectedVoteCount != nil || confirmedVoteCount != nil || isSubmitting)

            RemainingVotesBadge(
                votes: remainingVotes,
                width: 300,
                numberFontSize: 46,
                trailingPadding: 28
            )

            Spacer()
        }
        .padding(.top, max(12, topInset + 6))
    }

    private func voteRows(layout: VoteLayout, contestant: Contestant) -> some View {
        VStack(spacing: layout.rowSpacing) {
            voteRow(values: Array(1...8), itemWidth: layout.itemWidth, spacing: layout.itemSpacing, contestant: contestant)
            voteRow(values: Array(9...16), itemWidth: layout.itemWidth, spacing: layout.itemSpacing, contestant: contestant)

            HStack {
                Spacer(minLength: 0)
                voteBadge(value: 0, itemWidth: layout.zeroItemWidth, contestant: contestant)
                Spacer(minLength: 0)
            }
            .padding(.top, layout.zeroTopPadding)
        }
        .frame(maxWidth: .infinity)
    }

    private func voteRow(values: [Int], itemWidth: CGFloat, spacing: CGFloat, contestant: Contestant) -> some View {
        HStack(spacing: spacing) {
            ForEach(values, id: \.self) { value in
                voteBadge(value: value, itemWidth: itemWidth, contestant: contestant)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func voteBadge(value: Int, itemWidth: CGFloat, contestant: Contestant) -> some View {
        VoteButton(
            value: value,
            isEnabled: session.isVoteEnabled(value, for: contestant),
            isSelected: selectedVoteCount == value
        ) {
            selectedVoteCount = value
        }
        .frame(width: itemWidth)
    }

    private func voteLayout(for size: CGSize) -> VoteLayout {
        let landscape = size.width > size.height
        let horizontalPadding = landscape ? max(28, size.width * 0.045) : 20.0
        let availableWidth = size.width - horizontalPadding * 2
        let preferredSpacing = landscape
            ? min(26, max(12, availableWidth * 0.018))
            : min(14, max(8, availableWidth * 0.016))
        let itemWidth = min(132, max(82, (availableWidth - preferredSpacing * 7) / 8))
        let itemSpacing = max(8, min(preferredSpacing, (availableWidth - itemWidth * 8) / 7))
        let zeroItemWidth = min(140, itemWidth * (landscape ? 1.06 : 1.12))

        return VoteLayout(
            horizontalPadding: horizontalPadding,
            itemWidth: itemWidth,
            itemSpacing: itemSpacing,
            zeroItemWidth: zeroItemWidth,
            rowSpacing: landscape ? 18 : 22,
            topSpacing: landscape ? 22 : 36,
            bottomSpacing: landscape ? 28 : 34,
            zeroTopPadding: landscape ? 8 : 4
        )
    }

    private var missingContestantView: some View {
        ZStack {
            voteBackground

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

private struct VoteLayout {
    let horizontalPadding: CGFloat
    let itemWidth: CGFloat
    let itemSpacing: CGFloat
    let zeroItemWidth: CGFloat
    let rowSpacing: CGFloat
    let topSpacing: CGFloat
    let bottomSpacing: CGFloat
    let zeroTopPadding: CGFloat
}

private struct FinalVoteResultOverlay: View {
    let voteCount: Int
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppPageBackground()

                VStack(spacing: 0) {
                    Spacer(minLength: proxy.size.height * 0.12)

                    Image(resultAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: resultImageWidth(for: proxy.size))
                        .shadow(color: .black.opacity(0.2), radius: 14, y: 8)

                    Spacer(minLength: proxy.size.height * 0.05)

                    resultBanner

                    Spacer(minLength: proxy.size.height * 0.02)

                    resultCount

                    Spacer()

                    Text("点击任意位置返回首页")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .padding(.bottom, max(32, proxy.safeAreaInsets.bottom + 12))
                }
                .padding(.horizontal, 48)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onContinue)
        }
        .accessibilityElement(children: .contain)
    }

    private var resultAssetName: String {
        voteCount == 0 ? "ContestantBadgeBase" : "FinalVoteRings\(voteCount)"
    }

    private func resultImageWidth(for size: CGSize) -> CGFloat {
        switch voteCount {
        case 0...2:
            return min(size.width * 0.36, 360)
        case 3...4:
            return min(size.width * 0.5, 520)
        case 5...8:
            return min(size.width * 0.8, 980)
        default:
            return min(size.width * 0.86, 1140)
        }
    }

    private var resultBanner: some View {
        HStack(spacing: 0) {
            ornamentCap

            Text("获得融合舞台徽章数量")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color(red: 0.22, green: 0.17, blue: 0.12))
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.98, green: 0.93, blue: 0.8), Color(red: 0.95, green: 0.87, blue: 0.68)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ornamentCap
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.96, green: 0.9, blue: 0.78), Color(red: 0.93, green: 0.84, blue: 0.64)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0.7, green: 0.29, blue: 0.16), lineWidth: 3)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 10, y: 5)
    }

    private var ornamentCap: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.86, green: 0.21, blue: 0.13), Color(red: 0.59, green: 0.08, blue: 0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 44, height: 54)

            Image(systemName: "flame.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 1.0, green: 0.9, blue: 0.7))
        }
    }

    private var resultCount: some View {
        Text("\(voteCount)")
            .font(.system(size: 220, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .shadow(color: Color(red: 0.72, green: 0.58, blue: 0.28).opacity(0.9), radius: 1, x: 2, y: 3)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
    }
}

#Preview {
    NavigationStack {
        ContestantVoteView(contestantID: "contestant-01")
            .environmentObject(VotingSessionViewModel())
    }
}

import SwiftUI

struct ContestantVoteView: View {
    let contestantID: String

    @EnvironmentObject private var session: VotingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVoteCount: Int?
    @State private var confirmedVoteCount: Int?
    @State private var isSubmitting = false

    private let voteBadgeAspectRatio: CGFloat = 349.0 / 288.0

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
            let layout = voteLayout(for: proxy.size, safeTop: proxy.safeAreaInsets.top)

            ZStack(alignment: .top) {
                voteBackground

                VStack(spacing: 0) {
                    topBar(layout: layout, remainingVotes: session.remainingVotes)

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
                    .frame(maxWidth: min(720, proxy.size.width - 32))
                    .padding(24)
                    .transition(.opacity.combined(with: .scale))
                }

                if let confirmedVoteCount {
                    FinalVoteResultOverlay(
                        voteCount: confirmedVoteCount,
                        buttonTitle: session.allVotingCompleted ? "查看最终票数" : "退出返回首页",
                        onContinue: {
                            self.confirmedVoteCount = nil
                            dismiss()

                            if session.allVotingCompleted {
                                DispatchQueue.main.async {
                                    session.requestFinalResultsPresentation()
                                }
                            }
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

    private func topBar(layout: VoteLayout, remainingVotes: Int) -> some View {
        HStack(alignment: .top, spacing: layout.topBarSpacing) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.28))
                        .frame(width: layout.backButtonSize, height: layout.backButtonSize)

                    Image(systemName: "chevron.left")
                        .font(.system(size: layout.backIconSize, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(selectedVoteCount != nil || confirmedVoteCount != nil || isSubmitting)

            RemainingVotesBadge(
                votes: remainingVotes,
                width: layout.remainingBadgeWidth,
                numberFontSize: layout.remainingBadgeNumberFontSize,
                trailingPadding: layout.remainingBadgeTrailingPadding
            )

            Spacer()
        }
        .padding(.top, layout.topPadding)
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

    private func voteLayout(for size: CGSize, safeTop: CGFloat) -> VoteLayout {
        let landscape = size.width > size.height
        let horizontalPadding = landscape ? max(26, size.width * 0.038) : max(18, size.width * 0.024)
        let availableWidth = size.width - horizontalPadding * 2
        let backButtonSize = landscape ? 42.0 : 38.0
        let topPadding = max(12, safeTop + 6)
        let remainingBadgeWidth = min(340, max(216, availableWidth * (landscape ? 0.30 : 0.48)))
        let remainingBadgeAspectRatio: CGFloat = 580.0 / 124.0
        let topBarHeight = max(backButtonSize, remainingBadgeWidth / remainingBadgeAspectRatio)
        let baseTopSpacing = landscape ? max(18, size.height * 0.03) : max(28, size.height * 0.05)
        let baseBottomSpacing = landscape ? max(18, size.height * 0.03) : max(24, size.height * 0.04)
        let baseRowSpacing = landscape ? max(12, size.height * 0.025) : max(18, size.height * 0.03)
        let baseZeroTopPadding = landscape ? 8.0 : 6.0
        let preferredSpacing = landscape
            ? min(22, max(10, availableWidth * 0.014))
            : min(14, max(6, availableWidth * 0.01))
        let widthLimitedItem = max(82, (availableWidth - preferredSpacing * 7) / 8)
        let zeroScale = landscape ? 1.06 : 1.12
        let usableHeight = max(
            220,
            size.height - topPadding - topBarHeight - baseTopSpacing - baseBottomSpacing
        )
        let heightLimitedItem = max(
            82,
            (usableHeight - baseRowSpacing * 2 - baseZeroTopPadding) * voteBadgeAspectRatio / (2 + zeroScale)
        )
        let itemWidth = min(widthLimitedItem, heightLimitedItem)
        let itemSpacing = max(6, (availableWidth - itemWidth * 8) / 7)
        let zeroItemWidth = itemWidth * zeroScale
        let badgeHeight = itemWidth / voteBadgeAspectRatio
        let zeroBadgeHeight = zeroItemWidth / voteBadgeAspectRatio
        let occupiedHeight = badgeHeight * 2 + zeroBadgeHeight + baseRowSpacing * 2 + baseZeroTopPadding
        let verticalSlack = max(0, usableHeight - occupiedHeight)
        let topSpacing = baseTopSpacing + verticalSlack * (landscape ? 0.36 : 0.30)
        let rowSpacing = baseRowSpacing + verticalSlack * (landscape ? 0.16 : 0.20)
        let bottomSpacing = baseBottomSpacing + verticalSlack * (landscape ? 0.18 : 0.24)
        let zeroTopPadding = baseZeroTopPadding + verticalSlack * 0.06

        return VoteLayout(
            horizontalPadding: horizontalPadding,
            itemWidth: itemWidth,
            itemSpacing: itemSpacing,
            zeroItemWidth: zeroItemWidth,
            rowSpacing: rowSpacing,
            topSpacing: topSpacing,
            bottomSpacing: bottomSpacing,
            zeroTopPadding: zeroTopPadding,
            topPadding: topPadding,
            topBarSpacing: landscape ? 16 : 12,
            backButtonSize: backButtonSize,
            backIconSize: landscape ? 18 : 16,
            remainingBadgeWidth: remainingBadgeWidth,
            remainingBadgeNumberFontSize: landscape ? 46 : 40,
            remainingBadgeTrailingPadding: landscape ? 28 : 24
        )
    }

    private var missingContestantView: some View {
        ZStack {
            voteBackground

            VStack(spacing: 16) {
                Text("选手数据不存在")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("请检查 contestants.json 配置")
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
    let topPadding: CGFloat
    let topBarSpacing: CGFloat
    let backButtonSize: CGFloat
    let backIconSize: CGFloat
    let remainingBadgeWidth: CGFloat
    let remainingBadgeNumberFontSize: CGFloat
    let remainingBadgeTrailingPadding: CGFloat
}

private struct FinalVoteResultOverlay: View {
    let voteCount: Int
    let buttonTitle: String
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppPageBackground()

                VStack(spacing: 0) {
                    Spacer(minLength: proxy.size.height * 0.12)

                    if let resultAssetName {
                        Image(resultAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: resultImageWidth(for: proxy.size))
                            .shadow(color: .black.opacity(0.2), radius: 14, y: 8)
                    }

                    Spacer(minLength: proxy.size.height * 0.05)

                    resultBanner

                    Spacer(minLength: proxy.size.height * 0.02)

                    resultCount

                    Spacer()

                    Button(action: onContinue) {
                        Text(buttonTitle)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: min(proxy.size.width * 0.42, 320))
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.86, green: 0.21, blue: 0.13), Color(red: 0.59, green: 0.08, blue: 0.08)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.24), radius: 12, y: 6)
                    }
                    .padding(.bottom, max(32, proxy.safeAreaInsets.bottom + 12))
                }
                .padding(.horizontal, 48)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var resultAssetName: String? {
        voteCount == 0 ? nil : "FinalVoteRings\(voteCount)"
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

            Text("获得个人火种数量")
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

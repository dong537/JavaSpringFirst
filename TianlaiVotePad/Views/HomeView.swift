import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: VotingSessionViewModel
    @State private var path: [String] = []
    @State private var isShowingFinalResults = false

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in
                let layout = homeLayout(for: proxy.size)

                ZStack {
                    AppPageBackground()

                    VStack(alignment: .leading, spacing: layout.sectionSpacing) {
                        header(layout: layout)

                        if session.allVotingCompleted {
                            finalResultsButton
                        }

                        if let validationMessage = session.validationMessage {
                            validationBanner(message: validationMessage)
                        }

                        ScrollView {
                            LazyVGrid(columns: gridColumns(for: layout), spacing: layout.gridSpacing) {
                                ForEach(session.sortedContestants) { contestant in
                                    let entryState = session.entryState(for: contestant)

                                    Button {
                                        guard entryState.isInteractive else {
                                            return
                                        }

                                        path.append(contestant.id)
                                    } label: {
                                        ContestantCard(
                                            contestant: contestant,
                                            entryState: entryState
                                        )
                                    }
                                    .buttonStyle(ContestantCardButtonStyle(isEnabled: entryState.isInteractive))
                                    .disabled(!entryState.isInteractive)
                                }
                            }
                            .padding(.bottom, 12)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding(.horizontal, layout.horizontalPadding)
                    .padding(.top, layout.topPadding)
                    .padding(.bottom, layout.bottomPadding)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { contestantID in
                ContestantVoteView(contestantID: contestantID)
                    .environmentObject(session)
            }
        }
        .sheet(isPresented: $isShowingFinalResults, onDismiss: {
            session.consumeFinalResultsPresentation()
        }) {
            FinalResultsView()
                .environmentObject(session)
        }
        .onChange(of: session.shouldPresentFinalResults) { shouldPresent in
            if shouldPresent {
                isShowingFinalResults = true
            }
        }
    }

    private func header(layout: HomeLayout) -> some View {
        VStack(alignment: .leading, spacing: layout.headerSpacing) {
            VStack(alignment: .leading, spacing: layout.headerCardSpacing) {
                HStack(alignment: .center, spacing: layout.headerRowSpacing) {
                    Text(session.title)
                        .font(.system(size: layout.titleFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: layout.headerRowSpacing)

                    RemainingVotesBadge(
                        votes: session.remainingVotes,
                        width: layout.badgeWidth,
                        numberFontSize: layout.badgeNumberFontSize,
                        trailingPadding: layout.badgeTrailingPadding
                    )

                    if session.isLocked {
                        Text("票数已分配完毕")
                            .font(.system(size: layout.lockChipFontSize, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: layout.summarySpacing) {
                        summaryChip(title: "已完成", value: "\(session.completedContestantCount) / 16")
                        summaryChip(title: "待投", value: "\(session.pendingContestantCount) 位")
                    }

                    VStack(spacing: layout.summarySpacing) {
                        summaryChip(title: "已完成", value: "\(session.completedContestantCount) / 16")
                        summaryChip(title: "待投", value: "\(session.pendingContestantCount) 位")
                    }
                }
            }
            .padding(layout.headerCardPadding)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    private var finalResultsButton: some View {
        Button {
            isShowingFinalResults = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "list.bullet.rectangle.portrait.fill")
                    .font(.system(size: 18, weight: .bold))

                Text("查看最终票数")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.86, green: 0.21, blue: 0.13), Color(red: 0.59, green: 0.08, blue: 0.08)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.22), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func summaryChip(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.78))

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08))
        .clipShape(Capsule())
    }

    private func validationBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 1.0, green: 0.86, blue: 0.31))

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.48, green: 0.12, blue: 0.14).opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func gridColumns(for layout: HomeLayout) -> [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: layout.gridSpacing, alignment: .top),
            count: layout.columnCount
        )
    }

    private func homeLayout(for size: CGSize) -> HomeLayout {
        let landscape = size.width > size.height
        let horizontalPadding = landscape ? max(24, size.width * 0.03) : max(18, size.width * 0.024)
        let gridSpacing = landscape ? 18.0 : 14.0
        let minCardWidth = landscape ? 180.0 : 150.0
        let availableWidth = size.width - horizontalPadding * 2
        let rawColumnCount = Int((availableWidth + gridSpacing) / (minCardWidth + gridSpacing))
        let columnCount = min(4, max(2, rawColumnCount))

        return HomeLayout(
            horizontalPadding: horizontalPadding,
            topPadding: landscape ? 24 : 18,
            bottomPadding: landscape ? 24 : 18,
            sectionSpacing: landscape ? 22 : 18,
            headerSpacing: landscape ? 14 : 10,
            headerCardSpacing: landscape ? 16 : 14,
            headerRowSpacing: landscape ? 16 : 12,
            headerCardPadding: landscape ? 24 : 18,
            gridSpacing: gridSpacing,
            columnCount: columnCount,
            titleFontSize: landscape ? 34 : 28,
            badgeWidth: min(360, max(220, availableWidth * (landscape ? 0.33 : 0.52))),
            badgeNumberFontSize: landscape ? 54 : 42,
            badgeTrailingPadding: landscape ? 26 : 22,
            lockChipFontSize: landscape ? 16 : 14,
            summarySpacing: landscape ? 12 : 10
        )
    }
}

private struct HomeLayout {
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let sectionSpacing: CGFloat
    let headerSpacing: CGFloat
    let headerCardSpacing: CGFloat
    let headerRowSpacing: CGFloat
    let headerCardPadding: CGFloat
    let gridSpacing: CGFloat
    let columnCount: Int
    let titleFontSize: CGFloat
    let badgeWidth: CGFloat
    let badgeNumberFontSize: CGFloat
    let badgeTrailingPadding: CGFloat
    let lockChipFontSize: CGFloat
    let summarySpacing: CGFloat
}

private struct FinalResultsView: View {
    @EnvironmentObject private var session: VotingSessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { proxy in
            let landscape = proxy.size.width > proxy.size.height

            ZStack {
                AppPageBackground()

                VStack(spacing: landscape ? 20 : 16) {
                    header

                    summaryBar

                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(Array(session.finalResults.enumerated()), id: \.element.id) { index, contestant in
                                resultRow(rank: index + 1, contestant: contestant)
                            }
                        }
                        .padding(.horizontal, landscape ? 28 : 18)
                        .padding(.bottom, 12)
                    }

                    closeButton
                }
                .padding(.horizontal, landscape ? 34 : 20)
                .padding(.top, max(20, proxy.safeAreaInsets.top + 12))
                .padding(.bottom, max(24, proxy.safeAreaInsets.bottom + 12))
            }
        }
        .presentationBackground(.clear)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("最终票数")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("全部投票完成后，可在这里查看每位选手得票")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.black.opacity(0.26))
                    .clipShape(Circle())
            }
        }
    }

    private var summaryBar: some View {
        HStack(spacing: 12) {
            finalSummaryChip(title: "已完成", value: "\(session.completedContestantCount) / 16")
            finalSummaryChip(title: "剩余票数", value: "\(session.remainingVotes)")
            finalSummaryChip(title: "已分配", value: "\(session.initialVotes - session.remainingVotes)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func finalSummaryChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.72))

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func resultRow(rank: Int, contestant: Contestant) -> some View {
        HStack(spacing: 16) {
            Text("\(rank)")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 34)

            Image(contestant.badgeImageAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: 6) {
                Text(contestant.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text("第 \(contestant.order) 位投票对象")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("\(contestant.allocatedVotes ?? 0)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("票")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.78))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.black.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("关闭")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: 260)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.86, green: 0.21, blue: 0.13), Color(red: 0.59, green: 0.08, blue: 0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ContestantCardButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                if configuration.isPressed && isEnabled {
                    ContestantCardHighlight()
                        .transition(.opacity)
                }
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .brightness(configuration.isPressed && isEnabled ? 0.03 : 0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

private struct ContestantCardHighlight: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let circleSize = size.width * 0.73
            let lineWidth = max(4, size.width * 0.014)

            ZStack {
                Circle()
                    .trim(from: 0.03, to: 0.97)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.97, green: 0.84, blue: 0.44),
                                Color(red: 0.82, green: 0.58, blue: 0.18),
                                Color(red: 0.98, green: 0.9, blue: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .offset(y: -size.height * 0.015)
                    .shadow(color: Color(red: 0.95, green: 0.77, blue: 0.28).opacity(0.45), radius: 12)

                Circle()
                    .trim(from: 0.14, to: 0.36)
                    .stroke(
                        Color(red: 0.99, green: 0.9, blue: 0.62).opacity(0.9),
                        style: StrokeStyle(lineWidth: lineWidth * 0.55, lineCap: .round)
                    )
                    .frame(width: circleSize * 1.08, height: circleSize * 1.08)
                    .offset(x: size.width * 0.02, y: -size.height * 0.015)

                Circle()
                    .fill(Color(red: 0.99, green: 0.9, blue: 0.62))
                    .frame(width: lineWidth * 1.6, height: lineWidth * 1.6)
                    .offset(x: -circleSize * 0.44, y: -circleSize * 0.37)

                Circle()
                    .fill(Color(red: 0.99, green: 0.9, blue: 0.62))
                    .frame(width: lineWidth * 1.35, height: lineWidth * 1.35)
                    .offset(x: circleSize * 0.38, y: circleSize * 0.34)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }
}

struct RemainingVotesBadge: View {
    let votes: Int
    let width: CGFloat
    let numberFontSize: CGFloat
    let trailingPadding: CGFloat

    private let aspectRatio: CGFloat = 580.0 / 124.0

    var body: some View {
        ZStack {
            Image("RemainingVotesLabel")
                .resizable()
                .scaledToFit()

            HStack {
                Spacer()

                Text("\(votes)")
                    .font(.system(size: numberFontSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .offset(y: -1)
                    .padding(.trailing, trailingPadding)
            }
        }
        .frame(width: width)
        .aspectRatio(aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("剩余票数")
        .accessibilityValue("\(votes) 票")
    }
}

#Preview {
    HomeView()
        .environmentObject(VotingSessionViewModel())
}

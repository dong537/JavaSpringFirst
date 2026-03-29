import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: VotingSessionViewModel
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { _ in
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.05, green: 0.13, blue: 0.25), Color(red: 0.11, green: 0.25, blue: 0.42)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(alignment: .leading, spacing: 24) {
                        header

                        if let validationMessage = session.validationMessage {
                            validationBanner(message: validationMessage)
                        }

                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: 18) {
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
                    .padding(.horizontal, 28)
                    .padding(.vertical, 24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { contestantID in
                ContestantVoteView(contestantID: contestantID)
                    .environmentObject(session)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(session.title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    RemainingVotesBadge(
                        votes: session.remainingVotes,
                        width: 360,
                        numberFontSize: 54,
                        trailingPadding: 26
                    )

                    Spacer()

                    if session.isLocked {
                        Text("余额已归零，投票已锁定")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(.white.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        summaryChip(title: "已完成", value: "\(session.completedContestantCount) / 16")
                        summaryChip(title: "待投", value: "\(session.pendingContestantCount) 位")
                    }

                    VStack(spacing: 12) {
                        summaryChip(title: "已完成", value: "\(session.completedContestantCount) / 16")
                        summaryChip(title: "待投", value: "\(session.pendingContestantCount) 位")
                    }
                }
            }
            .padding(24)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
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

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)
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

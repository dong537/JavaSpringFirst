import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: VotingSessionViewModel
    @State private var path: [String] = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.13, blue: 0.25), Color(red: 0.11, green: 0.25, blue: 0.42)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    header

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(session.sortedContestants) { contestant in
                                Button {
                                    guard session.canOpenVoting(for: contestant) else {
                                        return
                                    }

                                    path.append(contestant.id)
                                } label: {
                                    ContestantCard(
                                        contestant: contestant,
                                        isEnabled: session.canOpenVoting(for: contestant),
                                        isLocked: session.isLocked
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(!session.canOpenVoting(for: contestant))
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 24)
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

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("剩余投票余额")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("\(session.remainingVotes) 票")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.86, blue: 0.31))
                }

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
            .padding(24)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(VotingSessionViewModel())
}

import SwiftUI

@main
struct TianlaiVotePadApp: App {
    @StateObject private var session = VotingSessionViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(session)
        }
    }
}

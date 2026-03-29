import Combine
import Foundation

enum ContestantEntryState: Equatable {
    case pending
    case voted(Int)
    case locked
    case invalidConfiguration

    var isInteractive: Bool {
        self == .pending
    }
}

@MainActor
final class VotingSessionViewModel: ObservableObject {
    @Published private(set) var contestants: [Contestant]
    @Published private(set) var remainingVotes: Int

    let title: String
    let badgeAssetName: String
    let initialVotes: Int
    let confirmationTemplate: String
    let validationMessage: String?

    init(config: AppConfig = .load()) {
        title = config.title
        badgeAssetName = config.badgeAssetName
        initialVotes = config.initialVotes
        confirmationTemplate = config.confirmationTemplate
        validationMessage = config.validationMessage
        contestants = config.contestants.sorted { $0.order < $1.order }
        remainingVotes = config.initialVotes
    }

    var isLocked: Bool {
        remainingVotes == 0
    }

    var isConfigurationValid: Bool {
        validationMessage == nil
    }

    var sortedContestants: [Contestant] {
        contestants
    }

    var completedContestantCount: Int {
        contestants.filter(\.voted).count
    }

    var pendingContestantCount: Int {
        contestants.count - completedContestantCount
    }

    func contestant(for id: String) -> Contestant? {
        contestants.first { $0.id == id }
    }

    func entryState(for contestant: Contestant) -> ContestantEntryState {
        if contestant.voted {
            return .voted(contestant.allocatedVotes ?? 0)
        }

        if !isConfigurationValid {
            return .invalidConfiguration
        }

        if isLocked {
            return .locked
        }

        return .pending
    }

    func canOpenVoting(for contestant: Contestant) -> Bool {
        entryState(for: contestant).isInteractive
    }

    func isVoteEnabled(_ count: Int, for contestant: Contestant) -> Bool {
        guard canOpenVoting(for: contestant) else {
            return false
        }

        return count >= 0 && count <= remainingVotes
    }

    func confirmationMessage(voteCount: Int) -> String {
        String(format: confirmationTemplate, voteCount)
    }

    @discardableResult
    func confirmVotes(for contestantID: String, count: Int) -> Bool {
        guard isConfigurationValid, count >= 0, count <= remainingVotes else {
            return false
        }

        guard let index = contestants.firstIndex(where: { $0.id == contestantID }) else {
            return false
        }

        guard contestants[index].voted == false else {
            return false
        }

        contestants[index].voted = true
        contestants[index].allocatedVotes = count
        remainingVotes -= count
        return true
    }
}

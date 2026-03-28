import Combine
import Foundation

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
        contestants.sorted { $0.order < $1.order }
    }

    func contestant(for id: String) -> Contestant? {
        contestants.first { $0.id == id }
    }

    func canOpenVoting(for contestant: Contestant) -> Bool {
        !contestant.voted && !isLocked && isConfigurationValid
    }

    func isVoteEnabled(_ count: Int, for contestant: Contestant) -> Bool {
        guard canOpenVoting(for: contestant) else {
            return false
        }

        return count >= 0 && count <= remainingVotes
    }

    func confirmationMessage(for contestantName: String, voteCount: Int) -> String {
        String(format: confirmationTemplate, contestantName, voteCount)
    }

    @discardableResult
    func confirmVotes(for contestantID: String, count: Int) -> Bool {
        guard count >= 0, count <= remainingVotes else {
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

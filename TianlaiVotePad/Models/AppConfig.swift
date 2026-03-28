import Foundation

struct AppConfig {
    let title: String
    let initialVotes: Int
    let badgeAssetName: String
    let confirmationTemplate: String
    let contestants: [Contestant]
    let validationMessage: String?

    var isValid: Bool {
        validationMessage == nil
    }

    static func load(bundle: Bundle = .main) -> AppConfig {
        let contestantLoadResult = loadContestants(bundle: bundle)

        return AppConfig(
            title: "《天籁与少年》投票器",
            initialVotes: 16,
            badgeAssetName: "BadgeLogo",
            confirmationTemplate: "是否确认为【%@】投 %d 票？",
            contestants: contestantLoadResult.contestants,
            validationMessage: contestantLoadResult.validationMessage
        )
    }

    private static func loadContestants(bundle: Bundle) -> ContestantLoadResult {
        guard
            let url = bundle.url(forResource: "contestants", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let seeds = try? JSONDecoder().decode([ContestantSeed].self, from: data)
        else {
            return ContestantLoadResult(
                contestants: fallbackContestants,
                validationMessage: "名单未配置完成，请检查 contestants.json。"
            )
        }

        let contestants = seeds
            .sorted { $0.order < $1.order }
            .map {
                Contestant(
                    id: $0.id,
                    name: $0.name,
                    order: $0.order
                )
            }

        guard isValidContestantList(contestants) else {
            return ContestantLoadResult(
                contestants: fallbackContestants,
                validationMessage: "名单未配置完成，请确认已提供 16 位选手的完整姓名与排序。"
            )
        }

        return ContestantLoadResult(contestants: contestants, validationMessage: nil)
    }

    private static func isValidContestantList(_ contestants: [Contestant]) -> Bool {
        guard contestants.count == 16 else {
            return false
        }

        let ids = Set(contestants.map(\.id))
        let orders = Set(contestants.map(\.order))
        let hasAllNames = contestants.allSatisfy { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        return ids.count == 16 && orders == Set(1...16) && hasAllNames
    }

    private static let fallbackContestants: [Contestant] = (1...16).map { index in
        Contestant(
            id: String(format: "contestant-%02d", index),
            name: String(format: "少年%02d", index),
            order: index
        )
    }
}

private struct ContestantSeed: Codable {
    let id: String
    let name: String
    let order: Int
}

private struct ContestantLoadResult {
    let contestants: [Contestant]
    let validationMessage: String?
}

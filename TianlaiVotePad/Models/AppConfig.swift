import Foundation

struct AppConfig {
    let title: String
    let initialVotes: Int
    let badgeAssetName: String
    let contestants: [Contestant]

    static func load(bundle: Bundle = .main) -> AppConfig {
        let contestants = loadContestants(bundle: bundle)

        return AppConfig(
            title: "《天籁与少年》投票器",
            initialVotes: 16,
            badgeAssetName: "BadgeLogo",
            contestants: contestants
        )
    }

    private static func loadContestants(bundle: Bundle) -> [Contestant] {
        guard
            let url = bundle.url(forResource: "contestants", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let seeds = try? JSONDecoder().decode([ContestantSeed].self, from: data),
            seeds.count == 16
        else {
            return fallbackContestants
        }

        return seeds
            .sorted { $0.order < $1.order }
            .map {
                Contestant(
                    id: $0.id,
                    name: $0.name,
                    order: $0.order
                )
            }
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

import Foundation

struct Contestant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let order: Int
    var voted: Bool
    var allocatedVotes: Int?

    init(
        id: String,
        name: String,
        order: Int,
        voted: Bool = false,
        allocatedVotes: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.voted = voted
        self.allocatedVotes = allocatedVotes
    }

    var badgeImageAssetName: String {
        String(format: "ContestantBadge%02d", order)
    }

    var badgeAccessibilityLabel: String {
        "\(name) 选手徽章"
    }
}

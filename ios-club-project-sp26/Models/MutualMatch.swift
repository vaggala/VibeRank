import Foundation

struct MutualMatch: Identifiable {
    let id: String
    let otherUserId: String
    let otherUserName: String
    let otherUserInstagram: String
    let otherUserHasInstagram: Bool
    let createdAt: Date

    static func pairDocId(_ a: String, _ b: String) -> String {
        let sorted = [a, b].sorted()
        return "\(sorted[0])_\(sorted[1])"
    }
}

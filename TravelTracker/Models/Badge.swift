import Foundation

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    var dateEarned: Date?
    
    static let allBadges: [Badge] = [
        Badge(id: "fifty_percent", name: "Halfway There", description: "Visit 50% of US states", imageName: "star.circle.fill"),
        Badge(id: "all_states", name: "All American", description: "Visit all 50 US states", imageName: "star.fill"),
        Badge(id: "east_coast", name: "East Coast King", description: "Visit all states touching the Atlantic Ocean", imageName: "water.waves"),
        Badge(id: "west_coast", name: "West Coast Best Coast", description: "Visit all states touching the Pacific Ocean", imageName: "sunset.fill"),
        Badge(id: "gulf_coast", name: "Gulf Explorer", description: "Visit all states touching the Gulf of Mexico", imageName: "tropicalstorm"),
        Badge(id: "four_corners", name: "Four Corners", description: "Visit all four corner states (Utah, Colorado, Arizona, New Mexico)", imageName: "square.grid.2x2.fill"),
        Badge(id: "great_lakes", name: "Great Lakes Tour", description: "Visit all states touching the Great Lakes", imageName: "drop.fill"),
        Badge(id: "hawaii_alaska", name: "Non-Continental", description: "Visit both Hawaii and Alaska", imageName: "airplane.circle.fill")
    ]
} 
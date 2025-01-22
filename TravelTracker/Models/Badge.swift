import Foundation

struct Badge: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    var dateEarned: Date?
    
    static let allBadges: [Badge] = [
        // Progress Badges
        Badge(id: "fifty_percent", name: "Halfway There", description: "Visit 50% of US states", imageName: "star.circle.fill"),
        Badge(id: "all_states", name: "All American", description: "Visit all 50 US states", imageName: "star.fill"),
        Badge(id: "continental", name: "Continental Explorer", description: "Visit all 48 continental states", imageName: "map.fill"),
        
        // Regional Badges
        Badge(id: "east_coast", name: "East Coast King", description: "Visit all states touching the Atlantic Ocean", imageName: "water.waves"),
        Badge(id: "west_coast", name: "West Coast Best Coast", description: "Visit all states touching the Pacific Ocean", imageName: "sunset.fill"),
        Badge(id: "gulf_coast", name: "Gulf Explorer", description: "Visit all states touching the Gulf of Mexico", imageName: "tropicalstorm"),
        Badge(id: "great_lakes", name: "Great Lakes Tour", description: "Visit all states touching the Great Lakes", imageName: "drop.fill"),
        Badge(id: "midwest", name: "Midwest Maven", description: "Visit all Midwest states", imageName: "leaf.circle.fill"),
        Badge(id: "new_england", name: "New England Explorer", description: "Visit all New England states", imageName: "fish.fill"),
        Badge(id: "mountain", name: "Mountain Climber", description: "Visit all Mountain states", imageName: "mountain.2.fill"),
        Badge(id: "southwest", name: "Southwest Wanderer", description: "Visit all Southwest states", imageName: "sun.max.fill"),
        Badge(id: "south", name: "Southern Charm", description: "Visit all Southern states", imageName: "cup.and.saucer.fill"),
        
        // Special Badges
        Badge(id: "four_corners", name: "Four Corners", description: "Visit all four corner states", imageName: "square.grid.2x2.fill"),
        Badge(id: "hawaii_alaska", name: "Non-Continental", description: "Visit both Hawaii and Alaska", imageName: "airplane.circle.fill")
    ]
} 
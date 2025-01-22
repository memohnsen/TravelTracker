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
    
    // New function to calculate the latest visit date for a badge
    func getLatestVisitDate(from states: [USState]) -> Date? {
        let relevantStates: Set<String>
        
        switch id {
        case "fifty_percent":
            // For percentage badges, use all visited states
            relevantStates = Set(states.filter { $0.visitDate != nil }.map { $0.id })
            guard relevantStates.count >= 25 else { return nil }
            
        case "all_states":
            relevantStates = Set(states.filter { $0.visitDate != nil }.map { $0.id })
            guard relevantStates.count == 50 else { return nil }
            
        case "continental":
            let nonContinental = Set(["HI", "AK"])
            relevantStates = Set(states.filter { $0.visitDate != nil }.map { $0.id })
                .subtracting(nonContinental)
            guard relevantStates.count == 48 else { return nil }
            
        case "east_coast":
            let eastCoastStates = Set(["ME", "NH", "MA", "RI", "CT", "NY", "NJ", "PA", "DE", "MD", "VA", "NC", "SC", "GA", "FL"])
            relevantStates = eastCoastStates
            
        case "west_coast":
            let westCoastStates = Set(["CA", "OR", "WA", "AK"])
            relevantStates = westCoastStates
            
        case "gulf_coast":
            let gulfStates = Set(["FL", "AL", "MS", "LA", "TX"])
            relevantStates = gulfStates
            
        case "midwest":
            let midwestStates = Set(["ND", "SD", "NE", "KS", "MN", "IA", "MO", "WI", "IL", "IN", "MI", "OH"])
            relevantStates = midwestStates
            
        case "new_england":
            let newEnglandStates = Set(["ME", "NH", "VT", "MA", "RI", "CT"])
            relevantStates = newEnglandStates
            
        case "hawaii_alaska":
            let nonContinental = Set(["HI", "AK"])
            relevantStates = nonContinental
            
        default:
            return nil
        }
        
        // Get all visit dates for relevant states
        let visitDates = states
            .filter { relevantStates.contains($0.id) && $0.visitDate != nil }
            .compactMap { $0.visitDate }
        
        // Return the latest date if all required states are visited
        return !visitDates.isEmpty && visitDates.count == relevantStates.count
            ? visitDates.max()
            : nil
    }
} 
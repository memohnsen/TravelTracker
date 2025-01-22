import Foundation
import SwiftUI

class StatesViewModel: ObservableObject {
    @Published var states: [USState]
    @Published var visitedStates: Set<String> = []
    @Published var newlyEarnedBadge: Badge? = nil
    private var earnedBadges: Set<String> = []
    
    init() {
        // Initialize with all US states
        states = [
            USState(id: "AL", name: "Alabama", latitude: 32.7794, longitude: -86.8287),
            USState(id: "AK", name: "Alaska", latitude: 64.0685, longitude: -152.2782),
            USState(id: "AZ", name: "Arizona", latitude: 34.2744, longitude: -111.6602),
            USState(id: "AR", name: "Arkansas", latitude: 34.8938, longitude: -92.4426),
            USState(id: "CA", name: "California", latitude: 36.7783, longitude: -119.4179),
            USState(id: "CO", name: "Colorado", latitude: 39.5501, longitude: -105.7821),
            USState(id: "CT", name: "Connecticut", latitude: 41.6032, longitude: -73.0877),
            USState(id: "DE", name: "Delaware", latitude: 38.9108, longitude: -75.5277),
            USState(id: "FL", name: "Florida", latitude: 27.6648, longitude: -81.5158),
            USState(id: "GA", name: "Georgia", latitude: 32.1656, longitude: -82.9001),
            USState(id: "HI", name: "Hawaii", latitude: 19.8968, longitude: -155.5828),
            USState(id: "ID", name: "Idaho", latitude: 44.0682, longitude: -114.7420),
            USState(id: "IL", name: "Illinois", latitude: 40.6331, longitude: -89.3985),
            USState(id: "IN", name: "Indiana", latitude: 39.8497, longitude: -86.2583),
            USState(id: "IA", name: "Iowa", latitude: 42.0329, longitude: -93.5818),
            USState(id: "KS", name: "Kansas", latitude: 38.5266, longitude: -96.7265),
            USState(id: "KY", name: "Kentucky", latitude: 37.6681, longitude: -84.6701),
            USState(id: "LA", name: "Louisiana", latitude: 31.1695, longitude: -91.8678),
            USState(id: "ME", name: "Maine", latitude: 44.6939, longitude: -69.3819),
            USState(id: "MD", name: "Maryland", latitude: 39.0639, longitude: -76.8021),
            USState(id: "MA", name: "Massachusetts", latitude: 42.2302, longitude: -71.5301),
            USState(id: "MI", name: "Michigan", latitude: 44.3148, longitude: -85.6024),
            USState(id: "MN", name: "Minnesota", latitude: 46.7296, longitude: -94.6859),
            USState(id: "MS", name: "Mississippi", latitude: 32.7416, longitude: -89.6787),
            USState(id: "MO", name: "Missouri", latitude: 38.4561, longitude: -92.2884),
            USState(id: "MT", name: "Montana", latitude: 46.8797, longitude: -110.3626),
            USState(id: "NE", name: "Nebraska", latitude: 41.4925, longitude: -99.9018),
            USState(id: "NV", name: "Nevada", latitude: 38.8026, longitude: -116.4194),
            USState(id: "NH", name: "New Hampshire", latitude: 43.1939, longitude: -71.5724),
            USState(id: "NJ", name: "New Jersey", latitude: 40.0583, longitude: -74.4057),
            USState(id: "NM", name: "New Mexico", latitude: 34.5199, longitude: -105.8701),
            USState(id: "NY", name: "New York", latitude: 42.1657, longitude: -74.9481),
            USState(id: "NC", name: "North Carolina", latitude: 35.7596, longitude: -79.0193),
            USState(id: "ND", name: "North Dakota", latitude: 47.5515, longitude: -101.0020),
            USState(id: "OH", name: "Ohio", latitude: 40.4173, longitude: -82.9071),
            USState(id: "OK", name: "Oklahoma", latitude: 35.0078, longitude: -97.0929),
            USState(id: "OR", name: "Oregon", latitude: 44.0721, longitude: -120.5186),
            USState(id: "PA", name: "Pennsylvania", latitude: 41.2033, longitude: -77.1945),
            USState(id: "RI", name: "Rhode Island", latitude: 41.5801, longitude: -71.4774),
            USState(id: "SC", name: "South Carolina", latitude: 33.8361, longitude: -81.1637),
            USState(id: "SD", name: "South Dakota", latitude: 43.9695, longitude: -99.9018),
            USState(id: "TN", name: "Tennessee", latitude: 35.7478, longitude: -86.6923),
            USState(id: "TX", name: "Texas", latitude: 31.9686, longitude: -99.9018),
            USState(id: "UT", name: "Utah", latitude: 39.3210, longitude: -111.0937),
            USState(id: "VT", name: "Vermont", latitude: 44.5588, longitude: -72.5778),
            USState(id: "VA", name: "Virginia", latitude: 37.4316, longitude: -78.6569),
            USState(id: "WA", name: "Washington", latitude: 47.7511, longitude: -120.7401),
            USState(id: "WV", name: "West Virginia", latitude: 38.5976, longitude: -80.4549),
            USState(id: "WI", name: "Wisconsin", latitude: 43.7844, longitude: -88.7879),
            USState(id: "WY", name: "Wyoming", latitude: 42.7475, longitude: -107.2085),
        ]
        
        // Load earned badges
        if let data = UserDefaults.standard.data(forKey: "EarnedBadges"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            earnedBadges = decoded
        }
        
        loadVisitedStates()
    }
    
    func checkForNewBadges() {
        for badge in Badge.allBadges {
            if !earnedBadges.contains(badge.id) && isEarned(badge) {
                newlyEarnedBadge = badge
                earnedBadges.insert(badge.id)
                saveEarnedBadges()
                
                // Reset after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.newlyEarnedBadge = nil
                }
                break // Show only one badge at a time
            }
        }
    }
    
    private func isEarned(_ badge: Badge) -> Bool {
        switch badge.id {
        case "fifty_percent":
            return visitedStates.count >= 25
        case "all_states":
            return visitedStates.count == 50
        case "east_coast":
            let eastCoastStates = ["ME", "NH", "MA", "RI", "CT", "NY", "NJ", "PA", "DE", "MD", "VA", "NC", "SC", "GA", "FL"]
            return Set(eastCoastStates).isSubset(of: visitedStates)
        case "west_coast":
            let westCoastStates = ["CA", "OR", "WA", "AK"]
            return Set(westCoastStates).isSubset(of: visitedStates)
        case "gulf_coast":
            let gulfStates = ["FL", "AL", "MS", "LA", "TX"]
            return Set(gulfStates).isSubset(of: visitedStates)
        case "four_corners":
            let cornerStates = ["UT", "CO", "AZ", "NM"]
            return Set(cornerStates).isSubset(of: visitedStates)
        case "great_lakes":
            let greatLakesStates = ["MN", "WI", "IL", "IN", "MI", "OH", "PA", "NY"]
            return Set(greatLakesStates).isSubset(of: visitedStates)
        case "hawaii_alaska":
            return visitedStates.contains("HI") && visitedStates.contains("AK")
        default:
            return false
        }
    }
    
    func toggleStateVisited(_ stateId: String) {
        if let index = states.firstIndex(where: { $0.id == stateId }) {
            var state = states[index]
            if state.visitDate == nil {
                state.visitDate = Date()
                visitedStates.insert(stateId)
                checkForNewBadges() // Check for badges after adding a state
            } else {
                state.visitDate = nil
                visitedStates.remove(stateId)
            }
            states[index] = state
            saveVisitedStates()
        }
    }
    
    func updateVisitDate(for stateId: String, date: Date) {
        if let index = states.firstIndex(where: { $0.id == stateId }) {
            var state = states[index]
            state.visitDate = date
            states[index] = state
            visitedStates.insert(stateId)
            saveVisitedStates()
        }
    }
    
    private func loadVisitedStates() {
        // Load basic visited states set
        if let visitedData = UserDefaults.standard.data(forKey: "VisitedStates"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: visitedData) {
            visitedStates = decoded
        }
        
        // Load states with their visit dates
        if let statesData = UserDefaults.standard.data(forKey: "StatesWithDates"),
           let decodedStates = try? JSONDecoder().decode([USState].self, from: statesData) {
            // Update states array with saved visit dates
            for savedState in decodedStates {
                if let index = states.firstIndex(where: { $0.id == savedState.id }) {
                    states[index].visitDate = savedState.visitDate
                }
            }
        }
    }
    
    func saveVisitedStates() {
        // Save basic visited states set
        if let encoded = try? JSONEncoder().encode(visitedStates) {
            UserDefaults.standard.set(encoded, forKey: "VisitedStates")
        }
        
        // Save states with their visit dates
        let statesWithDates = states.filter { $0.visitDate != nil }
        if let encoded = try? JSONEncoder().encode(statesWithDates) {
            UserDefaults.standard.set(encoded, forKey: "StatesWithDates")
        }
    }
    
    private func saveEarnedBadges() {
        if let encoded = try? JSONEncoder().encode(earnedBadges) {
            UserDefaults.standard.set(encoded, forKey: "EarnedBadges")
        }
    }
    
    func resetAllProgress() {
        // Clear all visit dates
        for index in states.indices {
            states[index].visitDate = nil
        }
        // Clear visited states set
        visitedStates.removeAll()
        // Clear earned badges
        earnedBadges.removeAll()
        // Save changes
        saveVisitedStates()
        saveEarnedBadges()
    }
} 
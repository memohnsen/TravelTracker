import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    
    var earnedBadges: [Badge] {
        Badge.allBadges.filter { badge in
            switch badge.id {
            case "fifty_percent":
                return viewModel.visitedStates.count >= 25
            case "all_states":
                return viewModel.visitedStates.count == 50
            case "east_coast":
                let eastCoastStates = ["ME", "NH", "MA", "RI", "CT", "NY", "NJ", "PA", "DE", "MD", "VA", "NC", "SC", "GA", "FL"]
                return Set(eastCoastStates).isSubset(of: viewModel.visitedStates)
            case "west_coast":
                let westCoastStates = ["CA", "OR", "WA", "AK"]
                return Set(westCoastStates).isSubset(of: viewModel.visitedStates)
            case "gulf_coast":
                let gulfStates = ["FL", "AL", "MS", "LA", "TX"]
                return Set(gulfStates).isSubset(of: viewModel.visitedStates)
            case "four_corners":
                let cornerStates = ["UT", "CO", "AZ", "NM"]
                return Set(cornerStates).isSubset(of: viewModel.visitedStates)
            case "great_lakes":
                let greatLakesStates = ["MN", "WI", "IL", "IN", "MI", "OH", "PA", "NY"]
                return Set(greatLakesStates).isSubset(of: viewModel.visitedStates)
            case "hawaii_alaska":
                return viewModel.visitedStates.contains("HI") && viewModel.visitedStates.contains("AK")
            default:
                return false
            }
        }
    }
    
    var unclaimedBadges: [Badge] {
        Badge.allBadges.filter { badge in
            !earnedBadges.contains { $0.id == badge.id }
        }
    }
    
    var body: some View {
        List {
            if !earnedBadges.isEmpty {
                Section("Earned") {
                    ForEach(earnedBadges) { badge in
                        BadgeRow(badge: badge, isEarned: true)
                    }
                }
            }
            
            Section("Unearned") {
                ForEach(unclaimedBadges) { badge in
                    BadgeRow(badge: badge, isEarned: false)
                }
            }
        }
        .navigationTitle("Badges")
    }
}

struct BadgeRow: View {
    let badge: Badge
    let isEarned: Bool
    
    var body: some View {
        HStack {
            Image(systemName: badge.imageName)
                .font(.title)
                .foregroundStyle(isEarned ? .yellow : .gray)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(badge.name)
                    .font(.headline)
                
                Text(badge.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isEarned {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 8)
    }
} 
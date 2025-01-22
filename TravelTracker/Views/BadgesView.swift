import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    
    var earnedBadges: [Badge] {
        Badge.allBadges.filter { viewModel.isEarned($0) }
    }
    
    var unclaimedBadges: [Badge] {
        Badge.allBadges.filter { !viewModel.isEarned($0) }
    }
    
    var body: some View {
        List {
            if !earnedBadges.isEmpty {
                Section("Earned") {
                    ForEach(earnedBadges) { badge in
                        BadgeRow(
                            badge: badge,
                            isEarned: true,
                            latestVisitDate: badge.getLatestVisitDate(from: viewModel.states)
                        )
                    }
                }
            }
            
            Section("Unearned") {
                ForEach(unclaimedBadges) { badge in
                    BadgeRow(
                        badge: badge,
                        isEarned: false,
                        latestVisitDate: nil
                    )
                }
            }
        }
        .navigationTitle("Badges")
    }
}

struct BadgeRow: View {
    let badge: Badge
    let isEarned: Bool
    let latestVisitDate: Date?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
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
                
                if isEarned, let date = latestVisitDate {
                    Text("Earned \(dateFormatter.string(from: date))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
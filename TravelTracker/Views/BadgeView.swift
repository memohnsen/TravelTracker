import SwiftUI
import Foundation

struct BadgeView: View {
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
        VStack {
            Image(systemName: badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(isEarned ? .blue : .gray)
                .opacity(isEarned ? 1.0 : 0.5)
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(badge.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if isEarned, let date = latestVisitDate {
                Text(dateFormatter.string(from: date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .frame(width: 120)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        }
    }
} 

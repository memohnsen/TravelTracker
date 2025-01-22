import SwiftUI

struct PassportView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @State private var selectedYear: String = "all"
    @State private var shareImage: Image?
    @State private var isShareSheetPresented = false
    
    var navigationTitle: String {
        if selectedYear == "all" {
            return "All Time Passport"
        } else {
            return "\(selectedYear) Passport"
        }
    }
    
    var visitYears: [String] {
        let calendar = Calendar.current
        let years = viewModel.states.compactMap { state -> Int? in
            guard let visitDate = state.visitDate else { return nil }
            return calendar.component(.year, from: visitDate)
        }
        let uniqueYears = Array(Set(years)).sorted(by: >)  // Reversed order so newest is first
        return ["all"] + uniqueYears.map { String($0) }  // "all" at the start
    }
    
    var filteredStates: [USState] {
        if selectedYear == "all" {
            return allTimeStates
        } else {
            let year = Int(selectedYear) ?? Calendar.current.component(.year, from: Date())
            return statesForYear(year)
        }
    }
    
    var allTimeStates: [USState] {
        viewModel.states.filter { $0.visitDate != nil }
            .sorted { $0.visitDate ?? Date() > $1.visitDate ?? Date() }
    }
    
    func statesForYear(_ year: Int) -> [USState] {
        let calendar = Calendar.current
        
        return viewModel.states.filter { state in
            guard let visitDate = state.visitDate else { return false }
            let visitYear = calendar.component(.year, from: visitDate)
            return visitYear == year
        }.sorted { $0.visitDate ?? Date() > $1.visitDate ?? Date() }
    }
    
    var currentYearIndex: Int {
        visitYears.firstIndex(of: selectedYear) ?? 0
    }
    
    var canGoBack: Bool {
        currentYearIndex > 0
    }
    
    var canGoForward: Bool {
        currentYearIndex < visitYears.count - 1
    }
    
    func createShareMessage(for states: [USState]) -> String {
        let stateCount = states.count
        let percentage = Int((Float(stateCount) / 50.0) * 100)
        let timeframe = selectedYear == "all" ? "total" : "in \(selectedYear)"
        
        var message = "🗺 My US Travel Progress \(timeframe):\n"
        message += "• Visited \(stateCount) states (\(percentage)% of the US)\n"
        
        if let firstVisit = states.last?.visitDate,
           let lastVisit = states.first?.visitDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = selectedYear == "all" ? "MMM d, yyyy" : "MMM d"
            
            if firstVisit != lastVisit {
                message += "• First visit: \(dateFormatter.string(from: firstVisit))\n"
                message += "• Latest visit: \(dateFormatter.string(from: lastVisit))\n"
            }
        }
        
        // Add earned badges for the timeframe
        let earnedBadges = Badge.allBadges.filter { badge in
            switch badge.id {
            case "fifty_percent":
                return stateCount >= 25
            case "all_states":
                return stateCount == 50
            // Add other badge checks as needed
            default:
                return false
            }
        }
        
        if !earnedBadges.isEmpty {
            message += "\n🏆 Badges earned:\n"
            earnedBadges.forEach { badge in
                message += "• \(badge.name)\n"
            }
        }
        
        message += "\nTracked with Travel Tracker 🧭"
        return message
    }
    
    func generateShareImage(for states: [USState]) -> UIImage {
        let timeframe = selectedYear == "all" ? "All Time" : selectedYear
        let renderer = ImageRenderer(content: ShareableStatsView(
            states: states,
            timeframe: timeframe
        ))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }
    
    func badgesEarnedInYear(_ year: Int?) -> [Badge] {
        return Badge.allBadges.filter { badge in
            guard let date = badge.getLatestVisitDate(from: viewModel.states) else {
                return false
            }
            
            if let year = year {
                return Calendar.current.component(.year, from: date) == year
            } else {
                // For "all" time view, show all earned badges
                return true
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedYear) {
            ForEach(visitYears, id: \.self) { year in
                List {
                    Section {
                        StatsView(
                            states: selectedYear == "all" ? allTimeStates : statesForYear(Int(year) ?? 0),
                            isYearView: selectedYear != "all"
                        )
                    }
                    
                    let badges = badgesEarnedInYear(year == "all" ? nil : Int(year))
                    if !badges.isEmpty {
                        Section("Badges Earned") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(badges) { badge in
                                        VStack(spacing: 8) {
                                            Image(systemName: badge.imageName)
                                                .font(.title)
                                                .foregroundStyle(.yellow)
                                            
                                            Text(badge.name)
                                                .font(.caption)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                                .frame(height: 32)
                                            
                                            if let date = badge.getLatestVisitDate(from: viewModel.states) {
                                                Text(date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .frame(width: 80, height: 120)
                                        .padding()
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.1), radius: 5)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    let states = year == "all" ? allTimeStates : statesForYear(Int(year) ?? 0)
                    if !states.isEmpty {
                        Section(year == "all" ? "All States Visited" : "States Visited in \(year)") {
                            ForEach(states) { state in
                                StateVisitRow(state: state)
                            }
                        }
                    } else {
                        Section {
                            Text("No states visited")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .tag(year)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .navigationTitle(navigationTitle)
        .animation(.default, value: navigationTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let image = generateShareImage(
                        for: selectedYear == "all" ? allTimeStates : statesForYear(Int(selectedYear) ?? 0)
                    )
                    let activityVC = UIActivityViewController(
                        activityItems: [image],
                        applicationActivities: nil
                    )
                    
                    // For iPad
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        activityVC.popoverPresentationController?.sourceView = rootVC.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                        activityVC.popoverPresentationController?.permittedArrowDirections = []
                    }
                    
                    // Present the share sheet
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootVC = window.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            selectedYear = "all"
        }
    }
}

struct YearView: View {
    let year: String
    let states: [USState]
    
    var body: some View {
        List {
            if states.isEmpty {
                Section {
                    Text("No states visited")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else {
                Section {
                    StatsView(
                        states: states,
                        isYearView: year != "all"
                    )
                }
                
                Section(year == "all" ? "All States Visited" : "States Visited in \(year)") {
                    ForEach(states) { state in
                        StateVisitRow(state: state)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct StatsView: View {
    let states: [USState]
    let isYearView: Bool
    
    private func formatDate(_ date: Date) -> String {
        if isYearView {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                StatBox(title: "New States", value: "\(states.count)")
                StatBox(title: "% of the US", value: "\(Int((Float(states.count) / 50.0) * 100))%")
            }
            
            if let firstVisit = states.last?.visitDate,
               let lastVisit = states.first?.visitDate {
                HStack(spacing: 16) {
                    StatBox(
                        title: "First Visit",
                        value: formatDate(firstVisit)
                    )
                    StatBox(
                        title: "Latest Visit",
                        value: formatDate(lastVisit)
                    )
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondary.opacity(0.1))
        }
    }
}

struct StateVisitRow: View {
    let state: USState
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(state.name)
                    .font(.headline)
                
                if let visitDate = state.visitDate {
                    Text(visitDate.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
} 
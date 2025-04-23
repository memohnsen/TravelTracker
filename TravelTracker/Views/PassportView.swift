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
        let years = viewModel.states.flatMap { $0.visitDates }.map { calendar.component(.year, from: $0) }
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
        viewModel.states.filter { !$0.visitDates.isEmpty }
            .sorted { ($0.visitDates.max() ?? Date()) > ($1.visitDates.max() ?? Date()) }
    }
    
    func statesForYear(_ year: Int) -> [USState] {
        let calendar = Calendar.current
        return viewModel.states.filter { state in
            state.visitDates.contains(where: { calendar.component(.year, from: $0) == year })
        }.sorted { ($0.visitDates.max() ?? Date()) > ($1.visitDates.max() ?? Date()) }
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
    
    func createShareMessage(for states: [USState], selectedYear: String) -> String {
        let calendar = Calendar.current
        let filteredStates: [USState] = {
            if selectedYear == "all" {
                return states
            } else if let year = Int(selectedYear) {
                return states.compactMap { state in
                    let yearDates = state.visitDates.filter { calendar.component(.year, from: $0) == year }
                    return yearDates.isEmpty ? nil : USState(id: state.id, name: state.name, latitude: state.coordinates.latitude, longitude: state.coordinates.longitude, visitDates: yearDates)
                }
            } else {
                return states
            }
        }()
        let stateCount = filteredStates.count
        let percentage = Int((Float(stateCount) / 50.0) * 100)
        let timeframe = selectedYear == "all" ? "total" : "in \(selectedYear)"
        var message = "🗺 My US Travel Progress \(timeframe):\n"
        message += "• Visited \(stateCount) states (\(percentage)% of the US)\n"
        if let firstVisit = filteredStates.compactMap({ $0.visitDates.min() }).min(),
           let lastVisit = filteredStates.compactMap({ $0.visitDates.max() }).max() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = selectedYear == "all" ? "MMM d, yyyy" : "MMM d"
            if firstVisit != lastVisit {
                message += "• First visit: \(dateFormatter.string(from: firstVisit))\n"
                message += "• Latest visit: \(dateFormatter.string(from: lastVisit))\n"
            }
        }
        // Add earned badges for the timeframe (keep as before)
        let earnedBadges = Badge.allBadges.filter { badge in
            switch badge.id {
            case "fifty_percent":
                return stateCount >= 25
            case "all_states":
                return stateCount == 50
            default:
                return false
            }
        }
        if !earnedBadges.isEmpty {
            earnedBadges.forEach { badge in
                message += "• \(badge.name)\n"
            }
        }
        message += "\nTracked with TrekBook 🧭"
        return message
    }
    
    func generateShareImage(for states: [USState], selectedYear: String) -> UIImage {
        let calendar = Calendar.current
        let filteredStates: [USState] = {
            if selectedYear == "all" {
                return states
            } else if let year = Int(selectedYear) {
                return states.compactMap { state in
                    let yearDates = state.visitDates.filter { calendar.component(.year, from: $0) == year }
                    return yearDates.isEmpty ? nil : USState(id: state.id, name: state.name, latitude: state.coordinates.latitude, longitude: state.coordinates.longitude, visitDates: yearDates)
                }
            } else {
                return states
            }
        }()
        let timeframe = selectedYear == "all" ? "All Time" : selectedYear
        let renderer = ImageRenderer(content: ShareableStatsView(
            states: filteredStates,
            timeframe: timeframe
        ))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
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
    
    struct StatsView: View {
        let states: [USState]
        let isYearView: Bool
        let selectedYear: String
        
        private func formatDate(_ date: Date) -> String {
            if isYearView {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yy"
                return formatter.string(from: date)
            }
        }
        
        var body: some View {
            VStack(spacing: 20) {
                // Stats box area
                HStack(spacing: 16) {
                    StatBox(title: "States Visited", value: "\(states.count)")
                    let percentage = Int((Float(states.count) / 50.0) * 100)
                    StatBox(title: "% of US", value: "\(percentage)%")
                }
                let allVisitDates: [Date] = {
                    if isYearView, let year = Int(selectedYear) {
                        let calendar = Calendar.current
                        return states.flatMap { $0.visitDates }.filter { calendar.component(.year, from: $0) == year }
                    } else {
                        return states.flatMap { $0.visitDates }
                    }
                }()
                if let firstVisit = allVisitDates.min(),
                   let lastVisit = allVisitDates.max() {
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
    
    struct StateVisitRow: View {
        let state: USState
        let year: Int? // nil means show all years
        
        var filteredVisitDates: [Date] {
            guard let year = year else { return state.visitDates }
            let calendar = Calendar.current
            return state.visitDates.filter { calendar.component(.year, from: $0) == year }
        }
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(state.name)
                        .font(.headline)
                    ForEach(filteredVisitDates.sorted(by: >), id: \.self) { visitDate in
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
    
    var badgesCard: some View {
        let yearInt: Int? = selectedYear == "all" ? nil : Int(selectedYear)
        let badges: [Badge] = {
            if let year = yearInt {
                return Badge.allBadges.filter { badge in
                    guard let date = badge.getLatestVisitDate(from: filteredStates) else { return false }
                    return Calendar.current.component(.year, from: date) == year
                }
            } else {
                return Badge.allBadges.filter { badge in
                    badge.getLatestVisitDate(from: filteredStates) != nil
                }
            }
        }()
        return Group {
            if !badges.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(badges) { badge in
                                VStack(spacing: 8) {
                                    Image(systemName: badge.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundStyle(.yellow)
                                    Text(badge.name)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 80)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedYear) {
            ForEach(visitYears, id: \.self) { year in
                List {
                    Section {
                        StatsView(states: filteredStates, isYearView: selectedYear != "all", selectedYear: selectedYear)
                    }
                    Section {
                        badgesCard
                    }
                    Section(year == "all" ? "All States Visited" : "States Visited in \(year)") {
                        ForEach(filteredStates) { state in
                            StateVisitRow(state: state, year: selectedYear == "all" ? nil : Int(selectedYear))
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
                        for: selectedYear == "all" ? allTimeStates : allTimeStates, selectedYear: selectedYear
                    )
                    shareImage = Image(uiImage: image)
                    isShareSheetPresented = true
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

import SwiftUI

struct PassportView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @State private var selectedYear: String = "all"
    
    var visitYears: [String] {
        let calendar = Calendar.current
        let years = viewModel.states.compactMap { state -> Int? in
            guard let visitDate = state.visitDate else { return nil }
            return calendar.component(.year, from: visitDate)
        }
        let uniqueYears = Array(Set(years)).sorted(by: <)
        return uniqueYears.map { String($0) } + ["all"]
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
    
    var body: some View {
        List {
            if !visitYears.isEmpty {
                Picker("Timeframe", selection: $selectedYear) {
                    ForEach(visitYears, id: \.self) { year in
                        Text(year == "all" ? "All Time" : year)
                            .tag(year)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .padding(.vertical, 8)
                
                if filteredStates.isEmpty {
                    Section {
                        Text("No states visited")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    Section {
                        StatsView(
                            states: filteredStates,
                            isYearView: selectedYear != "all"
                        )
                    }
                    
                    Section(selectedYear == "all" ? "All States Visited" : "States Visited in \(selectedYear)") {
                        ForEach(filteredStates) { state in
                            StateVisitRow(state: state)
                        }
                    }
                }
            } else {
                Section {
                    Text("No states visited yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .navigationTitle("Passport")
        .onAppear {
            // Set initial selection to current year if it exists, otherwise "all"
            let currentYear = String(Calendar.current.component(.year, from: Date()))
            selectedYear = visitYears.contains(currentYear) ? currentYear : "all"
        }
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
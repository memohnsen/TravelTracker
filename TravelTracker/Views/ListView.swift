import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @State private var sortOption = SortOption.alphabetical
    @State private var filterOption = FilterOption.all
    @State private var selectedState: USState?
    @State private var isShowingDatePicker = false
    
    enum SortOption {
        case alphabetical
        case visitDateNewest
        case visitDateOldest
    }
    
    enum FilterOption {
        case all
        case visited
        case notVisited
    }
    
    var filteredAndSortedStates: [USState] {
        let filtered = viewModel.states.filter { state in
            switch filterOption {
            case .all: return true
            case .visited: return viewModel.visitedStates.contains(state.id)
            case .notVisited: return !viewModel.visitedStates.contains(state.id)
            }
        }
        
        switch sortOption {
        case .alphabetical:
            return filtered.sorted { $0.name < $1.name }
        case .visitDateNewest:
            return filtered.sorted { state1, state2 in
                switch (state1.visitDate, state2.visitDate) {
                case (nil, nil): return state1.name < state2.name
                case (nil, _): return false
                case (_, nil): return true
                case (let date1?, let date2?): return date1 > date2
                }
            }
        case .visitDateOldest:
            return filtered.sorted { state1, state2 in
                switch (state1.visitDate, state2.visitDate) {
                case (nil, nil): return state1.name < state2.name
                case (nil, _): return false
                case (_, nil): return true
                case (let date1?, let date2?): return date1 < date2
                }
            }
        }
    }
    
    var body: some View {
        List(filteredAndSortedStates) { state in
            HStack {
                VStack(alignment: .leading) {
                    Text(state.name)
                        .font(.headline)
                    if let visitDate = state.visitDate {
                        Text("Visited: \(visitDate.formatted(date: .long, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: viewModel.visitedStates.contains(state.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.visitedStates.contains(state.id) ? .green : .gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedState = state
                isShowingDatePicker = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Menu {
                        Button {
                            filterOption = .all
                        } label: {
                            Label("All States", systemImage: filterOption == .all ? "checkmark" : "")
                        }
                        
                        Button {
                            filterOption = .visited
                        } label: {
                            Label("Visited", systemImage: filterOption == .visited ? "checkmark" : "")
                        }
                        
                        Button {
                            filterOption = .notVisited
                        } label: {
                            Label("Not Visited", systemImage: filterOption == .notVisited ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(filterOption == .all ? .gray : .blue)
                    }
                    
                    Menu {
                        Button {
                            sortOption = .alphabetical
                        } label: {
                            Label("Alphabetical", systemImage: "abc")
                        }
                        
                        Button {
                            sortOption = .visitDateNewest
                        } label: {
                            Label("Newest Visits First", systemImage: "arrow.down.circle")
                        }
                        
                        Button {
                            sortOption = .visitDateOldest
                        } label: {
                            Label("Oldest Visits First", systemImage: "arrow.up.circle")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                .padding(.top, 80)
                .padding(.bottom, 80)
            }
        }
        .sheet(item: $selectedState) { state in
            NavigationStack {
                Form {
                    Section("Visit Status") {
                        Toggle("Visited", isOn: Binding(
                            get: { viewModel.visitedStates.contains(state.id) },
                            set: { isVisited in
                                viewModel.toggleStateVisited(state.id)
                            }
                        ))
                    }
                    
                    if viewModel.visitedStates.contains(state.id) {
                        Section("Visit Details") {
                            DatePicker(
                                "Visit Date",
                                selection: Binding(
                                    get: { state.visitDate ?? Date() },
                                    set: { date in
                                        viewModel.updateVisitDate(for: state.id, date: date)
                                        selectedState = nil  // Dismiss sheet after date selection
                                    }
                                ),
                                displayedComponents: .date
                            )
                        }
                    }
                }
                .navigationTitle(state.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            selectedState = nil
                        }
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
} 
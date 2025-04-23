import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @State private var sortOption = SortOption.alphabetical
    @State private var filterOption = FilterOption.all
    @State private var selectedStateId: String? = nil
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
                switch (state1.visitDates, state2.visitDates) {
                case ([], []): return state1.name < state2.name
                case ([], _): return false
                case (_, []): return true
                case (let dates1, let dates2): return dates1.max() ?? Date() > dates2.max() ?? Date()
                }
            }
        case .visitDateOldest:
            return filtered.sorted { state1, state2 in
                switch (state1.visitDates, state2.visitDates) {
                case ([], []): return state1.name < state2.name
                case ([], _): return false
                case (_, []): return true
                case (let dates1, let dates2): return dates1.min() ?? Date() < dates2.min() ?? Date()
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
                    if !state.visitDates.isEmpty {
                        ForEach(state.visitDates.sorted(by: >), id: \.self) { date in
                            Text("Visited: \(date.formatted(date: .long, time: .omitted))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: viewModel.visitedStates.contains(state.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewModel.visitedStates.contains(state.id) ? .green : .gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedStateId = state.id
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
        .sheet(item: Binding(
            get: { selectedStateId.map { IdentifiableString(id: $0) } },
            set: { selectedStateId = $0?.id }
        )) { identifiable in
            let stateId = identifiable.id
            if let state = viewModel.states.first(where: { $0.id == stateId }) {
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
                                Button("Add Visit Date") {
                                    viewModel.updateVisitDates(for: state.id, newDate: Date())
                                }
                                if !state.visitDates.isEmpty {
                                    ForEach(state.visitDates.indices, id: \.self) { idx in
                                        HStack {
                                            DatePicker(
                                                "Visited",
                                                selection: Binding(
                                                    get: { state.visitDates[idx] },
                                                    set: { newDate in
                                                        viewModel.updateVisitDate(for: state.id, at: idx, newDate: newDate)
                                                    }
                                                ),
                                                displayedComponents: .date
                                            )
                                            Spacer()
                                            Button(role: .destructive) {
                                                viewModel.removeVisitDate(for: state.id, at: idx)
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle(state.name)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

struct IdentifiableString: Identifiable, Hashable {
    let id: String
}
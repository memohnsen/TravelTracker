import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @AppStorage("showTerritories") private var showTerritories = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Statistics") {
                    HStack {
                        Text("States Visited")
                        Spacer()
                        Text("\(viewModel.visitedStates.count)/50")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completion")
                        Spacer()
                        Text("\(Int((Float(viewModel.visitedStates.count) / 50.0) * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("App Settings") {
                    Toggle("Show US Territories", isOn: $showTerritories)
                    
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Text("Reset All Progress")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Progress", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetAllProgress()
                }
            } message: {
                Text("Are you sure you want to reset all your progress? This cannot be undone.")
            }
        }
    }
} 
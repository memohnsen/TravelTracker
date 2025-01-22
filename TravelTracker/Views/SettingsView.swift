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
                    
                    NavigationLink {
                        BadgesView()
                    } label: {
                        HStack {
                            Text("Badges")
                            Spacer()
                            Text("\(viewModel.visitedStates.isEmpty ? "0" : String(Badge.allBadges.count))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        PassportView()
                    } label: {
                        Text("Passport")
                    }
                }
                
                Section("App Settings") {
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

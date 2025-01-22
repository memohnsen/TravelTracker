//
//  ContentView.swift
//  TravelTracker
//
//  Created by Maddisen Mohnsen on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StatesViewModel()
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            TabView {
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                NavigationStack {
                    ListView()
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .environmentObject(viewModel)
        }
        .onAppear {
            // Dismiss splash screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isShowingSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

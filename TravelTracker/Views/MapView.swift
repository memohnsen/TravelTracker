import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var viewModel: StatesViewModel
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of US
        span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30) // Reduced from 60 to 45 for closer zoom
    ))
    
    var body: some View {
        ZStack {
            Map(position: $position) {
                ForEach(viewModel.states) { state in
                    Annotation(state.name, coordinate: state.coordinates) {
                        ZStack {
                            Circle()
                                .fill(viewModel.visitedStates.contains(state.id) ? Color.green : Color.red)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                        .shadow(radius: 2)
                        .contentShape(Rectangle())
                        .frame(width: 44, height: 44) // Minimum touch target size
                        .onTapGesture {
                            viewModel.toggleStateVisited(state.id)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.top) // Only ignore top safe area
            
            VStack {
                Spacer()
                
                // Status Card
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(viewModel.visitedStates.count) of 50 states visited")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Progress Circle
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(viewModel.visitedStates.count) / 50.0)
                                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int((Float(viewModel.visitedStates.count) / 50.0) * 100))%")
                                .font(.caption)
                                .bold()
                        }
                        .frame(width: 44, height: 44)
                    }
                    
                    // Legend
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Visited")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Not Visited")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // Added extra bottom padding to move it up
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(StatesViewModel())
} 
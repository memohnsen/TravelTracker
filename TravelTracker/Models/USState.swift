import Foundation
import CoreLocation

struct USState: Identifiable, Codable, Equatable {
    let id: String // State abbreviation
    let name: String
    let coordinates: CLLocationCoordinate2D
    var visitDate: Date?
    
    // For Codable support
    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, visitDate
    }
    
    init(id: String, name: String, latitude: Double, longitude: Double, visitDate: Date? = nil) {
        self.id = id
        self.name = name
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.visitDate = visitDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        visitDate = try container.decodeIfPresent(Date.self, forKey: .visitDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinates.latitude, forKey: .latitude)
        try container.encode(coordinates.longitude, forKey: .longitude)
        try container.encodeIfPresent(visitDate, forKey: .visitDate)
    }
    
    // Add Equatable conformance
    static func == (lhs: USState, rhs: USState) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.coordinates.latitude == rhs.coordinates.latitude &&
        lhs.coordinates.longitude == rhs.coordinates.longitude &&
        lhs.visitDate == rhs.visitDate
    }
} 
import ActivityKit
import Foundation

struct ToothbrushAttributes: ActivityAttributes {
    
        public struct ContentState: Hashable, Codable {
            var displayLocation: String
            var timeRemaining: Int
            var isPaused: Bool
            var currentStepDeadline: Date?
        }

    var totalDuration: Int
}

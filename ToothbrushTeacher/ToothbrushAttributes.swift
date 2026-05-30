import ActivityKit
import Foundation

struct ToothbrushAttributes: ActivityAttributes, Sendable {
    
        public struct ContentState: Hashable, Codable, Sendable {
            var displayLocation: String
            var timeRemaining: Int
            var isPaused: Bool
            var currentStepDeadline: Date?
        }

    var totalDuration: Int
}

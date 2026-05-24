import ActivityKit
import WidgetKit
import SwiftUI

struct ToothbrushWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ToothbrushAttributes.self) { context in
            VStack {
                Text("\(context.state.displayLocation) をみがこう")
                    .font(.headline)
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🪥")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ProgressView(value: Double(context.state.timeRemaining), total: Double(context.attributes.totalDuration))
                        .progressViewStyle(.circular)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text("\(context.state.displayLocation) をみがき中")
                            .font(.title2)
                    }
                }
            } compactLeading: {
                Text(context.state.displayLocation)
                    .font(.body)
                    .bold()
            } compactTrailing: {
                Text(String(format: "%02d", context.state.timeRemaining))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.orange)
            } minimal: {
                Text(String(context.state.timeRemaining))
            }
        }
    }
}

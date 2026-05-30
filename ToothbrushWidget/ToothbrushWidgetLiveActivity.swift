import ActivityKit
import WidgetKit
import SwiftUI

struct ToothbrushWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ToothbrushAttributes.self) { context in
            VStack {
                Text("\(context.state.displayLocation) をみがこう")
                    .font(.headline)
                timerText(for: context.state, showsPrefix: true)
                    .font(.title2.monospacedDigit())
                    .foregroundColor(.orange)
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("🪥")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timerText(for: context.state)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.orange)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text("\(context.state.displayLocation) をみがき中")
                            .font(.title2)
                        timerText(for: context.state, showsPrefix: true)
                            .font(.title3.monospacedDigit())
                            .foregroundColor(.orange)
                    }
                }
            } compactLeading: {
                Text(context.state.displayLocation)
                    .font(.body)
                    .bold()
            } compactTrailing: {
                timerText(for: context.state)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.orange)
            } minimal: {
                timerText(for: context.state)
            }
        }
    }

    @ViewBuilder
    private func timerText(for state: ToothbrushAttributes.ContentState, showsPrefix: Bool = false) -> some View {
        let pausedText = showsPrefix
            ? "あと \(state.timeRemaining) 秒"
            : String(format: "%02d", state.timeRemaining)

        if state.isPaused {
            Text(pausedText)
        } else if let deadline = state.currentStepDeadline {
            Text(deadline, style: .timer)
        } else {
            Text(pausedText)
        }
    }
}

import Foundation
import ActivityKit
import SwiftUI

private let appGroupID = "group.com.toothbrush.ToothbrushTeacher"

@Observable
class ToothbrushViewModel {
    var isRunning = false
    var currentStepIndex = 0
    var timeRemainingInStep = 10
    var isPaused = false
    
    let steps = [
        "右奥側", "右奥表", "右奥裏",
        "右中側", "右中表", "右中裏",
        "左中側", "左中表", "左中裏",
        "左奥側", "左奥表", "左奥裏",
        // 下顎（かがく）のターン
        "下右側", "下右表", "下右裏",
        "下中側", "下中表", "下中裏",
        "下左側", "下左表", "下左裏",
        "下奥側", "下奥表", "下奥裏"
    ]
    
    private var activity: Activity<ToothbrushAttributes>? = nil
    private var timer: Timer? = nil
    private var intentObserver: NSObjectProtocol? = nil
    private var currentStepDeadline: Date? = nil
    
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        currentStepIndex = 0
        timeRemainingInStep = 10
        currentStepDeadline = Date.now.addingTimeInterval(TimeInterval(timeRemainingInStep))
        
        // App Group UserDefaults をリセット
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.removeObject(forKey: "isPaused")
        defaults?.removeObject(forKey: "shouldStop")
        
        let attributes = ToothbrushAttributes(totalDuration: 10)
        let initialState = ToothbrushAttributes.ContentState(
            displayLocation: steps[currentStepIndex],
            timeRemaining: timeRemainingInStep,
            isPaused: false,
            currentStepDeadline: currentStepDeadline
        )
        
        do {
            activity = try Activity.request(attributes: attributes, content: .init(state: initialState, staleDate: nil))
        } catch {
            print("Dynamic Islandの起動に失敗: \(error.localizedDescription)")
        }
        
        // Live Activity のボタン操作（AppIntent 経由）を監視
        intentObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: defaults,
            queue: .main
        ) { [weak self] _ in
            self?.handleIntentUpdates()
        }
        
        startTicking()
    }
    
    private func handleIntentUpdates() {
        let defaults = UserDefaults(suiteName: appGroupID)
        
        if defaults?.bool(forKey: "shouldStop") == true {
            defaults?.removeObject(forKey: "shouldStop")
            endTimer()
            return
        }
        
        let newPaused = defaults?.bool(forKey: "isPaused") ?? false
        if newPaused != isPaused {
            if newPaused {
                syncTimeRemainingWithDeadline()
                currentStepDeadline = nil
            } else {
                currentStepDeadline = Date.now.addingTimeInterval(TimeInterval(timeRemainingInStep))
            }
            isPaused = newPaused
            updateActivity()
        }
    }
    
    private func startTicking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard !isPaused else { return }
        
        if timeRemainingInStep > 1 {
            timeRemainingInStep -= 1
        } else {
            if currentStepIndex < steps.count - 1 {
                currentStepIndex += 1
                timeRemainingInStep = 10
                currentStepDeadline = Date.now.addingTimeInterval(TimeInterval(timeRemainingInStep))
                updateActivity()
            } else {
                endTimer()
                return
            }
        }
    }
    
    private func updateActivity() {
        let updatedState = ToothbrushAttributes.ContentState(
            displayLocation: steps[currentStepIndex],
            timeRemaining: timeRemainingInStep,
            isPaused: isPaused,
            currentStepDeadline: currentStepDeadline
        )
        
        Task {
            await activity?.update(.init(state: updatedState, staleDate: nil))
        }
    }

    private func syncTimeRemainingWithDeadline() {
        guard let currentStepDeadline else { return }
        timeRemainingInStep = max(0, Int(ceil(currentStepDeadline.timeIntervalSinceNow)))
    }
    
    func endTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        currentStepDeadline = nil
        
        if let observer = intentObserver {
            NotificationCenter.default.removeObserver(observer)
            intentObserver = nil
        }
        
        Task {
            await activity?.end(activity?.content, dismissalPolicy: .immediate)
        }
        
        // ここでカレンダーに今日のスタンプを押す（ローカルDBやUserDefaultsへの保存）ロジックを入れます
    }
}

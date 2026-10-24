import Foundation
import HealthKit
import SwiftUI

/// Manages authorization and recording of Mindful Sessions to Apple HealthKit.
@MainActor
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    @Published var isAuthorized: Bool = false

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private init() {
        checkAuthorizationStatus()
    }

    func checkAuthorizationStatus() {
        guard isHealthDataAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            isAuthorized = false
            return
        }

        let status = healthStore.authorizationStatus(for: mindfulType)
        isAuthorized = (status == .sharingAuthorized)
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard isHealthDataAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            completion(false)
            return
        }

        let typesToWrite: Set<HKSampleType> = [mindfulType]

        healthStore.requestAuthorization(toShare: typesToWrite, read: nil) { [weak self] success, error in
            Task { @MainActor in
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                }
                self?.checkAuthorizationStatus()
                completion(success && error == nil)
            }
        }
    }

    /// Records a completed mindful session (e.g. from Guided Breathing or continuous Haptic Zen focus).
    func saveMindfulSession(duration: TimeInterval, preferences: UserPreferences) {
        guard duration > 5 else { return } // Ignore sessions shorter than 5 seconds

        // Always update local and shared statistics (with automatic new-day reset)
        SharedDataManager.recordMindfulDuration(duration)
        preferences.dailyMindfulSeconds = SharedDataManager.getDailyMindfulSeconds()

        // Save to Apple Health if enabled and available
        guard preferences.isHealthKitTrackingEnabled,
              isHealthDataAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )

        healthStore.save(sample) { success, error in
            if let error = error {
                print("Failed to save mindful session to Apple Health: \(error.localizedDescription)")
            } else if success {
                print("Successfully saved \(Int(duration)) seconds mindful session to Apple Health.")
            }
        }
    }
}

//
//  OnboardingPresentation.swift
//  knowzeno
//

import Observation

@MainActor
@Observable
final class OnboardingPresentation {
    private(set) var isShowingSetupGuide = false

    func showSetupGuide() {
        isShowingSetupGuide = true
    }

    func completeSetupGuide() {
        isShowingSetupGuide = false
    }

    func shouldShowOnboarding(hasCompletedOnboarding: Bool) -> Bool {
        isShowingSetupGuide || hasCompletedOnboarding == false
    }
}

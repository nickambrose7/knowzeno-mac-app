//
//  OnboardingPresentationTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

@MainActor
struct OnboardingPresentationTests {
    @Test func firstRunShowsOnboarding() {
        let presentation = OnboardingPresentation()

        #expect(presentation.shouldShowOnboarding(hasCompletedOnboarding: false))
    }

    @Test func completedSetupHidesOnboardingByDefault() {
        let presentation = OnboardingPresentation()

        #expect(presentation.shouldShowOnboarding(hasCompletedOnboarding: true) == false)
    }

    @Test func helpCommandCanShowSetupGuideAgain() {
        let presentation = OnboardingPresentation()

        presentation.showSetupGuide()

        #expect(presentation.isShowingSetupGuide)
        #expect(presentation.shouldShowOnboarding(hasCompletedOnboarding: true))
    }

    @Test func completingSetupGuideReturnsToMainAppWhenOnboardingIsComplete() {
        let presentation = OnboardingPresentation()
        presentation.showSetupGuide()

        presentation.completeSetupGuide()

        #expect(presentation.isShowingSetupGuide == false)
        #expect(presentation.shouldShowOnboarding(hasCompletedOnboarding: true) == false)
    }
}

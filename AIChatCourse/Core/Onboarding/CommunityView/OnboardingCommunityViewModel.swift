//
//  OnboardingCommunityViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@MainActor
protocol OnboardingCommunityInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCommunityInteractor { }

@Observable
@MainActor
class OnboardingCommunityViewModel {
    
    private let interactor: OnboardingCommunityInteractor
    
    init(interactor: OnboardingCommunityInteractor) {
        self.interactor = interactor
    }
    
    func onContinueButtonPressed(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.colorView)
    }
}

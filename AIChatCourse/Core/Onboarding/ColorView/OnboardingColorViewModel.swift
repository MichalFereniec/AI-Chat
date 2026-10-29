//
//  OnboardingColorViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingColorInteractor { }

@Observable
@MainActor
class OnboardingColorViewModel {
    
    private let interactor: OnboardingColorInteractor
    
    private(set) var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]

    init(interactor: OnboardingColorInteractor) {
        self.interactor = interactor
    }
    
    func onColorPressed(color: Color) {
        selectedColor = color
    }
    
    func onContinuePressed(path: Binding<[OnboardingPathOption]>) {
        guard let selectedColor else { return }
        path.wrappedValue.append(.completedView(selectedColor: selectedColor))
    }
}

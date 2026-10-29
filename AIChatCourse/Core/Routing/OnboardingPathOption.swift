//
//  OnboardingPathOption.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI
import Foundation

enum OnboardingPathOption: Hashable {
    case colorView
    case communityView
    case introView
    case completedView(selectedColor: Color)
}

struct NavDestForOnboardingModuleViewModifier: ViewModifier {
    
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[OnboardingPathOption]>
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: OnboardingPathOption.self) { newValue in
                switch newValue {
                case .colorView:
                    OnboardingColorView(viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .communityView:
                    OnboardingCommunityView(viewModel: OnboardingCommunityViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .introView:
                    OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: path)
                case .completedView(selectedColor: let selectedColor):
                    OnboardingCompletedView(viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container)), selectedColor: selectedColor)
                }
            }
    }
}

extension View {
    
    func navigationDestinationForOnboardingModule(path: Binding<[OnboardingPathOption]>) -> some View {
        modifier(NavDestForOnboardingModuleViewModifier(path: path))
    }
}

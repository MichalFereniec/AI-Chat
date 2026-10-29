//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/6/24.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingIntroViewModel
    @Binding var path: [OnboardingPathOption]
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses.")
            }
            .baselineOffset(6)
            .minimumScaleFactor(0.5)
            .frame(maxHeight: .infinity)
            .padding(24)

            Text("Continue")
                .callToActionButton()
                .anyButton(.press) {
                    viewModel.onContinueButtonPressed(path: $path)
                }
                .accessibilityIdentifier("ContinueButton")
        }
        .padding(24)
        .font(.title3)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingIntroView")
    }
}

#Preview("Original") {
    let container = DevPreview.shared.container
    
    return NavigationStack {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
    }
    .previewEnvironment()
}

#Preview("Onb Comm Test") {
    let container = DevPreview.shared.container
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))
    
    return NavigationStack {
        OnboardingIntroView(viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
    }
    .previewEnvironment()
}

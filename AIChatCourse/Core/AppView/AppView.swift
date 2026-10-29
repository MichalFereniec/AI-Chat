//
//  AppView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//
import SwiftUI

struct AppView: View {

    @State var viewModel: AppViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ),
            content: {
                AppViewBuilder(
                    showTabBar: viewModel.showTabBar,
                    tabbarView: {
                        TabBarView()
                    },
                    onboardingView: {
                        WelcomeView(
                            viewModel: WelcomeViewModel(
                                interactor: CoreInteractor(container: container)
                            )
                        )
                    }
                )
                .task {
                    await viewModel.checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await viewModel.showATTPromptIfNeeded()
                }
                .onChange(of: viewModel.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await viewModel.checkUserStatus()
                        }
                    }
                }
            }
        )
    }
}

#Preview("AppView - Tabbar") {
    let container = DevPreview(isSignedIn: true).container

    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container))
    )
    .previewEnvironment(container: container)
}

#Preview("AppView - Onboarding") {
    let container = DevPreview(isSignedIn: false).container

    return AppView(
        viewModel: AppViewModel(interactor: CoreInteractor(container: container))
    )
    .previewEnvironment(container: container)
}

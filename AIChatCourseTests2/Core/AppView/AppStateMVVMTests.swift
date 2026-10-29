import SwiftUI
import Testing
@testable import AIChatCourse

@Suite(.timeLimit(.minutes(1)))
@MainActor
struct AppStateMVVMTests {

    @Test("Reads the original persisted root-screen key", arguments: [false, true])
    func readsPersistedState(showTabBar: Bool) {
        let fixture = Fixture(showTabBar: showTabBar)
        defer { fixture.cleanUp() }

        #expect(fixture.appState.showTabBar == showTabBar)
    }

    @Test("Root-screen updates survive recreation", arguments: [false, true])
    func persistsUpdates(showTabBar: Bool) {
        let fixture = Fixture(showTabBar: !showTabBar)
        defer { fixture.cleanUp() }

        fixture.appState.updateViewState(showTabBarView: showTabBar)

        #expect(fixture.defaults.bool(forKey: "showTabbarView") == showTabBar)
        #expect(AppState(userDefaults: fixture.defaults).showTabBar == showTabBar)
    }

    @Test("An explicit initial state does not overwrite persisted state")
    func initialOverrideDoesNotWriteDefaults() {
        let fixture = Fixture(showTabBar: true)
        defer { fixture.cleanUp() }

        let state = AppState(showTabBar: false, userDefaults: fixture.defaults)

        #expect(state.showTabBar == false)
        #expect(fixture.defaults.bool(forKey: "showTabbarView") == true)
    }

    @Test("The container and separate Interactors share one AppState")
    func sharesStateAcrossViewModels() {
        let fixture = Fixture(showTabBar: false)
        defer { fixture.cleanUp() }
        let dependencies = Dependencies(config: .mock(isSignedIn: true), userDefaults: fixture.defaults)
        let first = CoreInteractor(container: dependencies.container)
        let second = CoreInteractor(container: dependencies.container)
        let firstViewModel = AppViewModel(interactor: first)
        let secondViewModel = AppViewModel(interactor: second)
        let welcome = WelcomeViewModel(interactor: second)

        #expect(dependencies.container.resolve(AppState.self) === dependencies.appState)
        #expect(firstViewModel.showTabBar == false)

        welcome.handleDidSignIn(isNewUser: false)

        #expect(firstViewModel.showTabBar == true)
        #expect(secondViewModel.showTabBar == true)
        #expect(dependencies.appState.showTabBar == true)

        first.updateViewState(showTabBarView: false)

        #expect(firstViewModel.showTabBar == false)
        #expect(secondViewModel.showTabBar == false)
    }

    @Test("Successful existing-user login opens tabs; new users stay in onboarding", arguments: [false, true])
    func routesSuccessfulLogin(isNewUser: Bool) async {
        let fixture = Fixture(showTabBar: false)
        defer { fixture.cleanUp() }
        fixture.interactor.isNewUser = isNewUser
        let welcome = WelcomeViewModel(interactor: fixture.interactor)
        let signIn = CreateAccountViewModel(interactor: fixture.interactor)

        signIn.onSignInApplePressed { isNewUser in
            welcome.handleDidSignIn(isNewUser: isNewUser)
        }
        await fixture.interactor.waitForEvent(WelcomeViewModel.Event.didSignIn(isNewUser: isNewUser).eventName)

        #expect(fixture.appState.showTabBar == !isNewUser)
        #expect(fixture.defaults.bool(forKey: "showTabbarView") == !isNewUser)
    }

    enum LoginFailure: CaseIterable {
        case authentication
        case profileLogin
    }

    @Test("Authentication and profile-login failures never open tabs", arguments: LoginFailure.allCases)
    func failedLoginDoesNotNavigate(failure: LoginFailure) async {
        let fixture = Fixture(showTabBar: false)
        defer { fixture.cleanUp() }
        fixture.interactor.failSignIn = failure == .authentication
        fixture.interactor.failLogin = failure == .profileLogin
        let welcome = WelcomeViewModel(interactor: fixture.interactor)
        let signIn = CreateAccountViewModel(interactor: fixture.interactor)

        signIn.onSignInApplePressed { isNewUser in
            welcome.handleDidSignIn(isNewUser: isNewUser)
        }
        await fixture.interactor.waitForEvent(CreateAccountViewModel.Event.appleAuthFail(error: TestError.expected).eventName)

        #expect(fixture.appState.showTabBar == false)
        #expect(fixture.interactor.actions.contains("root:true") == false)
    }

    @Test("Onboarding opens tabs only after the profile is saved")
    func completesOnboarding() async {
        let fixture = Fixture(showTabBar: false)
        defer { fixture.cleanUp() }
        let viewModel = OnboardingCompletedViewModel(interactor: fixture.interactor)

        viewModel.onFinishButtonPressed(selectedColor: .orange)
        await fixture.interactor.waitForEvent("root:true")

        #expect(fixture.appState.showTabBar == true)
        #expect(viewModel.isCompletingProfileSetup == false)
        #expect(fixture.interactor.savedProfileColor == Color.orange.asHex())
        #expect(fixture.interactor.actions == [
            OnboardingCompletedViewModel.Event.finishStart.eventName,
            "saveProfile",
            OnboardingCompletedViewModel.Event.finishSuccess(hex: "").eventName,
            "root:true"
        ])
    }

    @Test("A failed onboarding save shows an error without changing the root screen")
    func failedOnboardingDoesNotNavigate() async {
        let fixture = Fixture(showTabBar: false)
        defer { fixture.cleanUp() }
        fixture.interactor.failOnboarding = true
        let viewModel = OnboardingCompletedViewModel(interactor: fixture.interactor)

        viewModel.onFinishButtonPressed(selectedColor: .orange)
        await fixture.interactor.waitForEvent(OnboardingCompletedViewModel.Event.finishFail(error: TestError.expected).eventName)

        #expect(fixture.appState.showTabBar == false)
        #expect(viewModel.showAlert != nil)
        #expect(fixture.interactor.actions.contains("root:true") == false)
    }

    enum AccountAction: CaseIterable {
        case signOut
        case deleteAccount
    }

    @Test("Sign-out and deletion await Settings dismissal before changing the root", arguments: AccountAction.allCases)
    func dismissesSettingsBeforeChangingRoot(action: AccountAction) async {
        let fixture = Fixture(showTabBar: true)
        defer { fixture.cleanUp() }
        let viewModel = SettingsViewModel(interactor: fixture.interactor)
        let dismissal = AsyncStream<Void>.makeStream()
        defer { dismissal.continuation.finish() }
        let onDismiss: @MainActor @Sendable () async -> Void = {
            fixture.interactor.record("dismissStarted")
            for await _ in dismissal.stream {
                break
            }
            fixture.interactor.record("dismissFinished")
        }

        switch action {
        case .signOut:
            viewModel.onSignOutPressed(onDismiss: onDismiss)
        case .deleteAccount:
            viewModel.onDeleteAccountPressed(onDismiss: onDismiss)
            #expect(viewModel.showAlert != nil)
            #expect(fixture.interactor.actions.contains("deleteAccount") == false)
            viewModel.onDeleteAccountConfirmed(onDismiss: onDismiss)
        }
        await fixture.interactor.waitForEvent("dismissStarted")

        #expect(fixture.appState.showTabBar == true)
        #expect(fixture.defaults.bool(forKey: "showTabbarView") == true)

        dismissal.continuation.yield(())
        await fixture.interactor.waitForEvent("root:false")

        #expect(fixture.appState.showTabBar == false)
        #expect(fixture.defaults.bool(forKey: "showTabbarView") == false)
        #expect(Array(fixture.interactor.actions.suffix(3)) == ["dismissStarted", "dismissFinished", "root:false"])
    }

    @Test("Failed sign-out and deletion do not dismiss Settings or change the root", arguments: AccountAction.allCases)
    func failedAccountActionDoesNotNavigate(action: AccountAction) async {
        let fixture = Fixture(showTabBar: true)
        defer { fixture.cleanUp() }
        let viewModel = SettingsViewModel(interactor: fixture.interactor)
        let onDismiss: @MainActor @Sendable () async -> Void = {
            fixture.interactor.record("dismiss")
        }
        let failureEvent: String

        switch action {
        case .signOut:
            fixture.interactor.failSignOut = true
            viewModel.onSignOutPressed(onDismiss: onDismiss)
            failureEvent = SettingsViewModel.Event.signOutFail(error: TestError.expected).eventName
        case .deleteAccount:
            fixture.interactor.failDeletion = true
            viewModel.onDeleteAccountConfirmed(onDismiss: onDismiss)
            failureEvent = SettingsViewModel.Event.deleteAccountFail(error: TestError.expected).eventName
        }
        await fixture.interactor.waitForEvent(failureEvent)

        #expect(fixture.appState.showTabBar == true)
        #expect(viewModel.showAlert != nil)
        #expect(fixture.interactor.actions.contains("dismiss") == false)
        #expect(fixture.interactor.actions.contains("root:false") == false)
    }

    private enum TestError: Error {
        case expected
    }

    @MainActor
    private struct Fixture {
        let suiteName = "AIChatCourseTests.AppState.\(UUID().uuidString)"
        let defaults: UserDefaults
        let appState: AppState
        let interactor: NavigationInteractor

        init(showTabBar: Bool) {
            defaults = UserDefaults(suiteName: suiteName)!
            defaults.set(showTabBar, forKey: "showTabbarView")
            appState = AppState(userDefaults: defaults)
            interactor = NavigationInteractor(appState: appState)
        }

        func cleanUp() {
            defaults.removePersistentDomain(forName: suiteName)
        }
    }

    @MainActor
    private final class NavigationInteractor: WelcomeInteractor, CreateAccountInteractor, OnboardingCompletedInteractor, SettingsInteractor {
        let appState: AppState
        var auth: UserAuthInfo? = .mock()
        var isNewUser = false
        var failSignIn = false
        var failLogin = false
        var failOnboarding = false
        var failSignOut = false
        var failDeletion = false
        var savedProfileColor: String?
        private(set) var actions: [String] = []
        private let events: AsyncStream<String>
        private let continuation: AsyncStream<String>.Continuation

        init(appState: AppState) {
            self.appState = appState
            let stream = AsyncStream<String>.makeStream()
            events = stream.stream
            continuation = stream.continuation
        }

        func record(_ event: String) {
            actions.append(event)
            continuation.yield(event)
        }

        func waitForEvent(_ name: String) async {
            let event = await events.first { $0 == name }
            #expect(event == name)
        }

        func trackEvent(event: LoggableEvent) {
            record(event.eventName)
        }

        func updateViewState(showTabBarView: Bool) {
            appState.updateViewState(showTabBarView: showTabBarView)
            record("root:\(showTabBarView)")
        }

        func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
            if failSignIn { throw TestError.expected }
            return (.mock(), isNewUser)
        }

        func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
            if failLogin { throw TestError.expected }
        }

        func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
            record("saveProfile")
            if failOnboarding { throw TestError.expected }
            savedProfileColor = profileColorHex
        }

        func signOut() async throws {
            record("signOut")
            if failSignOut { throw TestError.expected }
        }

        func deleteAccount() async throws {
            record("deleteAccount")
            if failDeletion { throw TestError.expected }
        }
    }
}

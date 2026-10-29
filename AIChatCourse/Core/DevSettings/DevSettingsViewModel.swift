//
//  DevSettingsViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI
import SwiftfulUtilities

@MainActor
protocol DevSettingsInteractor {
    var activeTests: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    
    func trackEvent(event: LoggableEvent)
    func override(updateTests: ActiveABTests) throws
}

extension CoreInteractor: DevSettingsInteractor { }

@Observable
@MainActor
class DevSettingsViewModel {
    
    private let interactor: DevSettingsInteractor
    
    var createAccountTest: Bool = false
    var onboardingCommunityTest: Bool = false
    var categoryRowTest: CategoryRowTestOption = .default
    var paywallTest: PaywallTestOption = .default
    
    var authData: [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var userData: [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    var utilitiesData: [(key: String, value: Any)] {
        Utilities.eventParameters.asAlphabeticalArray
    }

    init(interactor: DevSettingsInteractor) {
        self.interactor = interactor
    }
    
    func loadABTests() {
        createAccountTest = interactor.activeTests.createAccountTest
        onboardingCommunityTest = interactor.activeTests.onboardingCommunityTest
        categoryRowTest = interactor.activeTests.categoryRowTest
        paywallTest = interactor.activeTests.paywallTest
    }

    func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: interactor.activeTests.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    
    func handleOnbCommunityChange(oldValue: Bool, newValue: Bool) {
        updateTest(
            property: &onboardingCommunityTest,
            newValue: newValue,
            savedValue: interactor.activeTests.onboardingCommunityTest,
            updateAction: { tests in
                tests.update(onboardingCommunityTest: newValue)
            }
        )
    }
    
    func handleCategoryRowOptionChange(oldValue: CategoryRowTestOption, newValue: CategoryRowTestOption) {
        updateTest(
            property: &categoryRowTest,
            newValue: newValue,
            savedValue: interactor.activeTests.categoryRowTest,
            updateAction: { tests in
                tests.update(categoryRowTest: newValue)
            }
        )
    }
    
    func handlePaywallOptionChange(oldValue: PaywallTestOption, newValue: PaywallTestOption) {
        updateTest(
            property: &paywallTest,
            newValue: newValue,
            savedValue: interactor.activeTests.paywallTest,
            updateAction: { tests in
                tests.update(paywallTest: newValue)
            }
        )
    }
    
    private func updateTest<Value: Equatable>(
        property: inout Value,
        newValue: Value,
        savedValue: Value,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = interactor.activeTests
                updateAction(&tests)
                try interactor.override(updateTests: tests)
            } catch {
                property = savedValue
            }
        }
    }

    func onBackButtonPressed(onDismiss: () -> Void) {
        onDismiss()
    }

}

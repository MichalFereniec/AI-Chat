//
//  WelcomeViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: LoggableEvent)
    func updateViewState(showTabBarView: Bool)
}

extension CoreInteractor: WelcomeInteractor { }

@Observable
@MainActor
class WelcomeViewModel {
    
    private let interactor: WelcomeInteractor
    
    private(set) var imageName: String = Constants.randomImage
    
    var showSignInView: Bool = false
    var path: [OnboardingPathOption] = []

    init(interactor: WelcomeInteractor) {
        self.interactor = interactor
    }
    
    func onGetStartedPressed() {
        path.append(.introView)
    }
        
    func handleDidSignIn(isNewUser: Bool) {
        interactor.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        
        if isNewUser {
            // Do nothing, user goes through onboarding
        } else {
            // Push into tabbar view
            interactor.updateViewState(showTabBarView: true)
        }
    }
    
    func onSignInPresssed() {
        showSignInView = true
        interactor.trackEvent(event: Event.signInPressed)
    }

    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn:          return "WelcomeView_DidSignIn"
            case .signInPressed:      return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser):
                return [
                    "is_new_user": isNewUser
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }

}

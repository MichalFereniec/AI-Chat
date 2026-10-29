//
//  OnboardingCompletedViewModel.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/9/24.
//
import SwiftUI

@MainActor
protocol OnboardingCompletedInteractor {
    func trackEvent(event: LoggableEvent)
    func updateViewState(showTabBarView: Bool)
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
}

extension CoreInteractor: OnboardingCompletedInteractor { }

@Observable
@MainActor
class OnboardingCompletedViewModel {
    
    private let interactor: OnboardingCompletedInteractor
    
    private(set) var isCompletingProfileSetup: Bool = false
    
    var showAlert: AnyAppAlert?

    init(interactor: OnboardingCompletedInteractor) {
        self.interactor = interactor
    }
        
    func onFinishButtonPressed(selectedColor: Color) {
        isCompletingProfileSetup = true
        interactor.trackEvent(event: Event.finishStart)
        
        Task {
            do {
                let hex = selectedColor.asHex()
                try await interactor.markOnboardingCompleteForCurrentUser(profileColorHex: hex)
                interactor.trackEvent(event: Event.finishSuccess(hex: hex))

                // dismiss screen
                isCompletingProfileSetup = false
                interactor.updateViewState(showTabBarView: true)
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.finishFail(error: error))
            }
        }
    }

    enum Event: LoggableEvent {
        case finishStart
        case finishSuccess(hex: String)
        case finishFail(error: Error)

        var eventName: String {
            switch self {
            case .finishStart:         return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:       return "OnboardingCompletedView_Finish_Success"
            case .finishFail:          return "OnboardingCompletedView_Finish_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishSuccess(hex: let hex):
                return [
                    "profile_color_hex": hex
                ]
            case .finishFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

}

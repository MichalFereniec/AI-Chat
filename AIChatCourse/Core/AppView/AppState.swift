//
//  AppState.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/6/24.
//
import SwiftUI

@Observable
@MainActor
class AppState {

    private let userDefaults: UserDefaults

    private(set) var showTabBar: Bool {
        didSet {
            userDefaults.set(showTabBar, forKey: UserDefaults.showTabbarViewKey)
        }
    }

    init(showTabBar: Bool? = nil, userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.showTabBar = showTabBar ?? userDefaults.bool(forKey: UserDefaults.showTabbarViewKey)
    }

    func updateViewState(showTabBarView: Bool) {
        showTabBar = showTabBarView
    }
}

extension UserDefaults {

    fileprivate static let showTabbarViewKey = "showTabbarView"

    static var showTabbarView: Bool {
        get {
            standard.bool(forKey: showTabbarViewKey)
        }
        set {
            standard.set(newValue, forKey: showTabbarViewKey)
        }
    }
}

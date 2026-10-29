//
//  ActiveABTests.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/31/24.
//
import SwiftUI

struct ActiveABTests: Codable {
    
    private(set) var createAccountTest: Bool
    private(set) var onboardingCommunityTest: Bool
    private(set) var categoryRowTest: CategoryRowTestOption
    private(set) var paywallTest: PaywallTestOption

    init(
        createAccountTest: Bool,
        onboardingCommunityTest: Bool,
        categoryRowTest: CategoryRowTestOption,
        paywallTest: PaywallTestOption
    ) {
        self.createAccountTest = createAccountTest
        self.onboardingCommunityTest = onboardingCommunityTest
        self.categoryRowTest = categoryRowTest
        self.paywallTest = paywallTest
    }
    
    enum CodingKeys: String, CodingKey {
        case createAccountTest = "_202411_CreateAccTest"
        case onboardingCommunityTest = "_202411_OnbCommunityTest"
        case categoryRowTest = "_202411_CategoryRowTest"
        case paywallTest = "_202411_PaywallTest"
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "test\(CodingKeys.createAccountTest.rawValue)": createAccountTest,
            "test\(CodingKeys.onboardingCommunityTest.rawValue)": onboardingCommunityTest,
            "test\(CodingKeys.categoryRowTest.rawValue)": categoryRowTest.rawValue,
            "test\(CodingKeys.paywallTest.rawValue)": paywallTest.rawValue
        ]
        return dict.compactMapValues({ $0 })
    }
    
    mutating func update(createAccountTest newValue: Bool) {
        createAccountTest = newValue
    }
    
    mutating func update(onboardingCommunityTest newValue: Bool) {
        onboardingCommunityTest = newValue
    }
    
    mutating func update(categoryRowTest newValue: CategoryRowTestOption) {
        categoryRowTest = newValue
    }
    
    mutating func update(paywallTest newValue: PaywallTestOption) {
        paywallTest = newValue
    }
}

// MARK: REMOTE CONFIG

import FirebaseRemoteConfig

extension ActiveABTests {
    
    init(config: RemoteConfig) {
        let createAccountTest = config.configValue(forKey: ActiveABTests.CodingKeys.createAccountTest.rawValue).boolValue
        self.createAccountTest = createAccountTest
        
        let onboardingCommunityTest = config.configValue(forKey: ActiveABTests.CodingKeys.onboardingCommunityTest.rawValue).boolValue
        self.onboardingCommunityTest = onboardingCommunityTest

        let categoryRowTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.categoryRowTest.rawValue).stringValue
        if let option = CategoryRowTestOption(rawValue: categoryRowTestStringValue) {
            self.categoryRowTest = option
        } else {
            self.categoryRowTest = .default
        }
        
        let paywallTestStringValue = config.configValue(forKey: ActiveABTests.CodingKeys.paywallTest.rawValue).stringValue
        if let option = PaywallTestOption(rawValue: paywallTestStringValue) {
            self.paywallTest = option
        } else {
            self.paywallTest = .default
        }
    }
    
    // Converted to a NSObject dictionary to setDefaults within FirebaseABTestService
    var asNSObjectDictionary: [String: NSObject]? {
        [
            CodingKeys.createAccountTest.rawValue: createAccountTest as NSObject,
            CodingKeys.onboardingCommunityTest.rawValue: onboardingCommunityTest as NSObject,
            CodingKeys.categoryRowTest.rawValue: categoryRowTest.rawValue as NSObject,
            CodingKeys.paywallTest.rawValue: paywallTest.rawValue as NSObject
        ]
    }
}

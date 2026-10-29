//
//  EntitlementOwnershipOption.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/1/24.
//
import SwiftUI

public enum EntitlementOwnershipOption: Codable, Sendable {
    case purchased, familyShared, unknown
}

import StoreKit

extension EntitlementOwnershipOption {

    init(type: StoreKit.Transaction.OwnershipType) {
        switch type {
        case .purchased:
            self = .purchased
        case .familyShared:
            self = .familyShared
        default:
            self = .unknown
        }
    }
}

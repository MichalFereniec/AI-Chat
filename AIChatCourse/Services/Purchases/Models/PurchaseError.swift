//
//  PurchaseError.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/2/24.
//
import SwiftUI

enum PurchaseError: LocalizedError {
    case productNotFound, userCancelledPurchase, failedToPurchase
}

//
//  PurchaseProfileAttributes.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/2/24.
//

struct PurchaseProfileAttributes {
    let email: String?
    let firebaseAppInstanceId: String?
    let mixpanelDistinctId: String?
    
    init(
        email: String? = nil,
        firebaseAppInstanceId: String? = nil,
        mixpanelDistinctId: String? = nil
    ) {
        self.email = email
        self.firebaseAppInstanceId = firebaseAppInstanceId
        self.mixpanelDistinctId = mixpanelDistinctId
    }
}

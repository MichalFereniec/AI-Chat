//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/12/24.
//
import Foundation

@MainActor
class MockAuthService: AuthService {
    
    @Published var currentUser: UserAuthInfo?
    
    init(user: UserAuthInfo? = nil) {
        self.currentUser = user
    }
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
            
            Task {
                for await value in $currentUser.values {
                    continuation.yield(value)
                }
            }
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: true)
        currentUser = user
        return (user, true)
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        
    }
    
    func deleteAccount() async throws {
        
    }
    
}

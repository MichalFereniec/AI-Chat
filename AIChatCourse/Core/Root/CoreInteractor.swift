//
//  CoreInteractor.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/8/24.
//
import SwiftUI

@MainActor
struct CoreInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
    }

    // MARK: AuthManager
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }
    
    // MARK: UserManager
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws {
        try await userManager.markOnboardingCompleteForCurrentUser(profileColorHex: profileColorHex)
    }
    
    // MARK: AIManager
    
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    // MARK: AvatarManager
    
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await avatarManager.getAvatar(id: id)
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuthor(userId: userId)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAvatar(avatarId: avatarId)
    }
    
    // MARK: ChatManager
    
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func getAllChats(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChats(userId: userId)
    }

    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(chatId: chatId, message: message)
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func streamChatMessages(chatId: String, onListenerConfigured: @escaping (AnyListener) -> Void) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        chatManager.streamChatMessages(chatId: chatId, onListenerConfigured: onListenerConfigured)
    }
    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
        
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
    
    // MARK: LogManager
    
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreenEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    // MARK: PushManager
    
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotificationsForTheNextWeek() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    // MARK: ABTestManager
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    var categoryRowTest: CategoryRowTestOption {
        activeTests.categoryRowTest
    }
    
    var createAccountTest: Bool {
        activeTests.createAccountTest
    }
    
    var paywallTest: PaywallTestOption {
        activeTests.paywallTest
    }
    
    var onboardingCommunityTest: Bool {
        activeTests.onboardingCommunityTest
    }
    
    func override(updateTests: ActiveABTests) throws {
        try abTestManager.override(updateTests: updateTests)
    }
    
    // MARK: PurchaseManager
    
    var entitlements: [PurchasedEntitlement] {
        purchaseManager.entitlements
    }
    
    var isPremium: Bool {
        entitlements.hasActiveEntitlement
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        try await purchaseManager.getProducts(productIds: productIds)
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        try await purchaseManager.restorePurchase()
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        try await purchaseManager.purchaseProduct(productId: productId)
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        try await purchaseManager.updateProfileAttributes(attributes: attributes)
    }
        
    // MARK: SHARED
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            attributes: PurchaseProfileAttributes(
                email: user.email,
                firebaseAppInstanceId: FirebaseAnalyticsService.appInstanceID,
                mixpanelDistinctId: MixpanelService.distinctId
            )
        )
    }
    
    func signOut() async throws {
        try authManager.signOut()
        try await purchaseManager.logOut()
        userManager.signOut()
    }
    
    func deleteAccount() async throws {
        let uid = try authManager.getAuthId()
        try await chatManager.deleteAllChatsForUser(userId: uid)
        try await avatarManager.removeAuthorIdFromAllUserAvatars(userId: uid)
        try await userManager.deleteCurrentUser()
        try await authManager.deleteAccount()
        try await purchaseManager.logOut()
        logManager.deleteUserProfile()
    }

}

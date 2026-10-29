//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//

import SwiftUI
import Firebase
import SwiftfulUtilities

@main
struct AppEntryPoint {
    
    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing!")
        }
    }
}

struct AIChatCourseApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting()
                } else {
                    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: delegate.dependencies.container)))
                }
            }
            .environment(delegate.dependencies.container)
            .environment(delegate.dependencies.purchaseManager)
            .environment(delegate.dependencies.abTestManager)
            .environment(delegate.dependencies.pushManager)
            .environment(delegate.dependencies.chatManager)
            .environment(delegate.dependencies.aiManager)
            .environment(delegate.dependencies.avatarManager)
            .environment(delegate.dependencies.userManager)
            .environment(delegate.dependencies.authManager)
            .environment(delegate.dependencies.logManager)
        }
    }
}

struct AppViewForUITesting: View {
    
    @Environment(DependencyContainer.self) private var container
    
    private var startOnAvatarScreen: Bool {
        ProcessInfo.processInfo.arguments.contains("STARTSCREEN_CREATEAVATAR")
    }

    var body: some View {
        if startOnAvatarScreen {
            CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: container)))
        } else {
            AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: container)))
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        if Utilities.isUITesting {
            let isSignedIn = ProcessInfo.processInfo.arguments.contains("SIGNED_IN")
            UserDefaults.showTabbarView = isSignedIn
            config = .mock(isSignedIn: isSignedIn)
        }
        
        config.configure()
        dependencies = Dependencies(config: config)
        return true
    }    
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does NOT run Firebase
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@Observable
@MainActor
class DependencyContainer {
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }
    
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration, userDefaults: UserDefaults = .standard) {
        appState = AppState(userDefaults: userDefaults)

        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            
            let isInOnboaringCommunityTest = ProcessInfo.processInfo.arguments.contains("ONBCOMMTEST")
            let abTestService = MockABTestService(
                onboardingCommunityTest: isInOnboaringCommunityTest,
                paywallTest: .custom
            )
            abTestManager = ABTestManager(service: abTestService, logManager: logManager)
            purchaseManager = PurchaseManager(service: MockPurchaseService(), logManager: logManager)
        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(
                service: RevenueCatPurchaseService(apiKey: Keys.revenueCatAPIKey), // StoreKitPurchaseService(),
                logManager: logManager
            )
        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Keys.mixpanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: FirebaseABTestService(), logManager: logManager)
            purchaseManager = PurchaseManager(service: StoreKitPurchaseService(), logManager: logManager)
        }
        
        pushManager = PushManager(logManager: logManager)
        
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        self.container = container
    }
}

extension View {
    func previewEnvironment(container: DependencyContainer = DevPreview.shared.container) -> some View {
        self
            .environment(container)
            .environment(container.resolve(PurchaseManager.self)!)
            .environment(container.resolve(ABTestManager.self)!)
            .environment(container.resolve(PushManager.self)!)
            .environment(container.resolve(ChatManager.self)!)
            .environment(container.resolve(AIManager.self)!)
            .environment(container.resolve(AvatarManager.self)!)
            .environment(container.resolve(UserManager.self)!)
            .environment(container.resolve(AuthManager.self)!)
            .environment(container.resolve(LogManager.self)!)
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        container.register(PurchaseManager.self, service: purchaseManager)
        container.register(AppState.self, service: appState)
        return container
    }
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    let purchaseManager: PurchaseManager
    let appState: AppState
    
    init(isSignedIn: Bool = true) {
        self.appState = AppState(
            showTabBar: isSignedIn,
            userDefaults: UserDefaults(suiteName: "AIChatCourse.Previews")!
        )
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.aiManager = AIManager(service: MockAIService())
        self.avatarManager = AvatarManager(service: MockAvatarService())
        self.chatManager = ChatManager(service: MockChatService())
        self.logManager = LogManager(services: [])
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestService())
        self.purchaseManager = PurchaseManager(service: MockPurchaseService())
    }

}

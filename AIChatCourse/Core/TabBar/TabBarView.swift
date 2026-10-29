//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        TabView {
            ExploreView(
                viewModel: ExploreViewModel(
                    interactor: CoreInteractor(container: container)
                )
            )
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            
            ChatsView(
                viewModel: ChatsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }
            
            ProfileView(
                viewModel: ProfileViewModel(
                    interactor: CoreInteractor(container: container)
                )
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvironment()
}

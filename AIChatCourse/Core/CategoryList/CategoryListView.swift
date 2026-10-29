//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/11/24.
//

import SwiftUI

struct CategoryListView: View {

    @State var viewModel: CategoryListViewModel

    @Binding var path: [TabbarPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found 😭")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterDescription
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onAvatarPressed(avatar: avatar, path: $path)
                    })
                    .removeListRowFormatting()
                }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .screenAppearAnalytics(name: "CategoryList")
        .ignoresSafeArea()
        .listStyle(PlainListStyle())
        .task {
            await viewModel.loadAvatars(category: category)
        }
    }
        
}

#Preview("Has data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    
    return CategoryListView(
        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
        path: .constant([])
    )
    .previewEnvironment()
}
#Preview("No data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [])))
    
    return CategoryListView(
        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
        path: .constant([])
    )
    .previewEnvironment()
}
#Preview("Slow loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 10)))
    
    return CategoryListView(
        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
        path: .constant([])
    )
    .previewEnvironment()
}
#Preview("Error loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 5, showError: true)))
    
    return CategoryListView(
        viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)),
        path: .constant([])
    )
    .previewEnvironment()
}

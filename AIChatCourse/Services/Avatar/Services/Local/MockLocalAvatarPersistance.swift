//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/17/24.
//

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    
    let avatars: [AvatarModel]
    
    init(avatars: [AvatarModel] = AvatarModel.mocks) {
        self.avatars = avatars
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        avatars
    }
}

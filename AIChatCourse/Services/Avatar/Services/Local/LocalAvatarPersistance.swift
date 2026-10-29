//
//  LocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/17/24.
//

@MainActor
protocol LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}

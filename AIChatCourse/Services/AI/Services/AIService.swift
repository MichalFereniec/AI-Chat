//
//  AIService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/15/24.
//
import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}

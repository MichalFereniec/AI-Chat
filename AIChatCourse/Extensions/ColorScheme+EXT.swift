//
//  ColorScheme+EXT.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/28/24.
//
import SwiftUI

extension ColorScheme {
    
    var backgroundPrimary: Color {
        self == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground)
    }
    
    var backgroundSecondary: Color {
        self == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemBackground)
    }
    
}

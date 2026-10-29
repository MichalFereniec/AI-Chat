//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/6/24.
//

import SwiftUI

struct OnboardingColorView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingColorViewModel
    @Binding var path: [OnboardingPathOption]

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if let selectedColor = viewModel.selectedColor {
                    ctaButton(selectedColor: selectedColor)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        })
        .animation(.bouncy, value: viewModel.selectedColor)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingColorView")
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(viewModel.profileColors, id: \.self) { color in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                color
                                    .clipShape(Circle())
                                    .padding(viewModel.selectedColor == color ? 10 : 0)
                            )
                            .onTapGesture {
                                viewModel.onColorPressed(color: color)
                            }
                            .accessibilityIdentifier("ColorCircle")
                    }
                }, header: {
                    Text("Select a profile color")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                })
            }
        )
    }
    
    private func ctaButton(selectedColor: Color) -> some View {
        Text("Continue")
            .callToActionButton()
            .anyButton(.press, action: {
                viewModel.onContinuePressed(path: $path)
            })
            .accessibilityIdentifier("ContinueButton")
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView(viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), path: .constant([]))
    }
    .previewEnvironment()
}

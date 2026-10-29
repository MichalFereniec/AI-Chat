# AI Chat

AIChat app by Swiftful Thinking in MVVM

A personal learning and reference project based on the Swiftful Thinking AI Chat
course starter, supplied as `lesson_119_starter_project.zip`.

## Attribution and provenance

The original course code is by **Swiftful Thinking / Nick Sarno**. Its source-file
attribution headers are preserved. This repository is a personal course exercise,
not an official Swiftful Thinking release.

The initial import preserves the starter sources unchanged. Subsequent commits
separate technical repairs from the AppState MVVM completion. That completion is
our reconstruction following the starter's patterns, **not the exact source of
the course's final lesson**.

The supplied archive did not include a license. No new license is assigned to the
course code; its original authors retain their rights.

Starter archive SHA-256:
`fcfd7911bed2d1ff852fdaaa0e33be7ab3df84d199584cb58c6cc5b5bf02753a`

## Running locally

Open `AIChatCourse.xcodeproj` and select **AIChatCourse - Mock**. The starter targets
iOS 17 or later and uses Swift Package Manager. Mock mode uses local mock services
and does not configure Firebase; no real service credentials are included.

Development and Production configurations require your own service setup and
credentials. Do not commit real keys or replace the checked-in placeholder
Firebase configuration with a real project's configuration.

## MVVM completion

The AppState completion keeps one shared, main-actor-isolated state in the existing
container. Root-screen reads and navigation go through screen ViewModels and
Interactor protocols, without a second writable state copy in the ViewModel.

See [AppState MVVM notes](docs/AppState-MVVM.md) for the data flow, preserved
behaviors, and test coverage.

## Tests

Run the unit tests with an installed iOS Simulator destination:

```sh
xcodebuild test -project AIChatCourse.xcodeproj \
  -scheme 'AIChatCourse - Mock' \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:AIChatCourseTests2
```

The shared schemes reference the real `AIChatCourseTests2` and
`AIChatCourseUITests2` targets. Build products use Xcode's default system
DerivedData location.

To run the full scheme, omit `-only-testing:AIChatCourseTests2`.

### Validation

The full Mock scheme passed on **October 29, 2026**, with **Xcode 26.4.1** and an
**iPhone 17 Pro / iOS 26.5 Simulator**: 44 test definitions, 53 executions including
parameterized tests and launch configurations, **zero failures**.

The optional SwiftLint executable was not installed locally. Development and
Production integrations were not exercised; they require your own credentials.

Reference tags: `lesson-119-starter` preserves the unchanged starter sources;
`appstate-mvvm` marks the tested AppState completion.

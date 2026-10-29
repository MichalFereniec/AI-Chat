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

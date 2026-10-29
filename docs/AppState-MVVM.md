# AppState MVVM completion

This is a reconstruction of the missing AppState refactor, following the supplied
lesson 119 starter. It is not presented as the instructor's exact final lesson.
Original source headers and the starter's remaining architecture are preserved.

## Data flow

```text
AppView -> AppViewModel -> AppViewInteractor
                                    |
                             CoreInteractor -> shared AppState -> UserDefaults
                                    ^
Welcome / Onboarding / Settings ViewModels
    -> their screen-specific Interactor protocols
```

- `Dependencies` creates one `AppState` and registers that instance in the existing
  container. Separate `CoreInteractor` values resolve the same state.
- `AppViewModel.showTabBar` is a read-only projection through `AppViewInteractor`.
  There is no second writable copy of the root-screen flag in the ViewModel.
  SwiftUI observes the underlying `@Observable` state through that getter.
- Views no longer create, read, inject, or mutate `AppState` directly.
- Successful existing-user sign-in opens the tabs. New users remain in onboarding.
  Finishing onboarding opens tabs only after saving the profile succeeds.
- Successful sign-out and account deletion await the Settings dismissal callback
  before changing the root screen. The view keeps responsibility for dismissal and
  its original one-second animation delay. Failures do not trigger navigation.
- Account deletion still requires confirmation in the UI. The confirmation handler
  is internal so its success and failure paths can be exercised directly in tests.

## Persistence, isolation, and previews

`AppState` is main-actor isolated and accepts `UserDefaults` for test isolation.
The persistence key remains **`showTabbarView`**. Its explicit initial-state
override keeps the starter's behavior: initialization alone does not persist it.

The `UI_TESTING`, `SIGNED_IN`, `STARTSCREEN_CREATEAVATAR`, and `ONBCOMMTEST` arguments
are retained. The UI-test bootstrap sets the persisted flag before the dependency
graph is created.

Preview environments resolve managers from their container rather than constructing
a second graph. AppView previews pass that same container to both their ViewModel
and environment; preview AppState persistence uses a separate defaults suite.

## Tests

`AppStateMVVMTests` uses Swift Testing and isolated defaults suites. It exercises:

- the existing persistence key, explicit overrides, updates, and recreation;
- shared state across the container, Interactors, and multiple root ViewModels;
- existing/new-user sign-in and authentication/profile-login failures;
- onboarding save success/failure;
- sign-out/deletion success/failure and waiting for Settings dismissal to finish.

Asynchronous tests wait for recorded events, not arbitrary sleeps. The original
XCTest UI tests cover the onboarding and sign-out flows; an added UI test
also verifies account-deletion confirmation and the return to Welcome.

This change does not rewrite the course's chat orchestration, replace its DI
container, upgrade dependencies, or introduce another app-wide Interactor.

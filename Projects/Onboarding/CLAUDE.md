# Onboarding

Post-login onboarding flow: a one-time, full-screen series of steps (welcome, analytics consent, phone number,
missing co-insured / co-owners / pet chip ids, invite a friend, theme, connect payment, cross-sell).

## Architecture
- `OnboardingStep` is both the route type and the step model; associated values carry each screen's data.
  `OnboardingStepList.compute(...)` decides which steps to show (e.g. missing-info steps only for contracts that
  need them, connect payment only if no payment method is connected, analytics consent behind a feature flag).
- `OnboardingClientOctopus` (App) fetches contracts, payment status, cross-sells and Forever data, then calls
  `OnboardingStepList.compute`. Put step-selection logic in `compute`, not in the client, so it stays testable.
- `OnboardingNavigationViewModel` owns the router and the `steps` array. Screens read it from the environment and
  call `advance(after:)`; the last step dismisses the flow. Progress is derived from `router.routeTypes`.
- Reuses the EditStakeholdersUI and ContractsUI (pet chip id) flows for the missing-info steps.

## Entry points
- `.handleOnboarding()` (applied in App's `LoggedInNavigation+Presentations`) presents the flow modally once
  feature flags have loaded, if `isOnboardingEnabled` is on and `OnboardingPresentationState.hasSeenOnboarding`
  (hCore, UserDefaults) is false. Dev Settings in Profile can reset that flag.

## Dependencies
- hCore, hCoreUI, ContractsCore/UI, EditStakeholdersCore/UI, CrossSellCore/UI, Payment, Forever, Profile

## Gotchas
- When a member adds missing info, the matching step is rebuilt with `missingData = false` (`markStakeholderAdded`,
  `markPetChipIdAdded`, `markPaymentConnected`). Screens read their contracts from `steps`, not from their initial
  route payload, so update `steps` instead of local screen state.
- `OnboardingStep.matches(_:)` compares cases and ignores associated values. Each case appears at most once per flow.
- `OnboardingStep` has a hand-written `maskedDescription` because `@Masked` can't be used on associated values.
  Keep the phone number and referral code masked when you add cases.
- Closing the flow with the dismiss button also sets `hasSeenOnboarding`, so it won't be shown again.
- `OnboardingNavigationRetainTests` guards against the route-count subscription retaining the ViewModel. Keep
  `[weak self]` in that sink.

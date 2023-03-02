# State

State is managed through a Event Sourcing model, the tools and framework for doing this is built in-house and is located at: `https://github.com/HedvigInsurance/presentation`

State management in Ugglan is essentially the same model as Redux.

## Store

A store is a class which inherits from the `StateStore<State, Action>` class, a class that inherits from this class should override two functions:

### Effects

Effects run side-effects that on completion updates the state by dispatching actions, use an effect to for example perform network calls. A effect is performed by returning a FiniteSignal of the action type, when you are done with the effect you should emit .end on the signal.

#### Example

```
public override func effects(
    _ getState: @escaping () -> State,
    _ action: Action
) -> FiniteSignal<Action>? {
    return nil
}
```

### Reducer

A reducer takes a State and an Action and produces a new updated State.

#### Example

```
public override func reduce(_ state: State, _ action: Action) -> State {
    return state
}
```

## Action

Should be an enum that implements the ActionProtocol, like this:

```
enum Action: ActionProtocol {
    case helloWorld(property: String)
}
```

Note that all associated values inside of the enum needs to be Codable.

## State

Should be a struct that implements the StateProtocol, like this:

```
struct State: StateProtocol {
    var hello: String
}
```

Note that all properties in this struct needs to implement Codable.

## Persistence

All state is persisted to disk after its been reduced, keep this in mind, that you might need to reset state when entering a new View if that is a desired behaviour.




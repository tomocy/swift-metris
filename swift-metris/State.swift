// tomocy

func mapState<State>(_ state: State, _ map: (inout State) -> Void) -> State {
    var next = state
    map(&next)
    return next
}

// tomocy

func align(_ n: Int, up alignment: Int) -> Int {
    return (n + alignment - 1) / alignment * alignment
}

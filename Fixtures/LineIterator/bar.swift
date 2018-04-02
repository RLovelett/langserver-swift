struct Bar {
    let x: Int
    let y: String
}

extension Bar {
    func foo() -> Int {
        return 1
    }
}

private struct Blah {
    let x: Bar
}

import Testing
@testable import QueensPuzzle

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {

    @Test("onAppear does not crash")
    func onAppearDoesNotCrash() {
        let sut = SettingsViewModel()
        sut.onAppear()
    }
}

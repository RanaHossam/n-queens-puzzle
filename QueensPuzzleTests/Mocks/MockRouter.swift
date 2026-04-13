import Foundation
@testable import QueensPuzzle
import QueensDomain

@MainActor
final class MockRouter: Router {
    private(set) var pushedRoutes: [NavigationRoute] = []

    override func push(route: NavigationRoute) {
        pushedRoutes.append(route)
    }
}

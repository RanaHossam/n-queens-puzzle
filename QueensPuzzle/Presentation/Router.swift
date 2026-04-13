//
//  Router.swift
//  QueensPuzzle
//
//  Created by Rana Hossam on 11/04/2026.
//

import Combine

class Router: ObservableObject {
    @Published var path: [NavigationRoute] = []
    @Published var sheetRoute: SheetRoute?
    
    func push(route: NavigationRoute) {
        path.append(route)
    }
    
    func pop() {
        _ = path.removeLast()
    }
    
}

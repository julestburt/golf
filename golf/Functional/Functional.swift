//
//  Functional.swift
//  golf
//
//  Created by Jules Burt on 2019-08-12.
//  Copyright © 2019 bethegame Inc. All rights reserved.
//

import Foundation

//----------------------------------------------------------
// MARK: Functional Swift
//----------------------------------------------------------
precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator |> : ForwardApplication

func |> <A,B>(x:A, f:(A)->B) -> B {
    return f(x)
}

precedencegroup CompositionOrder {
    associativity: left
    higherThan: ForwardApplication
    lowerThan: FunctionArrowPrecedence
}

infix operator >>> : CompositionOrder

func >>> <A,B,C>(f:@escaping (A)->B, g:@escaping (B)->C) -> ((A)->C) {
    return { value in
        return g(f(value))
    }
}

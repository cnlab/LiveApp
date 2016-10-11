//
//  Observable.swift
//  Live
//
//  Created by Denis Bohm on 10/10/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class Observable<T> {

    typealias ObserverType = () -> ()
    typealias HandlerType = (owner: AnyObject, observer: ObserverType)

    var value: T {

        didSet {
            handlers.forEach { (handler: HandlerType) in
                let (_, observer) = handler
                observer()
            }
        }

    }

    var handlers = [HandlerType]()

    init(value: T) {
        self.value = value
    }

    func subscribe(owner: AnyObject, observer: @escaping ObserverType) {
        let handler: HandlerType = (owner: owner, observer: observer)
        handlers.append(handler)
    }

    func unsubscribe(owner: AnyObject) {
        handlers = handlers.filter { handler in
            let (handlerOwner, _) = handler
            return handlerOwner !== owner
        }
    }

}

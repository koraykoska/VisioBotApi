//
//  BaseCallbackQuery.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

protocol BaseCallbackQuery {

    static var callbackData: String? { get }

    static func isParsable(callbackQuery: JSON) -> Bool

    var callbackQuery: JSON { get }

    init(callbackQuery: JSON)

    func run() throws
}

extension BaseCallbackQuery {

    static func isParsable(callbackQuery: JSON) -> Bool {
        guard let callbackData = callbackData else {
            return false
        }
        guard let data = callbackQuery["data"]?.string else {
            return false
        }
        return data == callbackData
    }
}

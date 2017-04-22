//
//  CallbackGame.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

class CallbackGame: JSONRepresentable {

    func makeJSON() throws -> JSON {
        return JSON(Node(nilLiteral: ()))
    }
}

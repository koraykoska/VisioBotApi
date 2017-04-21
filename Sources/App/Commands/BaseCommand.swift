//
//  BaseCommand.swift
//  VisioBotApi
//
//  Created by Koray Koska on 21/04/2017.
//
//

import Vapor

protocol BaseCommand {

    static var command: String { get }

    static func isParsable(json: JSON) -> Bool

    var message: JSON { get }

    init(message: JSON)

    func run() throws
}

extension BaseCommand {

    static func isParsable(json: JSON) -> Bool {
        guard let text = json["text"]?.string else {
            return false
        }
        return text == command || text == "\(command)\(ConfigHolder.botName)"
    }
}

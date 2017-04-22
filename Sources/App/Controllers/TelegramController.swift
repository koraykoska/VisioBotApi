//
// Created by Koray Koska on 21/04/2017.
//

import HTTP
import Vapor

final class TelegramController {

    func telegramBaseRequest(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }

        // Parse request
        if let message = json["message"] {
            try parseMessage(message)
        }

        return try JSON(node: [
            "success": true
            ])
    }

    fileprivate func parseMessage(_ message: JSON) throws {
        let commands: [BaseCommand.Type] = [StartCommand.self, AnalyzeCommand.self]

        var correctCommands: [BaseCommand] = []
        for command in commands {
            if command.isParsable(message: message) {
                correctCommands.append(command.init(message: message))
            }
        }

        for command in correctCommands {
            try command.run()
        }
    }
}

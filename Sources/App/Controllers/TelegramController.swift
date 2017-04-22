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

        if let callbackQuery = json["callback_query"] {
            drop.log.error(try callbackQuery.serialize().string())
            try parseCallbackQuery(callbackQuery)
        }

        return try JSON(node: [
            "success": true
            ])
    }

    fileprivate func parseMessage(_ message: JSON) throws {
        let commands: [BaseCommand.Type] = [StartCommand.self, AnalyzeCommand.self, PhotoCommand.self]

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

    fileprivate func parseCallbackQuery(_ callbackQuery: JSON) throws {
        let callbackQueries: [BaseCallbackQuery.Type] = [AnalyzeInlineCallbackQuery.self]

        var correctCallbackQueries: [BaseCallbackQuery] = []
        for query in callbackQueries {
            if query.isParsable(callbackQuery: callbackQuery) {
                correctCallbackQueries.append(query.init(callbackQuery: callbackQuery))
            }
        }

        for query in correctCallbackQueries {
            try query.run()
        }
    }
}

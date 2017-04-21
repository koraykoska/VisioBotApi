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
            parseMessage(message)
        }

        return try JSON(node: [
            "success": true
            ])
    }

    fileprivate func parseMessage(_ message: JSON) {
        switch message["text"] {
        case nil:
            print("Not a text")
        default:
            print("Text")
        }
    }
}

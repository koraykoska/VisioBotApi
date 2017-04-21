//
// Created by Koray Koska on 21/04/2017.
//

import HTTP
import Vapor

final class TelegramController {

    func telegramBaseRequest(_ req: Request) throws -> ResponseRepresentable {
        guard let update = req.json?["update_id"]?.int else {
            throw Abort.badRequest
        }
        return try JSON(node: [
            "update_id": update
            ])
    }
}

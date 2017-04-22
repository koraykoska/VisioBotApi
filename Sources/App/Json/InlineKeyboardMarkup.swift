//
//  InlineKeyboardMarkup.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor

class InlineKeyboardMarkup: ReplyMarkup, JSONRepresentable {

    let inlineKeyboardButtonRows: [[InlineKeyboardButton]]

    init(inlineKeyboardButtonRows: [[InlineKeyboardButton]]) {
        self.inlineKeyboardButtonRows = inlineKeyboardButtonRows
    }

    func makeJSON() throws -> JSON {
        var buttonRows: [JSON] = []

        for inlineKeyboardButtonRow in inlineKeyboardButtonRows {
            var buttonRow: [JSON] = []
            for button in inlineKeyboardButtonRow {
                buttonRow.append(try button.makeJSON())
            }

            buttonRows.append(JSON(buttonRow))
        }

        return try JSON(node: [
            "inline_keyboard": JSON(buttonRows)
            ])
    }
}

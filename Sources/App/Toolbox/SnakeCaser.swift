//
//  SnakeCaser.swift
//  App
//
//  Created by Koray Koska on 01.02.19.
//

import Foundation
import JavaScriptCore

class SnakeCaser {

    static func snakeCase(json: String) -> String? {
        let context = JSContext()

        let path = "Resources/snake_case.js"
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        let js = String(data: data, encoding: .utf8)

        context?.evaluateScript(js)

        let testFunction = context?.objectForKeyedSubscript("sn")
        let result = testFunction?.call(withArguments: [json])

        guard result?.isString ?? false else {
            return nil
        }

        return result?.toString()
    }
}

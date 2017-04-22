//
//  GoogleVisionApi.swift
//  VisioBotApi
//
//  Created by Koray Koska on 22/04/2017.
//
//

import Vapor
import HTTP

class GoogleVisionApi {

    static let baseUrl: (_ apiKey: String) -> String = { apiKey in
        return "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
    }

    static let jsonContentTypeHeader: [HeaderKey: String] = ["Content-Type": "application/json"]

    class func annotate(imageBytes: Bytes) throws -> Response {
        var imageRequestNode: [String: NodeRepresentable] = [
            "image": try JSON(node: ["content": imageBytes.base64Encoded.string()]),
        ]
        let features: [NodeRepresentable] = [try JSON(node: ["type": "LABEL_DETECTION", "maxResults": 10])]

        imageRequestNode["features"] = try JSON(node: features)

        let imageRequest = try JSON(node: [
            "requests": JSON(node: [JSON(node: imageRequestNode)])
            ])

        let apiKey = ConfigHolder.googleApiKey ?? ""
        let response = try drop.client.post(baseUrl(apiKey), headers: jsonContentTypeHeader, body: imageRequest.makeBody())

        return response
    }
}

//
//  GoogleVisionApiAnnotateResponse.swift
//  App
//
//  Created by Koray Koska on 30.01.19.
//

import Foundation

struct GoogleVisionApiAnnotateResponse: Codable {

    let responses: [AnnotateImageResponse]

    struct AnnotateImageResponse: Codable {

        let labelAnnotations: [EntityAnnotation]?

        struct EntityAnnotation: Codable {

            let mid: String

            let locale: String?

            let description: String

            let score: Double

            let topicality: Double
        }
    }
}

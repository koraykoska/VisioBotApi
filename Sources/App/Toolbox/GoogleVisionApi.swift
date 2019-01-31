//
//  GoogleVisionApi.swift
//  App
//
//  Created by Koray Koska on 14.01.19.
//

import Foundation
import PromiseKit
import Dispatch

struct GoogleVisionApi {

    let headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    var baseUrl: String {
        return "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
    }

    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    enum Error: Swift.Error {

        case requestFailed

        case serverError

        case decodeFailed
    }

    func annotate(request: GoogleVisionApiAnnotateRequest) -> Promise<GoogleVisionApiAnnotateResponse> {
        return Promise { seal in
            self.annotate(request: request, response: seal.resolve)
        }
    }

    func annotate(request: GoogleVisionApiAnnotateRequest, response: @escaping (GoogleVisionApiAnnotateResponse?, Error?) -> ()) {
        let queue = DispatchQueue(label: "AppGoogleVisionApi", attributes: .concurrent)

        queue.async {
            guard let url = URL(string: self.baseUrl) else {
                let err = Error.requestFailed
                response(nil, err)
                return
            }

            let body: Data
            do {
                body = try self.encoder.encode(request)
            } catch {
                let err = Error.requestFailed
                response(nil, err)
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.httpBody = body
            for (k, v) in self.headers {
                req.addValue(v, forHTTPHeaderField: k)
            }

            let session = URLSession(configuration: .default)

            let task = session.dataTask(with: req) { data, urlResponse, error in
                guard let urlResponse = urlResponse as? HTTPURLResponse, let data = data, error == nil else {
                    let err = Error.serverError
                    response(nil, err)
                    return
                }

                let status = urlResponse.statusCode
                guard status >= 200 && status < 300 else {
                    let err = Error.serverError
                    response(nil, err)
                    return
                }

                do {
                    let res = try self.decoder.decode(GoogleVisionApiAnnotateResponse.self, from: data)

                    // We got the Result
                    response(res, nil)
                } catch {
                    response(nil, Error.decodeFailed)
                    return
                }
            }
            task.resume()
        }
    }
}

//
//  ImageDownloader.swift
//  App
//
//  Created by Koray Koska on 30.01.19.
//

import Foundation
import Dispatch
import PromiseKit

struct ImageDownloader {

    enum Error: Swift.Error {

        case requestFailed

        case serverError
    }

    static func downloadImage(url: String) -> Promise<Data> {
        return Promise { seal in
            ImageDownloader.downloadImage(url: url, response: seal.resolve)
        }
    }

    static func downloadImage(url: String, response: @escaping (Data?, Error?) -> ()) {
        let queue = DispatchQueue(label: "AppImageDownloader", attributes: .concurrent)

        queue.async {
            guard let url = URL(string: url) else {
                let err = Error.requestFailed
                response(nil, err)
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = "GET"

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

                // We got the Result
                response(data, nil)
            }
            task.resume()
        }
    }
}

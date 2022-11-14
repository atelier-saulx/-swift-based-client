//
//  Client.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 11/02/2022.
//

import Foundation
import BasedClient

struct Client {
    let based: Based
    let configure: () async throws -> ()
    let prepare: ()  async throws -> ()
    let fillDatabase: ()  async throws -> ()
}

extension Client {
    static let `default` = Self(
        based: Based(opts: Based.Opts(env: "_ENV_", project: "_PRJ_", org: "_ORG_")),
        configure: {
            
            let client = BasedClient()
            client.connect(org: "airhub", project: "airhub", env: "edge")
            
            
            let result = try? await Current.client.based
                .configure(schema: [
                    "types": [
                        "movie": [
                            "fields": [
                                "title": ["type": "text"],
                                "actors": [
                                    "type": "set",
                                    "items": ["type": "actor"]
                                ]
                            ]
                        ],
                        "actor": [
                            "name": ["type": "string"]
                        ]
                    ]
                ])
            print(result ?? "")
        },
        prepare: {
            let query = BasedQuery.query(
                .field("movies", .field("name", true), .field("id", true), .list(.find(.traverse("children"), .filter(.from("type"), .operator("="), .value("movie")))))
            )
            let result = try? await Current.client.based.delete(id: "root", database: nil)
            print(result ?? "")
        },
        fillDatabase: {
            let movie1 = try? await Current.client.based.set(query: .query(
                    .field("type", "movie"),
                    .field("name", "The Matrix Reloaded")
                )
            )
            
            let movie2 = try? await Current.client.based.set(query: .query(
                .field("type", "movie"),
                .field("name", "The Ice Road")
                )
            )
            
            
            guard let movie1 = movie1, let movie2 = movie2 else { return }
            
            let actor1 = try? await Current.client.based.set(query: .query(
                    .field("type", "actor"),
                    .field("name", "Keanu Reeves"),
                    .field("parents", movie1)
                )
            )
            
            let actor2 = try? await Current.client.based.set(query: .query(
                    .field("type", "actor"),
                    .field("name", "Laurence Fishburne"),
                    .field("parents", movie1, movie2)
                )
            )
            
            let actor3 = try? await Current.client.based.set(query: .query(
                .field("type", "actor"),
                .field("name", "Liam Neeson"),
                .field("parents", movie2)
                )
            )
            
        }
    )
}

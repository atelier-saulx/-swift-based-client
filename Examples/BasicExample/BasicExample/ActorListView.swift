//
//  ActorListView.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 18/02/2022.
//

import SwiftUI
import Combine
import BasedClient

public struct Actor: Decodable {
    let id: String
    let name: String
}

public struct Actors: Decodable {
    public let actors: [Actor]
    public init(actors: [Actor]) {
        self.actors = actors
    }
}

@MainActor class ActorListViewModel: ObservableObject {
    
    @Published var actors = Actors(actors: [])
    private var task: Task<(), Error>?

    func fetchActors() {
        let query = BasedQuery.query(
            .field(
                "actors",
                    .field("name", true),
                    .field("id", true),
                    .list(
                        .find(
                            .traverse("descendants"),
                            .filter(.from("type"), .operator("="), .value("actor"))
                        )
                    )
            )
        )

        task = Task {
            do {
                for try await actors in try Current.client.based.subscribe(query: query) as AsyncThrowingStream<Actors, Error> {
                    self.actors = actors
                }
            } catch {
                print(error)
            }
        }
    }
    
    func dispose() {
        task = nil
    }
}

struct ActorListView: View {
    
    @StateObject private var viewModel = ActorListViewModel()
    
    var body: some View {
        List(viewModel.actors.actors, id: \.id) { item in
            Text(item.name)
        }
        .navigationBarTitle("Actors")
        .onAppear {
            self.viewModel.fetchActors()
        }
        .onDisappear {
            self.viewModel.dispose()
        }
    }
    
}

struct Previews_ActorListView_Previews: PreviewProvider {
    static var previews: some View {
        ActorListView()
    }
}

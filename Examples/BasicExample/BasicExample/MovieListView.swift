//
//  MovieListView.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 15/02/2022.
//

import SwiftUI
import Combine
import BasedClient

public struct Movie: Decodable {
    let id: String
    let name: String
}

public struct Movies: Decodable {
    public let movies: [Movie]
    public init(movies: [Movie]) {
        self.movies = movies
    }
}

class MovieListViewModel: ObservableObject {
    
    @Published var movies = Movies(movies: [])
    private var task: Task<(), Error>?

    func fetchMovies() {

        let query = BasedQuery.query(
            .field("movies", .field("name", true), .field("id", true), .list(.find(.traverse("children"), .filter(.from("type"), .operator("="), .value("movie")))))
        )
        
        task = Task {
            do {
                for try await movies in try Current.client.based.subscribe(query: query) as AsyncThrowingStream<Movies, Error> {
                    self.movies = movies
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

struct MovieListView: View {
    
    @StateObject private var viewModel = MovieListViewModel()
    
    var body: some View {
        List(viewModel.movies.movies, id: \.id) { movie in
            NavigationLink(destination: ActorListView()) {
                Text(movie.name)
            }
        }
        .navigationBarTitle("Movies")
        .onAppear {
            self.viewModel.fetchMovies()
        }
        .onDisappear {
            self.viewModel.dispose()
        }
    }
    
}

struct Previews_MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}

//
//  ContentView.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import SwiftUI
import BasedClient



class ViewModel: ObservableObject {
    
    @Published var ready = false
    @Published var statusText = "Updating schema..."
    
    let based = Based.init(configuration: .init(org: "airhub", project: "airhub", env: "edge"))
//    let test: [String: Int] = based.subscribe(name: "counter")
//
//    func getCounter() async {
//        for await a in based.subscribe(name: "counter") {
//            await MainActor.run {
//
//            }
//        }
//    }

    func setup() async {
        
//        - counter, an observable that fires every second
//        - crasher, a NON-observable that fires an error
//        - obsCrasher, an observable that crashes

        
        
        do {
            let test: [String: Int] = try await based.get(name: "counter")
            print(test)
            

//            try based.subscribe(name: "counter").asAirHubAsyncSequence()
        
            
            let schema = try await based.schema()
            print(schema)
        } catch {
            print(error)
        }
        
        
//        try? await Current.client.configure()
//        Task { @MainActor in
//            statusText = "Preparing..."
//        }
//        try? await Current.client.prepare()
//        Task { @MainActor in
//            statusText = "Setup data..."
//        }
//        try? await Current.client.fillDatabase()
//        Task { @MainActor in
//            ready = true
//        }
    }
}



struct ContentView: View {
    
    @ObservedObject private var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.ready {
            TypeChooserView()
        } else {
            ProgressView {
                Text(viewModel.statusText)
            }
            .onAppear {
                Task { await viewModel.setup() }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}


//func subscribe<Payload: Encodable, Response: Decodable>(
//    _ callSignature: RemoteCallSignature<Payload, Response>,
//    payload: Payload
//) throws -> AirHubAsyncSequence<Response> {
//    return try based.subscribe(name: callSignature.name, payload: payload).asAirHubAsyncSequence()
//}
//
//
//public struct AirHubAsyncSequence<Element>: AsyncSequence {
//    public final class Iterator: AsyncIteratorProtocol {
//        private var produceNext: () async throws -> Element?
//
//        init<Upstream: AsyncIteratorProtocol>(upstream: Upstream) where Element == Upstream.Element {
//            var mutableCopy = upstream
//            produceNext = {
//                try await mutableCopy.next()
//            }
//        }
//
//        public func next() async throws -> Element? {
//            try await produceNext()
//        }
//    }
//
//    private let makeIterator: () -> Iterator
//
//    init<Upstream: AsyncSequence>(upstream: Upstream) where Element == Upstream.Element {
//        makeIterator = {
//            Iterator(upstream: upstream.makeAsyncIterator())
//        }
//    }
//
//    public func makeAsyncIterator() -> Iterator {
//        makeIterator()
//    }
//}
//
//extension AsyncSequence {
//    func asAirHubAsyncSequence() -> AirHubAsyncSequence<Element> {
//        .init(upstream: self)
//    }
//}

# Based Swift client

This is a port of https://github.com/atelier-saulx/based-core/tree/main/docs, an Ios client for the Based data platform.
=======
# Usage

## Config
```
let client = Based(config: BasedConfig(env: "env", project: "projectName", org: "organization"))
```
## Get
```
        do {
            let result: [String: Int] = try await based.get(name: "functionName")
            print(result)
        } catch {
            print(error)
        }
```
## Delete
```
let res = try await client.delete(id: "root")
```
## Set
```
let res = try await client.set(query: BasedQuery.query(.field("type", "thing"), .field("name", name)))
```
## Observe
```
    var sequence: BasedAsyncSequence<[String: Int]>!
    var task: Task<(), Error>?
    
    ...
        
    sequence = based.subscribe(name: "functionName").asBasedAsyncSequence()
    task = Task {
        do {
            for try await c in sequence {
                print(c)
            }
        } catch {
            print(error)
        }
    }
    
    ...
    task.cancel()
    task = nil
```

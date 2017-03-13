import Foundation
import XCPlayground

let net = Network(inputs: 2, structure: [2, 4])!
for _ in 0...100 {
    net.train(inputs: [1, 0], expectedOutputs: [0, 1, 0.25, 0.75], η: 3)
    print(net.feed(inputs: [1, 0]))
}

import Foundation
import XCPlayground

let net = Network(inputs: 2, structure: [5, 1])!
let inputs: [Double] = [1, 0]
let outputs: [Double] = [1]

var cost: Double?
for _ in 0...10000 {
    print(net.feed(inputs: inputs))
    cost = net.cost(inputs: inputs, expectedOutputs: outputs)
    net.train(inputs: inputs, expectedOutputs: outputs, η: 0.01)
}
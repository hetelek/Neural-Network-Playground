import Foundation
import UIKit
import PlaygroundSupport

let net = Network(inputs: 2, structure: [2, 1])!
let inputs: [[Double]] = [[1, 1], [1, 0], [0, 1], [0, 0]]
let outputs: [[Double]] = [[1], [1], [1], [0]]

var cost: Double?
for _ in 0...100 {
    for index in 0..<inputs.count {
        print("got: \(net.feed(inputs: inputs[index])), expected: \(outputs[index])")
    }
    
    cost = net.cost(inputs: inputs[0], expectedOutputs: outputs[0])
    net.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: 2)
    print("-")
}

cost

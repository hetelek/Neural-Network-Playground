import Foundation
import UIKit
import PlaygroundSupport

let net = Network(inputs: 2, structure: [2, 1])!
let inputs: [[Double]] = [[1, 1], [1, 0], [0, 1], [0, 0]]
let outputs: [[Double]] = [[0], [1], [1], [0]]

var cost: Double?
for _ in 0...1000 {
    for index in 0..<inputs.count {
        let got = net.feed(inputs: inputs[index])
        print("got: \(got), expected: \(outputs[index])")
    }
    
    cost = net.cost(batchInputs: inputs, batchExpectedOutputs: outputs)
    net.batchTrain(batchInputs: inputs, batchExpectedOutputs: outputs, η: 0.5)
    print("")
}

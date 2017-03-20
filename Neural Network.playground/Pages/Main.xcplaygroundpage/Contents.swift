import Foundation
import UIKit
import PlaygroundSupport

let network = Network(inputs: 2, structure: [2, 1])!
let inputs: [[Double]] = [[1, 1], [0, 1], [1, 0], [0, 0]]
let outputs: [[Double]] = [[0], [1], [1], [0]]

let frame = CGRect(x: 0, y: 0, width: 600, height: 500)
let costView = NetworkCostView(frame: frame, network: network, inputs: inputs, outputs: outputs)
costView.learningRate = 4

let trainCount = 1000
for _ in 0..<trainCount {
    costView.train()
}

PlaygroundPage.current.liveView = costView

import Foundation
import UIKit
import PlaygroundSupport

/*:
 ## Neural Networks in Swift
 This playground uses standard Swift operations to create a working and trainable neural network. Neural networks are very powerful when used properly, and can fit any mathematical function.
 
 This playground will show you the basics of neural networks, and how their behavior changes based on a variety of hyperparameters. Even though we only scratch the surface of what's possible here, this is at the core of the most promising machine learning algorithms today.
 
 ---
 Let's begin by creating our network.
 */
let network = Network(inputs: 2, structure: [2, 1])!
/*:
 This creates a network that takes 2 values as input, has 2 hidden neurons, and 1 output neuron.
 */
let inputs: [[Double]] = [[1, 1], [0, 1], [1, 0], [0, 0]]
let outputs: [[Double]] = [[0], [1], [1], [0]]

let frame = CGRect(x: 0, y: 0, width: 600, height: 700)
let costView = NetworkCostView(frame: frame, network: network, inputs: inputs, outputs: outputs)
costView.learningRate = 4

let trainCount = 1000
for _ in 0..<trainCount {
    costView.train()
}

PlaygroundPage.current.liveView = costView

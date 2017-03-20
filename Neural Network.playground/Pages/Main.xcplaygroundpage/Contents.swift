import UIKit
import PlaygroundSupport

/*:
 ## Neural Networks in Swift
 This playground uses standard Swift operations to create a working and trainable neural network. Neural networks are very powerful when used properly, and can fit any mathematical function.
 
 This playground will show you the basics of neural networks, and how their behavior changes based on a variety of hyperparameters. Even though we only scratch the surface of what's possible here, these principles are the core of the most promising machine learning algorithms today.
 
 ---
 Let's begin by creating our network.
 */
let network = Network(inputs: 2, structure: [2, 1])!
/*:
 This creates a network that takes 2 values as input, has 2 hidden neurons, and 1 output neuron. Heuristics for network structure are not well established yet. In general, larger networks are the most flexible and applicable, but as a network's size increases so does the difficulty in training it. A network with 2 hidden neurons is able to fit the exclusive-OR function.
 
 We will now tell our network what behavior we're looking for. The inputs represent what we'll put into the network, and the outputs represent what a properly trained network should output when given the corresponding inputs.
 
 For example, when given [1, 1], the network should output 0 (or a close estimate). When given [0, 1], it should output 1. This represents the XOR (exclusive-OR) function.
 */
let inputs: [[Double]] = [[1, 1], [0, 1], [1, 0], [0, 0]]
let outputs: [[Double]] = [[0], [1], [1], [0]]

/*:
 Let's create a view that represents how well our network is doing. We are graphing the cost function. The cost function represents how far off we are from our desired outputs. A high cost function means that our network is not outputting what we're hoping for.
 */
let frame = CGRect(x: 0, y: 0, width: 600, height: 700)
let costView = NetworkCostView(frame: frame, network: network, inputs: inputs, outputs: outputs)

/*:
 Our learning rate represents how quickly the network attempts to converge. A high learning rate converges quicker, but has a greater probability of missing the global minimum of the cost function (or end up increasing the cost!). A smaller learning rate more accurately converges, but takes more training steps.
 
 Mess with the learning rate and see how it affects the cost graphs.
 */
costView.learningRate = 4

/*:
 We now train our network with the hyperparameters defined above. Try different iteration counts to see how it affects learning.
 */
let iterationCount = 1000
for _ in 0..<iterationCount {
    costView.train()
}

PlaygroundPage.current.liveView = costView

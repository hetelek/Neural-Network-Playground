import UIKit
import PlaygroundSupport

/*:
 ## Neural Networks in Swift
 
 Neural networks allow us to solve problems using vast amounts of data. We can _train_ a neural network by feeding it many examples, allowing it to generalize and make future predictions.
 
 We measure the accuracy of a network by calculating a _cost_ representing how far off the network's predictions are from the expected values. If a network is suppose to output 1, but actually outputs 0, then its cost is something greater than 0. If the network is working as desired, then it has a cost of 0.
 
 With this said, we train a network by:
 1. Feeding it some inputs, and getting the network's output.
 2. Calculating a cost by comparing the network's outputs and the desired outputs.
 3. Reducing the cost by changing some network parameters.
 4. Repeating.
 
 ---
 
 In this Playground, we will:
 1. Construct a neural networks
 2. [Train a neural network](InteractiveFitting)
 3. [Recognize handwritten digits](DigitRecognition)
 
 Let's begin by creating a network that takes 2 input values, has 2 hidden neurons, and outputs 1 value:
 */
let network = Network(inputs: 2, structure: [2, 1])!
/*:
 We will now tell our network what behavior we're looking for. The inputs represent what we'll put into the network, and the outputs represent what a properly trained network should output when given the corresponding inputs.
 
 For example, when given [1, 1], the network should output 0 (or a close estimate). When given [0, 1], it should output 1. This represents the XOR (exclusive-OR) function.
 */
let inputs: [[Double]] = [[1, 1], [0, 1], [1, 0], [0, 0]]
let outputs: [[Double]] = [[0], [1], [1], [0]]
/*:
 Let's create a view that represents how well our network is doing. We are graphing the cost function. A high cost function means that our network is not outputting what we're hoping for.
 */
let frame = CGRect(x: 0, y: 0, width: 600, height: 700)
let costView = NetworkCostView(frame: frame, network: network, inputs: inputs, outputs: outputs)
/*:
 We now train our network. Try changing the learning rate and iteration count to see how it affects learning.
 */
costView.learningRate = 4
let iterationCount = 1000
for _ in 0..<iterationCount {
    costView.train()
}
/*:
 If the network converged, it should be outputting the XOR gate and the cost should be near 0. If it failed to converge, try re-running or adjusting the learning rate.
 
 [Continue to Training a Network](@next)
 */
PlaygroundPage.current.liveView = costView

import Foundation

public class Network {
    private(set) var layers: [Matrix] = []
    private(set) var biases: [Matrix] = []
    
    public init?(inputs: Int, structure: [Int]) {
        guard let first = structure.first else {
            return nil
        }
        
        layers.append(Matrix(rows: inputs, columns: first))
        biases.append(Matrix(rows: 1, columns: first, repeating: 0.1))
        
        for hiddenNeurons in structure.dropFirst() {
            layers.append(Matrix(rows: layers.last!.columns, columns: hiddenNeurons))
            biases.append(Matrix(rows: 1, columns: hiddenNeurons, repeating: 0.1))
        }
    }
    
    public func feed(inputs: [Double]) -> Matrix {
        let (_, a) = internalFeed(inputs: inputs)
        return a.last!
    }
    
    public func cost(inputs: [Double], expectedOutputs: [Double]) -> Double {
        let expectedOutput = Matrix(elements: [expectedOutputs])
        let (_, a) = internalFeed(inputs: inputs)
        let difference = (a.last! - expectedOutput) ^ 2
        return (1.0 / (2.0 * 1)) * difference.sum()
    }
    
    public func batchTrain(batchInputs: [[Double]], batchExpectedOutputs: [[Double]], η: Double) {
        var derivativeSums: [Matrix] = []
        var errorSums: [Matrix] = []

        // calculate errors and derivatives for each sample
        for batchIndex in 0..<batchInputs.count {
            let inputs = batchInputs[batchIndex]
            let expectedOutput: Matrix = [batchExpectedOutputs[batchIndex]]
            let (allActivations, allSigmoidActivations) = internalFeed(inputs: inputs)
            
            let errors = calculateErrors(allActivations: allActivations, allSigmoidActivations: allSigmoidActivations, expectedOutput: expectedOutput)
            for index in 0..<errors.count {
                let layerErrors = errors[index]
                
                let derivatives = layerErrors.transpose().elementwiseProduct(matrix: allActivations[index])
                if batchIndex == 0 {
                    derivativeSums.append(derivatives)
                    errorSums.append(layerErrors)
                }
                else {
                    derivativeSums[index] = derivativeSums[index] + derivatives
                    errorSums[index] = errorSums[index] + layerErrors
                }
            }
        }
        
        // update the weights
        for layerIndex in 0..<derivativeSums.count {
            let layer = layers[layerIndex]
            let derivativeAverage = derivativeSums[layerIndex] / Double(derivativeSums.count)
            let errorAverage = errorSums[layerIndex] / Double(derivativeSums.count)
            
            for row in 0..<layer.rows {
                for col in 0..<layer.columns {
                    layer[row][col] = layer[row][col] - (derivativeAverage[0][col] * η)
                }
            }
            
            biases[layerIndex] = biases[layerIndex] - (errorAverage.transpose() * η)
        }
    }
    
    public func train(inputs: [Double], expectedOutputs: [Double], η: Double) {
        let expectedOutput = Matrix(elements: [expectedOutputs])
        let (allActivations, allSigmoidActivations) = internalFeed(inputs: inputs)
        
        let errors = calculateErrors(allActivations: allActivations, allSigmoidActivations: allSigmoidActivations, expectedOutput: expectedOutput)
        for index in 0..<errors.count {
            let layerErrors = errors[index]
            let layer = layers[index]
            
            let derivatives = layerErrors.transpose().elementwiseProduct(matrix: allActivations[index])
            for row in 0..<layer.rows {
                for col in 0..<layer.columns {
                    layer[row][col] = layer[row][col] - (derivatives[0][col] * η)
                }
            }

            biases[index] = biases[index] - (layerErrors.transpose() * η)
        }
    }
    
    private func calculateErrors(allActivations: [Matrix], allSigmoidActivations: [Matrix], expectedOutput: Matrix) -> [Matrix] {
        // cost error
        let outputSensitivity = allActivations.last!.elementMap(transform: Network.sigmoidDerivative)
        let outputError = (allSigmoidActivations.last! - expectedOutput).elementwiseProduct(matrix: outputSensitivity).transpose()
        
        // layer errors
        var errors = [outputError]
        for index in (1..<layers.count).reversed() {
            let previousError = errors.last!
            let layer = layers[index]
            let activation = allActivations[index - 1].transpose()
            let activationSigmoidPrime = activation.elementMap(transform: Network.sigmoidDerivative)
            
            let newError = (layer * previousError).elementwiseProduct(matrix: activationSigmoidPrime)
            errors.append(newError)
        }
        
        return errors.reversed()
    }
    
    private func internalFeed(inputs: [Double]) -> (z: [Matrix], a: [Matrix]) {
        var z: [Matrix] = []
        var a: [Matrix] = []
        
        var output = Matrix(elements: [inputs])
        
        for (index, layer) in layers.enumerated() {
            output = (output * layer) + biases[index]
            z.append(output)
            
            output = output.elementMap(transform: Network.sigmoid)
            a.append(output)
        }
        
        return (z, a)
    }
    
    
    // MARK: - Math functions
    private static func sigmoid(input: Double) -> Double {
        return 1.0 / (1 + pow(M_E, -input))
    }
    
    private static func sigmoidDerivative(input: Double) -> Double {
        let sigmoidValue = sigmoid(input: input)
        return sigmoidValue * (1 - sigmoidValue)
    }
}

import Foundation

public class Network {
    private(set) var layers: [Matrix] = []
    private(set) var biases: [Matrix] = []
    
    public init?(inputs: Int, structure: [Int]) {
        guard let first = structure.first else {
            return nil
        }
        
        layers.append(Matrix(rows: inputs, columns: first))
        biases.append(Matrix(rows: 1, columns: first, repeating: 0))
        
        for hiddenNeurons in structure.dropFirst() {
            layers.append(Matrix(rows: layers.last!.columns, columns: hiddenNeurons))
            biases.append(Matrix(rows: 1, columns: hiddenNeurons, repeating: 0))
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
    
    public func train(inputs: [Double], expectedOutputs: [Double], η: Double) {
        let expectedOutput = Matrix(elements: [expectedOutputs])
        let (allActivations, allSigmoidActivations) = internalFeed(inputs: inputs)
        
        let errors = calculateErrors(allActivations: allActivations, allSigmoidActivations: allSigmoidActivations, expectedOutput: expectedOutput)
        for index in 0..<errors.count {
            let layerErrors = errors[index]
            let layerBiases = biases[index]
            let layer = layers[index]
            
            for row in 0..<layer.rows {
                for col in 0..<layer.columns {
                    let weight = layer[row][col]
                    layer[row][col] = weight + (weight * -η * layerErrors[col][0])
                }
            }
            
            biases[index] = layerBiases + layerErrors.transpose().elementMap { -η * $0 }
        }
    }
    
    private func calculateErrors(allActivations: [Matrix], allSigmoidActivations: [Matrix], expectedOutput: Matrix) -> [Matrix] {
        // cost error
        let outputSensitivity = allActivations.last!.elementMap(transform: Network.sigmoidDerivative)
        let outputError = (allSigmoidActivations.last! - expectedOutput).elementwiseProduct(matrix: outputSensitivity).transpose()
        
        // layer errors
        var errors = [outputError]
        for layer in layers.dropFirst().reversed() {
            let previousError = errors.last!
            let newError = layer * previousError
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

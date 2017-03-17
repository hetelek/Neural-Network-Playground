import Foundation

public class Network {
    private(set) var layers: [Matrix] = []
    private(set) var biases: [Matrix] = []
    
    var σ: (Double) -> Double = { x in
        return 1.0 / (1 + pow(M_E, -x))
    }
    var σPrime: (Double) -> Double = { x in
        let sigmoidValue = 1.0 / (1 + pow(M_E, -x))
        return sigmoidValue * (1 - sigmoidValue)
    }
    
    public init?(inputs: Int, structure: [Int]) {
        guard let first = structure.first else {
            return nil
        }
        
        layers.append(Matrix(rows: first, columns: inputs))
        biases.append(Matrix(rows: first, columns: 1, repeating: 0.1))
        
        for hiddenNeurons in structure.dropFirst() {
            layers.append(Matrix(rows: hiddenNeurons, columns: layers.last!.rows))
            biases.append(Matrix(rows: hiddenNeurons, columns: 1, repeating: 0.1))
        }
    }
    
    public func feed(inputs: [Double]) -> Matrix {
        let (_, a) = internalFeed(inputs: inputs)
        return a.last!
    }
    
    public func batchTrain(batchInputs: [[Double]], batchExpectedOutputs: [[Double]], η: Double) {
        var weightGradients: [Matrix]!
        var biasGradients: [Matrix]!
        
        for sampleIndex in 0..<batchInputs.count {
            let inputs = batchInputs[sampleIndex]
            let expectedOutputs = batchExpectedOutputs[sampleIndex]
            
            let (sampleWeightGradients, sampleBiasGradients) = calculateGradients(inputs: inputs, expectedOutputs: expectedOutputs)
            if weightGradients != nil {
                // add the new gradients to the existing ones (later used to take gradient avergae)
                for layerIndex in 0..<sampleWeightGradients.count {
                    weightGradients[layerIndex] = weightGradients[layerIndex] + sampleWeightGradients[layerIndex]
                    biasGradients[layerIndex] = biasGradients[layerIndex] + sampleBiasGradients[layerIndex]
                }
            }
            else {
                weightGradients = sampleWeightGradients
                biasGradients = sampleBiasGradients
            }
        }
        
        let batchSize = Double(batchInputs.count)
        for layerIndex in 0..<layers.count {
            let layerWeightGradients = weightGradients[layerIndex] / batchSize
            let layerBiasGradients = biasGradients[layerIndex] / batchSize
            
            // update weights
            layers[layerIndex] = layers[layerIndex] - (layerWeightGradients * η)
            
            // update biases
            biases[layerIndex] = biases[layerIndex] - (layerBiasGradients * η)
        }
    }
    
    public func train(inputs: [Double], expectedOutputs: [Double], η: Double) {
        let (weightGradients, biasGradients) = calculateGradients(inputs: inputs, expectedOutputs: expectedOutputs)
        print(weightGradients)
        
        for layerIndex in 0..<layers.count {
            // update weights
            layers[layerIndex] = layers[layerIndex] - (weightGradients[layerIndex] * η)
            
            // update biases
            biases[layerIndex] = biases[layerIndex] - (biasGradients[layerIndex] * η)
        }
    }
    
    private func calculateGradients(inputs: [Double], expectedOutputs: [Double]) -> (weightGradients: [Matrix], biasGradients: [Matrix]) {
        // our return variables
        var allWeightGradients: [Matrix] = []
        var allBiasGradients: [Matrix] = []
        
        // forward pass
        let expectedOutput = Matrix(elements: [expectedOutputs]).transpose()
        var (allActivations, allSigmoidActivations) = internalFeed(inputs: inputs)
        
        // backpropagate
        let errors = calculateErrors(allActivations: allActivations, allSigmoidActivations: allSigmoidActivations, expectedOutput: expectedOutput)
        
        allSigmoidActivations.insert(Matrix(elements: [inputs]).transpose(), at: 0)
        
        for (index, error) in errors.enumerated() {
            // calculate weight gradients
            let layer = layers[index]
            let weightGradients = Matrix(rows: layer.rows, columns: layer.columns, repeating: 0)
            for row in 0..<weightGradients.rows {
                for col in 0..<weightGradients.columns {
                    weightGradients[row][col] = error[row][0] * allSigmoidActivations[index][col][0]
                }
            }
            
            // bias gradients are exactly equal to errors
            let biasGradients = error
            
            // add to array
            allWeightGradients.append(weightGradients)
            allBiasGradients.append(biasGradients)
        }
        
        return (allWeightGradients, allBiasGradients)
    }
    
    private func calculateErrors(allActivations: [Matrix], allSigmoidActivations: [Matrix], expectedOutput: Matrix) -> [Matrix] {
        // cost error
        let activationDerivative = allActivations.last!.elementMap(transform: self.σPrime)
        let outputError = (allSigmoidActivations.last! - expectedOutput).elementwiseProduct(matrix: activationDerivative)
        
        // layer errors
        var errors = [outputError]
        for index in (0..<(layers.count - 1)).reversed() {
            let previousError = errors.last!
            let layer = layers[index + 1].transpose()
            
            let activation = allActivations[index]
            let activationSigmoidPrime = activation.elementMap(transform: self.σPrime)
            
            let newError = (layer * previousError).elementwiseProduct(matrix: activationSigmoidPrime)
            errors.append(newError)
        }
        
        return errors.reversed()
    }
    
    private func internalFeed(inputs: [Double]) -> (z: [Matrix], a: [Matrix]) {
        var z: [Matrix] = []
        var a: [Matrix] = []
        
        var output = Matrix(elements: [inputs]).transpose()
        
        for (index, layer) in layers.enumerated() {
            output = (layer * output) + biases[index]
            z.append(output)
            
            output = output.elementMap(transform: self.σ)
            a.append(output)
        }
        
        return (z, a)
    }
}

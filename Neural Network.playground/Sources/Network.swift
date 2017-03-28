import Foundation

public class Network {
    // MARK: - Private properties
    private(set) var layers: [Matrix] = []
    private(set) var biases: [Matrix] = []
    
    // MARK: - Public properties
    public var σ: (Double) -> Double = { x in
        return 1.0 / (1 + pow(M_E, -x))
    }
    public var σPrime: (Double) -> Double = { x in
        let sigmoidValue = 1.0 / (1 + pow(M_E, -x))
        return sigmoidValue * (1 - sigmoidValue)
    }
    
    public var cost: (Matrix, Matrix) -> Double = { calculated, expected in
        let difference = (calculated - expected) ^ 2
        let distanceFromExpected = sqrt(difference.sum())
        let cost = pow(distanceFromExpected, 2) / 2
        return cost
    }
    public var costPrime: (Matrix, Matrix) -> Matrix = { calculated, expected in
        return calculated - expected
    }
    
    public var inputs: Int {
        get {
            return layers.first!.columns
        }
    }
    public var structure: [Int] {
        get {
            return layers.map { $0.rows }
        }
    }
    
    
    // MARK: - Initalization
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
    
    public init(url: URL) {
        guard let data = try? Data(contentsOf: url),
            let string = String.init(data: data, encoding: .utf8) else {
            fatalError("Cannot read given URL.")
        }
        
        // parse the weights file
        let components = string.components(separatedBy: "\n")
        for (index, component) in components.enumerated() {
            let numbers = component.components(separatedBy: ",")
            guard numbers.count > 2 else {
                continue
            }
            
            // get number of weights / matrix shape
            let rows = Int(numbers[0])!
            let columns = Int(numbers[1])!
            let layer = Matrix(rows: rows, columns: columns)
            
            // populate matrix
            for (index, number) in numbers.dropFirst(2).enumerated() {
                let row = index / columns
                let column = index % columns
                layer[row][column] = Double(number)!
            }
            
            // evens are considered the neurons, odds are the bias
            if index % 2 == 0 {
                layers.append(layer)
            }
            else {
                biases.append(layer)
            }
        }
    }
    
    
    // MARK: - Feeding, Cost, Training
    public func feed(inputs: [Double]) -> Matrix {
        let (_, a) = internalFeed(inputs: inputs)
        return a.last!
    }
    
    public func cost(batchInputs: [[Double]], batchExpectedOutputs: [[Double]]) -> Double {
        var runningCostSum: Double = 0
        
        // calculate cost for each sample
        for sampleIndex in 0..<batchInputs.count {
            // get inputs/expected outputs
            let inputs = batchInputs[sampleIndex]
            let expectedOutputs = batchExpectedOutputs[sampleIndex]
            let expectedOutputsMatrix = Matrix(elements: [expectedOutputs]).transpose()
            
            // calculate cost, add to runnign sum
            let calculatedOutput = feed(inputs: inputs)
            let sampleCost = cost(calculatedOutput, expectedOutputsMatrix)
            
            runningCostSum += sampleCost
        }
        
        // take average cost
        return runningCostSum / Double(batchInputs.count)
    }
    
    public func batchTrain(batchInputs: [[Double]], batchExpectedOutputs: [[Double]], η: Double) {
        // make sure we have something to train
        guard batchInputs.count > 0,
            batchInputs.count == batchExpectedOutputs.count else {
            return
        }
        
        var weightGradients: [Matrix]!
        var biasGradients: [Matrix]!
        
        // sum gradients from each sample
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
    
    
    // MARK: - Back propagation calculations
    private func calculateGradients(inputs: [Double], expectedOutputs: [Double]) -> (weightGradients: [Matrix], biasGradients: [Matrix]) {
        // our return variables
        var allWeightGradients: [Matrix] = []
        var allBiasGradients: [Matrix] = []
        
        // forward pass
        let expectedOutput = Matrix(elements: [expectedOutputs]).transpose()
        var (allActivations, allTransformedActivations) = internalFeed(inputs: inputs)
        
        // backpropagate
        let errors = calculateErrors(allActivations: allActivations, allTransformedActivations: allTransformedActivations, expectedOutput: expectedOutput)
        
        allTransformedActivations.insert(Matrix(elements: [inputs]).transpose(), at: 0)
        
        for (index, error) in errors.enumerated() {
            // calculate weight gradients
            let layer = layers[index]
            let weightGradients = Matrix(rows: layer.rows, columns: layer.columns, repeating: 0)
            for row in 0..<weightGradients.rows {
                for col in 0..<weightGradients.columns {
                    weightGradients[row][col] = error[row][0] * allTransformedActivations[index][col][0]
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
    
    private func calculateErrors(allActivations: [Matrix], allTransformedActivations: [Matrix], expectedOutput: Matrix) -> [Matrix] {
        // cost error
        let activationDerivative = allActivations.last!.elementMap(transform: self.σPrime)
        let outputError = costPrime(allTransformedActivations.last!, expectedOutput).elementwiseProduct(matrix: activationDerivative)
        
        // layer errors
        var errors = [outputError]
        for index in (0..<(layers.count - 1)).reversed() {
            let previousError = errors.last!
            let layer = layers[index + 1].transpose()
            
            let activation = allActivations[index]
            let activationTransformationPrime = activation.elementMap(transform: self.σPrime)
            
            let newError = (layer * previousError).elementwiseProduct(matrix: activationTransformationPrime)
            errors.append(newError)
        }
        
        return errors.reversed()
    }
    
    
    // MARK: - Forward propagation calculator
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

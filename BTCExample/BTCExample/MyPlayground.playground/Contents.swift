import UIKit

func fibonacciSequence(upTo n: Int) -> [Int] {
    var sequence: [Int] = []
    //O(n)
    for i in 0...n {
        if i <= 1 {
            sequence.append(i)
        } else {
            let nextNumber = sequence[i - 1] + sequence[i - 2]
            if nextNumber <= n {
                sequence.append(nextNumber)
            } else {
                break
            }
        }
    }
    
    return sequence
}

func isPrime(_ number: Int) -> Bool {
    if number <= 1 {
        return false
    }
    
    for i in 2..<number {
        if number % i == 0 {
            return false
        }
    }
    
    return true
}

func generatePrimeNumbers(upTo number: Int) -> [Int] {
    var primes = [Int]()
    
    for i in 2...number {
        if isPrime(i) {
            primes.append(i)
        }
    }
    
    return primes
}

func filterArray(from array1: [Int], compareWith array2: [Int]) -> [Int] {
    var filteredArray = [Int]()
    
    for item1 in array1 {
        for item2 in array2 {
            if item1 == item2 {
                filteredArray.append(item1)
                break
            }
        }
    }
    
    return filteredArray
}

let fibSequence = fibonacciSequence(upTo: 100)
let primeSequence = generatePrimeNumbers(upTo: 100)
filterArray(from: fibSequence, compareWith: primeSequence)

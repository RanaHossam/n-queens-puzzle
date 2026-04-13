//
//  BestTimeUseCase.swift
//  QueensDomain
//
//  Created by Rana Hossam on 12/04/2026.
//

public class BestTimeUseCase {
    
    private let bestTimesRepository: any BestTimesRepositoryProtocol
    
    public init(bestTimesRepository: any BestTimesRepositoryProtocol) {
        self.bestTimesRepository = bestTimesRepository
    }
    
    public func getBest(for size: Int) async throws -> BestTime? {
        try await bestTimesRepository.bestTime(for: size)
    }
    
    public func save(bestTime: BestTime) async throws {
        try await bestTimesRepository.save(bestTime: bestTime)
    }
    
    public func fetchAll() async throws -> [BestTime] {
        try await bestTimesRepository.fetchAll()
    }
}

//
//  Poll.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 18.02.2026.
//

import Foundation

// MARK: - Poll
struct PollDTO: Codable, Equatable, Hashable {
    let id: String
    let question: String
    let questionId: String
    let options: [PollOptionDTO]
}

// MARK: - PollOption
struct PollOptionDTO: Codable, Equatable, Hashable {
    let text: String
    let numberOfVotes: Int
}

//
//  PollViewData.swift
//  CarouselDemo
//

import Foundation

// MARK: - PollViewData
struct PollData: Equatable, Identifiable {
    let id: String
    let questionId: String
    let question: String
    let options: [PollOptionData]

    var totalVotes: Int {
        options.reduce(0) { $0 + $1.numberOfVotes }
    }
}

// MARK: - PollOptionData
struct PollOptionData: Equatable, Identifiable {
    let id: Int // index in array
    let text: String
    let numberOfVotes: Int
}

// MARK: - Convenience Initializer
extension PollData {
    init(from poll: PollDTO) {
        self.id = poll.id
        self.questionId = poll.questionId
        self.question = poll.question
        self.options = poll.options.enumerated().map { index, option in
            PollOptionData(from: option, index: index)
        }
    }
}

extension PollOptionData {
    init(from option: PollOptionDTO, index: Int) {
        self.id = index
        self.text = option.text
        self.numberOfVotes = option.numberOfVotes
    }
}


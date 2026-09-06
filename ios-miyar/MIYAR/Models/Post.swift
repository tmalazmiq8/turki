import Foundation

nonisolated enum PostKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case question
    case discussion
    case photo
    case educational
    case formula

    var id: String { rawValue }

    var label: LText {
        switch self {
        case .question: S.postQuestion
        case .discussion: S.postDiscussion
        case .photo: S.postPhoto
        case .educational: S.postEducational
        case .formula: S.postFormula
        }
    }

    var symbol: String {
        switch self {
        case .question: "questionmark.circle"
        case .discussion: "bubble.left.and.bubble.right"
        case .photo: "photo"
        case .educational: "graduationcap"
        case .formula: "flask"
        }
    }
}

/// A comment, optionally a reply to another comment.
nonisolated struct PostComment: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var authorID: String
    var bodyAr: String
    var bodyEn: String
    var createdAt: Date
    var parentID: UUID?
    var likeCount: Int = 0
    var isLiked: Bool = false

    func body(_ language: AppLanguage) -> String { language == .ar ? bodyAr : bodyEn }
}

/// A community post.
nonisolated struct Post: Codable, Identifiable, Hashable, Sendable {
    var id: UUID = UUID()
    var authorID: String
    var kind: PostKind
    var titleAr: String
    var titleEn: String
    var bodyAr: String
    var bodyEn: String
    var families: [OlfactoryFamily]
    var createdAt: Date
    var likeCount: Int = 0
    var isLiked: Bool = false
    var isSaved: Bool = false
    var comments: [PostComment] = []
    var artworkSeed: Int = 0
    var hasImage: Bool = true
    var photoIDs: [String] = []
    /// Present for formula-type posts.
    var formulaLines: [LText] = []

    func title(_ language: AppLanguage) -> String { language == .ar ? titleAr : titleEn }
    func body(_ language: AppLanguage) -> String { language == .ar ? bodyAr : bodyEn }

    var commentCount: Int { comments.count }

    /// Top-level comments, oldest first.
    var rootComments: [PostComment] {
        comments.filter { $0.parentID == nil }.sorted { $0.createdAt < $1.createdAt }
    }

    func replies(to commentID: UUID) -> [PostComment] {
        comments.filter { $0.parentID == commentID }.sorted { $0.createdAt < $1.createdAt }
    }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return [titleAr, titleEn, bodyAr, bodyEn].contains { $0.localizedStandardContains(query) }
    }
}

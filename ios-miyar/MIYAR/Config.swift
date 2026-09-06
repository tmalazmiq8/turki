// Config.swift
// Values for Rork's AI toolkit proxy (used only by AIService for the AI
// assistant feature). Left empty here — the AI assistant will show a
// "backend not configured" message until real values are filled in, but
// every other feature of the app (auth, database, IFRA, marketplace,
// community) works with these left blank.
//
// If you have a Rork toolkit URL/token, or wire the assistant to a
// different backend, fill the two values below directly.

import Foundation

enum Config {
    static let EXPO_PUBLIC_RORK_FUNCTIONS_URL = ""
    static let EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY = ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ""

    static let allValues: [String: String] = [
        "EXPO_PUBLIC_RORK_FUNCTIONS_URL": EXPO_PUBLIC_RORK_FUNCTIONS_URL,
        "EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY": EXPO_PUBLIC_RORK_TOOLKIT_SECRET_KEY,
        "EXPO_PUBLIC_TOOLKIT_URL": EXPO_PUBLIC_TOOLKIT_URL,
    ]
}

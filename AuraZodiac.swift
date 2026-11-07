// xcode: set sdk=iOS

//
//  AuraZodiac.swift
//  AuraZodiac — Pastel Pink Coquette Celestial & Synastry Studio
//
//  Single-File SwiftUI Architecture featuring:
//  1. @Observable MotionManager polling CMMotionManager gyroscope data (60 Hz)
//     for fluid 3D tilt, specular sheen parallax, and astrolabe wheel rotation.
//  2. Interactive Constellation Wheel with 12 vector star-maps, degree rings,
//     coquette bow ascendant crest, touch-spin physics, and live aspect chords.
//  3. Deterministic Synastry Engine mapping Elemental, Modality, Aspect Geometry,
//     and Triplicity Decan harmonics into multi-dimensional compatibility scores.
//  4. Undoable Action Ledger tracking profile edits, smart date parses, swaps,
//     and SwiftData Vault mutations with full Undo / Redo restoration.
//  5. Zero-dependency Smart Regex Date-Parser translating chaotic, conversational
//     textual inputs into validated DateComponents.
//  6. Structural SwiftData (@Model) persistence across app lifecycle sleep states.
//

import SwiftUI
import SwiftData
import Observation
import CoreMotion
import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 1. Coquette Aesthetic Design System & Haptics

enum AuraTheme {
    // Ultra-clean Pastel Pink Coquette Palette
    static let porcelainTop      = Color(red: 1.000, green: 0.980, blue: 0.988) // #FFF9FC
    static let balletBlush       = Color(red: 0.992, green: 0.937, blue: 0.957) // #FDEFF4
    static let rosewaterMist     = Color(red: 0.976, green: 0.882, blue: 0.918) // #F9E1EA
    static let petalSilk         = Color(red: 0.957, green: 0.808, blue: 0.867) // #F4CEDD
    static let coquettePink      = Color(red: 0.906, green: 0.545, blue: 0.682) // #E78BAE
    static let raspberryVelvet   = Color(red: 0.776, green: 0.345, blue: 0.518) // #C65884
    static let champagnePearl    = Color(red: 0.969, green: 0.918, blue: 0.890) // #F7EAE3
    static let gildedRose        = Color(red: 0.765, green: 0.569, blue: 0.545) // #C3918B
    static let celestialLilac    = Color(red: 0.867, green: 0.796, blue: 0.914) // #DDCBE9
    static let sageMist          = Color(red: 0.463, green: 0.659, blue: 0.576) // #76A893

    // High-contrast editorial ink tones
    static let plumInk           = Color(red: 0.235, green: 0.129, blue: 0.184) // #3C212F
    static let mauveSubtext      = Color(red: 0.475, green: 0.337, blue: 0.408) // #795668
    static let whisperedMauve    = Color(red: 0.639, green: 0.506, blue: 0.573) // #A38192

    static let backgroundGradient = LinearGradient(
        colors: [porcelainTop, balletBlush, rosewaterMist.opacity(0.65), porcelainTop],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ribbonGradient = LinearGradient(
        colors: [coquettePink, raspberryVelvet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let pearlCardGradient = LinearGradient(
        colors: [Color.white.opacity(0.92), Color(red: 1.0, green: 0.968, blue: 0.980).opacity(0.86)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

@MainActor
enum AuraHaptics {
    static func softTap() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 0.65)
        #endif
    }

    static func crispTick() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.55)
        #endif
    }

    static func successBloom() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    static func gentleWarning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
}

/// Custom vector French satin bow for the pastel coquette aesthetic.
struct CoquetteBowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let cx = rect.midX
        let cy = rect.midY - h * 0.08

        // Left satin loop
        path.move(to: CGPoint(x: cx, y: cy))
        path.addCurve(
            to: CGPoint(x: rect.minX + w * 0.06, y: cy - h * 0.26),
            control1: CGPoint(x: cx - w * 0.18, y: cy - h * 0.36),
            control2: CGPoint(x: rect.minX + w * 0.08, y: cy - h * 0.42)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: rect.minX + w * 0.04, y: cy + h * 0.16),
            control2: CGPoint(x: cx - w * 0.20, y: cy + h * 0.22)
        )

        // Right satin loop
        path.move(to: CGPoint(x: cx, y: cy))
        path.addCurve(
            to: CGPoint(x: rect.maxX - w * 0.06, y: cy - h * 0.26),
            control1: CGPoint(x: cx + w * 0.18, y: cy - h * 0.36),
            control2: CGPoint(x: rect.maxX - w * 0.08, y: cy - h * 0.42)
        )
        path.addCurve(
            to: CGPoint(x: cx, y: cy),
            control1: CGPoint(x: rect.maxX - w * 0.04, y: cy + h * 0.16),
            control2: CGPoint(x: cx + w * 0.20, y: cy + h * 0.22)
        )

        // Left flowing ribbon tail
        path.move(to: CGPoint(x: cx - w * 0.04, y: cy + h * 0.04))
        path.addQuadCurve(
            to: CGPoint(x: cx - w * 0.28, y: rect.maxY),
            control: CGPoint(x: cx - w * 0.12, y: cy + h * 0.34)
        )
        path.addLine(to: CGPoint(x: cx - w * 0.15, y: rect.maxY - h * 0.08))
        path.addQuadCurve(
            to: CGPoint(x: cx, y: cy + h * 0.06),
            control: CGPoint(x: cx - w * 0.06, y: cy + h * 0.26)
        )

        // Right flowing ribbon tail
        path.move(to: CGPoint(x: cx + w * 0.04, y: cy + h * 0.04))
        path.addQuadCurve(
            to: CGPoint(x: cx + w * 0.28, y: rect.maxY),
            control: CGPoint(x: cx + w * 0.12, y: cy + h * 0.34)
        )
        path.addLine(to: CGPoint(x: cx + w * 0.15, y: rect.maxY - h * 0.08))
        path.addQuadCurve(
            to: CGPoint(x: cx, y: cy + h * 0.06),
            control: CGPoint(x: cx + w * 0.06, y: cy + h * 0.26)
        )

        return path
    }
}

struct CoquetteBowEmblem: View {
    var size: CGFloat = 26
    var tint: Color = AuraTheme.raspberryVelvet

    var body: some View {
        ZStack {
            CoquetteBowShape()
                .fill(
                    LinearGradient(
                        colors: [AuraTheme.coquettePink, tint],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            CoquetteBowShape()
                .stroke(Color.white.opacity(0.75), lineWidth: 0.8)
            Circle()
                .fill(AuraTheme.porcelainTop)
                .frame(width: size * 0.20, height: size * 0.20)
                .overlay(Circle().stroke(tint.opacity(0.6), lineWidth: 0.8))
                .offset(y: -size * 0.07)
        }
        .frame(width: size, height: size * 0.82)
        .accessibilityHidden(true)
    }
}

/// Four-pointed celestial sparkle diamond.
struct CelestialSparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        path.move(to: CGPoint(x: cx, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: cy), control: CGPoint(x: cx, y: cy))
        path.addQuadCurve(to: CGPoint(x: cx, y: rect.maxY), control: CGPoint(x: cx, y: cy))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: cy), control: CGPoint(x: cx, y: cy))
        path.addQuadCurve(to: CGPoint(x: cx, y: rect.minY), control: CGPoint(x: cx, y: cy))
        return path
    }
}

struct PorcelainCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    var highlightTint: Color = AuraTheme.petalSilk

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AuraTheme.pearlCardGradient)
                    .shadow(color: AuraTheme.coquettePink.opacity(0.13), radius: 18, x: 0, y: 10)
                    .shadow(color: AuraTheme.plumInk.opacity(0.03), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white, highlightTint.opacity(0.85), Color.white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.25
                    )
            )
    }
}

extension View {
    func porcelainCard(cornerRadius: CGFloat = 24, highlightTint: Color = AuraTheme.petalSilk) -> some View {
        modifier(PorcelainCardModifier(cornerRadius: cornerRadius, highlightTint: highlightTint))
    }
}

struct CoquettePressButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.965

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .brightness(configuration.isPressed ? 0.02 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.68), value: configuration.isPressed)
    }
}

// MARK: - 2. @Observable MotionManager Polling CMMotionManager Gyroscope Data

@MainActor
@Observable
final class MotionManager {
    /// Smoothed 3D tilt pitch in degrees (-22° ... +22°) driven by X-axis gyroscope rate.
    var pitchDegrees: Double = 0.0
    /// Smoothed 3D tilt roll in degrees (-22° ... +22°) driven by Y-axis gyroscope rate.
    var rollDegrees: Double = 0.0
    /// Continuous cumulative wheel rotation offset in degrees driven by Z-axis gyroscope rate.
    var wheelGyroRotationDegrees: Double = 0.0

    /// Instantaneous polled rotation rates (rad/s) for subtle telemetry display.
    var rawRateX: Double = 0.0
    var rawRateY: Double = 0.0
    var rawRateZ: Double = 0.0

    var isHardwareGyroAvailable: Bool = false
    var isPolling: Bool = false
    /// Provides a gentle celestial breeze when running in Simulator or on stationary desks.
    var celestialBreezeEnabled: Bool = true

    #if !os(macOS)
    @ObservationIgnored private let motionManager = CMMotionManager()
    #endif
    @ObservationIgnored private var pollTimer: Timer?
    @ObservationIgnored private var lastPollTimestamp: TimeInterval?
    @ObservationIgnored private var simulationPhase: Double = 0.0
    @ObservationIgnored private var yawAngularVelocity: Double = 0.0

    private let pollInterval: TimeInterval = 1.0 / 60.0
    private let maxTiltDegrees: Double = 22.0

    init() {
        #if !os(macOS)
        let available = motionManager.isGyroAvailable
        self.isHardwareGyroAvailable = available
        self.celestialBreezeEnabled = !available
        #else
        self.isHardwareGyroAvailable = false
        self.celestialBreezeEnabled = true
        #endif
    }

    func startPolling() {
        guard !isPolling else { return }
        lastPollTimestamp = ProcessInfo.processInfo.systemUptime

        #if !os(macOS)
        isHardwareGyroAvailable = motionManager.isGyroAvailable
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = pollInterval
            if !motionManager.isGyroActive {
                motionManager.startGyroUpdates()
            }
        }
        #endif

        isPolling = true
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollGyroscopeSample()
            }
        }
    }

    func pausePolling() {
        pollTimer?.invalidate()
        pollTimer = nil
        #if !os(macOS)
        if motionManager.isGyroActive {
            motionManager.stopGyroUpdates()
        }
        #endif
        isPolling = false
        lastPollTimestamp = nil
    }

    func recenterWheel() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.74)) {
            pitchDegrees = 0
            rollDegrees = 0
            wheelGyroRotationDegrees = 0
            yawAngularVelocity = 0
        }
    }

    private func pollGyroscopeSample() {
        let now = ProcessInfo.processInfo.systemUptime
        let dt = min(max(now - (lastPollTimestamp ?? now), 1.0 / 120.0), 0.05)
        lastPollTimestamp = now

        #if !os(macOS)
        if motionManager.isGyroAvailable, let gyroSample = motionManager.gyroData {
            let rx = gyroSample.rotationRate.x // rad/s around pitch axis
            let ry = gyroSample.rotationRate.y // rad/s around roll axis
            let rz = gyroSample.rotationRate.z // rad/s around yaw (wheel spin) axis

            rawRateX = rx
            rawRateY = ry
            rawRateZ = rz

            let radToDeg = 180.0 / Double.pi
            // Deadband filter to ignore microscopic sensor floor noise
            let filteredX = abs(rx) > 0.015 ? rx : 0.0
            let filteredY = abs(ry) > 0.015 ? ry : 0.0
            let filteredZ = abs(rz) > 0.015 ? rz : 0.0

            // Integrate gyro rotation rates with gentle spring-centering so tilt feels buoyant and drift-free
            let targetPitch = pitchDegrees + (filteredX * radToDeg * dt * 1.45)
            let targetRoll  = rollDegrees + (filteredY * radToDeg * dt * 1.45)

            let centeringDamping = pow(0.955, dt * 60.0)
            pitchDegrees = clamp(targetPitch * centeringDamping, min: -maxTiltDegrees, max: maxTiltDegrees)
            rollDegrees  = clamp(targetRoll * centeringDamping, min: -maxTiltDegrees, max: maxTiltDegrees)

            // Yaw integrates into fluid wheel rotation with satin inertia
            yawAngularVelocity = (yawAngularVelocity * pow(0.92, dt * 60.0)) - (filteredZ * radToDeg * 0.85)
            wheelGyroRotationDegrees += yawAngularVelocity * dt

            if celestialBreezeEnabled {
                simulationPhase += dt * 0.95
                pitchDegrees = clamp(pitchDegrees + sin(simulationPhase) * 0.12, min: -maxTiltDegrees, max: maxTiltDegrees)
                rollDegrees  = clamp(rollDegrees + cos(simulationPhase * 0.78) * 0.12, min: -maxTiltDegrees, max: maxTiltDegrees)
            }
            return
        }
        #endif

        if celestialBreezeEnabled {
            // Smooth Lissajous gyroscope simulation when hardware sensor is unavailable
            simulationPhase += dt * 1.05
            let simRx = cos(simulationPhase * 0.9) * 0.24
            let simRy = -sin(simulationPhase * 0.68) * 0.24
            let simRz = sin(simulationPhase * 0.35) * 0.14

            rawRateX = simRx
            rawRateY = simRy
            rawRateZ = simRz

            let desiredPitch = sin(simulationPhase * 0.9) * 7.5
            let desiredRoll  = cos(simulationPhase * 0.68) * 7.5
            pitchDegrees += (desiredPitch - pitchDegrees) * min(1.0, dt * 4.5)
            rollDegrees  += (desiredRoll - rollDegrees) * min(1.0, dt * 4.5)
            wheelGyroRotationDegrees += simRz * (180.0 / .pi) * dt * 0.45
        } else {
            // Smoothly settle back to rest when breeze is paused on non-gyro hardware
            rawRateX *= 0.9
            rawRateY *= 0.9
            rawRateZ *= 0.9
            pitchDegrees *= pow(0.90, dt * 60.0)
            rollDegrees  *= pow(0.90, dt * 60.0)
        }
    }

    private func clamp(_ value: Double, min lower: Double, max upper: Double) -> Double {
        Swift.min(Swift.max(value, lower), upper)
    }
}

// MARK: - 3. Smart Regex Date-Parser (Zero External Dependencies)

struct ParsedBirthDate: Equatable, Sendable {
    let components: DateComponents
    let resolvedDate: Date
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let hasExplicitYear: Bool
    let hasExplicitTime: Bool
    let matchedPatternLabel: String
    let note: String?

    var formattedDisplay: String {
        let monthNames = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ]
        let mName = monthNames[max(0, min(11, month - 1))]
        let yearPart = hasExplicitYear ? "\(year)" : "\(year) (inferred)"
        if hasExplicitTime {
            return String(format: "%@ %02d, %@ · %02d:%02d", mName, day, yearPart, hour, minute)
        } else {
            return String(format: "%@ %02d, %@", mName, day, yearPart)
        }
    }

    var compactComponentSummary: String {
        if hasExplicitTime {
            return String(format: "Y:%04d M:%02d D:%02d · %02d:%02d", year, month, day, hour, minute)
        } else {
            return String(format: "Y:%04d M:%02d D:%02d", year, month, day)
        }
    }
}

enum SmartDateParseOutcome: Equatable, Sendable {
    case empty
    case success(ParsedBirthDate)
    case invalid(reason: String)
}

enum SmartDateParser {
    // Month regex lexicon supporting standard names, abbreviations, and chaotic human typos
    private static let monthRegexCatalog: [(month: Int, pattern: String)] = [
        (1,  #"\bjan[uary]*\.?\b"#),
        (2,  #"\bfeb[ruay]*\.?\b"#),
        (3,  #"\bmar(?:ch)?\.?\b"#),
        (4,  #"\bapr[il]*\.?\b"#),
        (5,  #"\bmay\b"#),
        (6,  #"\bjun(?:e)?\.?\b"#),
        (7,  #"\bjul(?:y)?\.?\b"#),
        (8,  #"\baug[uest]*\.?\b"#),
        (9,  #"\bsep[tembr]*\.?\b"#),
        (10, #"\boct[ober]*\.?\b"#),
        (11, #"\bnov[embr]*\.?\b"#),
        (12, #"\bdec[embr]*\.?\b"#)
    ]

    // Spoken word-numbers & word-ordinals (ordered longest-first so compound words match cleanly)
    private static let wordDayReplacements: [(pattern: String, replacement: String)] = [
        (#"\bthirty[-\s]?first\b"#, "31"),
        (#"\bthirty[-\s]?one\b"#, "31"),
        (#"\bthirtieth\b"#, "30"),
        (#"\bthirty\b"#, "30"),
        (#"\btwenty[-\s]?ninth\b"#, "29"),
        (#"\btwenty[-\s]?nine\b"#, "29"),
        (#"\btwenty[-\s]?eighth\b"#, "28"),
        (#"\btwenty[-\s]?eight\b"#, "28"),
        (#"\btwenty[-\s]?seventh\b"#, "27"),
        (#"\btwenty[-\s]?seven\b"#, "27"),
        (#"\btwenty[-\s]?sixth\b"#, "26"),
        (#"\btwenty[-\s]?six\b"#, "26"),
        (#"\btwenty[-\s]?fifth\b"#, "25"),
        (#"\btwenty[-\s]?five\b"#, "25"),
        (#"\btwenty[-\s]?fourth\b"#, "24"),
        (#"\btwenty[-\s]?four\b"#, "24"),
        (#"\btwenty[-\s]?third\b"#, "23"),
        (#"\btwenty[-\s]?three\b"#, "23"),
        (#"\btwenty[-\s]?second\b"#, "22"),
        (#"\btwenty[-\s]?two\b"#, "22"),
        (#"\btwenty[-\s]?first\b"#, "21"),
        (#"\btwenty[-\s]?one\b"#, "21"),
        (#"\btwentieth\b"#, "20"),
        (#"\bnineteenth\b"#, "19"),
        (#"\beighteenth\b"#, "18"),
        (#"\bseventeenth\b"#, "17"),
        (#"\bsixteenth\b"#, "16"),
        (#"\bfifteenth\b"#, "15"),
        (#"\bfourteenth\b"#, "14"),
        (#"\bthirteenth\b"#, "13"),
        (#"\btwelfth\b"#, "12"),
        (#"\beleventh\b"#, "11"),
        (#"\btenth\b"#, "10"),
        (#"\bninth\b"#, "9"),
        (#"\beighth\b"#, "8"),
        (#"\bseventh\b"#, "7"),
        (#"\bsixth\b"#, "6"),
        (#"\bfifth\b"#, "5"),
        (#"\bfourth\b"#, "4"),
        (#"\bthird\b"#, "3"),
        (#"\bsecond\b"#, "2"),
        (#"\bfirst\b"#, "1")
    ]

    static let chaoticExamples: [String] = [
        "🌸 14th of feb, '99 around 11:15pm!!",
        "uhh maybe oct 31st 2001 @ midnight?",
        "bday: 23/08/2001 noon ✨",
        "1998.05.02 06:30",
        "twenty-second of nov '97"
    ]

    /// Deterministically translates chaotic free-form text into validated `DateComponents`.
    static func parse(_ rawInput: String) -> SmartDateParseOutcome {
        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        // Step 1: Lowercase, normalize ISO 'T' separator & curly apostrophes, convert spoken ordinals
        var working = trimmed
            .lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "‘", with: "'")
            .replacingOccurrences(of: "—", with: "-")
            .replacingOccurrences(of: "–", with: "-")

        working = regexReplace(in: working, pattern: #"(\d)t(\d)"#, template: "$1 $2")

        for item in wordDayReplacements {
            working = regexReplace(in: working, pattern: item.pattern, template: item.replacement)
        }

        // Strip ordinal suffixes on numbers ("14th" -> "14", "1st" -> "1", "2nd" -> "2", "3rd" -> "3")
        working = regexReplace(in: working, pattern: #"\b(\d{1,2})\s*(?:st|nd|rd|th)\b"#, template: "$1")

        // Step 2: Extract optional Time-of-Birth FIRST and strip it from `working` so clock digits
        // never masquerade as day or year tokens.
        var parsedHour = 12
        var parsedMinute = 0
        var hasExplicitTime = false

        if let midnightRange = firstMatchRange(in: working, pattern: #"\b(?:midnight|12\s*:\s*00\s*a\.?m\.?|12\s*a\.?m\.?)\b"#) {
            parsedHour = 0
            parsedMinute = 0
            hasExplicitTime = true
            working.replaceSubrange(midnightRange, with: " ")
        } else if let noonRange = firstMatchRange(in: working, pattern: #"\b(?:noon|midday|12\s*:\s*00\s*p\.?m\.?|12\s*p\.?m\.?)\b"#) {
            parsedHour = 12
            parsedMinute = 0
            hasExplicitTime = true
            working.replaceSubrange(noonRange, with: " ")
        } else if let amPmMatch = firstCaptures(
            in: working,
            pattern: #"(?:@\s*|\bat\s+|\baround\s+)?\b(1[0-2]|0?[1-9])(?:[:.h]([0-5]\d))?\s*(a\.?m\.?|p\.?m\.?)\b"#
        ) {
            if let h = Int(amPmMatch.groups[0]) {
                let m = amPmMatch.groups[1].isEmpty ? 0 : (Int(amPmMatch.groups[1]) ?? 0)
                let meridiem = amPmMatch.groups[2].hasPrefix("p")
                var resolved24 = h % 12
                if meridiem { resolved24 += 12 }
                parsedHour = resolved24
                parsedMinute = m
                hasExplicitTime = true
                working.replaceSubrange(amPmMatch.fullRange, with: " ")
            }
        } else if let twentyFourMatch = firstCaptures(
            in: working,
            pattern: #"(?:@\s*|\bat\s+|\baround\s+|\bt\s*)?\b([01]?\d|2[0-3])[:h]([0-5]\d)(?::[0-5]\d)?\b"#
        ) {
            if let h = Int(twentyFourMatch.groups[0]), let m = Int(twentyFourMatch.groups[1]) {
                parsedHour = h
                parsedMinute = m
                hasExplicitTime = true
                working.replaceSubrange(twentyFourMatch.fullRange, with: " ")
            }
        }

        // Remove conversational filler words while preserving structure
        working = regexReplace(
            in: working,
            pattern: #"\b(?:born|bday|birthday|dob|on|the|of|in|around|maybe|approx|uh+|um+|at)\b"#,
            template: " "
        )

        // Step 3: Multi-stage Regex Date Resolution Cascade

        // Stage A: Compact 8-digit YYYYMMDD (e.g., "19990214")
        if let m = firstCaptures(in: working, pattern: #"\b((?:19|20)\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\b"#),
           let y = Int(m.groups[0]), let mo = Int(m.groups[1]), let d = Int(m.groups[2]) {
            return buildValidatedOutcome(
                year: y, month: mo, day: d,
                hour: parsedHour, minute: parsedMinute,
                hasExplicitYear: true, hasExplicitTime: hasExplicitTime,
                patternLabel: "Compact ISO-8", note: nil
            )
        }

        // Stage B: Year-First Numeric YYYY[-/. ]MM[-/. ]DD (e.g., "1998.05.02", "2001-10-31")
        if let m = firstCaptures(in: working, pattern: #"\b((?:18|19|20)\d{2})\s*[-./\s]\s*(0?[1-9]|1[0-2])\s*[-./\s]\s*(0?[1-9]|[12]\d|3[01])\b"#),
           let y = Int(m.groups[0]), let mo = Int(m.groups[1]), let d = Int(m.groups[2]) {
            return buildValidatedOutcome(
                year: y, month: mo, day: d,
                hour: parsedHour, minute: parsedMinute,
                hasExplicitYear: true, hasExplicitTime: hasExplicitTime,
                patternLabel: "ISO Numeric", note: nil
            )
        }

        // Stage C: Named Month Detection (handles "14 feb '99", "february 14, 1999", "1999 feb 14")
        for entry in monthRegexCatalog {
            if let monthRange = firstMatchRange(in: working, pattern: entry.pattern) {
                let prefix = String(working[..<monthRange.lowerBound])
                let suffix = String(working[monthRange.upperBound...])

                // Case C1: Year before month, day after month ("1999 feb 14")
                if let yCap = firstCaptures(in: prefix, pattern: #"\b((?:18|19|20)\d{2})\s*$"#),
                   let dCap = firstCaptures(in: suffix, pattern: #"^\s*[,.-]?\s*(\d{1,2})\b"#),
                   let y = Int(yCap.groups[0]), let d = Int(dCap.groups[0]) {
                    return buildValidatedOutcome(
                        year: y, month: entry.month, day: d,
                        hour: parsedHour, minute: parsedMinute,
                        hasExplicitYear: true, hasExplicitTime: hasExplicitTime,
                        patternLabel: "Year · Month · Day", note: nil
                    )
                }

                // Case C2: Day before month ("14 feb '99", "14 feb 1999", "14 feb")
                if let dCap = firstCaptures(in: prefix, pattern: #"(\d{1,2})\s*[,.-]?\s*$"#),
                   let d = Int(dCap.groups[0]), (1...31).contains(d) {
                    if let yCap = firstCaptures(in: suffix, pattern: #"^\s*[,./-]?\s*'?\s*(\d{4}|\d{2})\b"#),
                       let rawY = Int(yCap.groups[0]) {
                        let resolvedY = normalizeYear(rawY)
                        return buildValidatedOutcome(
                            year: resolvedY, month: entry.month, day: d,
                            hour: parsedHour, minute: parsedMinute,
                            hasExplicitYear: true, hasExplicitTime: hasExplicitTime,
                            patternLabel: "Day · Month · Year",
                            note: rawY < 100 ? "Expanded 2-digit year '\(String(format: "%02d", rawY)) → \(resolvedY)" : nil
                        )
                    } else {
                        return buildValidatedOutcome(
                            year: 2000, month: entry.month, day: d,
                            hour: parsedHour, minute: parsedMinute,
                            hasExplicitYear: false, hasExplicitTime: hasExplicitTime,
                            patternLabel: "Day · Month",
                            note: "Leap-safe reference year 2000 inferred"
                        )
                    }
                }

                // Case C3: Month followed by Day and optional Year ("feb 14, '99", "october 31 2001")
                if let dyCap = firstCaptures(
                    in: suffix,
                    pattern: #"^\s*[,./-]?\s*(\d{1,2})(?:\s*[,./\s-]\s*'?\s*(\d{4}|\d{2})\b)?"#
                ), let d = Int(dyCap.groups[0]) {
                    if !dyCap.groups[1].isEmpty, let rawY = Int(dyCap.groups[1]) {
                        let resolvedY = normalizeYear(rawY)
                        return buildValidatedOutcome(
                            year: resolvedY, month: entry.month, day: d,
                            hour: parsedHour, minute: parsedMinute,
                            hasExplicitYear: true, hasExplicitTime: hasExplicitTime,
                            patternLabel: "Month · Day · Year",
                            note: rawY < 100 ? "Expanded 2-digit year '\(String(format: "%02d", rawY)) → \(resolvedY)" : nil
                        )
                    } else {
                        return buildValidatedOutcome(
                            year: 2000, month: entry.month, day: d,
                            hour: parsedHour, minute: parsedMinute,
                            hasExplicitYear: false, hasExplicitTime: hasExplicitTime,
                            patternLabel: "Month · Day",
                            note: "Leap-safe reference year 2000 inferred"
                        )
                    }
                }
            }
        }

        // Stage D: Delimited Numeric Dates ("23/08/2001", "02/14/99", "5-4-1998", "11/22")
        if let numCap = firstCaptures(
            in: working,
            pattern: #"\b(\d{1,2})\s*[/.-]\s*(\d{1,2})(?:\s*[/.,\s-]\s*'?\s*(\d{4}|\d{2})\b)?"#
        ), let firstNum = Int(numCap.groups[0]), let secondNum = Int(numCap.groups[1]) {
            let hasYear = !numCap.groups[2].isEmpty
            let rawYear = Int(numCap.groups[2]) ?? 2000
            let resolvedYear = hasYear ? normalizeYear(rawYear) : 2000

            let resolvedMonth: Int
            let resolvedDay: Int
            var disambiguationNote: String? = nil

            if firstNum > 12 && (1...12).contains(secondNum) {
                resolvedDay = firstNum
                resolvedMonth = secondNum
                disambiguationNote = "Auto-detected DD/MM order (\(firstNum) > 12)"
            } else if secondNum > 12 && (1...12).contains(firstNum) {
                resolvedMonth = firstNum
                resolvedDay = secondNum
            } else if (1...12).contains(firstNum) && (1...12).contains(secondNum) {
                resolvedMonth = firstNum
                resolvedDay = secondNum
                if firstNum != secondNum {
                    disambiguationNote = "Interpreted as MM/DD (\(String(format: "%02d/%02d", firstNum, secondNum)))"
                }
            } else {
                return .invalid(reason: "Month must be 1–12 and day must fit calendar month ♡")
            }

            return buildValidatedOutcome(
                year: resolvedYear, month: resolvedMonth, day: resolvedDay,
                hour: parsedHour, minute: parsedMinute,
                hasExplicitYear: hasYear, hasExplicitTime: hasExplicitTime,
                patternLabel: "Numeric Delimited",
                note: disambiguationNote
            )
        }

        return .invalid(reason: "Try e.g. \"14th of feb '99\", \"oct 31 2001\", or \"23/08/2001\" ♡")
    }

    // MARK: Regex & Validation Helpers

    private static func normalizeYear(_ raw: Int) -> Int {
        guard raw < 100 else { return raw }
        return raw <= 29 ? (2000 + raw) : (1900 + raw)
    }

    private static func buildValidatedOutcome(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        hasExplicitYear: Bool,
        hasExplicitTime: Bool,
        patternLabel: String,
        note: String?
    ) -> SmartDateParseOutcome {
        guard (1800...2150).contains(year) else {
            return .invalid(reason: "Year \(year) is outside ephemeris range (1800–2150) ♡")
        }
        guard (1...12).contains(month) else {
            return .invalid(reason: "Month \(month) isn't between 1 and 12 ♡")
        }
        let maxDay = daysInMonth(month: month, year: year)
        guard (1...maxDay).contains(day) else {
            let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            return .invalid(reason: "\(monthNames[month - 1]) \(year) only has \(maxDay) days ♡")
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        guard let date = calendar.date(from: components) else {
            return .invalid(reason: "Could not construct calendar date ♡")
        }

        return .success(
            ParsedBirthDate(
                components: components,
                resolvedDate: date,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                hasExplicitYear: hasExplicitYear,
                hasExplicitTime: hasExplicitTime,
                matchedPatternLabel: patternLabel,
                note: note
            )
        )
    }

    static func daysInMonth(month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: return 31
        case 4, 6, 9, 11: return 30
        case 2:
            let isLeap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            return isLeap ? 29 : 28
        default: return 30
        }
    }

    private struct RegexCaptureResult {
        let fullRange: Range<String.Index>
        let groups: [String]
    }

    private static func regexReplace(in text: String, pattern: String, template: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return text
        }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.stringByReplacingMatches(in: text, options: [], range: nsRange, withTemplate: template)
    }

    private static func firstMatchRange(in text: String, pattern: String) -> Range<String.Index>? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange) else {
            return nil
        }
        return Range(match.range, in: text)
    }

    private static func firstCaptures(in text: String, pattern: String) -> RegexCaptureResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: nsRange),
              let fullRange = Range(match.range(at: 0), in: text) else {
            return nil
        }
        var groups: [String] = []
        for idx in 1..<match.numberOfRanges {
            let r = match.range(at: idx)
            if r.location != NSNotFound, let swiftRange = Range(r, in: text) {
                groups.append(String(text[swiftRange]))
            } else {
                groups.append("")
            }
        }
        return RegexCaptureResult(fullRange: fullRange, groups: groups)
    }
}

// MARK: - 4. Deterministic Astrological & Synastry Engine

enum AstroElement: String, CaseIterable, Codable, Sendable {
    case fire  = "Fire"
    case earth = "Earth"
    case air   = "Air"
    case water = "Water"

    var coquetteLabel: String {
        switch self {
        case .fire:  return "Velvet Flame"
        case .earth: return "Porcelain Garden"
        case .air:   return "Chiffon Breeze"
        case .water: return "Rosewater Tide"
        }
    }

    var symbol: String {
        switch self {
        case .fire:  return "🜂"
        case .earth: return "🜃"
        case .air:   return "🜁"
        case .water: return "🜄"
        }
    }

    var accentColor: Color {
        switch self {
        case .fire:  return Color(red: 0.855, green: 0.416, blue: 0.506) // Rose-Coral Flame
        case .earth: return Color(red: 0.690, green: 0.533, blue: 0.486) // Warm Cashmere Clay
        case .air:   return Color(red: 0.635, green: 0.525, blue: 0.745) // Lavender Silk
        case .water: return Color(red: 0.482, green: 0.620, blue: 0.753) // Periwinkle Mist
        }
    }
}

enum AstroModality: String, CaseIterable, Codable, Sendable {
    case cardinal = "Cardinal"
    case fixed    = "Fixed"
    case mutable  = "Mutable"

    var essence: String {
        switch self {
        case .cardinal: return "Spark & Overture"
        case .fixed:    return "Devotion & Sanctuary"
        case .mutable:  return "Grace & Metamorphosis"
        }
    }
}

enum PlanetaryRuler: String, CaseIterable, Codable, Sendable {
    case mars    = "Mars"
    case venus   = "Venus"
    case mercury = "Mercury"
    case moon    = "Moon"
    case sun     = "Sun"
    case pluto   = "Pluto"
    case jupiter = "Jupiter"
    case saturn  = "Saturn"
    case uranus  = "Uranus"
    case neptune = "Neptune"

    var glyph: String {
        switch self {
        case .mars:    return "♂\u{FE0E}"
        case .venus:   return "♀\u{FE0E}"
        case .mercury: return "☿\u{FE0E}"
        case .moon:    return "☽\u{FE0E}"
        case .sun:     return "☉\u{FE0E}"
        case .pluto:   return "♇\u{FE0E}"
        case .jupiter: return "♃\u{FE0E}"
        case .saturn:  return "♄\u{FE0E}"
        case .uranus:  return "♅\u{FE0E}"
        case .neptune: return "♆\u{FE0E}"
        }
    }
}

enum ZodiacSign: String, CaseIterable, Codable, Identifiable, Sendable {
    case aries       = "Aries"
    case taurus      = "Taurus"
    case gemini      = "Gemini"
    case cancer      = "Cancer"
    case leo         = "Leo"
    case virgo       = "Virgo"
    case libra       = "Libra"
    case scorpio     = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn   = "Capricorn"
    case aquarius    = "Aquarius"
    case pisces      = "Pisces"

    var id: String { rawValue }

    /// Index around the 360° tropical ecliptic wheel (0 = Aries 0° ... 11 = Pisces 330°).
    var wheelIndex: Int {
        switch self {
        case .aries:       return 0
        case .taurus:      return 1
        case .gemini:      return 2
        case .cancer:      return 3
        case .leo:         return 4
        case .virgo:       return 5
        case .libra:       return 6
        case .scorpio:     return 7
        case .sagittarius: return 8
        case .capricorn:   return 9
        case .aquarius:    return 10
        case .pisces:      return 11
        }
    }

    var startDegree: Double { Double(wheelIndex) * 30.0 }

    /// Text-presentation Unicode selector (\u{FE0E}) ensures crisp editorial astrological glyphs on iOS.
    var glyph: String {
        switch self {
        case .aries:       return "\u{2648}\u{FE0E}"
        case .taurus:      return "\u{2649}\u{FE0E}"
        case .gemini:      return "\u{264A}\u{FE0E}"
        case .cancer:      return "\u{264B}\u{FE0E}"
        case .leo:         return "\u{264C}\u{FE0E}"
        case .virgo:       return "\u{264D}\u{FE0E}"
        case .libra:       return "\u{264E}\u{FE0E}"
        case .scorpio:     return "\u{264F}\u{FE0E}"
        case .sagittarius: return "\u{2650}\u{FE0E}"
        case .capricorn:   return "\u{2651}\u{FE0E}"
        case .aquarius:    return "\u{2652}\u{FE0E}"
        case .pisces:      return "\u{2653}\u{FE0E}"
        }
    }

    var element: AstroElement {
        switch self {
        case .aries, .leo, .sagittarius:    return .fire
        case .taurus, .virgo, .capricorn:   return .earth
        case .gemini, .libra, .aquarius:    return .air
        case .cancer, .scorpio, .pisces:    return .water
        }
    }

    var modality: AstroModality {
        switch self {
        case .aries, .cancer, .libra, .capricorn:       return .cardinal
        case .taurus, .leo, .scorpio, .aquarius:        return .fixed
        case .gemini, .virgo, .sagittarius, .pisces:    return .mutable
        }
    }

    var ruler: PlanetaryRuler {
        switch self {
        case .aries:       return .mars
        case .taurus:      return .venus
        case .gemini:      return .mercury
        case .cancer:      return .moon
        case .leo:         return .sun
        case .virgo:       return .mercury
        case .libra:       return .venus
        case .scorpio:     return .pluto
        case .sagittarius: return .jupiter
        case .capricorn:   return .saturn
        case .aquarius:    return .uranus
        case .pisces:      return .neptune
        }
    }

    var coquetteArchetype: String {
        switch self {
        case .aries:       return "Crimson Ribbon Muse"
        case .taurus:      return "Porcelain Rose"
        case .gemini:      return "Twin Silk Sonnet"
        case .cancer:      return "Moonlit Pearl"
        case .leo:         return "Gilded Tiara"
        case .virgo:       return "Pressed Lace Botanist"
        case .libra:       return "Blush Satin Swan"
        case .scorpio:     return "Velvet Lock & Key"
        case .sagittarius: return "Starlit Arrow"
        case .capricorn:   return "Cameo Heirloom"
        case .aquarius:    return "Crystal Chalice"
        case .pisces:      return "Dreamer in Tulle"
        }
    }

    var dateSpanLabel: String {
        switch self {
        case .aries:       return "Mar 21 – Apr 19"
        case .taurus:      return "Apr 20 – May 20"
        case .gemini:      return "May 21 – Jun 20"
        case .cancer:      return "Jun 21 – Jul 22"
        case .leo:         return "Jul 23 – Aug 22"
        case .virgo:       return "Aug 23 – Sep 22"
        case .libra:       return "Sep 23 – Oct 22"
        case .scorpio:     return "Oct 23 – Nov 21"
        case .sagittarius: return "Nov 22 – Dec 21"
        case .capricorn:   return "Dec 22 – Jan 19"
        case .aquarius:    return "Jan 20 – Feb 18"
        case .pisces:      return "Feb 19 – Mar 20"
        }
    }

    /// Normalized star coordinates (0...1, 0...1) and line edges for authentic constellation rendering.
    var constellationPattern: (stars: [(Double, Double)], edges: [(Int, Int)]) {
        switch self {
        case .aries:
            return ([(0.18, 0.36), (0.48, 0.44), (0.74, 0.58), (0.84, 0.74)], [(0, 1), (1, 2), (2, 3)])
        case .taurus:
            return ([(0.16, 0.24), (0.42, 0.46), (0.20, 0.52), (0.56, 0.56), (0.84, 0.78)], [(0, 1), (2, 1), (1, 3), (3, 4)])
        case .gemini:
            return ([(0.26, 0.20), (0.70, 0.22), (0.30, 0.52), (0.68, 0.54), (0.28, 0.82), (0.72, 0.82)], [(0, 1), (0, 2), (2, 4), (1, 3), (3, 5), (2, 3)])
        case .cancer:
            return ([(0.24, 0.24), (0.50, 0.50), (0.78, 0.28), (0.52, 0.82)], [(0, 1), (2, 1), (1, 3)])
        case .leo:
            return ([(0.66, 0.22), (0.48, 0.20), (0.38, 0.38), (0.52, 0.52), (0.22, 0.72), (0.78, 0.74)], [(0, 1), (1, 2), (2, 3), (3, 5), (5, 4), (4, 3)])
        case .virgo:
            return ([(0.22, 0.30), (0.44, 0.46), (0.66, 0.32), (0.54, 0.68), (0.82, 0.76), (0.26, 0.78)], [(0, 1), (1, 2), (1, 3), (3, 4), (3, 5)])
        case .libra:
            return ([(0.50, 0.22), (0.24, 0.50), (0.76, 0.50), (0.34, 0.80), (0.68, 0.80)], [(0, 1), (0, 2), (1, 2), (1, 3), (2, 4)])
        case .scorpio:
            return ([(0.22, 0.26), (0.36, 0.34), (0.50, 0.48), (0.58, 0.68), (0.74, 0.80), (0.84, 0.66)], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)])
        case .sagittarius:
            return ([(0.24, 0.68), (0.46, 0.46), (0.76, 0.24), (0.48, 0.26), (0.72, 0.52)], [(0, 1), (1, 2), (3, 1), (1, 4), (3, 2), (4, 2)])
        case .capricorn:
            return ([(0.20, 0.34), (0.52, 0.40), (0.82, 0.30), (0.64, 0.76), (0.36, 0.68)], [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)])
        case .aquarius:
            return ([(0.18, 0.34), (0.38, 0.24), (0.56, 0.42), (0.78, 0.32), (0.44, 0.72), (0.70, 0.76)], [(0, 1), (1, 2), (2, 3), (2, 4), (4, 5)])
        case .pisces:
            return ([(0.22, 0.26), (0.34, 0.52), (0.50, 0.78), (0.68, 0.54), (0.80, 0.28)], [(0, 1), (1, 2), (2, 3), (3, 4)])
        }
    }

    static func from(month: Int, day: Int) -> ZodiacSign {
        switch (month, day) {
        case (3, 21...31), (4, 1...19):   return .aries
        case (4, 20...30), (5, 1...20):   return .taurus
        case (5, 21...31), (6, 1...20):   return .gemini
        case (6, 21...30), (7, 1...22):   return .cancer
        case (7, 23...31), (8, 1...22):   return .leo
        case (8, 23...31), (9, 1...22):   return .virgo
        case (9, 23...30), (10, 1...22):  return .libra
        case (10, 23...31), (11, 1...21): return .scorpio
        case (11, 22...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19):  return .capricorn
        case (1, 20...31), (2, 1...18):   return .aquarius
        default:                          return .pisces
        }
    }
}

struct AstroProfile: Equatable, Codable, Sendable {
    var name: String
    var rawDateInput: String
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var hasExplicitYear: Bool
    var hasExplicitTime: Bool

    var sign: ZodiacSign {
        ZodiacSign.from(month: month, day: day)
    }

    /// Deterministic solar position within the sign (0°..<30°) and full ecliptic longitude (0°..<360°).
    var degreeInSign: Double {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let signSpan: ((Int, Int), (Int, Int)) = {
            switch sign {
            case .aries:       return ((3, 21), (4, 19))
            case .taurus:      return ((4, 20), (5, 20))
            case .gemini:      return ((5, 21), (6, 20))
            case .cancer:      return ((6, 21), (7, 22))
            case .leo:         return ((7, 23), (8, 22))
            case .virgo:       return ((8, 23), (9, 22))
            case .libra:       return ((9, 23), (10, 22))
            case .scorpio:     return ((10, 23), (11, 21))
            case .sagittarius: return ((11, 22), (12, 21))
            case .capricorn:   return ((12, 22), (1, 19))
            case .aquarius:    return ((1, 20), (2, 18))
            case .pisces:      return ((2, 19), (3, 20))
            }
        }()

        let startYear = (sign == .capricorn && month == 1) ? (year - 1) : year
        let endYear   = (sign == .capricorn && month == 12) ? (year + 1) : year

        let startDate = calendar.date(from: DateComponents(year: startYear, month: signSpan.0.0, day: signSpan.0.1, hour: 0, minute: 0)) ?? Date()
        let endDate   = calendar.date(from: DateComponents(year: endYear, month: signSpan.1.0, day: signSpan.1.1, hour: 23, minute: 59)) ?? Date()
        let birthDate = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? startDate

        let totalSeconds = max(86_400.0, endDate.timeIntervalSince(startDate))
        let elapsed = min(max(0.0, birthDate.timeIntervalSince(startDate)), totalSeconds)
        return min(29.95, (elapsed / totalSeconds) * 30.0)
    }

    var eclipticLongitude: Double {
        sign.startDegree + degreeInSign
    }

    /// Triplicity Decan (1, 2, or 3) and sub-ruling planet.
    var decan: (number: Int, subRuler: PlanetaryRuler) {
        let idx = min(2, max(0, Int(degreeInSign / 10.0)))
        let sameElementIndex = (sign.wheelIndex + idx * 4) % 12
        let subSign = ZodiacSign.allCases[sameElementIndex]
        return (idx + 1, subSign.ruler)
    }

    var formattedDateLabel: String {
        let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let m = monthNames[max(0, min(11, month - 1))]
        if hasExplicitTime {
            return String(format: "%@ %d, %d · %02d:%02d", m, day, year, hour, minute)
        }
        return "\(m) \(day), \(year)"
    }
}

enum AstrologicalAspect: String, Codable, Sendable {
    case conjunction = "Conjunction"
    case semiSextile = "Semi-Sextile"
    case sextile     = "Sextile"
    case square      = "Square"
    case trine       = "Trine"
    case quincunx    = "Quincunx"
    case opposition  = "Opposition"

    var nominalAngle: Int {
        switch self {
        case .conjunction: return 0
        case .semiSextile: return 30
        case .sextile:     return 60
        case .square:      return 90
        case .trine:       return 120
        case .quincunx:    return 150
        case .opposition:  return 180
        }
    }

    var glyph: String {
        switch self {
        case .conjunction: return "☌"
        case .semiSextile: return "⚺"
        case .sextile:     return "⚹"
        case .square:      return "□"
        case .trine:       return "△"
        case .quincunx:    return "⚻"
        case .opposition:  return "☍"
        }
    }

    var coquetteSubtitle: String {
        switch self {
        case .conjunction: return "Twin Heartbeat · Unified Mirror"
        case .semiSextile: return "Next-Door Whisper · Gentle Curiosity"
        case .sextile:     return "Champagne Spark · Effortless Rapport"
        case .square:      return "Velvet Friction · Magnetic Growth"
        case .trine:       return "Golden Ribbon · Natural Grace"
        case .quincunx:    return "Enigmatic Lace · Soul Calibration"
        case .opposition:  return "Celestial Counterpart · Polar Pull"
        }
    }

    var chordColor: Color {
        switch self {
        case .trine, .conjunction: return AuraTheme.raspberryVelvet
        case .sextile:             return AuraTheme.coquettePink
        case .opposition:          return Color(red: 0.620, green: 0.435, blue: 0.745)
        case .square:              return Color(red: 0.835, green: 0.467, blue: 0.510)
        case .semiSextile, .quincunx: return AuraTheme.gildedRose
        }
    }

    static func fromSignDistance(_ steps: Int) -> AstrologicalAspect {
        switch steps {
        case 0: return .conjunction
        case 1: return .semiSextile
        case 2: return .sextile
        case 3: return .square
        case 4: return .trine
        case 5: return .quincunx
        default: return .opposition
        }
    }
}

struct SynastryReport: Equatable, Sendable {
    let profileA: AstroProfile
    let profileB: AstroProfile
    let overallScore: Int
    let elementalScore: Int
    let modalityScore: Int
    let aspectScore: Int
    let planetaryDecanScore: Int
    let aspect: AstrologicalAspect
    let exactAngularSeparation: Double
    let degreeOrbDelta: Double
    let ribbonTier: String
    let elementalHeadline: String
    let elementalProse: String
    let modalityHeadline: String
    let modalityProse: String
    let strengths: [String]
    let coquetteRitual: String
}

enum SynastryEngine {
    /// Pure, deterministic synastry calculation symmetric in `(profileA, profileB)`.
    static func evaluate(profileA: AstroProfile, profileB: AstroProfile) -> SynastryReport {
        let signA = profileA.sign
        let signB = profileB.sign

        // 1. Sign & Degree Aspect Geometry
        let rawSignDiff = abs(signA.wheelIndex - signB.wheelIndex)
        let signDistance = min(rawSignDiff, 12 - rawSignDiff) // 0...6
        let aspect = AstrologicalAspect.fromSignDistance(signDistance)

        let rawAngleDiff = abs(profileA.eclipticLongitude - profileB.eclipticLongitude)
        let exactAngle = rawAngleDiff > 180.0 ? (360.0 - rawAngleDiff) : rawAngleDiff
        let orbDelta = abs(exactAngle - Double(aspect.nominalAngle)) // 0°...30°

        let baseAspectScore: Double = {
            switch aspect {
            case .trine:       return 95.0
            case .sextile:     return 90.0
            case .conjunction: return signA.modality == .fixed ? 87.0 : 91.0
            case .opposition:  return 84.0
            case .square:      return 71.0
            case .semiSextile: return 74.0
            case .quincunx:    return 69.0
            }
        }()
        // Tight intra-sign degree alignment rewards exact geometric resonance (+/- 5 pts)
        let orbBonus = (15.0 - min(30.0, orbDelta)) / 3.0
        let computedAspectScore = clampScore(baseAspectScore + orbBonus)

        // 2. Elemental Chemistry Matrix
        let elemOutcome = evaluateElementalPair(signA.element, signB.element)
        let computedElementalScore = clampScore(elemOutcome.score + orbBonus * 0.45)

        // 3. Modality Cadence Matrix
        let modOutcome = evaluateModalityPair(signA.modality, signB.modality, sameSign: signA == signB)
        let computedModalityScore = clampScore(modOutcome.score + orbBonus * 0.35)

        // 4. Planetary Ruler & Decan Sub-Ruler Affinity
        let rulerBase = evaluatePlanetaryPair(signA.ruler, signB.ruler)
        let decanA = profileA.decan
        let decanB = profileB.decan
        let subRulerAffinity = evaluatePlanetaryPair(decanA.subRuler, decanB.subRuler)
        let computedPlanetaryScore = clampScore(rulerBase * 0.68 + subRulerAffinity * 0.32)

        // Weighted Deterministic Composite Score
        let weightedRaw =
            Double(computedElementalScore) * 0.34 +
            Double(computedAspectScore)    * 0.27 +
            Double(computedModalityScore)  * 0.21 +
            Double(computedPlanetaryScore) * 0.18

        let overall = max(48, min(99, Int(weightedRaw.rounded())))

        let tier: String = {
            switch overall {
            case 91...100: return "Soulbound Couture"
            case 83...90:  return "Celestial Satin"
            case 75...82:  return "Rosewater Alchemy"
            case 67...74:  return "Opposites in Lace"
            default:       return "Poetic Tension"
            }
        }()

        let strengths: [String] = [
            "\(signA.rawValue) (\(signA.glyph)) & \(signB.rawValue) (\(signB.glyph)) form a \(aspect.rawValue) (\(String(format: "%.1f°", exactAngle))), weaving \(aspect.coquetteSubtitle.lowercased()).",
            "\(signA.ruler.rawValue) \(signA.ruler.glyph) meets \(signB.ruler.rawValue) \(signB.ruler.glyph), harmonizing Decan \(decanA.number) & Decan \(decanB.number) undertones.",
            "\(elemOutcome.shortHighlight)"
        ]

        let ritual = ritualRecommendation(for: signA.element, and: signB.element, aspect: aspect)

        return SynastryReport(
            profileA: profileA,
            profileB: profileB,
            overallScore: overall,
            elementalScore: computedElementalScore,
            modalityScore: computedModalityScore,
            aspectScore: computedAspectScore,
            planetaryDecanScore: computedPlanetaryScore,
            aspect: aspect,
            exactAngularSeparation: exactAngle,
            degreeOrbDelta: orbDelta,
            ribbonTier: tier,
            elementalHeadline: elemOutcome.headline,
            elementalProse: elemOutcome.prose,
            modalityHeadline: modOutcome.headline,
            modalityProse: modOutcome.prose,
            strengths: strengths,
            coquetteRitual: ritual
        )
    }

    private static func clampScore(_ raw: Double) -> Int {
        max(45, min(99, Int(raw.rounded())))
    }

    private static func evaluateElementalPair(
        _ a: AstroElement,
        _ b: AstroElement
    ) -> (score: Double, headline: String, prose: String, shortHighlight: String) {
        let sorted = [a.rawValue, b.rawValue].sorted().joined(separator: "+")
        switch sorted {
        case "Fire+Fire":
            return (
                92,
                "Twin Velvet Flame",
                "Two radiant Fire signs ignite immediate warmth, playful candor, and celebratory momentum without needing translation.",
                "Unfiltered mutual enthusiasm keeps romance luminous and spontaneous."
            )
        case "Earth+Earth":
            return (
                93,
                "Porcelain Sanctuary",
                "Shared Earth creates tactile devotion, heirloom loyalty, and a serene sanctuary built on small daily rituals.",
                "Grounded sensory harmony turns everyday moments into lasting luxury."
            )
        case "Air+Air":
            return (
                92,
                "Twin Chiffon Sonnet",
                "Two Air signs converse in effortless shorthand—late-night wit, aesthetic curiosity, and weightless intellectual grace.",
                "Sparkling dialogue and shared curiosity keep both minds enchanted."
            )
        case "Water+Water":
            return (
                94,
                "Moonlit Rosewater Mirror",
                "Shared Water attunes intuitively to unspoken moods, creating poetic tenderness and deep emotional safety.",
                "Soul-deep empathy lets both hearts feel cherished without pretense."
            )
        case "Air+Fire":
            return (
                91,
                "Champagne Effervescence",
                "Air fans Fire's brilliance while Fire warms Air's imagination—an uplifting, socially magnetic duet.",
                "Playful banter fuels bold shared adventures and creative sparks."
            )
        case "Earth+Water":
            return (
                93,
                "Conservatory & Rain",
                "Water softens Earth into bloom while Earth holds a porcelain vessel for Water's deepest feelings.",
                "Tender emotional depth meets steady, protective follow-through."
            )
        case "Fire+Water":
            return (
                75,
                "Rose Steam & Velvet",
                "Passion meets intuition: when Fire slows down to listen and Water dares to glow openly, alchemy unfolds.",
                "High-contrast emotional warmth creates unforgettable cinematic pull."
            )
        case "Earth+Fire":
            return (
                76,
                "Kiln & Porcelain",
                "Fire inspires audacity while Earth sculpts dreams into tangible beauty—a pairing of muse and artisan.",
                "Visionary drive pairs with patient craft to build real legacies."
            )
        case "Air+Earth":
            return (
                74,
                "Silk Ribbon & Cameo",
                "Air brings fresh perspective and whimsy while Earth anchors ideas in sensory elegance and calm.",
                "Thoughtful perspective balances practical grace when both stay curious."
            )
        default: // Air+Water
            return (
                77,
                "Cloud & Pearl Mist",
                "Dreamy lyricism meets gentle analysis—poetry thrives when feelings and words are given equal reverence.",
                "Imaginative storytelling blends intuition with articulate tenderness."
            )
        }
    }

    private static func evaluateModalityPair(
        _ a: AstroModality,
        _ b: AstroModality,
        sameSign: Bool
    ) -> (score: Double, headline: String, prose: String) {
        let sorted = [a.rawValue, b.rawValue].sorted().joined(separator: "+")
        switch sorted {
        case "Cardinal+Cardinal":
            return (
                sameSign ? 85 : 79,
                "Twin Catalysts",
                "Both hearts love initiating chapters and curating memorable plans; taking turns leading keeps the waltz effortless."
            )
        case "Fixed+Fixed":
            return (
                sameSign ? 88 : 77,
                "Eternal Velvet Knot",
                "Unwavering devotion and deep loyalty anchor this bond; gentle softness dissolves occasional stubbornness."
            )
        case "Mutable+Mutable":
            return (
                84,
                "Chiffon Choreography",
                "Fluid, forgiving, and adaptable—you pivot gracefully together and delight in spontaneous detours."
            )
        case "Cardinal+Fixed":
            return (
                89,
                "Overture & Devotion",
                "Cardinal sparks the romantic vision while Fixed sustains the glow—an effortlessly balanced relational cadence."
            )
        case "Cardinal+Mutable":
            return (
                88,
                "Compass & Breeze",
                "Clear initiative meets graceful flexibility, allowing shared plans to unfold without friction."
            )
        default: // Fixed+Mutable
            return (
                86,
                "Anchor & Ribbon",
                "Fixed offers a serene harbor while Mutable brings fresh wonder and gentle movement."
            )
        }
    }

    private static func evaluatePlanetaryPair(_ a: PlanetaryRuler, _ b: PlanetaryRuler) -> Double {
        if a == b { return 90 }
        let pair = Set([a, b])
        if pair == Set([.venus, .mars])    { return 96 } // Classic romantic polarity
        if pair == Set([.sun, .moon])      { return 95 } // Luminary harmony
        if pair == Set([.venus, .jupiter]) { return 94 } // Greater & Lesser Benefic
        if pair == Set([.venus, .neptune]) { return 93 } // Higher octave romance
        if pair == Set([.moon, .neptune])  { return 91 }
        if pair == Set([.mercury, .venus]) { return 90 }
        if pair == Set([.mercury, .uranus]){ return 89 }
        if pair == Set([.sun, .jupiter])   { return 92 }
        if pair == Set([.mars, .pluto])    { return 85 }
        if pair == Set([.saturn, .venus])  { return 86 }
        if pair.contains(.venus) || pair.contains(.jupiter) { return 87 }
        return 80
    }

    private static func ritualRecommendation(
        for a: AstroElement,
        and b: AstroElement,
        aspect: AstrologicalAspect
    ) -> String {
        switch aspect {
        case .trine, .conjunction:
            return "Write handwritten notes on cream stationery over rose-hip tea and stargaze past 10 PM to celebrate your natural \(aspect.rawValue.lowercased()) flow."
        case .sextile:
            return "Wander a quiet art gallery or pastry café with no itinerary—your \(a.rawValue) × \(b.rawValue) chemistry sparkles brightest in unscripted conversation."
        case .opposition:
            return "Share a candlelit dinner where each chooses a song or dessert for the other, honoring your magnetic mirror polarity."
        case .square, .quincunx, .semiSextile:
            return "Take a slow twilight walk and trade three unspoken wishes—gentle curiosity transforms your \(aspect.rawValue.lowercased()) contrast into intimacy."
        }
    }
}

// MARK: - 5. Structural Local Persistence via SwiftData Macros

@Model
final class SavedProfilePair {
    @Attribute(.unique) var pairID: UUID
    var pairTitle: String
    var ribbonTag: String
    var personalNote: String
    var isFavorite: Bool

    // Soul A structured date components & raw input
    var nameA: String
    var rawInputA: String
    var yearA: Int
    var monthA: Int
    var dayA: Int
    var hourA: Int
    var minuteA: Int
    var hasExplicitYearA: Bool
    var hasExplicitTimeA: Bool

    // Soul B structured date components & raw input
    var nameB: String
    var rawInputB: String
    var yearB: Int
    var monthB: Int
    var dayB: Int
    var hourB: Int
    var minuteB: Int
    var hasExplicitYearB: Bool
    var hasExplicitTimeB: Bool

    // Cached deterministic synastry summary for instantaneous sorting & querying
    var signARaw: String
    var signBRaw: String
    var compatibilityScore: Int
    var elementalScore: Int
    var modalityScore: Int
    var aspectScore: Int
    var aspectName: String

    var createdAt: Date
    var updatedAt: Date

    init(
        pairID: UUID = UUID(),
        pairTitle: String,
        ribbonTag: String,
        personalNote: String = "",
        isFavorite: Bool = false,
        profileA: AstroProfile,
        profileB: AstroProfile,
        report: SynastryReport,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.pairID = pairID
        self.pairTitle = pairTitle
        self.ribbonTag = ribbonTag
        self.personalNote = personalNote
        self.isFavorite = isFavorite

        self.nameA = profileA.name
        self.rawInputA = profileA.rawDateInput
        self.yearA = profileA.year
        self.monthA = profileA.month
        self.dayA = profileA.day
        self.hourA = profileA.hour
        self.minuteA = profileA.minute
        self.hasExplicitYearA = profileA.hasExplicitYear
        self.hasExplicitTimeA = profileA.hasExplicitTime

        self.nameB = profileB.name
        self.rawInputB = profileB.rawDateInput
        self.yearB = profileB.year
        self.monthB = profileB.month
        self.dayB = profileB.day
        self.hourB = profileB.hour
        self.minuteB = profileB.minute
        self.hasExplicitYearB = profileB.hasExplicitYear
        self.hasExplicitTimeB = profileB.hasExplicitTime

        self.signARaw = profileA.sign.rawValue
        self.signBRaw = profileB.sign.rawValue
        self.compatibilityScore = report.overallScore
        self.elementalScore = report.elementalScore
        self.modalityScore = report.modalityScore
        self.aspectScore = report.aspectScore
        self.aspectName = report.aspect.rawValue

        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var astroProfileA: AstroProfile {
        AstroProfile(
            name: nameA,
            rawDateInput: rawInputA,
            year: yearA,
            month: monthA,
            day: dayA,
            hour: hourA,
            minute: minuteA,
            hasExplicitYear: hasExplicitYearA,
            hasExplicitTime: hasExplicitTimeA
        )
    }

    var astroProfileB: AstroProfile {
        AstroProfile(
            name: nameB,
            rawDateInput: rawInputB,
            year: yearB,
            month: monthB,
            day: dayB,
            hour: hourB,
            minute: minuteB,
            hasExplicitYear: hasExplicitYearB,
            hasExplicitTime: hasExplicitTimeB
        )
    }

    func applySnapshot(_ snapshot: PersistedPairValueSnapshot) {
        self.pairTitle = snapshot.pairTitle
        self.ribbonTag = snapshot.ribbonTag
        self.personalNote = snapshot.personalNote
        self.isFavorite = snapshot.isFavorite

        let a = snapshot.profileA
        self.nameA = a.name
        self.rawInputA = a.rawDateInput
        self.yearA = a.year
        self.monthA = a.month
        self.dayA = a.day
        self.hourA = a.hour
        self.minuteA = a.minute
        self.hasExplicitYearA = a.hasExplicitYear
        self.hasExplicitTimeA = a.hasExplicitTime

        let b = snapshot.profileB
        self.nameB = b.name
        self.rawInputB = b.rawDateInput
        self.yearB = b.year
        self.monthB = b.month
        self.dayB = b.day
        self.hourB = b.hour
        self.minuteB = b.minute
        self.hasExplicitYearB = b.hasExplicitYear
        self.hasExplicitTimeB = b.hasExplicitTime

        let report = SynastryEngine.evaluate(profileA: a, profileB: b)
        self.signARaw = a.sign.rawValue
        self.signBRaw = b.sign.rawValue
        self.compatibilityScore = report.overallScore
        self.elementalScore = report.elementalScore
        self.modalityScore = report.modalityScore
        self.aspectScore = report.aspectScore
        self.aspectName = report.aspect.rawValue
        self.updatedAt = Date()
    }

    var valueSnapshot: PersistedPairValueSnapshot {
        PersistedPairValueSnapshot(
            pairID: pairID,
            pairTitle: pairTitle,
            ribbonTag: ribbonTag,
            personalNote: personalNote,
            isFavorite: isFavorite,
            profileA: astroProfileA,
            profileB: astroProfileB,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

/// Persists active studio workspace state & initial seeding marker across sleep/termination states.
@Model
final class StudioWorkspaceRecord {
    @Attribute(.unique) var workspaceKey: String
    var didSeedCuratedPairs: Bool
    var activeRibbonTag: String
    var activeNote: String

    var nameA: String
    var rawInputA: String
    var yearA: Int
    var monthA: Int
    var dayA: Int
    var hourA: Int
    var minuteA: Int
    var hasExplicitYearA: Bool
    var hasExplicitTimeA: Bool

    var nameB: String
    var rawInputB: String
    var yearB: Int
    var monthB: Int
    var dayB: Int
    var hourB: Int
    var minuteB: Int
    var hasExplicitYearB: Bool
    var hasExplicitTimeB: Bool

    var updatedAt: Date

    init(
        workspaceKey: String = "primary_studio",
        didSeedCuratedPairs: Bool = false,
        activeRibbonTag: String = "Soulmate",
        activeNote: String = "",
        profileA: AstroProfile,
        profileB: AstroProfile,
        updatedAt: Date = Date()
    ) {
        self.workspaceKey = workspaceKey
        self.didSeedCuratedPairs = didSeedCuratedPairs
        self.activeRibbonTag = activeRibbonTag
        self.activeNote = activeNote

        self.nameA = profileA.name
        self.rawInputA = profileA.rawDateInput
        self.yearA = profileA.year
        self.monthA = profileA.month
        self.dayA = profileA.day
        self.hourA = profileA.hour
        self.minuteA = profileA.minute
        self.hasExplicitYearA = profileA.hasExplicitYear
        self.hasExplicitTimeA = profileA.hasExplicitTime

        self.nameB = profileB.name
        self.rawInputB = profileB.rawDateInput
        self.yearB = profileB.year
        self.monthB = profileB.month
        self.dayB = profileB.day
        self.hourB = profileB.hour
        self.minuteB = profileB.minute
        self.hasExplicitYearB = profileB.hasExplicitYear
        self.hasExplicitTimeB = profileB.hasExplicitTime

        self.updatedAt = updatedAt
    }

    var restoredProfileA: AstroProfile {
        AstroProfile(
            name: nameA,
            rawDateInput: rawInputA,
            year: yearA,
            month: monthA,
            day: dayA,
            hour: hourA,
            minute: minuteA,
            hasExplicitYear: hasExplicitYearA,
            hasExplicitTime: hasExplicitTimeA
        )
    }

    var restoredProfileB: AstroProfile {
        AstroProfile(
            name: nameB,
            rawDateInput: rawInputB,
            year: yearB,
            month: monthB,
            day: dayB,
            hour: hourB,
            minute: minuteB,
            hasExplicitYear: hasExplicitYearB,
            hasExplicitTime: hasExplicitTimeB
        )
    }

    func update(from profileA: AstroProfile, profileB: AstroProfile, ribbonTag: String, note: String) {
        self.activeRibbonTag = ribbonTag
        self.activeNote = note

        self.nameA = profileA.name
        self.rawInputA = profileA.rawDateInput
        self.yearA = profileA.year
        self.monthA = profileA.month
        self.dayA = profileA.day
        self.hourA = profileA.hour
        self.minuteA = profileA.minute
        self.hasExplicitYearA = profileA.hasExplicitYear
        self.hasExplicitTimeA = profileA.hasExplicitTime

        self.nameB = profileB.name
        self.rawInputB = profileB.rawDateInput
        self.yearB = profileB.year
        self.monthB = profileB.month
        self.dayB = profileB.day
        self.hourB = profileB.hour
        self.minuteB = profileB.minute
        self.hasExplicitYearB = profileB.hasExplicitYear
        self.hasExplicitTimeB = profileB.hasExplicitTime

        self.updatedAt = Date()
    }
}

// MARK: - 6. Undoable Action Ledger & Studio ViewModel

struct PersistedPairValueSnapshot: Equatable, Sendable {
    let pairID: UUID
    var pairTitle: String
    var ribbonTag: String
    var personalNote: String
    var isFavorite: Bool
    var profileA: AstroProfile
    var profileB: AstroProfile
    var createdAt: Date
    var updatedAt: Date
}

struct StudioSnapshot: Equatable, Sendable {
    var profileA: AstroProfile
    var profileB: AstroProfile
    var selectedRibbonTag: String
    var studioNote: String
}

enum VaultLedgerEffect: Equatable, Sendable {
    case none
    case insertedPair(PersistedPairValueSnapshot)
    case deletedPair(PersistedPairValueSnapshot)
    case toggledFavorite(pairID: UUID, previousFavorite: Bool, newFavorite: Bool)
}

enum LedgerActionCategory: String, Sendable {
    case smartParse   = "Regex Parse"
    case profileEdit  = "Profile Edit"
    case swapSouls    = "Polarity Swap"
    case presetPair   = "Muse Preset"
    case vaultSave    = "Vault Catalog"
    case vaultDelete  = "Vault Prune"
    case vaultFav     = "Ribbon Pin"
    case vaultRestore = "Vault Recall"

    var symbolName: String {
        switch self {
        case .smartParse:   return "wand.and.stars"
        case .profileEdit:  return "pencil.and.scribble"
        case .swapSouls:    return "arrow.left.arrow.right"
        case .presetPair:   return "sparkles"
        case .vaultSave:    return "heart.text.square.fill"
        case .vaultDelete:  return "trash"
        case .vaultFav:     return "heart.fill"
        case .vaultRestore: return "book.pages"
        }
    }
}

struct LedgerEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let category: LedgerActionCategory
    let title: String
    let detail: String
    let scoreBefore: Int
    let scoreAfter: Int
    let beforeStudio: StudioSnapshot
    let afterStudio: StudioSnapshot
    let vaultEffect: VaultLedgerEffect
}

@MainActor
@Observable
final class StudioController {
    var profileA: AstroProfile
    var profileB: AstroProfile
    var selectedRibbonTag: String = "Soulmate"
    var studioNote: String = ""

    // Live chaotic text buffers bound to the Smart Regex Date-Parser fields
    var draftInputA: String
    var draftInputB: String

    // Undoable Action Ledger stacks
    private(set) var undoStack: [LedgerEntry] = []
    private(set) var redoStack: [LedgerEntry] = []
    var lastToastBanner: String? = nil

    static let ribbonTags = ["Soulmate", "Crush", "Bestie", "Muse", "Twin Flame"]

    static let defaultProfileA = AstroProfile(
        name: "Celeste",
        rawDateInput: "14th of feb, '99 around 11:15pm",
        year: 1999, month: 2, day: 14, hour: 23, minute: 15,
        hasExplicitYear: true, hasExplicitTime: true
    )

    static let defaultProfileB = AstroProfile(
        name: "Julian",
        rawDateInput: "october 12th 1998 @ 08:30am",
        year: 1998, month: 10, day: 12, hour: 8, minute: 30,
        hasExplicitYear: true, hasExplicitTime: true
    )

    init() {
        self.profileA = Self.defaultProfileA
        self.profileB = Self.defaultProfileB
        self.draftInputA = Self.defaultProfileA.rawDateInput
        self.draftInputB = Self.defaultProfileB.rawDateInput
    }

    var currentReport: SynastryReport {
        SynastryEngine.evaluate(profileA: profileA, profileB: profileB)
    }

    var currentSnapshot: StudioSnapshot {
        StudioSnapshot(
            profileA: profileA,
            profileB: profileB,
            selectedRibbonTag: selectedRibbonTag,
            studioNote: studioNote
        )
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: Bootstrap & Lifecycle Persistence

    func bootstrapFromSwiftData(context: ModelContext) {
        let descriptor = FetchDescriptor<StudioWorkspaceRecord>(
            predicate: #Predicate { $0.workspaceKey == "primary_studio" }
        )
        if let existing = try? context.fetch(descriptor).first {
            self.profileA = existing.restoredProfileA
            self.profileB = existing.restoredProfileB
            self.selectedRibbonTag = existing.activeRibbonTag
            self.studioNote = existing.activeNote
            self.draftInputA = existing.rawInputA
            self.draftInputB = existing.rawInputB

            if !existing.didSeedCuratedPairs {
                seedInitialCuratedPairsIfEmpty(context: context)
                existing.didSeedCuratedPairs = true
                try? context.save()
            }
        } else {
            let record = StudioWorkspaceRecord(
                didSeedCuratedPairs: true,
                activeRibbonTag: selectedRibbonTag,
                activeNote: studioNote,
                profileA: profileA,
                profileB: profileB
            )
            context.insert(record)
            seedInitialCuratedPairsIfEmpty(context: context)
            try? context.save()
        }
    }

    func persistWorkspaceState(context: ModelContext) {
        let descriptor = FetchDescriptor<StudioWorkspaceRecord>(
            predicate: #Predicate { $0.workspaceKey == "primary_studio" }
        )
        if let existing = try? context.fetch(descriptor).first {
            existing.update(from: profileA, profileB: profileB, ribbonTag: selectedRibbonTag, note: studioNote)
        } else {
            let record = StudioWorkspaceRecord(
                didSeedCuratedPairs: true,
                activeRibbonTag: selectedRibbonTag,
                activeNote: studioNote,
                profileA: profileA,
                profileB: profileB
            )
            context.insert(record)
        }
        try? context.save()
    }

    private func seedInitialCuratedPairsIfEmpty(context: ModelContext) {
        let pairCount = (try? context.fetchCount(FetchDescriptor<SavedProfilePair>())) ?? 0
        guard pairCount == 0 else { return }

        let seeds: [(String, String, String, Bool, AstroProfile, AstroProfile)] = [
            (
                "Celeste × Julian",
                "Soulmate",
                "Rosewater trine under winter twilight.",
                true,
                Self.defaultProfileA,
                Self.defaultProfileB
            ),
            (
                "Odette × Soren",
                "Muse",
                "Water & Earth conservatory harmony.",
                true,
                AstroProfile(
                    name: "Odette",
                    rawDateInput: "born 4th of march 2001 @ midnight",
                    year: 2001, month: 3, day: 4, hour: 0, minute: 0,
                    hasExplicitYear: true, hasExplicitTime: true
                ),
                AstroProfile(
                    name: "Soren",
                    rawDateInput: "02/05/2000 noon",
                    year: 2000, month: 5, day: 2, hour: 12, minute: 0,
                    hasExplicitYear: true, hasExplicitTime: true
                )
            ),
            (
                "Vivienne × Theo",
                "Crush",
                "Fire & Air champagne effervescence.",
                false,
                AstroProfile(
                    name: "Vivienne",
                    rawDateInput: "aug 11th '00 7:45pm",
                    year: 2000, month: 8, day: 11, hour: 19, minute: 45,
                    hasExplicitYear: true, hasExplicitTime: true
                ),
                AstroProfile(
                    name: "Theo",
                    rawDateInput: "1999-06-03 14:20",
                    year: 1999, month: 6, day: 3, hour: 14, minute: 20,
                    hasExplicitYear: true, hasExplicitTime: true
                )
            )
        ]

        for (idx, item) in seeds.enumerated() {
            let report = SynastryEngine.evaluate(profileA: item.4, profileB: item.5)
            let timestamp = Date().addingTimeInterval(Double(-idx * 3600))
            let model = SavedProfilePair(
                pairTitle: item.0,
                ribbonTag: item.1,
                personalNote: item.2,
                isFavorite: item.3,
                profileA: item.4,
                profileB: item.5,
                report: report,
                createdAt: timestamp,
                updatedAt: timestamp
            )
            context.insert(model)
        }
    }

    // MARK: Undoable Mutations

    func updateName(isSoulA: Bool, newName: String, context: ModelContext) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let currentName = isSoulA ? profileA.name : profileB.name
        guard trimmed != currentName else { return }

        let before = currentSnapshot
        let scoreBefore = currentReport.overallScore

        if isSoulA {
            profileA.name = trimmed
        } else {
            profileB.name = trimmed
        }

        let after = currentSnapshot
        let scoreAfter = currentReport.overallScore
        recordLedgerEntry(
            category: .profileEdit,
            title: "Renamed \(currentName) → \(trimmed)",
            detail: "\(profileA.name) (\(profileA.sign.glyph)) × \(profileB.name) (\(profileB.sign.glyph))",
            scoreBefore: scoreBefore,
            scoreAfter: scoreAfter,
            before: before,
            after: after,
            vaultEffect: .none
        )
        persistWorkspaceState(context: context)
    }

    func applyParsedDate(
        isSoulA: Bool,
        rawText: String,
        parsed: ParsedBirthDate,
        context: ModelContext
    ) {
        let target = isSoulA ? profileA : profileB
        // Avoid duplicate ledger entries if resolved date components and raw text didn't meaningfully change
        let unchanged =
            target.year == parsed.year &&
            target.month == parsed.month &&
            target.day == parsed.day &&
            target.hour == parsed.hour &&
            target.minute == parsed.minute &&
            target.hasExplicitYear == parsed.hasExplicitYear &&
            target.hasExplicitTime == parsed.hasExplicitTime

        if unchanged {
            if isSoulA {
                profileA.rawDateInput = rawText
                draftInputA = rawText
            } else {
                profileB.rawDateInput = rawText
                draftInputB = rawText
            }
            persistWorkspaceState(context: context)
            return
        }

        let before = currentSnapshot
        let scoreBefore = currentReport.overallScore

        var updated = target
        updated.rawDateInput = rawText
        updated.year = parsed.year
        updated.month = parsed.month
        updated.day = parsed.day
        updated.hour = parsed.hour
        updated.minute = parsed.minute
        updated.hasExplicitYear = parsed.hasExplicitYear
        updated.hasExplicitTime = parsed.hasExplicitTime

        if isSoulA {
            profileA = updated
            draftInputA = rawText
        } else {
            profileB = updated
            draftInputB = rawText
        }

        let after = currentSnapshot
        let scoreAfter = currentReport.overallScore

        AuraHaptics.crispTick()
        recordLedgerEntry(
            category: .smartParse,
            title: "Parsed \(updated.name)'s Birth Date",
            detail: "\(parsed.formattedDisplay) · \(updated.sign.rawValue) \(updated.sign.glyph)",
            scoreBefore: scoreBefore,
            scoreAfter: scoreAfter,
            before: before,
            after: after,
            vaultEffect: .none
        )
        persistWorkspaceState(context: context)
    }

    func swapSouls(context: ModelContext) {
        let before = currentSnapshot
        let score = currentReport.overallScore

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            let temp = profileA
            profileA = profileB
            profileB = temp
            draftInputA = profileA.rawDateInput
            draftInputB = profileB.rawDateInput
        }

        AuraHaptics.softTap()
        let after = currentSnapshot
        recordLedgerEntry(
            category: .swapSouls,
            title: "Swapped \(profileB.name) ⇄ \(profileA.name)",
            detail: "Ascendant lead shifted to \(profileA.sign.rawValue) \(profileA.sign.glyph)",
            scoreBefore: score,
            scoreAfter: score,
            before: before,
            after: after,
            vaultEffect: .none
        )
        persistWorkspaceState(context: context)
    }

    func loadCuratedMusePreset(_ preset: (String, AstroProfile, AstroProfile), context: ModelContext) {
        let before = currentSnapshot
        let scoreBefore = currentReport.overallScore

        withAnimation(.spring(response: 0.48, dampingFraction: 0.75)) {
            profileA = preset.1
            profileB = preset.2
            draftInputA = preset.1.rawDateInput
            draftInputB = preset.2.rawDateInput
            selectedRibbonTag = preset.0
        }

        let after = currentSnapshot
        let scoreAfter = currentReport.overallScore
        AuraHaptics.softTap()
        recordLedgerEntry(
            category: .presetPair,
            title: "Loaded \(preset.1.name) × \(preset.2.name)",
            detail: "\(preset.1.sign.rawValue) × \(preset.2.sign.rawValue) · \(scoreAfter)% Harmony",
            scoreBefore: scoreBefore,
            scoreAfter: scoreAfter,
            before: before,
            after: after,
            vaultEffect: .none
        )
        persistWorkspaceState(context: context)
    }

    func saveCurrentPairToVault(context: ModelContext) {
        let before = currentSnapshot
        let report = currentReport
        let title = "\(profileA.name) × \(profileB.name)"
        let now = Date()

        let pair = SavedProfilePair(
            pairTitle: title,
            ribbonTag: selectedRibbonTag,
            personalNote: studioNote,
            isFavorite: report.overallScore >= 88,
            profileA: profileA,
            profileB: profileB,
            report: report,
            createdAt: now,
            updatedAt: now
        )
        context.insert(pair)
        try? context.save()

        let snapshot = pair.valueSnapshot
        AuraHaptics.successBloom()
        recordLedgerEntry(
            category: .vaultSave,
            title: "Cataloged \"\(title)\"",
            detail: "\(report.overallScore)% \(report.ribbonTier) · \(selectedRibbonTag)",
            scoreBefore: report.overallScore,
            scoreAfter: report.overallScore,
            before: before,
            after: currentSnapshot,
            vaultEffect: .insertedPair(snapshot)
        )
        showToast("Saved \"\(title)\" to Celestial Vault ♡")
    }

    func recallPairFromVault(_ pair: SavedProfilePair, context: ModelContext) {
        let before = currentSnapshot
        let scoreBefore = currentReport.overallScore

        withAnimation(.spring(response: 0.48, dampingFraction: 0.76)) {
            profileA = pair.astroProfileA
            profileB = pair.astroProfileB
            draftInputA = profileA.rawDateInput
            draftInputB = profileB.rawDateInput
            selectedRibbonTag = pair.ribbonTag
            studioNote = pair.personalNote
        }

        let after = currentSnapshot
        let scoreAfter = currentReport.overallScore
        AuraHaptics.softTap()
        recordLedgerEntry(
            category: .vaultRestore,
            title: "Recalled \"\(pair.pairTitle)\"",
            detail: "\(profileA.sign.rawValue) \(profileA.sign.glyph) × \(profileB.sign.rawValue) \(profileB.sign.glyph)",
            scoreBefore: scoreBefore,
            scoreAfter: scoreAfter,
            before: before,
            after: after,
            vaultEffect: .none
        )
        persistWorkspaceState(context: context)
        showToast("Loaded \"\(pair.pairTitle)\" into Wheel ✦")
    }

    func toggleFavorite(pair: SavedProfilePair, context: ModelContext) {
        let prev = pair.isFavorite
        let next = !prev
        pair.isFavorite = next
        pair.updatedAt = Date()
        try? context.save()

        let currentScore = currentReport.overallScore
        AuraHaptics.crispTick()
        recordLedgerEntry(
            category: .vaultFav,
            title: next ? "Pinned \"\(pair.pairTitle)\"" : "Unpinned \"\(pair.pairTitle)\"",
            detail: next ? "Marked as Favorite ♡" : "Removed Favorite ribbon",
            scoreBefore: currentScore,
            scoreAfter: currentScore,
            before: currentSnapshot,
            after: currentSnapshot,
            vaultEffect: .toggledFavorite(pairID: pair.pairID, previousFavorite: prev, newFavorite: next)
        )
    }

    func deletePairFromVault(_ pair: SavedProfilePair, context: ModelContext) {
        let snapshot = pair.valueSnapshot
        let title = pair.pairTitle
        context.delete(pair)
        try? context.save()

        let currentScore = currentReport.overallScore
        AuraHaptics.softTap()
        recordLedgerEntry(
            category: .vaultDelete,
            title: "Removed \"\(title)\"",
            detail: "Tap Undo anytime to restore to SwiftData Vault",
            scoreBefore: currentScore,
            scoreAfter: currentScore,
            before: currentSnapshot,
            after: currentSnapshot,
            vaultEffect: .deletedPair(snapshot)
        )
        showToast("Removed \"\(title)\" · Undo available")
    }

    // MARK: Undo & Redo Execution

    func performUndo(context: ModelContext) {
        guard !undoStack.isEmpty else { return }
        let entry = undoStack.removeFirst()
        redoStack.insert(entry, at: 0)

        withAnimation(.spring(response: 0.44, dampingFraction: 0.76)) {
            applyStudioSnapshot(entry.beforeStudio)
            reverseVaultEffect(entry.vaultEffect, context: context)
        }
        persistWorkspaceState(context: context)
        AuraHaptics.softTap()
        showToast("Undid: \(entry.title)")
    }

    func performRedo(context: ModelContext) {
        guard !redoStack.isEmpty else { return }
        let entry = redoStack.removeFirst()
        undoStack.insert(entry, at: 0)

        withAnimation(.spring(response: 0.44, dampingFraction: 0.76)) {
            applyStudioSnapshot(entry.afterStudio)
            reapplyVaultEffect(entry.vaultEffect, context: context)
        }
        persistWorkspaceState(context: context)
        AuraHaptics.softTap()
        showToast("Redid: \(entry.title)")
    }

    private func applyStudioSnapshot(_ snapshot: StudioSnapshot) {
        profileA = snapshot.profileA
        profileB = snapshot.profileB
        draftInputA = snapshot.profileA.rawDateInput
        draftInputB = snapshot.profileB.rawDateInput
        selectedRibbonTag = snapshot.selectedRibbonTag
        studioNote = snapshot.studioNote
    }

    private func reverseVaultEffect(_ effect: VaultLedgerEffect, context: ModelContext) {
        switch effect {
        case .none:
            break
        case .insertedPair(let snap):
            let id = snap.pairID
            let desc = FetchDescriptor<SavedProfilePair>(predicate: #Predicate { $0.pairID == id })
            if let existing = try? context.fetch(desc).first {
                context.delete(existing)
                try? context.save()
            }
        case .deletedPair(let snap):
            let report = SynastryEngine.evaluate(profileA: snap.profileA, profileB: snap.profileB)
            let restored = SavedProfilePair(
                pairID: snap.pairID,
                pairTitle: snap.pairTitle,
                ribbonTag: snap.ribbonTag,
                personalNote: snap.personalNote,
                isFavorite: snap.isFavorite,
                profileA: snap.profileA,
                profileB: snap.profileB,
                report: report,
                createdAt: snap.createdAt,
                updatedAt: Date()
            )
            context.insert(restored)
            try? context.save()
        case .toggledFavorite(let pairID, let previousFavorite, _):
            let desc = FetchDescriptor<SavedProfilePair>(predicate: #Predicate { $0.pairID == pairID })
            if let existing = try? context.fetch(desc).first {
                existing.isFavorite = previousFavorite
                existing.updatedAt = Date()
                try? context.save()
            }
        }
    }

    private func reapplyVaultEffect(_ effect: VaultLedgerEffect, context: ModelContext) {
        switch effect {
        case .none:
            break
        case .insertedPair(let snap):
            let report = SynastryEngine.evaluate(profileA: snap.profileA, profileB: snap.profileB)
            let inserted = SavedProfilePair(
                pairID: snap.pairID,
                pairTitle: snap.pairTitle,
                ribbonTag: snap.ribbonTag,
                personalNote: snap.personalNote,
                isFavorite: snap.isFavorite,
                profileA: snap.profileA,
                profileB: snap.profileB,
                report: report,
                createdAt: snap.createdAt,
                updatedAt: Date()
            )
            context.insert(inserted)
            try? context.save()
        case .deletedPair(let snap):
            let id = snap.pairID
            let desc = FetchDescriptor<SavedProfilePair>(predicate: #Predicate { $0.pairID == id })
            if let existing = try? context.fetch(desc).first {
                context.delete(existing)
                try? context.save()
            }
        case .toggledFavorite(let pairID, _, let newFavorite):
            let desc = FetchDescriptor<SavedProfilePair>(predicate: #Predicate { $0.pairID == pairID })
            if let existing = try? context.fetch(desc).first {
                existing.isFavorite = newFavorite
                existing.updatedAt = Date()
                try? context.save()
            }
        }
    }

    private func recordLedgerEntry(
        category: LedgerActionCategory,
        title: String,
        detail: String,
        scoreBefore: Int,
        scoreAfter: Int,
        before: StudioSnapshot,
        after: StudioSnapshot,
        vaultEffect: VaultLedgerEffect
    ) {
        let entry = LedgerEntry(
            id: UUID(),
            timestamp: Date(),
            category: category,
            title: title,
            detail: detail,
            scoreBefore: scoreBefore,
            scoreAfter: scoreAfter,
            beforeStudio: before,
            afterStudio: after,
            vaultEffect: vaultEffect
        )
        undoStack.insert(entry, at: 0)
        if undoStack.count > 40 {
            undoStack.removeLast()
        }
        redoStack.removeAll()
    }

    func showToast(_ message: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            lastToastBanner = message
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2.6))
            if self?.lastToastBanner == message {
                withAnimation(.easeOut(duration: 0.25)) {
                    self?.lastToastBanner = nil
                }
            }
        }
    }
}

// MARK: - 7. Interactive 3D Gyro Constellation Wheel View

struct InteractiveConstellationWheelView: View {
    let motionManager: MotionManager
    let report: SynastryReport
    @Binding var inspectedSign: ZodiacSign?

    @State private var manualRotationDegrees: Double = 0.0
    @State private var dragPreviousAngle: Double? = nil
    @State private var lastDetentSector: Int = 0
    @State private var chordPulsePhase: Bool = false

    private var combinedRotation: Double {
        motionManager.wheelGyroRotationDegrees + manualRotationDegrees
    }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let side = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

                ZStack {
                    // Ambient rose-quartz aura glow shifting subtly with gyroscope roll/pitch
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AuraTheme.coquettePink.opacity(0.26),
                                    AuraTheme.rosewaterMist.opacity(0.20),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: side * 0.12,
                                endRadius: side * 0.56
                            )
                        )
                        .frame(width: side * 1.06, height: side * 1.06)
                        .offset(
                            x: CGFloat(motionManager.rollDegrees * 0.85),
                            y: CGFloat(motionManager.pitchDegrees * 0.85)
                        )

                    // Main Astrolabe Porcelain Disc
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white,
                                        AuraTheme.porcelainTop,
                                        AuraTheme.balletBlush,
                                        AuraTheme.rosewaterMist.opacity(0.88)
                                    ],
                                    center: .center,
                                    startRadius: 4,
                                    endRadius: side * 0.50
                                )
                            )
                            .shadow(
                                color: AuraTheme.raspberryVelvet.opacity(0.16),
                                radius: 22,
                                x: CGFloat(-motionManager.rollDegrees * 0.7),
                                y: CGFloat(12 + motionManager.pitchDegrees * 0.6)
                            )

                        // Rotating Ecliptic Canvas: 360° degree ticks, 12 sectors, star-maps & synastry chord
                        Canvas { ctx, canvasSize in
                            drawWheelCanvas(in: &ctx, size: canvasSize)
                        }
                        .rotationEffect(.degrees(combinedRotation))

                        // Interactive Tappable Sign Medallions counter-rotated to stay upright & legible
                        ForEach(ZodiacSign.allCases) { sign in
                            signNodeButton(for: sign, wheelDiameter: side)
                        }

                        // Specular pearl sheen reacting to live gyroscope tilt
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.52),
                                        Color.clear,
                                        AuraTheme.coquettePink.opacity(0.08)
                                    ],
                                    startPoint: UnitPoint(
                                        x: 0.5 - motionManager.rollDegrees / 55.0,
                                        y: 0.5 - motionManager.pitchDegrees / 55.0
                                    ),
                                    endPoint: UnitPoint(
                                        x: 0.5 + motionManager.rollDegrees / 55.0,
                                        y: 0.5 + motionManager.pitchDegrees / 55.0
                                    )
                                )
                            )
                            .allowsHitTesting(false)

                        // Outer Pearl & Rose-Gold Bezel
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        AuraTheme.petalSilk,
                                        AuraTheme.gildedRose.opacity(0.65),
                                        Color.white
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.2
                            )
                            .allowsHitTesting(false)

                        // Center Coquette Synastry Medallion
                        centerSynastryHub(wheelDiameter: side)
                    }
                    .frame(width: side, height: side)
                    // Fluid 3D tilt driven by @Observable MotionManager gyroscope polling
                    .rotation3DEffect(
                        .degrees(motionManager.pitchDegrees),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.52
                    )
                    .rotation3DEffect(
                        .degrees(motionManager.rollDegrees),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.52
                    )
                    .gesture(wheelSpinDragGesture(center: center))

                    // Top Coquette Satin Bow Ascendant Crest
                    VStack(spacing: 2) {
                        CoquetteBowEmblem(size: 30, tint: AuraTheme.raspberryVelvet)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(AuraTheme.raspberryVelvet)
                    }
                    .offset(y: -side * 0.50 - 3)
                    .shadow(color: AuraTheme.coquettePink.opacity(0.30), radius: 5, x: 0, y: 2)
                }
                .position(center)
            }
            .frame(height: 318)

            // Selected Sign Mini Constellation Card (when user taps any zodiac sector)
            if let sign = inspectedSign {
                SignConstellationInspectorRibbon(sign: sign) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        inspectedSign = nil
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.94).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                chordPulsePhase = true
            }
        }
    }

    private func signNodeButton(for sign: ZodiacSign, wheelDiameter: CGFloat) -> some View {
        let sectorMidAngleDeg = sign.startDegree + 15.0 + combinedRotation - 90.0
        let angleRad = sectorMidAngleDeg * .pi / 180.0
        let glyphRadius = wheelDiameter * 0.395
        let xOffset = cos(angleRad) * glyphRadius
        let yOffset = sin(angleRad) * glyphRadius

        let isSoulA = report.profileA.sign == sign
        let isSoulB = report.profileB.sign == sign
        let isInspected = inspectedSign == sign

        return Button {
            AuraHaptics.crispTick()
            withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                inspectedSign = (inspectedSign == sign) ? nil : sign
            }
        } label: {
            ZStack {
                if isSoulA || isSoulB {
                    Circle()
                        .fill(
                            isSoulA && isSoulB
                                ? AnyShapeStyle(AuraTheme.ribbonGradient)
                                : AnyShapeStyle(isSoulA ? AuraTheme.raspberryVelvet : AuraTheme.coquettePink)
                        )
                        .frame(width: 34, height: 34)
                        .shadow(color: AuraTheme.raspberryVelvet.opacity(0.35), radius: 6, x: 0, y: 2)
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                } else if isInspected {
                    Circle()
                        .fill(AuraTheme.rosewaterMist)
                        .frame(width: 31, height: 31)
                        .overlay(Circle().stroke(AuraTheme.coquettePink, lineWidth: 1.2))
                }

                Text(sign.glyph)
                    .font(.system(size: (isSoulA || isSoulB) ? 16 : 14.5, weight: .semibold, design: .serif))
                    .foregroundStyle((isSoulA || isSoulB) ? Color.white : AuraTheme.plumInk)
            }
            .frame(width: 36, height: 36)
            .contentShape(Circle())
        }
        .buttonStyle(CoquettePressButtonStyle(scaleAmount: 0.88))
        .offset(x: xOffset, y: yOffset)
        .accessibilityLabel("\(sign.rawValue), \(sign.element.rawValue) \(sign.modality.rawValue)")
    }

    private func centerSynastryHub(wheelDiameter: CGFloat) -> some View {
        let hubSize = wheelDiameter * 0.31
        return Button {
            AuraHaptics.softTap()
            motionManager.recenterWheel()
            withAnimation(.spring(response: 0.55, dampingFraction: 0.74)) {
                manualRotationDegrees = 0
            }
        } label: {
            VStack(spacing: 2) {
                Text("\(report.overallScore)%")
                    .font(.system(size: 21, weight: .bold, design: .serif))
                    .foregroundStyle(AuraTheme.plumInk)
                    .contentTransition(.numericText())

                HStack(spacing: 4) {
                    Text(report.profileA.sign.glyph)
                    Text(report.aspect.glyph)
                        .foregroundStyle(AuraTheme.raspberryVelvet)
                    Text(report.profileB.sign.glyph)
                }
                .font(.system(size: 11.5, weight: .semibold, design: .serif))
                .foregroundStyle(AuraTheme.mauveSubtext)

                Text(report.aspect.rawValue.uppercased())
                    .font(.system(size: 8.5, weight: .bold, design: .rounded))
                    .tracking(0.9)
                    .foregroundStyle(AuraTheme.raspberryVelvet)
            }
            .frame(width: hubSize, height: hubSize)
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white, AuraTheme.porcelainTop, AuraTheme.balletBlush],
                            center: .center,
                            startRadius: 2,
                            endRadius: hubSize * 0.52
                        )
                    )
                    .shadow(color: AuraTheme.coquettePink.opacity(0.22), radius: 10, x: 0, y: 4)
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white, AuraTheme.coquettePink.opacity(0.65), Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(CoquettePressButtonStyle(scaleAmount: 0.94))
        .accessibilityLabel("Compatibility \(report.overallScore) percent, \(report.aspect.rawValue). Tap to recenter wheel.")
    }

    private func wheelSpinDragGesture(center: CGPoint) -> some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let dx = Double(value.location.x - center.x)
                let dy = Double(value.location.y - center.y)
                let currentAngle = atan2(dy, dx) * 180.0 / .pi

                if let prev = dragPreviousAngle {
                    var delta = currentAngle - prev
                    if delta > 180 { delta -= 360 }
                    if delta < -180 { delta += 360 }
                    manualRotationDegrees += delta

                    let currentSector = Int((combinedRotation.truncatingRemainder(dividingBy: 360) + 360) / 30.0) % 12
                    if currentSector != lastDetentSector {
                        lastDetentSector = currentSector
                        AuraHaptics.crispTick()
                    }
                }
                dragPreviousAngle = currentAngle
            }
            .onEnded { _ in
                dragPreviousAngle = nil
            }
    }

    private func drawWheelCanvas(in ctx: inout GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let outerR = min(size.width, size.height) * 0.485
        let glyphRingOuter = outerR * 0.92
        let constellationOuter = outerR * 0.72
        let innerChordR = outerR * 0.50

        // Concentric satin rings
        for radius in [outerR, glyphRingOuter, constellationOuter, innerChordR] {
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            ctx.stroke(
                Path(ellipseIn: rect),
                with: .color(AuraTheme.gildedRose.opacity(0.32)),
                lineWidth: radius == constellationOuter ? 1.1 : 0.8
            )
        }

        // 72 fine 5-degree ecliptic ticks around outer bezel
        for tick in 0..<72 {
            let deg = Double(tick) * 5.0 - 90.0
            let rad = deg * .pi / 180.0
            let isMajor = tick % 6 == 0
            let rStart = isMajor ? constellationOuter : (outerR * 0.945)
            let rEnd = outerR
            var line = Path()
            line.move(to: CGPoint(x: center.x + cos(rad) * rStart, y: center.y + sin(rad) * rStart))
            line.addLine(to: CGPoint(x: center.x + cos(rad) * rEnd, y: center.y + sin(rad) * rEnd))
            ctx.stroke(
                line,
                with: .color(AuraTheme.gildedRose.opacity(isMajor ? 0.42 : 0.25)),
                lineWidth: isMajor ? 1.0 : 0.65
            )
        }

        // 12 Constellation Star-Maps nestled inside the middle celestial band
        for sign in ZodiacSign.allCases {
            let midDeg = sign.startDegree + 15.0 - 90.0
            let midRad = midDeg * .pi / 180.0
            let bandRadius = (constellationOuter + innerChordR) * 0.50
            let clusterCenter = CGPoint(
                x: center.x + cos(midRad) * bandRadius,
                y: center.y + sin(midRad) * bandRadius
            )
            let boxSize = outerR * 0.145
            let pattern = sign.constellationPattern
            let isHighlighted = (sign == report.profileA.sign || sign == report.profileB.sign)

            let mappedPoints: [CGPoint] = pattern.stars.map { norm in
                CGPoint(
                    x: clusterCenter.x + CGFloat(norm.0 - 0.5) * boxSize,
                    y: clusterCenter.y + CGFloat(norm.1 - 0.5) * boxSize
                )
            }

            for edge in pattern.edges where edge.0 < mappedPoints.count && edge.1 < mappedPoints.count {
                var edgePath = Path()
                edgePath.move(to: mappedPoints[edge.0])
                edgePath.addLine(to: mappedPoints[edge.1])
                ctx.stroke(
                    edgePath,
                    with: .color(isHighlighted ? AuraTheme.raspberryVelvet.opacity(0.75) : AuraTheme.gildedRose.opacity(0.45)),
                    lineWidth: isHighlighted ? 1.15 : 0.75
                )
            }

            for pt in mappedPoints {
                let starR: CGFloat = isHighlighted ? 2.1 : 1.45
                let starRect = CGRect(x: pt.x - starR, y: pt.y - starR, width: starR * 2, height: starR * 2)
                ctx.fill(
                    Path(ellipseIn: starRect),
                    with: .color(isHighlighted ? AuraTheme.raspberryVelvet : AuraTheme.gildedRose)
                )
            }
        }

        // Inner Synastry Aspect Chord connecting exact Solar Longitudes of Soul A & Soul B
        let angleARad = (report.profileA.eclipticLongitude - 90.0) * .pi / 180.0
        let angleBRad = (report.profileB.eclipticLongitude - 90.0) * .pi / 180.0
        let ptA = CGPoint(
            x: center.x + cos(angleARad) * innerChordR,
            y: center.y + sin(angleARad) * innerChordR
        )
        let ptB = CGPoint(
            x: center.x + cos(angleBRad) * innerChordR,
            y: center.y + sin(angleBRad) * innerChordR
        )

        // Subtle geometric harmonic web
        var chord = Path()
        chord.move(to: ptA)
        if report.profileA.sign == report.profileB.sign {
            chord.addLine(to: center)
        } else {
            chord.addQuadCurve(
                to: ptB,
                control: CGPoint(
                    x: (ptA.x + ptB.x) * 0.5 * 0.35 + center.x * 0.65,
                    y: (ptA.y + ptB.y) * 0.5 * 0.35 + center.y * 0.65
                )
            )
        }

        ctx.stroke(
            chord,
            with: .color(report.aspect.chordColor.opacity(chordPulsePhase ? 0.34 : 0.16)),
            style: StrokeStyle(lineWidth: 6.0, lineCap: .round)
        )
        ctx.stroke(
            chord,
            with: .color(report.aspect.chordColor),
            style: StrokeStyle(lineWidth: 2.0, lineCap: .round, dash: report.aspect == .square ? [5, 4] : [])
        )

        for anchor in [ptA, ptB] {
            let glowRect = CGRect(x: anchor.x - 6, y: anchor.y - 6, width: 12, height: 12)
            ctx.fill(Path(ellipseIn: glowRect), with: .color(AuraTheme.coquettePink.opacity(0.32)))
            let pinRect = CGRect(x: anchor.x - 3.2, y: anchor.y - 3.2, width: 6.4, height: 6.4)
            ctx.fill(Path(ellipseIn: pinRect), with: .color(AuraTheme.raspberryVelvet))
        }
    }
}

struct SignConstellationInspectorRibbon: View {
    let sign: ZodiacSign
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Mini Star-Map Preview
            Canvas { ctx, size in
                let pattern = sign.constellationPattern
                let pts = pattern.stars.map {
                    CGPoint(x: 6 + CGFloat($0.0) * (size.width - 12), y: 6 + CGFloat($0.1) * (size.height - 12))
                }
                for e in pattern.edges where e.0 < pts.count && e.1 < pts.count {
                    var p = Path()
                    p.move(to: pts[e.0])
                    p.addLine(to: pts[e.1])
                    ctx.stroke(p, with: .color(AuraTheme.raspberryVelvet.opacity(0.65)), lineWidth: 1.2)
                }
                for pt in pts {
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: pt.x - 2.3, y: pt.y - 2.3, width: 4.6, height: 4.6)),
                        with: .color(AuraTheme.raspberryVelvet)
                    )
                }
            }
            .frame(width: 46, height: 46)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AuraTheme.balletBlush)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AuraTheme.petalSilk, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("\(sign.glyph) \(sign.rawValue)")
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(AuraTheme.plumInk)
                    Text("· \(sign.coquetteArchetype)")
                        .font(.system(size: 12, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(AuraTheme.raspberryVelvet)
                }

                Text("\(sign.dateSpanLabel) · \(sign.element.rawValue) · \(sign.modality.rawValue) · Ruled by \(sign.ruler.rawValue) \(sign.ruler.glyph)")
                    .font(.system(size: 11.5, weight: .medium, design: .rounded))
                    .foregroundStyle(AuraTheme.mauveSubtext)
                    .lineLimit(2)
            }

            Spacer(minLength: 4)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AuraTheme.mauveSubtext)
                    .frame(width: 26, height: 26)
                    .background(Circle().fill(AuraTheme.balletBlush))
            }
            .buttonStyle(CoquettePressButtonStyle())
        }
        .padding(12)
        .porcelainCard(cornerRadius: 18)
    }
}

// MARK: - 8. Smart Regex Profile Editor Card

struct SmartProfileEditorCard: View {
    let roleLabel: String
    let isSoulA: Bool
    let profile: AstroProfile
    @Binding var rawText: String
    let onCommitName: (String) -> Void
    let onParsedDate: (String, ParsedBirthDate) -> Void

    @State private var editableName: String = ""
    @FocusState private var isDateFieldFocused: Bool

    private var liveParseOutcome: SmartDateParseOutcome {
        SmartDateParser.parse(rawText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            // Card Header: Role Ribbon + Live Sign Badge
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    CelestialSparkleShape()
                        .fill(isSoulA ? AuraTheme.raspberryVelvet : AuraTheme.coquettePink)
                        .frame(width: 10, height: 10)
                    Text(roleLabel.uppercased())
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.1)
                        .foregroundStyle(AuraTheme.raspberryVelvet)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Capsule().fill(AuraTheme.balletBlush))

                Spacer()

                HStack(spacing: 5) {
                    Text(profile.sign.glyph)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                    Text(profile.sign.rawValue)
                        .font(.system(size: 12.5, weight: .semibold, design: .serif))
                    Text("D\(profile.decan.number)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1.5)
                        .background(Capsule().fill(Color.white.opacity(0.75)))
                }
                .foregroundStyle(AuraTheme.plumInk)
                .padding(.horizontal, 10)
                .padding(.vertical, 4.5)
                .background(
                    Capsule()
                        .fill(profile.sign.element.accentColor.opacity(0.16))
                        .overlay(Capsule().stroke(profile.sign.element.accentColor.opacity(0.35), lineWidth: 0.9))
                )
            }

            // Editable Name Row
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.moon")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AuraTheme.coquettePink)

                TextField("Muse Name", text: $editableName)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(AuraTheme.plumInk)
                    .autocorrectionDisabled()
                    .onSubmit {
                        onCommitName(editableName)
                    }
                    .onChange(of: editableName) { _, updated in
                        if updated.trimmingCharacters(in: .whitespaces).count >= 2 {
                            onCommitName(updated)
                        }
                    }

                Text("\(profile.sign.element.rawValue) · \(profile.sign.modality.rawValue)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(AuraTheme.whisperedMauve)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(AuraTheme.porcelainTop)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .stroke(AuraTheme.petalSilk.opacity(0.75), lineWidth: 0.9)
                    )
            )

            // Chaotic Regex Date-Parser Input Field
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AuraTheme.raspberryVelvet)

                    TextField("Messy birth date (e.g. 14th of feb '99 @ 11pm)", text: $rawText)
                        .font(.system(size: 13.5, weight: .medium, design: .rounded))
                        .foregroundStyle(AuraTheme.plumInk)
                        .autocorrectionDisabled()
                        .focused($isDateFieldFocused)
                        .onSubmit {
                            if case .success(let parsed) = liveParseOutcome {
                                onParsedDate(rawText, parsed)
                            }
                        }

                    if case .success(let parsed) = liveParseOutcome {
                        Button {
                            isDateFieldFocused = false
                            onParsedDate(rawText, parsed)
                        } label: {
                            Text("Apply")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(AuraTheme.ribbonGradient))
                        }
                        .buttonStyle(CoquettePressButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8.5)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(
                                    isDateFieldFocused ? AuraTheme.raspberryVelvet.opacity(0.65) : AuraTheme.petalSilk,
                                    lineWidth: isDateFieldFocused ? 1.3 : 0.9
                                )
                        )
                )

                // Live Structured DateComponents Readout
                regexDiagnosticBanner

                // One-tap Chaotic Sample Chips for effortless parser testing
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Text("Try messy text:")
                            .font(.system(size: 10.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(AuraTheme.whisperedMauve)

                        ForEach(SmartDateParser.chaoticExamples, id: \.self) { sample in
                            Button {
                                rawText = sample
                                if case .success(let parsed) = SmartDateParser.parse(sample) {
                                    onParsedDate(sample, parsed)
                                }
                            } label: {
                                Text(sample)
                                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                                    .foregroundStyle(AuraTheme.mauveSubtext)
                                    .padding(.horizontal, 8.5)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(AuraTheme.balletBlush)
                                            .overlay(Capsule().stroke(AuraTheme.petalSilk.opacity(0.8), lineWidth: 0.7))
                                    )
                            }
                            .buttonStyle(CoquettePressButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(15)
        .porcelainCard(cornerRadius: 22)
        .onAppear {
            editableName = profile.name
        }
        .onChange(of: profile.name) { _, newValue in
            if editableName != newValue {
                editableName = newValue
            }
        }
    }

    @ViewBuilder
    private var regexDiagnosticBanner: some View {
        switch liveParseOutcome {
        case .empty:
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10.5))
                Text("Type any chaotic date phrase—ordinals, 2-digit years, slashes, or times.")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundStyle(AuraTheme.whisperedMauve)

        case .success(let parsed):
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AuraTheme.sageMist)
                    Text(parsed.compactComponentSummary)
                        .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AuraTheme.plumInk)
                    Spacer()
                    Text(parsed.matchedPatternLabel)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(AuraTheme.raspberryVelvet)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1.5)
                        .background(Capsule().fill(AuraTheme.balletBlush))
                }
                if let note = parsed.note {
                    Text(note)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(AuraTheme.whisperedMauve)
                }
            }

        case .invalid(let reason):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.heart")
                    .font(.system(size: 11))
                Text(reason)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundStyle(AuraTheme.raspberryVelvet)
        }
    }
}

// MARK: - 9. Synastry Harmonics Deep-Dive View

struct SynastryHarmonicsView: View {
    let report: SynastryReport
    let onSaveToVault: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Hero Compatibility Score & Ribbon Tier Card
            VStack(spacing: 14) {
                CoquetteBowEmblem(size: 28, tint: AuraTheme.raspberryVelvet)

                Text(report.ribbonTier.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(AuraTheme.raspberryVelvet)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AuraTheme.balletBlush))

                HStack(spacing: 20) {
                    soulMedallion(profile: report.profileA)

                    // Circular Satin Compatibility Ring
                    ZStack {
                        Circle()
                            .stroke(AuraTheme.rosewaterMist, lineWidth: 9)
                        Circle()
                            .trim(from: 0, to: CGFloat(report.overallScore) / 100.0)
                            .stroke(
                                AuraTheme.ribbonGradient,
                                style: StrokeStyle(lineWidth: 9, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.65, dampingFraction: 0.78), value: report.overallScore)

                        VStack(spacing: 1) {
                            Text("\(report.overallScore)%")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundStyle(AuraTheme.plumInk)
                                .contentTransition(.numericText())
                            Text("HARMONY")
                                .font(.system(size: 8.5, weight: .bold, design: .rounded))
                                .tracking(1.1)
                                .foregroundStyle(AuraTheme.whisperedMauve)
                        }
                    }
                    .frame(width: 108, height: 108)

                    soulMedallion(profile: report.profileB)
                }

                Text("\(report.aspect.glyph) \(report.aspect.rawValue) · \(String(format: "%.1f°", report.exactAngularSeparation)) Separation (Orb Δ \(String(format: "%.1f°", report.degreeOrbDelta)))")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AuraTheme.mauveSubtext)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .porcelainCard(cornerRadius: 26)

            // 4-Pillar Deterministic Sub-Scores
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("Deterministic Aspect Matrix")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(AuraTheme.plumInk)
                    Spacer()
                    Text("4-Pillar Telemetry")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AuraTheme.whisperedMauve)
                }

                metricBar(
                    label: "Elemental Chemistry (\(report.profileA.sign.element.rawValue) × \(report.profileB.sign.element.rawValue))",
                    score: report.elementalScore,
                    tint: AuraTheme.raspberryVelvet
                )
                metricBar(
                    label: "Aspect Geometry (\(report.aspect.rawValue) \(report.aspect.nominalAngle)°)",
                    score: report.aspectScore,
                    tint: AuraTheme.coquettePink
                )
                metricBar(
                    label: "Modality Cadence (\(report.profileA.sign.modality.rawValue) × \(report.profileB.sign.modality.rawValue))",
                    score: report.modalityScore,
                    tint: AuraTheme.gildedRose
                )
                metricBar(
                    label: "Planetary & Decan (\(report.profileA.sign.ruler.glyph) × \(report.profileB.sign.ruler.glyph))",
                    score: report.planetaryDecanScore,
                    tint: Color(red: 0.635, green: 0.490, blue: 0.725)
                )
            }
            .padding(18)
            .porcelainCard(cornerRadius: 24)

            // Elemental & Modality Editorial Cards
            VStack(alignment: .leading, spacing: 14) {
                editorialBlock(
                    eyebrow: "ELEMENTAL ALCHEMY",
                    title: report.elementalHeadline,
                    bodyText: report.elementalProse
                )

                Divider()
                    .overlay(AuraTheme.petalSilk.opacity(0.6))

                editorialBlock(
                    eyebrow: "MODALITY CHOREOGRAPHY",
                    title: report.modalityHeadline,
                    bodyText: report.modalityProse
                )
            }
            .padding(18)
            .porcelainCard(cornerRadius: 24)

            // Crystalline Strengths & Coquette Ritual
            VStack(alignment: .leading, spacing: 12) {
                Text("Celestial Signatures & Ritual")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(AuraTheme.plumInk)

                ForEach(Array(report.strengths.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .top, spacing: 9) {
                        CelestialSparkleShape()
                            .fill(AuraTheme.coquettePink)
                            .frame(width: 10, height: 10)
                            .padding(.top, 4)
                        Text(line)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(AuraTheme.plumInk)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        CoquetteBowEmblem(size: 18, tint: AuraTheme.raspberryVelvet)
                        Text("BESPOKE EVENING RITUAL")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.1)
                            .foregroundStyle(AuraTheme.raspberryVelvet)
                    }
                    Text(report.coquetteRitual)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(AuraTheme.plumInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AuraTheme.balletBlush)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AuraTheme.petalSilk, lineWidth: 0.9)
                        )
                )

                Button(action: onSaveToVault) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.text.square.fill")
                        Text("Catalog \(report.profileA.name) × \(report.profileB.name) in Vault")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Capsule().fill(AuraTheme.ribbonGradient))
                    .shadow(color: AuraTheme.raspberryVelvet.opacity(0.26), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(CoquettePressButtonStyle())
            }
            .padding(18)
            .porcelainCard(cornerRadius: 24)
        }
    }

    private func soulMedallion(profile: AstroProfile) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(AuraTheme.balletBlush)
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(AuraTheme.petalSilk, lineWidth: 1.2))
                Text(profile.sign.glyph)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(AuraTheme.raspberryVelvet)
            }
            Text(profile.name)
                .font(.system(size: 13.5, weight: .bold, design: .serif))
                .foregroundStyle(AuraTheme.plumInk)
                .lineLimit(1)
            Text("\(profile.sign.rawValue) · \(String(format: "%.0f°", profile.degreeInSign))")
                .font(.system(size: 10.5, weight: .medium, design: .rounded))
                .foregroundStyle(AuraTheme.mauveSubtext)
        }
        .frame(width: 86)
    }

    private func metricBar(label: String, score: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AuraTheme.plumInk)
                Spacer()
                Text("\(score)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(AuraTheme.raspberryVelvet)
                    .contentTransition(.numericText())
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AuraTheme.balletBlush)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.75), tint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * CGFloat(score) / 100.0))
                        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: score)
                }
            }
            .frame(height: 7.5)
        }
    }

    private func editorialBlock(eyebrow: String, title: String, bodyText: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(eyebrow)
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .tracking(1.2)
                .foregroundStyle(AuraTheme.raspberryVelvet)
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(AuraTheme.plumInk)
            Text(bodyText)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(AuraTheme.mauveSubtext)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 10. SwiftData Celestial Vault & Undoable Action Ledger View

enum VaultFilterMode: String, CaseIterable {
    case all       = "All Pairs"
    case favorites = "Pinned ♡"
    case soulbound = "88%+ Couture"
}

struct CelestialVaultAndLedgerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedProfilePair.updatedAt, order: .reverse) private var savedPairs: [SavedProfilePair]

    let studio: StudioController
    let onRecallPair: (SavedProfilePair) -> Void

    @State private var filterMode: VaultFilterMode = .all
    @State private var searchQuery: String = ""

    private var filteredPairs: [SavedProfilePair] {
        savedPairs.filter { pair in
            let matchesFilter: Bool = {
                switch filterMode {
                case .all:       return true
                case .favorites: return pair.isFavorite
                case .soulbound: return pair.compatibilityScore >= 88
                }
            }()
            guard matchesFilter else { return false }
            let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return true }
            let q = trimmed.lowercased()
            return pair.pairTitle.lowercased().contains(q) ||
                   pair.signARaw.lowercased().contains(q) ||
                   pair.signBRaw.lowercased().contains(q) ||
                   pair.ribbonTag.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            // Section 1: SwiftData Persisted Pairs Catalog
            VStack(alignment: .leading, spacing: 13) {
                HStack(spacing: 8) {
                    CoquetteBowEmblem(size: 22, tint: AuraTheme.raspberryVelvet)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SwiftData Celestial Vault")
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundStyle(AuraTheme.plumInk)
                        Text("\(savedPairs.count) persisted pair\(savedPairs.count == 1 ? "" : "s") · Auto-restores across sleep states")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AuraTheme.whisperedMauve)
                    }
                    Spacer()
                }

                // Search + Filter Chips
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(AuraTheme.coquettePink)
                    TextField("Search names, signs, or ribbons...", text: $searchQuery)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AuraTheme.plumInk)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8.5)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(AuraTheme.petalSilk, lineWidth: 0.9)
                        )
                )

                HStack(spacing: 8) {
                    ForEach(VaultFilterMode.allCases, id: \.rawValue) { mode in
                        let selected = filterMode == mode
                        Button {
                            AuraHaptics.crispTick()
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                                filterMode = mode
                            }
                        } label: {
                            Text(mode.rawValue)
                                .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                .foregroundStyle(selected ? .white : AuraTheme.mauveSubtext)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(selected ? AnyShapeStyle(AuraTheme.ribbonGradient) : AnyShapeStyle(AuraTheme.balletBlush))
                                )
                        }
                        .buttonStyle(CoquettePressButtonStyle())
                    }
                    Spacer()
                }

                if filteredPairs.isEmpty {
                    VStack(spacing: 8) {
                        CoquetteBowEmblem(size: 28, tint: AuraTheme.coquettePink)
                        Text("No matching pairs in this ribbon view")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundStyle(AuraTheme.plumInk)
                        Text("Save a pairing from the Wheel or Harmonics studio to persist it with SwiftData.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(AuraTheme.whisperedMauve)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    VStack(spacing: 11) {
                        ForEach(filteredPairs, id: \.pairID) { pair in
                            savedPairRow(pair)
                        }
                    }
                }
            }
            .padding(16)
            .porcelainCard(cornerRadius: 24)

            // Section 2: Undoable Action Ledger Chronicle
            ActionLedgerPanelView(studio: studio)
        }
    }

    private func savedPairRow(_ pair: SavedProfilePair) -> some View {
        let pA = pair.astroProfileA
        let pB = pair.astroProfileB

        return VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .center, spacing: 10) {
                // Dual Glyph Badge
                HStack(spacing: 3) {
                    Text(pA.sign.glyph)
                    Text("×")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AuraTheme.coquettePink)
                    Text(pB.sign.glyph)
                }
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AuraTheme.raspberryVelvet)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AuraTheme.balletBlush)
                )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(pair.pairTitle)
                            .font(.system(size: 14.5, weight: .bold, design: .serif))
                            .foregroundStyle(AuraTheme.plumInk)
                        Text(pair.ribbonTag)
                            .font(.system(size: 9.5, weight: .bold, design: .rounded))
                            .foregroundStyle(AuraTheme.raspberryVelvet)
                            .padding(.horizontal, 6.5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AuraTheme.rosewaterMist))
                    }
                    Text("\(pA.formattedDateLabel) · \(pB.formattedDateLabel)")
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(AuraTheme.mauveSubtext)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                // Compatibility Score Pill
                VStack(alignment: .trailing, spacing: 1) {
                    Text("\(pair.compatibilityScore)%")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(AuraTheme.raspberryVelvet)
                    Text(pair.aspectName)
                        .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(AuraTheme.whisperedMauve)
                }
            }

            if !pair.personalNote.isEmpty {
                Text("“\(pair.personalNote)”")
                    .font(.system(size: 11.5, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(AuraTheme.mauveSubtext)
            }

            HStack(spacing: 8) {
                Button {
                    onRecallPair(pair)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                        Text("Load into Wheel")
                    }
                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(AuraTheme.raspberryVelvet)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AuraTheme.balletBlush)
                            .overlay(Capsule().stroke(AuraTheme.petalSilk, lineWidth: 0.9))
                    )
                }
                .buttonStyle(CoquettePressButtonStyle())

                Spacer()

                Button {
                    studio.toggleFavorite(pair: pair, context: modelContext)
                } label: {
                    Image(systemName: pair.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(pair.isFavorite ? AuraTheme.raspberryVelvet : AuraTheme.whisperedMauve)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(AuraTheme.porcelainTop))
                        .overlay(Circle().stroke(AuraTheme.petalSilk, lineWidth: 0.8))
                }
                .buttonStyle(CoquettePressButtonStyle())
                .accessibilityLabel(pair.isFavorite ? "Unpin favorite" : "Pin favorite")

                Button {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                        studio.deletePairFromVault(pair, context: modelContext)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(AuraTheme.mauveSubtext)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(AuraTheme.porcelainTop))
                        .overlay(Circle().stroke(AuraTheme.petalSilk, lineWidth: 0.8))
                }
                .buttonStyle(CoquettePressButtonStyle())
                .accessibilityLabel("Delete saved pair")
            }
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AuraTheme.petalSilk.opacity(0.85), lineWidth: 1)
                )
        )
    }
}

struct ActionLedgerPanelView: View {
    @Environment(\.modelContext) private var modelContext
    let studio: StudioController

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Undoable Action Ledger")
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(AuraTheme.plumInk)
                    Text("Deterministic state history · \(studio.undoStack.count) undoable, \(studio.redoStack.count) redoable")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AuraTheme.whisperedMauve)
                }

                Spacer()

                HStack(spacing: 7) {
                    Button {
                        studio.performUndo(context: modelContext)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Undo")
                        }
                        .font(.system(size: 11.5, weight: .bold, design: .rounded))
                        .foregroundStyle(studio.canUndo ? .white : AuraTheme.whisperedMauve)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6.5)
                        .background(
                            Capsule()
                                .fill(studio.canUndo ? AnyShapeStyle(AuraTheme.ribbonGradient) : AnyShapeStyle(AuraTheme.balletBlush))
                        )
                    }
                    .disabled(!studio.canUndo)
                    .buttonStyle(CoquettePressButtonStyle())

                    Button {
                        studio.performRedo(context: modelContext)
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundStyle(studio.canRedo ? AuraTheme.raspberryVelvet : AuraTheme.whisperedMauve.opacity(0.55))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(AuraTheme.balletBlush))
                    }
                    .disabled(!studio.canRedo)
                    .buttonStyle(CoquettePressButtonStyle())
                }
            }

            if studio.undoStack.isEmpty && studio.redoStack.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 16))
                        .foregroundStyle(AuraTheme.coquettePink)
                    Text("Edit any birth date, swap souls, or catalog a pair—every action will chronicle here with instant Undo.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AuraTheme.mauveSubtext)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AuraTheme.balletBlush.opacity(0.65))
                )
            } else {
                VStack(spacing: 9) {
                    ForEach(Array(studio.undoStack.prefix(10).enumerated()), id: \.element.id) { index, entry in
                        HStack(alignment: .top, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(index == 0 ? AuraTheme.raspberryVelvet : AuraTheme.rosewaterMist)
                                    .frame(width: 28, height: 28)
                                Image(systemName: entry.category.symbolName)
                                    .font(.system(size: 11.5, weight: .semibold))
                                    .foregroundStyle(index == 0 ? Color.white : AuraTheme.raspberryVelvet)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(entry.title)
                                        .font(.system(size: 13, weight: .semibold, design: .serif))
                                        .foregroundStyle(AuraTheme.plumInk)
                                    Spacer()
                                    if entry.scoreBefore != entry.scoreAfter {
                                        Text("\(entry.scoreBefore)% → \(entry.scoreAfter)%")
                                            .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                            .foregroundStyle(AuraTheme.raspberryVelvet)
                                    } else {
                                        Text("\(entry.scoreAfter)%")
                                            .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                            .foregroundStyle(AuraTheme.whisperedMauve)
                                    }
                                }

                                Text(entry.detail)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(AuraTheme.mauveSubtext)

                                Text("\(entry.category.rawValue) · \(entry.timestamp.formatted(date: .omitted, time: .standard))")
                                    .font(.system(size: 9.5, weight: .medium, design: .rounded))
                                    .foregroundStyle(AuraTheme.whisperedMauve)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(index == 0 ? AuraTheme.porcelainTop : Color.white.opacity(0.75))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(AuraTheme.petalSilk.opacity(index == 0 ? 1.0 : 0.55), lineWidth: 0.9)
                                )
                        )
                    }
                }
            }
        }
        .padding(16)
        .porcelainCard(cornerRadius: 24)
    }
}

// MARK: - 11. Root AuraZodiac Experience View & Navigation

enum AuraTab: String, CaseIterable {
    case celestial = "Celestial"
    case harmonics = "Harmonics"
    case archive   = "Vault & Ledger"

    var icon: String {
        switch self {
        case .celestial: return "sparkles"
        case .harmonics: return "heart.circle"
        case .archive:   return "book.closed"
        }
    }
}

struct AuraZodiacRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \SavedProfilePair.updatedAt, order: .reverse) private var savedPairs: [SavedProfilePair]

    @State private var motionManager = MotionManager()
    @State private var studio = StudioController()
    @State private var activeTab: AuraTab = .celestial
    @State private var inspectedSign: ZodiacSign? = nil
    @State private var swapRotationAngle: Double = 0.0
    @State private var showLedgerSheet: Bool = false
    @State private var didBootstrap: Bool = false

    @Namespace private var tabNamespace

    var body: some View {
        let report = studio.currentReport

        ZStack(alignment: .bottom) {
            AuraTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Ultra-clean Coquette Header + Gyro & Undo Controls
                topCelestialHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                // Satin Sliding Segmented Bar
                coquetteTabSelector
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                // Main Scrollable Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        switch activeTab {
                        case .celestial:
                            celestialStudioContent(report: report)
                        case .harmonics:
                            SynastryHarmonicsView(report: report) {
                                studio.saveCurrentPairToVault(context: modelContext)
                            }
                        case .archive:
                            CelestialVaultAndLedgerView(studio: studio) { pair in
                                studio.recallPairFromVault(pair, context: modelContext)
                                withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                                    activeTab = .celestial
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 54)
                }
            }

            // Delicate Floating Coquette Toast Banner
            if let toast = studio.lastToastBanner {
                HStack(spacing: 8) {
                    CoquetteBowEmblem(size: 18, tint: .white)
                    Text(toast)
                        .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AuraTheme.plumInk.opacity(0.90))
                        .shadow(color: AuraTheme.raspberryVelvet.opacity(0.28), radius: 12, x: 0, y: 6)
                )
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showLedgerSheet) {
            NavigationStack {
                ScrollView {
                    ActionLedgerPanelView(studio: studio)
                        .padding(16)
                }
                .background(AuraTheme.backgroundGradient.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showLedgerSheet = false }
                            .foregroundStyle(AuraTheme.raspberryVelvet)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            if !didBootstrap {
                didBootstrap = true
                studio.bootstrapFromSwiftData(context: modelContext)
            }
            motionManager.startPolling()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                motionManager.startPolling()
            case .inactive, .background:
                // Enforce structural persistence flush & clean sensor sleep across app lifecycle states
                studio.persistWorkspaceState(context: modelContext)
                try? modelContext.save()
                motionManager.pausePolling()
            @unknown default:
                break
            }
        }
    }

    // MARK: Header & Tab Subviews

    private var topCelestialHeader: some View {
        HStack(spacing: 10) {
            CoquetteBowEmblem(size: 28, tint: AuraTheme.raspberryVelvet)

            VStack(alignment: .leading, spacing: 1) {
                Text("AuraZodiac")
                    .font(.system(size: 21, weight: .bold, design: .serif))
                    .foregroundStyle(AuraTheme.plumInk)

                // Live Gyroscope Telemetry Subtitle
                Button {
                    AuraHaptics.crispTick()
                    motionManager.celestialBreezeEnabled.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(motionManager.isPolling ? AuraTheme.sageMist : AuraTheme.whisperedMauve)
                            .frame(width: 6, height: 6)
                        Text(
                            motionManager.isHardwareGyroAvailable
                                ? String(format: "Gyro 60Hz · Tilt %+.0f°/%+.0f°", motionManager.pitchDegrees, motionManager.rollDegrees)
                                : (motionManager.celestialBreezeEnabled
                                    ? String(format: "Gyro Breeze · %+.0f°/%+.0f°", motionManager.pitchDegrees, motionManager.rollDegrees)
                                    : "Gyro Paused · Tap for Breeze")
                        )
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AuraTheme.mauveSubtext)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Instant Undo & Ledger Drawer Pills
            HStack(spacing: 6) {
                Button {
                    studio.performUndo(context: modelContext)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 11, weight: .bold))
                        if !studio.undoStack.isEmpty {
                            Text("\(studio.undoStack.count)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                        }
                    }
                    .foregroundStyle(studio.canUndo ? AuraTheme.raspberryVelvet : AuraTheme.whisperedMauve.opacity(0.55))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .overlay(Capsule().stroke(AuraTheme.petalSilk, lineWidth: 1))
                    )
                }
                .disabled(!studio.canUndo)
                .buttonStyle(CoquettePressButtonStyle())
                .accessibilityLabel("Undo last action")

                Button {
                    AuraHaptics.crispTick()
                    showLedgerSheet = true
                } label: {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundStyle(AuraTheme.plumInk)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .overlay(Circle().stroke(AuraTheme.petalSilk, lineWidth: 1))
                        )
                }
                .buttonStyle(CoquettePressButtonStyle())
                .accessibilityLabel("Open Action Ledger")
            }
        }
    }

    private var coquetteTabSelector: some View {
        HStack(spacing: 6) {
            ForEach(AuraTab.allCases, id: \.rawValue) { tab in
                let isSelected = activeTab == tab
                Button {
                    AuraHaptics.crispTick()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.76)) {
                        activeTab = tab
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 11.5, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                        if tab == .archive && !savedPairs.isEmpty {
                            Text("\(savedPairs.count)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule().fill(isSelected ? Color.white.opacity(0.26) : AuraTheme.rosewaterMist)
                                )
                        }
                    }
                    .foregroundStyle(isSelected ? Color.white : AuraTheme.mauveSubtext)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(AuraTheme.ribbonGradient)
                                .matchedGeometryEffect(id: "activeSatinTab", in: tabNamespace)
                                .shadow(color: AuraTheme.raspberryVelvet.opacity(0.25), radius: 8, x: 0, y: 3)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.84))
                .overlay(Capsule().stroke(AuraTheme.petalSilk, lineWidth: 1))
        )
    }

    // MARK: Tab 1 — Celestial Wheel & Dual Smart-Parser Studio

    private func celestialStudioContent(report: SynastryReport) -> some View {
        VStack(spacing: 14) {
            // Interactive 3D Gyro Constellation Wheel
            InteractiveConstellationWheelView(
                motionManager: motionManager,
                report: report,
                inspectedSign: $inspectedSign
            )

            // Compact Live Synastry Summary Strip (tappable to jump into full Harmonics breakdown)
            Button {
                AuraHaptics.softTap()
                withAnimation(.spring(response: 0.38, dampingFraction: 0.76)) {
                    activeTab = .harmonics
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(report.ribbonTier) · \(report.elementalHeadline)")
                            .font(.system(size: 13.5, weight: .bold, design: .serif))
                            .foregroundStyle(AuraTheme.plumInk)
                        Text("\(report.profileA.name) (\(report.profileA.sign.rawValue)) \(report.aspect.glyph) \(report.profileB.name) (\(report.profileB.sign.rawValue)) · Tap for 4-pillar chart")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(AuraTheme.mauveSubtext)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(report.overallScore)%")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .contentTransition(.numericText())
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AuraTheme.raspberryVelvet)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AuraTheme.balletBlush))
                }
                .padding(14)
                .porcelainCard(cornerRadius: 20)
            }
            .buttonStyle(CoquettePressButtonStyle())

            // Soul A Smart-Regex Card
            SmartProfileEditorCard(
                roleLabel: "Soul I · Ascendant Lead",
                isSoulA: true,
                profile: studio.profileA,
                rawText: $studio.draftInputA,
                onCommitName: { studio.updateName(isSoulA: true, newName: $0, context: modelContext) },
                onParsedDate: { raw, parsed in
                    studio.applyParsedDate(isSoulA: true, rawText: raw, parsed: parsed, context: modelContext)
                }
            )

            // Coquette Polarity Swap Divider
            HStack(spacing: 12) {
                Rectangle()
                    .fill(AuraTheme.petalSilk.opacity(0.7))
                    .frame(height: 1)

                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                        swapRotationAngle += 180
                    }
                    studio.swapSouls(context: modelContext)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11, weight: .bold))
                            .rotationEffect(.degrees(swapRotationAngle))
                        Text("Swap Souls")
                            .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(AuraTheme.raspberryVelvet)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: AuraTheme.coquettePink.opacity(0.20), radius: 6, x: 0, y: 2)
                            .overlay(Capsule().stroke(AuraTheme.petalSilk, lineWidth: 1))
                    )
                }
                .buttonStyle(CoquettePressButtonStyle())

                Rectangle()
                    .fill(AuraTheme.petalSilk.opacity(0.7))
                    .frame(height: 1)
            }
            .padding(.horizontal, 8)

            // Soul B Smart-Regex Card
            SmartProfileEditorCard(
                roleLabel: "Soul II · Celestial Mirror",
                isSoulA: false,
                profile: studio.profileB,
                rawText: $studio.draftInputB,
                onCommitName: { studio.updateName(isSoulA: false, newName: $0, context: modelContext) },
                onParsedDate: { raw, parsed in
                    studio.applyParsedDate(isSoulA: false, rawText: raw, parsed: parsed, context: modelContext)
                }
            )

            // Save to SwiftData Vault Card with Ribbon Tag Picker
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    CoquetteBowEmblem(size: 20, tint: AuraTheme.raspberryVelvet)
                    Text("Catalog Pair to SwiftData Vault")
                        .font(.system(size: 14.5, weight: .bold, design: .serif))
                        .foregroundStyle(AuraTheme.plumInk)
                    Spacer()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 7) {
                        ForEach(StudioController.ribbonTags, id: \.self) { tag in
                            let selected = studio.selectedRibbonTag == tag
                            Button {
                                AuraHaptics.crispTick()
                                studio.selectedRibbonTag = tag
                                studio.persistWorkspaceState(context: modelContext)
                            } label: {
                                Text(tag)
                                    .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                                    .foregroundStyle(selected ? .white : AuraTheme.mauveSubtext)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 5.5)
                                    .background(
                                        Capsule()
                                            .fill(selected ? AnyShapeStyle(AuraTheme.ribbonGradient) : AnyShapeStyle(AuraTheme.balletBlush))
                                    )
                            }
                            .buttonStyle(CoquettePressButtonStyle())
                        }
                    }
                }

                TextField("Whispered note (optional, e.g. Met at the rose conservatory)...", text: $studio.studioNote)
                    .font(.system(size: 12.5, design: .rounded))
                    .foregroundStyle(AuraTheme.plumInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8.5)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AuraTheme.petalSilk, lineWidth: 0.9)
                            )
                    )

                Button {
                    studio.saveCurrentPairToVault(context: modelContext)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                        Text("Save \"\(studio.profileA.name) × \(studio.profileB.name)\" (\(report.overallScore)%)")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 13.5, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.5)
                    .background(Capsule().fill(AuraTheme.ribbonGradient))
                    .shadow(color: AuraTheme.raspberryVelvet.opacity(0.25), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(CoquettePressButtonStyle())
            }
            .padding(15)
            .porcelainCard(cornerRadius: 22)
        }
    }
}

// MARK: - 12. @main App Entry & Persistent SwiftData ModelContainer

@main
struct AuraZodiacApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedProfilePair.self,
            StudioWorkspaceRecord.self
        ])
        let persistentConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            // Safe in-memory fallback only if sandboxed disk path is restricted during previews
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("AuraZodiac failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            AuraZodiacRootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}

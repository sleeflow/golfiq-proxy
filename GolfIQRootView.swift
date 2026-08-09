import SwiftUI
import Foundation
import Combine
import CoreLocation

// MARK: - Brand Identity

struct GolfIQBrand {
    static let primary = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let accent = Color(red: 0.08, green: 0.72, blue: 0.42)
    static let accentSoft = Color(red: 0.08, green: 0.72, blue: 0.42).opacity(0.15)
    static let tagline = "PLAY SMART.  STAY CALM.  SCORE LOWER."
    static let feedbackEmail = "sleeflow@gmail.com"
}

// MARK: - Splash Screen

struct SplashView: View {
    @State private var opacity = 0.0
    @State private var scale = 0.85
    @State private var taglineOpacity = 0.0

    var body: some View {
        ZStack {
            GolfIQBrand.primary.ignoresSafeArea()
            VStack(spacing: 28) {
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 8) {
                        Text("Caddie Edge")
                            .font(.system(size: 38, weight: .bold, design: .serif))
                            .foregroundColor(.white)
                        Image("GolfIQLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                    }
                    Text(GolfIQBrand.tagline)
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundColor(GolfIQBrand.accent)
                        .opacity(taglineOpacity)
                }
            }
            .scaleEffect(scale).opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { opacity = 1.0; scale = 1.0 }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) { taglineOpacity = 1.0 }
        }
    }
}

struct GolfIQRootView: View {
    @State private var showSplash = true
    var body: some View {
        ZStack {
            if showSplash { SplashView().transition(.opacity) }
            else { ContentView().transition(.opacity) }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
            }
        }
    }
}

// MARK: - Course Models

struct GolfHole: Identifiable {
    let id: Int
    let par: Int
    let yards: Int
    let handicap: Int
}

struct GolfCourse: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let rating: Double
    let slope: Int
    let par: Int
    let yards: Int
    let holes: [GolfHole]
    var isComingSoon: Bool = false

    var difficultyLabel: String {
        switch slope {
        case ..<110: return "Beginner Friendly"
        case 110..<120: return "Moderate"
        case 120..<130: return "Challenging"
        case 130..<140: return "Very Difficult"
        default: return "Extremely Difficult"
        }
    }
}

// MARK: - Mental Game Models

struct MentalTip: Identifiable {
    let id = UUID()
    let quote: String
    let situation: MentalSituation
    let philosophy: MentalPhilosophy
    let voice: MentalVoice
}

enum MentalSituation: String, CaseIterable {
    case eaglePlus = "Eagle or Better"
    case birdie = "Birdie Mindset"
    case par = "Stay Steady"
    case bogey = "Recovery"
    case double = "Reset Now"
    case triple = "Resilience"
    case preShot = "Before the Shot"
    case startStrong = "Starting Strong"
    case stayPatient = "Stay Patient"
    case closingOut = "Closing Out"
    case pressureMoment = "Pressure Moments"
    case recoveryMode = "Recovery Mode"

    var icon: String {
        switch self {
        case .eaglePlus: return "🦅"
        case .birdie: return "🐦"
        case .par: return "✅"
        case .bogey: return "🔄"
        case .double: return "💭"
        case .triple: return "💪"
        case .preShot: return "🎯"
        case .startStrong: return "🌅"
        case .stayPatient: return "⏳"
        case .closingOut: return "🏁"
        case .pressureMoment: return "⚡"
        case .recoveryMode: return "🧘"
        }
    }
}

enum MentalPhilosophy: String {
    case processAndCommitment = "Process & Commitment"
    case confidenceAndTrust = "Confidence & Trust"
    case zenPresence = "Zen Presence"
    case fearlessness = "Fearlessness"
}

enum MentalVoice: String {
    case caddy = "Caddy"
    case coach = "Coach"
}

class MentalGame: ObservableObject {
    @Published var shownTipIDs: Set<UUID> = []

    func tipForScore(score: Int, par: Int) -> MentalTip {
        let diff = score - par
        let pool: [MentalTip]
        switch diff {
        case ...(-2): pool = MentalTipLibrary.eagleTips
        case -1: pool = MentalTipLibrary.birdieTips
        case 0: pool = MentalTipLibrary.parTips
        case 1: pool = MentalTipLibrary.bogeyTips
        case 2: pool = MentalTipLibrary.doubleTips
        default: pool = MentalTipLibrary.tripleTips
        }
        return freshTip(from: pool)
    }

    func preShotTip(lie: String, hazards: String, holeNumber: Int) -> MentalTip {
        if hazards != "None" { return freshTip(from: MentalTipLibrary.pressureTips) }
        if lie == "Sand" || lie == "Rough" { return freshTip(from: MentalTipLibrary.recoveryTips) }
        if holeNumber == 1 { return freshTip(from: MentalTipLibrary.startStrongTips) }
        if holeNumber >= 16 { return freshTip(from: MentalTipLibrary.closingTips) }
        return freshTip(from: MentalTipLibrary.preShotTips)
    }

    func freshTip(from pool: [MentalTip]) -> MentalTip {
        let unseen = pool.filter { !shownTipIDs.contains($0.id) }
        let selected = unseen.isEmpty ? pool.randomElement()! : unseen.randomElement()!
        shownTipIDs.insert(selected.id)
        return selected
    }

    func resetRound() { shownTipIDs = [] }
}

// MARK: - Mental Tip Library

struct MentalTipLibrary {

    static let eagleTips: [MentalTip] = [
        MentalTip(quote: "Stay even. The course doesn't know what you just made. Every hole starts at zero.", situation: .eaglePlus, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "The danger after a great shot is letting excitement pull you away from your routine on the very next one.", situation: .eaglePlus, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Momentum is real but fragile. Protect it by treating the next shot exactly like the last.", situation: .eaglePlus, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "A quiet mind after a great result is the mark of a mature golfer. Celebrate inside, then reset.", situation: .eaglePlus, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "The best players know that excellence is not a reason to relax — it's a reason to stay present.", situation: .eaglePlus, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "You earned that. Now let it go completely and give the next hole the same focus.", situation: .eaglePlus, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "One great hole doesn't win a round. Stay in your process and let the score take care of itself.", situation: .eaglePlus, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Champions feel the joy briefly, then return to the routine that produced it.", situation: .eaglePlus, philosophy: .confidenceAndTrust, voice: .coach),
    ]

    static let birdieTips: [MentalTip] = [
        MentalTip(quote: "One shot at a time. You can't bank birdies — you can only play the shot in front of you.", situation: .birdie, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Good players don't think about their score while they're making it. Stay in the process.", situation: .birdie, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "After a birdie, take a breath and reset. The next hole doesn't care about the last one.", situation: .birdie, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Play each shot as if it's the only one you'll hit all day. Complete presence, every time.", situation: .birdie, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Trust is built one committed shot at a time. You just proved it works — keep trusting.", situation: .birdie, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "The golfer who stays fearless after a birdie is dangerous. Don't back off now.", situation: .birdie, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Your pre-shot routine produced that birdie. Honor it by using it again on every shot.", situation: .birdie, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Scoring comes in clusters when you stay present. Breathe, reset, and keep going.", situation: .birdie, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "A fearless golfer doesn't protect a lead — they extend it. Same commitment, next hole.", situation: .birdie, philosophy: .fearlessness, voice: .coach),
    ]

    static let parTips: [MentalTip] = [
        MentalTip(quote: "Par is always a good score. Never be disappointed by a par — build on it.", situation: .par, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Eighteen pars beats most scorecards. Stay patient and let the birdies come to you.", situation: .par, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Solid is underrated. A round built on smart decisions is a round built to last.", situation: .par, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "The golfer who makes the most pars wins more often than not. Keep doing what you're doing.", situation: .par, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Stay in the moment. Each shot is its own complete experience — not a stepping stone to the next.", situation: .par, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Patience is a weapon. Play within yourself and trust the round will come to you.", situation: .par, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "A committed swing to a clear target is always the right play. You just did that.", situation: .par, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Purpose on every shot means every shot matters — including the ones that make par.", situation: .par, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "The present shot is the only shot. Past holes and future holes are just distractions.", situation: .par, philosophy: .zenPresence, voice: .caddy),
    ]

    static let bogeyTips: [MentalTip] = [
        MentalTip(quote: "One bogey changes nothing. The round is still completely in front of you.", situation: .bogey, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Walk to the next tee with your head up. Your body language tells your mind how to feel.", situation: .bogey, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Every great round has a bogey in it somewhere. The best players simply move on.", situation: .bogey, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Let it go completely. The ability to release a bad hole instantly is a learnable skill.", situation: .bogey, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "You are not your last shot. Bring full commitment and a clear mind to this next tee.", situation: .bogey, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Resilience is built one reset at a time. This is your moment to practice it.", situation: .bogey, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Trust your swing. One bogey doesn't mean anything is broken — stay the course.", situation: .bogey, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "A clear target and a committed swing on the next hole is all you need right now.", situation: .bogey, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "The score is just information. What matters is how you respond to it.", situation: .bogey, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Golfers who score well aren't those who avoid bogeys — they're those who forget them fastest.", situation: .bogey, philosophy: .confidenceAndTrust, voice: .coach),
    ]

    static let doubleTips: [MentalTip] = [
        MentalTip(quote: "Stop the bleeding. Par the next three and nobody will remember this hole — including you.", situation: .double, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Every great round has a storm in it. You've hit yours. Now play the round of your life from here.", situation: .double, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Control what you can control. You own every shot from this moment forward.", situation: .double, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "The worst thing after a double is trying to get it back immediately. Play smart, not hard.", situation: .double, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "A quiet mind after adversity is your greatest competitive advantage. Find it now.", situation: .double, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "This hole is done. Close the book on it completely and open a new one right now.", situation: .double, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Fear of more mistakes causes more mistakes. Commit fearlessly to the next shot.", situation: .double, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Purpose and presence — that's all you need right now. One clear shot at a time.", situation: .double, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "The golfer who recovers fastest after a big number usually finishes strongest.", situation: .double, philosophy: .confidenceAndTrust, voice: .coach),
    ]

    static let tripleTips: [MentalTip] = [
        MentalTip(quote: "It's one hole. This game is eighteen. Walk to the next tee like someone who knows that.", situation: .triple, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "The mental strength to walk off a disaster with your chin up is exactly what separates players.", situation: .triple, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Write the number down, close the book, and start completely fresh. That hole no longer exists.", situation: .triple, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Resilience isn't the absence of adversity — it's what you do the very next shot after it.", situation: .triple, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Your mind will try to replay that hole. Refuse to let it. Be here, on this tee, right now.", situation: .triple, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Some of the best rounds ever played had a disaster hole in them. Yours might be one of them.", situation: .triple, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "One bad hole followed by a great attitude is still a recoverable round. Go prove it.", situation: .triple, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Reset completely. One shot at a time, one target at a time, one committed swing at a time.", situation: .triple, philosophy: .processAndCommitment, voice: .caddy),
    ]

    static let preShotTips: [MentalTip] = [
        MentalTip(quote: "Pick a small, specific target. The smaller the target, the sharper the focus.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Once you've decided on the shot, commit to it completely. Half-committed swings produce whole mistakes.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "Trust your preparation. You've hit this shot before. Let it happen.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "A smooth swing with full confidence beats a perfect swing with doubt every single time.", situation: .preShot, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Take dead aim. Pick your target, commit fully, and let the swing go.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Every shot must have a purpose. Know exactly what you want before you step into the ball.", situation: .preShot, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "See the shot clearly in your mind before you swing. Visualization is not optional — it's the shot.", situation: .preShot, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Breathe out slowly before you start your swing. Let tension leave with the breath.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Your only job right now is this shot. Not the last one, not the next one. This one.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Fearless golf means swinging to a target, not swinging away from trouble. Pick your spot.", situation: .preShot, philosophy: .fearlessness, voice: .coach),
    ]

    static let pressureTips: [MentalTip] = [
        MentalTip(quote: "Commit to your target, not to what you're avoiding. The mind goes where the eye leads.", situation: .pressureMoment, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Pick your landing spot and trust it completely. Doubt is more dangerous than any hazard.", situation: .pressureMoment, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "See the shot you want to hit, not the trouble you want to miss. Visualize only success.", situation: .pressureMoment, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Pressure is a privilege. It means something is at stake. Embrace it and swing free.", situation: .pressureMoment, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "The hazard doesn't matter. Your target does. Find it, trust it, commit to it.", situation: .pressureMoment, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "A fearless player aims at where they want the ball to go — not away from where they don't.", situation: .pressureMoment, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Slow your breathing, narrow your focus to the target, and trust your swing completely.", situation: .pressureMoment, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Every great shot under pressure started with a clear mind and a committed target.", situation: .pressureMoment, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "Your routine is your anchor in pressure moments. Use it exactly as you always do.", situation: .pressureMoment, philosophy: .processAndCommitment, voice: .caddy),
    ]

    static let recoveryTips: [MentalTip] = [
        MentalTip(quote: "From a tough spot, your only job is to get back in play. Take your medicine and move forward.", situation: .recoveryMode, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "A hero shot from trouble usually costs two. The smart play is always the right play.", situation: .recoveryMode, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Accept the situation completely. Fighting reality costs strokes. Work with what you have.", situation: .recoveryMode, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "The best recovery shot is the one with the highest percentage of success. Pick that one.", situation: .recoveryMode, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Extraordinary golf means playing every lie as if it's exactly the lie you wanted.", situation: .recoveryMode, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Trust your hands from here. You've played from worse. Pick a target and commit.", situation: .recoveryMode, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Trouble is temporary. A committed recovery shot followed by a good attitude changes everything.", situation: .recoveryMode, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "One shot at a time means this shot matters more than the one that got you here.", situation: .recoveryMode, philosophy: .processAndCommitment, voice: .caddy),
    ]

    static let startStrongTips: [MentalTip] = [
        MentalTip(quote: "Start with a smooth, comfortable swing. The first hole is about finding rhythm, not proving anything.", situation: .startStrong, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Play the first hole like it's the tenth — no nerves, no extra effort, just your normal game.", situation: .startStrong, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "Your only goal on the first tee is to commit to a target and trust your swing completely.", situation: .startStrong, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Every great round starts with one purposeful shot. This is that shot. Be present for it.", situation: .startStrong, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Breathe. You've hit this shot thousands of times. Today is no different.", situation: .startStrong, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "A fearless first swing sets the tone for the whole round. Commit and let it go.", situation: .startStrong, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "The round begins right here, right now, with this one shot. Give it your full presence.", situation: .startStrong, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Pick the smallest target you can find and swing to it with complete confidence.", situation: .startStrong, philosophy: .processAndCommitment, voice: .caddy),
    ]

    static let patientTips: [MentalTip] = [
        MentalTip(quote: "Patience is one of the most powerful weapons in golf. Let the round come to you.", situation: .stayPatient, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "You don't have to force anything. Trust your process and the score will take care of itself.", situation: .stayPatient, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Golf rewards the golfer who stays in the present moment regardless of what the scorecard says.", situation: .stayPatient, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Every shot has a purpose. Stay connected to that purpose and patience becomes natural.", situation: .stayPatient, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "The middle of a round is where rounds are really won. Stay steady and keep your routine.", situation: .stayPatient, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Don't add pressure by checking your score too often. Play the shot, not the number.", situation: .stayPatient, philosophy: .fearlessness, voice: .coach),
    ]

    static let closingTips: [MentalTip] = [
        MentalTip(quote: "These are the holes that define your round. Play them with the same routine you used on hole one.", situation: .closingOut, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Don't protect a score — play golf. Protective swings cause the very mistakes you're trying to avoid.", situation: .closingOut, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Stay in the present. The final holes reward the golfer who is most in the moment right now.", situation: .closingOut, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Commit to every shot as if the round depends on it — because right now, it does.", situation: .closingOut, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Fearless golf on the closing holes means trusting everything you've built all round.", situation: .closingOut, philosophy: .fearlessness, voice: .coach),
        MentalTip(quote: "Your pre-shot routine is your anchor when the pressure rises. Use it on every single shot.", situation: .closingOut, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "The golfer who finishes strong is the one who stayed present when others started thinking ahead.", situation: .closingOut, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Take dead aim. Small target, full commitment, free swing. That's all there is.", situation: .closingOut, philosophy: .confidenceAndTrust, voice: .caddy),
    ]

    // MARK: Putting Cues — 4 Categories

    static let shortPuttCues: [MentalTip] = [
        MentalTip(quote: "See the back of the cup and roll it there. Simple as that.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Pick your spot just in front of the ball and roll it over that spot.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Stay in the blue. Calm, still, one smooth stroke. You've made this putt before.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Give it a chance — hit it with enough pace to reach the back of the cup.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Breathe out. Soften your grip. One smooth roll.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Just a putt. Pick your line, trust your read, roll it in.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Look at the hole, trust your hands. They know what to do.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "One clear target, one smooth stroke. The cup isn't going anywhere.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Been here before. Commit to the line and roll it with confidence.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Positive, committed, free. Roll it in.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Pick the back of the cup. Commit. Roll it there.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Stay calm, pick your target, trust your stroke.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
    ]

    static let midRangePuttCues: [MentalTip] = [
        MentalTip(quote: "Pick your spot on the line and roll it over that spot. Speed first.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "See the whole line, trust your read, roll it with smooth tempo.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Calm and committed. Pick your line and trust it.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Been here before. Trust what you saw walking up to the ball.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Smooth tempo, clear target, free stroke. That's all it takes.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Read it, trust it, roll it. No second guessing.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Pick your intermediate target and roll it over that spot.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Just a putt. Stay calm, commit to the read, let the stroke happen.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Read it, trust it, forget it. Just roll it smooth.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Positive read, committed stroke.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Every putt is makeable — see it going in and roll it there.", situation: .preShot, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Your only job is to start it on the line at the right speed.", situation: .preShot, philosophy: .processAndCommitment, voice: .coach),
    ]

    static let lagPuttCues: [MentalTip] = [
        MentalTip(quote: "Speed is everything — feel the distance in your practice stroke and trust it.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Pick a two-foot circle around the hole and lag it in there.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Smooth and slow — this is all about feel and tempo.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Get the speed right and the line takes care of itself.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Been here before. Trust your feel — your hands know this distance.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Two putts is the goal. Get it close.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Breathe out, relax your arms, let the putter swing naturally.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Big stroke, soft hands. Roll it to within a couple feet.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Visualize the ball rolling up close and trust that image.", situation: .preShot, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Feel the distance. Your instincts are better than you think.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "A well-lagged putt that finishes close is just as good as making it.", situation: .preShot, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Positive, free, roll it with good tempo.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
    ]

    static let pressurePuttCues: [MentalTip] = [
        MentalTip(quote: "Just another putt — same routine, same read, same stroke.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Calm, quiet, one smooth roll.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "You in the game. Commit to the line and roll it free.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Been here before. Trust your read and trust your stroke.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Your routine is your anchor — use it just like always.", situation: .preShot, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "See it going in. Roll it in.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "One breath. One target. One smooth stroke.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "This is the game you love. Pick your line and enjoy the moment.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Soft grip, quiet mind. Roll it on the line.", situation: .preShot, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Read it, trust it, commit to it. The rest takes care of itself.", situation: .preShot, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Calm hands, clear target. You've made this before.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Dead aim, smooth stroke, let it go.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Your hands remember every putt you've ever made. Trust them.", situation: .preShot, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "Positive, committed, free. This is your moment.", situation: .preShot, philosophy: .fearlessness, voice: .caddy),
    ]

    static let puttingCues: [MentalTip] = shortPuttCues + midRangePuttCues + lagPuttCues + pressurePuttCues

    // MARK: - Streak Tips

    static let birdieStreakTips: [MentalTip] = [
        MentalTip(quote: "You're locked in right now. Same routine, same trust — keep it rolling.", situation: .birdie, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Momentum is yours. Not to worry about anything — just keep doing what you're doing.", situation: .birdie, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "You in the game right now. Stay there — one shot at a time, same focus.", situation: .birdie, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Something special happening out here. Trust the process and let it keep going.", situation: .birdie, philosophy: .confidenceAndTrust, voice: .coach),
        MentalTip(quote: "Stay even. The best thing you can do with momentum is protect it with your routine.", situation: .birdie, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "You're playing free. Don't change a thing — same target, same swing, same trust.", situation: .birdie, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Momentum is real — and it's yours right now. Stay calm and keep riding it.", situation: .birdie, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "Back-to-back. Stay present. The next hole doesn't know what just happened.", situation: .birdie, philosophy: .zenPresence, voice: .caddy),
    ]

    static let parStreakTips: [MentalTip] = [
        MentalTip(quote: "That's your game right there. Steady and smart — keep the process going.", situation: .par, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Solid golf, hole after hole. Not to worry about birdies — pars win rounds.", situation: .par, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Consistent. Calm. In control. That's exactly what this game rewards.", situation: .par, philosophy: .zenPresence, voice: .coach),
        MentalTip(quote: "You're building something here. Stay patient and trust the round to come to you.", situation: .par, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Par after par — that's great golf. Stay even and keep doing exactly this.", situation: .par, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Steady wins. You're making smart decisions and it's showing. Keep it up.", situation: .par, philosophy: .fearlessness, voice: .caddy),
    ]

    static let bogeyStreakTips: [MentalTip] = [
        MentalTip(quote: "Not to worry — but let's pump the brakes. One smart hole resets everything.", situation: .bogey, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Time to simplify. Pick the safest target on the next hole and trust one good swing.", situation: .bogey, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Not to worry. Been here before — one good decision and the round turns around.", situation: .bogey, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Slow it down. Take a breath. The only job now is one steady hole.", situation: .bogey, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Not to worry — but we need a reset right here. Play the percentage and move forward.", situation: .bogey, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Two in a row means it's time to get back to basics. Target, routine, trust.", situation: .bogey, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Not to worry. Stop the run with one smart, committed shot. That's all it takes.", situation: .bogey, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Take your medicine on the next one. Smart play now sets up a strong finish.", situation: .bogey, philosophy: .fearlessness, voice: .caddy),
    ]

    static let doubleStreakTips: [MentalTip] = [
        MentalTip(quote: "Stop. Breathe. One safe shot back in play — nothing heroic right now.", situation: .double, philosophy: .processAndCommitment, voice: .caddy),
        MentalTip(quote: "Not to worry — but we need one good decision right here. Play the percentage.", situation: .double, philosophy: .fearlessness, voice: .caddy),
        MentalTip(quote: "Two tough holes. Not to worry — but simplify everything on the next tee.", situation: .double, philosophy: .zenPresence, voice: .caddy),
        MentalTip(quote: "Reset completely. Smallest target, safest shot, one committed swing. That's it.", situation: .double, philosophy: .processAndCommitment, voice: .coach),
        MentalTip(quote: "Not to worry. The round is still there — but we need to stop this right now.", situation: .double, philosophy: .confidenceAndTrust, voice: .caddy),
        MentalTip(quote: "Slow everything down. One bogey here feels like a birdie after two doubles.", situation: .double, philosophy: .zenPresence, voice: .coach),
    ]
}

// MARK: - NM Courses

extension GolfCourse {
    static let localCourses: [GolfCourse] = [

        GolfCourse(name: "UNM Championship Course", city: "Albuquerque, NM",
            rating: 74.3, slope: 134, par: 72, yards: 7248, holes: [
            GolfHole(id: 1,  par: 4, yards: 452, handicap: 5),
            GolfHole(id: 2,  par: 5, yards: 575, handicap: 11),
            GolfHole(id: 3,  par: 4, yards: 418, handicap: 9),
            GolfHole(id: 4,  par: 3, yards: 198, handicap: 17),
            GolfHole(id: 5,  par: 5, yards: 548, handicap: 7),
            GolfHole(id: 6,  par: 4, yards: 432, handicap: 3),
            GolfHole(id: 7,  par: 4, yards: 399, handicap: 13),
            GolfHole(id: 8,  par: 3, yards: 260, handicap: 1),
            GolfHole(id: 9,  par: 5, yards: 576, handicap: 15),
            GolfHole(id: 10, par: 4, yards: 520, handicap: 2),
            GolfHole(id: 11, par: 4, yards: 388, handicap: 10),
            GolfHole(id: 12, par: 4, yards: 412, handicap: 8),
            GolfHole(id: 13, par: 3, yards: 205, handicap: 16),
            GolfHole(id: 14, par: 5, yards: 542, handicap: 12),
            GolfHole(id: 15, par: 4, yards: 364, handicap: 14),
            GolfHole(id: 16, par: 3, yards: 194, handicap: 18),
            GolfHole(id: 17, par: 4, yards: 405, handicap: 6),
            GolfHole(id: 18, par: 5, yards: 560, handicap: 4)]),

        GolfCourse(name: "Canyon Club at Four Hills", city: "Albuquerque, NM",
            rating: 71.4, slope: 130, par: 72, yards: 6767, holes: [
            GolfHole(id: 1,  par: 4, yards: 382, handicap: 9),
            GolfHole(id: 2,  par: 4, yards: 367, handicap: 11),
            GolfHole(id: 3,  par: 3, yards: 181, handicap: 15),
            GolfHole(id: 4,  par: 5, yards: 528, handicap: 1),
            GolfHole(id: 5,  par: 4, yards: 330, handicap: 13),
            GolfHole(id: 6,  par: 3, yards: 166, handicap: 17),
            GolfHole(id: 7,  par: 4, yards: 400, handicap: 7),
            GolfHole(id: 8,  par: 5, yards: 564, handicap: 5),
            GolfHole(id: 9,  par: 4, yards: 456, handicap: 3),
            GolfHole(id: 10, par: 4, yards: 371, handicap: 10),
            GolfHole(id: 11, par: 5, yards: 504, handicap: 12),
            GolfHole(id: 12, par: 4, yards: 433, handicap: 2),
            GolfHole(id: 13, par: 3, yards: 167, handicap: 18),
            GolfHole(id: 14, par: 4, yards: 444, handicap: 8),
            GolfHole(id: 15, par: 5, yards: 502, handicap: 4),
            GolfHole(id: 16, par: 4, yards: 348, handicap: 14),
            GolfHole(id: 17, par: 3, yards: 189, handicap: 16),
            GolfHole(id: 18, par: 4, yards: 435, handicap: 6)]),

        GolfCourse(name: "Paa-Ko Ridge Golf Club", city: "Tijeras, NM",
            rating: 73.1, slope: 138, par: 72, yards: 7561, holes: [
            GolfHole(id: 1,  par: 4, yards: 421, handicap: 7),
            GolfHole(id: 2,  par: 5, yards: 552, handicap: 11),
            GolfHole(id: 3,  par: 3, yards: 193, handicap: 17),
            GolfHole(id: 4,  par: 4, yards: 438, handicap: 3),
            GolfHole(id: 5,  par: 4, yards: 419, handicap: 9),
            GolfHole(id: 6,  par: 3, yards: 219, handicap: 13),
            GolfHole(id: 7,  par: 5, yards: 601, handicap: 1),
            GolfHole(id: 8,  par: 4, yards: 386, handicap: 15),
            GolfHole(id: 9,  par: 4, yards: 457, handicap: 5),
            GolfHole(id: 10, par: 4, yards: 448, handicap: 6),
            GolfHole(id: 11, par: 3, yards: 205, handicap: 16),
            GolfHole(id: 12, par: 5, yards: 561, handicap: 10),
            GolfHole(id: 13, par: 4, yards: 415, handicap: 14),
            GolfHole(id: 14, par: 4, yards: 461, handicap: 2),
            GolfHole(id: 15, par: 5, yards: 573, handicap: 8),
            GolfHole(id: 16, par: 3, yards: 186, handicap: 18),
            GolfHole(id: 17, par: 4, yards: 412, handicap: 12),
            GolfHole(id: 18, par: 4, yards: 414, handicap: 4)]),

        GolfCourse(name: "Twin Warriors Golf Club", city: "Santa Ana Pueblo, NM",
            rating: 73.0, slope: 134, par: 72, yards: 6914, holes: [
            GolfHole(id: 1,  par: 5, yards: 528, handicap: 9),
            GolfHole(id: 2,  par: 4, yards: 437, handicap: 7),
            GolfHole(id: 3,  par: 4, yards: 440, handicap: 3),
            GolfHole(id: 4,  par: 3, yards: 178, handicap: 15),
            GolfHole(id: 5,  par: 4, yards: 411, handicap: 13),
            GolfHole(id: 6,  par: 4, yards: 399, handicap: 11),
            GolfHole(id: 7,  par: 4, yards: 453, handicap: 1),
            GolfHole(id: 8,  par: 5, yards: 549, handicap: 5),
            GolfHole(id: 9,  par: 3, yards: 180, handicap: 17),
            GolfHole(id: 10, par: 4, yards: 447, handicap: 2),
            GolfHole(id: 11, par: 4, yards: 324, handicap: 16),
            GolfHole(id: 12, par: 5, yards: 529, handicap: 4),
            GolfHole(id: 13, par: 3, yards: 153, handicap: 14),
            GolfHole(id: 14, par: 4, yards: 362, handicap: 18),
            GolfHole(id: 15, par: 3, yards: 184, handicap: 12),
            GolfHole(id: 16, par: 5, yards: 558, handicap: 8),
            GolfHole(id: 17, par: 4, yards: 344, handicap: 10),
            GolfHole(id: 18, par: 4, yards: 435, handicap: 6)]),

        GolfCourse(name: "Isleta Eagle Golf Course", city: "Albuquerque, NM",
            rating: 70.9, slope: 121, par: 72, yards: 6783, holes: [
            GolfHole(id: 1,  par: 4, yards: 397, handicap: 11),
            GolfHole(id: 2,  par: 4, yards: 381, handicap: 13),
            GolfHole(id: 3,  par: 3, yards: 158, handicap: 17),
            GolfHole(id: 4,  par: 5, yards: 519, handicap: 7),
            GolfHole(id: 5,  par: 4, yards: 401, handicap: 5),
            GolfHole(id: 6,  par: 4, yards: 373, handicap: 15),
            GolfHole(id: 7,  par: 3, yards: 172, handicap: 9),
            GolfHole(id: 8,  par: 5, yards: 538, handicap: 1),
            GolfHole(id: 9,  par: 4, yards: 414, handicap: 3),
            GolfHole(id: 10, par: 4, yards: 389, handicap: 10),
            GolfHole(id: 11, par: 4, yards: 376, handicap: 16),
            GolfHole(id: 12, par: 3, yards: 164, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 521, handicap: 6),
            GolfHole(id: 14, par: 4, yards: 408, handicap: 4),
            GolfHole(id: 15, par: 4, yards: 384, handicap: 14),
            GolfHole(id: 16, par: 3, yards: 178, handicap: 8),
            GolfHole(id: 17, par: 5, yards: 544, handicap: 2),
            GolfHole(id: 18, par: 4, yards: 386, handicap: 12)]),

        GolfCourse(name: "Arroyo del Oso Golf Course", city: "Albuquerque, NM",
            rating: 69.4, slope: 113, par: 72, yards: 6600, holes: [
            GolfHole(id: 1,  par: 4, yards: 360, handicap: 13),
            GolfHole(id: 2,  par: 5, yards: 510, handicap: 7),
            GolfHole(id: 3,  par: 4, yards: 370, handicap: 11),
            GolfHole(id: 4,  par: 3, yards: 155, handicap: 17),
            GolfHole(id: 5,  par: 4, yards: 390, handicap: 3),
            GolfHole(id: 6,  par: 4, yards: 365, handicap: 15),
            GolfHole(id: 7,  par: 3, yards: 162, handicap: 9),
            GolfHole(id: 8,  par: 5, yards: 525, handicap: 5),
            GolfHole(id: 9,  par: 4, yards: 398, handicap: 1),
            GolfHole(id: 10, par: 4, yards: 375, handicap: 8),
            GolfHole(id: 11, par: 5, yards: 495, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 148, handicap: 18),
            GolfHole(id: 13, par: 4, yards: 382, handicap: 4),
            GolfHole(id: 14, par: 4, yards: 355, handicap: 16),
            GolfHole(id: 15, par: 3, yards: 170, handicap: 10),
            GolfHole(id: 16, par: 5, yards: 518, handicap: 6),
            GolfHole(id: 17, par: 4, yards: 388, handicap: 2),
            GolfHole(id: 18, par: 4, yards: 434, handicap: 12)]),

        GolfCourse(name: "Los Altos Golf Course", city: "Albuquerque, NM",
            rating: 68.1, slope: 108, par: 71, yards: 6110, holes: [
            GolfHole(id: 1,  par: 4, yards: 350, handicap: 11),
            GolfHole(id: 2,  par: 4, yards: 340, handicap: 15),
            GolfHole(id: 3,  par: 3, yards: 145, handicap: 17),
            GolfHole(id: 4,  par: 5, yards: 490, handicap: 5),
            GolfHole(id: 5,  par: 4, yards: 365, handicap: 7),
            GolfHole(id: 6,  par: 4, yards: 330, handicap: 13),
            GolfHole(id: 7,  par: 3, yards: 150, handicap: 9),
            GolfHole(id: 8,  par: 5, yards: 500, handicap: 3),
            GolfHole(id: 9,  par: 4, yards: 375, handicap: 1),
            GolfHole(id: 10, par: 4, yards: 358, handicap: 10),
            GolfHole(id: 11, par: 4, yards: 345, handicap: 16),
            GolfHole(id: 12, par: 3, yards: 140, handicap: 18),
            GolfHole(id: 13, par: 4, yards: 372, handicap: 4),
            GolfHole(id: 14, par: 5, yards: 508, handicap: 6),
            GolfHole(id: 15, par: 3, yards: 162, handicap: 14),
            GolfHole(id: 16, par: 4, yards: 348, handicap: 8),
            GolfHole(id: 17, par: 4, yards: 360, handicap: 12),
            GolfHole(id: 18, par: 4, yards: 372, handicap: 2)]),

        GolfCourse(name: "Sandia Golf Club", city: "Albuquerque, NM",
            rating: 71.8, slope: 126, par: 72, yards: 6910, holes: [
            GolfHole(id: 1,  par: 4, yards: 404, handicap: 9),
            GolfHole(id: 2,  par: 5, yards: 530, handicap: 5),
            GolfHole(id: 3,  par: 4, yards: 380, handicap: 15),
            GolfHole(id: 4,  par: 3, yards: 175, handicap: 17),
            GolfHole(id: 5,  par: 4, yards: 415, handicap: 3),
            GolfHole(id: 6,  par: 4, yards: 390, handicap: 11),
            GolfHole(id: 7,  par: 5, yards: 545, handicap: 7),
            GolfHole(id: 8,  par: 3, yards: 165, handicap: 13),
            GolfHole(id: 9,  par: 4, yards: 420, handicap: 1),
            GolfHole(id: 10, par: 4, yards: 410, handicap: 8),
            GolfHole(id: 11, par: 4, yards: 385, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 180, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 555, handicap: 4),
            GolfHole(id: 14, par: 4, yards: 395, handicap: 12),
            GolfHole(id: 15, par: 4, yards: 425, handicap: 2),
            GolfHole(id: 16, par: 3, yards: 160, handicap: 16),
            GolfHole(id: 17, par: 5, yards: 540, handicap: 6),
            GolfHole(id: 18, par: 4, yards: 436, handicap: 10)]),

        GolfCourse(name: "Santa Ana Golf Club", city: "Bernalillo, NM",
            rating: 72.3, slope: 130, par: 72, yards: 7048, holes: [
            GolfHole(id: 1,  par: 4, yards: 418, handicap: 5),
            GolfHole(id: 2,  par: 4, yards: 392, handicap: 11),
            GolfHole(id: 3,  par: 5, yards: 558, handicap: 7),
            GolfHole(id: 4,  par: 3, yards: 196, handicap: 15),
            GolfHole(id: 5,  par: 4, yards: 437, handicap: 1),
            GolfHole(id: 6,  par: 4, yards: 409, handicap: 9),
            GolfHole(id: 7,  par: 3, yards: 184, handicap: 17),
            GolfHole(id: 8,  par: 5, yards: 562, handicap: 3),
            GolfHole(id: 9,  par: 4, yards: 428, handicap: 13),
            GolfHole(id: 10, par: 4, yards: 415, handicap: 6),
            GolfHole(id: 11, par: 4, yards: 388, handicap: 12),
            GolfHole(id: 12, par: 3, yards: 188, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 571, handicap: 2),
            GolfHole(id: 14, par: 4, yards: 420, handicap: 8),
            GolfHole(id: 15, par: 4, yards: 396, handicap: 16),
            GolfHole(id: 16, par: 3, yards: 178, handicap: 14),
            GolfHole(id: 17, par: 5, yards: 543, handicap: 4),
            GolfHole(id: 18, par: 4, yards: 465, handicap: 10)]),

        GolfCourse(name: "Albuquerque Country Club", city: "Albuquerque, NM",
            rating: 0.0, slope: 0, par: 72, yards: 0, holes: [], isComingSoon: true),

        GolfCourse(name: "Tanoan Country Club", city: "Albuquerque, NM",
            rating: 0.0, slope: 0, par: 72, yards: 0, holes: [], isComingSoon: true),

        GolfCourse(name: "Marty Sanchez Links de Santa Fe", city: "Santa Fe, NM",
            rating: 74.1, slope: 131, par: 72, yards: 7272, holes: [
            GolfHole(id: 1,  par: 4, yards: 430, handicap: 9),
            GolfHole(id: 2,  par: 4, yards: 395, handicap: 13),
            GolfHole(id: 3,  par: 5, yards: 560, handicap: 5),
            GolfHole(id: 4,  par: 3, yards: 210, handicap: 17),
            GolfHole(id: 5,  par: 4, yards: 445, handicap: 1),
            GolfHole(id: 6,  par: 4, yards: 415, handicap: 7),
            GolfHole(id: 7,  par: 3, yards: 195, handicap: 15),
            GolfHole(id: 8,  par: 5, yards: 565, handicap: 3),
            GolfHole(id: 9,  par: 4, yards: 420, handicap: 11),
            GolfHole(id: 10, par: 4, yards: 408, handicap: 10),
            GolfHole(id: 11, par: 4, yards: 385, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 200, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 572, handicap: 4),
            GolfHole(id: 14, par: 4, yards: 425, handicap: 8),
            GolfHole(id: 15, par: 4, yards: 398, handicap: 16),
            GolfHole(id: 16, par: 3, yards: 188, handicap: 12),
            GolfHole(id: 17, par: 5, yards: 548, handicap: 2),
            GolfHole(id: 18, par: 4, yards: 313, handicap: 6)]),

        GolfCourse(name: "Towa Golf Club at Buffalo Thunder", city: "Pojoaque, NM",
            rating: 73.1, slope: 136, par: 72, yards: 7190, holes: [
            GolfHole(id: 1,  par: 4, yards: 420, handicap: 7),
            GolfHole(id: 2,  par: 3, yards: 195, handicap: 15),
            GolfHole(id: 3,  par: 5, yards: 558, handicap: 3),
            GolfHole(id: 4,  par: 4, yards: 432, handicap: 5),
            GolfHole(id: 5,  par: 4, yards: 388, handicap: 13),
            GolfHole(id: 6,  par: 3, yards: 178, handicap: 17),
            GolfHole(id: 7,  par: 5, yards: 545, handicap: 9),
            GolfHole(id: 8,  par: 4, yards: 410, handicap: 1),
            GolfHole(id: 9,  par: 4, yards: 402, handicap: 11),
            GolfHole(id: 10, par: 4, yards: 415, handicap: 8),
            GolfHole(id: 11, par: 3, yards: 188, handicap: 16),
            GolfHole(id: 12, par: 5, yards: 562, handicap: 4),
            GolfHole(id: 13, par: 4, yards: 398, handicap: 10),
            GolfHole(id: 14, par: 4, yards: 425, handicap: 2),
            GolfHole(id: 15, par: 3, yards: 182, handicap: 18),
            GolfHole(id: 16, par: 5, yards: 548, handicap: 6),
            GolfHole(id: 17, par: 4, yards: 376, handicap: 14),
            GolfHole(id: 18, par: 4, yards: 368, handicap: 12)]),

        GolfCourse(name: "Black Mesa Golf Club", city: "La Mesilla, NM",
            rating: 73.9, slope: 141, par: 72, yards: 7307, holes: [
            GolfHole(id: 1,  par: 4, yards: 385, handicap: 11),
            GolfHole(id: 2,  par: 4, yards: 448, handicap: 3),
            GolfHole(id: 3,  par: 5, yards: 556, handicap: 7),
            GolfHole(id: 4,  par: 3, yards: 208, handicap: 13),
            GolfHole(id: 5,  par: 4, yards: 432, handicap: 1),
            GolfHole(id: 6,  par: 5, yards: 545, handicap: 9),
            GolfHole(id: 7,  par: 4, yards: 388, handicap: 15),
            GolfHole(id: 8,  par: 3, yards: 225, handicap: 5),
            GolfHole(id: 9,  par: 4, yards: 420, handicap: 17),
            GolfHole(id: 10, par: 4, yards: 440, handicap: 2),
            GolfHole(id: 11, par: 5, yards: 562, handicap: 8),
            GolfHole(id: 12, par: 4, yards: 377, handicap: 12),
            GolfHole(id: 13, par: 3, yards: 196, handicap: 16),
            GolfHole(id: 14, par: 4, yards: 425, handicap: 4),
            GolfHole(id: 15, par: 5, yards: 553, handicap: 10),
            GolfHole(id: 16, par: 4, yards: 396, handicap: 14),
            GolfHole(id: 17, par: 3, yards: 212, handicap: 18),
            GolfHole(id: 18, par: 4, yards: 439, handicap: 6)]),

        GolfCourse(name: "Taos Country Club", city: "Ranchos de Taos, NM",
            rating: 73.6, slope: 129, par: 72, yards: 7302, holes: [
            GolfHole(id: 1,  par: 4, yards: 415, handicap: 9),
            GolfHole(id: 2,  par: 4, yards: 388, handicap: 13),
            GolfHole(id: 3,  par: 5, yards: 552, handicap: 5),
            GolfHole(id: 4,  par: 3, yards: 195, handicap: 17),
            GolfHole(id: 5,  par: 4, yards: 432, handicap: 3),
            GolfHole(id: 6,  par: 4, yards: 408, handicap: 7),
            GolfHole(id: 7,  par: 3, yards: 182, handicap: 15),
            GolfHole(id: 8,  par: 5, yards: 568, handicap: 1),
            GolfHole(id: 9,  par: 4, yards: 412, handicap: 11),
            GolfHole(id: 10, par: 4, yards: 420, handicap: 8),
            GolfHole(id: 11, par: 4, yards: 395, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 188, handicap: 18),
            GolfHole(id: 13, par: 4, yards: 428, handicap: 6),
            GolfHole(id: 14, par: 5, yards: 558, handicap: 2),
            GolfHole(id: 15, par: 5, yards: 545, handicap: 10),
            GolfHole(id: 16, par: 3, yards: 178, handicap: 16),
            GolfHole(id: 17, par: 4, yards: 405, handicap: 4),
            GolfHole(id: 18, par: 4, yards: 441, handicap: 12)]),

        GolfCourse(name: "Pinon Hills Golf Course", city: "Farmington, NM",
            rating: 73.9, slope: 139, par: 72, yards: 7198, holes: [
            GolfHole(id: 1,  par: 4, yards: 420, handicap: 7),
            GolfHole(id: 2,  par: 5, yards: 568, handicap: 11),
            GolfHole(id: 3,  par: 4, yards: 408, handicap: 3),
            GolfHole(id: 4,  par: 5, yards: 561, handicap: 13),
            GolfHole(id: 5,  par: 3, yards: 198, handicap: 17),
            GolfHole(id: 6,  par: 4, yards: 432, handicap: 1),
            GolfHole(id: 7,  par: 4, yards: 388, handicap: 9),
            GolfHole(id: 8,  par: 3, yards: 216, handicap: 15),
            GolfHole(id: 9,  par: 5, yards: 548, handicap: 5),
            GolfHole(id: 10, par: 4, yards: 415, handicap: 6),
            GolfHole(id: 11, par: 4, yards: 395, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 185, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 556, handicap: 4),
            GolfHole(id: 14, par: 4, yards: 428, handicap: 2),
            GolfHole(id: 15, par: 4, yards: 375, handicap: 16),
            GolfHole(id: 16, par: 3, yards: 204, handicap: 12),
            GolfHole(id: 17, par: 5, yards: 542, handicap: 8),
            GolfHole(id: 18, par: 4, yards: 359, handicap: 10)]),

        GolfCourse(name: "Sonoma Ranch Golf Course", city: "Las Cruces, NM",
            rating: 73.6, slope: 144, par: 72, yards: 7028, holes: [
            GolfHole(id: 1,  par: 4, yards: 348, handicap: 15),
            GolfHole(id: 2,  par: 4, yards: 389, handicap: 11),
            GolfHole(id: 3,  par: 3, yards: 147, handicap: 17),
            GolfHole(id: 4,  par: 4, yards: 309, handicap: 13),
            GolfHole(id: 5,  par: 4, yards: 472, handicap: 1),
            GolfHole(id: 6,  par: 4, yards: 420, handicap: 7),
            GolfHole(id: 7,  par: 5, yards: 600, handicap: 3),
            GolfHole(id: 8,  par: 3, yards: 164, handicap: 9),
            GolfHole(id: 9,  par: 4, yards: 456, handicap: 5),
            GolfHole(id: 10, par: 4, yards: 402, handicap: 10),
            GolfHole(id: 11, par: 3, yards: 172, handicap: 16),
            GolfHole(id: 12, par: 5, yards: 568, handicap: 2),
            GolfHole(id: 13, par: 4, yards: 388, handicap: 12),
            GolfHole(id: 14, par: 4, yards: 415, handicap: 4),
            GolfHole(id: 15, par: 3, yards: 168, handicap: 18),
            GolfHole(id: 16, par: 5, yards: 545, handicap: 6),
            GolfHole(id: 17, par: 4, yards: 395, handicap: 8),
            GolfHole(id: 18, par: 4, yards: 470, handicap: 14)]),

        GolfCourse(name: "Picacho Hills Country Club", city: "Las Cruces, NM",
            rating: 72.9, slope: 134, par: 72, yards: 6970, holes: [
            GolfHole(id: 1,  par: 4, yards: 395, handicap: 7),
            GolfHole(id: 2,  par: 4, yards: 410, handicap: 1),
            GolfHole(id: 3,  par: 5, yards: 540, handicap: 5),
            GolfHole(id: 4,  par: 3, yards: 175, handicap: 15),
            GolfHole(id: 5,  par: 4, yards: 388, handicap: 11),
            GolfHole(id: 6,  par: 4, yards: 365, handicap: 13),
            GolfHole(id: 7,  par: 5, yards: 530, handicap: 3),
            GolfHole(id: 8,  par: 3, yards: 170, handicap: 17),
            GolfHole(id: 9,  par: 4, yards: 402, handicap: 9),
            GolfHole(id: 10, par: 4, yards: 398, handicap: 8),
            GolfHole(id: 11, par: 4, yards: 375, handicap: 14),
            GolfHole(id: 12, par: 3, yards: 182, handicap: 18),
            GolfHole(id: 13, par: 5, yards: 545, handicap: 4),
            GolfHole(id: 14, par: 4, yards: 415, handicap: 6),
            GolfHole(id: 15, par: 4, yards: 378, handicap: 16),
            GolfHole(id: 16, par: 3, yards: 168, handicap: 12),
            GolfHole(id: 17, par: 5, yards: 528, handicap: 2),
            GolfHole(id: 18, par: 4, yards: 406, handicap: 10)]),

        GolfCourse(name: "NMSU Golf Course", city: "Las Cruces, NM",
            rating: 72.7, slope: 129, par: 72, yards: 7040, holes: [
            GolfHole(id: 1,  par: 4, yards: 392, handicap: 7),
            GolfHole(id: 2,  par: 4, yards: 418, handicap: 3),
            GolfHole(id: 3,  par: 5, yards: 538, handicap: 9),
            GolfHole(id: 4,  par: 3, yards: 198, handicap: 15),
            GolfHole(id: 5,  par: 4, yards: 405, handicap: 5),
            GolfHole(id: 6,  par: 4, yards: 378, handicap: 13),
            GolfHole(id: 7,  par: 5, yards: 552, handicap: 11),
            GolfHole(id: 8,  par: 3, yards: 157, handicap: 17),
            GolfHole(id: 9,  par: 4, yards: 388, handicap: 11),
            GolfHole(id: 10, par: 4, yards: 402, handicap: 8),
            GolfHole(id: 11, par: 4, yards: 365, handicap: 14),
            GolfHole(id: 12, par: 4, yards: 411, handicap: 1),
            GolfHole(id: 13, par: 3, yards: 204, handicap: 16),
            GolfHole(id: 14, par: 5, yards: 548, handicap: 4),
            GolfHole(id: 15, par: 4, yards: 395, handicap: 10),
            GolfHole(id: 16, par: 4, yards: 372, handicap: 12),
            GolfHole(id: 17, par: 5, yards: 521, handicap: 6),
            GolfHole(id: 18, par: 5, yards: 573, handicap: 2)]),

        GolfCourse(name: "Rockwind Community Links", city: "Hobbs, NM",
            rating: 73.0, slope: 127, par: 72, yards: 7103, holes: [
            GolfHole(id: 1,  par: 4, yards: 402, handicap: 9),
            GolfHole(id: 2,  par: 4, yards: 378, handicap: 13),
            GolfHole(id: 3,  par: 3, yards: 185, handicap: 17),
            GolfHole(id: 4,  par: 5, yards: 561, handicap: 5),
            GolfHole(id: 5,  par: 4, yards: 415, handicap: 3),
            GolfHole(id: 6,  par: 4, yards: 388, handicap: 11),
            GolfHole(id: 7,  par: 3, yards: 192, handicap: 15),
            GolfHole(id: 8,  par: 5, yards: 548, handicap: 7),
            GolfHole(id: 9,  par: 4, yards: 420, handicap: 1),
            GolfHole(id: 10, par: 4, yards: 395, handicap: 8),
            GolfHole(id: 11, par: 4, yards: 372, handicap: 16),
            GolfHole(id: 12, par: 5, yards: 535, handicap: 4),
            GolfHole(id: 13, par: 3, yards: 178, handicap: 18),
            GolfHole(id: 14, par: 4, yards: 408, handicap: 6),
            GolfHole(id: 15, par: 4, yards: 385, handicap: 14),
            GolfHole(id: 16, par: 5, yards: 542, handicap: 2),
            GolfHole(id: 17, par: 3, yards: 143, handicap: 10),
            GolfHole(id: 18, par: 4, yards: 456, handicap: 12)]),

        GolfCourse(name: "Hillcrest Golf Club", city: "Durango, CO",
            rating: 71.2, slope: 132, par: 71, yards: 6784, holes: [
            GolfHole(id: 1,  par: 4, yards: 365, handicap: 14),
            GolfHole(id: 2,  par: 4, yards: 430, handicap: 4),
            GolfHole(id: 3,  par: 5, yards: 528, handicap: 8),
            GolfHole(id: 4,  par: 4, yards: 470, handicap: 2),
            GolfHole(id: 5,  par: 3, yards: 195, handicap: 16),
            GolfHole(id: 6,  par: 4, yards: 324, handicap: 18),
            GolfHole(id: 7,  par: 4, yards: 405, handicap: 6),
            GolfHole(id: 8,  par: 4, yards: 406, handicap: 10),
            GolfHole(id: 9,  par: 3, yards: 196, handicap: 12),
            GolfHole(id: 10, par: 5, yards: 553, handicap: 7),
            GolfHole(id: 11, par: 4, yards: 322, handicap: 17),
            GolfHole(id: 12, par: 3, yards: 207, handicap: 13),
            GolfHole(id: 13, par: 4, yards: 442, handicap: 1),
            GolfHole(id: 14, par: 4, yards: 380, handicap: 11),
            GolfHole(id: 15, par: 3, yards: 194, handicap: 15),
            GolfHole(id: 16, par: 4, yards: 407, handicap: 9),
            GolfHole(id: 17, par: 5, yards: 562, handicap: 3),
            GolfHole(id: 18, par: 4, yards: 452, handicap: 5)]),
    ]
}

// MARK: - GPS Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
    }

    func requestPermission() { manager.requestWhenInUseAuthorization() }
    func startUpdating() { manager.startUpdatingLocation() }
    func stopUpdating() { manager.stopUpdatingLocation() }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

// MARK: - Weather Service

class WeatherService: ObservableObject {
    @Published var windSpeed: Int = 0
    @Published var windDirection: String = "Calm"
    @Published var isLoading = false

    func fetchWeather(lat: Double, lon: Double) async {
        await MainActor.run { isLoading = true }
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=wind_speed_10m,wind_direction_10m&wind_speed_unit=mph") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let current = json["current"] as? [String: Any],
               let speed = current["wind_speed_10m"] as? Double,
               let dir = current["wind_direction_10m"] as? Double {
                await MainActor.run {
                    self.windSpeed = Int(speed)
                    self.windDirection = self.degreesToDirection(degrees: dir, speed: Int(speed))
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }

    func degreesToDirection(degrees: Double, speed: Int) -> String {
        if speed == 0 { return "Calm" }
        let dirs = ["N","NE","E","SE","S","SW","W","NW"]
        let index = Int((degrees + 22.5) / 45.0) % 8
        switch dirs[index] {
        case "N": return "Into Wind"
        case "S": return "With Wind"
        case "E": return "Left to Right"
        case "W": return "Right to Left"
        case "NE", "NW": return "Into Wind"
        case "SE", "SW": return "With Wind"
        default: return "Calm"
        }
    }
}

// MARK: - Course List Views

struct CourseListView: View {
    @Binding var selectedCourse: GolfCourse?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var abqCourses: [GolfCourse] { filtered(region: ["Albuquerque","Bernalillo","Tijeras","Santa Ana Pueblo"]) }
    var santaFeCourses: [GolfCourse] { filtered(region: ["Santa Fe","Pojoaque","La Mesilla"]) }
    var southernCourses: [GolfCourse] { filtered(region: ["Las Cruces","Hobbs"]) }
    var otherCourses: [GolfCourse] {
        GolfCourse.localCourses.filter { c in
            !abqCourses.contains(where: { $0.id == c.id }) &&
            !santaFeCourses.contains(where: { $0.id == c.id }) &&
            !southernCourses.contains(where: { $0.id == c.id })
        }.filter { matchesSearch($0) }
    }

    func filtered(region: [String]) -> [GolfCourse] {
        GolfCourse.localCourses.filter { c in
            region.contains(where: { c.city.contains($0) }) && matchesSearch(c)
        }
    }

    func matchesSearch(_ c: GolfCourse) -> Bool {
        searchText.isEmpty ||
        c.name.localizedCaseInsensitiveContains(searchText) ||
        c.city.localizedCaseInsensitiveContains(searchText)
    }

    var body: some View {
        NavigationView {
            List {
                Button(action: { selectedCourse = nil; dismiss() }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("No Course Selected").font(.headline).foregroundColor(.primary)
                            Text("Enter hole details manually").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedCourse == nil {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(GolfIQBrand.accent)
                        }
                    }
                }
                if !abqCourses.isEmpty { Section("Albuquerque Area") { ForEach(abqCourses) { courseButton($0) } } }
                if !santaFeCourses.isEmpty { Section("Santa Fe / Northern NM") { ForEach(santaFeCourses) { courseButton($0) } } }
                if !southernCourses.isEmpty { Section("Southern NM") { ForEach(southernCourses) { courseButton($0) } } }
                if !otherCourses.isEmpty { Section("Other Regions") { ForEach(otherCourses) { courseButton($0) } } }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search by name or city")
            .navigationTitle("Select Course")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(GolfIQBrand.accent)
                }
            }
        }
    }

    @ViewBuilder
    func courseButton(_ course: GolfCourse) -> some View {
        Button(action: {
            if !course.isComingSoon { selectedCourse = course; dismiss() }
        }) {
            CourseRowView(course: course, isSelected: selectedCourse?.id == course.id)
        }
        .disabled(course.isComingSoon)
    }
}

struct CourseRowView: View {
    let course: GolfCourse
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            if course.isComingSoon {
                Text("🔜").font(.caption)
            } else {
                Circle().fill(slopeColor(course.slope)).frame(width: 10, height: 10)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(course.name).font(.headline)
                    .foregroundColor(course.isComingSoon ? .secondary : .primary)
                Text(course.city).font(.caption).foregroundColor(.secondary)
                if course.isComingSoon {
                    Text("Scorecard coming soon — check back after launch")
                        .font(.caption2).foregroundColor(GolfIQBrand.accent)
                } else {
                    HStack(spacing: 6) {
                        Label("Par \(course.par)", systemImage: "flag.fill")
                        Text("·")
                        Text("\(course.yards) yds")
                        Text("·")
                        Text(course.difficultyLabel)
                    }
                    .font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer()
            if !course.isComingSoon {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(course.rating, specifier: "%.1f")").font(.headline)
                    Text("/ \(course.slope)").font(.caption).foregroundColor(.secondary)
                }
            }
            if isSelected {
                Image(systemName: "checkmark.circle.fill").foregroundColor(GolfIQBrand.accent)
            }
        }
        .padding(.vertical, 4)
    }

    func slopeColor(_ slope: Int) -> Color {
        switch slope {
        case ..<110: return .blue
        case 110..<120: return GolfIQBrand.accent
        case 120..<130: return .yellow
        case 130..<140: return .orange
        default: return .red
        }
    }
}

struct CourseInfoBanner: View {
    let course: GolfCourse
    let onChangeCourse: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "map.fill").foregroundColor(GolfIQBrand.accent).font(.title3)
            VStack(alignment: .leading, spacing: 1) {
                Text(course.name).font(.subheadline).fontWeight(.semibold)
                HStack(spacing: 6) {
                    Text("Rating \(course.rating, specifier: "%.1f")")
                    Text("·")
                    Text("Slope \(course.slope)")
                    Text("·")
                    Text("Par \(course.par)")
                }
                .font(.caption2).foregroundColor(.secondary)
            }
            Spacer()
            Button("Change", action: onChangeCourse).font(.caption).foregroundColor(GolfIQBrand.accent)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Player & Hole Models

struct PlayerProfile {
    var name: String
    var handicap: Double
    var missDirection: String
    var clubDistances: [String: Int]

    static let clubOrder = ["Driver","3-Wood","5-Wood",
        "3-Hybrid","4-Hybrid","5-Hybrid","6-Hybrid",
        "3-Iron","4-Iron","5-Iron","6-Iron","7-Iron","8-Iron","9-Iron",
        "PW","GW","SW","LW"]

    static let defaultClubDistances: [String: Int] = [
        "Driver": 245, "3-Wood": 220, "5-Wood": 205,
        "3-Hybrid": 0, "4-Hybrid": 0, "5-Hybrid": 0, "6-Hybrid": 0,
        "3-Iron": 190, "4-Iron": 180, "5-Iron": 170, "6-Iron": 160,
        "7-Iron": 150, "8-Iron": 140, "9-Iron": 130,
        "PW": 120, "GW": 105, "SW": 90, "LW": 75
    ]

    static var sample: PlayerProfile {
        let storedClubs: [String: Int]
        if let data = UserDefaults.standard.data(forKey: "player_clubs"),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            storedClubs = decoded
        } else {
            storedClubs = defaultClubDistances
        }
        return PlayerProfile(
            name: UserDefaults.standard.string(forKey: "player_name") ?? "Sammy",
            handicap: UserDefaults.standard.double(forKey: "player_handicap") == 0 ? 14.2 : UserDefaults.standard.double(forKey: "player_handicap"),
            missDirection: UserDefaults.standard.string(forKey: "player_miss") ?? "Right",
            clubDistances: storedClubs
        )
    }
    func save() {
        UserDefaults.standard.set(name, forKey: "player_name")
        UserDefaults.standard.set(handicap, forKey: "player_handicap")
        UserDefaults.standard.set(missDirection, forKey: "player_miss")
        if let encoded = try? JSONEncoder().encode(clubDistances) {
            UserDefaults.standard.set(encoded, forKey: "player_clubs")
        }
    }
}

struct HoleData {
    var holeNumber: Int = 1
    var par: Int = 4
    var distanceToPin: Int = 150
    var wind: String = "Calm"
    var windSpeed: Int = 0
    var elevation: String = "Flat"
    var lie: String = "Fairway"
    var hazards: String = "None"
}

// MARK: - Caddy Service

class CaddyService: ObservableObject {
    @Published var isLoading = false
    @Published var advice: String = ""
    @Published var errorMessage: String = ""
    @Published var preShotTip: MentalTip? = nil

    private let mentalGame = MentalGame()

    func getAdvice(hole: HoleData, player: PlayerProfile, course: GolfCourse?) async {
        await MainActor.run {
            isLoading = true; errorMessage = ""; advice = ""
            preShotTip = mentalGame.preShotTip(lie: hole.lie, hazards: hole.hazards, holeNumber: hole.holeNumber)
        }
        let prompt = buildPrompt(hole: hole, player: player, course: course)
        do {
            guard let url = URL(string: "https://golfiq-proxy.onrender.com/api/caddie-advice") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("caddie-iq-canyon-2026-x7k9", forHTTPHeaderField: "x-app-key")
            let body: [String: Any] = ["prompt": prompt]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let text = json["advice"] as? String {
                await MainActor.run { self.advice = text; self.isLoading = false }
            }
        } catch {
            await MainActor.run { self.errorMessage = "Connection error. Check your internet."; self.isLoading = false }
        }
    }

    private func buildPrompt(hole: HoleData, player: PlayerProfile, course: GolfCourse?) -> String {
        let courseSection: String
        if let course = course {
            let difficulty = course.slope > 130 ? "a demanding, tour-caliber layout" :
                             course.slope > 120 ? "a challenging course that demands course management" :
                             course.slope > 110 ? "a moderate track where scoring is realistic" :
                                                  "a forgiving layout with birdie opportunities"
            let holeInfo = course.holes.first(where: { $0.id == hole.holeNumber }).map {
                "  - Stroke index: \($0.handicap) of 18 — \(ordinal($0.handicap)) hardest hole"
            } ?? ""
            courseSection = "COURSE: \(course.name), \(course.city)\n- Rating: \(String(format: "%.1f", course.rating)) / Slope: \(course.slope)\n- Par \(course.par), \(course.yards) yards\n- \(difficulty)\n\(holeInfo)"
        } else {
            courseSection = "COURSE: Unknown — advise on general principles"
        }

        let courseHandicap = course.map { Int((player.handicap * Double($0.slope) / 113.0).rounded()) } ?? Int(player.handicap.rounded())
        let handicapContext = course != nil ? "Course handicap here: ~\(courseHandicap)" : "Handicap index: \(String(format: "%.1f", player.handicap))"

        let missRisk: String
        switch player.missDirection {
        case "Right": missRisk = "Misses right — aim left of center"
        case "Left": missRisk = "Misses left — aim right of center"
        case "Both Ways": missRisk = "Misses both ways — play widest safe corridor"
        default: missRisk = "Generally straight"
        }

        let bagLines = PlayerProfile.clubOrder.compactMap { club -> String? in
            guard let yards = player.clubDistances[club], yards > 0 else { return nil }
            return "\(club): \(yards) yds"
        }.joined(separator: ", ")

        return """
        You are an experienced golf caddy — direct, practical, course-smart. Give advice a real caddy would give on the course. Use the player's actual club distances below to recommend one specific club by name — don't just describe a club type.

        \(courseSection)

        PLAYER: \(player.name)
        - \(handicapContext)
        - Miss: \(player.missDirection) — \(missRisk)
        - Club distances: \(bagLines)

        HOLE \(hole.holeNumber) — Par \(hole.par):
        - Distance remaining to the pin for THIS shot: \(hole.distanceToPin) yards (this is the player's current distance for whatever shot they're about to hit right now — it could be their tee shot, or a much shorter approach/recovery shot after already playing earlier shots on this hole. A short number on a high-par hole is completely normal and expected — it does NOT mean an error, so don't second-guess or flag the yardage.)
        - Lie: \(hole.lie)
        - Elevation: \(hole.elevation) shot — \(hole.elevation == "Uphill" ? "plays about 5-10 yards LONGER than the flat yardage" : hole.elevation == "Downhill" ? "plays about 5-10 yards SHORTER than the flat yardage" : "no adjustment needed")
        - Wind: \(hole.wind)\(hole.windSpeed > 0 ? " at \(hole.windSpeed) mph" : "")
        - Hazards: \(hole.hazards)

        Respond with exactly these four items, 1-2 sentences each:
        🏌️ CLUB: Name the exact club from the player's bag above that best fits the effective distance after adjusting for elevation (+/- 5-10 yards as noted above), wind, and lie, e.g. "7-Iron"
        🎯 AIM: Exact target, bail-out zone, and where to miss if the shot goes wrong — be specific (e.g. miss right, short is safe, avoid the left bunker)
        ✋ SHOT: Shape or trajectory and why it fits the conditions
        ⚠️ AVOID: The one mistake that blows this hole up and how to prevent it
        """
    }

    private func ordinal(_ n: Int) -> String {
        switch n { case 1: return "1st"; case 2: return "2nd"; case 3: return "3rd"; default: return "\(n)th" }
    }
}

// MARK: - Mental Tip Views

struct MentalTipCard: View {
    let tip: MentalTip
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile").foregroundColor(.purple)
                Text("Mental Game").font(.headline).foregroundColor(.purple)
            }
            Divider()
            Text("\u{201C}\(tip.quote)\u{201D}").font(.subheadline).italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.purple.opacity(0.07))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.2), lineWidth: 1))
    }
}

struct ScoreMentalTipView: View {
    let tip: MentalTip
    let streakTip: MentalTip?
    let streakLabel: String
    let scoreLabel: String
    let accentColor: Color
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(scoreLabel).font(.title2).fontWeight(.bold).foregroundColor(accentColor)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary).font(.title3)
                }
            }
            Divider()

            // Streak tip on top if present
            if let streak = streakTip {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(streakLabel)
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    Text("\u{201C}\(streak.quote)\u{201D}")
                        .font(.subheadline).italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.orange.opacity(0.2), lineWidth: 1))

                Divider()
            }

            // Regular mental tip below
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile").foregroundColor(accentColor)
                Text("Mental Reset").font(.subheadline).fontWeight(.semibold).foregroundColor(accentColor)
                Spacer()
            }
            Text("\u{201C}\(tip.quote)\u{201D}").font(.body).italic()
                .multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)

            Button(action: onDismiss) {
                Text("Got it — Next Hole").font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(accentColor).cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 24)
    }
}

// MARK: - Putting Selection View

struct PuttingSelectionView: View {
    @Binding var showPuttingTip: Bool
    @Binding var currentPuttingTip: MentalTip?
    var holeNumber: Int
    @Environment(\.dismiss) var dismiss

    let categories: [(title: String, subtitle: String, icon: String, tips: [MentalTip])] = [
        ("Short Putt", "Under 10 feet", "target", MentalTipLibrary.shortPuttCues),
        ("Mid Range", "10 to 25 feet", "circle.dashed", MentalTipLibrary.midRangePuttCues),
        ("Lag Putt", "25 feet or more", "arrow.forward", MentalTipLibrary.lagPuttCues),
        ("Pressure Putt", "Birdie · Par · On the Line", "bolt.fill", MentalTipLibrary.pressurePuttCues),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("⛳ Select Your Putt")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .padding(.top, 8)

            Text("Get your mental cue for this moment")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 10) {
                ForEach(categories, id: \.title) { cat in
                    Button(action: {
                        let tip = cat.tips.randomElement()
                        currentPuttingTip = tip
                        if let tip = tip {
                            PuttingTipSession.shared.tipsByHole[holeNumber] = (label: cat.title, quote: tip.quote)
                        }
                        dismiss()
                        showPuttingTip = true
                    }) {
                        HStack(spacing: 14) {
                            Image(systemName: cat.icon)
                                .font(.title3)
                                .foregroundColor(GolfIQBrand.accent)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(cat.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)

            Button("Cancel") { dismiss() }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Putting Tip Popup

struct PuttingTipPopupView: View {
    let tip: MentalTip
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("⛳ Putting Thought")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            Divider()
            Text("\u{201C}\(tip.quote)\u{201D}")
                .font(.body)
                .italic()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: onDismiss) {
                Text("Got it — Step up and roll it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.18), radius: 20, x: 0, y: 8)
        .padding(.horizontal, 24)
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var selectedCourse: GolfCourse? = nil
    @StateObject private var mentalGame = MentalGame()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherService = WeatherService()
    // Shared player profile — updates in Profile tab flow to Caddie tab
    @State private var player = PlayerProfile.sample

    var body: some View {
        TabView {
            CaddyView(selectedCourse: $selectedCourse, player: $player, locationManager: locationManager, weatherService: weatherService)
                .tabItem { Label("Caddie Edge", systemImage: "figure.golf") }
            RoundView(selectedCourse: selectedCourse, player: player, mentalGame: mentalGame)
                .tabItem { Label("Round", systemImage: "flag.fill") }
            MentalGameTabView()
                .tabItem { Label("Mental", systemImage: "brain.head.profile") }
            CourseTab(selectedCourse: $selectedCourse)
                .tabItem { Label("Courses", systemImage: "map") }
            ProfileView(player: $player)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .accentColor(GolfIQBrand.accent)
        .onAppear { locationManager.requestPermission() }
    }
}

// MARK: - Caddy View

struct CaddyView: View {
    @Binding var selectedCourse: GolfCourse?
    @Binding var player: PlayerProfile
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var weatherService: WeatherService
    @StateObject private var caddyService = CaddyService()
    @State private var hole = HoleData()
    @State private var showSetup = false
    @State private var showCourseList = false
    @State private var showPuttingSelection = false
    @State private var showPuttingTipPopup = false
    @State private var currentPuttingTip: MentalTip? = nil
    let defaultLat = 35.0853
    let defaultLon = -106.6056

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "figure.golf").foregroundColor(GolfIQBrand.accent)
                        Text("Showtime! In the game!")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundColor(GolfIQBrand.accent)
                        Spacer()
                        if weatherService.windSpeed > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "wind").font(.caption).foregroundColor(GolfIQBrand.accent)
                                Text("\(weatherService.windSpeed) mph \(weatherService.windDirection)")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.bottom, 4)

                    // Tagline banner — only shows before course is selected
                    if selectedCourse == nil {
                        HStack {
                            Spacer()
                            Text(GolfIQBrand.tagline)
                                .font(.system(size: 13, weight: .semibold, design: .serif))
                                .foregroundColor(GolfIQBrand.accent)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(GolfIQBrand.accentSoft)
                        .cornerRadius(10)
                    }

                    if let course = selectedCourse {
                        CourseInfoBanner(course: course) { showCourseList = true }
                    } else {
                        Button(action: { showCourseList = true }) {
                            HStack {
                                Image(systemName: "map").foregroundColor(GolfIQBrand.accent)
                                Text("Select a course for smarter advice").font(.subheadline).foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.secondary).font(.caption)
                            }
                            .padding(12).background(Color(.systemBackground)).cornerRadius(12)
                            .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                        }
                    }

                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("HOLE \(hole.holeNumber)").font(.caption).fontWeight(.bold).foregroundColor(.secondary)
                                Text("Par \(hole.par)").font(.system(size: 42, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(hole.distanceToPin)")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundColor(GolfIQBrand.accent)
                                Text("yards").font(.caption).foregroundColor(.secondary)
                            }
                        }

                        HStack(spacing: 8) {
                            Image(systemName: locationManager.location != nil ? "location.fill" : "location.slash")
                                .font(.caption2)
                                .foregroundColor(locationManager.location != nil ? GolfIQBrand.accent : .secondary)
                            Text(locationManager.location != nil ? "GPS Active" : "GPS Unavailable")
                                .font(.caption2).foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "wind").font(.caption2).foregroundColor(GolfIQBrand.accent)
                            Text(weatherService.windSpeed == 0 ? "Calm" : "\(weatherService.windSpeed)mph \(weatherService.windDirection)")
                                .font(.caption2).foregroundColor(.secondary)
                        }

                        Divider()
                        HStack {
                            Label(hole.lie, systemImage: "location.fill").font(.caption)
                            Spacer()
                            Label(hole.elevation, systemImage: "arrow.up.right").font(.caption)
                            Spacer()
                            Label(hole.hazards == "None" ? "No Hazards" : hole.hazards, systemImage: "exclamationmark.triangle").font(.caption)
                        }
                        .foregroundColor(.secondary)

                        if let course = selectedCourse,
                           let h = course.holes.first(where: { $0.id == hole.holeNumber }) {
                            Divider()
                            HStack {
                                Image(systemName: "bolt.fill").font(.caption2).foregroundColor(.orange)
                                Text("HCP \(h.handicap)")
                                    .font(.caption2).foregroundColor(.secondary)
                                Spacer()
                                Text("\(h.yards) yds").font(.caption2).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)

                    Button(action: {
                        hole.wind = weatherService.windSpeed == 0 ? "Calm" : weatherService.windDirection
                        hole.windSpeed = weatherService.windSpeed
                        Task { await caddyService.getAdvice(hole: hole, player: player, course: selectedCourse) }
                    }) {
                        HStack {
                            if caddyService.isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Consulting Caddy...")
                            } else {
                                Image(systemName: "figure.golf")
                                Text("Ask My Caddy")
                            }
                        }
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(GolfIQBrand.accent).cornerRadius(16)
                    }
                    .disabled(caddyService.isLoading)

                    // Quick Shot Controls — always visible
                    VStack(spacing: 10) {

                        // Distance to Pin — always visible
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Distance to Pin")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(hole.distanceToPin) yards")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(GolfIQBrand.accent)
                            }
                            Slider(value: Binding(
                                get: { Double(hole.distanceToPin) },
                                set: { hole.distanceToPin = Int($0) }
                            ), in: 10...250, step: 5)
                            .accentColor(GolfIQBrand.accent)
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)

                        // On the Green button — always visible
                        Button(action: { showPuttingSelection = true }) {
                            HStack {
                                Text("🟢")
                                    .font(.title3)
                                Text("On the Green")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Get Putting Thought")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(12)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        }

                        // Elevation quick tap — always visible
                        HStack(spacing: 0) {
                            Text("Elevation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach([("arrow.up", "Uphill"), ("minus", "Flat"), ("arrow.down", "Downhill")], id: \.1) { icon, label in
                                    Button(action: { hole.elevation = label }) {
                                        Image(systemName: icon)
                                            .font(.subheadline)
                                            .foregroundColor(hole.elevation == label ? .white : GolfIQBrand.accent)
                                            .frame(width: 38, height: 32)
                                            .background(hole.elevation == label ? GolfIQBrand.accent : GolfIQBrand.accentSoft)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)

                        // Lie quick tap — shown after first caddie tap
                        if !caddyService.advice.isEmpty {
                            HStack(spacing: 0) {
                                Text("Lie")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .leading)
                                Spacer()
                                HStack(spacing: 6) {
                                    ForEach(["Fairway", "Rough", "Sand", "Fringe"], id: \.self) { lieOption in
                                        Button(action: { hole.lie = lieOption }) {
                                            Text(lieOption)
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(hole.lie == lieOption ? .white : GolfIQBrand.accent)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 6)
                                                .background(hole.lie == lieOption ? GolfIQBrand.accent : GolfIQBrand.accentSoft)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                        }
                    }
                    // Next Hole Button
                    HStack(spacing: 12) {
                        if hole.holeNumber < 18 {
                            Button(action: {
                                hole.holeNumber += 1
                                caddyService.advice = ""
                                caddyService.preShotTip = nil
                                hole.lie = "Fairway"
                                hole.elevation = "Flat"
                                hole.hazards = "None"
                                hole.wind = weatherService.windSpeed == 0 ? "Calm" : weatherService.windDirection
                                hole.windSpeed = weatherService.windSpeed
                                if let course = selectedCourse,
                                   let h = course.holes.first(where: { $0.id == hole.holeNumber }) {
                                    hole.par = h.par
                                    hole.distanceToPin = h.yards
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Next Hole")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(GolfIQBrand.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(GolfIQBrand.accentSoft)
                                .cornerRadius(12)
                            }
                        } else {
                            // Hole 18 complete
                            HStack {
                                Image(systemName: "flag.checkered")
                                Text("Round Complete!")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }

                    // Caddie advice first
                    if !caddyService.advice.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.fill.checkmark").foregroundColor(GolfIQBrand.accent)
                                Text("Caddie Advice").font(.headline)
                            }
                            Divider()
                            Text(caddyService.advice).font(.subheadline).fixedSize(horizontal: false, vertical: true)
                        }
                        .padding().background(Color(.systemBackground)).cornerRadius(16)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }

                    // Mental tip at bottom — final thought before the shot
                    if let tip = caddyService.preShotTip, !caddyService.advice.isEmpty {
                        MentalTipCard(tip: tip)
                    }

                    if !caddyService.errorMessage.isEmpty {
                        Text(caddyService.errorMessage).foregroundColor(.red).font(.caption)
                    }
                }
                .padding()
            }
            .navigationTitle("Caddie Edge IQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSetup = true }) { Image(systemName: "slider.horizontal.3") }
                }
            }
            .sheet(isPresented: $showSetup) { HoleSetupView(hole: $hole, course: selectedCourse) }
            .sheet(isPresented: $showCourseList) { CourseListView(selectedCourse: $selectedCourse) }
            .sheet(isPresented: $showPuttingSelection) {
                PuttingSelectionView(showPuttingTip: $showPuttingTipPopup, currentPuttingTip: $currentPuttingTip, holeNumber: hole.holeNumber)
                    .presentationDetents([.medium])
            }
            .overlay {
                if showPuttingTipPopup, let tip = currentPuttingTip {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { showPuttingTipPopup = false }
                    VStack {
                        Spacer()
                        PuttingTipPopupView(tip: tip) { showPuttingTipPopup = false }
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPuttingTipPopup)
                }
            }
            .onAppear {
                let lat = locationManager.location?.coordinate.latitude ?? defaultLat
                let lon = locationManager.location?.coordinate.longitude ?? defaultLon
                Task { await weatherService.fetchWeather(lat: lat, lon: lon) }
                // Sync hole yardage/par from the selected course right away,
                // in case a course was already chosen before this screen appeared
                if let course = selectedCourse,
                   let h = course.holes.first(where: { $0.id == hole.holeNumber }) {
                    hole.par = h.par
                    hole.distanceToPin = h.yards
                }
            }
            .onChange(of: selectedCourse?.id) { _, _ in
                // When course changes, load hole 1 data automatically
                hole.holeNumber = 1
                if let course = selectedCourse,
                   let h = course.holes.first(where: { $0.id == 1 }) {
                    hole.par = h.par
                    hole.distanceToPin = h.yards
                }
                caddyService.advice = ""
                caddyService.preShotTip = nil
            }
        }
    }

    func diffWord(_ i: Int) -> String {
        switch i { case 1...4: return "hardest"; case 5...9: return "tough"
        case 10...14: return "mid-difficulty"; default: return "easier" }
    }
}

// MARK: - Hole Setup

struct HoleSetupView: View {
    @Binding var hole: HoleData
    let course: GolfCourse?
    @Environment(\.dismiss) var dismiss

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 9)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Current hole info card
                    VStack(spacing: 6) {
                        Text("Hole \(hole.holeNumber)")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                        if let course = course,
                           let h = course.holes.first(where: { $0.id == hole.holeNumber }) {
                            HStack(spacing: 16) {
                                Label("Par \(h.par)", systemImage: "flag.fill")
                                Label("\(h.yards) yds", systemImage: "arrow.right")
                                Label("HCP \(h.handicap)", systemImage: "bolt.fill")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
                    .padding(.horizontal)

                    // Front Nine Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FRONT NINE")
                            .font(.caption).fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(1...9, id: \.self) { i in holeButton(i) }
                        }
                        .padding(.horizontal)
                    }

                    // Back Nine Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BACK NINE")
                            .font(.caption).fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(10...18, id: \.self) { i in holeButton(i) }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Hole")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(GolfIQBrand.accent)
                }
            }
        }
    }

    @ViewBuilder
    func holeButton(_ number: Int) -> some View {
        let isSelected = hole.holeNumber == number
        let holePar = course?.holes.first(where: { $0.id == number })?.par
        Button(action: {
            hole.holeNumber = number
            if let course = course,
               let h = course.holes.first(where: { $0.id == number }) {
                hole.par = h.par
                hole.distanceToPin = h.yards
            }
        }) {
            VStack(spacing: 2) {
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(isSelected ? .white : .primary)
                if let par = holePar {
                    Text("P\(par)")
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? GolfIQBrand.accent : Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        }
    }
}


// MARK: - Round History

struct HoleTipRecord: Codable {
    var scoreLabel: String
    var quote: String
    var streakLabel: String?
    var streakQuote: String?
    var puttingLabel: String?
    var puttingQuote: String?
}

struct SavedRound: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var courseName: String
    var courseCity: String
    var pars: [Int]
    var scores: [Int]
    var holeTips: [Int: HoleTipRecord] = [:]
    var isPlanned: Bool = false

    var holesPlayed: Int { scores.filter { $0 > 0 }.count }
    var totalScore: Int { scores.filter { $0 > 0 }.reduce(0, +) }
    var parPlayed: Int {
        var total = 0
        for i in 0..<scores.count where i < pars.count && scores[i] > 0 { total += pars[i] }
        return total
    }
    var scoreToPar: Int { totalScore - parPlayed }
    var scoreToParLabel: String {
        scoreToPar == 0 ? "E" : scoreToPar > 0 ? "+\(scoreToPar)" : "\(scoreToPar)"
    }
    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Shared across tabs so a putting tip picked on the Caddie Edge tab
// can be included when a round is saved from the Round tab
class PuttingTipSession: ObservableObject {
    static let shared = PuttingTipSession()
    @Published var tipsByHole: [Int: (label: String, quote: String)] = [:]
}

class RoundHistoryStore: ObservableObject {
    @Published var rounds: [SavedRound] = []
    private let storageKey = "saved_rounds"

    init() { load() }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([SavedRound].self, from: data) else {
            rounds = []
            return
        }
        rounds = decoded.sorted { $0.date > $1.date }
    }

    func save(_ round: SavedRound) {
        rounds.insert(round, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        rounds.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(rounds) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}

struct RoundHistoryView: View {
    @ObservedObject var store: RoundHistoryStore

    var body: some View {
        Group {
            if store.rounds.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No saved rounds yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Finish a round and tap Save to see it here.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.rounds) { round in
                        NavigationLink(destination: RoundHistoryDetailView(round: round)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(round.courseName).font(.headline)
                                    if round.isPlanned {
                                        Text("PRACTICE")
                                            .font(.caption2).fontWeight(.bold)
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.2))
                                            .foregroundColor(.orange)
                                            .cornerRadius(4)
                                    }
                                    Spacer()
                                    Text("\(round.totalScore) (\(round.scoreToParLabel))")
                                        .font(.headline)
                                        .foregroundColor(round.scoreToPar <= 0 ? GolfIQBrand.accent : .primary)
                                }
                                HStack {
                                    Text(round.dateLabel).font(.caption).foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(round.holesPlayed) holes").font(.caption).foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: store.delete)
                }
            }
        }
        .navigationTitle("Round History")
    }
}

struct RoundHistoryDetailView: View {
    let round: SavedRound

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if round.isPlanned {
                    Text("PRACTICE SESSION — Not a live round")
                        .font(.caption).fontWeight(.bold)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(6)
                        .padding(.top, 8)
                }
                HStack {
                    scoreCell("Score", "\(round.totalScore)")
                    Divider().frame(height: 40)
                    scoreCell("To Par", round.scoreToParLabel,
                        color: round.scoreToPar < 0 ? .red : round.scoreToPar == 0 ? .primary : .blue)
                    Divider().frame(height: 40)
                    scoreCell("Holes", "\(round.holesPlayed)/18")
                }
                .padding()

                VStack(spacing: 0) {
                    ForEach(0..<round.scores.count, id: \.self) { i in
                        if round.scores[i] > 0 {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Hole \(i+1)").font(.subheadline)
                                    Text("Par \(i < round.pars.count ? round.pars[i] : 4)")
                                        .font(.caption).foregroundColor(.secondary)
                                    Spacer()
                                    historyScoreDisplay(round.scores[i], i < round.pars.count ? round.pars[i] : 4)
                                }
                                if let tip = round.holeTips[i] {
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "quote.bubble.fill")
                                            .font(.caption2)
                                            .foregroundColor(GolfIQBrand.accent)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(tip.scoreLabel): \(tip.quote)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            if let streakLabel = tip.streakLabel, let streakQuote = tip.streakQuote {
                                                Text("\(streakLabel): \(streakQuote)")
                                                    .font(.caption)
                                                    .foregroundColor(GolfIQBrand.accent)
                                            }
                                            if let puttingLabel = tip.puttingLabel, let puttingQuote = tip.puttingQuote {
                                                Text("⛳ \(puttingLabel): \(puttingQuote)")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle(round.courseName)
        .navigationBarTitleDisplayMode(.inline)
    }

    func scoreCell(_ label: String, _ value: String, color: Color = .primary) -> some View {
        VStack {
            Text(value).font(.title).fontWeight(.bold).foregroundColor(color)
            Text(label).font(.caption).foregroundColor(.secondary)
        }.frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func historyScoreDisplay(_ score: Int, _ par: Int) -> some View {
        let diff = score - par
        ZStack {
            switch diff {
            case ...(-2):
                Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 34, height: 34)
                Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 25, height: 25)
            case -1:
                Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 30, height: 30)
            case 1:
                Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 27, height: 27)
            case 2:
                Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 34, height: 34)
                Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 25, height: 25)
            default:
                EmptyView()
            }
            Text("\(score)")
                .font(.title3).fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 36, height: 36)
    }
}

// MARK: - Round View

struct RoundView: View {
    let selectedCourse: GolfCourse?
    let player: PlayerProfile
    @ObservedObject var mentalGame: MentalGame
    @State private var scores: [Int] = Array(repeating: 0, count: 18)
    @State private var showMentalTip = false
    @State private var currentTip: MentalTip? = nil
    @State private var currentStreakTip: MentalTip? = nil
    @State private var currentStreakLabel = ""
    @State private var currentLabel = ""
    @State private var currentColor: Color = GolfIQBrand.accent
    @StateObject private var historyStore = RoundHistoryStore()
    @State private var showSavedConfirmation = false
    @State private var holeTips: [Int: HoleTipRecord] = [:]
    @State private var isPlanningMode = false

    var pars: [Int] { selectedCourse?.holes.map { $0.par } ?? [4,4,3,5,4,4,3,5,4,4,4,3,5,4,4,3,5,4] }
    var holesPlayed: Int { scores.filter { $0 > 0 }.count }
    var totalScore: Int { scores.filter { $0 > 0 }.reduce(0, +) }
    var parPlayed: Int {
        var total = 0
        for i in 0..<18 { if scores[i] > 0 { total += pars[i] } }
        return total
    }
    var scoreToPar: Int { totalScore - parPlayed }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Mode Toggle — Live Round vs Planning
                    Picker("Mode", selection: $isPlanningMode) {
                        Text("Live Round").tag(false)
                        Text("Practice").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    if isPlanningMode {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                                .font(.caption)
                            Text("Practice Mode — this session won't count as a real round")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.top, 6)
                    }

                    // Score Header
                    HStack {
                        scoreCell("Score", holesPlayed == 0 ? "-" : "\(totalScore)")
                        Divider().frame(height: 40)
                        scoreCell("To Par",
                            holesPlayed == 0 ? "-" : scoreToPar == 0 ? "E" : scoreToPar > 0 ? "+\(scoreToPar)" : "\(scoreToPar)",
                            color: scoreToPar < 0 ? .red : scoreToPar == 0 ? .primary : .blue)
                        Divider().frame(height: 40)
                        scoreCell("Holes", "\(holesPlayed)/18")
                    }
                    .padding().background(Color(.systemBackground))

                    if let course = selectedCourse {
                        HStack {
                            Image(systemName: "map.fill").font(.caption).foregroundColor(GolfIQBrand.accent)
                            Text(course.name).font(.caption).foregroundColor(.secondary)
                        }.padding(.bottom, 4)
                    }

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(0..<18, id: \.self) { i in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Hole \(i+1)").font(.subheadline)
                                        HStack(spacing: 8) {
                                            Text("Par \(pars[i])").font(.caption).foregroundColor(.secondary)
                                            if let course = selectedCourse,
                                               let h = course.holes.first(where: { $0.id == i+1 }) {
                                                Text("HCP \(h.handicap)").font(.caption2).foregroundColor(GolfIQBrand.accent)
                                            }
                                        }
                                    }
                                    Spacer()
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            if scores[i] > 1 { scores[i] -= 1 }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(scores[i] > 0 ? .secondary : Color.secondary.opacity(0.3))
                                        }
                                        .disabled(scores[i] == 0)

                                        scoreDisplay(scores[i], pars[i])

                                        Button(action: {
                                            if scores[i] == 0 { scores[i] = pars[i] }
                                            else { scores[i] += 1 }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(GolfIQBrand.accent)
                                        }

                                        // Done button — triggers mental tip
                                        if scores[i] > 0 {
                                            Button(action: {
                                                let finalScore = scores[i]
                                                showTip(score: finalScore, par: pars[i], holeIndex: i)
                                            }) {
                                                Text("Done")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .frame(width: 72, height: 30)
                                                    .background(GolfIQBrand.accent)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            NavigationLink(destination: RoundHistoryView(store: historyStore)) {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 16) {
                                if holesPlayed > 0 {
                                    Button("Save") {
                                        // Backfill a tip for any scored hole that never had
                                        // "Done" tapped, so history is always complete
                                        var completeTips = holeTips
                                        for i in 0..<scores.count where scores[i] > 0 && completeTips[i] == nil {
                                            let tip = mentalGame.tipForScore(score: scores[i], par: pars[i])
                                            let diff = scores[i] - pars[i]
                                            let label: String
                                            switch diff {
                                            case ...(-2): label = "Eagle or Better!"
                                            case -1:      label = "Birdie!"
                                            case 0:       label = "Par"
                                            case 1:       label = "Bogey"
                                            case 2:       label = "Double Bogey"
                                            default:      label = "Shake it off"
                                            }
                                            completeTips[i] = HoleTipRecord(scoreLabel: label, quote: tip.quote)
                                        }
                                        // Merge in any putting cues picked on the Caddie Edge tab for these holes
                                        for i in 0..<scores.count {
                                            guard let putt = PuttingTipSession.shared.tipsByHole[i + 1] else { continue }
                                            if completeTips[i] != nil {
                                                completeTips[i]?.puttingLabel = putt.label
                                                completeTips[i]?.puttingQuote = putt.quote
                                            } else {
                                                completeTips[i] = HoleTipRecord(
                                                    scoreLabel: "—", quote: "",
                                                    puttingLabel: putt.label, puttingQuote: putt.quote
                                                )
                                            }
                                        }
                                        let round = SavedRound(
                                            date: Date(),
                                            courseName: selectedCourse?.name ?? "Unknown Course",
                                            courseCity: selectedCourse?.city ?? "",
                                            pars: pars,
                                            scores: scores,
                                            holeTips: completeTips,
                                            isPlanned: isPlanningMode
                                        )
                                        historyStore.save(round)
                                        PuttingTipSession.shared.tipsByHole = [:]
                                        showSavedConfirmation = true
                                    }.foregroundColor(GolfIQBrand.accent)
                                }
                                Button("New Round") {
                                    scores = Array(repeating: 0, count: 18)
                                    holeTips = [:]
                                    PuttingTipSession.shared.tipsByHole = [:]
                                    isPlanningMode = false
                                    mentalGame.resetRound()
                                }.foregroundColor(GolfIQBrand.accent)
                            }
                        }
                    }
                    .alert("Round Saved", isPresented: $showSavedConfirmation) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("You can find it under Round History.")
                    }
                }

                if showMentalTip, let tip = currentTip {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture { showMentalTip = false }
                    VStack {
                        Spacer()
                        ScoreMentalTipView(tip: tip, streakTip: currentStreakTip,
                                           streakLabel: currentStreakLabel,
                                           scoreLabel: currentLabel,
                                           accentColor: currentColor) { showMentalTip = false }
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showMentalTip)
                }
            }
            .navigationTitle("Scorecard")
        }
    }

    func showTip(score: Int, par: Int, holeIndex: Int) {
        let diff = score - par
        currentTip = mentalGame.tipForScore(score: score, par: par)
        switch diff {
        case ...(-2): currentLabel = "Eagle or Better!"; currentColor = .yellow
        case -1:      currentLabel = "Birdie!";          currentColor = .red
        case 0:       currentLabel = "Par";              currentColor = GolfIQBrand.accent
        case 1:       currentLabel = "Bogey";            currentColor = .blue
        case 2:       currentLabel = "Double Bogey";     currentColor = .orange
        default:      currentLabel = "Shake it off";     currentColor = .gray
        }
        // Streak detection — requires at least 3 holes played
        currentStreakTip = nil
        currentStreakLabel = ""
        let played = scores.filter { $0 > 0 }
        if played.count >= 3 {
            let recentCount = Bool.random() ? 2 : 3 // random 2 or 3 hole check
            let recent = scores.filter { $0 > 0 }.suffix(recentCount)
            let recentPars = zip(recent, pars.prefix(played.count).suffix(recentCount))
            let diffs = recentPars.map { $0.0 - $0.1 }
            // Birdie streak
            if diffs.allSatisfy({ $0 <= -1 }) {
                currentStreakTip = MentalTipLibrary.birdieStreakTips.randomElement()
                currentStreakLabel = diffs.count == 2 ? "🔥 Back-to-Back Birdies" : "🔥 Birdie Streak — You\'re On A Run"
            }
            // Par streak — only for higher handicaps
            else if diffs.allSatisfy({ $0 == 0 }) && player.handicap >= 15 {
                currentStreakTip = Bool.random() ? MentalTipLibrary.parStreakTips.randomElement() : nil
                currentStreakLabel = "✅ Pars In A Row — Solid Golf"
            }
            // Bogey streak
            else if diffs.allSatisfy({ $0 == 1 }) {
                currentStreakTip = Bool.random() ? MentalTipLibrary.bogeyStreakTips.randomElement() : nil
                currentStreakLabel = "⚠️ Time To Reset"
            }
            // Double+ streak
            else if diffs.allSatisfy({ $0 >= 2 }) {
                currentStreakTip = MentalTipLibrary.doubleStreakTips.randomElement()
                currentStreakLabel = "🚨 Reset Right Now"
            }
        }
        if let tip = currentTip {
            holeTips[holeIndex] = HoleTipRecord(
                scoreLabel: currentLabel,
                quote: tip.quote,
                streakLabel: currentStreakTip != nil ? currentStreakLabel : nil,
                streakQuote: currentStreakTip?.quote
            )
        }
        withAnimation { showMentalTip = true }
    }

    func scoreCell(_ label: String, _ value: String, color: Color = .primary) -> some View {
        VStack {
            Text(value).font(.title).fontWeight(.bold).foregroundColor(color)
            Text(label).font(.caption).foregroundColor(.secondary)
        }.frame(maxWidth: .infinity)
    }

    func scoreColor(_ score: Int?, _ par: Int) -> Color {
        guard let s = score else { return .primary }
        switch s - par {
        case ...(-2): return .yellow; case -1: return .red
        case 0: return .primary; case 1: return .blue; default: return .gray
        }
    }

    @ViewBuilder
    func scoreDisplay(_ score: Int, _ par: Int) -> some View {
        if score == 0 {
            Text("-")
                .font(.title3).fontWeight(.bold)
                .frame(width: 36, height: 36)
                .foregroundColor(.secondary)
        } else {
            let diff = score - par
            ZStack {
                switch diff {
                case ...(-2):
                    Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 34, height: 34)
                    Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 25, height: 25)
                case -1:
                    Circle().stroke(Color.red, lineWidth: 1.5).frame(width: 30, height: 30)
                case 1:
                    Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 27, height: 27)
                case 2:
                    Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 34, height: 34)
                    Rectangle().stroke(Color.white, lineWidth: 1.5).frame(width: 25, height: 25)
                default:
                    EmptyView()
                }
                Text("\(score)")
                    .font(.title3).fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 36, height: 36)
        }
    }

    func scoreColorInt(_ score: Int, _ par: Int) -> Color {
        if score == 0 { return .primary }
        switch score - par {
        case ...(-2): return .yellow; case -1: return .red
        case 0: return .primary; case 1: return .blue; default: return .gray
        }
    }
}

// MARK: - Mental Game Tab

struct MentalGameTabView: View {
    let situations: [(title: String, icon: String, tips: [MentalTip])] = [
        ("Starting Strong", "🌅", MentalTipLibrary.startStrongTips),
        ("Before the Shot", "🎯", MentalTipLibrary.preShotTips),
        ("Stay Patient", "⏳", MentalTipLibrary.patientTips),
        ("Birdie Mindset", "🐦", MentalTipLibrary.birdieTips),
        ("Recovery Mode", "🔄", MentalTipLibrary.bogeyTips),
        ("Pressure Moments", "⚡", MentalTipLibrary.pressureTips),
        ("Closing Out", "🏁", MentalTipLibrary.closingTips),
        ("Resilience", "💪", MentalTipLibrary.tripleTips),
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(situations, id: \.title) { section in
                    NavigationLink(destination: MentalSituationDetailView(
                        title: section.title, icon: section.icon, tips: section.tips)) {
                        HStack(spacing: 14) {
                            Text(section.icon).font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(section.title).font(.headline)
                                Text("\(section.tips.count) tips").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Mental Game")
        }
    }
}

struct MentalSituationDetailView: View {
    let title: String
    let icon: String
    let tips: [MentalTip]

    var body: some View {
        List {
            ForEach(tips) { tip in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text(tip.voice == .caddy ? "Caddy" : "Coach")
                            .font(.caption2)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(tip.voice == .caddy ? GolfIQBrand.accentSoft : Color.purple.opacity(0.12))
                            .foregroundColor(tip.voice == .caddy ? GolfIQBrand.accent : .purple)
                            .cornerRadius(6)
                        Text(tip.philosophy.rawValue).font(.caption2).foregroundColor(.secondary)
                    }
                    Text("\u{201C}\(tip.quote)\u{201D}").font(.subheadline).italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(icon) \(title)")
    }
}

// MARK: - Add Course View

struct AddCourseView: View {
    @Environment(\.dismiss) var dismiss
    @State private var courseName = ""
    @State private var courseCity = ""
    @State private var contactName = ""
    @State private var contactEmail = ""
    @State private var holeData: [(par: String, yards: String, hcp: String)] =
        Array(repeating: (par: "4", yards: "", hcp: ""), count: 18)
    @State private var submitted = false

    var body: some View {
        NavigationView {
            Form {
                Section("Course Information") {
                    HStack {
                        Text("Course Name")
                        Spacer()
                        TextField("Required", text: $courseName)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("City, State")
                        Spacer()
                        TextField("Required", text: $courseCity)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Your Contact") {
                    HStack {
                        Text("Your Name")
                        Spacer()
                        TextField("Optional", text: $contactName)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Your Email")
                        Spacer()
                        TextField("Optional", text: $contactEmail)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.emailAddress)
                    }
                }

                Section("Hole Data") {
                    Text("Enter par, yards, and HCP for each hole")
                        .font(.caption).foregroundColor(.secondary)

                    HStack {
                        Text("Hole").font(.caption).fontWeight(.bold).frame(width: 36)
                        Spacer()
                        Text("Par").font(.caption).fontWeight(.bold).frame(width: 50)
                        Text("Yards").font(.caption).fontWeight(.bold).frame(width: 70)
                        Text("HCP").font(.caption).fontWeight(.bold).frame(width: 50)
                    }
                    .foregroundColor(.secondary)

                    ForEach(0..<18, id: \.self) { i in
                        HStack {
                            Text("\(i+1)").font(.subheadline).frame(width: 36)
                            Spacer()
                            TextField("4", text: $holeData[i].par)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                            TextField("Yards", text: $holeData[i].yards)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 70)
                            TextField("HCP", text: $holeData[i].hcp)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 50)
                        }
                    }
                }

                Section {
                    Button(action: submitCourse) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Course Request")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(courseName.isEmpty || courseCity.isEmpty ? Color.gray : GolfIQBrand.accent)
                        .cornerRadius(10)
                    }
                    .disabled(courseName.isEmpty || courseCity.isEmpty)

                    if submitted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Request sent! We\'ll add \(courseName) within 48 hours.")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add a Course")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(GolfIQBrand.accent)
                }
            }
        }
    }

    func submitCourse() {
        var body = "New Course Request\n\n"
        body += "Course: \(courseName)\n"
        body += "City: \(courseCity)\n"
        if !contactName.isEmpty { body += "Submitted by: \(contactName)\n" }
        if !contactEmail.isEmpty { body += "Contact email: \(contactEmail)\n" }
        body += "\nHole Data:\n"
        body += "Hole | Par | Yards | HCP\n"
        for (i, h) in holeData.enumerated() {
            body += "\(i+1) | \(h.par) | \(h.yards) | \(h.hcp)\n"
        }
        body += "\nPlease also email scorecard photo if available to sleeflow@gmail.com"

        let subject = "New Course Request — \(courseName)"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:sleeflow@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
        submitted = true
    }
}

// MARK: - Course Tab

struct CourseTab: View {
    @Binding var selectedCourse: GolfCourse?
    @State private var showCourseList = false
    @State private var showAddCourse = false

    var body: some View {
        NavigationView {
            Group {
                if let course = selectedCourse {
                    CourseDetailView(course: course) { selectedCourse = nil }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60)).foregroundColor(GolfIQBrand.accent.opacity(0.6))
                        Text("No Course Selected").font(.title2).fontWeight(.semibold)
                        Text("Pick a course to unlock hole-by-hole data and smarter caddie advice.")
                            .font(.subheadline).foregroundColor(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                        Button(action: { showCourseList = true }) {
                            Text("Browse Courses").font(.headline).foregroundColor(.white)
                                .padding(.horizontal, 32).padding(.vertical, 14)
                                .background(GolfIQBrand.accent).cornerRadius(14)
                        }
                        Button(action: { showAddCourse = true }) {
                            Text("+ Request a Course")
                                .font(.subheadline).foregroundColor(GolfIQBrand.accent)
                        }
                    }
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showCourseList = true }) {
                            Label("Browse Courses", systemImage: "list.bullet")
                        }
                        Button(action: { showAddCourse = true }) {
                            Label("Request a Course", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showCourseList) { CourseListView(selectedCourse: $selectedCourse) }
            .sheet(isPresented: $showAddCourse) { AddCourseView() }
        }
    }
}

struct CourseDetailView: View {
    let course: GolfCourse
    let onDeselect: () -> Void

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.name).font(.title2).fontWeight(.bold)
                    Text(course.city).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        statPill("Par", "\(course.par)")
                        statPill("Yards", "\(course.yards)")
                        statPill("Rating", String(format: "%.1f", course.rating))
                        statPill("Slope", "\(course.slope)")
                    }.padding(.top, 4)
                }.padding(.vertical, 4)
            }
            if !course.holes.isEmpty {
                Section("Scorecard") {
                    HStack {
                        Text("Hole").font(.caption).fontWeight(.bold).frame(width: 36, alignment: .leading)
                        Spacer()
                        Text("Par").font(.caption).fontWeight(.bold).frame(width: 28)
                        Text("Yards").font(.caption).fontWeight(.bold).frame(width: 48)
                        Text("HCP").font(.caption).fontWeight(.bold).frame(width: 36)
                    }.foregroundColor(.secondary)
                    ForEach(course.holes) { h in
                        HStack {
                            Text("\(h.id)").font(.subheadline).frame(width: 36, alignment: .leading)
                            Spacer()
                            Text("\(h.par)").font(.subheadline).frame(width: 28)
                                .foregroundColor(h.par == 3 ? .blue : h.par == 5 ? GolfIQBrand.accent : .primary)
                            Text("\(h.yards)").font(.subheadline).frame(width: 48)
                            Text("\(h.handicap)").font(.subheadline).frame(width: 36).foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                Section {
                    Text("Scorecard coming soon — check back after launch")
                        .font(.subheadline).foregroundColor(.secondary)
                }
            }
            Section {
                Button(role: .destructive, action: onDeselect) {
                    HStack { Image(systemName: "xmark.circle"); Text("Remove Course") }
                }
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    func statPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).fontWeight(.bold)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Color(.secondarySystemBackground)).cornerRadius(8)
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @Binding var player: PlayerProfile
    @State private var feedbackRating = 0
    @State private var feedbackText = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Player Info") {
                    HStack {
                        Text("Name"); Spacer()
                        TextField("Your name", text: $player.name)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: player.name) { _, _ in player.save() }
                    }
                    VStack(alignment: .leading) {
                        Text("Handicap: \(player.handicap, specifier: "%.1f")")
                        Slider(value: $player.handicap, in: 0...54, step: 0.1)
                            .accentColor(GolfIQBrand.accent)
                            .onChange(of: player.handicap) { _, _ in player.save() }
                    }
                }
                Section("Typical Miss") {
                    Picker("Miss", selection: $player.missDirection) {
                        ForEach(["Left","Right","Straight","Both Ways"], id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: player.missDirection) { _, _ in player.save() }
                }
                Section("My Clubs (yards)") {
                    Text("Set to 0 for any club you don't carry")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(PlayerProfile.clubOrder, id: \.self) { club in
                        HStack {
                            Text(club).frame(width: 70, alignment: .leading)
                            Stepper(
                                value: Binding(
                                    get: { player.clubDistances[club] ?? PlayerProfile.defaultClubDistances[club] ?? 0 },
                                    set: { player.clubDistances[club] = $0; player.save() }
                                ),
                                in: 0...350, step: 5
                            ) {
                                let yards = player.clubDistances[club] ?? PlayerProfile.defaultClubDistances[club] ?? 0
                                Text(yards == 0 ? "Not in bag" : "\(yards) yds")
                                    .foregroundColor(yards == 0 ? .secondary.opacity(0.6) : .secondary)
                            }
                        }
                    }
                }
                Section("How is Caddie Edge IQ working for you?") {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= feedbackRating ? "star.fill" : "star")
                                    .foregroundColor(star <= feedbackRating ? .yellow : .gray)
                                    .font(.title2).onTapGesture { feedbackRating = star }
                            }
                        }
                        if feedbackRating > 0 {
                            TextField("Tell us more (optional)...", text: $feedbackText, axis: .vertical)
                                .lineLimit(3...6).font(.subheadline)
                            HStack(spacing: 12) {
                                Button(action: sendEmailFeedback) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                        Text("Send Email")
                                    }
                                    .font(.subheadline).foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(GolfIQBrand.accent).cornerRadius(10)
                                }
                                Button(action: { feedbackRating = 0; feedbackText = "" }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle")
                                        Text("Submit")
                                    }
                                    .font(.subheadline).foregroundColor(GolfIQBrand.accent)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(GolfIQBrand.accentSoft).cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                Section("Upgrades 2027") {
                    VStack(alignment: .leading, spacing: 8) {
                        proFeatureRow("Worldwide Course Database", icon: "globe")
                        proFeatureRow("GPS Distance to Pin", icon: "location.fill")
                        proFeatureRow("Advanced Weather Intelligence", icon: "cloud.sun.fill")
                        proFeatureRow("Apple Watch Support", icon: "applewatch")
                    }
                    .padding(.vertical, 4)
                }
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Caddie Edge IQ").font(.headline).foregroundColor(GolfIQBrand.accent)
                        Text(GolfIQBrand.tagline).font(.caption).foregroundColor(.secondary)
                        Text("Caddie Edge IQ  |  Version 1.0 Beta").font(.caption2).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationSubtitle("Hit Fairways. Hit Greens. Make Putts!")
        }
    }

    func proFeatureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(GolfIQBrand.accent).frame(width: 20)
            Text(text).font(.subheadline)
            Spacer()
            Text("Pro").font(.caption2).fontWeight(.bold).foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(GolfIQBrand.accent).cornerRadius(6)
        }
    }

    func sendEmailFeedback() {
        let stars = String(repeating: "⭐", count: feedbackRating)
        let body = "Caddie Edge IQ Feedback\nFrom: \(player.name)\nRating: \(stars) (\(feedbackRating)/5)\nHandicap: \(String(format: "%.1f", player.handicap))\nTypical Miss: \(player.missDirection)\nComments: \(feedbackText.isEmpty ? "No additional comments" : feedbackText)"
        let encoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let subject = "GolfIQ%20Feedback%20-%20\(feedbackRating)%20Stars"
        if let url = URL(string: "mailto:\(GolfIQBrand.feedbackEmail)?subject=\(subject)&body=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

import SwiftUI

enum ReactionStyle {
    case pop        // spring scale-in, subtle breathing during hold
    case shake      // violent horizontal jitter (vine-boom energy)
    case spin       // continuous 360° rotation
    case drop       // falls from above with bounce
    case stretch    // horizontal scaleX oscillation
    case explode    // big overshoot scale on entry
}

struct VoteReaction {
    let sound: String
    let emoji: String
    let caption: String
    let captionColor: Color
    let style: ReactionStyle
}

enum VoteReactionPool {
    static let smash: [VoteReaction] = [
        VoteReaction(sound: "anime-wow-sound-effect",           emoji: "🤯", caption: "DECEASED",    captionColor: AppTheme.pink,   style: .explode),
        VoteReaction(sound: "mlg-airhorn",                      emoji: "🗣️", caption: "SHEEEESH",    captionColor: AppTheme.orange, style: .spin),
        VoteReaction(sound: "ding-sound-effect_2",              emoji: "💯", caption: "no cap",      captionColor: AppTheme.yellow, style: .drop),
        VoteReaction(sound: "oh-my-god-meme",                   emoji: "😩", caption: "+1000 aura",  captionColor: AppTheme.pink,   style: .shake),
        VoteReaction(sound: "romanceeeeeeeeeeeeee",             emoji: "💘", caption: "delulu 4 u",  captionColor: AppTheme.pink,   style: .stretch),
    ]

    static let pass: [VoteReaction] = [
        VoteReaction(sound: "vine-boom",                            emoji: "💀", caption: "him??",         captionColor: AppTheme.textDim, style: .shake),
        VoteReaction(sound: "spongebob-fail",                       emoji: "🤡", caption: "clown fr",      captionColor: AppTheme.red,     style: .spin),
        VoteReaction(sound: "wrong-answer-sound-effect",            emoji: "❌", caption: "nope.exe",      captionColor: AppTheme.red,     style: .drop),
        VoteReaction(sound: "tuco-get-out",                         emoji: "🫥", caption: "vanish pls",    captionColor: AppTheme.red,     style: .shake),
        VoteReaction(sound: "sad-meow-song",                        emoji: "😿", caption: "the ick",       captionColor: AppTheme.blue,    style: .pop),
        VoteReaction(sound: "omni-man-are-you-sure",                emoji: "🤨", caption: "u sure bae?",   captionColor: AppTheme.purple,  style: .pop),
        VoteReaction(sound: "bone-crack",                           emoji: "💥", caption: "FATALITY",      captionColor: AppTheme.red,     style: .shake),
        VoteReaction(sound: "metal-pipe-clang",                     emoji: "🪛", caption: "oop-",          captionColor: AppTheme.silver,  style: .drop),
        VoteReaction(sound: "perfect-fart",                         emoji: "💨", caption: "yikes",         captionColor: AppTheme.green,   style: .pop),
        VoteReaction(sound: "long-brain-fart",                      emoji: "🧠", caption: "lobotomy",      captionColor: AppTheme.pink,    style: .pop),
        VoteReaction(sound: "error_CDOxCYm",                        emoji: "🚫", caption: "404 rizz",      captionColor: AppTheme.red,     style: .shake),
        VoteReaction(sound: "punch-gaming-sound-effect-hd_RzlG1GE", emoji: "👊", caption: "KO'd",          captionColor: AppTheme.orange,  style: .explode),
        VoteReaction(sound: "gunshotjbudden",                       emoji: "🥀", caption: "rip bozo",      captionColor: AppTheme.red,     style: .drop),
        VoteReaction(sound: "dexter-meme",                          emoji: "🚪", caption: "GTFO",          captionColor: AppTheme.red,     style: .shake),
    ]

    static let skip: [VoteReaction] = [
        VoteReaction(sound: "baby-laughing-meme",         emoji: "👶", caption: "wait wat",  captionColor: AppTheme.textDim, style: .pop),
        VoteReaction(sound: "cat-laugh-meme-1",           emoji: "😹", caption: "lmaoo",     captionColor: AppTheme.textDim, style: .shake),
        VoteReaction(sound: "chicken-on-tree-screaming",  emoji: "🐔", caption: "BWAK",      captionColor: AppTheme.textDim, style: .shake),
        VoteReaction(sound: "m-e-o-w",                    emoji: "😺", caption: "mrow?",     captionColor: AppTheme.textDim, style: .pop),
        VoteReaction(sound: "among-us-role-reveal-sound", emoji: "🧑‍🚀", caption: "sus",      captionColor: AppTheme.red,     style: .pop),
        VoteReaction(sound: "tf_nemesis",                 emoji: "⚠️", caption: "mid",       captionColor: AppTheme.textDim, style: .shake),
        VoteReaction(sound: "movie_1",                    emoji: "🎬", caption: "plot twist", captionColor: AppTheme.textDim, style: .pop),
        VoteReaction(sound: "gopgopgop",                  emoji: "🥁", caption: "gop gop",   captionColor: AppTheme.textDim, style: .shake),
        VoteReaction(sound: "fahhhhhhhhhhhhhh",           emoji: "😮‍💨", caption: "im cooked", captionColor: AppTheme.textDim, style: .stretch),
    ]

    static func random(for type: VoteType) -> VoteReaction {
        switch type {
        case .smash: return smash.randomElement() ?? smash[0]
        case .pass:  return pass.randomElement()  ?? pass[0]
        case .skip:  return skip.randomElement()  ?? skip[0]
        }
    }
}

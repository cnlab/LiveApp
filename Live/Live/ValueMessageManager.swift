//
//  ValueMessageManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class ValueMessageManager {

    var messageSequence = [Message]()
    var filterGroup: String
    var lastMessage: String?

    var group: String {

        get {
            return filterGroup
        }

        set {
            if filterGroup != newValue {
                lastMessage = nil
                messageSequence.removeAll()
            }
            filterGroup = newValue
        }

    }

    func next() -> Message {
        if messageSequence.isEmpty {
            messageSequence = MessageManager().getMessageSequence(messages: messages, group: filterGroup, lastMessage: lastMessage)
            if let message = messageSequence.last {
                lastMessage = message.identifier
            }
        }
        return messageSequence.removeFirst()
    }

    let messages: [Message]

    init() {
        let independence = "Independence"
        let politics = "Politics"
        let spirituality = "Spirituality"
        let humor = "Humor"
        let fame = "Fame"
        let powerAndStatus = "Power and Status"
        let familyAndFriends = "Family and Friends"
        let compassionAndKindness = "Compassion and Kindness"

        filterGroup = independence

        messages = [
            Message(group: independence, identifier: "1", string: "not being swayed by the thoughts or feelings of others"),
            Message(group: independence, identifier: "2", string: "deciding to do something because you felt that it was the right thing to do"),
            Message(group: independence, identifier: "3", string: "standing up for yourself"),
            Message(group: independence, identifier: "4", string: "making a decision about something, regardless of what others thought"),
            Message(group: independence, identifier: "5", string: "speaking out about something when others have not"),
            Message(group: independence, identifier: "6", string: "excelling in a situation as a result of your ability to think on your own"),
            Message(group: independence, identifier: "7", string: "taking responsibility for your own actions"),
            Message(group: independence, identifier: "8", string: "making informed choices"),
            Message(group: independence, identifier: "9", string: "having the freedom to do what you want"),
            Message(group: independence, identifier: "10", string: "being self-sufficient"),
            Message(group: independence, identifier: "11", string: "being on your own"),
            Message(group: independence, identifier: "12", string: "being responsible for yourself"),
            Message(group: independence, identifier: "13", string: "voicing your own opinion during a discussion"),
            Message(group: independence, identifier: "14", string: "waking up in the morning and dressing the way that you wanted to"),
            Message(group: independence, identifier: "15", string: "being solely responsible for your everyday successes"),
            Message(group: independence, identifier: "16", string: "seeing someone else make their own decisions"),
            Message(group: independence, identifier: "17", string: "being secure about your choice, even if it was an unpopular one"),
            Message(group: independence, identifier: "18", string: "self-respect that your independence gave you"),
            Message(group: independence, identifier: "19", string: "being your own boss"),
            Message(group: independence, identifier: "20", string: "making your own set of rules"),

            Message(group: politics, identifier: "1", string: "thinking about choices politicians made"),
            Message(group: politics, identifier: "2", string: "getting fired up from watching the news"),
            Message(group: politics, identifier: "3", string: "engaging with the political system"),
            Message(group: politics, identifier: "4", string: "being inspired by people taking political action"),
            Message(group: politics, identifier: "5", string: "being frustrated with inefficiency in the political system"),
            Message(group: politics, identifier: "6", string: "being frustrated with waste in the government"),
            Message(group: politics, identifier: "7", string: "obeying the law"),
            Message(group: politics, identifier: "8", string: "being involved in politics"),
            Message(group: politics, identifier: "9", string: "enjoying living in a democracy"),
            Message(group: politics, identifier: "10", string: "reading about current events"),
            Message(group: politics, identifier: "11", string: "paying taxes"),
            Message(group: politics, identifier: "12", string: "feeling politically informed"),
            Message(group: politics, identifier: "13", string: "feeling up to date on current events"),
            Message(group: politics, identifier: "14", string: "being educated on issues"),
            Message(group: politics, identifier: "15", string: "taking a stand on an issue"),
            Message(group: politics, identifier: "16", string: "learning about the news on-line"),
            Message(group: politics, identifier: "17", string: "buying products made in the US"),
            Message(group: politics, identifier: "18", string: "reading the newspaper"),
            Message(group: politics, identifier: "19", string: "watching the news on TV"),
            Message(group: politics, identifier: "20", string: "voting"),

            Message(group: spirituality, identifier: "1", string: "handing your problems over to God or a higher power"),
            Message(group: spirituality, identifier: "2", string: "getting help from God or a higher power"),
            Message(group: spirituality, identifier: "3", string: "be blessed by a spiritual connection"),
            Message(group: spirituality, identifier: "4", string: "reflecting on spiritual beliefs that give you a sense of peace during a hard time"),
            Message(group: spirituality, identifier: "5", string: "finding spiritual values to keep life in perspective"),
            Message(group: spirituality, identifier: "6", string: "praising and being connected to God or a higher power"),
            Message(group: spirituality, identifier: "7", string: "finding spiritual values that help give you guidelines to live by"),
            Message(group: spirituality, identifier: "8", string: "using religious beliefs that help you show love to others"),
            Message(group: spirituality, identifier: "9", string: "seeing God or a higher power in nature"),
            Message(group: spirituality, identifier: "10", string: "having spiritual values offering you moral guidance"),
            Message(group: spirituality, identifier: "11", string: "having spiritual values helping you feel fulfilled"),
            Message(group: spirituality, identifier: "12", string: "having spiritual values help you deal with stress"),
            Message(group: spirituality, identifier: "13", string: "connecting with spiritual values to feel energized"),
            Message(group: spirituality, identifier: "14", string: "having spiritual values give you a purpose in life"),
            Message(group: spirituality, identifier: "15", string: "using meditation or prayer to achieve a spiritual connection"),
            Message(group: spirituality, identifier: "16", string: "meditating and feel connected to the world"),
            Message(group: spirituality, identifier: "17", string: "having spiritual guidance to help you with your decisions"),
            Message(group: spirituality, identifier: "18", string: "having spiritual beliefs that lead you to ask for forgiveness"),
            Message(group: spirituality, identifier: "19", string: "having spiritual beliefs that lead you to forgive"),
            Message(group: spirituality, identifier: "20", string: "relying on spiritual guidance to go through difficult times"),

            Message(group: humor, identifier: "1", string: "finding humor in an unexpected situation"),
            Message(group: humor, identifier: "2", string: "incorporating humor into your own work"),
            Message(group: humor, identifier: "3", string: "using your humor to cheer someone up"),
            Message(group: humor, identifier: "4", string: "seeing humor in a difficult moment"),
            Message(group: humor, identifier: "5", string: "diffusing a tense situation with humor"),
            Message(group: humor, identifier: "6", string: "laughing really hard"),
            Message(group: humor, identifier: "7", string: "making someone else laugh"),
            Message(group: humor, identifier: "8", string: "watching a really funny video"),
            Message(group: humor, identifier: "9", string: "laughing at a really funny joke"),
            Message(group: humor, identifier: "10", string: "relieving some stress by laughing"),
            Message(group: humor, identifier: "11", string: "having someone else make you laugh"),
            Message(group: humor, identifier: "12", string: "using your humor to get through a bad day"),
            Message(group: humor, identifier: "13", string: "not taking life too seriously"),
            Message(group: humor, identifier: "14", string: "connection with someone else when you shared a laugh"),
            Message(group: humor, identifier: "15", string: "overcoming an obstacle by finding humor in a situation"),
            Message(group: humor, identifier: "16", string: "using humor to illuminate the absurd in the world"),
            Message(group: humor, identifier: "17", string: "relieving some of your stress with humor"),
            Message(group: humor, identifier: "18", string: "lifting somebody else's mood with humor"),
            Message(group: humor, identifier: "19", string: "being with others who shared a similar sense of humor"),
            Message(group: humor, identifier: "20", string: "excelling in your everyday work using your sense of humor"),

            Message(group: fame, identifier: "1", string: "becoming famous and well known"),
            Message(group: fame, identifier: "2", string: "having many people recognize you on the street"),
            Message(group: fame, identifier: "3", string: "becoming a local celebrity"),
            Message(group: fame, identifier: "4", string: "being popular among your peers"),
            Message(group: fame, identifier: "5", string: "becoming so famous that people recognize you in public"),
            Message(group: fame, identifier: "6", string: "having many people like you and want to be around you"),
            Message(group: fame, identifier: "7", string: "feeling like you are so famous that everyone on the street recognizes you"),
            Message(group: fame, identifier: "8", string: "being recognized publicly"),
            Message(group: fame, identifier: "9", string: "becoming well known in your town"),
            Message(group: fame, identifier: "10", string: "being popular and have people want to talk to you"),
            Message(group: fame, identifier: "11", string: "having people be impressed with who you are and what you do"),
            Message(group: fame, identifier: "12", string: "having many people who want to invite you to their parties"),
            Message(group: fame, identifier: "13", string: "being the center of attention"),
            Message(group: fame, identifier: "14", string: "being widely recognized for what you've achieved in life"),
            Message(group: fame, identifier: "15", string: "feeling like you are well known to everyone"),
            Message(group: fame, identifier: "16", string: "having people want to become friends with you"),
            Message(group: fame, identifier: "17", string: "feeling like you are a popular person"),
            Message(group: fame, identifier: "18", string: "getting loads of hits when someone searches your name on Google"),
            Message(group: fame, identifier: "19", string: "being asked to do high profile things in your community"),
            Message(group: fame, identifier: "20", string: "feeling like you are the most popular person on the street"),

            Message(group: powerAndStatus, identifier: "1", string: "being in a position to hire many people who work for you"),
            Message(group: powerAndStatus, identifier: "2", string: "becoming a leader in your organization"),
            Message(group: powerAndStatus, identifier: "3", string: "being rated as one of the most influential people at work or in an organization"),
            Message(group: powerAndStatus, identifier: "4", string: "being in a high position at work and feel important"),
            Message(group: powerAndStatus, identifier: "5", string: "having many connections to socially powerful people"),
            Message(group: powerAndStatus, identifier: "6", string: "having a high profile career"),
            Message(group: powerAndStatus, identifier: "7", string: "becoming a CEO of a company or organization"),
            Message(group: powerAndStatus, identifier: "8", string: "having a high social status and people take your opinions seriously"),
            Message(group: powerAndStatus, identifier: "9", string: "gaining power and social status"),
            Message(group: powerAndStatus, identifier: "10", string: "being in a prestigious position at work"),
            Message(group: powerAndStatus, identifier: "11", string: "being thought of as important among people"),
            Message(group: powerAndStatus, identifier: "12", string: "being in a position to make important decisions at work or in your organization"),
            Message(group: powerAndStatus, identifier: "13", string: "serving in a leadership role and have people listen to you"),
            Message(group: powerAndStatus, identifier: "14", string: "feeling important and powerful"),
            Message(group: powerAndStatus, identifier: "15", string: "getting others to recognize or acknowledge your impact"),
            Message(group: powerAndStatus, identifier: "16", string: "having the authority to get people do what you ask"),
            Message(group: powerAndStatus, identifier: "17", string: "being in a socially powerful position"),
            Message(group: powerAndStatus, identifier: "18", string: "becoming a president or leader of your organization"),
            Message(group: powerAndStatus, identifier: "19", string: "being in a powerful position to make decisions for other people"),
            Message(group: powerAndStatus, identifier: "20", string: "being in a high position to have people work for you"),

            Message(group: familyAndFriends, identifier: "1", string: "having fun with family and friends"),
            Message(group: familyAndFriends, identifier: "2", string: "getting support from your friends and family"),
            Message(group: familyAndFriends, identifier: "3", string: "having your friends and family come to you for advice"),
            Message(group: familyAndFriends, identifier: "4", string: "being present for an important event in someone's life"),
            Message(group: familyAndFriends, identifier: "5", string: "reaching out to a loved one who is having a hard time"),
            Message(group: familyAndFriends, identifier: "6", string: "making time for a friend or family member"),
            Message(group: familyAndFriends, identifier: "7", string: "being a good friend or family member"),
            Message(group: familyAndFriends, identifier: "8", string: "spending extra time with friends and family"),
            Message(group: familyAndFriends, identifier: "9", string: "being proud of your friends and family"),
            Message(group: familyAndFriends, identifier: "10", string: "being able to rely on your friends and family"),
            Message(group: familyAndFriends, identifier: "11", string: "telling a friend or family member that you love them"),
            Message(group: familyAndFriends, identifier: "12", string: "feeling you belong to a family or friendship"),
            Message(group: familyAndFriends, identifier: "13", string: "reuniting with friends or family after a long absence"),
            Message(group: familyAndFriends, identifier: "14", string: "maintaining traditions with your friends or family"),
            Message(group: familyAndFriends, identifier: "15", string: "your friends or family showing you love"),
            Message(group: familyAndFriends, identifier: "16", string: "having connection with your friends and family"),
            Message(group: familyAndFriends, identifier: "17", string: "sharing life experiences with your friends and family"),
            Message(group: familyAndFriends, identifier: "18", string: "feeling that you belong to a family or friendship"),
            Message(group: familyAndFriends, identifier: "19", string: "helping a friend or family member achieve an accomplishment"),
            Message(group: familyAndFriends, identifier: "20", string: "having a friend or family member help you achieve an accomplishment"),

            Message(group: compassionAndKindness, identifier: "1", string: "letting people know that you care for them"),
            Message(group: compassionAndKindness, identifier: "2", string: "comforting and cheer up someone who is feeling sad"),
            Message(group: compassionAndKindness, identifier: "3", string: "saying something kind to show your love"),
            Message(group: compassionAndKindness, identifier: "4", string: "letting someone who is suffering know that you are there for them to lean on"),
            Message(group: compassionAndKindness, identifier: "5", string: "helping someone in trouble without expecting anything in return"),
            Message(group: compassionAndKindness, identifier: "6", string: "allowing others to be themselves in your presence"),
            Message(group: compassionAndKindness, identifier: "7", string: "accepting and be understanding of others' weaknesses"),
            Message(group: compassionAndKindness, identifier: "8", string: "smiling at someone you pass by"),
            Message(group: compassionAndKindness, identifier: "9", string: "letting someone going through difficult times know that you are proud of them"),
            Message(group: compassionAndKindness, identifier: "10", string: "encouraging someone who is in trouble"),
            Message(group: compassionAndKindness, identifier: "11", string: "being gentle and compassionate with someone in emotional pain"),
            Message(group: compassionAndKindness, identifier: "12", string: "forgiving someone for their mistakes"),
            Message(group: compassionAndKindness, identifier: "13", string: "making someone feel better"),
            Message(group: compassionAndKindness, identifier: "14", string: "showing compassion to someone else"),
            Message(group: compassionAndKindness, identifier: "15", string: "genuinely caring about someone"),
            Message(group: compassionAndKindness, identifier: "16", string: "letting go of a grudge and forgive"),
            Message(group: compassionAndKindness, identifier: "17", string: "feeling sorry and care for others in tough situations"),
            Message(group: compassionAndKindness, identifier: "18", string: "showing people how much you love them by expressing kindness"),
            Message(group: compassionAndKindness, identifier: "19", string: "letting someone know how much they mean to you"),
            Message(group: compassionAndKindness, identifier: "20", string: "being tender to someone who is in trouble"),
        ]
    }

}

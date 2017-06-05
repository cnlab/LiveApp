//
//  ValueMessageManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class ValueMessageManager: MessageManager {

    class State: JSONConvertable {

        var messageKeySequence: [Message.Key]
        var filterGroup: String
        var lastMessage: String?

        init(messageKeySequence: [Message.Key] = [], filterGroup: String, lastMessage: String? = nil) {
            self.messageKeySequence = messageKeySequence
            self.filterGroup = filterGroup
            self.lastMessage = lastMessage
        }

        required init(json: [String: Any]) throws {
            let messageKeySequence: [Message.Key] = try JSON.jsonArray(json: json, key: "messageKeySequence")
            let filterGroup = try JSON.jsonString(json: json, key: "filterGroup")
            let lastMessage = try JSON.jsonOptionalString(json: json, key: "lastMessage")

            self.messageKeySequence = messageKeySequence
            self.filterGroup = filterGroup
            self.lastMessage = lastMessage
        }

        func json() -> [String: Any] {
            var object: [String: Any] = [
                "messageKeySequence": JSON.json(array: messageKeySequence),
                "filterGroup": JSON.json(string: filterGroup),
            ]
            if let lastMessage = lastMessage {
                object["lastMessage"] = JSON.json(string: lastMessage)
            }
            return object
        }

    }

    var type: String {
        get {
            return "Value"
        }
    }
    let messages: [Message]
    var state: State

    var group: String {

        get {
            return state.filterGroup
        }

        set {
            if state.filterGroup != newValue {
                state.lastMessage = nil
                state.messageKeySequence.removeAll()
            }
            state.filterGroup = newValue
        }

    }

    static let independence = "Independence"
    static let politics = "Politics"
    static let spirituality = "Spirituality"
    static let humor = "Humor"
    static let fame = "Fame"
    static let powerAndStatus = "Power & Status"
    static let familyAndFriends = "Family & Friends"
    static let compassionAndKindness = "Compassion & Kindness"

    static let groups = [familyAndFriends, compassionAndKindness, spirituality, humor, independence, powerAndStatus, politics, fame]

    init() {
        let independence = ValueMessageManager.independence
        let politics = ValueMessageManager.politics
        let spirituality = ValueMessageManager.spirituality
        let humor = ValueMessageManager.humor
        let fame = ValueMessageManager.fame
        let powerAndStatus = ValueMessageManager.powerAndStatus
        let familyAndFriends = ValueMessageManager.familyAndFriends
        let compassionAndKindness = ValueMessageManager.compassionAndKindness

        state = State(filterGroup: independence)

        messages = [
            Message(group: independence, identifier: "1", string: "Think about not being swayed by the thoughts or feelings of others."),
            Message(group: independence, identifier: "2", string: "Think about deciding to do something because you felt that it was the right thing to do."),
            Message(group: independence, identifier: "3", string: "Think about standing up for yourself."),
            Message(group: independence, identifier: "4", string: "Think about making a decision about something, regardless of what others thought."),
            Message(group: independence, identifier: "5", string: "Think about speaking out about something when others have not."),
            Message(group: independence, identifier: "6", string: "Think about excelling in a situation as a result of your ability to think on your own."),
            Message(group: independence, identifier: "7", string: "Think about taking responsibility for your own actions."),
            Message(group: independence, identifier: "8", string: "Think about making informed choices."),
            Message(group: independence, identifier: "9", string: "Think about having the freedom to do what you want."),
            Message(group: independence, identifier: "10", string: "Think about being self-sufficient."),
            Message(group: independence, identifier: "11", string: "Think about being on your own."),
            Message(group: independence, identifier: "12", string: "Think about being responsible for yourself."),
            Message(group: independence, identifier: "13", string: "Think about voicing your own opinion during a discussion."),
            Message(group: independence, identifier: "14", string: "Think about waking up in the morning and dressing the way that you wanted to."),
            Message(group: independence, identifier: "15", string: "Think about being solely responsible for your everyday successes."),
            Message(group: independence, identifier: "16", string: "Think about seeing someone else make their own decisions."),
            Message(group: independence, identifier: "17", string: "Think about being secure about your choice, even if it was an unpopular one."),
            Message(group: independence, identifier: "18", string: "Think about self-respect that your independence gave you."),
            Message(group: independence, identifier: "19", string: "Think about being your own boss."),
            Message(group: independence, identifier: "20", string: "Think about making your own set of rules."),

            Message(group: politics, identifier: "1", string: "Think about thinking about choices politicians made."),
            Message(group: politics, identifier: "2", string: "Think about getting fired up from watching the news."),
            Message(group: politics, identifier: "3", string: "Think about engaging with the political system."),
            Message(group: politics, identifier: "4", string: "Think about being inspired by people taking political action."),
            Message(group: politics, identifier: "5", string: "Think about being frustrated with inefficiency in the political system."),
            Message(group: politics, identifier: "6", string: "Think about being frustrated with waste in the government."),
            Message(group: politics, identifier: "7", string: "Think about obeying the law."),
            Message(group: politics, identifier: "8", string: "Think about being involved in politics."),
            Message(group: politics, identifier: "9", string: "Think about enjoying living in a democracy."),
            Message(group: politics, identifier: "10", string: "Think about reading about current events."),
            Message(group: politics, identifier: "11", string: "Think about paying taxes."),
            Message(group: politics, identifier: "12", string: "Think about feeling politically informed."),
            Message(group: politics, identifier: "13", string: "Think about feeling up to date on current events."),
            Message(group: politics, identifier: "14", string: "Think about being educated on issues."),
            Message(group: politics, identifier: "15", string: "Think about taking a stand on an issue."),
            Message(group: politics, identifier: "16", string: "Think about learning about the news on-line."),
            Message(group: politics, identifier: "17", string: "Think about buying products made in the US."),
            Message(group: politics, identifier: "18", string: "Think about reading the newspaper."),
            Message(group: politics, identifier: "19", string: "Think about watching the news on TV."),
            Message(group: politics, identifier: "20", string: "Think about voting."),

            Message(group: spirituality, identifier: "1", string: "Think about handing your problems over to God or a higher power."),
            Message(group: spirituality, identifier: "2", string: "Think about getting help from God or a higher power."),
            Message(group: spirituality, identifier: "3", string: "Think about be blessed by a spiritual connection."),
            Message(group: spirituality, identifier: "4", string: "Think about reflecting on spiritual beliefs that give you a sense of peace during a hard time."),
            Message(group: spirituality, identifier: "5", string: "Think about finding spiritual values to keep life in perspective."),
            Message(group: spirituality, identifier: "6", string: "Think about praising and being connected to God or a higher power."),
            Message(group: spirituality, identifier: "7", string: "Think about finding spiritual values that help give you guidelines to live by."),
            Message(group: spirituality, identifier: "8", string: "Think about using religious beliefs that help you show love to others."),
            Message(group: spirituality, identifier: "9", string: "Think about seeing God or a higher power in nature."),
            Message(group: spirituality, identifier: "10", string: "Think about having spiritual values offering you moral guidance."),
            Message(group: spirituality, identifier: "11", string: "Think about having spiritual values helping you feel fulfilled."),
            Message(group: spirituality, identifier: "12", string: "Think about having spiritual values help you deal with stress."),
            Message(group: spirituality, identifier: "13", string: "Think about connecting with spiritual values to feel energized."),
            Message(group: spirituality, identifier: "14", string: "Think about having spiritual values give you a purpose in life."),
            Message(group: spirituality, identifier: "15", string: "Think about using meditation or prayer to achieve a spiritual connection."),
            Message(group: spirituality, identifier: "16", string: "Think about meditating and feel connected to the world."),
            Message(group: spirituality, identifier: "17", string: "Think about having spiritual guidance to help you with your decisions."),
            Message(group: spirituality, identifier: "18", string: "Think about having spiritual beliefs that lead you to ask for forgiveness."),
            Message(group: spirituality, identifier: "19", string: "Think about having spiritual beliefs that lead you to forgive."),
            Message(group: spirituality, identifier: "20", string: "Think about relying on spiritual guidance to go through difficult times."),

            Message(group: humor, identifier: "1", string: "Think about finding humor in an unexpected situation."),
            Message(group: humor, identifier: "2", string: "Think about incorporating humor into your own work."),
            Message(group: humor, identifier: "3", string: "Think about using your humor to cheer someone up."),
            Message(group: humor, identifier: "4", string: "Think about seeing humor in a difficult moment."),
            Message(group: humor, identifier: "5", string: "Think about diffusing a tense situation with humor."),
            Message(group: humor, identifier: "6", string: "Think about laughing really hard."),
            Message(group: humor, identifier: "7", string: "Think about making someone else laugh."),
            Message(group: humor, identifier: "8", string: "Think about watching a really funny video."),
            Message(group: humor, identifier: "9", string: "Think about laughing at a really funny joke."),
            Message(group: humor, identifier: "10", string: "Think about relieving some stress by laughing."),
            Message(group: humor, identifier: "11", string: "Think about having someone else make you laugh."),
            Message(group: humor, identifier: "12", string: "Think about using your humor to get through a bad day."),
            Message(group: humor, identifier: "13", string: "Think about not taking life too seriously."),
            Message(group: humor, identifier: "14", string: "Think about connection with someone else when you shared a laugh."),
            Message(group: humor, identifier: "15", string: "Think about overcoming an obstacle by finding humor in a situation."),
            Message(group: humor, identifier: "16", string: "Think about using humor to illuminate the absurd in the world."),
            Message(group: humor, identifier: "17", string: "Think about relieving some of your stress with humor."),
            Message(group: humor, identifier: "18", string: "Think about lifting somebody else's mood with humor."),
            Message(group: humor, identifier: "19", string: "Think about being with others who shared a similar sense of humor."),
            Message(group: humor, identifier: "20", string: "Think about excelling in your everyday work using your sense of humor."),

            Message(group: fame, identifier: "1", string: "Think about becoming famous and well known."),
            Message(group: fame, identifier: "2", string: "Think about having many people recognize you on the street."),
            Message(group: fame, identifier: "3", string: "Think about becoming a local celebrity."),
            Message(group: fame, identifier: "4", string: "Think about being popular among your peers."),
            Message(group: fame, identifier: "5", string: "Think about becoming so famous that people recognize you in public."),
            Message(group: fame, identifier: "6", string: "Think about having many people like you and want to be around you."),
            Message(group: fame, identifier: "7", string: "Think about feeling like you are so famous that everyone on the street recognizes you."),
            Message(group: fame, identifier: "8", string: "Think about being recognized publicly."),
            Message(group: fame, identifier: "9", string: "Think about becoming well known in your town."),
            Message(group: fame, identifier: "10", string: "Think about being popular and have people want to talk to you."),
            Message(group: fame, identifier: "11", string: "Think about having people be impressed with who you are and what you do."),
            Message(group: fame, identifier: "12", string: "Think about having many people who want to invite you to their parties."),
            Message(group: fame, identifier: "13", string: "Think about being the center of attention."),
            Message(group: fame, identifier: "14", string: "Think about being widely recognized for what you've achieved in life."),
            Message(group: fame, identifier: "15", string: "Think about feeling like you are well known to everyone."),
            Message(group: fame, identifier: "16", string: "Think about having people want to become friends with you."),
            Message(group: fame, identifier: "17", string: "Think about feeling like you are a popular person."),
            Message(group: fame, identifier: "18", string: "Think about getting loads of hits when someone searches your name on Google."),
            Message(group: fame, identifier: "19", string: "Think about being asked to do high profile things in your community."),
            Message(group: fame, identifier: "20", string: "Think about feeling like you are the most popular person on the street."),

            Message(group: powerAndStatus, identifier: "1", string: "Think about being in a position to hire many people who work for you."),
            Message(group: powerAndStatus, identifier: "2", string: "Think about becoming a leader in your organization."),
            Message(group: powerAndStatus, identifier: "3", string: "Think about being rated as one of the most influential people at work or in an organization."),
            Message(group: powerAndStatus, identifier: "4", string: "Think about being in a high position at work and feel important."),
            Message(group: powerAndStatus, identifier: "5", string: "Think about having many connections to socially powerful people."),
            Message(group: powerAndStatus, identifier: "6", string: "Think about having a high profile career."),
            Message(group: powerAndStatus, identifier: "7", string: "Think about becoming a CEO of a company or organization."),
            Message(group: powerAndStatus, identifier: "8", string: "Think about having a high social status and people take your opinions seriously."),
            Message(group: powerAndStatus, identifier: "9", string: "Think about gaining power and social status."),
            Message(group: powerAndStatus, identifier: "10", string: "Think about being in a prestigious position at work."),
            Message(group: powerAndStatus, identifier: "11", string: "Think about being thought of as important among people."),
            Message(group: powerAndStatus, identifier: "12", string: "Think about being in a position to make important decisions at work or in your organization."),
            Message(group: powerAndStatus, identifier: "13", string: "Think about serving in a leadership role and have people listen to you."),
            Message(group: powerAndStatus, identifier: "14", string: "Think about feeling important and powerful."),
            Message(group: powerAndStatus, identifier: "15", string: "Think about getting others to recognize or acknowledge your impact."),
            Message(group: powerAndStatus, identifier: "16", string: "Think about having the authority to get people do what you ask."),
            Message(group: powerAndStatus, identifier: "17", string: "Think about being in a socially powerful position."),
            Message(group: powerAndStatus, identifier: "18", string: "Think about becoming a president or leader of your organization."),
            Message(group: powerAndStatus, identifier: "19", string: "Think about being in a powerful position to make decisions for other people."),
            Message(group: powerAndStatus, identifier: "20", string: "Think about being in a high position to have people work for you."),

            Message(group: familyAndFriends, identifier: "1", string: "Think about having fun with family and friends."),
            Message(group: familyAndFriends, identifier: "2", string: "Think about getting support from your friends and family."),
            Message(group: familyAndFriends, identifier: "3", string: "Think about having your friends and family come to you for advice."),
            Message(group: familyAndFriends, identifier: "4", string: "Think about being present for an important event in someone's life."),
            Message(group: familyAndFriends, identifier: "5", string: "Think about reaching out to a loved one who is having a hard time."),
            Message(group: familyAndFriends, identifier: "6", string: "Think about making time for a friend or family member."),
            Message(group: familyAndFriends, identifier: "7", string: "Think about being a good friend or family member."),
            Message(group: familyAndFriends, identifier: "8", string: "Think about spending extra time with friends and family."),
            Message(group: familyAndFriends, identifier: "9", string: "Think about being proud of your friends and family."),
            Message(group: familyAndFriends, identifier: "10", string: "Think about being able to rely on your friends and family."),
            Message(group: familyAndFriends, identifier: "11", string: "Think about telling a friend or family member that you love them."),
            Message(group: familyAndFriends, identifier: "12", string: "Think about feeling you belong to a family or friendship."),
            Message(group: familyAndFriends, identifier: "13", string: "Think about reuniting with friends or family after a long absence ."),
            Message(group: familyAndFriends, identifier: "14", string: "Think about maintaining traditions with your friends or family."),
            Message(group: familyAndFriends, identifier: "15", string: "Think about your friends or family showing you love."),
            Message(group: familyAndFriends, identifier: "16", string: "Think about having connection with your friends and family."),
            Message(group: familyAndFriends, identifier: "17", string: "Think about sharing life experiences with your friends and family."),
            Message(group: familyAndFriends, identifier: "18", string: "Think about feeling that you belong to a family or friendship."),
            Message(group: familyAndFriends, identifier: "19", string: "Think about helping a friend or family member achieve an accomplishment."),
            Message(group: familyAndFriends, identifier: "20", string: "Think about having a friend or family member help you achieve an accomplishment."),

            Message(group: compassionAndKindness, identifier: "1", string: "Think about letting people know that you care for them."),
            Message(group: compassionAndKindness, identifier: "2", string: "Think about comforting and cheer up someone who is feeling sad."),
            Message(group: compassionAndKindness, identifier: "3", string: "Think about saying something kind to show your love."),
            Message(group: compassionAndKindness, identifier: "4", string: "Think about letting someone who is suffering know that you are there for them to lean on."),
            Message(group: compassionAndKindness, identifier: "5", string: "Think about helping someone in trouble without expecting anything in return."),
            Message(group: compassionAndKindness, identifier: "6", string: "Think about allowing others to be themselves in your presence."),
            Message(group: compassionAndKindness, identifier: "7", string: "Think about accepting and be understanding of others' weaknesses."),
            Message(group: compassionAndKindness, identifier: "8", string: "Think about smiling at someone you pass by."),
            Message(group: compassionAndKindness, identifier: "9", string: "Think about letting someone going through difficult times know that you are proud of them."),
            Message(group: compassionAndKindness, identifier: "10", string: "Think about encouraging someone who is in trouble."),
            Message(group: compassionAndKindness, identifier: "11", string: "Think about being gentle and compassionate with someone in emotional pain."),
            Message(group: compassionAndKindness, identifier: "12", string: "Think about forgiving someone for their mistakes."),
            Message(group: compassionAndKindness, identifier: "13", string: "Think about making someone feel better."),
            Message(group: compassionAndKindness, identifier: "14", string: "Think about showing compassion to someone else."),
            Message(group: compassionAndKindness, identifier: "15", string: "Think about genuinely caring about someone."),
            Message(group: compassionAndKindness, identifier: "16", string: "Think about letting go of a grudge and forgive."),
            Message(group: compassionAndKindness, identifier: "17", string: "Think about feeling sorry and care for others in tough situations."),
            Message(group: compassionAndKindness, identifier: "18", string: "Think about showing people how much you love them by expressing kindness."),
            Message(group: compassionAndKindness, identifier: "19", string: "Think about letting someone know how much they mean to you."),
            Message(group: compassionAndKindness, identifier: "20", string: "Think about being tender to someone who is in trouble."),
        ]
    }

    func next() -> Message.Key {
        if state.messageKeySequence.isEmpty {
            state.messageKeySequence = MessageSequencer().getMessageKeySequence(messages: messages, group: state.filterGroup, lastMessage: state.lastMessage)
            if let messageKey = state.messageKeySequence.last {
                state.lastMessage = messageKey.identifier
            }
        }
        return state.messageKeySequence.removeFirst()
    }

}

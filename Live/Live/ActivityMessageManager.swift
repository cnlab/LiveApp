//
//  ActivityMessageManager.swift
//  Live
//
//  Created by Denis Bohm on 9/12/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import Foundation

class ActivityMessageManager: MessageManager {

    class State: JSONConvertable {

        var messageKeySequence: [Message.Key]
        var lastGroup: String?

        init(messageKeySequence: [Message.Key] = [], lastGroup: String? = nil) {
            self.messageKeySequence = messageKeySequence
            self.lastGroup = lastGroup
        }

        required init(json: [String: Any]) throws {
            let messageKeySequence: [Message.Key] = try JSON.jsonArray(json: json, key: "messageKeySequence")
            let lastGroup = try JSON.jsonOptionalString(json: json, key: "lastGroup")

            self.messageKeySequence = messageKeySequence
            self.lastGroup = lastGroup
        }

        func json() -> [String: Any] {
            var object: [String: Any] = [
                "messageKeySequence": JSON.json(array: messageKeySequence),
                ]
            if let lastGroup = lastGroup {
                object["lastGroup"] = JSON.json(string: lastGroup)
            }
            return object
        }
        
    }

    var type: String {
        get {
            return "Activity"
        }
    }
    let messages: [Message]
    var state: State

    init() {
        let how = "how"
        let why = "why"
        let risk = "risk"
        let active = "active"
        let inactive = "inactive"

        messages = [
            // PA1 Active How
            Message(group: how, identifier: "1", alternatives:
                (active, "The best parking spots are the ones farther away. Choose the last row or the top floor so you have farther to walk."),
                (inactive, "The best parking spots are the ones farther away. Choose the last row or the top floor so you have farther to walk.")),
            Message(group: how, identifier: "2", alternatives:
                (active, "Stairs can keep you active. Instead of the elevator, start with going up short distances and always walking down."),
                (inactive, "Stairs can get you active. Instead of the elevator, start with going up short distances and always walking down.")),
            Message(group: how, identifier: "3", alternatives:
                (active, "Squeeze in even more walking or biking. Think about places you go and see if any are close enough to walk or bike to."),
                (inactive, "Squeeze in more walking or biking. Think about places you go and see if any are close enough to walk or bike to.")),
            Message(group: how, identifier: "4", alternatives:
                (active, "Dancing is a great activity. Pick your favorite song and start dancing. No need to look good, moving your body is all that counts."),
                (inactive, "Dancing is a great activity. Pick your favorite song and start dancing. No need to look good, moving your body is all that counts.")),
            Message(group: how, identifier: "5", alternatives:
                (active, "Some types of entertainment are more active than others. Bowling, skating, or swimming are some good things to mix in."),
                (inactive, "Some types of entertainment are more active than others. Bowling, skating, or swimming are some good things to mix in.")),
            Message(group: how, identifier: "6", alternatives:
                (active, "You can stay active during weekends. Visit places where you walk a lot, like the store, mall, park, or museum."),
                (inactive, "You can be more active during weekends. Visit places where you walk a lot, like the store, mall, park, or museum.")),
            Message(group: how, identifier: "7", alternatives:
                (active, "Doing housework can keep you moving. Put on some music when you tidy, do dishes or dust, and dance around while working."),
                (inactive, "Doing housework can get you moving. Put on some music when you tidy, do dishes or dust, and dance around while working.")),

            // PA1 Sedentary How
            Message(group: how, identifier: "8", alternatives:
                (active, "After you sit for an hour, go for a 5-minute walk. Walk around the block, go up and down the stairs, or walk the halls."),
                (inactive, "After you sit for an hour, go for a 5-minute walk. Walk around the block, go up and down the stairs, or walk the halls.")),
            Message(group: how, identifier: "9", alternatives:
                (active, "After an hour of sitting, stand up. Stand while you read, watch TV, talk on the phone, fold laundry, or write an email."),
                (inactive, "After an hour of sitting, stand up. Stand while you read, watch TV, talk on the phone, fold laundry, or write an email.")),
            Message(group: how, identifier: "10", alternatives:
                (active, "When you go to the bathroom, take the long way. Walk to a bathroom that's farther away, maybe on a different floor."),
                (inactive, "When you go to the bathroom, take the long way. Walk to a bathroom that's farther away, maybe on a different floor.")),
            Message(group: how, identifier: "11", alternatives:
                (active, "After you've been still for a while, stand up. Stretch everything you can think of, arms, legs, neck, shoulders, ankles."),
                (inactive, "After you've been still for a while, stand up. Stretch everything you can think of, arms, legs, neck, shoulders, ankles.")),
            Message(group: how, identifier: "12", alternatives:
                (active, "Think of activities you can do while on the phone. While chatting, walk around, twist, stretch, or do deep knee bends."),
                (inactive, "Think of activities you can do while on the phone. While chatting, walk around, twist, stretch, or do deep knee bends.")),
            Message(group: how, identifier: "13", alternatives:
                (active, "Move more while you watch TV or watch less. Exchange TV watching for something more active - like going for a walk."),
                (inactive, "Move more while you watch TV or watch less. Exchange TV watching for something more active - like going for a walk.")),
            Message(group: how, identifier: "14", alternatives:
                (active, "Make your family time more active. Instead of sitting while you catch up with family, go for a walk while you chat."),
                (inactive, "Make your family time more active. Instead of sitting while you catch up with family, go for a walk while you chat.")),
            Message(group: how, identifier: "15", alternatives:
                (active, "Yard work can keep you moving. Instead of using a leaf blower, rake your leaves to move around more."),
                (inactive, "Yard work can get you moving. Instead of using a leaf blower, rake your leaves to move around more.")),

            // PA2 How
            Message(group: how, identifier: "16", alternatives:
                (active, "Think of nearby places you go to often. Try walking to these places instead of driving."),
                (inactive, "Think of nearby places you go to often. Try walking to these places instead of driving.")),
            Message(group: how, identifier: "17", alternatives:
                (active, "Find a time every day when you can get out and walk around for at least 15 minutes. Maybe to and from your job."),
                (inactive, "Find a time every day when you can get out and walk around for at least 15 minutes. Maybe to and from your job.")),
            Message(group: how, identifier: "18", alternatives:
                (active, "Make a habit of walking up and down the stairs whenever you can. Avoid taking the elevator as often as possible."),
                (inactive, "Make a habit of walking up and down the stairs whenever you can. Avoid taking the elevator as often as possible.")),
            Message(group: how, identifier: "19", alternatives:
                (active, "Visit places where you can walk around. Go to places like the mall, a park, or museum to do lots of walking."),
                (inactive, "Visit places where you can walk around. Go to places like the mall, a park, or museum to do lots of walking.")),
            Message(group: how, identifier: "20", alternatives:
                (active, "Put on some music while you do housework and move to the beat. Dance around while you tidy, do dishes, or dust."),
                (inactive, "Put on some music while you do housework and move to the beat. Dance around while you tidy, do dishes, or dust.")),
            Message(group: how, identifier: "21", alternatives:
                (active, "Try out fun and active hobbies both indoors and outdoors. Try hobbies like bowling, swimming, or roller-skating."),
                (inactive, "Try out fun and active hobbies both indoors and outdoors. Try hobbies like bowling, swimming, or roller-skating.")),
            Message(group: how, identifier: "22", alternatives:
                (active, "Stand up, stretch, and move around. You can also encourage your family and friends to stretch together with you."),
                (inactive, "Stand up, stretch, and move around. You can also encourage your family and friends to stretch together with you.")),
            Message(group: how, identifier: "23", alternatives:
                (active, "Find a time to go for a 15-20 minute walk 3-4 times a week. Try casual walks to and from nearby places."),
                (inactive, "Find a time to go for a 15-20 minute walk 3-4 times a week. Try casual walks to and from nearby places.")),
            Message(group: how, identifier: "24", alternatives:
                (active, "Start muscle-strengthening activity at least 2 days a week. You can do it around the house such as lifting or carrying."),
                (inactive, "Start muscle-strengthening activity at least 2 days a week. You can do it around the house such as lifting or carrying.")),
            Message(group: how, identifier: "25", alternatives:
                (active, "While you watch TV, stand up and move around if a show ends. When a show ends, use that as a reminder to stretch."),
                (inactive, "While you watch TV, stand up and move around if a show ends. When a show ends, use that as a reminder to stretch.")),

            // PA1 Active Why
            Message(group: why, identifier: "1", alternatives:
                (active, "Staying active can help with back pain. You will have better posture, the best way to manage and prevent back pain."),
                (inactive, "Becoming active can help with back pain. You will have better posture, the best way to manage and prevent back pain.")),
            Message(group: why, identifier: "2", alternatives:
                (active, "Staying active helps with new things. Your brain takes ~3 weeks to learn new skills, but after that it's a lot easier."),
                (inactive, "Getting more active helps with new things. Your brain takes ~3 weeks to learn new skills, but after that it's a lot easier.")),
            Message(group: why, identifier: "3", alternatives:
                (active, "Staying active can help your brain make chemicals that make you feel happier and more relaxed, even after working out."),
                (inactive, "Getting active can help your brain make chemicals that make you feel happier and more relaxed, even after working out.")),
            Message(group: why, identifier: "4", alternatives:
                (active, "You can feel proud when you reach your goals. Staying active feels good and makes you feel better about yourself."),
                (inactive, "You can feel proud when you reach your goals. Becoming more active feels good and makes you feel better about yourself.")),
            Message(group: why, identifier: "5", alternatives:
                (active, "Staying active can help you sleep better. It will help you fall and stay asleep, and feel more rested."),
                (inactive, "Getting more active can help you sleep better. It will help you fall and stay asleep, and feel more rested.")),
            Message(group: why, identifier: "6", alternatives:
                (active, "Staying active can help sex lives. Active people can get and stay aroused more easily for longer periods of time."),
                (inactive, "Getting active can help sex lives. Active people can get and stay aroused more easily for longer periods of time.")),
            Message(group: why, identifier: "7", alternatives:
                (active, "Staying active can connect you with others in fun social settings, like in classes, teams, or just playing with friends."),
                (inactive, "Getting active can connect you with others in fun social settings, like in classes, teams, or just playing with friends.")),
            Message(group: why, identifier: "8", alternatives:
                (active, "Staying active builds muscle. Becoming even stronger helps with everyday things and helps you feel more powerful in life."),
                (inactive, "Getting more active builds muscle. Becoming stronger helps with everyday things and helps you feel more powerful in life.")),
            Message(group: why, identifier: "9", alternatives:
                (active, "Physical activity helps you age better. Staying active will help you continue doing things you like."),
                (inactive, "Physical activity helps you age better. Becoming active will help you continue doing things you like.")),
            Message(group: why, identifier: "10", alternatives:
                (active, "Exercise helps with stress. Staying active can give a mental break from troubles, step back and make time for yourself."),
                (inactive, "Exercise helps with stress. Getting active can give a mental break from troubles, step back and make time for yourself.")),

            // PA1 Sedentary Why
            Message(group: why, identifier: "11", alternatives:
                (active, "Imagine what you'd fill your time with if you watched less TV. Imagine how good it would feel to get more done in your free time."),
                (inactive, "Imagine what you'd fill your time with if you watched less TV. Imagine how good it would feel to get more done in your free time.")),
            Message(group: why, identifier: "12", alternatives:
                (active, "The more you sit, the more damage it does. Your body won't handle sugar and fat, increasing risk for disease."),
                (inactive, "The more you continue to sit, the more damage it does. Your body won't handle sugar and fat, increasing risk for disease.")),
            Message(group: why, identifier: "13", alternatives:
                (active, "Sitting makes you sore and tired. Notice how you feel after sitting for an hour. Stand up and notice if you feel better."),
                (inactive, "Sitting makes you sore and tired. Notice how you feel after sitting for an hour. Stand up and notice if you feel better.")),
            Message(group: why, identifier: "14", alternatives:
                (active, "Sitting makes you sore and tired. Notice how you feel after sitting for an hour. Stand up and notice if you feel better."),
                (inactive, "You may inspire others by sitting less. Turn off TV or stand during work. People may eventually thank you.")),
            Message(group: why, identifier: "15", alternatives:
                (active, "Sitting less and achieving a healthy body means less worry and hospital visits, and more time and energy to enjoy life."),
                (inactive, "Sitting less and achieving a healthy body means less worry and hospital visits, and more time and energy to enjoy life.")),
            Message(group: why, identifier: "16", alternatives:
                (active, "A lack of activity means a shorter life. Continue to sit less to enjoy the things that mean the most to you for longer."),
                (inactive, "A lack of activity means a shorter life. Start to sit less to enjoy the things that mean the most to you for longer.")),
            Message(group: why, identifier: "17", alternatives:
                (active, "People who sit less have lower risk for certain diseases like diabetes and heart disease than those who sit more."),
                (inactive, "People who sit less have lower risk for certain diseases like diabetes and heart disease than those who sit more.")),
            Message(group: why, identifier: "18", alternatives:
                (active, "Sitting less helps control weight. No need to become an athlete or join a gym, just sitting less can make a difference."),
                (inactive, "Sitting less helps control weight. No need to become an athlete or join a gym, just sitting less can make a difference.")),
            Message(group: why, identifier: "19", alternatives:
                (active, "Sitting less can energize you. It delivers oxygen to your heart, lungs, and veins, making you feel better."),
                (inactive, "Sitting less can energize you. It delivers oxygen to your heart, lungs, and veins, making you feel better.")),
            Message(group: why, identifier: "20", alternatives:
                (active, "Sitting less means fewer pills. Your body will make good cholesterol, lowering blood pressure and blood sugar."),
                (inactive, "Sitting less means fewer pills. Your body will make good cholesterol, lowering blood pressure and blood sugar.")),

            // PA2 Why
            Message(group: why, identifier: "21", alternatives:
                (active, "You can live longer doing things you love if you continue to sit less. You can spend more time with the people you love."),
                (inactive, "You can live longer doing things you love if you start to sit less. You can spend more time with the people you love.")),
            Message(group: why, identifier: "22", alternatives:
                (active, "If you move around even more, your body can use blood sugar. This can keep your arteries healthy."),
                (inactive, "As you start to move around more, your body can use blood sugar. This can keep your arteries healthy.")),
            Message(group: why, identifier: "23", alternatives:
                (active, "As you remain active, your bones will grow stronger. Stronger bones will help you stay pain free."),
                (inactive, "As you become more active, your bones will grow stronger. Stronger bones will help you stay pain free.")),
            Message(group: why, identifier: "24", alternatives:
                (active, "You can lower the risk of cancer if you keep exercising regularly. This means you can live longer and healthier."),
                (inactive, "You can lower the risk of cancer if you exercise regularly. This means you can live longer and healthier.")),
            Message(group: why, identifier: "25", alternatives:
                (active, "Staying active means less risk for diabetes. This means you can enjoy a longer and healthier life with more freedom."),
                (inactive, "Staying active means less risk for diabetes. This means you can enjoy a longer and healthier life with more freedom.")),
            Message(group: why, identifier: "26", alternatives:
                (active, "Active people tend to live longer than less active people. You can live longer and healthier by staying active."),
                (inactive, "Active people tend to live longer than less active people. You can live longer and healthier by becoming more active.")),
            Message(group: why, identifier: "27", alternatives:
                (active, "You can help prevent age-related memory loss with more exercise. Your mind will be more clear as you become older."),
                (inactive, "You can help prevent age-related memory loss with more exercise. Your mind will be more clear as you become older.")),
            Message(group: why, identifier: "28", alternatives:
                (active, "Staying active will strengthen your muscles. Stronger muscles can help you do the things you enjoy for longer."),
                (inactive, "Getting more active will strengthen your muscles. Stronger muscles can help you do the things you enjoy for longer.")),
            Message(group: why, identifier: "29", alternatives:
                (active, "Spending less time with the TV or computer can strengthen your heart. This means you will live longer and healthier."),
                (inactive, "Spending less time with the TV or computer can strengthen your heart. This means you will live longer and healthier.")),

            // RISK MESSAGES
            Message(group: risk, identifier: "1", alternatives:
                (active, "Doctors have called physical inactivity \"the biggest public health problem of the 21st century.\""),
                (inactive, "Doctors have called physical inactivity \"the biggest public health problem of the 21st century.\"")),
            Message(group: risk, identifier: "2", alternatives:
                (active, "According to the American Heart Association, inactive people are at much higher risk for developing heart disease."),
                (inactive, "According to the American Heart Association, inactive people are at much higher risk for developing heart disease.")),
            Message(group: risk, identifier: "3", alternatives:
                (active, "A sedentary lifestyle increases the risk of diabetes, hypertension, colon cancer, depression, anxiety, and obesity."),
                (inactive, "A sedentary lifestyle increases the risk of diabetes, hypertension, colon cancer, depression, anxiety, and obesity.")),
            Message(group: risk, identifier: "4", alternatives:
                (active, "Being inactive puts you at risk for health problems related to lack of exercise."),
                (inactive, "Remaining inactive puts you at risk for health problems related to lack of exercise.")),
            Message(group: risk, identifier: "5", alternatives:
                (active, "On average, physically active people outlive those who are inactive."),
                (inactive, "On average, physically active people outlive those who are inactive.")),
            Message(group: risk, identifier: "6", alternatives:
                (active, "Physical inactivity affects at least 20 of the deadliest chronic disorders."),
                (inactive, "Physical inactivity affects at least 20 of the deadliest chronic disorders.")),
            Message(group: risk, identifier: "7", alternatives:
                (active, "Sitting for extended periods of time without breaks to move around does significant damage to your health."),
                (inactive, "Sitting for extended periods of time without breaks to move around does significant damage to your health.")),
            Message(group: risk, identifier: "8", alternatives:
                (active, "Each hour spent sitting watching TV is linked to an 18% increase in the risk of dying from cardiovascular disease."),
                (inactive, "Each hour spent sitting watching TV is linked to an 18% increase in the risk of dying from cardiovascular disease.")),
            Message(group: risk, identifier: "9", alternatives:
                (active, "Sitting for long each day is bad for you, like smoking is bad for you, regardless of whether you do healthy activities."),
                (inactive, "Sitting for long each day is bad for you, like smoking is bad for you, regardless of whether you do healthy activities.")),
            Message(group: risk, identifier: "10", alternatives:
                (active, "The less you move, the less blood sugar your body uses, which causes health problems."),
                (inactive, "The less you move, the less blood sugar your body uses, which causes health problems.")),
            Message(group: risk, identifier: "11", alternatives:
                (active, "Doing more regular physical activity can help people feel less depressed."),
                (inactive, "Doing more regular physical activity can help people feel less depressed.")),
            Message(group: risk, identifier: "12", alternatives:
                (active, "Bones, like muscles, require regular exercise to maintain their mineral content and strength."),
                (inactive, "Bones, like muscles, require regular exercise to maintain their mineral content and strength.")),
            Message(group: risk, identifier: "13", alternatives:
                (active, "Bone loss progresses much faster in people who remain physically inactive."),
                (inactive, "Bone loss progresses much faster in people who remain physically inactive.")),
            Message(group: risk, identifier: "14", alternatives:
                (active, "Sedentary lifestyles are one of the ten leading causes of death and disability in the world."),
                (inactive, "Sedentary lifestyles are one of the ten leading causes of death and disability in the world.")),
            Message(group: risk, identifier: "15", alternatives:
                (active, "Active people often have lower blood sugar. High blood sugar levels can hurt your arteries."),
                (inactive, "Inactive people often have high blood sugar. High blood sugar levels can hurt your arteries.")),
            Message(group: risk, identifier: "16", alternatives:
                (active, "The American Heart Association recommends aerobic exercise. This can lower your risk of getting heart disease."),
                (inactive, "The American Heart Association recommends aerobic exercise. This can lower your risk of getting heart disease.")),
            Message(group: risk, identifier: "17", alternatives:
                (active, "If you become sedentary, you could shorten your life. Inactive people tend to die before more active people."),
                (inactive, "If you are sedentary, you could shorten your life. Inactive people tend to die before more active people.")),
            Message(group: risk, identifier: "18", alternatives:
                (active, "Inactive lifestyle can worsen your memory. Being sedentary can shrink the brain's memory areas with age."),
                (inactive, "Inactive lifestyle can worsen your memory. Remaining sedentary can shrink the brain's memory areas with age.")),
            Message(group: risk, identifier: "19", alternatives:
                (active, "Sitting most of the time weakens your muscles, making it difficult to get around and do the things you enjoy."),
                (inactive, "Sitting most of the time weakens your muscles, making it difficult to get around and do the things you enjoy.")),
        ]

        state = State()
    }
    
    func next() -> Message.Key {
        if state.messageKeySequence.isEmpty {
            state.messageKeySequence = MessageSequencer().getMessageKeySequence(messages: messages, initialGroup: state.lastGroup)
            if let messageKey = state.messageKeySequence.last {
                state.lastGroup = messageKey.group
            }
        }
        return state.messageKeySequence.removeFirst()
    }

}

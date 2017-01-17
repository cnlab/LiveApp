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
        let inactive = "inactive"

        messages = [
            // PA1 Active How
            Message(group: how, identifier: "1", string: "The best parking spots are the ones that are farther away. Choose the last row of a parking lot or the top floor so you have farther to walk."),
            Message(group: how, identifier: "2", string: "Stairs are a great way to /stay/ active. Take the stairs instead of the elevator - start with going up short distances and always walking down.", variants: [inactive: ["stay": "get more"]]),
            Message(group: how, identifier: "3", string: "Think of ways to squeeze in /even/ more walking or biking. Think about the places you go each week and see if any are close enough to walk or bike to.", variants: [inactive: ["even": "a little"]]),
            Message(group: how, identifier: "4", string: "Dancing is a great activity, even if you don't know how. Pick your favorite music, and just start dancing - it doesn't have to look good, moving your body at all counts."),
            Message(group: how, identifier: "5", string: "Some types of entertainment are more active than others. Bowling, roller skating, swimming, and ice skating are some good things to mix in from time to time."),
            Message(group: how, identifier: "6", string: "You might be able to /stay active during/ weekends. Visit places where you walk a lot - like the store, the mall, a park, or museum.", variants: [inactive: ["stay active during": "include more activity into your"]]),
            Message(group: how, identifier: "7", string: "Doing work around your house can /keep/ you moving. Put on some music while you tidy, do dishes, or dust, and dance around while you're working.", variants: [inactive: ["keep": "get"]]),

            // PA1 Sedentary How
            Message(group: how, identifier: "8", string: "When you've sat for an hour, try going for a 5-minute walk. Take a walk around the block, go upstairs and come back down, or walk the halls."),
            Message(group: how, identifier: "9", string: "After an hour of sitting, try standing for 5 minutes. Stand up while you read, watch TV, talk on the phone, fold laundry, or write an email."),
            Message(group: how, identifier: "10", string: "When you go to the bathroom or get a drink, take the long way. Walk to a bathroom that's farther away - for example, on a different floor."),
            Message(group: how, identifier: "11", string: "After you've been still for a while, try to stand up and stretch. Stretch everything you can think of - arms, legs, neck, shoulders, back, ankles."),
            Message(group: how, identifier: "12", string: "Think of activities you can do while you're on the phone. While you're chatting on the phone, walk around, twist, stretch, or do deep knee bends."),
            Message(group: how, identifier: "13", string: "Move more while you watch TV or watch less. Exchange a portion of your TV watching for something more active - like going for a walk."),
            Message(group: how, identifier: "14", string: "Make the time you spend with your family more active. Instead of sitting while you catch up with family, go for a walk while you chat."),
            Message(group: how, identifier: "15", string: "Depending on how you do it, yard work can be get you moving. Instead of using a leaf blower, raking your leaves the old fashioned way to move around more."),

            // PA2 How
            Message(group: how, identifier: "16", string: "Think of nearby places you go to often. Try walking to these places instead of driving."),
            Message(group: how, identifier: "17", string: "Find a time every day when you can get out and walk around for at least 15 minutes. For example, maybe you can walk to and from your job every day."),
            Message(group: how, identifier: "18", string: "Make a habit of walking up and down the stairs whenever you can. Avoid taking the elevator as often as possible."),
            Message(group: how, identifier: "19", string: "Visit places where you can walk around as often as possible. Go to places like the mall, a park, or museum to do lots of walking."),
            Message(group: how, identifier: "20", string: "Put on some music while you do housework and move to the beat. Dance around to music while you tidy, do dishes, or dust."),
            Message(group: how, identifier: "21", string: "Try out fun and active hobbies both indoors and outdoors. Try hobbies like bowling, swimming, or roller-skating."),
            Message(group: how, identifier: "22", string: "Try to stand up, stretch, and move around as often as you can. You can also encourage your family and friends to stretch together with you."),
            Message(group: how, identifier: "23", string: "Find a time to go for a 15-20 minute walk 3-4 times a week. Try casual walks to and from nearby places."),
            Message(group: how, identifier: "24", string: "Try to /do/ muscle-strengthening activity at least 2 days a week. You can do muscle-strengthening activities around the house such as lifting or carrying.", variants: [inactive: ["do": "start"]]),
            Message(group: how, identifier: "25", string: "While you are watching TV, stand up and move around if a show or movie ends. When a show or video clip you were watching on your computer ends, use that as a reminder to stretch."),

            // PA1 Active Why
            Message(group: why, identifier: "1", string: "/Staying/ active can help with back pain. When people are stronger and more active, they have better posture, which is the best way to manage and prevent back pain.", variants: [inactive: ["Staying": "Getting more"]]),
            Message(group: why, identifier: "2", string: "/Staying/ active gives you a chance to learn how to do new things. It takes about 3 weeks for your brain to get used to new physical skills - but after that, it's a lot easier.", variants: [inactive: ["Staying": "Getting more"]]),
            Message(group: why, identifier: "3", string: "/Staying/ active can help you feel more alert, positive, and energetic. Physical activity helps your brain make chemicals that make you feel happier and more relaxed, even after you're done working out.", variants: [inactive: ["Staying": "Becoming more"]]),
            Message(group: why, identifier: "4", string: "You can feel proud when you reach your goals. /Staying/ active feels good, gives you more energy, and makes you feel better about yourself.", variants: [inactive: ["Staying": "Becoming more"]]),
            Message(group: why, identifier: "5", string: "Getting more activity can help you sleep better at night. People who are active have an easier time falling asleep and staying asleep - they feel more rested in the morning."),
            Message(group: why, identifier: "6", string: "/Staying/ physically active can sometimes help people's sex lives. People who are active can get aroused more easily and may be able to stay aroused for longer periods of time.", variants: [inactive: ["Staying": "Becoming more"]]),
            Message(group: why, identifier: "7", string: "If you find something you like, exercise can be fun. /Staying/ active can help you connect with other people in fun, social settings - like taking classes, being on a team, or just playing with friends.", variants: [inactive: ["Staying": "Getting"]]),
            Message(group: why, identifier: "8", string: "/Staying/ active helps build muscle. Becoming even stronger makes it easier to do everyday things and might help you feel more powerful in life.", variants: [inactive: ["Staying": "Getting"]]),
            Message(group: why, identifier: "9", string: "Physical activity helps you live better as you grow older. /Staying/ active will help you reach, bend, lift, carry, and move around more easily, so you can continue doing the things you like to do.", variants: [inactive: ["Staying": "Becoming"]]),
            Message(group: why, identifier: "10", string: "Exercise can help you deal with stress. /Staying/ active can give you a mental break from what's troubling you - it helps you take a step back and make time for yourself.", variants: [inactive: ["Staying": "Getting"]]),

            // PA1 Sedentary Why
            Message(group: why, identifier: "11", string: "Imagine what you'd fill your time with if you watched less TV. People get more checked off their to-do lists when they don't watch TV - imagine how good that would feel."),
            Message(group: why, identifier: "12", string: "The more you /sit/, the more damage it does to your body. When you sit for long periods of time, your body can't handle sugar and fat - this can mean higher risk for disease.", variants: [inactive: ["sit": "continue to sit"]]),
            Message(group: why, identifier: "13", string: "Sitting for a long time can make you sore and tired. After you've sat for an hour, notice how your body feels - then, stand up and notice any changes you feel."),
            Message(group: why, identifier: "14", string: "You might inspire others by /continuing to move more and sit less/. It might be hard /sometimes/ - to turn off the TV or to stand during meetings - but after a while, other people will probably thank you.", variants: [inactive: ["continuing to move more and sit less": "getting more active and sitting less", "sometimes": "at first"]]),
            Message(group: why, identifier: "15", string: "The more you get off your seat, the better your chances of having a healthier body for longer. /Maintaining/ a healthy body means less worry, pills, and doctor's appointments. It also means more time and energy to enjoy life.", variants: [inactive: ["Maintaining": "Achieving"]]),
            Message(group: why, identifier: "16", string: "A lack of activity can be linked to a shorter life. By /continuing/ to sit less and move more, you can help make sure you live longer - to enjoy the things that mean the most to you in life.", variants: [inactive: ["continuing": "starting"]]),
            Message(group: why, identifier: "17", string: "People who sit less are at lower risk for certain diseases. People who sit less are less likely to have diabetes, and heart disease than people who are more active."),
            Message(group: why, identifier: "18", string: "People who sit less have an easier time controlling their weight. You don't need to turn into an athlete or join a gym - even sitting less throughout the day can make a difference."),
            Message(group: why, identifier: "19", string: "/Continue/ to sit less can mean you have more energy to get you through the day. Getting off your seat helps get oxygen to your heart, lungs, and veins - your body feels better when it works better.", variants: [inactive: ["Continue": "Starting"]]),
            Message(group: why, identifier: "20", string: "Sitting less over time might mean fewer pills. When you /continue/ to sit less your body is better at making good cholesterol, and lowering bad cholesterol, blood pressure, and blood sugar.", variants: [inactive: ["continue": "start"]]),

            // PA2 Why
            Message(group: why, identifier: "21", string: "You can live longer to enjoy the things you love if you /continue/ to sit less and move more. You will spend a longer time with the people you love.", variants: [inactive: ["continue": "start"]]),
            Message(group: why, identifier: "22", string: "As you /move/ around even more, your body can use blood sugar. This can keep your arteries healthy.", variants: [inactive: ["move": "start to move"]]),
            Message(group: why, identifier: "23", string: "As you /remain/ active, your bones will grow stronger. Stronger bones will help you stay pain free.", variants: [inactive: ["remain": "become more"]]),
            Message(group: why, identifier: "24", string: "You can lower your risk of getting cancer even more if you /continue to exercise/ regularly. This means you can live longer and healthier.", variants: [inactive: ["continue to exercise": "exercise"]]),
            Message(group: why, identifier: "25", string: "If you /stay/ active, you will be less likely to get diabetes. This means you can enjoy a longer and healthier life with more freedom.", variants: [inactive: ["stay": "become more"]]),
            Message(group: why, identifier: "26", string: "Active people tend to live longer than people who are less physically active. You can live longer and healthier by /staying/ active.", variants: [inactive: ["staying": "becoming"]]),
            Message(group: why, identifier: "27", string: "You can help prevent age-related memory loss with more exercise. This means your mind will be more clear and alert as you become older."),
            Message(group: why, identifier: "28", string: "/Staying/ active will strengthen your muscles. Stronger muscles will make it easier for you to get around and do the things you enjoy for longer.", variants: [inactive: ["Staying": "Getting more"]]),
            Message(group: why, identifier: "29", string: "Spending less time in front of the TV or computer can strengthen your heart. This means you will live longer and healthier."),

            // RISK MESSAGES
            Message(group: risk, identifier: "1", string: "Doctors have called physical inactivity \"the biggest public health problem of the 21st century.\""),
            Message(group: risk, identifier: "2", string: "According to the American Heart Association, people who are physically inactive are at much higher risk for developing heart disease."),
            Message(group: risk, identifier: "3", string: "A sedentary lifestyle increases the risk of developing diabetes, hypertension, colon cancer, depression and anxiety, obesity, and weak muscles and bones."),
            Message(group: risk, identifier: "4", string: "Remaining inactive puts you at risk for health problems related to lack of exercise."),
            Message(group: risk, identifier: "5", string: "On average, physically active people outlive those who are inactive."),
            Message(group: risk, identifier: "6", string: "Physical inactivity affects at least 20 of the deadliest chronic disorders."),
            Message(group: risk, identifier: "7", string: "Sitting for extended periods of time without breaks to move around does significant damage to your health."),
            Message(group: risk, identifier: "8", string: "Each hour spent sitting watching TV is linked to an 18% increase in the risk of dying from cardiovascular disease."),
            Message(group: risk, identifier: "9", string: "/Sitting/ for several hours each day is bad for you, like smoking is bad for you, regardless of whether you do healthful activities, too.", variants: [inactive: ["Sitting": "Continuing to sit"]]),
            Message(group: risk, identifier: "10", string: "The less you move, the less blood sugar your body uses, which causes health problems."),
            Message(group: risk, identifier: "11", string: "Doing more regular physical activity can help people feel less depressed."),
            Message(group: risk, identifier: "12", string: "Bones, like muscles, require regular exercise to maintain their mineral content and strength."),
            Message(group: risk, identifier: "13", string: "Bone loss progresses much faster in people who remain physically inactive."),
            Message(group: risk, identifier: "14", string: "Sedentary lifestyles are one of the ten leading causes of death and disability in the world."),
            Message(group: risk, identifier: "15", string: "/Active people often have lower/ blood sugar. High blood sugar levels can hurt your arteries/, so stay active!/", variants: [inactive: ["Active people often have lower": "Inactive people often have high", ", so stay active!": "."]]),
            Message(group: risk, identifier: "16", string: "The American Heart Association encourages people to do more aerobic exercise. /Doing/ more aerobic exercise can lower your risk of getting heart disease.", variants: [inactive: ["Doing": "Starting"]]),
            Message(group: risk, identifier: "17", string: "If you /become/ sedentary, you could shorten your life. Inactive people tend to die before more active people.", variants: [inactive: ["become": "are"]]),
            Message(group: risk, identifier: "18", string: "Inactive lifestyle can worsen your memory as you get older. /Becoming/ sedentary can shrink the brain's memory areas with age.", variants: [inactive: ["Becoming": "Remaining"]]),
            Message(group: risk, identifier: "19", string: "If you /start/ to sit most of the time, your muscles will become weak. Weak muscles make it difficult for you to get around and do the things you enjoy.", variants: [inactive: ["start": "continue"]]),
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

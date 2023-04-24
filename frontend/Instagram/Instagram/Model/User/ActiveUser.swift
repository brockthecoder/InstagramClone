//
//  ActiveUser.swift
//  InstagramClone
//
//  Created by brock davis on 1/17/23.
//

import UIKit

struct ActiveUser {
    
    let id: String
    
    let username: String
    
    let isVerified: Bool
    
    let profilePicture: UIImage
    
    let hasPublicStory: Bool
    
    let postCount: Int
    
    let followerCount: Int
    
    let followingCount: Int
    
    let fullName: String
    
    let accountCategory: String
    
    let accountCategoryHidden: Bool
    
    let bio: String?
    
    let link: String?
    
    let channel: String?
    
    let accountsReachedThisMonth: Int
    
    let contactInfoHidden: Bool
    
    let storyHighlights: [StoryHighlightReel]
    
    let posts: [ProfilePagePost]
    
    let subscriberPosts: [ProfilePagePost]
    
    let reels: [ProfilePageReel]
    
    let taggedIn: [ProfilePagePost]
    
    var activityNotifications: ActivityNotifications
    
    var messengerNotifications: MessengerNotifications
    
    let chats: [Chat] = []
    
    let feed: Feed
    
    static let loggedIn = [zuck]
    
    static var otherAccountNotificationsCount: Int {
        var total = 0
        for user in loggedIn {
            total += user.activityNotifications.totalUnseen
        }
        return total
    }
    
    static let zuck = ActiveUser(id: "314216", username: "zuck", isVerified: true, profilePicture: UIImage(named: "Users/Zuck/pfp")!, hasPublicStory: false, postCount: 266, followerCount: 10910258, followingCount: 504, fullName: "Mark Zuckerberg", accountCategory: "Entrepreneur", accountCategoryHidden: true, bio: nil, link: nil, channel: "Meta Channel 📢", accountsReachedThisMonth: Int(10910258 * 1.7), contactInfoHidden: true, storyHighlights: [], posts: [
        ProfilePagePost(id: "1", thumbnail: UIImage(named: "Users/Zuck/Posts/0")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "2", thumbnail: UIImage(named: "Users/Zuck/Posts/1")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "3", thumbnail: UIImage(named: "Users/Zuck/Posts/2")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "4", thumbnail: UIImage(named: "Users/Zuck/Posts/3")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "5", thumbnail: UIImage(named: "Users/Zuck/Posts/4")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "6", thumbnail: UIImage(named: "Users/Zuck/Posts/5")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "7", thumbnail: UIImage(named: "Users/Zuck/Posts/6")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "8", thumbnail: UIImage(named: "Users/Zuck/Posts/7")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "9", thumbnail: UIImage(named: "Users/Zuck/Posts/8")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "10", thumbnail: UIImage(named: "Users/Zuck/Posts/9")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "11", thumbnail: UIImage(named: "Users/Zuck/Posts/10")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "12", thumbnail: UIImage(named: "Users/Zuck/Posts/11")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "13", thumbnail: UIImage(named: "Users/Zuck/Posts/12")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "14", thumbnail: UIImage(named: "Users/Zuck/Posts/13")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "15", thumbnail: UIImage(named: "Users/Zuck/Posts/14")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "16", thumbnail: UIImage(named: "Users/Zuck/Posts/15")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "17", thumbnail: UIImage(named: "Users/Zuck/Posts/16")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "18", thumbnail: UIImage(named: "Users/Zuck/Posts/17")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "19", thumbnail: UIImage(named: "Users/Zuck/Posts/18")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "20", thumbnail: UIImage(named: "Users/Zuck/Posts/19")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "21", thumbnail: UIImage(named: "Users/Zuck/Posts/20")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
    ], subscriberPosts: [], reels: [
        ProfilePageReel(id: "22", coverImage: UIImage(named: "Users/Zuck/Reels/0")!, playCount: 3621111, isPinned: false, takenAt: Date(timeIntervalSince1970: 1677773007)),
        ProfilePageReel(id: "23", coverImage: UIImage(named: "Users/Zuck/Reels/1")!, playCount: 2667680, isPinned: false, takenAt: Date(timeIntervalSince1970: 1676657716)),
        ProfilePageReel(id: "24", coverImage: UIImage(named: "Users/Zuck/Reels/2")!, playCount: 5168710, isPinned: false, takenAt: Date(timeIntervalSince1970: 1676596652)),
        ProfilePageReel(id: "25", coverImage: UIImage(named: "Users/Zuck/Reels/3")!, playCount: 5840050, isPinned: false, takenAt: Date(timeIntervalSince1970: 1675961997)),
        ProfilePageReel(id: "26", coverImage: UIImage(named: "Users/Zuck/Reels/4")!, playCount: 2945936, isPinned: false, takenAt: Date(timeIntervalSince1970: 1669993263)),
        ProfilePageReel(id: "27", coverImage: UIImage(named: "Users/Zuck/Reels/5")!, playCount: 1583315, isPinned: false, takenAt: Date(timeIntervalSince1970: 1667566721)),
        ProfilePageReel(id: "28", coverImage: UIImage(named: "Users/Zuck/Reels/6")!, playCount: 4380414, isPinned: false, takenAt: Date(timeIntervalSince1970: 1667458671)),
        ProfilePageReel(id: "29", coverImage: UIImage(named: "Users/Zuck/Reels/7")!, playCount: 4230236, isPinned: false, takenAt: Date(timeIntervalSince1970: 1666192134)),
        ProfilePageReel(id: "30", coverImage: UIImage(named: "Users/Zuck/Reels/8")!, playCount: 2592160, isPinned: false, takenAt: Date(timeIntervalSince1970: 1665671504)),
        ProfilePageReel(id: "31", coverImage: UIImage(named: "Users/Zuck/Reels/9")!, playCount: 3120015, isPinned: false, takenAt: Date(timeIntervalSince1970: 1665512778)),
        ProfilePageReel(id: "32", coverImage: UIImage(named: "Users/Zuck/Reels/10")!, playCount: 3629802, isPinned: false, takenAt: Date(timeIntervalSince1970: 1664384263)),
        ProfilePageReel(id: "33", coverImage: UIImage(named: "Users/Zuck/Reels/11")!, playCount: 6348176, isPinned: false, takenAt: Date(timeIntervalSince1970: 1662217732)),
        ProfilePageReel(id: "34", coverImage: UIImage(named: "Users/Zuck/Reels/12")!, playCount: 3123827, isPinned: false, takenAt: Date(timeIntervalSince1970: 1660580859)),
        ProfilePageReel(id: "35", coverImage: UIImage(named: "Users/Zuck/Reels/13")!, playCount: 2790509, isPinned: false, takenAt: Date(timeIntervalSince1970: 1658843569)),
        ProfilePageReel(id: "36", coverImage: UIImage(named: "Users/Zuck/Reels/14")!, playCount: 3919035, isPinned: false, takenAt: Date(timeIntervalSince1970: 1657991753)),
        ProfilePageReel(id: "37", coverImage: UIImage(named: "Users/Zuck/Reels/15")!, playCount: 1243604, isPinned: false, takenAt: Date(timeIntervalSince1970: 1655819891)),
        ProfilePageReel(id: "38", coverImage: UIImage(named: "Users/Zuck/Reels/16")!, playCount: 3310817, isPinned: false, takenAt: Date(timeIntervalSince1970: 1655733242)),
        ProfilePageReel(id: "39", coverImage: UIImage(named: "Users/Zuck/Reels/17")!, playCount: 2984931, isPinned: false, takenAt: Date(timeIntervalSince1970: 1654873758)),
        ProfilePageReel(id: "40", coverImage: UIImage(named: "Users/Zuck/Reels/18")!, playCount: 1372792, isPinned: false, takenAt: Date(timeIntervalSince1970: 1652454176)),
        ProfilePageReel(id: "41", coverImage: UIImage(named: "Users/Zuck/Reels/19")!, playCount: 3490262, isPinned: false, takenAt: Date(timeIntervalSince1970: 1652364875)),
        ProfilePageReel(id: "42", coverImage: UIImage(named: "Users/Zuck/Reels/20")!, playCount: 1947806, isPinned: false, takenAt: Date(timeIntervalSince1970: 1652101548)),
    ], taggedIn: [
        ProfilePagePost(id: "43", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/0")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "44", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/1")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "45", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/2")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "46", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/3")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "47", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/4")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "48", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/5")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "49", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/6")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "50", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/7")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "51", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/8")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "52", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/9")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "53", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/10")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "54", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/11")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "55", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/12")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "56", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/13")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "57", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/14")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
        ProfilePagePost(id: "58", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/15")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "59", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/16")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "60", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/17")!, isCarousel: false, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "61", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/18")!, isCarousel: true, isPinned: false, hasShoppingLinks: false),
        ProfilePagePost(id: "62", thumbnail: UIImage(named: "Users/Zuck/TaggedIn/19")!, isCarousel: false, isPinned: false, hasShoppingLinks: false, isReel: true),
    ], activityNotifications: ActivityNotifications(unseenLikes: 200, unseenFollows: 111, unseenComments: 32), messengerNotifications: MessengerNotifications(unseenRequests: 0, unseenPrimaryMessages: 0, unseenGeneralMessages: 9), feed: Feed(stories: [
        FeedStory(id: "1", profilePictureURL: Bundle.main.url(forResource: "0", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "randizuckerberg"),
        FeedStory(id: "2", profilePictureURL: Bundle.main.url(forResource: "1", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "karliekloss"),
        FeedStory(id: "3", profilePictureURL: Bundle.main.url(forResource: "2", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "gloverteixeira"),
        FeedStory(id: "4", profilePictureURL: Bundle.main.url(forResource: "3", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "davecamarillo"),
        FeedStory(id: "5", profilePictureURL: Bundle.main.url(forResource: "4", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "kookslams"),
        FeedStory(id: "6", profilePictureURL: Bundle.main.url(forResource: "5", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "mpakes"),
        FeedStory(id: "7", profilePictureURL: Bundle.main.url(forResource: "6", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "hrescak"),
        FeedStory(id: "8", profilePictureURL: Bundle.main.url(forResource: "7", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "ludacris"),
        FeedStory(id: "9", profilePictureURL: Bundle.main.url(forResource: "8", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "voyager_foiler"),
        FeedStory(id: "10", profilePictureURL: Bundle.main.url(forResource: "9", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "erusli"),
        FeedStory(id: "11", profilePictureURL: Bundle.main.url(forResource: "10", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "foiltheworld"),
        FeedStory(id: "12", profilePictureURL: Bundle.main.url(forResource: "11", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "danielarsham"),
        FeedStory(id: "13", profilePictureURL: Bundle.main.url(forResource: "12", withExtension: "jpg", subdirectory: "Data/Feed/Stories/")!, username: "oliwiabby")
    ],posts: [
        FeedPost(id: "0", type: .imageCarousel, creator: FeedUser(id: "0", username: "kyliejenner", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/0/")!, hasStory: true, activeUserFollows: true), location: nil, caption: "COPERNI BACKSTAGE @coperni @arnaud_vaillant @sebastienmeyer"
                 , commentCount: 31241, commentDisabled: false, topComments: [
                    FeedPostComment(id: "0", creatorUsername: "oliviapierson", text: "Queen 🔥🔥😍😍"),
                    FeedPostComment(id: "1", creatorUsername: "anxhelina", text: "Divinely Beautiful !!!!!!! 🤩❤️")
                 ], likeCount: 6244804, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1678131452), hasUserTags: [true, false, false, false, true], topLikers: [], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "Data/Feed/Posts/0/media/")!),
        FeedPost(id: "1", type: .imageCarousel, creator: FeedUser(id: "1", username: "ana_d_armas", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/1/")!, hasStory: true, activeUserFollows: true), location: nil, caption: "Oscars 2023, that was fun! Last night was the most special night of my career. I loved every single minute of it. Thank you @theacademy for such a wonderful night. Congratulations to all the nominees and winners. Much love, Ana. 💖", commentCount: 25, commentDisabled: false, topComments: [], likeCount: 1466640, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1678830396), hasUserTags: [true, true, true, true, true, true], topLikers: [], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "Data/Feed/Posts/1/media/")!, audio: nil),
        FeedPost(id: "2", type: .singleImage, creator: FeedUser(id: "2", username: "fuckjerry", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/2/")!, hasStory: false, activeUserFollows: true), location: nil, caption: "Anyone know where this is?"
                 , commentCount: 233, commentDisabled: false, topComments: [], likeCount: 25307, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1679241784), hasUserTags: [false], topLikers: [], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "Data/Feed/Posts/2/media/")!, audio: nil),
        FeedPost(id: "3", type: .reel, creator: FeedUser(id: "3", username: "ufc", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/3/")!, hasStory: false, activeUserFollows: true), location: nil, caption: "Last time inside the Octagon @ChitoVeraUFC made a statement 😳 #UFCSanAntonio", commentCount: 787, commentDisabled: false, topComments: [FeedPostComment(id: "0", creatorUsername: "ufccollectibles", text: "😮‍💨")], likeCount: 193070, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1679333707), hasUserTags: [false], topLikers: [
                   FeedUser(id: "99", username: "whoisjob", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "0", withExtension: "jpg", subdirectory: "Data/Feed/Posts/3/top_likers/")!, hasStory: false, activeUserFollows: true),
                   FeedUser(id: "100", username: "chitoveraufc", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "1", withExtension: "jpg", subdirectory: "Data/Feed/Posts/3/top_likers/")!, hasStory: false, activeUserFollows: true)
        ], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "Data/Feed/Posts/3/media/")!, audio: PostAudio(artistDisplayName: "ufc")),
        FeedPost(id: "4", type: .reel, creator: FeedUser(id: "101", username: "livvydunne", isVerified: true, profilePictureURL: Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/4/")!, hasStory: false, activeUserFollows: false), location: nil, caption: "#gymnastics", commentCount: 287, commentDisabled: false, topComments: [], likeCount: 50754, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1660890302), hasUserTags: [false], topLikers: [], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "Data/Feed/Posts/4/media/")!, audio: PostAudio(artistDisplayName: "Amar Arshi, Badshah...", audioTitle: "Kala Chashma")),
        FeedPost(id: "5", type: .reel, creator: FeedUser(id: "99", username: "philippmitt"
, isVerified: false, profilePictureURL:  Bundle.main.url(forResource: "pfp", withExtension: "jpg", subdirectory: "Data/Feed/Posts/5/")!, hasStory: true, activeUserFollows: true), location: nil, caption: "Oh the winter light. Pretty sure this is my favourite light- mid winter, up north 🇫🇮\n.\n.\n#ourfinland #finland #lapland #earthpix #earthoutdoors #roamtheplanet #stayandwander #neverstopexploring #dreamermagazine #forevermagazine #upnorth #arctic #folkscenery #weroamgermany #bergliebe #wondermore #loadfilm"
, commentCount: 4977, commentDisabled: false, topComments:[], likeCount: 2211701, likeCountHidden: false, timestamp: Date(timeIntervalSince1970: 1676644875), hasUserTags: [true], topLikers: [], mediaURLs: Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: "Data/Feed/Posts/5/media/")!, audio: PostAudio(artistDisplayName: "demon gummies", audioTitle: "cloud diving", explicit: false))
    ]))
}

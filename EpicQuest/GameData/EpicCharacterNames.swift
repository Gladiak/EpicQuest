import Foundation

enum EpicCharacterNames {
    static let all: [String] = [
        "Aldric Stormborn", "Morgath Ironhowl", "Lyra Nightweave", "Tharion Embervein", "Kael Dreadmark",
        "Seraphine Ashglow", "Brannoc Skullforge", "Elyndra Moonshade", "Vorik Blacktide", "Cassian Runecloak",
        "Nymera Starfall", "Drogan Frostbrand", "Valeria Thorncrest", "Korrin Stoneblood", "Zephira Windlash",
        "Malrik Crowbane", "Ilyra Dawnwhisper", "Torvald Grimhelm", "Selene Voidbloom", "Ragnar Oathbreaker",
        "Vespera Mistveil", "Draven Bloodthorn", "Isolde Silverflame", "Bromm Hearthhammer", "Calyra Dusksong",
        "Garruk Ironfang", "Aethra Skyshard", "Fenric Wolfscar", "Orlaith Ravencrest", "Tiber Ashenblade",
        "Mirella Nightbriar", "Dorian Emberforge", "Skarn Doomwhisper", "Althea Frostpetal", "Balthor Thundermaw",
        "Nerissa Shadowlark", "Haldric Stonegaze", "Ysara Starveil", "Korven Blightreaver", "Lucian Hollowbrand",
        "Thalia Brightthorn", "Mordek Ironwound", "Eira Wintersong", "Varkun Bonegrip", "Caelum Dawnstrike",
        "Sylvara Moonflare", "Rurik Deepdelver", "Naelia Whisperwind", "Talon Grimward", "Elowen Cindershard",
        "Kharok Hellbrow", "Aurelia Sunspear", "Durnan Rockfury", "Velora Nightquill", "Grimnar Ashfist",
        "Illythra Spellthorn", "Torin Goldvein", "Morwen Darkriver", "Hadrian Steelbloom", "Sable Stargrim",
        "Odrik Frostmane", "Lunara Veilthorn", "Kazmir Duskreign", "Aelric Brightforge", "Nimue Shadowmere",
        "Brakka Ironroot", "Virel Stormquill", "Corvin Deathglass", "Liora Embermist", "Thrain Oakshield",
        "Ysolda Blackrose", "Darek Soulbrand", "Aradia Moonfrost", "Keldor Doomforge", "Selrik Nightreaver",
        "Meridia Flameveil", "Borin Thunderforge", "Zyrella Voidstar", "Gideon Crowstrike", "Faelith Dewsong",
        "Ravok Skullbrand", "Elira Stormpetal", "Magnar Ironclaw", "Nysa Brightgloom", "Tarvek Bonehelm",
        "Syris Starshard", "Hroth Grimstone", "Velkan Ashenfang", "Arielle Mistbloom", "Droven Blackflame",
        "Kaida Shadowfern", "Orin Talonforge", "Myrra Dawnraven", "Tharos Nightforge", "Eldrin Frostwhisper",
        "Razana Emberthorn", "Karnok Steeljaw", "Ione Silvernight", "Belric Stoneflame", "Veyra Moonthorn"
    ]

    static func randomName() -> String {
        all.randomElement() ?? "Uckvood"
    }
}

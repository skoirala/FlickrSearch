import Foundation

struct User {
    let username: String
    let realname: String
    let identifier: String
    let nsid: String
    let description: String

    let photosCount: UInt32
    let firstdate: String
    let iconfarm: UInt
    let iconserver: String
}

extension User: Decodable {
    enum JsonKeys: String, CodingKey {
        case person, username, realname, id, nsid,
        photos, count, firstdate,
        description, content = "_content",
        iconfarm, iconserver
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JsonKeys.self)
        let valuesContainer = try container.nestedContainer(keyedBy: JsonKeys.self,
                                                            forKey: .person)
        let usernameContainer = try valuesContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                    forKey: .username)
        let realnameContainer = try valuesContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                    forKey: .realname)
        try username = usernameContainer.decode(String.self, forKey: .content)
        try realname = realnameContainer.decode(String.self, forKey: .content)
        try identifier = valuesContainer.decode(String.self, forKey: .id)
        try nsid = valuesContainer.decode(String.self, forKey: .nsid)

        let descriptionContainer = try valuesContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                       forKey: .description)
        try description = descriptionContainer.decode(String.self, forKey: .content)

        let photosContainer = try valuesContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                  forKey: .photos)
        let photosCountContainer = try photosContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                       forKey: .count)
        let firstDateContainer = try photosContainer.nestedContainer(keyedBy: JsonKeys.self,
                                                                     forKey: .firstdate)

        try photosCount = photosCountContainer.decode(UInt32.self,
                                                      forKey: .content)
        try firstdate = firstDateContainer.decode(String.self,
                                                  forKey: .content)

        try iconfarm = valuesContainer.decode(UInt.self,
                                              forKey: .iconfarm)
        try iconserver = valuesContainer.decode(String.self,
                                                forKey: .iconserver)
    }
}

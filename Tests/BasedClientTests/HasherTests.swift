import XCTest
@testable import BasedClient
import NakedJson

final class HasherTest: XCTestCase {

    private var sut: Hasher!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = Hasher.default
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testOrder() {
        let a: Json = .from(string: """
         {
            "a": true,
            "b": true,
            "c": {
                "d": true,
                "e": true
            }
        }
        """)!
        
        let b: Json = .from(string: """
            {
            "c": {
                "e": true,
                "d": true
            },
            "b": true,
            "a": true
         }
         """)!
        
        XCTAssertEqual(sut.hashObjectIgnoreKeyOrder(a), sut.hashObjectIgnoreKeyOrder(b))
    }
    
    func testLarge() {
        let a: Json = .from(string: """
        {"children":[{"type":"waitingScreen","index":0,"id":"wa4ab7e44c","disabled":false,"title":"Wait # 1"},{"type":"welcomeScreen","index":1,"id":"we7e8b4bfc","disabled":false,"title":"The voting will start soon!"},{"type":"videoScreen","index":2,"id":"vi6d2e21ca","title":"Watch the recap first!","disabled":false,"video":"https://based-videos-fra.s3.eu-central-1.amazonaws.com/5f9bdb334d7c7d975473bab4413f1d73/5f9bdb334d7c7d975473bab4413f1d73.m3u8"},{"type":"multipleChoice","index":3,"id":"mu241ab268","disabled":false,"title":"Pick 3 of your favorite songs and submit your vote."},{"type":"thankYouScreen","index":4,"id":"thba70c809","disabled":false,"title":"Thank you for voting!"}],"type":"edition","title":"JESC 2020","ogImage":"","id":"ed936c4793","ogTitle":"","ogDescription":"","aliases":["jesc"],"name":"","config":{"logo":"https://static.junioreurovision.tv/dist/assets/images/jesc_slogan.c6c10aa7dcf40254bf08d7f7f3d65b90.png","borderWidth":0,"borderRadius":0,"logoLink":"https://hotmail.com"},"logo":"","updatedAt":1605711695555,"theme":{"buttonText":"rgb(245,245,245)","highlight":"rgb(49,130,206)","backgroundImage":"https://based-images.imgix.net/c37e075134b55505f28fc28c7c21536c.png","background":"rgb(17,11,87)","itemBackground":"rgb(252,252,252)","itemText":"rgb(0,0,0)","text":"rgb(254,255,254)"},"companyName":""}
        """
        )!
        
        let b: Json = .from(string: """
        {"children":[{"type":"waitingScreen","index":0,"id":"wa4ab7e44c","disabled":true,"title":"Wait # 1"},{"type":"welcomeScreen","index":1,"id":"we7e8b4bfc","disabled":false,"title":"The voting will start soon!"},{"type":"videoScreen","index":2,"id":"vi6d2e21ca","title":"Watch the recap first!","disabled":false,"video":"https://based-videos-fra.s3.eu-central-1.amazonaws.com/5f9bdb334d7c7d975473bab4413f1d73/5f9bdb334d7c7d975473bab4413f1d73.m3u8"},{"type":"multipleChoice","index":3,"id":"mu241ab268","disabled":false,"title":"Pick 3 of your favorite songs and submit your vote."},{"type":"thankYouScreen","index":4,"id":"thba70c809","disabled":false,"title":"Thank you for voting!"}],"type":"edition","title":"JESC 2020","ogImage":"","id":"ed936c4793","ogTitle":"","ogDescription":"","aliases":["jesc"],"name":"","config":{"logo":"https://static.junioreurovision.tv/dist/assets/images/jesc_slogan.c6c10aa7dcf40254bf08d7f7f3d65b90.png","borderWidth":0,"borderRadius":0,"logoLink":"https://hotmail.com"},"logo":"","updatedAt":1605711695555,"theme":{"buttonText":"rgb(245,245,245)","highlight":"rgb(49,130,206)","backgroundImage":"https://based-images.imgix.net/c37e075134b55505f28fc28c7c21536c.png","background":"rgb(17,11,87)","itemBackground":"rgb(252,252,252)","itemText":"rgb(0,0,0)","text":"rgb(254,255,254)"},"companyName":""}
        """
        )!
        
        let h1 = sut.hashObjectIgnoreKeyOrder(a)
        let h2 = sut.hashObjectIgnoreKeyOrder(b)
        
        XCTAssertNotEqual(h1, h2)
    }
    
}

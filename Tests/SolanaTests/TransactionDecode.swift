import XCTest
import Foundation
@testable import Solana

final class TransactionDecodeTests: XCTestCase {
    func testTransactionDecode() {
        let swapTransaction = "AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAQAHE6qKuts57bO2mg6cbj30QT4A3skmECnYiUVLCsOTirdeCgUkQaFYTleMcAX2p74eBXQZd1dwDyQZAPJfSv2KGc4W3FfOv2Xk+oeN6f/J0NU72gYddLzELx4G5UGmCxeNgj8R1MPvyuvS2qXi6VM9UWstHrV+HUZwbaukvr0Q0WY9Q+6gPplbNhPv+SK6XOQSX8+FMvOyP12TWA3oJ+XkLeVG4Udk5e5oReTsPZ52w8mzs3/ivxQXTupZBJzIVPHw/k54rg5UE6ZjmyUBpObjmq0QBWuBNpLrILwzSDuKyv2HXAcVuklgKT/VF1QWEnmrf7ArRq42XRiUkdWIZYgEfrNuCHH/POhqrZBNawsW/vjZ0w5tXghOCOpXZOYKLcemsLmFrjy6CB49a7T3SzV9/jKgKMC9Qt5n5ypgWf4B2TlNyVrr4IBnDfDn1F4pIswzwRa4dcMGijQHlQPLvHCWcnbb0Qs6UV6mEE7Jw0D1r3D9NZXd6iIwj4TsasfYvhotfwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwZGb+UhFzL/7K26csOb57yM5bvF9xJrLEObOkAAAAAEedVb8jHAbu50xW7OaBUH/bGy3qP0jlECsc2iVrwTjwbd9uHXZaGT2cvhRs7reawctIXtX1s3kTqM9YV+/wCpjJclj04kifG7PRApFI4NgwtaE5na/xCEBI572Nvp+Fm0P/on9df2SnTAmx8pWHneSwmrNt/J3VFLMhqns4zl6OL4d+g9rsaIj0Orta57MRu3jDSWCJf85ae4LBbiD/GX9tnJbfcDAMPlrdqyxs23gNR9+Snk0dv5uKt9vG+rsqgIDQAFAjSEBgANAAkDr5IDAAAAAAAQBgACACUMDwEBDAIAAgwCAAAAgJaYAAAAAAAPAQIBERAGAAcAKAwPAQEOOg8SAAIBCgclKA4OEQ4mEicdAQMaGBkPCBwbCw4jDxMiFBUXJBYTExMTExMDCRIhDxIeCiAJHwQFBiktwSCbM0HWnIEAAwAAABpkAAEHZAECEQBkAgOAlpgAAAAAAAgCky4AAAAAMgAADwMCAAABCQNciv9l8mgl8j6Fd6xh+aVvmEOc54Bo9QVJ10TmSZpG0gXr6uzo6QQqCwxGVy4M7t45sy4vc4DaiT7ps5V5J3MYJmWX01fgbyZiOTcGlMPCx8TJA+nGyFVVKMyqsvHK2ZNsvoVS7mHQL2FekI0eZHSdNlR6FTuiA6SjoQKQpg=="
        
        let data = Data(base64Encoded: swapTransaction)
        assert(data != nil)
        let transaction = try! Transaction.from(buffer: data!)
        let programIds = transaction.instructions.map {
            $0.programId.base58EncodedString
        }
        XCTAssert(programIds == [
            "ComputeBudget111111111111111111111111111111",
            "ComputeBudget111111111111111111111111111111",
            "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
            "11111111111111111111111111111111",
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
            "JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4",
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
        ])

    }

}

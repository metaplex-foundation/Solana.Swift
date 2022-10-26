//
//  TransactionTest.swift
//  
//
//  Created by Mirek Rousal on 25/10/2022.
//

import Foundation
import XCTest

@testable import Solana

final class TransactionTest: XCTestCase {
    @available(iOS 13.0.0, *)
    func testParseTransaction() async throws {
        let base64EncodedTransaction = "AowfOvMIGMKpHdSMkJngzXiF+R1nhZpXl4ead8v9j2KMRNGWxw4ORAEMBxVDHauoPybbYzxE8DxwVkGNSlpHJA8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAGDE1NcOheAvyv+bxRcoAAg+MRGtu2bkAm/5wdXQJ8rken1FULStGZ1asG/Yq4nf1D5fRiPugrD4fCDubSMsuHkdIayMAB688AuwbzoF9XnkQFo2FzCNJXzqL54DE6mJ3jcVhQyOsVuOXyU8XVGmOO2ep3vzbZGM4vgpLvjEcAM00J+V3TgVRf23jeOe/lnzkzO6KxIRRsdiBzWWuNQTu8yH/6ZEwlvNmeorQ162ZCz63Oge4CfDiNpiav1AqEyomoh3Fva1OSac1YjEGTGcfA31cfJcQU3+q9HrQZS+lxomSRdvMm5PB133e9DwijLEt6TSX1hyKy/MHeJpT5sgfx0Q6rTKN/L2kwSCbxyvNbI19PNeLYInltDmx6X1AtAMntzsjbHnHIO/C4BzQArccr6sxzJRGosQj9TDQA5uKlJYJ+C3BlsePRfEU4nVJ/awTDzVi4bHMaoP21SbbRvAP4KUYG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqS9th6tOQZlmjaIuFlZG82nyqa3jkyOF4l/umJZJMUYrAQcMAwQFAgABBggJCwsKQgxhNeMOztloLAAAAHE5N3A1TzE3VXRqWUVwRWI4UVd0Y0tXTi9hK0Q4MjI0OFhwOEdDNEFSczg9BgAAADEyMzQ1Ng=="
        
        let decoded = Data(base64Encoded: base64EncodedTransaction)!
        
        let signer = HotAccount(phrase: ["transfer", "frown", "island", "economy", "raccoon", "champion", "wisdom", "talent", "tragic", "scrub", "kangaroo", "balcony", "twenty", "miracle", "soul", "bind", "abuse", "practice", "help", "crane", "betray", "enjoy", "artwork", "clever"])!
        
        XCTAssertEqual(signer.publicKey.base58EncodedString, "FHreS1zRRqDKYfkZzoCKCPyxPNqwFFCky15qWpcvZJTT")
        
        var transaction = try Transaction.from(buffer: decoded)
        
        try transaction.partialSign(signers: [signer]).get()
        
        try transaction.serialize(requiredAllSignatures: true, verifySignatures: true)
            .onFailure {
                print($0.localizedDescription)
            }
            .onSuccess {
                let base64 = $0.base64EncodedString()
                XCTAssertEqual(base64, "AowfOvMIGMKpHdSMkJngzXiF+R1nhZpXl4ead8v9j2KMRNGWxw4ORAEMBxVDHauoPybbYzxE8DxwVkGNSlpHJA8THKf+J4IT6EzeEOQKkewZrAipeHS1im/n9LAebGOYfeXg39/TBRF9R4TE54vGIZ0gakPVcSLQk25BmDxOUpQFAgAGDE1NcOheAvyv+bxRcoAAg+MRGtu2bkAm/5wdXQJ8rken1FULStGZ1asG/Yq4nf1D5fRiPugrD4fCDubSMsuHkdIayMAB688AuwbzoF9XnkQFo2FzCNJXzqL54DE6mJ3jcVhQyOsVuOXyU8XVGmOO2ep3vzbZGM4vgpLvjEcAM00J+V3TgVRf23jeOe/lnzkzO6KxIRRsdiBzWWuNQTu8yH/6ZEwlvNmeorQ162ZCz63Oge4CfDiNpiav1AqEyomoh3Fva1OSac1YjEGTGcfA31cfJcQU3+q9HrQZS+lxomSRdvMm5PB133e9DwijLEt6TSX1hyKy/MHeJpT5sgfx0Q6rTKN/L2kwSCbxyvNbI19PNeLYInltDmx6X1AtAMntzsjbHnHIO/C4BzQArccr6sxzJRGosQj9TDQA5uKlJYJ+C3BlsePRfEU4nVJ/awTDzVi4bHMaoP21SbbRvAP4KUYG3fbh12Whk9nL4UbO63msHLSF7V9bN5E6jPWFfv8AqS9th6tOQZlmjaIuFlZG82nyqa3jkyOF4l/umJZJMUYrAQcMAwQFAgABBggJCwsKQgxhNeMOztloLAAAAHE5N3A1TzE3VXRqWUVwRWI4UVd0Y0tXTi9hK0Q4MjI0OFhwOEdDNEFSczg9BgAAADEyMzQ1Ng==")
            }
    
    }
}


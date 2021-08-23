import Foundation
import secp256k1

struct CKSecp256k1 {
    /*
     + (NSData *)generatePublicKeyWithPrivateKey:(NSData *)privateKeyData compression:(BOOL)isCompression
     {
         secp256k1_context *context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
         
         const unsigned char *prvKey = (const unsigned char *)privateKeyData.bytes;
         secp256k1_pubkey pKey;
         
         int result = secp256k1_ec_pubkey_create(context, &pKey, prvKey);
         if (result != 1) {
             return nil;
         }
         
         int size = isCompression ? 33 : 65;
         unsigned char *pubkey = malloc(size);
         
         size_t s = size;
         
         result = secp256k1_ec_pubkey_serialize(context, pubkey, &s, &pKey, isCompression ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED);
         if (result != 1) {
             return nil;
         }
         
         secp256k1_context_destroy(context);
         
         NSMutableData *data = [NSMutableData dataWithBytes:pubkey length:size];
         free(pubkey);
         return data;
     }
     */
    static func generatePublicKey(withPrivateKey privateKeyData: Data, compression isCompression: Bool) -> Data? {
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        let prvKey = privateKeyData.bytes
        var pKey = secp256k1_pubkey()

        var result = secp256k1_ec_pubkey_create(context, &pKey, prvKey)
        if result != 1 {
            return nil
        }

        let size = isCompression ? 33 : 65
        let pubkey = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        var s = size

        result = secp256k1_ec_pubkey_serialize(context, pubkey, &s, &pKey, UInt32(isCompression ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
        if result != 1 {
            return nil
        }

        secp256k1_context_destroy(context)

        let data = NSMutableData(bytes: pubkey, length: size).copy()
        return data as? Data
    }
    /*
     + (NSData *)compactSignData:(NSData *)msgData withPrivateKey:(NSData *)privateKeyData
     {
         secp256k1_context *context = secp256k1_context_create(SECP256K1_CONTEXT_SIGN);
         
         const unsigned char *prvKey = (const unsigned char *)privateKeyData.bytes;
         const unsigned char *msg = (const unsigned char *)msgData.bytes;
         
         unsigned char *siga = malloc(64);
         secp256k1_ecdsa_signature sig;
         int result = secp256k1_ecdsa_sign(context, &sig, msg, prvKey, NULL, NULL);
         
         result = secp256k1_ecdsa_signature_serialize_compact(context, siga, &sig);
         
         if (result != 1) {
             return nil;
         }
         
         secp256k1_context_destroy(context);
         
         NSMutableData *data = [NSMutableData dataWithBytes:siga length:64];
         free(siga);
         return data;
     }
     */
    static func compactSignData(msgData: Data, withPrivateKey privateKeyData: Data) -> Data? {
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
        let prvKey = privateKeyData.bytes
        let msg = msgData.bytes
        let siga = UnsafeMutablePointer<UInt8>.allocate(capacity: 64)
        var sig = secp256k1_ecdsa_signature()

        var result = secp256k1_ecdsa_sign(context, &sig, msg, prvKey, nil, nil)
        result = secp256k1_ecdsa_signature_serialize_compact(context, siga, &sig)

        if result != 1 {
            return nil
        }

        secp256k1_context_destroy(context)

        let data = NSMutableData(bytes: siga, length: 64).copy()
        return data as? Data
    }

    /*
     + (NSInteger)verifySignedData:(NSData *)sigData withMessageData:(NSData *)msgData usePublickKey:(NSData *)pubKeyData
    {
        secp256k1_context *context = secp256k1_context_create(SECP256K1_CONTEXT_VERIFY | SECP256K1_CONTEXT_SIGN);
        
        const unsigned char *sig = (const unsigned char *)sigData.bytes;
        const unsigned char *msg = (const unsigned char *)msgData.bytes;
        
        const unsigned char *pubKey = (const unsigned char *)pubKeyData.bytes;
        
        secp256k1_pubkey pKey;
        int pubResult = secp256k1_ec_pubkey_parse(context, &pKey, pubKey, pubKeyData.length);
        if (pubResult != 1) return -3;
        
        secp256k1_ecdsa_signature sig_ecdsa;
        int sigResult = secp256k1_ecdsa_signature_parse_compact(context, &sig_ecdsa, sig);
        if (sigResult != 1) return -4;
        
        int result = secp256k1_ecdsa_verify(context, &sig_ecdsa, msg, &pKey);
        
        secp256k1_context_destroy(context);
        return result;
    }*/
    static func verifySignedData(sigData: Data, withMessageData msgData: Data, usePublickKey pubKeyData: Data) -> Int32 {

        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY | SECP256K1_CONTEXT_SIGN))!
        let sig = sigData.bytes
        let msg = msgData.bytes

        let pubKey = pubKeyData.bytes
        var pKey = secp256k1_pubkey()

        let pubResult = secp256k1_ec_pubkey_parse(context, &pKey, pubKey, pubKeyData.count)
        if pubResult != 1 { return -3 }

        var sig_ecdsa = secp256k1_ecdsa_signature()
        let sigResult = secp256k1_ecdsa_signature_parse_compact(context, &sig_ecdsa, sig)
        if sigResult != 1 { return -4 }

        let result = secp256k1_ecdsa_verify(context, &sig_ecdsa, msg, &pKey)

        secp256k1_context_destroy(context)
        return result
    }

}

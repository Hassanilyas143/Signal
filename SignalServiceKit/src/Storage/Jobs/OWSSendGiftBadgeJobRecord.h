//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/SSKJobRecord.h>

NS_ASSUME_NONNULL_BEGIN

@class SDSAnyWriteTransaction;

@interface OWSSendGiftBadgeJobRecord : SSKJobRecord

// Several of these properties aren't right but match their database columns.
//
// - Several columns are Stripe-specific, from a time before PayPal was supported as a processor
// - "Credential" is misspelled as "credentail"
//
// In the long term, we should rename these columns.
@property (nonatomic, readonly) NSString *paymentProcessor;
@property (nonatomic, readonly) NSData *receiptCredentailRequestContext;
@property (nonatomic, readonly) NSData *receiptCredentailRequest;
@property (nonatomic, readonly) NSDecimalNumber *amount;
@property (nonatomic, readonly) NSString *currencyCode;
@property (nonatomic, readonly, nullable) NSString *paymentIntentClientSecret;
@property (nonatomic, readonly, nullable) NSString *boostPaymentIntentID;
@property (nonatomic, readonly, nullable) NSString *paymentMethodId;
@property (nonatomic, readonly, nullable) NSString *paypalPayerId;
@property (nonatomic, readonly, nullable) NSString *paypalPaymentId;
@property (nonatomic, readonly, nullable) NSString *paypalPaymentToken;
@property (nonatomic, readonly) NSString *threadId;
@property (nonatomic, readonly) NSString *messageText;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPaymentProcessor:(NSString *)paymentProcessor
         receiptCredentialRequestContext:(NSData *)receiptCredentailRequestContext
                receiptCredentialRequest:(NSData *)receiptCredentialRequest
                                  amount:(NSDecimalNumber *)amount
                            currencyCode:(NSString *)currencyCode
               paymentIntentClientSecret:(nullable NSString *)paymentIntentClientSecret
                         paymentIntentId:(nullable NSString *)paymentIntentId
                         paymentMethodId:(nullable NSString *)paymentMethodId
                           paypalPayerId:(nullable NSString *)paypalPayerId
                         paypalPaymentId:(nullable NSString *)paypalPaymentId
                      paypalPaymentToken:(nullable NSString *)paypalPaymentToken
                                threadId:(NSString *)threadId
                             messageText:(NSString *)messageText
                                   label:(NSString *)label NS_DESIGNATED_INITIALIZER;

- (nullable)initWithLabel:(NSString *)label NS_UNAVAILABLE;

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
    exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                  failureCount:(NSUInteger)failureCount
                         label:(NSString *)label
                        sortId:(unsigned long long)sortId
                        status:(SSKJobRecordStatus)status NS_UNAVAILABLE;

// --- CODE GENERATION MARKER

// This snippet is generated by /Scripts/sds_codegen/sds_generate.py. Do not manually edit it, instead run
// `sds_codegen.sh`.

// clang-format off

- (instancetype)initWithGrdbId:(int64_t)grdbId
                      uniqueId:(NSString *)uniqueId
      exclusiveProcessIdentifier:(nullable NSString *)exclusiveProcessIdentifier
                    failureCount:(NSUInteger)failureCount
                           label:(NSString *)label
                          sortId:(unsigned long long)sortId
                          status:(SSKJobRecordStatus)status
                          amount:(NSDecimalNumber *)amount
            boostPaymentIntentID:(nullable NSString *)boostPaymentIntentID
                    currencyCode:(NSString *)currencyCode
                     messageText:(NSString *)messageText
       paymentIntentClientSecret:(nullable NSString *)paymentIntentClientSecret
                 paymentMethodId:(nullable NSString *)paymentMethodId
                paymentProcessor:(NSString *)paymentProcessor
                   paypalPayerId:(nullable NSString *)paypalPayerId
                 paypalPaymentId:(nullable NSString *)paypalPaymentId
              paypalPaymentToken:(nullable NSString *)paypalPaymentToken
        receiptCredentailRequest:(NSData *)receiptCredentailRequest
 receiptCredentailRequestContext:(NSData *)receiptCredentailRequestContext
                        threadId:(NSString *)threadId
NS_DESIGNATED_INITIALIZER NS_SWIFT_NAME(init(grdbId:uniqueId:exclusiveProcessIdentifier:failureCount:label:sortId:status:amount:boostPaymentIntentID:currencyCode:messageText:paymentIntentClientSecret:paymentMethodId:paymentProcessor:paypalPayerId:paypalPaymentId:paypalPaymentToken:receiptCredentailRequest:receiptCredentailRequestContext:threadId:));

// clang-format on

// --- CODE GENERATION MARKER

@end

NS_ASSUME_NONNULL_END

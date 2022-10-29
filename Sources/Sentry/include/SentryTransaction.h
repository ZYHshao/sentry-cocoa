#import "SentryEvent.h"
#import "SentrySpanProtocol.h"
#import "SentryTracer.h"

NS_ASSUME_NONNULL_BEGIN

@class SentryTracer, SentryTransactionContext;

NS_SWIFT_NAME(Transaction)
@interface SentryTransaction : SentryEvent
SENTRY_NO_INIT

@property (nonatomic, strong) SentryTracer *trace;
@property (nonatomic, strong) NSArray<id<SentrySpan>> *spans;

- (instancetype)initWithTrace:(SentryTracer *)trace;

@end

NS_ASSUME_NONNULL_END

#import "SentryTransactionContext.h"
#import "SentryLog.h"

NS_ASSUME_NONNULL_BEGIN

@implementation SentryTransactionContext

- (instancetype)initWithName:(NSString *)name operation:(NSString *)operation
{
    return [self initWithName:name
                   nameSource:kSentryTransactionNameSourceCustom
                    operation:operation];
}

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(NSString *)operation
{
    if (self = [super initWithOperation:operation]) {
        [self commonInitWithName:name source:source parentSampled:NO];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                   operation:(NSString *)operation
                     sampled:(SentrySampleDecision)sampled
{
    return [self initWithName:name
                   nameSource:kSentryTransactionNameSourceCustom
                    operation:operation
                      sampled:sampled];
}

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(NSString *)operation
                     sampled:(SentrySampleDecision)sampled
{
    if (self = [super initWithOperation:operation sampled:sampled]) {
        [self commonInitWithName:name source:source parentSampled:NO];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                   operation:(nonnull NSString *)operation
                     traceId:(SentryId *)traceId
                      spanId:(SentrySpanId *)spanId
                parentSpanId:(nullable SentrySpanId *)parentSpanId
               parentSampled:(SentrySampleDecision)parentSampled
{
    return [self initWithName:name
                   nameSource:kSentryTransactionNameSourceCustom
                    operation:operation
                      traceId:traceId
                       spanId:spanId
                 parentSpanId:parentSpanId
                parentSampled:parentSampled];
}

- (instancetype)initWithName:(NSString *)name
                  nameSource:(SentryTransactionNameSource)source
                   operation:(nonnull NSString *)operation
                     traceId:(SentryId *)traceId
                      spanId:(SentrySpanId *)spanId
                parentSpanId:(nullable SentrySpanId *)parentSpanId
               parentSampled:(SentrySampleDecision)parentSampled
{
    if (self = [super initWithTraceId:traceId
                               spanId:spanId
                             parentId:parentSpanId
                            operation:operation
                              sampled:false]) {
        [self commonInitWithName:name source:source parentSampled:parentSampled];
    }
    return self;
}

#pragma mark - Private

- (void)commonInitWithName:(NSString *)name
                    source:(SentryTransactionNameSource)source
             parentSampled:(BOOL)parentSampled
{
    _name = [NSString stringWithString:name];
    _nameSource = source;
    self.parentSampled = parentSampled;
    SENTRY_LOG_DEBUG(@"Created transaction context with name %@", name);
}

@end

NS_ASSUME_NONNULL_END

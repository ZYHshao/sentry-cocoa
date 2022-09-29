#import "SentryANRTracker.h"
#import "SentryDefaultCurrentDateProvider.h"
#import "SentryDispatchQueueWrapper.h"
#import "SentryUIApplication.h"
#import <Foundation/Foundation.h>
#import <SentryAppStateManager.h>
#import <SentryClient+Private.h>
#import <SentryCrashWrapper.h>
#import <SentryDebugImageProvider.h>
#import <SentryDefaultCurrentDateProvider.h>
#import <SentryDependencyContainer.h>
#import <SentryDispatchQueueWrapper.h>
#import <SentryHub.h>
#import <SentryNSNotificationCenterWrapper.h>
#import <SentrySDK+Private.h>
#import <SentryScreenshot.h>
#import <SentrySwizzleWrapper.h>
#import <SentrySysctl.h>
#import <SentryThreadWrapper.h>
#import <SentryViewHierarchy.h>

@implementation SentryDependencyContainer {
    NSMutableDictionary<NSString *, id (^)(void)> *_callbacks;
}

static SentryDependencyContainer *instance;
static NSObject *sentryDependencyContainerLock;

+ (void)initialize
{
    if (self == [SentryDependencyContainer class]) {
        sentryDependencyContainerLock = [[NSObject alloc] init];
    }
}

+ (instancetype)sharedInstance
{
    @synchronized(sentryDependencyContainerLock) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
        return instance;
    }
}

+ (void)reset
{
    @synchronized(sentryDependencyContainerLock) {
        instance = nil;
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        _callbacks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerProtocol:(Protocol *)proto withImplementation:(id (^)(void))callback
{
    @synchronized(sentryDependencyContainerLock) {
        NSString *name = NSStringFromProtocol(proto);
        if (name) {
            _callbacks[name] = callback;
        }
    }
}

- (nullable id)implementationForProtocol:(Protocol *)proto
{
    NSString *name = NSStringFromProtocol(proto);
    id (^imp)(void) = _callbacks[name];
    if (!imp) {
        return nil;
    }
    return imp();
}

- (SentryFileManager *)fileManager
{
    @synchronized(sentryDependencyContainerLock) {
        if (_fileManager == nil) {
            _fileManager = [[[SentrySDK currentHub] getClient] fileManager];
        }
        return _fileManager;
    }
}

- (SentryAppStateManager *)appStateManager
{
    @synchronized(sentryDependencyContainerLock) {
        if (_appStateManager == nil) {
            SentryOptions *options = [[[SentrySDK currentHub] getClient] options];
            _appStateManager = [[SentryAppStateManager alloc]
                    initWithOptions:options
                       crashWrapper:self.crashWrapper
                        fileManager:self.fileManager
                currentDateProvider:[SentryDefaultCurrentDateProvider sharedInstance]
                             sysctl:[[SentrySysctl alloc] init]];
        }
        return _appStateManager;
    }
}

- (SentryCrashWrapper *)crashWrapper
{
    if (_crashWrapper == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_crashWrapper == nil) {
                _crashWrapper = [SentryCrashWrapper sharedInstance];
            }
        }
    }
    return _crashWrapper;
}

- (SentryThreadWrapper *)threadWrapper
{
    if (_threadWrapper == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_threadWrapper == nil) {
                _threadWrapper = [[SentryThreadWrapper alloc] init];
            }
        }
    }
    return _threadWrapper;
}

- (SentryDispatchQueueWrapper *)dispatchQueueWrapper
{
    @synchronized(sentryDependencyContainerLock) {
        if (_dispatchQueueWrapper == nil) {
            _dispatchQueueWrapper = [[SentryDispatchQueueWrapper alloc] init];
        }
        return _dispatchQueueWrapper;
    }
}

- (SentryNSNotificationCenterWrapper *)notificationCenterWrapper
{
    @synchronized(sentryDependencyContainerLock) {
        if (_notificationCenterWrapper == nil) {
            _notificationCenterWrapper = [[SentryNSNotificationCenterWrapper alloc] init];
        }
        return _notificationCenterWrapper;
    }
}

- (id<SentryRandom>)random
{
    if (_random == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_random == nil) {
                _random = [[SentryRandom alloc] init];
            }
        }
    }
    return _random;
}

#if SENTRY_HAS_UIKIT
- (SentryScreenshot *)screenshot
{
    if (_screenshot == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_screenshot == nil) {
                _screenshot = [[SentryScreenshot alloc] init];
            }
        }
    }
    return _screenshot;
}

- (SentryViewHierarchy *)viewHierarchy
{
    if (_viewHierarchy == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_viewHierarchy == nil) {
                _viewHierarchy = [[SentryViewHierarchy alloc] init];
            }
        }
    }
    return _viewHierarchy;
}

- (SentryUIApplication *)application
{
    if (_application == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_application == nil) {
                _application = [[SentryUIApplication alloc] init];
            }
        }
    }
    return _application;
}
#endif

- (SentrySwizzleWrapper *)swizzleWrapper
{
    if (_swizzleWrapper == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_swizzleWrapper == nil) {
                _swizzleWrapper = SentrySwizzleWrapper.sharedInstance;
            }
        }
    }
    return _swizzleWrapper;
}

- (SentryDebugImageProvider *)debugImageProvider
{
    if (_debugImageProvider == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_debugImageProvider == nil) {
                _debugImageProvider = [[SentryDebugImageProvider alloc] init];
            }
        }
    }

    return _debugImageProvider;
}

- (SentryANRTracker *)getANRTracker:(NSTimeInterval)timeout
{
    if (_anrTracker == nil) {
        @synchronized(sentryDependencyContainerLock) {
            if (_anrTracker == nil) {
                _anrTracker = [[SentryANRTracker alloc]
                    initWithTimeoutInterval:timeout
                        currentDateProvider:[SentryDefaultCurrentDateProvider sharedInstance]
                               crashWrapper:self.crashWrapper
                       dispatchQueueWrapper:[[SentryDispatchQueueWrapper alloc] init]
                              threadWrapper:self.threadWrapper];
            }
        }
    }
    return _anrTracker;
}

- (id<SentryDescriptor>)descriptor
{
    id<SentryDescriptor> result = [self implementationForProtocol:@protocol(SentryDescriptor)];
    if (!result) {
        @synchronized(sentryDependencyContainerLock) {
            result = SentryDescriptor.shared;
            [self registerProtocol:@protocol(SentryDescriptor)
                withImplementation:^id { return [SentryDescriptor shared]; }];
        }
    }
    return result;
}

@end

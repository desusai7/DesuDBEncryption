//
//  Bugsnag+Private.h
//  Bugsnag
//
//  Created by Nick Dowell on 04/12/2020.
//  Copyright © 2020 Bugsnag Inc. All rights reserved.
//

#import <RSCrashReporter/RSCrashReporter.h>

#import "BSGDefines.h"

NS_ASSUME_NONNULL_BEGIN

BSG_OBJC_DIRECT_MEMBERS
@interface RSCrashReporter ()

#pragma mark Methods

+ (void)purge;

@end

NS_ASSUME_NONNULL_END

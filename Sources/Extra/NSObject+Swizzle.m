// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "NSObject+Swizzle.h"

#import <objc/runtime.h>
#import <objc/message.h>

static void swizzle_intern(Class c, SEL orig, SEL new, BOOL class_method)
{
    Method origMethod;
    Method newMethod;
	
	if (class_method)
	{
		origMethod = class_getClassMethod(c, orig);
		newMethod = class_getClassMethod(c, new);
	} else {
		origMethod = class_getInstanceMethod(c, orig);
		newMethod = class_getInstanceMethod(c, new);
	}
	
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
	{
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
		method_exchangeImplementations(origMethod, newMethod);
	}
}

@implementation NSObject (Swizzle)

+ (void) swizzleMethod: (SEL) orig_sel withMethod: (SEL) alt_sel
{
	swizzle_intern([self class], orig_sel, alt_sel, NO);
}

+ (void) swizzleClassMethod: (SEL) orig_sel withClassMethod: (SEL) alt_sel
{
	swizzle_intern([self class], orig_sel, alt_sel, YES);
}

@end

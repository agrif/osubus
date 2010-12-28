// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

#import "NSObject+Swizzle.h"

#import <objc/runtime.h>
#import <objc/message.h>

static BOOL swizzle_intern(Class c, SEL orig, SEL new, BOOL class_method)
{
	if (class_method)
		c = c->isa;
	
	Method origMethod = class_getInstanceMethod(c, orig);
	Method newMethod = class_getInstanceMethod(c, new);
	
	if (!newMethod)
		return NO;
	
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
	{
		if (origMethod)
			class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
		if (origMethod)
			method_exchangeImplementations(origMethod, newMethod);
	}
	
	return origMethod != NULL;
}

@implementation NSObject (Swizzle)

+ (BOOL) swizzleMethod: (SEL) orig_sel withMethod: (SEL) alt_sel
{
	return swizzle_intern([self class], orig_sel, alt_sel, NO);
}

+ (BOOL) swizzleClassMethod: (SEL) orig_sel withClassMethod: (SEL) alt_sel
{
	return swizzle_intern([self class], orig_sel, alt_sel, YES);
}

@end

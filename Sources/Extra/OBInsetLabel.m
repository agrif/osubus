// OSU Bus - a client for the OSU Bus System
// Copyright (C) 2010 Aaron Griffith
//
// This file is licensed under the GNU GPL v2. See
// the file "main.m" for details.

// this source is originally from
// http://stackoverflow.com/a/17557490
// though it has been modified

#import "OBInsetLabel.h"

@implementation OBInsetLabel

- (id) initWithFrame: (CGRect) frame {
	self = [super initWithFrame: frame];
	if (self)
	{
		self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
	}
	return self;
}

- (void) drawTextInRect: (CGRect) rect {
	[super drawTextInRect: UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize) sizeThatFits: (CGSize) size
{
	CGSize inset = size;
	inset.width -= self.edgeInsets.left + self.edgeInsets.right;
	inset.height -= self.edgeInsets.top + self.edgeInsets.bottom;
	
	CGSize result = [super sizeThatFits: inset];
	result.width += self.edgeInsets.left + self.edgeInsets.right;
	result.height += self.edgeInsets.top + self	.edgeInsets.bottom;
	return result;
}

- (CGSize) intrinsicContentSize
{
	CGSize size = [super intrinsicContentSize];
	size.width  += self.edgeInsets.left + self.edgeInsets.right;
	size.height += self.edgeInsets.top + self.edgeInsets.bottom;
	return size;
}

@end
#import <Foundation/Foundation.h>

int main (int argc, char** argv)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Hello, World!");
	
    [pool drain];
    return 0;
}

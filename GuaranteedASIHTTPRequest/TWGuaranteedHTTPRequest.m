//
//  GuaranteedASIHTTPRequest.m
//
//  Created by Tom Nys on 16/12/11.
//  Copyright (c) 2011 Netwalk VOF. All rights reserved.
//

#import "GuaranteedASIHTTPRequest.h"
#import "Reachability.h"

#define kASIPendingRequests				@"__pendingRequests"

@implementation TWGuaranteedHTTPRequest

-(id)initWithURL:(NSURL *)newURL
{
	if (self = [super initWithURL:newURL])
	{
		// if we have pending requests AND we have a network connectio, schedule them first
		Reachability* r = [Reachability reachabilityForInternetConnection];
		if ([r currentReachabilityStatus] != NotReachable)
		{
			NSArray* requests = [[NSUserDefaults standardUserDefaults] objectForKey:kASIPendingRequests];
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:kASIPendingRequests];
			[[NSUserDefaults standardUserDefaults] synchronize];
			for (NSString* __url in requests)
			{
				TWGuaranteedHTTPRequest* req = [TWGuaranteedHTTPRequest requestWithURL:[NSURL URLWithString:__url]];
				[req startAsynchronous];
			}
		}
	}
	return self;
}

-(void)startAsynchronous
{
	if (failureBlock || completionBlock || delegate)
	{
		// this class cannot work if you have a failure block, completion block or delegate specified
		abort();
	}
	
	// first set the failed block.  If something fails, we store the URL for later retrial
	[self setFailedBlock:^{
		
		if (self 
		
		NSMutableArray* requests = [[[[NSUserDefaults standardUserDefaults] objectForKey:kASIPendingRequests] mutableCopy] autorelease];
		if (!requests) requests = [NSMutableArray arrayWithCapacity:1];
		[requests addObject:self.url.absoluteString];
		[[NSUserDefaults standardUserDefaults] setObject:requests forKey:kASIPendingRequests];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];

	[super startAsynchronous];
}

@end

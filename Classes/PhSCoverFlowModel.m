#import "PhSCoverFlowModel.h"


@implementation PhSCoverFlowModel

@synthesize coverFlowLayer;
@synthesize index;
@synthesize quality;

-(PhSCoverFlowModel *)initWithCoverFlowLayer:(UICoverFlowLayer *)cvLayer index:(int)i quality:(int)q
{
	if (!(self = [super init])) return self;
	
	self.coverFlowLayer = cvLayer;
	self.index = i;
	self.quality = q;
	
	return self;
}

@end

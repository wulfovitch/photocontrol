#import "PhSCoverFlowViewController.h"

@implementation CFView

- (id) initWithFrame:(struct CGRect)frame covers:(NSMutableArray *)covers {
	self = [ super initWithFrame: frame ];
	
	if (self != nil) {
		_covers = covers;
		selectedCover = 0;
		
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = YES;
		self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
		self.delegate = self;
		self.scrollsToTop = NO;
		self.bouncesZoom = NO;
		self.alwaysBounceHorizontal = NO;
		self.alwaysBounceVertical = NO;
		
		cfIntLayer = [ [ CAScrollLayer alloc ] init ];
		cfIntLayer.bounds = CGRectMake(0.0, 0.0, frame.size.width + COVER_WIDTH_HEIGHT, frame.size.height );
		cfIntLayer.position = CGPointMake(160.0, 200.0);
		cfIntLayer.frame = frame;
		
		for(int i = 0; i < [ _covers count ]; i++) {
			NSLog(@"Initializing cfIntLayer layer %d\n", i);
			UIImageView *background = [ [ [ UIImageView alloc ] initWithImage: [ _covers objectAtIndex: i ] ] autorelease ];
			background.frame = CGRectMake(0.0, 0.0, COVER_WIDTH_HEIGHT, COVER_WIDTH_HEIGHT);
			[ cfIntLayer addSublayer: background.layer ];
		}
		
		self.contentSize = CGSizeMake(320.0 + SCROLL_PIXELS * ([ _covers count ] -1), frame.size.height  );
		
		[ self.layer addSublayer: cfIntLayer ];
		[ self layoutLayer: cfIntLayer ];
	}
	
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
    selectedCover = (int) roundf((self.contentOffset.x/SCROLL_PIXELS));
	if (selectedCover > [ _covers count ] -1) {
		selectedCover = [ _covers count ] - 1;
	}
	[ self layoutLayer: cfIntLayer ];
}

- (void)setSelectedCover:(int)index {
	
	if (index != selectedCover) {
		selectedCover  = index;
		[ self layoutLayer: cfIntLayer ];
		self.contentOffset = CGPointMake(selectedCover * SCROLL_PIXELS, self.contentOffset.y);
	}
}

- (int) getSelectedCover {
	return selectedCover;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	NSUInteger tapCount = [touch tapCount];
	
	switch (tapCount)
	{
		case 1:
			//NSLog(@"tapcount 1");
			//	[self performSelector:@selector(singleTapMethod) withObject:nil afterDelay:.4];
			break;
		case 2:
			//NSLog(@"tapcount 2");
			//[self performSelector:@selector(doubleTapMethod) withObject:nil afterDelay:.2];
			NSLog([NSString stringWithFormat: @"double tap - cover: %d", self.selectedCover]);
			break;
		default:
			break;
	}
	[super touchesBegan:touches withEvent:event];
}

-(void) layoutLayer:(CAScrollLayer *)layer
{
    CALayer *sublayer;
    NSArray *array;
    size_t i, count;
    CGRect rect, cfImageRect;
    CGSize cellSize, spacing, margin;
    CGSize size;
    CATransform3D leftTransform, rightTransform, sublayerTransform;
    float zCenterPosition, zSidePosition;
    float sideSpacingFactor, rowScaleFactor;
    float angle = 1.6;
    int x;
	
    size = [ layer bounds ].size;
	
    zCenterPosition = 40;      /* Z-Position of selected cover */
    zSidePosition = -10;         /* Default Z-Position for other covers */
    sideSpacingFactor = .6;   /* How close should slide covers be */
    rowScaleFactor = .6;      /* Distance between main cover and side covers */
	
    leftTransform = CATransform3DMakeRotation(angle, 0, 1, 0);
    rightTransform = CATransform3DMakeRotation(-angle, 0, 1, 0);
	
    margin   = CGSizeMake(5.0, 5.0);
    spacing  = CGSizeMake(5.0, 5.0);
    cellSize = CGSizeMake (COVER_WIDTH_HEIGHT, COVER_WIDTH_HEIGHT);
	
    //margin.height += (size.height - cellSize.height * [ _covers count ] -  spacing.height * ([ _covers count ] - 1)) * .5;
    //margin.height = floor (margin.height);
	margin.width += (size.width - cellSize.width * [ _covers count ] -  spacing.width * ([ _covers count ] - 1)) * .1;
    margin.width = floor (margin.width);
	
    /* Build an array of covers */
    array = [ layer sublayers ];
    count = [ array count ];
    sublayerTransform = CATransform3DIdentity;
	
	/* Set perspective */
    sublayerTransform.m34 = -0.006;
    
	/* Begin a CATransaction so that all animations happen simultaneously */
    [ CATransaction begin ];
    [ CATransaction setValue: [ NSNumber numberWithFloat: 0.5f ] forKey:@"animationDuration" ];
	
    for (i = 0; i < count; i++)
    {
        sublayer = [ array objectAtIndex:i ];
        x = i;
		
        rect.size = *(CGSize *)&cellSize;
        rect.origin = CGPointZero;
        cfImageRect = rect;
		
        /* Base position */
        rect.origin.y = size.height / 2 - cellSize.height / 2;
        rect.origin.x = margin.width + x * (cellSize.width + spacing.width);
		
        [ [ sublayer superlayer ] setSublayerTransform: sublayerTransform ];
		
        if (x < selectedCover)        /* Left side */
        {
            rect.origin.x += cellSize.width * sideSpacingFactor * (float) (selectedCover - x - rowScaleFactor);
            sublayer.zPosition = zSidePosition - .01 * (selectedCover - x);
            sublayer.transform = leftTransform;
        }
        else if (x > selectedCover)   /* Right side */
        {
            rect.origin.x -= cellSize.width * sideSpacingFactor * (float) (x - selectedCover - rowScaleFactor);
            sublayer.zPosition = zSidePosition - .01 * (x - selectedCover);
            sublayer.transform = rightTransform;
        }
        else                     /* Selected cover */
        {
            sublayer.transform = CATransform3DIdentity;
            sublayer.zPosition = zCenterPosition;
			
            /* Position in the middle of the scroll layer */
            [ layer scrollToPoint: CGPointMake(rect.origin.x - (([ layer bounds ].size.width - cellSize.height)/2.0), 0.0) ];
			
            /* Position the scroll layer in the center of the view */
            layer.position = CGPointMake(160.0f + (selectedCover * SCROLL_PIXELS), 240.0f);
        }
        [ sublayer setFrame: rect ];
		
    }
    [ CATransaction commit ];
}

@end

@implementation PhSCoverFlowViewController

@synthesize conManager;
@synthesize currentDirectory;

- (id)initWithConManager:(ConnectionManager *)connectionManager andDirectory:(NSString *)dir
{
	self = [ super init ];
	
	self.conManager = connectionManager;
	self.currentDirectory = dir;
	
	int pictureCount = [[conManager currentPictures] count];
	
	if (self != nil) {
		covers = [ [ NSMutableArray alloc ] init ];
		
		for(int i = 0; i < pictureCount; i++) {
			//UIImage *image = [ [ UIImage alloc ] initWithData: [ NSData dataWithContentsOfURL: [ NSURL URLWithString: [ NSString stringWithFormat: @"http://www.zdziarski.com/demo/%d.png", i%5+1 ] ] ] ];
			
			
			//NSString *imageURLString = [NSString stringWithFormat:@"http://%@:55598%@%@", [conManager serverIP], currentDirectory, [[conManager currentPictures] objectAtIndex:i]];
			//NSLog(imageURLString);
			//NSURL *url = [NSURL URLWithString:imageURLString];
			//NSData *data = [NSData dataWithContentsOfURL:url];
			//UIImage *image = [[UIImage alloc] initWithData:data];
			UIImage *image = [UIImage imageNamed:@"computer.png"];
			[ covers addObject: image ];
			[image release];
		}
	}
    return self;
}

- (void)loadView {
	[ super loadView ];
	
	covertFlowView = [ [ CFView alloc ] initWithFrame: self.view.frame covers: covers ];
	covertFlowView.selectedCover = 2;
	
	self.view = covertFlowView;	 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [ super didReceiveMemoryWarning ];
	
}


- (void)dealloc {
	[ covertFlowView release ];
    [ super dealloc ];
}

@end


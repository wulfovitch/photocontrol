#import <UIKit/UIKit.h>
#import "UICoverFlowLayer.h"

@interface PhSCoverFlowModel : NSObject {
	UICoverFlowLayer *coverFlowLayer;
	int index;
	int quality;
}

@property (nonatomic, retain) UICoverFlowLayer *coverFlowLayer;
@property int index;
@property int quality;

-(PhSCoverFlowModel *)initWithCoverFlowLayer:(UICoverFlowLayer *)cvLayer index:(int)i quality:(int)q;

@end

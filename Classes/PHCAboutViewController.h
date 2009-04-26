#import <UIKit/UIKit.h>


@interface PHCAboutViewController : UIViewController <UIAlertViewDelegate> {
	// Strings for the NIB
	IBOutlet UILabel *applicationCanBeDownloadedAt;
	IBOutlet UILabel *applicationWasCreatedBy;
	IBOutlet UILabel *supportedBy;
	IBOutlet UILabel *cameraIconBy;
	
	// String where the to opened URL is stored
	NSString *urlToOpen;
}

@property (nonatomic, retain) UILabel *applicationCanBeDownloadedAt;
@property (nonatomic, retain) UILabel *applicationWasCreatedBy;
@property (nonatomic, retain) UILabel *supportedBy;
@property (nonatomic, retain) UILabel *cameraIconBy;

@property (nonatomic, retain) NSString *urlToOpen;

-(IBAction)openURLofPhotoControlInSafari:(id)sender;
-(IBAction)openURLofOffisInSafari:(id)sender;
-(IBAction)openURLofUniOLInSafari:(id)sender;
-(IBAction)openURLofRefuelDesignInSafari:(id)sender;

@end

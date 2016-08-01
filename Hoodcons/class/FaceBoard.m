//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"
#import "ChatViewController.h"

#define FACE_COUNT_ALL  63

#define FACE_COUNT_ROW  3

#define FACE_COUNT_CLU  7

#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )

#define FACE_ICON_SIZE  44


@implementation FaceBoard

@synthesize delegate;

@synthesize inputTextField = _inputTextField;
@synthesize inputTextView = _inputTextView;
@synthesize imgTextView = _imgTextView;

- (id)init {

    userdefaults = [NSUserDefaults standardUserDefaults];
    
   
    
    
    self = [super initWithFrame:CGRectMake(0, 0, 320, 218)];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.viewForBaselineLayout.backgroundColor = [UIColor clearColor];

        faceViewBkg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 218)];
//        [faceViewBkg setImage:[UIImage imageNamed:@"msg_screen_bkg_2.png"]];
        [faceViewBkg setBackgroundColor:[UIColor grayColor]];
        [self addSubview:faceViewBkg];
        
        [self categoryload];
        
        
        UIButton *common = [UIButton buttonWithType:UIButtonTypeCustom];
        [common setImage:[UIImage imageNamed:@"store_btn.jpg"] forState:UIControlStateNormal];
        [common addTarget:self action:@selector(commoncategory) forControlEvents:UIControlEventTouchUpInside];
        common.frame = CGRectMake(0, 163, 320, 55);
        [self addSubview:common];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage imageNamed:@"kb_cats_back_white.png"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"kb_cats_back_black.png"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(285, 178, 30, 30);
        [self addSubview:back];

        
    }

    return self;
}



- (void)categoryload
{
    [faceView removeFromSuperview];
    [facePageControl removeFromSuperview];
   
    category_dictionary = [[NSMutableDictionary alloc]init];
    _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                [[NSBundle mainBundle] pathForResource:@"_expression_en"
                                                     ofType:@"plist"]];
    
    [category_dictionary addEntriesFromDictionary:_faceMap];
    
    
    if([userdefaults boolForKey:@"animalpngs"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                [[NSBundle mainBundle] pathForResource:@"_animations_en"
                                                ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"artsuplies"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_artsuplies_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"fashion"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_fashion_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"food"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_food_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"hands"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_hands_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"hoodconfacepngs"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_hoodconfacepngs_en"
                                                    ofType:@"plist"]];
       [category_dictionary addEntriesFromDictionary:_faceMap];
        
    }
    if([userdefaults boolForKey:@"music"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_music_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"sexdrugs"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_sexdrugs_en"
                                                    ofType:@"plist"]];
       [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"slang"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_slang_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"weapons"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_weapons_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"whips"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_whips_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
    }
    if([userdefaults boolForKey:@"places"])
    {
        _faceMap = [NSDictionary dictionaryWithContentsOfFile:
                    [[NSBundle mainBundle] pathForResource:@"_places_en"
                                                    ofType:@"plist"]];
        [category_dictionary addEntriesFromDictionary:_faceMap];
        
        
    }
    
    category_itemarray = [category_dictionary keysSortedByValueUsingComparator:^(id first, id second) {
        
        return [first compare:second];
        
    }];
    
    NSLog(@"array=%@", category_dictionary);
    
   [[NSUserDefaults standardUserDefaults] setObject:category_dictionary forKey:@"FaceMap"];
    
    [self categorysettings];
}


- (void)commoncategory
{
    
    ChatViewController *controller =  (ChatViewController *)delegate;
    [controller gotostorecontroller];

}


- (void)categorysettings
{
    float pagefloat = (float) ([category_itemarray count]) / FACE_COUNT_PAGE;
    int pageCnt = (int)pagefloat;
    if(pagefloat>pageCnt)
        pageCnt = pageCnt + 1;
    faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 15, 320, 170)];
    faceView.pagingEnabled = YES;
    //        faceView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * 320, 190);
    faceView.contentSize = CGSizeMake((pageCnt) * 320, 150);
    faceView.showsHorizontalScrollIndicator = NO;
    faceView.showsVerticalScrollIndicator = NO;
    faceView.delegate = self;
    
    faceView.backgroundColor = [UIColor clearColor];
    int i =1;
    for (id object in category_itemarray) {
        
        FaceButton *faceButton = [FaceButton buttonWithType:UIButtonTypeCustom];
        faceButton.buttonIndex = [object intValue];
        
        [faceButton addTarget:self
                       action:@selector(faceButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + ((i - 1) / FACE_COUNT_PAGE * 320);
        CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
        faceButton.frame = CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
        
        NSString *imgName = [NSString stringWithFormat:@"%@.png",object];
        UIImage *currImg =[UIImage imageNamed: imgName];
        if (currImg.size.width != FACE_ICON_SIZE) {
            currImg = [self image:currImg scaledToWidth:FACE_ICON_SIZE];
            //                NSLog(@"Image size is now %@",NSStringFromCGSize(currImg.size));
        }
        
        [faceButton setImage:currImg forState:UIControlStateNormal];
        
        [faceView addSubview:faceButton];
        i++;
    }
    //PageControl
    facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(110, 0, 100, 20)];
    
    facePageControl.backgroundColor = [UIColor clearColor];
    
    [facePageControl addTarget:self
                        action:@selector(pageChange:)
              forControlEvents:UIControlEventValueChanged];
    
    //        facePageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
    facePageControl.numberOfPages = pageCnt;
    
    facePageControl.currentPage = 0;
    [self addSubview:facePageControl];
    
    [self addSubview:faceView];

}


//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [facePageControl setCurrentPage:faceView.contentOffset.x / 320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {

    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * 320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {

    int i = ((FaceButton*)sender).buttonIndex;
    if (self.inputTextField) {

        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
        [faceString appendString:[category_dictionary objectForKey:[NSString stringWithFormat:@"c", i]]];
                self.inputTextField.text = faceString;
    }

    if (self.inputTextView) {

        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        [faceString appendString:[category_dictionary objectForKey:[NSString stringWithFormat:@"%03d", i]]];
//        NSLog(@"%@", [NSString stringWithFormat:@"%03d", i]);
//        NSLog(@"%@", [_faceMap objectForKey:[NSString stringWithFormat:@"%03d", i]]);
//        NSLog([_faceMap description]);
        self.inputTextView.text = faceString;
//        NSString *imgName = [NSString stringWithFormat:@"%@.png", [NSString stringWithFormat:@"%03d", i]];
//        NSLog(@"Should insert image named %@", imgName);
//        UIImage *insImg = [UIImage imageNamed:imgName];
//        if (insImg) {
//            [self.imgTextView insertObject:insImg size:insImg.size];
//        }
        
//        [imgName release];

        [delegate textViewDidChange:self.inputTextView];
    }
}

- (void)backFace{

    NSString *inputString;
    inputString = self.inputTextField.text;
    if ( self.inputTextView ) {

        inputString = self.inputTextView.text;
    }

    if ( inputString.length ) {
        
        NSString *string = nil;
        NSInteger stringLength = inputString.length;
        if ( stringLength >= FACE_NAME_LEN ) {
            
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                
                string = [inputString substringToIndex:
                          [inputString rangeOfString:FACE_NAME_HEAD
                                             options:NSBackwardsSearch].location];
            }
            else {
                
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            
            string = [inputString substringToIndex:stringLength - 1];
        }
        
        if ( self.inputTextField ) {
            
            self.inputTextField.text = string;
        }
        
        if ( self.inputTextView ) {
            
            self.inputTextView.text = string;
            
            [delegate textViewDidChange:self.inputTextView];
        }
    }
}


#pragma mark - Image Processing

- (UIImage*)image:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    //    float imgHeight = imagePreview.frame.size.height * 2;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = oldHeight * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end

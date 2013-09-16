//
//  ViewController.m
//  PinYin4ObjcExample
//
//  Created by kimziv on 13-9-16.
//  Copyright (c) 2013年 kimziv. All rights reserved.
//

#import "ViewController.h"
#import "PinYin4Objc.h"
@interface ViewController ()
{
    IBOutlet UITextField *_inputTf;
    IBOutlet UITextView *_outputTv;
    IBOutlet UILabel *_timeLb;
    IBOutlet UILabel *_wordsLb;
    IBOutlet UIButton *_OKBtn;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)doClick:(id)sender
{
    NSString *sourceText=_inputTf.text;
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    NSTimeInterval startTime=[[NSDate date] timeIntervalSince1970];
    NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:sourceText withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
    NSTimeInterval endTime=[[NSDate date] timeIntervalSince1970];
    NSTimeInterval totalTime=endTime-startTime;
    _timeLb.text=[NSString stringWithFormat:@"Total Time:%fs",totalTime];
    _wordsLb.text=[NSString stringWithFormat:@"Total Words:%i characters",sourceText.length];
    //    NSLog(@"%@:%@, seconds:%f",sourceText,outputPinyin,(end - begin)/(float)CLOCKS_PER_SEC);
    _outputTv.text=outputPinyin;
    //[NSString stringWithFormat:@"%@:%@, seconds:%fs",sourceText,outputPinyin,totalTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

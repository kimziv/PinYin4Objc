PinYin4Objc
===========

PinYin4Objc is a popular objective-c library supporting convertion between Chinese(both Simplified and Tranditional) characters and most popular Pinyin systems， it's performance is very efficient, data cached at first time. The output format of pinyin could be customized. 


* Usage 
	
		NSString *sourceText=@"我爱中文";
    	HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    	[outputFormat setToneType:ToneTypeWithoutTone];
    	[outputFormat setVCharType:VCharTypeWithV];
    	[outputFormat setCaseType:CaseTypeLowercase];
    	NSString *outputPinyin=[PinyinHelper toHanyuPinyinStringWithNSString:sourceText withHanyuPinyinOutputFormat:outputFormat withNSString:@" "];
    	
    	
    	
* ScreenShot

   ![ScreenShot](ScreenShot.PNG)
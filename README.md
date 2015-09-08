# FImageOperation
Image Operation Libaray by Frank/Objective-C 
<br />
<br />
support image operation types: 
<br />
① Clip
<br />
② Mosaic
<br />
③ Rotaing 
<br />
<br />
Implementation steps（eg）： 
<br />
① #import "FImageOperationManager" 
<br />
② call [[FImageOperationManager sharedInstance] operationType:(FImageOperationType)operationType sourceImage:(UIImage *)sourceImage delegate:(UIViewController *)delegate];
<br />
<br />
App Demo:
<br />
<img src="https://github.com/After90Coder/FImageOperation/blob/master/FImageOperation/FImageOperation.gif" width="320" height="480"/>

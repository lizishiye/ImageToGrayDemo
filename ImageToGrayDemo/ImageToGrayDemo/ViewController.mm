//
//  ViewController.m
//  ImageToGrayDemo
//
//  Created by admin on 17/6/21.
//  Copyright © 2017年 lizihaha. All rights reserved.
//

#import "ViewController.h"

#import <opencv2/opencv.hpp>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *myImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //使用ios系统方法处理
//    self.myImgView.image = [self systemImageToGrayImage:[UIImage imageNamed:@"587484756219e.jpg"]];
    //使用openvc处理
    self.myImgView.image = [self imageToGrayImage:[UIImage imageNamed:@"587484756219e.jpg"]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (UIImage*)imageToGrayImage:(UIImage*)image {
    
    //image源文件
    // 1.将iOS的UIImage转成cv::Mat
    cv::Mat mat_image = [self cvMatFromUIImage:image];
    
    // 2. 将cv::Mat转成更改后的UIImage
    UIImage * img = [self UIImageFromCVMat:mat_image];
    
    return img;
}

//UIImage To cv::Mat:
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//cv::Mat To UIImage:
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
//    if (cvMat.elemSize() == 1) {//可以根据这个决定使用哪种
//        colorSpace = CGColorSpaceCreateDeviceGray();
//    } else {
//        colorSpace = CGColorSpaceCreateDeviceRGB();
//    }
    
    colorSpace = CGColorSpaceCreateDeviceGray();

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


- (UIImage*)systemImageToGrayImage:(UIImage*)image {
    
    int width  = image.size.width;
    int height = image.size.height;
    //第一步：创建颜色空间(说白了就是开辟一块颜色内存空间)
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceGray();
    
    //第二步：颜色空间上下文(保存图像数据信息)
    //参数一：指向这块内存区域的地址（内存地址）
    //参数二：要开辟的内存的大小，图片宽
    //参数三：图片高
    //参数四：像素位数(颜色空间，例如：32位像素格式和RGB的颜色空间，8位）
    //参数五：图片的每一行占用的内存的比特数
    //参数六：颜色空间
    //参数七：图片是否包含A通道（ARGB四个通道）
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorRef, kCGImageAlphaNone);
    //释放内存
    CGColorSpaceRelease(colorRef);
    
    if (context == nil) {
        return  nil;
    }
    
    //渲染图片
    //参数一：上下文对象
    //参数二：渲染区域
    //源图片
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);;
    
    //将绘制的颜色空间转成CGImage
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    
    //将c/c++图片转成iOS可显示的图片
    UIImage *dstImage = [UIImage imageWithCGImage:grayImageRef];
    
    //释放内存
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    
    return dstImage;
}


@end

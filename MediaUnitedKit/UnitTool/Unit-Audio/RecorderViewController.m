//
//  RecorderViewController.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/22.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "RecorderViewController.h"
#import "MMAudioUtil.h"
#import <UUButton.h>

@interface RecorderViewController ()
{
    int recordSeconds;  // 记录定时
    NSTimer * recordTimer; // 定时器
    CGFloat btMargin;
    CGFloat btHeight;
    CGFloat btTop;
}

@property (nonatomic, strong) UIImageView * dotImageView;  // 录制时闪烁的绿点
@property (nonatomic, strong) UILabel * dotLabel; // 标识
@property (nonatomic, strong) UILabel * timeLabel; // 时长
@property (nonatomic, strong) UUButton * finishBtn; // 完成
@property (nonatomic, strong) UUButton * pauseBtn; // 录制/暂停
@property (nonatomic, strong) UUButton * cancelBtn; // 取消
@property (nonatomic, strong) MMAudioUtil * audioUtil; // 录音

@end

@implementation RecorderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"audio_bg"]];
    
    btMargin = 15;
    btHeight = (kScreenWidth - 6 * btMargin)/3.0;
    btTop = kScreenHeight- btHeight -2 * btMargin;
    if (k_iPhoneX) {
        btTop -= 20;
    }
    // 添加视图
    [self configUI];
    // util
    _audioUtil = [MMAudioUtil instance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 返回
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 录制相关
// 完成录制
- (void)finishClicked
{
    // 回传录音名称
    NSString * filePath = [_audioUtil finishRecord];
    NSString * mp3FileName = [filePath lastPathComponent];
    if (self.mp3FileNameBlock) {
        self.mp3FileNameBlock(mp3FileName);
    }
    [self backAction];
}

// 录制
- (void)recordClicked
{
    self.pauseBtn.selected = !self.pauseBtn.selected;
    NSString * title = nil;
    if (self.pauseBtn.selected == YES) {
        self.finishBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        title = @"正在录音";
        [self.dotImageView startAnimating];
        if ([self.pauseBtn.titleLabel.text isEqualToString:@"开始"]) {
            recordSeconds = 0;
        }
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTime:) userInfo:nil repeats:YES];
        // 开始录音
        [_audioUtil beginRecord];
    } else {
        title = @"录音";
        self.finishBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
        [self.dotImageView stopAnimating];
        [self.pauseBtn setTitle:@"继续" forState:UIControlStateNormal];
        // 取消定时器
        [recordTimer invalidate],recordTimer = nil;
        [_audioUtil pause];
    }
    
    CGFloat titleW = [title sizeWithFont:[UIFont systemFontOfSize:18.0] maxSize:CGSizeMake(kScreenWidth, kNavHeight)].width;
    self.dotLabel.text = title;
    self.dotLabel.frame = CGRectMake((kScreenWidth-titleW)/2, 0, titleW, kNavHeight);
    self.dotImageView.center = self.dotLabel.center;
    self.dotImageView.right = self.dotLabel.left-5;
}

// 取消
- (void)cancelClicked
{
    self.pauseBtn.selected = NO;
    [self.pauseBtn setTitle:@"开始" forState:UIControlStateNormal];
    self.finishBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.timeLabel.text = @"00:00:00";
    // 取消录音
    [_audioUtil cancelRecord];
}

#pragma mark - 计时操作
- (void)recordTime:(NSTimer *)timer
{
    recordSeconds ++;
    self.timeLabel.text = [Utility getHMSFormatBySeconds:recordSeconds];
}

#pragma mark - config ui
- (void)configUI
{
    // 顶部视图 ↓↓
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusHeight, kScreenWidth, kNavHeight)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    // 返回按钮
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, kNavHeight, kNavHeight)];
    [backBtn setImage:[UIImage imageNamed:@"media_top_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    // 绿点
    NSString * title = @"录音";
    CGFloat titleW = [title sizeWithFont:[UIFont systemFontOfSize:18.0] maxSize:CGSizeMake(kScreenWidth, kNavHeight)].width;
    _dotLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-titleW)/2, 0, titleW, kNavHeight)];
    _dotLabel.backgroundColor = [UIColor clearColor];
    _dotLabel.font = [UIFont systemFontOfSize:18.0];
    _dotLabel.textColor = [UIColor whiteColor];
    _dotLabel.text = title;
    [topView addSubview:_dotLabel];
    // 闪烁视图
    _dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_dot_clear"]];
    _dotImageView.center = _dotLabel.center;
    _dotImageView.right = _dotLabel.left-5;
    _dotImageView.animationImages = @[[UIImage imageNamed:@"media_dot"],[UIImage imageNamed:@"media_dot_clear"]];
    _dotImageView.animationDuration = 0.8;
    [topView addSubview:_dotImageView];
  
    // 中间圆圈图 ↓↓
    UIImageView * midImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_mid"]];
    midImageView.size = CGSizeMake(self.view.width*2/3, self.view.width*2/3);
    midImageView.center = self.view.center;
    if (k_iPhoneX) {
        midImageView.center = CGPointMake(self.view.center.x, self.view.center.y-20);
    }
    [self.view addSubview:midImageView];
 
    // 完整按钮 ↓↓
    _finishBtn = [[UUButton alloc] initWithFrame:CGRectMake(2*btMargin, btTop, btHeight, btHeight)];
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _finishBtn.contentAlignment = UUContentAlignmentCenterImageTop;
    [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_finishBtn setTitleColor:kUnitMainColor forState:UIControlStateHighlighted];
    [_finishBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_finishBtn setImage:[UIImage imageNamed:@"audio_finish"] forState:UIControlStateNormal];
    [_finishBtn setImage:[UIImage imageNamed:@"audio_finished"] forState:UIControlStateHighlighted];
    [_finishBtn addTarget:self action:@selector(finishClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_finishBtn];
    // 暂停按钮
    _pauseBtn = [[UUButton alloc] initWithFrame:CGRectMake(self.finishBtn.right+btMargin, btTop, btHeight, btHeight)];
    _pauseBtn.selected = NO;
    _pauseBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _pauseBtn.contentAlignment = UUContentAlignmentCenterImageTop;
    [_pauseBtn setTitle:@"继续" forState:UIControlStateNormal];
    [_pauseBtn setTitle:@"暂停" forState:UIControlStateSelected];
    [_pauseBtn setTitleColor:kUnitMainColor forState:UIControlStateHighlighted];
    [_pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_pauseBtn setImage:[UIImage imageNamed:@"audio_record"] forState:UIControlStateNormal];
    [_pauseBtn setImage:[UIImage imageNamed:@"audio_pause"] forState:UIControlStateSelected];
    [_pauseBtn addTarget:self action:@selector(recordClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pauseBtn];
    // 取消按钮
    _cancelBtn = [[UUButton alloc] initWithFrame:CGRectMake(self.pauseBtn.right+btMargin, btTop, btHeight, btHeight)];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    _cancelBtn.contentAlignment = UUContentAlignmentCenterImageTop;
    [_cancelBtn setTitle: @"取消" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:kUnitMainColor forState:UIControlStateHighlighted];
    [_cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_cancelBtn setImage:[UIImage imageNamed:@"audio_cancel"] forState:UIControlStateNormal];
    [_cancelBtn setImage:[UIImage imageNamed:@"audio_canceled"] forState:UIControlStateHighlighted];
    [_cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];

    // 录制时间 ↓↓
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topView.bottom, kScreenWidth, 44)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont fontWithName:@"Thonburi" size:30.0];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"00:00:00";
    [self.view addSubview:_timeLabel];

    self.finishBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_audioUtil cancelRecord];
    _audioUtil = nil;
}

@end

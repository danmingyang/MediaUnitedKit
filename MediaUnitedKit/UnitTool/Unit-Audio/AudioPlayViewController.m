//
//  AudioPlayViewController.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/22.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "AudioPlayViewController.h"
#import <UIView+Geometry.h>
#import "MMAudioUtil.h"

@interface AudioPlayViewController ()

@property (nonatomic, strong) UIButton * localBtn;
@property (nonatomic, strong) UIButton * remoteBtn;
@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UILabel * pathLabel;
@property (nonatomic, strong) MMAudioUtil * audioUtil;
@property (nonatomic, copy) NSString * remoteMP3Path;

@end

@implementation AudioPlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"音频播放";
    // UI
    [self configUI];
    // 播放
    _audioUtil = [MMAudioUtil instance];
    _remoteMP3Path = @"http://39.108.135.80:8080/file/message/1234/voi/20170918114342.mp3";
}

#pragma mark - 音频播放相关
- (void)selectType:(UIButton *)btn
{
    if (btn.tag == 100) {
        self.localBtn.selected = YES;
        self.remoteBtn.selected = NO;
        self.pathLabel.text = [[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName];
    } else {
        self.localBtn.selected = NO;
        self.remoteBtn.selected = YES;
        self.pathLabel.text = _remoteMP3Path;
    }
}

- (void)playAudio
{
    self.playBtn.selected = !self.playBtn.selected;
    // 播放
    if (self.playBtn.selected) {
        NSURL * mp3URL = nil;
        if (self.localBtn.selected) {
            mp3URL = [NSURL fileURLWithPath:[[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName]];
        } else {
            mp3URL = [NSURL URLWithString:_remoteMP3Path];
        }
        [_audioUtil playAudioByFileURL:mp3URL];
        // 播放完成
        __weak typeof(self) weakSelf = self;
        [_audioUtil setAudioPlayFinish:^{
            weakSelf.playBtn.selected = NO;
        }];
    } else { //停止
        [_audioUtil pause];
    }
}

#pragma mark - config ui
- (void)configUI
{
    _localBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-220)/2, 50, 100, 40)];
    _localBtn.tag = 100;
    _localBtn.selected = YES;
    _localBtn.layer.masksToBounds = YES;
    _localBtn.layer.cornerRadius = _localBtn.height/2;
    _localBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_localBtn setTitle:@"本地音频" forState:UIControlStateNormal];
    [_localBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_localBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_localBtn setBackgroundImage:[UIImage imageFromColor:kUnitUnableColor] forState:UIControlStateNormal];
    [_localBtn setBackgroundImage:[UIImage imageFromColor:kUnitMainColor] forState:UIControlStateSelected];
    [_localBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_localBtn];
    
    _remoteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.localBtn.right+20, 50, 100, 40)];
    _remoteBtn.tag = 200;
    _remoteBtn.selected = NO;
    _remoteBtn.layer.masksToBounds = YES;
    _remoteBtn.layer.cornerRadius = _remoteBtn.height/2;
    _remoteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_remoteBtn setTitle:@"在线音频" forState:UIControlStateNormal];
    [_remoteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_remoteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_remoteBtn setBackgroundImage:[UIImage imageFromColor:kUnitUnableColor] forState:UIControlStateNormal];
    [_remoteBtn setBackgroundImage:[UIImage imageFromColor:kUnitMainColor] forState:UIControlStateSelected];
    [_remoteBtn addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_remoteBtn];
    
    _pathLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, kScreenWidth-20, 60)];
    _pathLabel.font = [UIFont systemFontOfSize:12.0];
    _pathLabel.textColor = [UIColor lightGrayColor];
    _pathLabel.numberOfLines = 0;
    _pathLabel.text = [[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName];
    [self.view addSubview:_pathLabel];
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, 200, 60, 60)];
    _playBtn.selected = NO;
    [_playBtn setImage:[UIImage imageNamed:@"media_play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"media_pause"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_audioUtil pause];
    _audioUtil = nil;
}

@end

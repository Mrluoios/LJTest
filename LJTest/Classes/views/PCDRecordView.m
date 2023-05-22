//
//  PCDRecordView.m
//  PCDBank
//
//  Created by luojian on 2022/5/8.
//  Copyright © 2022 DK. All rights reserved.
//

#import "PCDRecordView.h"
#include "lame.h"
#import "PCDRecordButtonView.h"
static NSString *const MP3SaveFilePath = @"recordFile";
@interface PCDRecordView ()
<AVAudioRecorderDelegate>{
    
    AVAudioRecorder *recorder;
   
    /** caf文件路径 */
    NSURL *tmpUrl;
}

@property(nonatomic,strong)UILabel *timeLabel;
/** 录音计时器 */
@property(nonatomic,weak)NSTimer *recordTimer;
@property(nonatomic,assign)NSInteger timeCount;
@property(nonatomic,assign)NSInteger audioTimeCount;
@property(nonatomic,strong)PCDRecordButtonView *recordButton;
@property (nonatomic,strong) NSString *mp3Path;
@property (nonatomic,strong) NSString *cafPath;
@end

@implementation PCDRecordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       
        [self initTakeRecordSubViews];
    }
    return self;
}

//录音
-(void)initTakeRecordSubViews{
    _timeCount = 0;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor colorWithHex:0x333333];
    bgView.alpha = 0.3;
    
    CGFloat maxWid = 574;
    CGFloat valueWid = 0;
    valueWid = PCDScreenWidth - 40;
    if (valueWid > maxWid) {
        valueWid = maxWid;
    }
    
    
    UIView *valueView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 574)/2, (CGRectGetHeight(self.frame) - 320)/2, 574, 320)];
    [self addSubview:valueView];
    valueView.backgroundColor = [UIColor whiteColor];
    valueView.layer.cornerRadius = 12;
    valueView.layer.masksToBounds = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, CGRectGetWidth(valueView.frame) - 20, 25)];
    [valueView addSubview:titleLabel];
    titleLabel.font = [UIFont boldSystemFontOfSize:24];
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"语音录制";
    
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, CGRectGetWidth(valueView.frame) - 20, 66)];
    [valueView addSubview:_timeLabel];
    _timeLabel.font =[UIFont boldSystemFontOfSize:48];
    _timeLabel.textColor = [UIColor colorWithHex:0x333333];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"00:00";
    
    CGFloat indexY = 207;
    CGFloat indexWidth = (CGRectGetWidth(valueView.frame)/3);
    
    PCDRecordButtonView *cancleButton = [[PCDRecordButtonView alloc] initWithFrame:CGRectMake(0, indexY, indexWidth, 100)];
    [valueView addSubview:cancleButton];
    cancleButton.backgroundColor = [UIColor whiteColor];
    [cancleButton.imageButton addTarget:self action:@selector(takeClose) forControlEvents:(UIControlEventTouchUpInside)];
    cancleButton.btnameLabel.text  =@"取消";
//    cancleButton.btImgView.image = [UIImage imageNamed:@"icon_record_cancle"];
    [cancleButton.imageButton setImage:[UIImage imageNamed:@"icon_record_cancle_n"] forState:(UIControlStateNormal)];
    [cancleButton.imageButton setImage:[UIImage imageNamed:@"icon_record_cancle_s"] forState:(UIControlStateHighlighted)];

    _recordButton = [[PCDRecordButtonView alloc] initWithFrame:CGRectMake(indexWidth, indexY, indexWidth, 100)];
    [valueView addSubview:_recordButton];
    _recordButton.backgroundColor = [UIColor whiteColor];
 
    [_recordButton.imageButton addTarget:self action:@selector(clickRecordButton) forControlEvents:(UIControlEventTouchUpInside)];
    _recordButton.btnameLabel.text  =@"开始录音";
    [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_n"] forState:(UIControlStateNormal)];
    [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_s"] forState:(UIControlStateHighlighted)];

    
   
    PCDRecordButtonView *finishButton = [[PCDRecordButtonView alloc] initWithFrame:CGRectMake(indexWidth*2, indexY, indexWidth, 100)];
    [valueView addSubview:finishButton];
    finishButton.backgroundColor = [UIColor whiteColor];
    [finishButton.imageButton addTarget:self action:@selector(takeFinish) forControlEvents:(UIControlEventTouchUpInside)];
    finishButton.btnameLabel.text  =@"确定";
    [finishButton.imageButton setImage:[UIImage imageNamed:@"icon_record_finish_n"] forState:(UIControlStateNormal)];
    [finishButton.imageButton setImage:[UIImage imageNamed:@"icon_record_finish_s"] forState:(UIControlStateHighlighted)];
    if (![self initRecord]) {
       
        [PCDUtil showAlert:@"" message:@"创建录音失败"];
        [self removeFromSuperview];
    }
    
    CGAffineTransform newTransform =

    CGAffineTransformScale(valueView.transform, valueWid/maxWid, valueWid/maxWid);

    [valueView setTransform:newTransform];
    
    
}

-(void)takeClose{
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    if (recorder||[recorder isRecording]) {
        [recorder stop];
    }
    [self removeFromSuperview];
}
-(void)clickRecordButton{
    if (_timeCount > 0) {
        if ([recorder isRecording]) {
            //暂停
            [self pauseAction];
            _recordButton.btnameLabel.text = @"继续";
            if (_recordTimer) {
                [_recordTimer setFireDate:[NSDate distantFuture]];
            }
            [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_stop_n"] forState:(UIControlStateNormal)];
            [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_stop_s"] forState:(UIControlStateHighlighted)];
            
        }else{
            //继续
            _recordButton.btnameLabel.text = @"暂停";
            [self recordingAction];
//            _recordButton.btImgView.image = [UIImage imageNamed:@""];
            if (_recordTimer) {
            [_recordTimer setFireDate:[NSDate date]];
            }
            [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_n"] forState:(UIControlStateNormal)];
            [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_s"] forState:(UIControlStateHighlighted)];
        }
    }else{
        [self recordingAction];
        _recordButton.btnameLabel.text = @"暂停";
//        _recordButton.btImgView.image = [UIImage imageNamed:@""];
        [self.recordTimer fire];
        [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_n"] forState:(UIControlStateNormal)];
        [_recordButton.imageButton setImage:[UIImage imageNamed:@"icon_record_start_s"] forState:(UIControlStateHighlighted)];
        
    }
}

//计算录音时间
-(void)calcuRecordTimeResu{
    if (_timeCount >= _recordTime) {
        //超过录音时间
        [self stopAction];
        _recordButton.hidden = YES;
        if (_recordTimer) {
            [_recordTimer invalidate];
            _recordTimer = nil;
        }

        return;
    }
    _timeCount ++ ;
    _timeLabel.text = [self dealTimeValue];
    NSLog(@"🐦🐦🐦🐦🐦🐦🐦🐦🐦🐦%ld",_timeCount);
}
//时间处理
-(NSString *)dealTimeValue{
    NSString *timeStr = @"00:00";
    
//    int houStr = (int)_timeCount/3600;
    int minutes = (_timeCount / 60) % 60;
    int miaos = _timeCount % 60;
    timeStr = [NSString stringWithFormat:@"%02d:%02d", minutes, miaos];
    return timeStr;
}
-(void)takeFinish{
    //完成
    if (_recordTime <=0) {
//        [MBProgressHUD showError:@"未录音"];
        [PCDUtil showAlert:@"" message:@"未录音"];
        return;
    }
    if (recorder || [recorder isRecording]) {
        [recorder stop];
    }
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
    _audioTimeCount = _timeCount;
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      
        if (weakSelf.recordBlock) {
//            [MBProgressHUD showMessage:@"正在处理..."];
            [weakSelf createMp3Folder];
            
            if (![weakSelf audioPCMtoMP3:weakSelf.cafPath andMP3FilePath:weakSelf.mp3Path]) {
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"文件转换失败"];
                [PCDUtil showAlert:@"" message:@"文件转换失败"];
                return;
            }
            NSData *videoData = [NSData dataWithContentsOfFile:weakSelf.mp3Path];
            NSString *imageID;

                imageID = [NSString stringWithFormat:@"%@.mp3",[PCDUtil md5StringWithData:videoData]];

            NSString *locationPath = [NSString stringWithFormat:@"%@/%@",PackageSericePath,PCDCacheAudio];

            NSString *filePath = [locationPath stringByAppendingPathComponent:imageID];
            if (![PCDFile fileExistsAtPath:locationPath]) {
                [PCDFile createDirectoryAtPath:locationPath];
            }

            [videoData writeToFile:filePath atomically:YES];
            NSString *tempFilePath = PcdCacheAudioPath(imageID);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.recordBlock(@{@"audioId":tempFilePath,@"audioTime":@(weakSelf.audioTimeCount)});
               // [MBProgressHUD hideHUD];
                [self takeClose];
            });
           
            
        }else{
            //[MBProgressHUD hideHUD];
        }
        
    });
    
}
//MP3转BASE64
- (NSString *)mp3ToBASE64{
    NSData *mp3Data = [NSData dataWithContentsOfFile:_mp3Path];
    NSString *encodedImageStr = [mp3Data base64EncodedStringWithOptions:0];
    NSLog(@"===Encoded image:\n%@", encodedImageStr);
    return encodedImageStr;
}
#pragma mark---------------------录音

/**
 开始录音
 */
- (void)recordingAction {
    [recorder record];
    if (!_recordTimer) {
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(calcuRecordTimeResu) userInfo:nil repeats:YES];
    }
}
-(BOOL)initRecord{
    [self clearCafFile];
    NSLog(@"开始录音");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];

    //录音设置
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    //录音格式
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];
    //通道数
    [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    [recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];

    NSError *error = nil;
    // 沙盒目录Documents地址
    NSString *recordUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // caf文件路径
    self.cafPath = [NSString stringWithFormat:@"%@/record_%@.wav",recordUrl,[PCDUtil getCurrentTime]];//[recordUrl stringByAppendingPathComponent:@"selfRecord.wav"];
    tmpUrl = [NSURL fileURLWithPath:_cafPath];//[NSURL URLWithString:self.cafPath]; 
    recorder = [[AVAudioRecorder alloc]initWithURL:tmpUrl settings:recordSettings error:&error];
    
    if (recorder) {
        //启动或者恢复记录的录音文件
        if ([recorder prepareToRecord] == YES) {
//            [recorder record];
            return YES;
        }
        return NO;
    }else {
        NSLog(@"录音创建失败");
        return NO;
    }
}
/**
 停止录音
 */
- (void)stopAction {
    
    NSLog(@"停止录音");
    //停止录音
    [recorder stop];
    
  
}
- (void)pauseAction {
    
    NSLog(@"停止录音");
    //停止录音
    [recorder pause];
    
  
}

/**
 创建Mp3保存路径文件夹
 */
- (void)createMp3Folder{
    NSString *pathStr = [NSString stringWithFormat:@"%@/%@_.mp3",MP3SaveFilePath,[PCDUtil getCurrentTime]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:pathStr];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir))
    {
        BOOL createFolderSuc = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(createFolderSuc){
            NSLog(@"创建Mp3保存路径成功");
           
        }
    }
    self.mp3Path = path;
}
/**
 下一次录音开始会清除上一次的Caf文件，这里不缓存录音源文件
 */
- (void)clearCafFile {
    if (self.cafPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:self.cafPath isDirectory:&isDir];
        if (isDirExist) {
            [fileManager removeItemAtPath:self.cafPath error:nil];
            NSLog(@"清除上一次的Caf文件");
        }
    }
}
#pragma mark - 转换PCM本地文件到MP3
//转编码为 mp3
- (BOOL)audioPCMtoMP3:(NSString *)cafFilePath andMP3FilePath:(NSString *)mp3FilePath
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil]) {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置

        if(pcm == NULL) {
            NSLog(@"file not found");
        } else {
            fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
            FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE*2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_in_samplerate(lame, 11025.0);
            lame_set_VBR(lame, vbr_default);
            lame_init_params(lame);
            
            do {
                read = fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                if (read == 0)
                    write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                
                fwrite(mp3_buffer, write, 1, mp3);
                
            } while (read != 0);
            
            lame_close(lame);
            fclose(mp3);
            fclose(pcm);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    @finally {
        NSLog(@"MP3生成成功");
        return YES;
    }
}
@end

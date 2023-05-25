//
//  WSViewController.m
//  LJTest
//
//  Created by Mrluoios on 05/25/2023.
//  Copyright (c) 2023 Mrluoios. All rights reserved.
//

#import "WSViewController.h"
#import <LJTest/PCDRecordView.h>
@interface WSViewController ()
    
@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
 [PCDRecordView takeMyTest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.h
//  ScanBLE
//
//  Created by Jonas Scharpf on 02.05.13.
//  Copyright (c) 2013 Jonas Scharpf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UITableView *myTableView;
    UIImageView *tableImage;
    NSMutableArray *foundDevices;
    int nowConnected;
    NSString *peripheralName;
    NSString *rssiValueString;
}

@property (nonatomic, strong) CBCentralManager *CM;
@property (nonatomic, strong) CBPeripheral *activePeripheral;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) UIImageView *tableImage;
@property (nonatomic, retain) NSMutableArray *foundDevices;
@property (retain, nonatomic) IBOutlet UILabel *receivedLabel;
@property (retain, nonatomic) IBOutlet UILabel *nowConnectedLabel;
@property (retain, nonatomic) IBOutlet UILabel *errorLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *rssiValueLabel;

- (IBAction)scanForDevicesButton:(id)sender;
- (IBAction)sendSomethingButton:(id)sender;
@end

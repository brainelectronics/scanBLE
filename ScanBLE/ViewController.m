//
//  ViewController.m
//  ScanBLE
//
//  Created by Jonas Scharpf on 02.05.13.
//  Copyright (c) 2013 Jonas Scharpf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CBPeripheralDelegate, CBPeripheralManagerDelegate>
{
    
}

@property (nonatomic, strong) CBMutableCharacteristic *transferCharacteristic;
@property (nonatomic, strong) CBPeripheralManager *periphalManager;

@end

@implementation ViewController

@synthesize activePeripheral;
@synthesize CM;
@synthesize myTableView;
@synthesize tableImage;
@synthesize foundDevices;
@synthesize receivedLabel;
@synthesize nowConnectedLabel;
@synthesize periphalManager;
@synthesize errorLabel;
@synthesize nameLabel;
@synthesize rssiValueLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    foundDevices = [[NSMutableArray alloc]init];
    
    CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    periphalManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    CGRect tablePosition = CGRectMake(0.0, 0.0, self.view.frame.size.width, 165.0);
    UITableView *discoveredBLEDevices = [[UITableView alloc] initWithFrame:tablePosition style:UITableViewStylePlain];
    self.myTableView = discoveredBLEDevices;
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //CGRect button = CGRectMake(20.0, 110.0, 73.0, 43.0);
    [self.view addSubview:discoveredBLEDevices];
    
    [discoveredBLEDevices release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [errorLabel release];
    [nameLabel release];
    [rssiValueLabel release];
    [super dealloc];
    
    [receivedLabel release];
    [nowConnectedLabel release];
    [foundDevices release];
}

#pragma mark - Table View Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [foundDevices count];
    //return 10;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    //UIImage *btImage = [[UIImage imageNamed:@"Bluetooth-1.png"]autorelease];
    //UIImage	 *btImage = [[UIImage imageNamed:@"stop-32.png"]autorelease];
    
    UIImage	 *lostImage = [[UIImage imageNamed:@"stop-32.png"]autorelease];
    
	CGRect imageFrame = CGRectMake(2, 8, 40, 40);
	self.tableImage = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
	self.tableImage.image = lostImage;
	[cell.contentView addSubview:self.tableImage];
    /*
     CGRect imageFrame = CGRectMake(2, 8, 40, 40);
     tableImage = [[[UIImageView alloc] initWithFrame:imageFrame]autorelease];
     tableImage.image = btImage;
     [cell.contentView addSubview:tableImage];
     */
    CGRect nameFrame = CGRectMake(45, 7, 265, 20);
    UILabel *nameLabelTable = [[[UILabel alloc] initWithFrame:nameFrame] autorelease];
    nameLabelTable.numberOfLines = 2;
    nameLabelTable.font = [UIFont boldSystemFontOfSize:12];
    nameLabelTable.text = peripheralName;//[foundDevices objectAtIndex:indexPath.row];//deviceName;
    [cell.contentView addSubview:nameLabelTable];
    
    
    CGRect rssiFrame = CGRectMake(115.0, 7.0, 195.0, 20.0);
    UILabel *rssiLabelTable = [[[UILabel alloc] initWithFrame:rssiFrame] autorelease];
    rssiLabelTable.numberOfLines = 2;
    rssiLabelTable.font = [UIFont boldSystemFontOfSize:12];
    rssiLabelTable.text = rssiValueString;//@"Service Name";
    [cell.contentView addSubview:rssiLabelTable];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //connectedPeripheral = indexPath.row;
    //NSLog(@"did select row: %d", connectedPeripheral);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    nowConnected = indexPath.row;
    [CM connectPeripheral:[foundDevices objectAtIndex:nowConnected] options:nil];
    [CM stopScan];

    NSLog(@"Connect to Peripheral %@", [foundDevices objectAtIndex:indexPath.row]);
}


#pragma mark - Bluetooth

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self doesSupportLowEnergyCM];
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString] primary:YES];
    
    transferService.characteristics = @[self.transferCharacteristic];
    
    [self.periphalManager addService:transferService];
}

-(BOOL) doesSupportLowEnergyCM
{
    NSString *state = [[NSString alloc] init];
    
    switch ([CM state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"No support for Bluetooth 4.0";
            break;
            
        case CBCentralManagerStateUnauthorized:
            state = @"Not allowed to use Bluetooth";
            break;
            
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is off";
            break;
            
        case CBCentralManagerStatePoweredOn:
            return TRUE;
            
        case CBCentralManagerStateUnknown:
            state = @"Unknown state";
            return FALSE;
            
        default:
            return FALSE;
    }
    
    NSLog(@"Central manager state: %@", state);
    errorLabel.text = state;
    return FALSE;
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    [self doesSupportLowEnergyPM];
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString] primary:YES];
    
    transferService.characteristics = @[self.transferCharacteristic];
    
    [self.periphalManager addService:transferService];
}

-(BOOL) doesSupportLowEnergyPM
{
    NSString *state = [[NSString alloc] init];
    
    switch ([periphalManager state])
    {
        case CBPeripheralManagerStateUnsupported:
            state = @"No support for Bluetooth 4.0";
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            state = @"Not allowed to use Bluetooth";
            break;
            
        case CBPeripheralManagerStatePoweredOff:
            state = @"Bluetooth is off";
            break;
            
        case CBPeripheralManagerStatePoweredOn:
            return TRUE;
            
        case CBPeripheralManagerStateUnknown:
            state = @"Unknown state";
            return FALSE;
            
        default:
            return FALSE;
    }
    
    NSLog(@"Peripheral manager state: %@", state);
    
    return FALSE;
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Received peripheral: %@", peripheral);
    NSLog(@"Peripheral Name: %@", peripheral.name);
    NSLog(@"Ad data: %@", advertisementData);
    NSLog(@"RSSI Value %d", RSSI.integerValue);
    
    peripheralName = peripheral.name;
    rssiValueString = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%d",RSSI.integerValue]];
    nameLabel.text = peripheralName;
    rssiValueLabel.text = rssiValueString;
    
    if (![self.foundDevices containsObject:peripheral])
    {
        [foundDevices addObject:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to %@", peripheral);
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected from %@ with error %@",peripheral, error);
    
    UIAlertView *bleDisconnected = [[UIAlertView alloc]initWithTitle:@"Got disconnected" message:@"The connected device has been disconnected or is out of range" delegate:nil cancelButtonTitle:@"Shit" otherButtonTitles: nil];
    [bleDisconnected show]; //Zeigt den UIAlert
    
    [CM scanForPeripheralsWithServices:nil options:nil];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Received Data: %@",characteristic.value);
    NSLog(@"As UTF8 string: %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
    
    receivedLabel.text = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSLog(@"As ASCII: %@", [[NSString alloc]initWithData:characteristic.value encoding:NSASCIIStringEncoding]);
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    /*
    NSArray *characteristics	= [service characteristics];
    CBCharacteristic *characteristic;
    
    for (characteristic in characteristics)
    {
        NSLog(@"Discovered characteristic %@", [characteristic UUID]);
		if ([[characteristic UUID] isEqual:minimumTemperatureUUID]) { // Min Temperature.
            NSLog(@"Discovered Minimum Alarm Characteristic");
			minTemperatureCharacteristic = [characteristic retain];
			[peripheral readValueForCharacteristic:characteristic];
		}
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]])
        {
            NSLog(@"Generic Access Profile");
            sendc= [characteristic retain];
			[peripheral readValueForCharacteristic:characteristic];
		}
    }
     */
}
- (IBAction)scanForDevicesButton:(id)sender
{
    [CM scanForPeripheralsWithServices:nil options:nil];
    NSLog(@"Scaning...");
}

- (IBAction)sendSomethingButton:(id)sender
{
    NSString *stringToSend = @"Hello";
    NSData *data = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
    [[foundDevices objectAtIndex:nowConnected] updateValue:data forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
    //[self.periphalManager updateValue:data forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
}
@end

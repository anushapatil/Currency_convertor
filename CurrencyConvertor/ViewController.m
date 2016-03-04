//
//  ViewController.m
//  CurrencyConvertor
//
//  Created by Anusha Patil on 27/02/16.
//  Copyright © 2016 Anusha Patil. All rights reserved.
//

#import "ViewController.h"
#import "DataModel.h"
#import "ServiceHandler.h"
#import "Constants.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, ServiceHandlerDelegate>
{
    NSMutableArray *tableDataArray;
    NSString *currencyCode;
    NSString *anotherCurrencyCode;
    ServiceHandler *serviceHandler;
    NSInteger enteredValue;
    NSString *currencySymbol;
    NSString *anotherCurrencySymbol;
}
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UITableView *dropDownTableView;
@property (weak, nonatomic) IBOutlet UITableView *anotherDropDownTableView;

@property (weak, nonatomic) IBOutlet UIButton *dropDownOneButton;
@property (weak, nonatomic) IBOutlet UIButton *dropDownTwoButton;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

- (IBAction)fromTextFieldBeginEditing:(id)sender;
- (IBAction)toTextFieldBeginEditing:(id)sender;
- (IBAction)showCurrencyListDropDownOne:(id)sender;
- (IBAction)showCurrencyListDropDownTwo:(id)sender;
- (IBAction)didClickOnCurrencyConvertButton:(id)sender;
- (IBAction)textFiledTouchUpInsideAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self customIntialization];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Intialization

- (void)customIntialization
{
    //Set view background images
    [self.view setBackgroundColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:BGImage_Name]] colorWithAlphaComponent:0.8]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnView:)];
    tapGesture.numberOfTapsRequired = 1;
    [_holderView addGestureRecognizer:tapGesture];
    
    [_dropDownTableView setSeparatorColor:[UIColor grayColor]];
    currencyCode = Currency_Code;
    anotherCurrencyCode = Currency_Another_Code;
    [self formTableViewDataFromPlist];
}

- (void)formTableViewDataFromPlist
{
    tableDataArray = [[NSMutableArray alloc] init];
    
    //Read data from plist for Table view
    NSMutableArray *plistData = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:Currency_Plist_Name ofType:nil]];
    
    for (NSDictionary *dict in plistData)
    {
        NSArray *key = [dict allKeys];
        NSArray *value = [dict allValues];
        DataModel *dataModel = [[DataModel alloc] init];
        dataModel.currencyCode = [key firstObject];
        dataModel.currencyName = [value firstObject];
        [tableDataArray addObject:dataModel];
    }
}

- (void)dropDownFramingOfDropDownButton:(UIButton *)button andTableView:(UITableView *)tableView
{
    CGPoint origin = [self.view convertPoint:button.frame.origin fromView:button.superview];
    if (!button.selected)
    {
        tableView.hidden = YES;
    }
    else
    {
        [_holderView bringSubviewToFront:tableView];
        [self.view bringSubviewToFront:tableView];
        tableView.hidden = NO;
        tableView.frame = CGRectMake(origin.x, origin.y+CGRectGetHeight(button.frame), CGRectGetWidth(button.frame), CGRectGetHeight(self.view.frame)-origin.y-50);
    }
}

- (void)resetDropDowns
{
    _dropDownOneButton.selected = _dropDownTwoButton.selected = !_dropDownOneButton.selected;
    _dropDownTableView.hidden = _anotherDropDownTableView.hidden = YES;
}

#pragma mark Orientation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self resetDropDowns];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark Gesture Methods

- (void)singleTapOnView:(UITapGestureRecognizer *)tapGesture
{
    [self resetDropDowns];
}

#pragma mark TableView DataSource and Delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DropDownCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    DataModel *data = [tableDataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = data.currencyName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Reset text fields
    _fromTextField.text = _toTextField.text = @"";
    
    DataModel *data = [tableDataArray objectAtIndex:indexPath.row];
    if (_dropDownOneButton.selected)
    {
        [_dropDownOneButton setTitle:data.currencyName forState:UIControlStateNormal];
        currencyCode = data.currencyCode;
    }
    else if (_dropDownTwoButton.selected)
    {
        [_dropDownTwoButton setTitle:data.currencyName forState:UIControlStateNormal];
        anotherCurrencyCode = data.currencyCode;
    }
    [self resetDropDowns];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did deselect row at index path had called");
}

#pragma mark Action Methods

- (IBAction)showCurrencyListDropDownOne:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.dropDownTableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.anotherDropDownTableView.hidden = YES;
    [self dropDownFramingOfDropDownButton:sender andTableView:self.dropDownTableView];
}

- (IBAction)showCurrencyListDropDownTwo:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.dropDownTableView.hidden = YES;
    self.anotherDropDownTableView.translatesAutoresizingMaskIntoConstraints = YES;

    [self dropDownFramingOfDropDownButton:sender andTableView:self.anotherDropDownTableView];
}

- (IBAction)didClickOnCurrencyConvertButton:(id)sender
{
    [self resetDropDowns];
    
    self.displayLabel.text = @"";
    //Call service handler to get the converted values
    serviceHandler = [ServiceHandler sharedManager];
    serviceHandler.delegate = self;
    
    //REST METHODS
    /*[serviceHandler formGETRequestWithFromCurrency:currencyCode ToCurrency:anotherCurrencyCode];
    [serviceHandler formPOSTRequestWithFromCurrency:currencyCode ToCurrency:anotherCurrencyCode];*/
    
    //SOAP METHODS
    [serviceHandler workingWithSOAPServicesFromCurrency:currencyCode toCurrency:anotherCurrencyCode];
    
    
    [_fromTextField endEditing:YES];
    [_fromTextField resignFirstResponder];
}


#pragma mark TextField Delagte methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //Check the entered text is numeric value or not
    NSScanner *scanner = [NSScanner scannerWithString:newString];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    
    if (isNumeric)
    {
        enteredValue = [newString integerValue];
    }
    return YES;
}

- (IBAction)textFiledTouchUpInsideAction:(UITextField *)sender
{
    //Check the entered text is numeric value or not
    NSScanner *scanner = [NSScanner scannerWithString:sender.text];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    
    if (isNumeric)
    {
        enteredValue = [sender.text integerValue];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!!" message:@"Please enter valid number." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"Text field ended editing");
}

- (IBAction)fromTextFieldBeginEditing:(id)sender
{
    
}

- (IBAction)toTextFieldBeginEditing:(id)sender
{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self resetDropDowns];
    _fromTextField.text = @"";
    _toTextField.text = @"";
    return YES;
}

#pragma mark Response Handler

- (void)handlerResponseDictForRest:(NSDictionary *)jsonDict
{
    NSString *errorString = [jsonDict valueForKey:@"error"];
    if (errorString != nil)
    {
        //Show alert in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        });
        
        return;
    }
    
    NSDictionary *dict = [jsonDict valueForKey:@"rates"];
    NSString *value = [dict valueForKey:[NSString stringWithFormat:@"%@",anotherCurrencyCode]];
    
    double finalValue = enteredValue*[value doubleValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _toTextField.text = [NSString stringWithFormat:@"%@%f",[self currencySymbolsOfCurrencyCode:anotherCurrencyCode],finalValue];
        
        _fromTextField.text = [NSString stringWithFormat:@"%@%ld",[self currencySymbolsOfCurrencyCode:currencyCode],(long)enteredValue];
        
        self.displayLabel.text = [NSString stringWithFormat:@"%ld %@ equals %f %@",(long)enteredValue,_dropDownOneButton.titleLabel.text,finalValue,_dropDownTwoButton.titleLabel.text];
    });
   
}

- (void)handlerResponseXmlForSoap:(NSString *)xmlData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Found" message:@"Some SOAP data found" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
    });
    
    NSLog(@"some SOAP data found %@",xmlData);
}

#pragma mark

- (NSString *)currencySymbolsOfCurrencyCode:(NSString *)curCode
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:curCode];
    NSString *currencySymbol1 = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:curCode]];
    return currencySymbol1;
}

@end

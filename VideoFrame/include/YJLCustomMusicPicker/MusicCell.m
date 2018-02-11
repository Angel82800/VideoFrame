//
//  MusicCell.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MusicCell.h"

@implementation MusicCell

@synthesize nameTextField;
@synthesize originalName = _originalName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Initialization code
        
        self.nameTextField = [[UITextField alloc] initWithFrame:self.textLabel.frame];
        [self.nameTextField setBackgroundColor:[UIColor clearColor]];
        [self.nameTextField setTextColor:[UIColor blackColor]];
        [self.nameTextField setTextAlignment:NSTextAlignmentLeft];
        self.nameTextField.delegate = self;
        [self addSubview:self.nameTextField];
        
        self.nameTextField.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.0f];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];

    NSString *oldName = [folderPath stringByAppendingPathComponent:self.originalName];
    oldName = [NSString stringWithFormat:@"%@.m4a", oldName];
    
    NSString *changeName = [folderPath stringByAppendingPathComponent:textField.text];
    changeName = [NSString stringWithFormat:@"%@.m4a", changeName];
    
    if (rename([oldName fileSystemRepresentation], [changeName fileSystemRepresentation]) == -1)
    {
        [textField setText:oldName];
        
        NSString* errorMessage = [NSString stringWithFormat:@"A music \"%@\" is exist already! Please set another new name.", textField.text];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
        [alert show];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(changedMusicName)])
        {
            [self.delegate changedMusicName];
        }
    }

    [self.textLabel setText:textField.text];
}

@end

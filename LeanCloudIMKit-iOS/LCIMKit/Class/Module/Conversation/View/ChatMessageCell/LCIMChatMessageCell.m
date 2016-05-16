//
//  LCIMChatMessageCell.m
//  LCIMChatExample
//
//  Created by ElonChan ( https://github.com/leancloud/LeanCloudIMKit-iOS ) on 15/11/13.
//  Copyright © 2015年 https://LeanCloud.cn . All rights reserved.
//

#import "LCIMChatMessageCell.h"

#import "LCIMChatTextMessageCell.h"
#import "LCIMChatImageMessageCell.h"
#import "LCIMChatVoiceMessageCell.h"
#import "LCIMChatSystemMessageCell.h"
#import "LCIMChatLocationMessageCell.h"

#import "Masonry.h"
#import <objc/runtime.h>
#import "LCIMBubbleImageFactory.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "LCIMKit.h"
#import "UIImageView+CornerRadius.h"

static CGFloat const kAvatarImageViewWidth = 50.f;
static CGFloat const kAvatarImageViewHeight = 50.f;

@interface LCIMChatMessageCell ()

@property (nonatomic, strong, readwrite) LCIMMessage *message;

@end

@implementation LCIMChatMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - Override Methods


- (void)updateConstraints {
    [super updateConstraints];
    if (self.messageOwner == LCIMMessageOwnerSystem || self.messageOwner == LCIMMessageOwnerUnknown) {
        return;
    }
    if (self.messageOwner == LCIMMessageOwnerSelf) {
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).with.offset(-16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@(kAvatarImageViewWidth));
            make.height.equalTo(@(kAvatarImageViewHeight));
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top);
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == LCIMConversationTypeGroup ? @16 : @0);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.avatarImageView.mas_left).with.offset(-16);
            make.top.equalTo(self.nicknameLabel.mas_bottom).with.offset(4);
            make.width.lessThanOrEqualTo(@LCIMMessageCellLimit).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageContentView.mas_left).with.offset(-8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    } else if (self.messageOwner == LCIMMessageOwnerOther){
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).with.offset(16);
            make.top.equalTo(self.contentView.mas_top).with.offset(16);
            make.width.equalTo(@(kAvatarImageViewWidth));
            make.height.equalTo(@(kAvatarImageViewHeight));
        }];
        
        [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top);
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(16);
            make.width.mas_lessThanOrEqualTo(@120);
            make.height.equalTo(self.messageChatType == LCIMConversationTypeGroup ? @16 : @0);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(16);
            make.top.equalTo(self.nicknameLabel.mas_bottom).with.offset(4);
            make.width.lessThanOrEqualTo(@LCIMMessageCellLimit).priorityHigh();
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-16).priorityLow();
        }];
        
        [self.messageSendStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [self.messageReadStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageContentView.mas_right).with.offset(8);
            make.centerY.equalTo(self.messageContentView.mas_centerY);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
    }
    [self.messageContentBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.messageContentView);
    }];
    
    if (self.messageChatType == LCIMConversationTypeSingle) {
        [self.nicknameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0);
        }];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint = [[touches anyObject] locationInView:self.contentView];
    if (CGRectContainsPoint(self.messageContentView.frame, touchPoint)) {
        self.messageContentBackgroundImageView.highlighted = YES;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.messageContentBackgroundImageView.highlighted = NO;
}


#pragma mark - Private Methods

- (void)setup {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nicknameLabel];
    [self.contentView addSubview:self.messageContentView];
    [self.contentView addSubview:self.messageReadStateImageView];
    [self.contentView addSubview:self.messageSendStateImageView];
    
    self.messageSendStateImageView.hidden = YES;
    self.messageReadStateImageView.hidden = YES;
    
    [self.messageContentBackgroundImageView setImage:[LCIMBubbleImageFactory bubbleImageViewForType:self.messageOwner isHighlighted:NO]];
    [self.messageContentBackgroundImageView setHighlightedImage:[LCIMBubbleImageFactory bubbleImageViewForType:self.messageOwner isHighlighted:YES]];
    
    self.messageContentView.layer.mask.contents = (__bridge id _Nullable)(self.messageContentBackgroundImageView.image.CGImage);
    [self.contentView insertSubview:self.messageContentBackgroundImageView belowSubview:self.messageContentView];
    
    [self updateConstraintsIfNeeded];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.contentView addGestureRecognizer:tap];
    
}

#pragma mark - Public Methods

- (void)configureCellWithData:(LCIMMessage *)message {
    self.message = message;
    self.nicknameLabel.text = self.message.sender;
    [self.avatarImageView sd_setImageWithURL:self.message.avatorURL
                            placeholderImage:({
        NSString *imageName = @"Placeholder_Avator";
        NSString *imageNameWithBundlePath = [NSString stringWithFormat:@"Placeholder.bundle/%@", imageName];
        UIImage *image = [UIImage imageNamed:imageNameWithBundlePath];
        image;})
     ];
    if (message.messageReadState) {
        self.messageReadState = self.message.messageReadState;
    }
    self.messageSendState = self.message.status;
}

#pragma mark - Private Methods

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [tap locationInView:self.contentView];
        if (CGRectContainsPoint(self.messageContentView.frame, tapPoint)) {
            [self.delegate messageCellTappedMessage:self];
        }  else if (CGRectContainsPoint(self.avatarImageView.frame, tapPoint)) {
            [self.delegate messageCellTappedHead:self];
        } else {
            [self.delegate messageCellTappedBlank:self];
        }
    }
}

#pragma mark - Setters

- (void)setMessageSendState:(LCIMMessageSendState)messageSendState {
    _messageSendState = messageSendState;
    if (self.messageOwner == LCIMMessageOwnerOther) {
        self.messageSendStateImageView.hidden = YES;
    }
    self.messageSendStateImageView.messageSendState = messageSendState;
}

- (void)setMessageReadState:(LCIMMessageReadState)messageReadState {
    _messageReadState = messageReadState;
    if (self.messageOwner == LCIMMessageOwnerSelf) {
        self.messageSendStateImageView.hidden = YES;
    }
    switch (_messageReadState) {
            case LCIMMessageUnRead:
            self.messageReadStateImageView.hidden = NO;
            break;
        default:
            self.messageReadStateImageView.hidden = YES;
            break;
    }
}

#pragma mark - Getters

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        LCIMAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock = [LCIMKit sharedInstance].avatarImageViewCornerRadiusBlock;
        if (avatarImageViewCornerRadiusBlock) {
            CGSize avatarImageViewSize = CGSizeMake(kAvatarImageViewWidth, kAvatarImageViewHeight);
            CGFloat avatarImageViewCornerRadius = avatarImageViewCornerRadiusBlock(avatarImageViewSize);
            [_avatarImageView zy_cornerRadiusAdvance:avatarImageViewCornerRadius rectCornerType:UIRectCornerAllCorners];
        }
        [self bringSubviewToFront:_avatarImageView];
    }
    return _avatarImageView;
}

- (UILabel *)nicknameLabel {
    if (!_nicknameLabel) {
        _nicknameLabel = [[UILabel alloc] init];
        _nicknameLabel.font = [UIFont systemFontOfSize:12.0f];
        _nicknameLabel.textColor = [UIColor blackColor];
        _nicknameLabel.text = @"nickname";
    }
    return _nicknameLabel;
}

- (LCIMContentView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[LCIMContentView alloc] init];
    }
    return _messageContentView;
}

- (UIImageView *)messageReadStateImageView {
    if (!_messageReadStateImageView) {
        _messageReadStateImageView = [[UIImageView alloc] init];
    }
    return _messageReadStateImageView;
}

- (LCIMSendImageView *)messageSendStateImageView {
    if (!_messageSendStateImageView) {
        _messageSendStateImageView = [[LCIMSendImageView alloc] init];
    }
    return _messageSendStateImageView;
}

- (UIImageView *)messageContentBackgroundImageView {
    if (!_messageContentBackgroundImageView) {
        _messageContentBackgroundImageView = [[UIImageView alloc] init];
    }
    return _messageContentBackgroundImageView;
}

- (LCIMMessageType)messageType {
    if ([self isKindOfClass:[LCIMChatTextMessageCell class]]) {
        return LCIMMessageTypeText;
    } else if ([self isKindOfClass:[LCIMChatImageMessageCell class]]) {
        return LCIMMessageTypeImage;
    } else if ([self isKindOfClass:[LCIMChatVoiceMessageCell class]]) {
        return LCIMMessageTypeVoice;
    } else if ([self isKindOfClass:[LCIMChatLocationMessageCell class]]) {
        return LCIMMessageTypeLocation;
    } else if ([self isKindOfClass:[LCIMChatSystemMessageCell class]]) {
        return LCIMMessageTypeSystem;
    }
    return LCIMMessageTypeUnknow;
}

- (LCIMConversationType)messageChatType {
    if ([self.reuseIdentifier containsString:@"GroupCell"]) {
        return LCIMConversationTypeGroup;
    }
    return LCIMConversationTypeSingle;
}

- (LCIMMessageOwner)messageOwner {
    if ([self.reuseIdentifier containsString:@"OwnerSelf"]) {
        return LCIMMessageOwnerSelf;
    } else if ([self.reuseIdentifier containsString:@"OwnerOther"]) {
        return LCIMMessageOwnerOther;
    } else if ([self.reuseIdentifier containsString:@"OwnerSystem"]) {
        return LCIMMessageOwnerSystem;
    }
    return LCIMMessageOwnerUnknown;
}

@end

#pragma mark - LCIMChatMessageCellMenuActionCategory

NSString * const kLCIMChatMessageCellMenuControllerKey;

@interface LCIMChatMessageCell (LCIMChatMessageCellMenuAction)

@property (nonatomic, strong, readonly) UIMenuController *menuController;

@end

@implementation LCIMChatMessageCell (LCIMChatMessageCellMenuAction)

#pragma mark - Private Methods

//以下两个方法必须有
/*
 *  让UIView成为第一responser
 */
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/*
 *  根据action,判断UIMenuController是否显示对应aciton的title
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(menuRelayAction) || action == @selector(menuCopyAction)) {
        return YES;
    }
    return NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGes {
    if (longPressGes.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressPoint = [longPressGes locationInView:self.contentView];
        if (!CGRectContainsPoint(self.messageContentView.frame, longPressPoint)) {
            return;
        }
        [self becomeFirstResponder];
        //TODO:
        //!!!此处使用self.superview.superview 获得到cell所在的tableView,不是很严谨,有哪位知道更加好的方法请告知
        CGRect targetRect = [self convertRect:self.messageContentView.frame toView:self.superview.superview];
        [self.menuController setTargetRect:targetRect inView:self.superview.superview];
        [self.menuController setMenuVisible:YES animated:YES];
    }
}

//TODO:
- (void)menuCopyAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:withActionType:)]) {
        [self.delegate messageCell:self withActionType:kLCIMChatMessageCellMenuControllerKey];
    }
}

- (void)menuRelayAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:withActionType:)]) {
        [self.delegate messageCell:self withActionType:kLCIMChatMessageCellMenuControllerKey];
    }
}

#pragma mark - Getters

- (UIMenuController *)menuController{
    UIMenuController *menuController = objc_getAssociatedObject(self,&kLCIMChatMessageCellMenuControllerKey);
    if (!menuController) {
        menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopyAction)];
        UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(menuRelayAction)];
        if (self.messageType == LCIMMessageTypeText) {
            [menuController setMenuItems:@[copyItem,shareItem]];
        } else{
            [menuController setMenuItems:@[shareItem]];
        }
        [menuController setArrowDirection:UIMenuControllerArrowDown];
        objc_setAssociatedObject(self, &kLCIMChatMessageCellMenuControllerKey, menuController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return menuController;
}

@end

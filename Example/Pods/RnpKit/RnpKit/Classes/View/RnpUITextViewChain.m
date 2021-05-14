//
//  RnpUITextViewChain.m
//  RnpKit
//
//  Created by Zomfice on 2019/7/31.
//

#import "RnpUITextViewChain.h"
#import <objc/runtime.h>

#define RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(RPMethod,RPParaType) RPCATEGORY_CHAIN_VIEWCLASS_IMPLEMENTATION(RPMethod,RPParaType, RnpUITextViewChain *,UITextView)
@implementation RnpUITextViewChain
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(delegate, id<UITextViewDelegate>);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(text, NSString *);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(font, UIFont *);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(textColor, UIColor *);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(textAlignment, NSTextAlignment);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(selectedRange, NSRange);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(editable, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(selectable, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(dataDetectorTypes, UIDataDetectorTypes);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(keyboardType, UIKeyboardType);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(allowsEditingTextAttributes, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(attributedText, NSAttributedString *);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(typingAttributes, NSDictionary *);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(clearsOnInsertion, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(textContainerInset, UIEdgeInsets);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(linkTextAttributes, NSDictionary *);
#pragma mark - UITextInputTraits -
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(autocapitalizationType, UITextAutocapitalizationType);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(autocorrectionType, UITextAutocorrectionType)
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(spellCheckingType, UITextSpellCheckingType)

RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(keyboardAppearance, UIKeyboardAppearance);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(returnKeyType, UIReturnKeyType);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(enablesReturnKeyAutomatically, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(secureTextEntry, BOOL);
RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION(textContentType, UITextContentType);
@end
RPCATEGORY_VIEW_IMPLEMENTATION(UITextView, RnpUITextViewChain)

#undef RPCATEGORY_CHAIN_TEXT_IMPLEMENTATION
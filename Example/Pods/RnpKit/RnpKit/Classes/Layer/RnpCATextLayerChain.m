//
//  RnpCATextLayerChain.m
//  RnpKit
//
//  Created by Zomfice on 2019/8/2.
//

#import "RnpCATextLayerChain.h"
#define RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(RPMethod,RPParaType) RPCATEGORY_CHAIN_LAYERCLASS_IMPLEMENTATION(RPMethod,RPParaType, RnpCATextLayerChain *, CATextLayer)

@implementation RnpCATextLayerChain

RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(string, id)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(font, CFTypeRef)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(fontSize, CGFloat)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(foregroundColor, CGColorRef)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(wrapped, BOOL)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(truncationMode, CATextLayerTruncationMode)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(alignmentMode, CATextLayerAlignmentMode)
RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION(allowsFontSubpixelQuantization, BOOL)

@end
RPCATEGORY_LAYER_IMPLEMENTATION(CATextLayer, RnpCATextLayerChain)
#undef RPCATEGORY_CHAIN_TEXTLAYER_IMPLEMENTATION
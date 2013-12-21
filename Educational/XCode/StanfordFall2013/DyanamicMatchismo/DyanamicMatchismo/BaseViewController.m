//
//  BaseViewController.m
//  DyanamicMatchismo
//
//  Created by Ethan Petuchowski on 12/19/13.
//  Copyright (c) 2013 Ethan Petuchowski. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (Deck *)createDeck
{
    return [[Deck alloc] init];
}

- (Grid *)grid
{
    if (!_grid) _grid = [[Grid alloc] init];
    return _grid;
}

- (void)restartGame
{
    self.game = nil;
    [self updateUI];
}


- (IBAction)touchRedealButton:(UIButton *)sender {
    [self restartGame];
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    [self updateUI];
}

- (void)updateUI
{

    // count cards in play
    int numCardsInPlay = 0;
    for (Card *card in self.game.cards) {
        if (!card.chosen) {
            numCardsInPlay++;
        }
    }
    
    CGFloat height = self.layoutContainerView.bounds.size.height;
    CGFloat width  = self.layoutContainerView.bounds.size.width;
    [_grid setCellAspectRatio:height/width];
    [_grid setSize:CGSizeMake(height, width)];
    [_grid setMinimumNumberOfCells:numCardsInPlay];

    
// ============================ THE OLD METHOD =============================
//    for (UIButton *cardButton in self.cardButtons) {
//        int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
//        Card *card = [self.game cardAtIndex:cardButtonIndex];
//        [cardButton setTitle:[self titleForCard:card]
//                    forState:UIControlStateNormal];
//        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
//                              forState:UIControlStateNormal];
//        cardButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        cardButton.enabled = !card.isMatched;
//        self.scoreLabel.text =
//        [NSString stringWithFormat:@"Score: %d", self.game.score];
//    }
}

- (NSString *)titleForCard:(Card *)card
{
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
    return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}

@end

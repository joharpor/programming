//
//  BaseViewController.m
//  DyanamicMatchismo
//
//  Created by Ethan Petuchowski on 12/19/13.
//  Copyright (c) 2013 Ethan Petuchowski. All rights reserved.
//

#import "BaseViewController.h"
#import "CardView.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (NSMutableDictionary *)cardsInView
{
    if (!_cardsInView) _cardsInView = [[NSMutableDictionary alloc] init];
    return _cardsInView;
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

// makes cards appear on the screen when the game first starts up
- (void)viewDidLayoutSubviews
{
    [self updateUI];
}

- (IBAction)touchRedealButton:(UIButton *)sender {
    [self restartGame];
}

// Note: inheriting classes must specify the actual CardView they want to use
- (void)putCardInViewAtIndex:(int)index intoViewInRect:(CGRect)rect
{
    Card *card = self.game.cardsInPlay[index];
    [self.cardsInView setObject:[[CardView alloc]
                                 initWithFrame:rect withCard:card inContainer:self]
                         forKey:card.attributedContents];
}

- (void)redrawAllCards
{
    [[self.layoutContainerView subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat height = self.layoutContainerView.bounds.size.height;
    CGFloat width  = self.layoutContainerView.bounds.size.width;
    [self.grid setCellAspectRatio:width/height];
    [self.grid setSize:CGSizeMake(width, height)];
    [self.grid setMinimumNumberOfCells:[self.game.cardsInPlay count]];
    
    [[self.cardsInView allKeys]
     makeObjectsPerformSelector:@selector(animateCardRemoval:)];
    
    int cardsPlaced = 0;
    for (int row = 0; row < self.grid.rowCount; row++) {
        for (int col = 0; col < self.grid.columnCount; col++) {
            if (cardsPlaced < [self.game.cardsInPlay count]) {
                
                CGRect rect = [self.grid frameOfCellAtRow:row
                                                 inColumn:col];
                
                rect.size.height *= 0.9;
                rect.size.width  *= 0.9;
                
                [self putCardInViewAtIndex:cardsPlaced
                            intoViewInRect:rect];
                
                cardsPlaced++;
            }
            else break;
        }
    }
    
    [[self.cardsInView allKeys]
     makeObjectsPerformSelector:@selector(animateCardInsertion:)];
    
}

// TODO
- (void)animateCardInsertion:(NSString *)cardName
{
    
}

// TODO
- (void)animateCardRemoval:(NSString *)cardName
{
    
}

// TODO
- (void)animateChooseCard:(Card *)card
{
    
}

// TODO
- (void)removeCardFromView:(NSString *)cardName
{
    
}

- (void)addCardToView:(Card *)card
{
    // if there's space for the card in the grid,
    // find the first empty spot and stick it in there (animatedly)
    int gridCapacity = [self.grid columnCount] * [self.grid rowCount];
    if ([self.cardsInView count] + 1 > gridCapacity) {
        
    }
    
    // otw add the view to self.cardsInView and redrawAllCards()
}

- (void)updateUI
{
    // new game, or redeal
    if (!self.game)
        [self redrawAllCards];
    
    // if size changes across 9 in either direction,
    // move to new grid
    // (not sure this will work, but it sounds nice)
    if (([self.cardsInView count] > 9) != ([self.game.cardsInPlay count] > 9))
        [self redrawAllCards];

    
    /* 
     * UPDATE WHICH CARDS ARE ON THE SCREEN
     */
    
    NSMutableDictionary *viewDictCopy = [self.cardsInView mutableCopy];
    
    // add cards that are in play but not in view to view
    // un/choose cards that are in view but have the wrong "thinksItsChosen" status
    for (Card *card in self.game.cardsInPlay) {
        CardView *cardView = [self.cardsInView objectForKey:card.attributedContents];
        if (!cardView) {
            [self addCardToView:card];
        } else if (card.chosen != cardView.thinksItsChosen) {
            [self animateChooseCard:card];
        }
        [viewDictCopy removeObjectForKey:card.attributedContents];
    }
    
    // remove cards that have been removed for any reason (really just matched)
    for (NSString *cardName in viewDictCopy.allKeys) {
        [self removeCardFromView:cardName];
    }
    
    // update score
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

- (void)cardWasChosen:(Card *)card
{
    [self.game chooseCardAtIndex:[self.game.cards indexOfObject:card]];
    [self updateUI];
    
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

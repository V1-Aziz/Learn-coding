from art import logo
print(logo)
bid_is_going = True
# TODO-1: Ask the user for input
# TODO-2: Save data into dictionary {name: price}
# TODO-3: Whether if new bids need to be added
def find_highest_bidder(bidding_dictionary):
    winner = ""
    highest_bid = 0

    max(bidding_dictionary)

    for bidder in bidding_dictionary:
        bid_amount = bidding_dictionary[bidder]
        if bid_amount > highest_bid:
            highest_bid = bid_amount
            winner = bidder
    print(f"The winner is {winner} with a bis of ${highest_bid}")
bids = {}
while bid_is_going:
    name = input("Please enter your nane: ")
    bid = int(input("PLease enter you bid: $"))
    bids[name]=bid
    continue_bidding = input("Someone want to bid? type 'yes' to continue or 'no' to stop bidding\n").lower()
    if continue_bidding == "no":
        bid_is_going = False
        find_highest_bidder(bids)
    elif continue_bidding == "yes":
        print("\n"*30)
# TODO-4: Compare bids in dictionary

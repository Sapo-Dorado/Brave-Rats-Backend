# Rave Bats

[![codecov](https://codecov.io/gh/Sapo-Dorado/Rave-Bats-Backend/branch/main/graph/badge.svg?token=DRJWNIQ7UU)](https://codecov.io/gh/Sapo-Dorado/Rave-Bats-Backend)


## API Routes

Route | Request Type | Params | Description | Example Result
------|--------------|--------|-------------|-------------
/api/user | POST | **username** **password** | Creates a new user and returns its uuid | `{"uuid": "p8gh323c-23t2-4po8-9fb1-l6p12e9a125h"}`
/api/user | GET | **username** **password** | Returns the uuid of the desired user | `{"uuid": "p8gh323c-23t2-4po8-9fb1-l6p12e9a125h"}`
/api/games | GET | **user**(a players uuid) **opponent**(optional opponent username to filter results) | Returns a list of games that fit the parameters | `[a list of games]`
/api/completed | GET |  **user**(a players uuid) **opponent**(optional opponent username to filter results) | Returns a list of completed games that fit the parameters |`[a list of completed games]`
/api/game | GET | **id**(the game's id) **user**(optional player uuid) | Returns the game that corresponds the the game id. Hides card values except for ones played by the specified user | `{a game object}`
/api/games | POST | **user**(a players uuid) **opponent**(opponents username) | Creates a new game with the user and opponent and returns the game | `{a game object}`
/api/action | PATCH | **id**(the game's id) **user**(the user's uuid) **card**(the card being played by the user) | updates the game with the played card and returns the game | `{a game object}`

## The Game Object

```json
{
    "completed?":false,
    "game_id":"016p9p0d-fjl6-4p92-b94b-9d7906e4089b",
    "on_hold":[],
    "p1_card":null,
    "p1_cards":[0,1,2,3,4,5,6,7],
    "p1_general?":false,
    "p1_name":"Jorfe",
    "p1_points":0,
    "p1_spy?":false,
    "p1_winnings":[],
    "p2_card":false,
    "p2_cards":[0,1,2,3,4,5,6,7],
    "p2_general?":false,
    "p2_name":"test",
    "p2_points":0,
    "p2_spy?":false,
    "p2_winnings":[]
}
```
This assumes an understanding of the rules of Brave Rats https://blueorangegames.eu/wp-content/uploads/2018/05/BRAVERATS_rules_UK.pdf


Field | Description
------|------------
completed? | A boolean value that is true if the game is over and false otherwise
game_id | The game's id
on_hold | A list of the card pairs that are on hold
p1_card | The card played by player 1
p1_cards | The list of cards that player 1 has in their hand
p1_general? | A boolean indicating whether or not player 1 has the general effect in the current round
p1_name | The username of player 1
p1_points | The number of round win points player 1 has this game
p1_spy? | A boolean indicating whether or not player 1 has the spy effect in the current round
p1_winnings? | A list of the card pairs from rounds that player 1 has won
rest of p2 fields | see the descriptions of p1 fields

## Notes
* Cards are represented by an integer with the card's power.
* Card pairs are stored in the winnings fields and the on_hold field as an array of length 2 where the first element is the card played by p1 in that pair and the second element is the card played by p2.
* For the fields p1_card and p2_card, the field corresponding to the user whose uuid was in the request will be the card value being played or nil if no card has been played. For the other player the field will be false if no card has been played and true if a card has been played this turn.
* If no user is specified in the request both p1_card and p2_card will be booleans

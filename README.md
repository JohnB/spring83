# Spring83 & Other Projects

While this started out as an attempt at a Spring83 serbver,
my forced shift from Heroku to Fly.io has allowed me to move
existing projects (usually just a few main files) to migrate here.

## Street Food
Available at [/street_food](https://spring-83.fly.dev/street_food)
with SF food-truck data for an interview question.

**NOTE**: Data is from a [static file](https://data.sfgov.org/resource/rqzj-sfat.json)
downloaded 10/3/2022 and likely won't be updated in a timely manner.

### Roadmap
(not necessarily in implementation order)
- [x] Load the JSON data during compilation.
- [x] List N food trucks.
- [x] List N _nearest_ food trucks.
- [x] Prep a map centered on Union Square.
- [x] Show food trucks on map.
- [ ] Add tests
- [ ] Periodically (weekly?) fetch and cache the JSON file.

## Pizza Bot
Now at [/pizza](https://spring-83.fly.dev/pizza) (but slow 
because it scrapes the slow pizza page during the request cycle).

### Roadmap
- [ ] Switch FakeCron to [quantum](https://hexdocs.pm/quantum/readme.html)
- [ ] Cache the pizza data on server restart,
  for a faster [/pizza](https://spring-83.fly.dev/pizza) page load.
- [ ] Update previous repo(s) to point here.

## Kenken
Now at [/kenken](https://spring-83.fly.dev/kenken).

### Roadmap
- [ ] Fix refresh bug in the middle of trying to solve the puzzle.
- [ ] Verify at setup that all answers are filled and don't conflict.
- [ ] Track groupings within the puzzle.
- [ ] Make sure each grouping's result is valid (how?)
- [ ] When a cell has only 1 guess, gray out that guess elsewhere (10% opacity).
- [ ] When a cell has 2+ selected, slightly gray them elsewhere (40% opacity).

## Collaborative Canvas
Now at [/collaborative_canvas](https://spring-83.fly.dev/collaborative_canvas).

### Roadmap
- [ ] Replace CSS animation for just-placed pieces.

## Pentomino Game
Not yet moved over here from [phoenix_live_view_example](https://github.com/johnb/phoenix_live_view_example)

### Roadmap
- [ ] Move it over
- [ ] Make it work better
- [ ] Update previous repo(s) to point here.

## Spring83
Elixir attempt at implementing the 
[Spring83 Protocol](https://github.com/robinsloan/spring-83).
Found at [/boards](https://spring-83.fly.dev/boards).

### Example boards and clients:
* [My sad board](https://bogbody.biz/f1d76c53a050dafb9e1f10683bd274b0b4afbcc5afd5198748786fb8983e0123)
* [My client](https://spring-83.fly.dev/boards)
* [Robin's client](https://followersentinel.com/)
* [Someone else's client](https://spring83.kindrobot.ca/)

### Reading board data
The server will just return HTML unless one provides
the correct `Spring-Version: 83` header. Like this:

`curl -H "Spring-Version: 83" https://bogbody.biz/f1d76c53a050dafb9e1f10683bd274b0b4afbcc5afd5198748786fb8983e0123`

### Roadmap
(not necessarily in implementation order)
- [ ] Correctly parse/display a full SpringFile
- [ ] Correctly parse a board, rejecting invalid ones
- [ ] Improve board display
- [ ] Enable SpringFile editing
- [ ] Enable board editing
- [ ] Store SpringFile in the DB
- [ ] Store cached boards in the DB
- [ ] Periodically re-fetch cached boards
- [ ] Expire boards when necessary

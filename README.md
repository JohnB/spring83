# Spring83 and Other Projects

While this started out as an attempt at a Spring83 serbver,
my forced shift from Heroku to Fly.io has allowed me to move
existing projects (usually just a few main files) to migrate here.

## Todays_Pizza bot
Now at [/pizza](https://spring-83.fly.dev/pizza) (but slow 
because it scrapes the slow pizza page during the request cycle).

### Roadmap
- [ ] Switch FakeCron to [quantum](https://hexdocs.pm/quantum/readme.html)
- [ ] Cache the pizza data on server restart,
  for a faster [/pizza](https://spring-83.fly.dev/pizza) page load.
- [ ] Update previous repo(s) to point here.

## Collaborative Canvas
Now at [/collaborative_canvas](https://spring-83.fly.dev/collaborative_canvas).

### Roadmap
- [ ] Periodically persist the canvas to the DB,
  possibly every 100 clicks or maybe after 2 minutes of inactivity.
- [ ] Show the persisted canvases as an animation.
- [ ] After a restart, start from the latest DB canvas instead of _@default_canvas_.
- [ ] Update previous repo(s) to point here.

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

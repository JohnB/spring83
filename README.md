# Spring83

Elixir attempt at implementing the 
[Spring83 Protocol](https://github.com/robinsloan/spring-83)

## Example boards and clients:
* [My sad board](https://bogbody.biz/f1d76c53a050dafb9e1f10683bd274b0b4afbcc5afd5198748786fb8983e0123)
* [My client](https://spring-83.fly.dev/boards)
* [Robin's client](https://followersentinel.com/)
* [Someone else's client](https://spring83.kindrobot.ca/)

## Reading board data
The server will just return HTML unless one provides
the correct `Spring-Version: 83` header. Like this:

`curl -H "Spring-Version: 83" https://bogbody.biz/f1d76c53a050dafb9e1f10683bd274b0b4afbcc5afd5198748786fb8983e0123`

## Roadmap
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

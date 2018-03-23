# golf
Golf Leaderboard Tech Test

This was an overnight response to a tech test offered to me by a local development company. I rather liked their approach, in that it wasn't some abstract academic geeky cleverness or the 'current challenging issue at work' repackaged as a technical test...no this was good old real world.

The test was focussed on getting some data from a server and then displaying it on a screen (or two).

I decided just to make it as 'clean' as I could - in terms of size of functions, one purpose for each, clear deliniation between and a good split between view code, presenter code and interactors / business modesl and ultimately the core entities. This would make a good unit test candidate also.

I got a new project going, and decided to focus on the visual. A table of sorts. Knowing how I'd like to plumb the other data areas in.

Building this tech test I wanted to really show how I could 'model' the problem in a very logical way. This certainly wasn't proof of perfect encapsulation, or unit testing - but it was an exercise in constructing a solution for the outlined requirement.

I spent ~8 hours generating this app. As always there was a couple of pesky issues I faced, one with an added framework crashing the app and another with some weird access of an array thay always returned nil, despite there clearly being data within (the range).

I hope it is seen as a suitable response from the company as they seem very cool so far. As always, I look forward to hearing feedback, good or bad and learning from the experience.

-----

Sml Update: I was called back for another set of meetings. I wanted to review my code, be able to talk to it - and again hopefully learn something. On reviewing I found a circular reference (not good), and the API error report wasn't work fully. I rewrote that after reading AlamoFire docs and some examples. I also added some further dependecy injection, to better show the architechture.

And...I met with 3 different developers at the company and had chance to review the code. They had some great comments. One guy rightly pointed out my loose count of expected API calls returned could hit a problem (rarely) and suggested at least adding locks to that value count. After thinking about this - he's absolutely right of course. Rarely it could cause a hang at least... I would opt to build a small stack with keys to each API call made ust to ensure what goes out, does spefically come back. This stack would need locks too. This would also allow for retries etc.

-----

One bug was pointed out to me so I resolved by adding unit testing to Presenter class - but found no issue. I added tests to JSON parsing and then found and fixed the problem. Adding the dependecy injection allowed me to easily mock the ViewController class to get the output from the Presenter, although I had initially exposed the internal function in the protocol to allow for this I prefer the former.

Anyway a good test. You can see the code I created above. 1.0.3 is the version as of this ReadMe edit.

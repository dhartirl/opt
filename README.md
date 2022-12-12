# Optimus Grime

Travelling salesman style problem. Given a grid of size WxH and 1 or more points, find the most optimal path to reach and "clean" all points.

Output is in the format `NNCEECSSC`, where `NSEW` are directions and `C` indicates the "clean" action.

## Usage

```bash
./opt.rb [--debug] 12x12 "(3,3) (1,1) (6,6) (0,6) (6,0) (5,3) (2,1) (1,9) (11,10) (0,10) (11,4) (7,2) (6,4)"
```

This solution uses a heuristic approach. At each iteration we append each remaining point to our path.
We then sort the new paths by length and take the shortest 33% into the next iteration.

## Output

Regular output
```bash
dhart@Daves-MacBook-Pro opt % ./opt.rb 12x12 "(3,3) (1,1) (6,6) (0,6) (6,0) (5,3) (2,1) (1,9) (11,10) (0,10) (11,4) (7,2) (6,4)"
ENCECEEEESCENNCWWNCWWCWWWNNNCNNNNCESCEEEEESSSCSSCEEEEECNNNNNNC
```

Debug output
```bash
dhart@Daves-MacBook-Pro opt % ./opt.rb --debug 12x12 "(3,3) (1,1) (6,6) (0,6) (6,0) (5,3) (2,1) (1,9) (11,10) (0,10) (11,4) (7,2) (6,4)"
____________
X__________X
_X__________
____________
____________
X_____X_____
____________
______X____X
___X_X______
_______X____
_XX_________
O_____X_____
Generating paths...
Possible paths: 6,227,020,800
This may take a while...
Found 691,200 paths
Discarded 1,217,749 suboptimal branches
Shortest path: 62, Longest path: 120
Selected path: (0,0),(1,1),(2,1),(6,0),(7,2),(5,3),(3,3),(0,6),(0,10),(1,9),(6,6),(6,4),(11,4),(11,10)
There are 4 equivalent paths
ENCECEEEESCENNCWWNCWWCWWWNNNCNNNNCESCEEEEESSSCSSCEEEEECNNNNNNC
Steps: 62
Calculation took 27.26 seconds
```
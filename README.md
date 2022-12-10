# Optimus Grime

Travelling salesman style problem. Given a grid of size WxH and 1 or more points, find the most optimal path to reach and "clean" all points.

Output is in the format `NNCEECSSC`, where `NSEW` are directions and `C` indicates the "clean" action.

## Usage

```bash
./opt.rb [--debug] 12x12 "(3,3) (1,1) (6,6) (0,6) (6,0) (5,3) (2,1) (1,9) (11,10) (0,10) (11,4) (7,2) (6,4)"
```

This solution uses a heuristic approach. At each iteration we append each remaining point to our path.
We then sort the new paths by length and take the shortest 33% into the next iteration.
% Example 4 in Adam Wyner, Trevor J. M. Bench-Capon, Paul E. Dunne: On the Instantiation of Knowledge Bases in Abstract Argumentation Frameworks. CLIMA 2013: 34-50

head(r1, x1).

head(r2, x2).

head(r3, x3).

body(r4, x4).
body(r4, x5).
head(r4, neg(x3)).

def(r5).
body(r5, x1).
head(r5, x4).

def(r6).
body(r6, x2).
head(r6, x5).

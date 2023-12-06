# Advent of Code 2023 solutions

In case it wasn't obvious, the code in this repo will give away the solutions to this year's Advent of Code, so don't look if you haven't figured it out yet!

Most files provide a function `f` of type `(String) -> Int` or equivalent; other functions are just helpers. I typically obtain the solution by writing an entrypoint or top-level code like

```swift
print(f("""
... input goes here ...
"""))
```

Day 4 star 1 is written in [Trilangle](https://github.com/bbrk24/Trilangle), which doesn't have functions. Instead, that file is a full program that reads the input from stdin.

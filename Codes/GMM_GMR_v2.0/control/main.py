import os, sys
from compare import compare
from action import action

if __name__ == "__main__":
  ironhide = "10.26.210.60"
  action(ironhide, False, "wiping")
  diff = compare()
  print "compared difference: ", diff
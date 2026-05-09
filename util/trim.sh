#!/bin/bash

for F in *.wav
do
    sox --norm=-2 "${F}" "${F%.wav}.t.wav" trim 0s 9120000s
done
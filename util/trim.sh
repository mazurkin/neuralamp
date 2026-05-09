#!/bin/bash

for F in *.wav
do
    sox --norm=-1 "${F}" "${F%.wav}.t.wav" trim 0s 9120000s
done

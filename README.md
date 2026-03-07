# neural-amp-modeler environment

Conda environment and bootstrap scripts for [NeuralAmp Modeler](https://github.com/sdatkinson/neural-amp-modeler)

Read the instruction here, also you can download `input.wav` and `output.wav`
to the local `work` folder: [tutorial](https://neural-amp-modeler.readthedocs.io/en/latest/tutorials/full.html)

## install

```shell
# first, make an isolated Conda environment with Python, Poetry and CUDA inside
$ make env-init-conda

# then install the most of the dependencies with Poetry
$ make env-init-poetry
```

## run

Copy `input.wav` and `output.wav` to the `work` folder.

```shell
# run training
$ make run
```

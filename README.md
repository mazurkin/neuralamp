# neural-amp-modeler environment

Conda environment and bootstrap scripts for [NeuralAmp Modeler](https://github.com/sdatkinson/neural-amp-modeler)

Read the instruction here, download `input.wav` and `output.wav` to the local `work` folder:
- [tutorial](https://neural-amp-modeler.readthedocs.io/en/latest/tutorials/full.html)
- [configs](https://github.com/sdatkinson/neural-amp-modeler/tree/main/nam_full_configs)

## install

```shell
# first, make an isolated Conda environment with Python, Poetry and CUDA inside
$ make env-init-conda

# then install the most of the dependencies with Poetry
$ make env-init-poetry
```

## run

After copying `input.wav` and `output.wav` to the `work` folder:

```shell
# run training
$ make run
```

Which runs:

```shell
@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
    nam-full \
        "$(ROOT)/nam_full_configs/data/default.json" \
        "$(ROOT)/nam_full_configs/models/wavenet.json" \
        "$(ROOT)/nam_full_configs/learning/default.json" \
        "$(ROOT)/work"
```

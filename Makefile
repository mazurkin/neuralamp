SHELL := /bin/bash
ROOT  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

CONDA_ENV_NAME = neuralamp

# -----------------------------------------------------------------------------
# notebook
# -----------------------------------------------------------------------------

.DEFAULT_GOAL = run

# -----------------------------------------------------------------------------
# conda environment
# -----------------------------------------------------------------------------

.PHONY: env-init-conda
env-init-conda:
	@conda create --yes --copy --name "$(CONDA_ENV_NAME)" \
		conda-forge::python=3.12.12 \
		conda-forge::poetry=2.3.1 \
		conda-forge::ffmpeg==5.1.2 \
		nvidia::cuda=13.0.2

.PHONY: env-init-poetry
env-init-poetry:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry install --no-root --no-directory

.PHONY: env-update
env-update:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry update

.PHONY: env-list
env-list:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		poetry show

.PHONY: env-remove
env-remove:
	@conda env remove --yes --name "$(CONDA_ENV_NAME)"

.PHONY: env-shell
env-shell:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)"\
		bash

.PHONY: env-info
env-info:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		conda info

# -----------------------------------------------------------------------------
# run
# -----------------------------------------------------------------------------

.PHONY: run
run:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		nam-full \
			"$(ROOT)/nam_full_configs/data/single_pair.json" \
			"$(ROOT)/nam_full_configs/models/wavenet.json" \
			"$(ROOT)/nam_full_configs/learning/demo.json" \
			"$(ROOT)/work"

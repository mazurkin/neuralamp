SHELL := /bin/bash
ROOT  := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

RSYNC          = rsync --archive --verbose --compress --rsh='ssh -o ClearAllForwardings=yes'

REMOTE_HOST   ?= pp-neuralamp
REMOTE_PATH   ?= projects/neuralamp

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
		poetry show --tree

.PHONY: env-remove
env-remove:
	@conda env remove --yes --name "$(CONDA_ENV_NAME)"

.PHONY: env-shell
env-shell:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" --cwd "$(ROOT)" \
		poetry run --no-interaction \
			bash

.PHONY: env-info
env-info:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		conda info

# -----------------------------------------------------------------------------
# tensorboard
# -----------------------------------------------------------------------------

.PHONY: tensorboard
tensorboard:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		tensorboard \
			--logdir "$(ROOT)/work/" \
			--load_fast false \
			--host "127.0.0.1" \
			--port "38001"

# -----------------------------------------------------------------------------
# run
# -----------------------------------------------------------------------------

.PHONY: run-wavenet
run-wavenet: export PYTHONOPTIMIZE=1
run-wavenet: export PYTHONDONTWRITEBYTECODE=1
run-wavenet: export PYTHONUNBUFFERED=1
run-wavenet: export OMP_NUM_THREADS=1
run-wavenet: export CUDA_VISIBLE_DEVICES=0
run-wavenet:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		nam-full \
			--no-plots \
			"$(ROOT)/config/local/data.json" \
			"$(ROOT)/config/models/wavenet.json" \
			"$(ROOT)/config/local/learning.json" \
			"$(ROOT)/work"

.PHONY: run-lstm
run-lstm: export PYTHONOPTIMIZE=1
run-lstm: export PYTHONDONTWRITEBYTECODE=1
run-lstm: export PYTHONUNBUFFERED=1
run-lstm: export OMP_NUM_THREADS=1
run-lstm: export CUDA_VISIBLE_DEVICES=0
run-lstm:
	@conda run --no-capture-output --live-stream --name "$(CONDA_ENV_NAME)" \
		nam-full \
			--no-plots \
			"$(ROOT)/config/local/data.json" \
			"$(ROOT)/config/models/lstm.json" \
			"$(ROOT)/config/local/learning.json" \
			"$(ROOT)/work"

# -----------------------------------------------------------------------------
# rsync push
# -----------------------------------------------------------------------------

.PHONY: rsync-push
rsync-push:
	@$(RSYNC) \
		--exclude='/.git' \
		--exclude='/.idea' \
		--exclude='*.log' \
		--exclude='__pycache__' \
		--exclude='.pytest_cache' \
		--exclude='.ipynb_checkpoints' \
		'$(ROOT)/' \
		'$(REMOTE_HOST):$(REMOTE_PATH)/'

# -----------------------------------------------------------------------------
# rsync pull
# -----------------------------------------------------------------------------

.PHONY: rsync-pull
rsync-pull:
	@$(RSYNC) \
		--rsh="ssh -o ClearAllForwardings=yes" \
		--exclude='/.git' \
		--exclude='/.idea' \
		--exclude='*.log' \
		--exclude='__pycache__' \
		--exclude='.pytest_cache' \
		--exclude='.ipynb_checkpoints' \
		'$(REMOTE_HOST):$(REMOTE_PATH)/' \
		'$(ROOT)/'

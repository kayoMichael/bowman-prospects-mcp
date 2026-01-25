IMAGE_NAME = baseball-clip-train
CONTAINER_NAME = $(IMAGE_NAME)-ctr
PYTHON = python3
SCRIPT = image_classification_model/clip_model.py

LR ?= 5e-6
EPOCHS ?= 15
BATCH_SIZE ?= 8
ACC_STEPS ?= 4

CUSTOM ?= 0
FETCH ?= 0
RESET ?= 0

ARGS = --lr $(LR) --epochs $(EPOCHS) --batch-size $(BATCH_SIZE) --accumulation-steps $(ACC_STEPS)

ifeq ($(CUSTOM),1)
ARGS += --custom-dataset
endif

ifeq ($(FETCH),1)
ARGS += --fetch-data
endif

ifeq ($(RESET),1)
ARGS += --reset-to-base
endif

cpu-build:
	docker build -t $(IMAGE_NAME) -f dockerfile .

train-cpu:
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		-v $(PWD):/app \
		$(IMAGE_NAME) \
		python3 $(SCRIPT) $(ARGS)

train-mps:
	python -m image_classification_model.clip_model $(ARGS)

train-cpu-bash:
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		-v $(PWD):/app \
		$(IMAGE_NAME) bash \
		python3 $(SCRIPT) $(ARGS)

clean:
	docker system prune -f

run-mcp:
	python context/main.py

# Standardize Makefile for React projects
# This Makefile provides common commands for React projects, including:
# - install: Install dependencies
# - start: Start the development server
# - build: Build the project for production
# - test: Run tests
# - lint: Run ESLint to check for code quality issues
# - clean: Remove node_modules and build artifacts

# ═══════════════════════════════════════════════════════════════
# Makefile — React Application
# ═══════════════════════════════════════════════════════════════

.PHONY: print-env help install dev build lint fmt test check clean check-all \
		# Docker targets
		docker-login build-image run-container push-images pull-images docker-exec docker-clean \
		host-arch buildx-version install-qemu-binfmt buildx-create buildx-inspect buildx-list \
		buildx-build-push buildx-manifest buildx-run-arm64 buildx-run-amd64 buildx-clean
		

# Colors for output
YELLOW := \033[0;33m
GREEN  := \033[0;32m
RED    := \033[0;31m
NC     := \033[0m


# Load .env variables if .env.local file exists (Alternatively, you can load .env or other .env.* files as needed)
ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' ./.env)
endif

DOCKER_REPO := ${DOCKER_REPO}
IMAGE_NAME := ${IMAGE_NAME}
MULTI_PLATFORM_IMAGE_NAME := ${MULTI_PLATFORM_IMAGE_NAME}
DOCKER_DRIVER := ${DOCKER_DRIVER}
CONTAINER_NAME := ${CONTAINER_NAME}
TAG_VERSION := ${TAG_VERSION}
HOST_PORTS := ${HOST_PORTS}
CONTAINER_PORT := ${CONTAINER_PORT}
PACKAGE_JSON := $(shell [ -f package.json ])
CURRENT_USER := $(shell whoami)

# Default target
help: ## Show available commands
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


# ═══════════════════════════════════════════════════════════════
# Print Environment Variables (for debugging)
# ═══════════════════════════════════════════════════════════════
print-env: ## Print all environment variables (for debugging)
	@echo "$(YELLOW)Current Environment Variables:$(NC)"
	@env | grep -E '^(DOCKER_REPO|IMAGE_NAME|MULTI_PLATFORM_IMAGE_NAME|DOCKER_DRIVER|CONTAINER_NAME|TAG_VERSION|HOST_PORTS|CONTAINER_PORT)=' || echo "No relevant environment variables found."	


# ═══════════════════════════════════════════════════════════════
# Runtime Tests and Checks
# ═══════════════════════════════════════════════════════════════

check-all: ## Run lint and tests with runtime detection
	@echo "$(YELLOW) Running lint and test checks...$(NC)"
	@$(MAKE) lint
	@$(MAKE) test

install: ## Install dependencies
	@echo "Installing dependencies...[1/7]"
	@npm install
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

dev: ## Start React development server
	@echo "Starting React development server...[2/7]"
	@npm start

build: ## Build React app for production
	@echo "Building React app for production...[3/7]"
	@npm run build
	@echo "$(GREEN)✅ Build complete — output in build/$(NC)"

fmt: ## Format code with Prettier
	@echo "Formatting code...[4/7]"
	@npx prettier --write src/
	@echo "$(GREEN)✅ Formatting complete$(NC)"

lint: ## Lint code with ESLint
	@echo "Linting code...[5/7]"
	@npx eslint src/ --quiet || (echo "$(RED)🚫 ESLint failed.$(NC)" && exit 1)
	@echo "$(GREEN)✅ Linting Completed & ESLint passed.$(NC)"

test: ## Run tests with React Testing Library
	@echo "Running tests...[6/7]"
	@if find tests/ -name "*.test.js" -o -name "*.spec.js" 2>/dev/null | grep -q .; then \
		npm test -- --watchAll=false || (echo "$(RED)🚫 Tests failed.$(NC)" && exit 1); \
		echo "$(GREEN)✅ Tests passed & Completed.$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  No JS tests found. Skipping.$(NC)"; \
	fi

check: fmt check-all ## Run all checks & optionally can add fmt to run formatting before checks (mirrors pre-push guardrails)
	@echo "$(GREEN)✅ All checks passed — safe to push$(NC)"

clean: ## Remove build artifacts and dependencies
	@echo "Cleaning...[7/7]"
	@rm -rf node_modules/ build/ .eslintcache
	@echo "✅ Clean complete"


# ═══════════════════════════════════════════════════════════════
# Docker Installation
# ═══════════════════════════════════════════════════════════════
docker-install: ## Docker Installation
	@echo "1. Adding Docker GPG Key..."
	sudo apt update -y
	sudo apt install -y ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	@echo "2. Adding Repository..."
	echo "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $$(. /etc/os-release && echo "$${VERSION_CODENAME}") stable" | \
	sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	@echo "3. Installing Docker Engines..."
	sudo apt update -y
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

	@echo "4. Enabling and Starting Services..."
	sudo systemctl enable docker
	sudo systemctl start docker

	@echo "5. Running Post-Installation (User Groups)..."
	sudo groupadd docker || true
	sudo usermod -aG docker $(CURRENT_USER)
	newgrp docker
	@echo "Docker Installation Completed"

# ═══════════════════════════════════════════════════════════════
# Docker Orchestration for Frontend UI (Application)
# ═══════════════════════════════════════════════════════════════
docker-login: ## Docker Login
	@echo "Login to Docker Hub via CLI locally"
	@docker login -u ${DOCKER_REPO}

build-image: ## Build Docker image locally
	@echo "Build Docker New docker Image locally...."
	@docker build --build-arg GEMINI_API_KEY=${VITE_GEMINI_API_KEY} -t ${IMAGE_NAME}:${TAG_VERSION} .

run-container: ## Run Image as a Container
	@echo "Running Container using built image...."
	@docker run --name ${CONTAINER_NAME} -p ${HOST_PORTS}:${CONTAINER_PORT} -d ${IMAGE_NAME}:${TAG_VERSION}

push-images: ## Tag & Push Image to Docker Hub
	@echo "Tagging Docker image"
	@docker tag ${IMAGE_NAME}:${TAG_VERSION} ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}

	@echo "Pushing Tagged Image to Docker Registry"
	@docker push ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}

pull-images: ## Pull Docker Images
	@echo "Pulling docker Image...."
	@docker pull ${DOCKER_REPO}/${IMAGE_NAME}:${TAG_VERSION}


docker-exec: ## Connect to Docker Container via Terminal
	@docker exec -it ${CONTAINER_NAME} /bin/sh

docker-clean: ## Stop Container && Remove Image
# Stop Docker Container
	@echo "Stopping Container...."
	@docker stop ${CONTAINER_NAME}

# Remove Docker Container
	@echo "Removing Container...."
	@docker rm ${CONTAINER_NAME}

# Remove Docker Images
	@echo "Removing Image from Local Host /var/lib/docker/image"
	@docker rmi ${IMAGE_NAME}:${TAG_VERSION}
	@echo "$(GREEN)✅ Docker cleanup complete$(NC)"


# ═════════════════════════════════════════════════════════════════════
# Multi-Platform Using Docker Buildx (for ARM64 and AMD64 architectures)
# ═════════════════════════════════════════════════════════════════════

host-arch: ## Detect OS & Host Architecture (amd64 or arm64)
	@echo "Detecting Host Architecture..."
	@echo "OS Information:"
	@cat /etc/os-release | sed -n '1,6p' 2>/dev/null || echo "OS info not available"
	@echo "Host Architecture: $$(uname -m)"

buildx-version: ## Check Docker Buildx Version
	@echo "Checking Docker Buildx Version..."
	@export DOCKER_BUILDKIT=1
	@docker buildx version

install-qemu-binfmt: ## Install QEMU binfmt Emulator for multi-platform builds
	@echo "Installing QEMU binfmt for multi-platform builds..."
	@docker run --privileged --rm tonistiigi/binfmt --install all

buildx-create: ## Create multi-arch using Docker Buildx Builder   
	@echo "Creating Docker Buildx Builder instance..."
	@docker buildx create --name ${MULTI_PLATFORM_IMAGE_NAME} --driver ${DOCKER_DRIVER} --use || true

buildx-inspect: ## Inspect Docker Buildx Builder instance
	@echo "Inspecting Docker Buildx Builder instance..."
	@docker buildx inspect ${MULTI_PLATFORM_IMAGE_NAME} --bootstrap

buildx-list: ## List Docker Buildx Builder instances
	@echo "Listing Docker Buildx Builder instances..."
	@docker buildx ls

buildx-build-push: ## Build and Push multi-arch image using Docker Buildx
	@echo "Building and pushing multi-arch image using Docker Buildx..."
	@docker buildx build --platform linux/amd64,linux/arm64 \
		-t ${DOCKER_REPO}/${MULTI_PLATFORM_IMAGE_NAME}:${TAG_VERSION} --push .

buildx-manifest: ## Verify pushed multi-arch image manifest
	@echo "Verifying pushed multi-arch image manifest..."
	@docker buildx imagetools inspect ${DOCKER_REPO}/${MULTI_PLATFORM_IMAGE_NAME}:${TAG_VERSION}

buildx-run-arm64: ## Run ARM64 image on AMD64 host using Buildx QEMU emulation
	@echo "Cleaning existing ARM64 container..."
	@docker rm -f ${CONTAINER_NAME}-arm64 2>/dev/null || true
	@echo "Running ARM64 image on AMD64 host using Buildx QEMU emulation..."
	@docker run --platform linux/arm64 \
		-p ${HOST_PORTS}:${CONTAINER_PORT} \
		--name ${CONTAINER_NAME}-arm64 -d \
		${DOCKER_REPO}/${MULTI_PLATFORM_IMAGE_NAME}:${TAG_VERSION}

buildx-run-amd64: ## Run AMD64 image on ARM64 host using Buildx QEMU emulation
	@echo "Cleaning existing AMD64 container..."
	@docker rm -f ${CONTAINER_NAME}-amd64 2>/dev/null || true
	@echo "Running AMD64 image on ARM64 host using Buildx QEMU emulation..."
	@docker run --platform linux/amd64 \
		-p ${HOST_PORTS}:${CONTAINER_PORT} \
		--name ${CONTAINER_NAME}-amd64 -d \
		${DOCKER_REPO}/${MULTI_PLATFORM_IMAGE_NAME}:${TAG_VERSION}

buildx-clean: ## Clean up Buildx builder and multi-arch images
	@echo "Cleaning up Buildx builder and multi-arch images..."
	@docker rm -f ${CONTAINER_NAME}-arm64 ${CONTAINER_NAME}-amd64 2>/dev/null || true
	@docker buildx rm ${MULTI_PLATFORM_IMAGE_NAME} 2>/dev/null || true
	@docker rmi ${DOCKER_REPO}/${MULTI_PLATFORM_IMAGE_NAME}:${TAG_VERSION} 2>/dev/null || true
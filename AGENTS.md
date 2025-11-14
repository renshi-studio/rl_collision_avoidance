# Repository Guidelines

## Project Structure & Module Organization
- Root scripts: `install.sh`, `train.sh`, `utils.sh`, `ga3c_cadrl_aws.sh`.
- RL core: `ga3c/GA3C/` (training loop, `Run.py`, `Config.py`).
- Gym environment: `gym-collision-avoidance/gym_collision_avoidance/` (envs, policies, experiments, tests).
- Docs and assets: `docs/`.

## Build, Test, and Development Commands
- Install (creates venv, pulls Git LFS, installs deps):
  - `./install.sh`
- Train (phase 1 or 2; sets GA3C config via env):
  - `./train.sh TrainPhase1`
  - `./train.sh TrainPhase2`
  - Example override: `GYM_CONFIG_CLASS=TrainPhase1 GYM_CONFIG_PATH=$PWD/ga3c/GA3C/Config.py ./train.sh`.
- Run unit tests (unittest-based in the gym submodule):
  - `python -m unittest discover -s gym-collision-avoidance/gym_collision_avoidance/tests -v`

## Coding Style & Naming Conventions
- Language: Python 3.4–3.7 (TensorFlow 1.15). Use 4 spaces, PEP 8.
- Modules and files: `snake_case.py`. Classes: `PascalCase`. Constants: `UPPER_SNAKE_CASE`.
- Config classes in `ga3c/GA3C/Config.py` use `PascalCase` (e.g., `TrainPhase1`, `TrainPhase2`).
- Keep functions small and documented with short docstrings. Avoid large inline prints; prefer logging hooks already present.

## Testing Guidelines
- Framework: `unittest` with files like `tests/test_*.py`.
- Tests may write plots/results under `gym_collision_avoidance/experiments/results/`; do not commit generated artifacts.
- Aim to cover new environment logic, config changes, and deterministic utilities.

## Commit & Pull Request Guidelines
- Commits: concise, present tense (e.g., "update gym pointer", "fix config"). No strict Conventional Commits used historically; include scope when helpful.
- PRs: include a clear description, rationale, run instructions, and any relevant logs/plots (as links). Reference issues (e.g., `Fixes #123`).
- Changes affecting training should note expected reward ranges and config deltas.

## Security & Configuration Tips
- Git LFS is required for checkpoints; `./install.sh` initializes it.
- Set `USE_WANDB` and `LOAD_FROM_WANDB_RUN_ID` in `Config.py` to manage experiment tracking and loading.
- macOS: if `fork()` errors occur, set `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` before training.

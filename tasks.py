# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Invoke tasks - a Python-equivelant of a Makefile or Rakefile.
# http://www.pyinvoke.org/

# LINTING NOTE: invoke doesn't support annotations in task signatures.
# https://github.com/pyinvoke/invoke/issues/777
# Workaround: add "  # noqa: ANN001, ANN201"

import os
import sys
from typing import List

from invoke import task

venv = "source ./venv/bin/activate"
APP = os.environ.get("APP")
PROJECT_ID = os.environ.get("PROJECT_ID")
SERVICE_ACCOUNT = os.environ.get("SERVICE_ACCOUNT")
IMAGE = os.environ.get("IMAGE")
REGION = os.environ.get("REGION", "us-central1")
REPOSITORY = os.environ.get("REPOSITORY", "chugai")
CB_YAML = os.environ.get("CB_YAML", "cloudbuild.yaml")
SRC_DIR = os.environ.get("SRC_DIR", ".")
PORT = os.environ.get("PORT", "8080")

@task
def require_environ(c):  # noqa: ANN001, ANN201
    environ_dict = {
        "APP": APP,
        "PROJECT_ID": PROJECT_ID,
        "SERVICE_ACCOUNT": SERVICE_ACCOUNT,
        "IMAGE": IMAGE,
        "REGION": REGION,
        "REPOSITORY": REPOSITORY,
        "CB_YAML": CB_YAML,
        "SRC_DIR": SRC_DIR,
        "PORT": PORT,
    }
    missing_envs = []
    for key, val in environ_dict.items():
        """(Check) Require environ be defined"""
        if val is None:
            missing_envs.append(key)
    if len(missing_envs) > 0:
        print("The following environment variables are not defined. They are required for task")
        print(missing_envs)
        sys.exit(1)

@task
def require_project(c):  # noqa: ANN001, ANN201
    """(Check) Require PROJECT_ID be defined"""
    if PROJECT_ID is None:
        print("PROJECT_ID not defined. Required for task")
        sys.exit(1)


@task
def require_venv(c, test_requirements=False, quiet=True):  # noqa: ANN001, ANN201
    """(Check) Require that virtualenv is setup, requirements installed"""

    c.run("python -m venv venv")
    quiet_param = " -q" if quiet else ""

    with c.prefix(venv):
        c.run(f"pip install -r requirements.txt {quiet_param}")

        if test_requirements:
            c.run(f"pip install -r requirements-test.txt {quiet_param}")


@task
def require_venv_test(c):  # noqa: ANN001, ANN201
    """(Check) Require that virtualenv is setup, requirements (incl. test) installed"""
    require_venv(c, test_requirements=True)


@task
def setup_virtualenv(c):  # noqa: ANN001, ANN201
    """Create virtualenv, and install requirements, with output"""
    require_venv(c, test_requirements=True, quiet=False)


@task(pre=[require_venv])
def start(c):  # noqa: ANN001, ANN201
    """Start the web service"""
    with c.prefix(venv):
        c.run("python app.py")


@task(pre=[require_venv])
def dev(c):  # noqa: ANN001, ANN201
    """Start the web service in a development environment, with fast reload"""
    with c.prefix(venv):
        c.run("uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload")


@task(pre=[require_venv])
def lint(c):  # noqa: ANN001, ANN201
    """Run linting checks"""
    #"--import-order-style=google "
    #f"--application-import-names {','.join(local_names)} "
    with c.prefix(venv):
        # local_names = _determine_local_import_names(".")
        c.run(
            "flake8 --exclude venv "
            "--max-line-length=88 "
            "--ignore=E121,E123,E126,E203,E226,E24,E266,E501,E704,W503,W504,I202"
        )


def _determine_local_import_names(start_dir: str) -> List[str]:
    """Determines all import names that should be considered "local".
    This is used when running the linter to insure that import order is
    properly checked.
    """
    file_ext_pairs = [os.path.splitext(path) for path in os.listdir(start_dir)]
    return [
        basename
        for basename, extension in file_ext_pairs
        if extension == ".py"
        or os.path.isdir(os.path.join(start_dir, basename))
        and basename not in ("__pycache__")
    ]


@task(pre=[require_venv])
def fix(c):  # noqa: ANN001, ANN201
    """Apply linting fixes"""
    with c.prefix(venv):
        c.run("black *.py **/*.py --force-exclude venv")
        c.run("isort --profile google *.py **/*.py")


@task(pre=[require_environ])
def build(c):  # noqa: ANN001, ANN201
    """Build the service into a container image"""
    c.run(
        f"gcloud builds submit --config={CB_YAML} "
        f"--substitutions=_LOCATION={REGION},_REPOSITORY={REPOSITORY},_IMAGE={IMAGE} {SRC_DIR}"        
    )


@task(pre=[require_environ])
def deploy(c):  # noqa: ANN001, ANN201
    """Deploy the container into Cloud Run (fully managed)"""
    c.run(
	    f"gcloud run deploy ${APP} " \
        f"--image {REGION}-docker.pkg.dev/{PROJECT_ID}/{REPOSITORY}/{IMAGE} "
        f"--region us-central1 " \
        f"--port {PORT} " \
        f"--platform managed " \
        f"--service-account {SERVICE_ACCOUNT} "
    )


@task(pre=[require_venv_test])
def test(c):  # noqa: ANN001, ANN201
    """Run unit tests"""
    with c.prefix(venv):
        c.run("pytest test/test_app.py")


@task(pre=[require_venv_test])
def system_test(c):  # noqa: ANN001, ANN201
    """Run system tests"""
    with c.prefix(venv):
        c.run("pytest test/test_system.py")

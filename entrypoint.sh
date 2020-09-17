#!/bin/sh -l
set -x

REPOSITORY_BRANCH=$1

git clone --single-branch --branch "$REPOSITORY_BRANCH" "https://github.com/$GITHUB_REPOSITORY.git" /github/main-branch/
# Assure that the tests are the originals
rm -rf /github/workspace/tests
cp -r /github/main-branch/tests /github/workspace

# Install deps and run pytest over the student source
cd /github/workspace
python3 -m pip install -r requirements.txt
python3 -m pytest --json=/tmp/report.json

# Run evaluator over pytest result assuring that the requirements file is the original
python3 /home/evaluation.py /tmp/report.json /github/main-branch/.trybe/requirements.json > /tmp/evaluation_result.json
printf "$(cat /tmp/evaluation_result.json)\n"

if [ $? != 0 ]; then
  printf "Execution error $?"
  exit 1
fi

echo ::set-output name=result::`cat /tmp/evaluation_result.json | base64 -w 0`

#!/bin/bash

git add .
git commit -m "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
git push $*

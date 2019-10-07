#!/bin/bash

gcloud compute instances create reddit-app-full\
  --image-family reddit-full\
  --tags puma-server\
  --restart-on-failure

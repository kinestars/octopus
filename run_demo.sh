#!/usr/bin/env bash
user_id="$1"
python infer_single.py sample /ai_data/input/$user_id/segmentations /ai_data/input/$user_id/keypoints --out_dir /ai_data/input/$user_id/
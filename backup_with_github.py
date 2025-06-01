#!/usr/bin/env python3
"""Backup script với GitHub token"""
import os

if os.path.exists('github_token.txt'):
    print("✅ GitHub token found")
    print("🚀 Running backup with push to GitHub...")
    exec(open('backup_end_day.py').read())
else:
    print("❌ github_token.txt not found!")
    print("Run: python3 setup_github_token.py")

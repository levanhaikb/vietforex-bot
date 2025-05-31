
import os
import json
import subprocess
from datetime import datetime

class GitHubAutoSync:
    def __init__(self):
        self.project_root = os.getcwd()
        
    def complete_step(self, step_name, files_created, achievements, issues="None"):
        """Gọi khi hoàn thành 1 bước"""
        print(f"🔄 Processing step: {step_name}")
        
        # 1. Cập nhật progress
        self.update_progress_tracker(step_name, files_created, achievements, issues)
        
        # 2. Tạo step summary  
        self.create_step_summary(step_name, files_created, achievements, issues)
        
        # 3. Auto commit (nếu có git)
        self.auto_commit_to_github(step_name, files_created)
        
        print(f"✅ Step '{step_name}' completed and logged!")
    
    def update_progress_tracker(self, step_name, files_created, achievements, issues):
        """Cập nhật PROGRESS.md"""
        
        progress_update = f"""
## ✅ {step_name} - COMPLETED
**Date:** {datetime.now().strftime('%d/%m/%Y %H:%M')}
**Files Created:** {', '.join(files_created)}
**Achievements:** 
{chr(10).join([f'- ✅ {a}' for a in achievements])}
**Issues:** {issues}
**Status:** Complete

---
"""
        
        # Append to PROGRESS.md
        if os.path.exists('PROGRESS.md'):
            with open('PROGRESS.md', 'a', encoding='utf-8') as f:
                f.write(progress_update)
        else:
            with open('PROGRESS.md', 'w', encoding='utf-8') as f:
                f.write(f"# 🎯 VIETFOREX BOT PROGRESS TRACKER\n\n{progress_update}")
    
    def create_step_summary(self, step_name, files_created, achievements, issues):
        """Tạo summary chi tiết"""
        
        step_summary = {
            "step_name": step_name,
            "completed_at": datetime.now().isoformat(),
            "files_created": files_created,
            "achievements": achievements,
            "issues_encountered": issues,
            "status": "completed"
        }
        
        # Save step summary
        safe_name = step_name.lower().replace(" ", "_").replace(":", "")
        with open(f'step_summaries/{safe_name}.json', 'w') as f:
            json.dump(step_summary, f, indent=2, ensure_ascii=False)
    
    def auto_commit_to_github(self, step_name, files_created):
        """Tự động commit (nếu có git setup)"""
        try:
            if os.path.exists('.git'):
                subprocess.run(['git', 'add', '.'], check=True)
                
                commit_message = f"✅ COMPLETED: {step_name}\n\nFiles: {', '.join(files_created)}"
                subprocess.run(['git', 'commit', '-m', commit_message], check=True)
                
                print("✅ Git commit successful")
            else:
                print("⚠️ No git repository found - skipping commit")
        except Exception as e:
            print(f"⚠️ Git commit failed: {e}")

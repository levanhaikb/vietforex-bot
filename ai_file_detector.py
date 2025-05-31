
import json
from datetime import datetime

class AIFileDetector:
    def __init__(self):
        self.github_repo = "https://github.com/levanhaikb/vietforex-bot"
        
    def generate_ai_briefing(self):
        """Tạo briefing cho AI"""
        
        # Đọc progress hiện tại
        try:
            with open('current_progress.json', 'r') as f:
                progress = json.load(f)
                current_step = progress['current_step']
        except:
            current_step = "Unknown step"
        
        # Xác định files cần thiết
        required_files = self.get_required_files_for_ai(current_step)
        
        # Tạo briefing
        briefing = self.create_ai_briefing_template(current_step, required_files)
        
        # Lưu briefing
        with open('AI_BRIEFING_CURRENT.md', 'w', encoding='utf-8') as f:
            f.write(briefing)
        
        print("✅ AI briefing generated: AI_BRIEFING_CURRENT.md")
        return briefing
    
    def get_required_files_for_ai(self, current_step):
        """Files AI cần đọc dựa trên bước hiện tại"""
        
        base_files = [
            "PROGRESS.md",
            "current_progress.json"
        ]
        
        step_specific_files = {
            "Day 8": ["src/colab/vietforex_api.py"],
            "Day 9": ["src/colab/vietforex_api.py", "notebooks/day8_api_testing.ipynb"],
            "Day 10": ["src/colab/data_processor.py"],
            "Day 11": ["src/colab/feature_engineer.py"],
            "Day 12": ["src/colab/model_trainer.py"],
            "Day 15": ["src/telegram-bot/index.js"],
            "Day 17": ["src/telegram-bot/signal_sender.js"]
        }
        
        # Tìm files cho step hiện tại
        for key in step_specific_files:
            if key in current_step:
                return base_files + step_specific_files[key]
        
        return base_files
    
    def create_ai_briefing_template(self, current_step, required_files):
        """Tạo template cho AI"""
        
        template = f"""# 🤖 AI BRIEFING - {current_step}

## 📋 TO UNDERSTAND CURRENT SITUATION

Please read these files in order:

### 1. Essential Context:
{chr(10).join([f'- {f}' for f in required_files[:2]])}

### 2. Current Step Files:
{chr(10).join([f'- {f}' for f in required_files[2:]])}

## 🎯 PROJECT INFO
**Current Step:** {current_step}
**GitHub:** {self.github_repo}
**Architecture:** Google Colab ↔ VPS API ↔ Telegram Bot

## 🚨 WHAT I NEED HELP WITH
[USER WILL ADD SPECIFIC ISSUE HERE]

## 📁 AFTER READING FILES, PLEASE TELL ME:
1. What additional files do you need to see?
2. What context is missing?
3. Which files should I prioritize sharing?

---
*Generated: {datetime.now().strftime('%d/%m/%Y %H:%M')}*
"""
        
        return template

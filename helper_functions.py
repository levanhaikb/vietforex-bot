
from auto_github_sync import GitHubAutoSync
from ai_file_detector import AIFileDetector

def complete_current_step(step_name, files_created, achievements, issues="None"):
    """Function dễ sử dụng để hoàn thành bước"""
    
    print(f"🎯 Completing: {step_name}")
    
    # 1. Sync to progress tracking
    sync = GitHubAutoSync()
    sync.complete_step(step_name, files_created, achievements, issues)
    
    # 2. Generate AI briefing
    detector = AIFileDetector()
    detector.generate_ai_briefing()
    
    # 3. Update current progress
    import json
    from datetime import datetime
    
    # Extract day number from step name
    day_num = 8  # Default
    if "Day" in step_name:
        try:
            day_num = int(step_name.split("Day")[1].split(":")[0].strip())
        except:
            pass
    
    progress_data = {
        "current_week": 2 if day_num <= 14 else 3,
        "current_day": day_num,
        "current_step": step_name,
        "last_updated": datetime.now().isoformat()
    }
    
    with open('current_progress.json', 'w') as f:
        json.dump(progress_data, f, indent=2)
    
    print("\n🎉 STEP COMPLETED!")
    print(f"📁 Files logged: {len(files_created)} files")
    print(f"🎯 Achievements: {len(achievements)} items")
    print("📋 AI briefing ready for next chat")
    print("\n📂 GitHub status: Ready for commit")

def show_current_status():
    """Hiển thị status hiện tại"""
    import json
    
    try:
        with open('current_progress.json', 'r') as f:
            progress = json.load(f)
        
        print("📊 CURRENT STATUS:")
        print(f"Week: {progress['current_week']}")
        print(f"Day: {progress['current_day']}")
        print(f"Step: {progress['current_step']}")
        print(f"Updated: {progress['last_updated']}")
        
    except Exception as e:
        print(f"❌ Could not read status: {e}")

def prepare_for_ai_chat():
    """Chuẩn bị cho chat AI mới"""
    
    detector = AIFileDetector()
    briefing = detector.generate_ai_briefing()
    
    template = """
Xin chào! VietForex Bot project tiếp tục.

📂 GITHUB: https://github.com/levanhaikb/vietforex-bot

🎯 ĐỌC CÁC FILES:
1. PROGRESS.md (project progress)
2. AI_BRIEFING_CURRENT.md (current step details)
3. current_progress.json (current status)

🚨 VẤN ĐỀ HIỆN TẠI:
[Mô tả vấn đề cụ thể ở đây]

📋 Sau khi đọc, cho tôi biết:
1. Cần files gì thêm?
2. Context nào còn thiếu?
3. Files nào ưu tiên đọc trước?

Ready to help?
"""
    
    print("🤖 TEMPLATE FOR NEW AI CHAT:")
    print("="*50)
    print(template)
    print("="*50)
    print("\n📋 Copy template above for new chat!")
    
    return template

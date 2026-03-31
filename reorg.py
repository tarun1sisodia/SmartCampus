import os
import shutil
import glob

base = 'lib/features/teacher/screens'

# Mappings from screen name (without _screen.dart) to existing variant folder if different
variant_folder_map = {
    'teacher_messages': 'messages',
    'teacher_settings': 'settings'
}

count = 0

for file in os.listdir(base):
    if file.endswith('_screen.dart'):
        feature = file.replace('_screen.dart', '')
        os.makedirs(os.path.join(base, feature, 'variants'), exist_ok=True)
        shutil.move(os.path.join(base, file), os.path.join(base, feature, file))
        count += 1
        print(f"Moved {file} to {feature}/")
        
        var_folder = variant_folder_map.get(feature, feature)
        var_path = os.path.join(base, 'variants', var_folder)
        
        if os.path.isdir(var_path):
            if feature == 'reports' or feature == 'attendance_reports':
                pass # handeled below
            else:
                for v in os.listdir(var_path):
                    shutil.move(os.path.join(var_path, v), os.path.join(base, feature, 'variants', v))
                    print(f"Moved variant {v} to {feature}/variants/")

# Handle loose dashboard variants
dashboard_vars = glob.glob(os.path.join(base, 'variants', 'dashboard_*.dart'))
os.makedirs(os.path.join(base, 'dashboard', 'variants'), exist_ok=True)
for dv in dashboard_vars:
    shutil.move(dv, os.path.join(base, 'dashboard', 'variants', os.path.basename(dv)))
    print(f"Moved loose dashboard {os.path.basename(dv)}")

# Handle mixed reports variants
reports_var_path = os.path.join(base, 'variants', 'reports')
if os.path.isdir(reports_var_path):
    os.makedirs(os.path.join(base, 'reports', 'variants'), exist_ok=True)
    os.makedirs(os.path.join(base, 'attendance_reports', 'variants'), exist_ok=True)
    for rv in os.listdir(reports_var_path):
        if rv.startswith('attendance_reports_'):
            shutil.move(os.path.join(reports_var_path, rv), os.path.join(base, 'attendance_reports', 'variants', rv))
        elif rv.startswith('reports_'):
            shutil.move(os.path.join(reports_var_path, rv), os.path.join(base, 'reports', 'variants', rv))
        print(f"Moved report variant {rv}")

print(f"Done restructuring. Moved {count} root screens.")

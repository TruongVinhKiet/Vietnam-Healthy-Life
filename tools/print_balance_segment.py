from pathlib import Path
p = Path('d:/new/my_diary/lib/widgets/add_meal_dialog.dart')
s = p.read_text(encoding='utf-8')
lines = s.splitlines()
count = 0
for i,l in enumerate(lines,1):
    count += l.count('{') - l.count('}')
    if 1160 <= i <= 1200 or 2200 <= i <= len(lines):
        print(f"{i:4d} [{count:3d}]: {l}")
print('\nfinal balance:', count)

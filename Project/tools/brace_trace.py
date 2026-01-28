from pathlib import Path
p = Path('d:/new/my_diary/lib/widgets/add_meal_dialog.dart')
s = p.read_text(encoding='utf-8')
lines = s.splitlines()
count = 0
maxcount = 0
maxline = None
for i,l in enumerate(lines,1):
    count += l.count('{') - l.count('}')
    if count > maxcount:
        maxcount = count
        maxline = i
    if i>=1 and i%50==0:
        pass
print('final count:', count)
print('max imbalance', maxcount, 'at line', maxline)
for i in range(max(1,maxline-3), min(len(lines), maxline+3)+1):
    print(f"{i:4d}: {lines[i-1]}")

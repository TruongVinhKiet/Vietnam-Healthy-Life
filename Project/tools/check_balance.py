import sys
from pathlib import Path

pairs = {'(':')','{':'}','[':']'}
opens = set(pairs.keys())
closes = set(pairs.values())

for rel in sys.argv[1:]:
    p = Path('d:/new/my_diary') / rel
    if not p.exists():
        print(f"File not found: {p}")
        continue
    s = p.read_text(encoding='utf-8')
    counts = {k: s.count(k) for k in '(){}[]'}
    print(f"\n{rel}: ")
    print('counts:', counts)
    # simple stack check
    stack = []
    line = 1
    error_pos = None
    for i,ch in enumerate(s):
        if ch == '\n':
            line += 1
        if ch in opens:
            stack.append((ch,line,i))
        elif ch in closes:
            if not stack:
                error_pos = ('unmatched_close', ch, line, i)
                break
            last, lnum, idx = stack.pop()
            if pairs[last] != ch:
                error_pos = ('mismatch', last, ch, lnum, line, i)
                break
    if error_pos:
        print('Balance error:', error_pos)
        print('stack size:', len(stack))
        if stack:
            print('stack items (open tokens with line):')
            for it in stack:
                print(' ', it)
        # show context around error index
        try:
            err_idx = error_pos[-1]
            start = max(0, err_idx - 40)
            end = min(len(s), err_idx + 40)
            excerpt = s[start:end]
            print('\n--- context around error (approx) ---')
            print(excerpt.replace('\n','\\n'))
            print('--- end context ---\n')
        except Exception:
            pass
    else:
        if stack:
            print('Unclosed opens count:', len(stack))
            print('unclosed stack (from bottom to top):')
            for it in stack:
                print(' ', it)
                # show context around the top unclosed token
            try:
                err_idx = stack[-1][2]
                start = max(0, err_idx - 120)
                end = min(len(s), err_idx + 120)
                excerpt = s[start:end]
                print('\n--- context around top unclosed (approx) ---')
                print(excerpt.replace('\n','\\n'))
                print('--- end context ---\n')
            except Exception:
                pass
        else:
            print('All balanced (simple check)')

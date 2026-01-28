import os
import re

def replace_localhost_in_file(filepath):
    """Replace http://localhost:60491 with ApiConfig.baseUrl reference"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Check if file already imports ApiConfig
        has_import = 'import \'../config/api_config.dart\'' in content or 'import \'package:my_diary/config/api_config.dart\'' in content
        
        # Replace patterns
        replacements = [
            (r'http://localhost:60491', '${ApiConfig.baseUrl}'),
            (r"'http://localhost:60491'", 'ApiConfig.baseUrl'),
            (r'"http://localhost:60491"', 'ApiConfig.baseUrl'),
            (r'static const String baseUrl = ApiConfig\.baseUrl;', 'static String get baseUrl => ApiConfig.baseUrl;'),
            (r'static const _baseUrl = ApiConfig\.baseUrl;', 'static String get _baseUrl => ApiConfig.baseUrl;'),
        ]
        
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)
        
        # Add import if changes were made and import doesn't exist
        if content != original_content and not has_import:
            # Find the import section
            import_match = re.search(r"(import [^\n]+;\n)+", content)
            if import_match:
                last_import_end = import_match.end()
                # Insert after last import
                content = (content[:last_import_end] + 
                          "import '../config/api_config.dart';\n" + 
                          content[last_import_end:])
        
        # Write back if changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    project_root = r"d:\New folder (2)\new\Project\lib"
    dart_files = []
    
    # Find all .dart files
    for root, dirs, files in os.walk(project_root):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"Found {len(dart_files)} Dart files")
    modified = 0
    
    for filepath in dart_files:
        if replace_localhost_in_file(filepath):
            modified += 1
            print(f"Modified: {os.path.relpath(filepath, project_root)}")
    
    print(f"\nModified {modified} files")

if __name__ == '__main__':
    main()

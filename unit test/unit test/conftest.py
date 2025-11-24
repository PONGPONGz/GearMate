# Test Suite Configuration
# This file ensures Python can find the api modules when running tests

import sys
from pathlib import Path

# Add the parent directory to the Python path so we can import from api/
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

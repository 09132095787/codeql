from create_database_utils import *
import os

os.environ["CODEQL_EXTRACTOR_CSHARP_BUILDLESS_MONO_PATH"] = "/non-existent-path"
run_codeql_database_create([], lang="csharp", extra_args=["--extractor-option=buildless=true"])

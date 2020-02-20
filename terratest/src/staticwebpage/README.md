### [Go](https://golang.org/doc/install) installation

- Clean: The step removes all generated and temporary files that are generated during test executions.
- Format: The step runs terraform fmt and go fmt to format your code base.
- Unit: The step runs all unit tests (by using the function name convention TestUT\_\*) under the ./test/ folder.
- Integration: The step is similar to Unit, but instead of unit tests, it executes integration tests (TestIT\_\*).
- Full: The step runs Clean, Format, Unit, and Integration in sequence.

```bash
$ cd [Your GoPath]/src/staticwebpage
GoPath/src/staticwebpage$ dep init    # Run only once for this folder
GoPath/src/staticwebpage$ dep ensure  # Required to run if you imported new packages in magefile or test cases
GoPath/src/staticwebpage$ go fmt      # Only required when you change the magefile
GoPath/src/staticwebpage$ az login    # Required when no service principal environment variables are present
GoPath/src/staticwebpage$ mage
```

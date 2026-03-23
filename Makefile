DOTNET := dotnet
SCAFFOLD_TESTS := scaffold/tests

.PHONY: build test coverage lint clean

build:
	$(DOTNET) build --configuration Release

test:
	@for f in $(SCAFFOLD_TESTS)/*.sh; do \
	  echo "--- $$f ---"; \
	  sh "$$f" || exit 1; \
	done

coverage:
	$(DOTNET) test --collect:"XPlat Code Coverage" --results-directory ./coverage-results
	@echo "Coverage report generated in ./coverage-results"

lint:
	$(DOTNET) format --verify-no-changes

clean:
	find . -type d -name bin -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name obj -exec rm -rf {} + 2>/dev/null || true
	rm -rf coverage-results

frozen-requirements.txt:
	pip install -r submodules/ores/requirements.txt && \
	pip install -r submodules/editquality/requirements.txt && \
	pip install -r submodules/wikiclass/requirements.txt && \
	pip install -r requirements.txt && \
	pip freeze | \
	  grep -v ores | grep -v editquality | grep -v wikiclass | \
	  grep -v setuptools | grep -v pkg-resources > \
	frozen-requirements.txt

deployment_wheels:
	mkdir -p wheels && \
	pip wheel -r frozen-requirements.txt -w wheels


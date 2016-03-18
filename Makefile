deployment_wheels:
	mkdir -p wheels && \
	pip wheel -r frozen-requirements.txt -w wheels

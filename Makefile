RUN=~/run/TreMoR
INTERNALWEBPRODUCTS=${INTERNALWEBPRODUCTS}
 
html:
	rsync -r --dry-run html/* ${INTERNALWEBPRODUCTS}/html

rtexec:
	cp rtexec.pf ${RUN}/

startup:
	cp startup_tremor.m ${RUN}/

mkdir:
	cd ${RUN}
	mkdir 1mindata logs db dbmaster pf rtsys state  


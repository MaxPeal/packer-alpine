#define GetFromVERSION
##$(shell node -p "require('./version.json').$(1)" || jq $(1) ./version.json)
#$(shell node -p "require('./alpine-iso-install.json').$(1)" || jq $(1) ./alpine-iso-install.json)
#endef

#define GetFromVERSION
# $(shell command -v node && node -p "require('./version.json').$(1)")
# $(shell command -v jq && jq $(1) ./alpine-iso-install.json)


#define GetFromVERSION-old
#$(shell [ $(command -v node) ] && node -p "require('./version.json').$(1)")
#$(shell [ $(command -v jq) ] && jq $(1) ./alpine-iso-install.json)
#endef

define GetFromVERSION
$(shell jq -r $(1) ./alpine-iso-install.json)
endef


LAST_VERSION := $(call GetFromVERSION, .variables.box_version)
BOX_NAME := $(call GetFromVERSION, .variables.box_name)
OUT_DIR := $(call GetFromVERSION, .variables.out_dir)
#PROJECT      := $(call GetFromVERSION,name)
#LAST_VERSION := $(call GetFromVERSION,version)
#DESCRIPTION  := $(call GetFromVERSION,description)
#PROJECT_URL  := $(call GetFromVERSION,repository.url)

.PHONY: run

run:
	#echo ${LAST_VERSION}

clean:
	echo ${LAST_VERSION}
	rm -rf output-virtualbox-iso
	#rm -rf output-box
	#vagrant destroy

build:
	packer build alpine-iso-install.json

upload:
	echo "packer build -var 'box_version=${LAST_VERSION}' -var 'box_name=${BOX_NAME}' -var 'out_dir=${OUT_DIR}' alpine-iso-install-upload-to-VagrantCloud.json"
	packer build -var 'box_version=${LAST_VERSION}' -var 'box_name=${BOX_NAME}' -var 'out_dir=${OUT_DIR}' alpine-iso-install-upload-to-VagrantCloud.json

add-box:
#	vagrant box add alpine-clean-${LAST_VERSION} ../output-box/alpine-clean-${LAST_VERSION}_virtualbox.box
	vagrant box add alpine-clean-${LAST_VERSION} ${OUT_DIR}/${BOX_NAME}-${LAST_VERSION}_virtualbox.box

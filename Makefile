
APP_NAME := ocamlorg

MANUAL_DIR := "/var/www/data/manualwiki"
API_DIR := "/var/www/data/apiwiki"

SERVER_FILES := \
  src/ocsforge_color_tokens.ml \
  src/ocsforge_default_lexer.ml \
  src/ocsforge_color.ml \
  src/ocaml_lexer.ml \
  src/oo_wiki_ext.ml

CLIENT_FILES := # src/plop.eliom

PORT := 8080

SERVER_PACKAGE := extlib,ocsimore.wiki_site
CLIENT_PACKAGE := ocsimore_client.site
ELIOMCFLAGS := -I _server/src
ELIOMOPTFLAGS := -I _server/src
ELIOMDEPFLAGS_SERVER := -I src

OCSIMORE_STATIC := ../ocsimore/local/var/www/static/

###

all: local byte opt

LIBDIR := local/lib
JSDIR  := local/var/www/static

include Makefile.common
-include Makefile.local

distclean::
	-rm -r local

####

DIRS = local/var/lib/ocsidbm local/var/run local/var/log \
       local/lib local/etc

local: ${DIRS} local/var/www/static local/var/www/ocsimore_static

local/var/www/static:
	mkdir -p $@

local/var/www/ocsimore_static:
	mkdir -p $(basename local/var/www)
	ln -fs ../../../${OCSIMORE_STATIC} $@

${DIRS}:
	mkdir -p $@

local/etc/${APP_NAME}.p${PORT}.conf: files/${APP_NAME}.conf.in
	sed -e "s|%%SRC%%|$$(pwd)|" \
	    -e "s|%%APPNAME%%|${APP_NAME}|" \
	    -e "s|%%LIBDIR%%|${LIBDIR}|" \
	    -e "s|%%JSDIR%%|${JSDIR}|" \
	    -e "s|%%PORT%%|${PORT}|" \
            -e "s|%%MANUAL_DIR%%|${MANUAL_DIR}|" \
            -e "s|%%API_DIR%%|${API_DIR}|" \
	    $< > $@

run.local: local/etc/${APP_NAME}.p${PORT}.conf
	ocsigenserver -c local/etc/${APP_NAME}.p${PORT}.conf ${DEBUG}

run.opt.local: local/etc/${APP_NAME}.p${PORT}.conf
	ocsigenserver.opt -c local/etc/${APP_NAME}.p${PORT}.conf ${DEBUG}

####


src/ocsforge_default_lexer.ml: src/ocsforge_default_lexer.mll
	ocamllex -o $@ $^

src/ocaml_lexer.ml: src/ocaml_lexer.mll
	ocamllex -o $@ $^

src/ocaml_lexer.mll: src/ocaml/parsing/lexer.mll
	patch -o $@ $^ src/ocaml_lexer.patch

####

INSTALL_DIR := /var/www/${APP_NAME}

install::
	cd files/data && \
	  find \( -type d -and ! -type l \) -exec install -d -m 775 ${INSTALL_USER} ${INSTALL_DIR}/static/{} \;
	cd files/data && \
	  find ! \( -type d -or -type l \) -exec install -D -m 664 ${INSTALL_USER} {} ${INSTALL_DIR}/static/{} \;
	cd files/data && \
	  sudo -u www-data find -type l -exec cp -d {} ${INSTALL_DIR}/static/{} \;
	install -d -m 775 ${INSTALL_USER} ${INSTALL_DIR}/ocsimore_static
	install -m 664 ${INSTALL_USER} \
	  ${OCSIMORE_STATIC}/* \
	  ${INSTALL_DIR}/ocsimore_static
	install -m 644 ${INSTALL_USER} \
	  local/var/www/static/site.css \
	  ${INSTALL_DIR}/static
	install -m 644 ${INSTALL_USER} \
	  local/var/www/static/${APP_NAME}.js \
	  ${INSTALL_DIR}/static

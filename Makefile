DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
lockdir = /var/lock
runtimedir = /var/run
sbindir = /usr/sbin
sysconfdir = /etc
sudoers_dir = ${sysconfdir}/sudoers.d

ACL_DIR = ${STATE_DIR}/acl
CMD_DIR = ${libexecdir}/girar
CONF_DIR = ${sysconfdir}/girar
EMAIL_ALIASES = ${CONF_DIR}/aliases
EMAIL_DIR = ${STATE_DIR}/email
EMAIL_DOMAIN = altlinux.org
GEARS_DIR = /gears
GITWEB_URL = http://git.altlinux.org
GIT_TEMPLATE_DIR = ${girar_datadir}/templates
HOOKS_DIR = ${girar_datadir}/hooks
MAINTAINERS_GROUP = maintainers
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
CACHE_DIR = ${STATE_DIR}/cache
UPLOAD_DIR = ${STATE_DIR}/upload
PEOPLE_DIR = /people
PLUGIN_DIR = ${libexecdir}/girar
RUNTIME_DIR = ${runtimedir}/girar
RUN_AS = @RUN_AS@
SOCKDIR = @SOCKDIR@
SOCKGRP = @SOCKGRP@
SRPMS_DIR = /srpms
STATE_DIR = ${localstatedir}/girar
TASKS_DIR = /tasks
TASKS_GROUP = tasks
USERS_GROUP = girar-users
USER_PREFIX = git_
girar_datadir = ${datadir}/girar
girar_lockdir = ${lockdir}/girar
girar_sbindir = ${sbindir}

WARNINGS = -W -Wall -Waggregate-return -Wcast-align -Wconversion \
	-Wdisabled-optimization -Wmissing-declarations \
	-Wmissing-format-attribute -Wmissing-noreturn \
	-Wmissing-prototypes -Wpointer-arith -Wredundant-decls \
	-Wshadow -Wstrict-prototypes -Wwrite-strings
CPPFLAGS = -std=gnu99 ${WARNINGS} \
	-DCMD_DIR=\"${CMD_DIR}\" \
	-DGEARS_DIR=\"${GEARS_DIR}\" \
	-DPEOPLE_DIR=\"${PEOPLE_DIR}\" \
	-DPLUGIN_DIR=\"${PLUGIN_DIR}\" \
	-DSRPMS_DIR=\"${SRPMS_DIR}\" \
	-DSOCKDIR=\"${SOCKDIR}\" \
	-DRUN_AS=\"${RUN_AS}\" \
	-DUSER_PREFIX=\"${USER_PREFIX}\"
CFLAGS = -pipe -O2

bin_TARGETS = \
	bin/find-subscribers \
	bin/girar-charset \
	bin/girar-clone \
	bin/girar-default-branch \
	bin/girar-find \
	bin/girar-gen-people-packages-list \
	bin/girar-get-email-address \
	bin/girar-hooks-sh-functions \
	bin/girar-init-db \
	bin/girar-ls \
	bin/girar-mv-db \
	bin/girar-quota \
	bin/girar-repack \
	bin/girar-rm-db \
	bin/girar-sh \
	bin/girar-sh-config \
	bin/girar-sh-functions \
	bin/girar-sh-tmpdir \
	#

hooks_TARGETS = \
	hooks/post-receive \
	hooks/post-update \
	hooks/update \
	#

hooks_update_TARGETS = \
	hooks/update.d/girar-update-check-refs \
	hooks/update.d/girar-update-etc \
	#

hooks_receive_TARGETS = \
	hooks/post-receive.d/girar-etc \
	hooks/post-receive.d/girar-sendmail \
	#

lib_TARGETS = lib/rsync.so

admin_TARGETS = \
	admin/girar-add \
	admin/girar-admin-sh-functions \
	admin/girar-auth-add \
	admin/girar-auth-zero \
	admin/girar-del \
	admin/girar-disable \
	admin/girar-enable \
	admin/girar-make-template-repos \
	#

sudoers_TARGETS = sudoers/girar

TARGETS = \
	${admin_TARGETS} \
	${bin_TARGETS} \
	${hooks_TARGETS} \
	${hooks_receive_TARGETS} \
	${hooks_update_TARGETS} \
	${lib_TARGETS} \
	${sudoers_TARGETS} \
	#

.PHONY: all install install-bin install-check install-data \
	install-lib install-sbin install-sudoers install-var

all: ${TARGETS}

install: install-bin install-check install-data install-lib \
	install-sbin install-sudoers install-var

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${CMD_DIR}
	install -pm755 $^ ${DESTDIR}${CMD_DIR}/

install-data: ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}
	install -d -m750 \
		${DESTDIR}${girar_datadir} \
		${DESTDIR}${HOOKS_DIR} \
		${DESTDIR}${HOOKS_DIR}/update.d \
		${DESTDIR}${HOOKS_DIR}/post-receive.d \
		${DESTDIR}${GIT_TEMPLATE_DIR} \
		#
	install -pm750 ${hooks_TARGETS} ${DESTDIR}${HOOKS_DIR}/
	install -pm750 ${hooks_update_TARGETS} ${DESTDIR}${HOOKS_DIR}/update.d/
	install -pm750 ${hooks_receive_TARGETS} ${DESTDIR}${HOOKS_DIR}/post-receive.d/
	ln -snf ${HOOKS_DIR} ${DESTDIR}${GIT_TEMPLATE_DIR}/hooks

install-lib: ${lib_TARGETS}
	install -d -m750 ${DESTDIR}${PLUGIN_DIR}
	install -pm644 $^ ${DESTDIR}${PLUGIN_DIR}/

install-sbin: ${admin_TARGETS}
	install -d -m755 ${DESTDIR}${girar_sbindir}
	install -pm700 $^ ${DESTDIR}${girar_sbindir}/

install-sudoers: ${sudoers_TARGETS}
	install -d -m700 ${DESTDIR}${sudoers_dir}
	install -pm400 $^ ${DESTDIR}${sudoers_dir}/

install-var:
	install -d -m750 \
		${DESTDIR}${EMAIL_DIR} \
		${DESTDIR}${EMAIL_DIR}/packages \
		${DESTDIR}${EMAIL_DIR}/private \
		${DESTDIR}${EMAIL_DIR}/public \
		${DESTDIR}${STATE_DIR} \
		${DESTDIR}${STATE_DIR}/acl \
		${DESTDIR}${STATE_DIR}/awaiter \
		${DESTDIR}${STATE_DIR}/awaiter/.cache \
		${DESTDIR}${STATE_DIR}/awaiter/.qa-cache \
		${DESTDIR}${STATE_DIR}/awaiter/.qa-cache/rpmelfsym \
		${DESTDIR}${STATE_DIR}/cache \
		${DESTDIR}${STATE_DIR}/pender \
		${DESTDIR}${STATE_DIR}/repo \
		${DESTDIR}${STATE_DIR}/upload/{copy,lockdir,log} \
		${DESTDIR}${TASKS_DIR} \
		${DESTDIR}${TASKS_DIR}/archive \
		${DESTDIR}${TASKS_DIR}/archive/{.trash,done,eperm,failed,failure,new,postponed,tested} \
		${DESTDIR}${TASKS_DIR}/index \
		${DESTDIR}${girar_lockdir} \
		${DESTDIR}${girar_lockdir}/awaiter \
		${DESTDIR}${girar_lockdir}/pender \
		${DESTDIR}/people \
		#

bin/girar-sh: bin/girar-sh.c

lib/rsync.so: lib/rsync.c
	$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -fpic -shared -ldl -o $@

%: %.in
	sed \
	    -e 's,@ACL_DIR@,${ACL_DIR},g' \
	    -e 's,@CMD_DIR@,${CMD_DIR},g' \
	    -e 's,@CONF_DIR@,${CONF_DIR},g' \
	    -e 's,@EMAIL_ALIASES@,${EMAIL_ALIASES},g' \
	    -e 's,@EMAIL_DIR@,${EMAIL_DIR},g' \
	    -e 's,@EMAIL_DOMAIN@,${EMAIL_DOMAIN},g' \
	    -e 's,@GEARS_DIR@,${GEARS_DIR},g' \
	    -e 's,@GITWEB_URL@,${GITWEB_URL},g' \
	    -e 's,@GIT_TEMPLATE_DIR@,${GIT_TEMPLATE_DIR},g' \
	    -e 's,@HOOKS_DIR@,${HOOKS_DIR},g' \
	    -e 's,@PACKAGES_EMAIL@,${PACKAGES_EMAIL},g' \
	    -e 's,@CACHE_DIR@,${CACHE_DIR},g' \
	    -e 's,@PEOPLE_DIR@,${PEOPLE_DIR},g' \
	    -e 's,@RUNTIME_DIR@,${RUNTIME_DIR},g' \
	    -e 's,@RUN_AS@,${RUN_AS},g' \
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SRPMS_DIR@,${SRPMS_DIR},g' \
	    -e 's,@STATE_DIR@,${STATE_DIR},g' \
	    -e 's,@TASKS_DIR@,${TASKS_DIR},g' \
	    -e 's,@TASKS_GROUP@,${TASKS_GROUP},g' \
	    -e 's,@MAINTAINERS_GROUP@,${MAINTAINERS_GROUP},g' \
	    -e 's,@UPLOAD_DIR@,${UPLOAD_DIR},g' \
	    -e 's,@USERS_GROUP@,${USERS_GROUP},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@

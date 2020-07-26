DESTDIR =
datadir = /usr/share
libexecdir = /usr/libexec
localstatedir = /var/lib
lockdir = /var/lock
runtimedir = /var/run
sbindir = /usr/sbin
sysconfdir = /etc

ADMIN_DIR = ${libexecdir}/gitery-admin
ACL_DIR = ${STATE_DIR}/acl
CMD_DIR = ${libexecdir}/gitery
CONF_DIR = ${sysconfdir}/gitery
EMAIL_ALIASES = ${CONF_DIR}/aliases
EMAIL_DIR = ${STATE_DIR}/email
EMAIL_DOMAIN = altlinux.org
GEARS_DIR = /gears
GITWEB_URL = http://git.altlinux.org
GIT_TEMPLATE_DIR = ${gitery_datadir}/templates
HOOKS_DIR = ${gitery_datadir}/hooks
MAINTAINERS_GROUP = maintainers
PACKAGES_EMAIL = ALT Devel discussion list <devel@lists.${EMAIL_DOMAIN}>
CACHE_DIR = ${STATE_DIR}/cache
UPLOAD_DIR = ${STATE_DIR}/upload
PEOPLE_DIR = /people
PLUGIN_DIR = ${libexecdir}/gitery
RUNTIME_DIR = ${runtimedir}/gitery
SRPMS_DIR = /srpms
STATE_DIR = ${localstatedir}/gitery
USERS_GROUP = gitery-users
USER_PREFIX = git_
gitery_datadir = ${datadir}/gitery
gitery_lockdir = ${lockdir}/gitery
gitery_sbindir = ${sbindir}

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
	-DUSER_PREFIX=\"${USER_PREFIX}\"
CFLAGS = -pipe -O2

bin_TARGETS = \
	bin/find-subscribers \
	bin/gitery-charset \
	bin/gitery-clone \
	bin/gitery-default-branch \
	bin/gitery-find \
	bin/gitery-gen-people-packages-list \
	bin/gitery-get-email-address \
	bin/gitery-hooks-sh-functions \
	bin/gitery-init-db \
	bin/gitery-ls \
	bin/gitery-mv-db \
	bin/gitery-quota \
	bin/gitery-repack \
	bin/gitery-rm-db \
	bin/gitery-sh \
	bin/gitery-sh-config \
	bin/gitery-sh-functions \
	bin/gitery-sh-tmpdir \
	#

hooks_TARGETS = \
	hooks/pre-receive \
	hooks/post-receive \
	hooks/post-update \
	hooks/update \
	#

hooks_update_TARGETS = \
	hooks/update.d/gitery-update-check-refs \
	hooks/update.d/gitery-update-etc \
	#

hooks_receive_TARGETS = \
	hooks/post-receive.d/gitery-etc \
	hooks/post-receive.d/gitery-sendmail \
	#

admin_TARGETS = \
	admin/gitery-admin \
	admin/gitery-admin-sh-functions \
	admin/gitery-admin--auth-add \
	admin/gitery-admin--auth-clear \
	admin/gitery-admin--user-add \
	admin/gitery-admin--user-del \
	admin/gitery-admin--user-disable \
	admin/gitery-admin--user-enable \
	#

sbin_TARGETS = sbin/gitery-make-template-repos

TARGETS = \
	${admin_TARGETS} \
	${sbin_TARGETS} \
	${bin_TARGETS} \
	${hooks_TARGETS} \
	${hooks_receive_TARGETS} \
	${hooks_update_TARGETS} \
	#

.PHONY: all install install-bin install-check install-data \
	install-lib install-sbin install-var

all: ${TARGETS}

install: \
	install-admin \
	install-bin \
	install-check \
	install-data \
	install-lib \
	install-sbin \
	install-var \
	#

install-bin: ${bin_TARGETS}
	install -d -m750 ${DESTDIR}${CMD_DIR}
	install -pm755 $^ ${DESTDIR}${CMD_DIR}/

install-data: ${hooks_TARGETS} ${hooks_update_TARGETS} ${hooks_receive_TARGETS}
	install -d -m750 \
		${DESTDIR}${gitery_datadir} \
		${DESTDIR}${HOOKS_DIR} \
		${DESTDIR}${HOOKS_DIR}/update.d \
		${DESTDIR}${HOOKS_DIR}/post-receive.d \
		${DESTDIR}${GIT_TEMPLATE_DIR} \
		#
	install -pm750 ${hooks_TARGETS} ${DESTDIR}${HOOKS_DIR}/
	install -pm750 ${hooks_update_TARGETS} ${DESTDIR}${HOOKS_DIR}/update.d/
	install -pm750 ${hooks_receive_TARGETS} ${DESTDIR}${HOOKS_DIR}/post-receive.d/
	ln -snf ${HOOKS_DIR} ${DESTDIR}${GIT_TEMPLATE_DIR}/hooks

install-admin: ${admin_TARGETS}
	install -d -m700 ${DESTDIR}${ADMIN_DIR}
	install -pm700 $^ ${DESTDIR}${ADMIN_DIR}/

install-sbin: ${sbin_TARGETS}
	install -d -m755 ${DESTDIR}${gitery_sbindir}
	install -pm700 $^ ${DESTDIR}${gitery_sbindir}/

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
		${DESTDIR}${gitery_lockdir} \
		${DESTDIR}${gitery_lockdir}/awaiter \
		${DESTDIR}${gitery_lockdir}/pender \
		${DESTDIR}/people \
		#

bin/gitery-sh: bin/gitery-sh.c

%: %.in
	sed \
	    -e 's,@ACL_DIR@,${ACL_DIR},g' \
	    -e 's,@ADMIN_DIR@,${ADMIN_DIR},g' \
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
	    -e 's,@SOCKDIR@,${SOCKDIR},g' \
	    -e 's,@SRPMS_DIR@,${SRPMS_DIR},g' \
	    -e 's,@STATE_DIR@,${STATE_DIR},g' \
	    -e 's,@MAINTAINERS_GROUP@,${MAINTAINERS_GROUP},g' \
	    -e 's,@UPLOAD_DIR@,${UPLOAD_DIR},g' \
	    -e 's,@USERS_GROUP@,${USERS_GROUP},g' \
	    -e 's,@USER_PREFIX@,${USER_PREFIX},g' \
		<$< >$@
	chmod --reference=$< $@

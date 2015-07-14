# --no-sisyphus-check-out=fhs

Name: gitery
Version: 0.5
Release: alt1

Summary: git.alt server engine
License: GPLv2+
Group: System/Servers
Packager: Dmitry V. Levin <ldv@altlinux.org>

Source: %name-%version.tar

Requires(pre): shadow-utils
# due to "enable -f /usr/lib/bash/lockf lockf"
Requires: bash-builtin-lockf >= 0:0.2
# due to post-receive hook
Requires: git-core >= 0:1.5.1
# due to "locale -m"
Requires: glibc-i18ndata

#BuildRequires: perl(RPM.pm) perl(Date/Format.pm)

%description
This package contains server engine initially developed for git.alt,
including administration and user utilities, git hooks, email
subscription support and config files.

%prep
%setup

%build
%make_build

%install
%makeinstall_std

touch %buildroot/var/lib/gitery/cache/people-packages-list
mkdir -p %buildroot/etc/gitery/
cat > %buildroot/etc/gitery/aliases <<'EOF'
git-update-subscribers: /dev/null
cacher:		root
EOF

%pre
%_sbindir/groupadd -r -f gitery
%_sbindir/groupadd -r -f gitery-users
%_sbindir/groupadd -r -f gitery-admin
for u in cacher; do
	%_sbindir/groupadd -r -f $u
	%_sbindir/useradd -r -g $u -G gitery -d /var/empty -s /dev/null -c 'Gitery $u robot' -n $u ||:
done

%post
%_sbindir/gitery-make-template-repos
if [ $1 -eq 1 ]; then
	if grep -Fxqs 'AllowGroups wheel users' /etc/openssh/sshd_config; then
		sed -i 's/^AllowGroups wheel users/& gitery-users/' /etc/openssh/sshd_config
	fi
	if [ -f /etc/postfix/main.cf ]; then
		postconf=postconf
		if [ -z "$(postconf -h recipient_canonical_maps)" ]; then
			f=/etc/postfix/recipient_canonical_regexp
			if [ ! -f "$f" ]; then
				domain="$(. /usr/libexec/gitery/gitery-sh-config && echo "$EMAIL_DOMAIN" ||:)"
				[ -z "$domain" ] ||
					echo "/$domain/	root" > "$f"
			fi
			$postconf -e "recipient_canonical_maps = regexp:$f"
		fi
		alias_database="$(postconf -h alias_database ||:)"
		if ! printf %%s "$alias_database" | grep -qs /etc/gitery/aliases; then
			[ -n "$alias_database" ] &&
				alias_database="$alias_database, cdb:/etc/gitery/aliases" ||
				alias_database="cdb:/etc/gitery/aliases"
			$postconf -e "alias_database = $alias_database"
		fi
		alias_maps="$(postconf -h alias_maps ||:)"
		if ! printf %%s "$alias_maps" | grep -qs /etc/gitery/aliases; then
			[ -n "$alias_maps" ] &&
				alias_maps="$alias_maps, cdb:/etc/gitery/aliases" ||
				alias_maps="cdb:/etc/gitery/aliases"
			$postconf -e "alias_maps = $alias_maps"
		fi
	fi
	crontab -u cacher - <<-'EOF'
	#20	*	*	*	*	/usr/libexec/gitery/gitery-gen-people-packages-list
	EOF
fi

%files
%config(noreplace) %attr(400,root,root) /etc/sudoers.d/gitery
%config(noreplace) /etc/gitery/aliases
/etc/gitery/
/usr/libexec/gitery/
%_datadir/gitery/
%attr(700,root,root) %_sbindir/*

%doc LICENSE

# all the rest should be listed explicitly
%defattr(0,0,0,0)

%dir %attr(755,root,root) /people/

%dir %attr(1771,root,cacher) /var/lib/gitery/cache
%config(noreplace) %attr(644,cacher,cacher) /var/lib/gitery/cache/people-packages-list

%dir %attr(750,root,gitery) /var/lib/gitery/email/
%dir %attr(755,root,root) /var/lib/gitery/email/*

%changelog
* Wed Nov 21 2012 Dmitry V. Levin <ldv@altlinux.org> 0.5-alt1
- Imported gitery-builder.

* Fri Nov 16 2012 Dmitry V. Levin <ldv@altlinux.org> 0.4-alt1
- Imported gb-depot.

* Thu Dec 11 2008 Dmitry V. Levin <ldv@altlinux.org> 0.3-alt1
- Added task subcommands.

* Mon Jun 16 2008 Dmitry V. Levin <ldv@altlinux.org> 0.2-alt1
- Rewrote hooks using post-receive.

* Tue Nov 21 2006 Dmitry V. Levin <ldv@altlinux.org> 0.1-alt1
- Specfile cleanup.

* Fri Nov 17 2006 Alexey Gladkov <legion@altlinux.ru> 0.0.1-alt1
- Initial revision.

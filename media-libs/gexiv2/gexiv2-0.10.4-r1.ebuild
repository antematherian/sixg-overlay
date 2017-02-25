# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit eutils multilib python-r1 toolchain-funcs versionator xdg-utils

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="GObject-based wrapper around the Exiv2 library"
HOMEPAGE="https://wiki.gnome.org/Projects/gexiv2"
SRC_URI="mirror://gnome/sources/${PN}/${MY_PV}/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="introspection python static-libs"

REQUIRED_USE="python? ( introspection ${PYTHON_REQUIRED_USE} )"

RDEPEND="${PYTHON_DEPS}
	>=dev-libs/glib-2.26.1:2
	>=media-gfx/exiv2-0.21:0=
	introspection? ( dev-libs/gobject-introspection:= )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	xdg_environment_reset
	tc-export CXX
	default
}

src_configure() {
	econf \
		$(use_enable introspection) \
		$(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" LIB="$(get_libdir)" install
	dodoc AUTHORS NEWS README THANKS

	if use python ; then
		python_moduleinto gi/overrides/
		python_foreach_impl python_domodule GExiv2.py
	fi

	use static-libs || prune_libtool_files --modules
}

pkg_postinst() {
#fix blunder made by not applying the fix prerelease. 
#symlink won't be necessary with next release
#https://github.com/GNOME/gexiv2/commit/7c47e3907c4888190138c3301232e198206217fb
#applying workaround symlink
ln -s /usr/share/gir-1.0/GExiv2-0.10.typelib /usr/lib/girepository-1.0/GExiv2-0.10.typelib
}

pkg_prerm() {
	unlink /usr/lib/girepository-1.0/GExiv2-0.10.typelib
}

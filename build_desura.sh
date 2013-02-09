#!/bin/sh
printf 'Make sure to run \033[1;31msudo ./install-deps.sh\033[0m before compiling!\n\n'


PREFIX="../install"
BINDIR=""
LIBDIR="lib"
DATADIR=""


compile_cef() {
	printf 'We are compiling CEF first\n'
	if [ ! -d "build_cef" ] ; then
		mkdir build_cef
	fi
	cd build_cef
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DRUNTIME_LIBDIR=$LIBDIR -DBUILD_ONLY_CEF=ON || exit 1
	make install $args || exit 2
	cd ../
	printf "\n"
	}

compile_desurium() {
	printf 'Now we are compiling desurium\n'
	if [ ! -d "build" ] ; then
		mkdir build
	fi
	cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBINDIR=$BINDIR -DRUNTIME_LIBDIR=$LIBDIR -DDATADIR=$DATADIR -DBUILD_CEF=OFF || exit 3
	make install $args || exit 4
}



clean_cef() {
		printf "Making clean for cef...\n"
		if [ -d "build_cef" ] ; then
			cd ./build_cef/
			make clean
			cd ../
		fi
		if [ ! -d "build" ] ; then
			printf "Removing install directory...\n"
			rm -rf "install"
		fi
		echo "Done"
}

clean_desurium() {
		printf "Making clean for desurium...\n"
		if [ -d "build" ] ; then
			cd ./build/
			make clean
			cd ../
		fi
		if [ ! -d "build_cef" ] ; then
			printf "Removing install directory...\n"
			rm -rf "install"
		fi
		printf "Done\n"
}


case "$@" in
	"compile_desurium" )
		compile_desurium
		;;
	"compile_cef" )
		compile_cef
		;;
	"clean_cef" )
		clean_cef
		exit
		;;
	"clean_desurium" )
		clean_desurium
		exit
		;;
	"clean" )
		clean_cef
		clean_desurium
		exit
		;;
	*check* )
		echo "'make check' will be called."
		args=`echo "$@" | sed -e 's/check//'`
		compile_cef
		compile_desurium
		printf "Running 'make check'\n"
		# already in /build
		make test
		;;
	* )
		args=$@
		compile_cef
		compile_desurium
		;;
esac

printf 'Run \033[1;31m./install/desura\033[0m to start Desura!\n'

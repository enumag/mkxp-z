ARCH := $(shell ruby -e "puts (\`gcc -dumpmachine\`[/i686/].nil?) ? 'mingw64' : 'mingw'")
RB_PREFIX := $(shell ruby -e "puts ('$(ARCH)' == 'mingw64') ? 'x64-msvcrt' : 'msvcrt'")

SDL_FLAGS := ${SDL_FLAGS}
SDL2_IMAGE_FLAGS := ${SDL2_IMAGE_FLAGS}
SDL2_TTF_FLAGS := ${SDL2_TTF_FLAGS}
OPENAL_FLAGS := ${OPENAL_FLAGS}
OPENSSL_FLAGS := $(ARCH) ${OPENSSL_FLAGS}
RUBY_FLAGS := ${RUBY_FLAGS}

BUILD_PREFIX := ${PWD}/build-$(ARCH)
LIBDIR := $(BUILD_PREFIX)/lib
BINDIR := $(BUILD_PREFIX)/bin
INCLUDEDIR := $(BUILD_PREFIX)/include
DOWNLOADS := ${PWD}/downloads/$(ARCH)
NPROC := $(shell nproc)
CFLAGS := -I$(INCLUDEDIR) -O3
LDFLAGS := -L$(LIBDIR)
CC      := gcc
PKG_CONFIG_LIBDIR := $(BUILD_PREFIX)/lib/pkgconfig
GIT := git
CLONE := $(GIT) clone -q
GITHUB := https://github.com

CONFIGURE_ENV := \
	CMAKE_POLICY_VERSION_MINIMUM=3.10 \
	PKG_CONFIG_LIBDIR=$(PKG_CONFIG_LIBDIR) \
	CC="$(CC)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"

CONFIGURE_ARGS := --prefix="$(BUILD_PREFIX)"

CMAKE_ARGS := \
	-DCMAKE_INSTALL_PREFIX="$(BUILD_PREFIX)" \
	-DCMAKE_PREFIX_PATH="$(BUILD_PREFIX)" \
	-DCMAKE_C_FLAGS="$(CFLAGS)" \
	-DCMAKE_BUILD_TYPE=Release \
	-G "MSYS Makefiles"

RUBY_CONFIGURE_ARGS := \
	--prefix="$(shell cygpath -m ${BUILD_PREFIX})" \
	--enable-install-static-library \
	--disable-install-doc \
	--with-out-ext=readline,dbm,gdbm,win32ole \
	--with-static-linked-ext \
	--disable-rubygems \
	--without-gmp

CONFIGURE := $(CONFIGURE_ENV) ./configure $(CONFIGURE_ARGS)
AUTOGEN   := $(CONFIGURE_ENV) ./autogen.sh $(CONFIGURE_ARGS)
CMAKE     := $(CONFIGURE_ENV) cmake .. $(CMAKE_ARGS)

default: everything

# Theora
libtheora: init_dirs libvorbis libogg $(LIBDIR)/libtheora.a

$(LIBDIR)/libtheora.a: $(LIBDIR)/libogg.a $(DOWNLOADS)/theora/Makefile
	cd $(DOWNLOADS)/theora; \
	make -j$(NPROC); make install

$(DOWNLOADS)/theora/Makefile: $(DOWNLOADS)/theora/configure
	cd $(DOWNLOADS)/theora; \
	$(CONFIGURE) --with-ogg=$(BUILD_PREFIX) --enable-shared=false --enable-static=true --disable-examples

$(DOWNLOADS)/theora/configure: $(DOWNLOADS)/theora/autogen.sh
	cd $(DOWNLOADS)/theora; \
	./autogen.sh

$(DOWNLOADS)/theora/autogen.sh:
	$(CLONE) $(GITHUB)/xiph/theora $(DOWNLOADS)/theora

# Vorbis
libvorbis: init_dirs libogg $(LIBDIR)/libvorbis.a

$(LIBDIR)/libvorbis.a: $(LIBDIR)/libogg.a $(DOWNLOADS)/vorbis/cmakebuild/Makefile
	cd $(DOWNLOADS)/vorbis/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/vorbis/cmakebuild/Makefile: $(DOWNLOADS)/vorbis/CMakeLists.txt
	cd $(DOWNLOADS)/vorbis; \
	mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DBUILD_SHARED_LIBS=no

$(DOWNLOADS)/vorbis/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/vorbis $(DOWNLOADS)/vorbis


# Ogg, dependency of Vorbis
libogg: init_dirs $(LIBDIR)/libogg.a

$(LIBDIR)/libogg.a: $(DOWNLOADS)/ogg/Makefile
	cd $(DOWNLOADS)/ogg; \
	make -j$(NPROC); make install

$(DOWNLOADS)/ogg/Makefile: $(DOWNLOADS)/ogg/configure
	cd $(DOWNLOADS)/ogg; \
	$(CONFIGURE) --enable-static=true --enable-shared=false

$(DOWNLOADS)/ogg/configure: $(DOWNLOADS)/ogg/autogen.sh
	cd $(DOWNLOADS)/ogg; ./autogen.sh

$(DOWNLOADS)/ogg/autogen.sh:
	$(CLONE) $(GITHUB)/mkxp-z/ogg $(DOWNLOADS)/ogg

# Pixman
pixman: init_dirs libpng $(LIBDIR)/libpixman-1.a

$(LIBDIR)/libpixman-1.a: $(DOWNLOADS)/pixman/Makefile
	cd $(DOWNLOADS)/pixman
	make -C $(DOWNLOADS)/pixman -j$(NPROC)
	make -C $(DOWNLOADS)/pixman install

$(DOWNLOADS)/pixman/Makefile: $(DOWNLOADS)/pixman/autogen.sh
	cd $(DOWNLOADS)/pixman; \
	$(AUTOGEN) --enable-static=yes --enable-shared=no

$(DOWNLOADS)/pixman/autogen.sh:
	$(CLONE) $(GITHUB)/mkxp-z/pixman $(DOWNLOADS)/pixman


# PhysFS

physfs: init_dirs $(LIBDIR)/libphysfs.a

$(LIBDIR)/libphysfs.a: $(DOWNLOADS)/physfs/cmakebuild/Makefile
	cd $(DOWNLOADS)/physfs/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/physfs/cmakebuild/Makefile: $(DOWNLOADS)/physfs/CMakeLists.txt
	cd $(DOWNLOADS)/physfs; \
	mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DPHYSFS_BUILD_STATIC=true -DPHYSFS_BUILD_SHARED=false

$(DOWNLOADS)/physfs/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/physfs -b release-3.2.0 $(DOWNLOADS)/physfs

# libpng
libpng: init_dirs $(LIBDIR)/libpng.a

$(LIBDIR)/libpng.a: $(DOWNLOADS)/libpng/Makefile
	cd $(DOWNLOADS)/libpng; \
	make -j$(NPROC); make install

$(DOWNLOADS)/libpng/Makefile: $(DOWNLOADS)/libpng/configure
	cd $(DOWNLOADS)/libpng; \
	$(CONFIGURE) \
	--enable-shared=no --enable-static=yes

$(DOWNLOADS)/libpng/configure:
	$(CLONE) $(GITHUB)/mkxp-z/libpng $(DOWNLOADS)/libpng

# uchardet
uchardet: init_dirs $(LIBDIR)/libuchardet.a

$(LIBDIR)/libuchardet.a: $(DOWNLOADS)/uchardet/cmakebuild/Makefile
	cd $(DOWNLOADS)/uchardet/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/uchardet/cmakebuild/Makefile: $(DOWNLOADS)/uchardet/CMakeLists.txt
	cd $(DOWNLOADS)/uchardet; \
	mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DBUILD_SHARED_LIBS=no

$(DOWNLOADS)/uchardet/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/uchardet $(DOWNLOADS)/uchardet

# SDL2
sdl2: init_dirs $(LIBDIR)/libSDL2.a

$(LIBDIR)/libSDL2.a: $(DOWNLOADS)/sdl2/cmakebuild/Makefile
	cd $(DOWNLOADS)/sdl2/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/sdl2/cmakebuild/Makefile: $(DOWNLOADS)/sdl2/CMakeLists.txt
	cd $(DOWNLOADS)/sdl2; \
	mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DBUILD_SHARED_LIBS=no

$(DOWNLOADS)/sdl2/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/SDL $(DOWNLOADS)/sdl2 -b mkxp-z-2.28.1

# SDL_image
sdl2image: init_dirs sdl2 $(LIBDIR)/libSDL2_image.a

$(LIBDIR)/libSDL2_image.a: $(DOWNLOADS)/sdl2_image/cmakebuild/Makefile
	cd $(DOWNLOADS)/sdl2_image/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/sdl2_image/cmakebuild/Makefile: $(DOWNLOADS)/sdl2_image/CMakeLists.txt
	cd $(DOWNLOADS)/sdl2_image; mkdir -p cmakebuild; cd cmakebuild; \
	$(CMAKE) \
	-DBUILD_SHARED_LIBS=no \
	-DSDL2IMAGE_JPG_SAVE=yes \
	-DSDL2IMAGE_PNG_SAVE=yes \
	-DSDL2IMAGE_PNG_SHARED=no \
	-DSDL2IMAGE_JPG_SHARED=no \
	-DSDL2IMAGE_JXL=yes \
	-DSDL2IMAGE_JXL_SHARED=no \
	-DSDL2IMAGE_VENDORED=yes

$(DOWNLOADS)/sdl2_image/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/SDL_image $(DOWNLOADS)/sdl2_image -b mkxp-z; \
	cd $(DOWNLOADS)/sdl2_image; \
	./external/download.sh

# SDL_sound
sdlsound: init_dirs sdl2 libogg libvorbis $(LIBDIR)/libSDL2_sound.a

$(LIBDIR)/libSDL2_sound.a: $(DOWNLOADS)/sdl_sound/cmakebuild/Makefile
	cd $(DOWNLOADS)/sdl_sound/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/sdl_sound/cmakebuild/Makefile: $(DOWNLOADS)/sdl_sound/CMakeLists.txt
	cd $(DOWNLOADS)/sdl_sound; mkdir -p cmakebuild; cd cmakebuild; \
	$(CMAKE) \
	-DSDLSOUND_BUILD_SHARED=false \
	-DSDLSOUND_BUILD_TEST=false

$(DOWNLOADS)/sdl_sound/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/SDL_sound $(DOWNLOADS)/sdl_sound -b git

# SDL2 (ttf)
sdl2ttf: init_dirs sdl2 freetype $(LIBDIR)/libSDL2_ttf.a

$(LIBDIR)/libSDL2_ttf.a: $(DOWNLOADS)/sdl2_ttf/Makefile
	cd $(DOWNLOADS)/sdl2_ttf; \
	make -j$(NPROC); make install

$(DOWNLOADS)/sdl2_ttf/Makefile: $(DOWNLOADS)/sdl2_ttf/configure
	cd $(DOWNLOADS)/sdl2_ttf; \
	$(CONFIGURE) --enable-static=true --enable-shared=false $(SDL2_TTF_FLAGS)

$(DOWNLOADS)/sdl2_ttf/configure: $(DOWNLOADS)/sdl2_ttf/autogen.sh
	cd $(DOWNLOADS)/sdl2_ttf; ./autogen.sh

$(DOWNLOADS)/sdl2_ttf/autogen.sh:
	$(CLONE) $(GITHUB)/mkxp-z/SDL_ttf $(DOWNLOADS)/sdl2_ttf -b mkxp-z

# Freetype (dependency of SDL2_ttf)
freetype: init_dirs $(LIBDIR)/libfreetype.a

$(LIBDIR)/libfreetype.a: $(DOWNLOADS)/freetype/Makefile
	cd $(DOWNLOADS)/freetype; \
	make -j$(NPROC); make install

$(DOWNLOADS)/freetype/Makefile: $(DOWNLOADS)/freetype/configure
	cd $(DOWNLOADS)/freetype; \
	$(CONFIGURE) --enable-static=true --enable-shared=false

$(DOWNLOADS)/freetype/configure: $(DOWNLOADS)/freetype/autogen.sh
	cd $(DOWNLOADS)/freetype; ./autogen.sh

$(DOWNLOADS)/freetype/autogen.sh:
	$(CLONE) $(GITHUB)/mkxp-z/freetype2 $(DOWNLOADS)/freetype

# OpenAL
openal: init_dirs libogg $(LIBDIR)/libOpenAL32.a

$(LIBDIR)/libOpenAL32.a: $(DOWNLOADS)/openal/cmakebuild/Makefile
	cd $(DOWNLOADS)/openal/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/openal/cmakebuild/Makefile: $(DOWNLOADS)/openal/CMakeLists.txt
	cd $(DOWNLOADS)/openal; mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DLIBTYPE=STATIC -DALSOFT_EXAMPLES=no -DALSOFT_UTILS=no $(OPENAL_FLAGS)

$(DOWNLOADS)/openal/CMakeLists.txt:
	$(CLONE) $(GITHUB)/kcat/openal-soft -b 1.24.3 $(DOWNLOADS)/openal

# FluidSynth
fluidsynth: init_dirs $(LIBDIR)/libfluidsynth.a

$(LIBDIR)/libfluidsynth.a: $(DOWNLOADS)/fluidsynth/cmakebuild/Makefile
	cd $(DOWNLOADS)/fluidsynth/cmakebuild; \
	make -j$(NPROC); make install

$(DOWNLOADS)/fluidsynth/cmakebuild/Makefile: $(DOWNLOADS)/fluidsynth/CMakeLists.txt
	cd $(DOWNLOADS)/fluidsynth; mkdir cmakebuild; cd cmakebuild; \
	$(CMAKE) -DBUILD_SHARED_LIBS=no -Denable-sdl2=no -Denable-readline=no

$(DOWNLOADS)/fluidsynth/CMakeLists.txt:
	$(CLONE) $(GITHUB)/mkxp-z/fluidsynth-sans-glib $(DOWNLOADS)/fluidsynth

# OpenSSL
openssl: init_dirs $(LIBDIR)/libssl.a
$(LIBDIR)/libssl.a: $(DOWNLOADS)/openssl/Makefile
	cd $(DOWNLOADS)/openssl; \
	make -j$(NPROC); make install_sw

$(DOWNLOADS)/openssl/Makefile: $(DOWNLOADS)/openssl/Configure
	cd $(DOWNLOADS)/openssl; \
	./Configure $(OPENSSL_FLAGS) \
	--prefix="$(BUILD_PREFIX)" \
	--openssldir="$(BUILD_PREFIX)"

$(DOWNLOADS)/openssl/Configure:
	$(CLONE) $(GITHUB)/openssl/openssl $(DOWNLOADS)/openssl --single-branch --branch openssl-3.0.12 --depth 1

# Standard ruby
ruby: init_dirs openssl $(BINDIR)/$(RB_PREFIX)-ruby310.dll

$(BINDIR)/$(RB_PREFIX)-ruby310.dll: $(DOWNLOADS)/ruby/Makefile
	cd $(DOWNLOADS)/ruby; \
	make -j$(NPROC); make install

$(DOWNLOADS)/ruby/Makefile: $(DOWNLOADS)/ruby/configure
	cd $(DOWNLOADS)/ruby; \
	export $(CONFIGURE_ENV); \
	export CFLAGS="-flto $$CFLAGS"; \
	export LDFLAGS="-flto $$LDFLAGS"; \
	./configure $(CONFIGURE_ARGS) $(RUBY_CONFIGURE_ARGS) $(RUBY_FLAGS)

$(DOWNLOADS)/ruby/configure: $(DOWNLOADS)/ruby/configure.ac
	cd $(DOWNLOADS)/ruby; autoreconf -i

$(DOWNLOADS)/ruby/configure.ac:
	$(CLONE) $(GITHUB)/mkxp-z/ruby $(DOWNLOADS)/ruby --single-branch --branch mkxp-z-3.1.3 --depth 1;

# ====
init_dirs:
	@mkdir -p $(LIBDIR) $(INCLUDEDIR)

powerwash: clean-downloads

clean-downloads:
	-rm -rf downloads

deps-core: libtheora libvorbis pixman libpng physfs sdl2 sdl2image sdlsound sdl2ttf openal openssl fluidsynth uchardet
everything: deps-core ruby

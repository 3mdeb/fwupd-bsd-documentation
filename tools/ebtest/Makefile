def:
	@$(MAKE) $(MAKEFLAGS) `uname -s`

Linux: ebtest.c
	gcc -g3 \
	    -o ebtest ebtest.c \
	    -lefiboot -lefivar

OpenBSD: ebtest.c
	clang -g3 -gdwarf-2 \
	      -I/usr/local/include -L/usr/local/lib \
	      -o ebtest ebtest.c \
	      -lefiboot -lefivar

NetBSD: ebtest.c
	gcc -g3 \
	    -I/usr/pkg/include -L/usr/pkg/lib \
	    -o ebtest ebtest.c \
	    -Wl,-rpath,/usr/pkg/lib -lefiboot -lefivar

DragonFly: ebtest.c
	gcc -g3 \
	    -I/usr/local/include -L/usr/local/lib \
	    -o ebtest ebtest.c \
	    -Wl,-rpath,/usr/local/lib -lefiboot -lefivar
